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
 filename = "../inventory/hosts.yml"
}
