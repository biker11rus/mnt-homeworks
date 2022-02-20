# Домашнее задание к занятию "08.4 Работа с Roles"

## Окружение для примера
1. Виртуальные машины создаются в Яндекс облаке через terraform 
2. Inventory динамический, создается терефоромом c помощью resource "local_file" "AnsibleInventory" и шаблона inventory.tpl  
3. Добавлен ansible.cfg с host_key_checking = False

## Playbook

1. Состоит из 3 ролей: elasticsearch, kibana-role, filebeat-role, устанавливаемых через requirements.yml
2. Каждая устанавливает и конфигурирует свой сервис
3. Необходимо переопределить, например через group_vars, переменные  elasticsearch_host и kibana_host при развертывании на разные хосты на разные хосты

---
