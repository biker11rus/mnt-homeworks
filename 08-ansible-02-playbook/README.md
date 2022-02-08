# Домашнее задание к занятию "08.02 Работа с Playbook"

## Подготовка к выполнению
1. Создайте свой собственный (или используйте старый) публичный репозиторий на github с произвольным именем.  
https://github.com/biker11rus/mnt-homeworks/tree/MNT-7/08-ansible-02-playbook/playbook
2. Скачайте [playbook](./playbook/) из репозитория с домашним заданием и перенесите его в свой репозиторий.  
Выполнено
3. Подготовьте хосты в соотвтествии с группами из предподготовленного playbook.  
Окружение создано с помощью docker-compose   
```yaml
version: "3"
networks:
  net:
    driver: bridge
services:
  elasticsearch:
    image: pycontribs/centos:7
    container_name: elasticsearch
    ports:
      - "9200:9200"
    networks:
      - net
    tty: true
  kibana:
    image: pycontribs/centos:7
    container_name: kibana
    ports:
      - "5601:5601"
    networks:
      - net
    tty: true
```
4. Скачайте дистрибутив [java](https://www.oracle.com/java/technologies/javase-jdk11-downloads.html) и положите его в директорию `playbook/files/`.   
Выполнено

## Основная часть
1. Приготовьте свой собственный inventory файл `prod.yml`.  
```yaml
---
elasticsearch:
  hosts:
    elasticsearch:
      ansible_connection: docker
kibana:
  hosts:
    kibana:
      ansible_connection: docker
```
2. Допишите playbook: нужно сделать ещё один play, который устанавливает и настраивает kibana.  
```
- name: Install kibana
  hosts: kibana
  tasks:
    - name: Upload tar.gz kibana from remote URL
      get_url:
        url: "https://artifacts.elastic.co/downloads/kibana/kibana-{{ kibana_version }}-linux-x86_64.tar.gz"
        dest: "/tmp/kibana-{{ kibana_version }}-linux-x86_64.tar.gz"
        mode: 0755
        timeout: 60
        force: true
        validate_certs: false
      register: get_kibana
      until: get_kibana is succeeded
      tags: kibana
    - name: Create directrory for Kibana
      file:
        state: directory
        path: "{{ kibana_home }}"
        mode: "644"
      tags: kibana
    - name: Extract Kibana in the installation directory
      become: true
      unarchive:
        copy: false
        src: "/tmp/kibana-{{ kibana_version }}-linux-x86_64.tar.gz"
        dest: "{{ kibana_home }}"
        extra_opts: [--strip-components=1]
        creates: "{{ kibana_home }}/bin/kibana"
      tags:
        - kibana
    - name: Set environment Kibana
      become: true
      template:
        src: templates/kibana.sh.j2
        dest: /etc/profile.d/kibana.sh
        mode: "644"
      tags: kibana
```
3. При создании tasks рекомендую использовать модули: `get_url`, `template`, `unarchive`, `file`.
4. Tasks должны: скачать нужной версии дистрибутив, выполнить распаковку в выбранную директорию, сгенерировать конфигурацию с параметрами.
5. Запустите `ansible-lint site.yml` и исправьте ошибки, если они есть.
```bash
~/.local/bin/ansible-lint site.yml 

WARNING  Overriding detected file kind 'yaml' with 'playbook' for given positional argument: site.yml
```
6. Попробуйте запустить playbook на этом окружении с флагом `--check`.  
```bash
$ ansible-playbook -i ./inventory/prod.yml site.yml --check
[WARNING]: Found both group and host with same name: elasticsearch
[WARNING]: Found both group and host with same name: kibana

PLAY [Install Java] *************************************************************************************************************************************************

TASK [Gathering Facts] **********************************************************************************************************************************************
ok: [elasticsearch]
ok: [kibana]

TASK [Set facts for Java 11 vars] ***********************************************************************************************************************************
ok: [elasticsearch]
ok: [kibana]

TASK [Upload .tar.gz file containing binaries from local storage] ***************************************************************************************************
changed: [kibana]
changed: [elasticsearch]

TASK [Ensure installation dir exists] *******************************************************************************************************************************
changed: [kibana]
changed: [elasticsearch]

TASK [Extract java in the installation directory] *******************************************************************************************************************
An exception occurred during task execution. To see the full traceback, use -vvv. The error was: NoneType: None
fatal: [elasticsearch]: FAILED! => {"changed": false, "msg": "dest '/opt/jdk/11.0.14' must be an existing dir"}
An exception occurred during task execution. To see the full traceback, use -vvv. The error was: NoneType: None
fatal: [kibana]: FAILED! => {"changed": false, "msg": "dest '/opt/jdk/11.0.14' must be an existing dir"}

PLAY RECAP **********************************************************************************************************************************************************
elasticsearch              : ok=4    changed=2    unreachable=0    failed=1    skipped=0    rescued=0    ignored=0   
kibana                     : ok=4    changed=2    unreachable=0    failed=1    skipped=0    rescued=0    ignored=0   
```
7. Запустите playbook на `prod.yml` окружении с флагом `--diff`. Убедитесь, что изменения на системе произведены.  
```bash
ansible-playbook -i ./inventory/prod.yml site.yml --diff
[WARNING]: Found both group and host with same name: kibana
[WARNING]: Found both group and host with same name: elasticsearch

PLAY [Install Java] *************************************************************************************************************************************************

TASK [Gathering Facts] **********************************************************************************************************************************************
ok: [elasticsearch]
ok: [kibana]

TASK [Set facts for Java 11 vars] ***********************************************************************************************************************************
ok: [elasticsearch]
ok: [kibana]

TASK [Upload .tar.gz file containing binaries from local storage] ***************************************************************************************************
diff skipped: source file size is greater than 104448
changed: [kibana]
diff skipped: source file size is greater than 104448
changed: [elasticsearch]

TASK [Ensure installation dir exists] *******************************************************************************************************************************
--- before
+++ after
@@ -1,5 +1,5 @@
 {
-    "mode": "0755",
+    "mode": "0644",
     "path": "/opt/jdk/11.0.14",
-    "state": "absent"
+    "state": "directory"
 }

changed: [kibana]
--- before
+++ after
@@ -1,5 +1,5 @@
 {
-    "mode": "0755",
+    "mode": "0644",
     "path": "/opt/jdk/11.0.14",
-    "state": "absent"
+    "state": "directory"
 }

changed: [elasticsearch]

TASK [Extract java in the installation directory] *******************************************************************************************************************
changed: [elasticsearch]
changed: [kibana]

TASK [Export environment variables] *********************************************************************************************************************************
--- before
+++ after: /home/rkhozyainov/.ansible/tmp/ansible-local-54823a45huzws/tmpfhid0upd/jdk.sh.j2
@@ -0,0 +1,5 @@
+# Warning: This file is Ansible Managed, manual changes will be overwritten on next playbook run.
+#!/usr/bin/env bash
+
+export JAVA_HOME=/opt/jdk/11.0.14
+export PATH=$PATH:$JAVA_HOME/bin
\ No newline at end of file

changed: [elasticsearch]
--- before
+++ after: /home/rkhozyainov/.ansible/tmp/ansible-local-54823a45huzws/tmpm3ttzmo9/jdk.sh.j2
@@ -0,0 +1,5 @@
+# Warning: This file is Ansible Managed, manual changes will be overwritten on next playbook run.
+#!/usr/bin/env bash
+
+export JAVA_HOME=/opt/jdk/11.0.14
+export PATH=$PATH:$JAVA_HOME/bin
\ No newline at end of file

changed: [kibana]

PLAY [Install Elasticsearch] ****************************************************************************************************************************************

TASK [Gathering Facts] **********************************************************************************************************************************************
ok: [elasticsearch]

TASK [Upload tar.gz Elasticsearch from remote URL] ******************************************************************************************************************
changed: [elasticsearch]

TASK [Create directrory for Elasticsearch] **************************************************************************************************************************
--- before
+++ after
@@ -1,5 +1,5 @@
 {
-    "mode": "0755",
+    "mode": "0644",
     "path": "/opt/elastic/7.10.1",
-    "state": "absent"
+    "state": "directory"
 }

changed: [elasticsearch]

TASK [Extract Elasticsearch in the installation directory] **********************************************************************************************************
changed: [elasticsearch]

TASK [Set environment Elastic] **************************************************************************************************************************************
--- before
+++ after: /home/rkhozyainov/.ansible/tmp/ansible-local-54823a45huzws/tmpjj818ehu/elk.sh.j2
@@ -0,0 +1,5 @@
+# Warning: This file is Ansible Managed, manual changes will be overwritten on next playbook run.
+#!/usr/bin/env bash
+
+export ES_HOME=/opt/elastic/7.10.1
+export PATH=$PATH:$ES_HOME/bin
\ No newline at end of file

changed: [elasticsearch]

PLAY [Install kibana] ***********************************************************************************************************************************************

TASK [Gathering Facts] **********************************************************************************************************************************************
ok: [kibana]

TASK [Upload tar.gz kibana from remote URL] *************************************************************************************************************************
changed: [kibana]

TASK [Create directrory for Kibana] *********************************************************************************************************************************
--- before
+++ after
@@ -1,5 +1,5 @@
 {
-    "mode": "0755",
+    "mode": "0644",
     "path": "/opt/kibana/7.17.0",
-    "state": "absent"
+    "state": "directory"
 }

changed: [kibana]

TASK [Extract Kibana in the installation directory] *****************************************************************************************************************
changed: [kibana]

TASK [Set environment Kibana] ***************************************************************************************************************************************
--- before
+++ after: /home/rkhozyainov/.ansible/tmp/ansible-local-54823a45huzws/tmp0nur9jg7/kibana.sh.j2
@@ -0,0 +1,4 @@
+#!/usr/bin/env bash
+
+export ES_HOME=/opt/kibana/7.17.0
+export PATH=$PATH:$ES_HOME/bin

changed: [kibana]

PLAY RECAP **********************************************************************************************************************************************************
elasticsearch              : ok=11   changed=8    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
kibana                     : ok=11   changed=8    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
```
8. Повторно запустите playbook с флагом `--diff` и убедитесь, что playbook идемпотентен.  
```bash
ansible-playbook -i ./inventory/prod.yml site.yml --diff
[WARNING]: Found both group and host with same name: kibana
[WARNING]: Found both group and host with same name: elasticsearch

PLAY [Install Java] *************************************************************************************************************************************************

TASK [Gathering Facts] **********************************************************************************************************************************************
ok: [elasticsearch]
ok: [kibana]

TASK [Set facts for Java 11 vars] ***********************************************************************************************************************************
ok: [kibana]
ok: [elasticsearch]

TASK [Upload .tar.gz file containing binaries from local storage] ***************************************************************************************************
ok: [elasticsearch]
ok: [kibana]

TASK [Ensure installation dir exists] *******************************************************************************************************************************
ok: [elasticsearch]
ok: [kibana]

TASK [Extract java in the installation directory] *******************************************************************************************************************
skipping: [kibana]
skipping: [elasticsearch]

TASK [Export environment variables] *********************************************************************************************************************************
ok: [elasticsearch]
ok: [kibana]

PLAY [Install Elasticsearch] ****************************************************************************************************************************************

TASK [Gathering Facts] **********************************************************************************************************************************************
ok: [elasticsearch]

TASK [Upload tar.gz Elasticsearch from remote URL] ******************************************************************************************************************
ok: [elasticsearch]

TASK [Create directrory for Elasticsearch] **************************************************************************************************************************
ok: [elasticsearch]

TASK [Extract Elasticsearch in the installation directory] **********************************************************************************************************
skipping: [elasticsearch]

TASK [Set environment Elastic] **************************************************************************************************************************************
ok: [elasticsearch]

PLAY [Install kibana] ***********************************************************************************************************************************************

TASK [Gathering Facts] **********************************************************************************************************************************************
ok: [kibana]

TASK [Upload tar.gz kibana from remote URL] *************************************************************************************************************************
ok: [kibana]

TASK [Create directrory for Kibana] *********************************************************************************************************************************
ok: [kibana]

TASK [Extract Kibana in the installation directory] *****************************************************************************************************************
skipping: [kibana]

TASK [Set environment Kibana] ***************************************************************************************************************************************
ok: [kibana]

PLAY RECAP **********************************************************************************************************************************************************
elasticsearch              : ok=9    changed=0    unreachable=0    failed=0    skipped=2    rescued=0    ignored=0   
kibana                     : ok=9    changed=0    unreachable=0    failed=0    skipped=2    rescued=0    ignored=0   
```
9.  Подготовьте README.md файл по своему playbook. В нём должно быть описано: что делает playbook, какие у него есть параметры и теги.  
https://github.com/biker11rus/mnt-homeworks/blob/MNT-7/08-ansible-02-playbook/playbook/README.md
10. Готовый playbook выложите в свой репозиторий, в ответ предоставьте ссылку на него.
https://github.com/biker11rus/mnt-homeworks/blob/MNT-7/08-ansible-02-playbook/playbook/site.yml
---

### Как оформить ДЗ?

Выполненное домашнее задание пришлите ссылкой на .md-файл в вашем репозитории.

---
