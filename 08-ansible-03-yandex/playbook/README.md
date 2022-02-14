# Домашнее задание к занятию "08.03 Использование Yandex Cloud"

## Окружение
1. Виртуальные машины создаются в Яндекс облаке через terraform   
main.tf
```tf
terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "~> 0.61.0"
    }
  }
}
provider "yandex" {
  service_account_key_file = "key.json"
  cloud_id  = var.yandex_cloud_id
  folder_id = var.yandex_folder_id
  zone      = var.yandex_zone
}
module "vpc" {
  source  = "hamnsk/vpc/yandex"
  version = "0.5.0"
  description = "managed by terraform"
  yc_folder_id = var.yandex_folder_id
  name = "yc_vpc"
  subnets = local.vpc_subnets.yc_sub
}
locals {
  vpc_subnets = {
    yc_sub = [
      {
        "v4_cidr_blocks": [
          "10.128.0.0/24"
        ],
        "zone": var.yandex_zone
      }
    ]
  }
}
locals {
  instance_set = {
    el-instance = "elasticsearch"
    k-instance = "kibana"
    app-instance = "application"
  }   
}
resource "yandex_compute_instance" "vms" {
  for_each = local.instance_set
  name = each.key
  resources {
    cores  = 2
    memory = 4
  }
  boot_disk {
    initialize_params {
      image_id = var.iso_id
    }
  }
  network_interface {
    subnet_id = module.vpc.subnet_ids[0]
    nat       = true
  }
  metadata = {
    ssh-keys = "${var.user}:${file("~/.ssh/id_rsa.pub")}"
  }
  labels = {
    ansible-group = each.value
  }
}
resource "local_file" "AnsibleInventory" {
 content = templatefile("inventory.tpl",
   {
     vm-names                   = [for k, p in yandex_compute_instance.vms: p.name],
     private-ip                 = [for k, p in yandex_compute_instance.vms: p.network_interface.0.ip_address],
     public-ip                  = [for k, p in yandex_compute_instance.vms: p.network_interface.0.nat_ip_address],
     ansible-group              = [for k, p in yandex_compute_instance.vms: p.labels.ansible-group],  
     ssh_user                   = var.user
   }
 )
 filename = "../inventory/prod/hosts.yml"
}
```
variables.tf
```tf
variable "yandex_cloud_id" {
  default = "b1g99cj6gj1uugbm8csl"
}
variable "yandex_folder_id" {
  default = "b1g21i3gads8jqf0fgei"
}
variable "iso_id" {
  default = "fd8gdnd09d0iqdu7ll2a"
}
variable "yandex_zone" {
  default = "ru-central1-a"
}
variable "user" {
  default = "centos"
}
```
2. Inventory диманический, создается терефоромом c помощью resource "local_file" "AnsibleInventory" и шаблона inventory.tpl  
inventory.tpl
```
---
all:
  hosts:
%{ for index, vms in vm-names ~}
    ${vms}:
      ansible_host: ${public-ip[index]}
      local_ip: ${private-ip[index]}
%{ endfor ~}
  vars:
    ansible_connection: ssh
    ansible_user: ${ssh_user}

%{ for indexgp, group in ansible-group ~}
${group}:
  hosts:
    ${vm-names[indexgp]}:
%{ endfor ~}
```
## Playbook

1. Создано еще 2 play в site.yml, добавлены 2 конфигурации в templates, инвентори динамический, group_vars общий all.yml, добавлен ansible.cfg с host_key_checking = False  
- Install Kibana содержит 3 task  и 1 handlers
  - handler: restart kibana - Перезапуск сервиса kibana c sudo
  - task: Download kibana's rpm - скачивает rpm kibana и регистрирует переменную download_kibana, пока она не будет "is succeeded" задача будет повторяться, но не более 3 раз  
  - task: Install Kibana - устанавливает kibana с помощью yum из под sudo, с проверкой на его установку через state
  - task: Configure Kibana - формирует конфиг kibana, с помощью template из под sudo и перезапускает kibana
- Install filebeat содержит 5 task  и 1 handlers
  - handler: restart filebeat Перезапуск сервиса filebeat c sudo  
  - task: Download filebeat's rpm - скачивает rpm filebeat и регистрирует переменную download_filebeat, пока она не будет "is succeeded" задача будет повторяться, но не более 3 раз 
  - task: Install filebeat станавливает - устанавливает filebeat с помощью yum из под sudo, с проверкой на его установку через state и перезапускает filebeat
  - task: Configure filebeat - формирует конфиг filebeat, с помощью template из под sudo и перезапускает filebeat
  - task: Set filebeat systemwork - переходит в директорию с filebeat, и запускает команду на включение модулей, регистрирует переменную filebeat_modules и через changed_when и делает проверку вывод Module system is already enabled, что бы соблюсти идемпотентность
  - task: Load Kibana Dash - переходит в директорию с filebeat, и запускает команду filebeat setup что бы установить дашборды. Регистриует переменндую filebeat_setup, что бы не ломать идемпотентность changed_when: false, запуск происходит до filebeat_setup is succeeded, но не более 3 раз

---
