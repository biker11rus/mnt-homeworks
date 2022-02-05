# Домашнее задание к занятию "08.01 Введение в Ansible"

## Подготовка к выполнению
1. Установите ansible версии 2.10 или выше.
2. Создайте свой собственный публичный репозиторий на github с произвольным именем.
3. Скачайте [playbook](./playbook/) из репозитория с домашним заданием и перенесите его в свой репозиторий.

## Основная часть
1. Попробуйте запустить playbook на окружении из `test.yml`, зафиксируйте какое значение имеет факт `some_fact` для указанного хоста при выполнении playbook'a.
2. Найдите файл с переменными (group_vars) в котором задаётся найденное в первом пункте значение и поменяйте его на 'all default fact'.
3. Воспользуйтесь подготовленным (используется `docker`) или создайте собственное окружение для проведения дальнейших испытаний.
4. Проведите запуск playbook на окружении из `prod.yml`. Зафиксируйте полученные значения `some_fact` для каждого из `managed host`.
5. Добавьте факты в `group_vars` каждой из групп хостов так, чтобы для `some_fact` получились следующие значения: для `deb` - 'deb default fact', для `el` - 'el default fact'.
6.  Повторите запуск playbook на окружении `prod.yml`. Убедитесь, что выдаются корректные значения для всех хостов.
7. При помощи `ansible-vault` зашифруйте факты в `group_vars/deb` и `group_vars/el` с паролем `netology`.
8. Запустите playbook на окружении `prod.yml`. При запуске `ansible` должен запросить у вас пароль. Убедитесь в работоспособности.
9. Посмотрите при помощи `ansible-doc` список плагинов для подключения. Выберите подходящий для работы на `control node`.
10. В `prod.yml` добавьте новую группу хостов с именем  `local`, в ней разместите localhost с необходимым типом подключения.
11. Запустите playbook на окружении `prod.yml`. При запуске `ansible` должен запросить у вас пароль. Убедитесь что факты `some_fact` для каждого из хостов определены из верных `group_vars`.
12. Заполните `README.md` ответами на вопросы. Сделайте `git push` в ветку `master`. В ответе отправьте ссылку на ваш открытый репозиторий с изменённым `playbook` и заполненным `README.md`.

## Необязательная часть

1. При помощи `ansible-vault` расшифруйте все зашифрованные файлы с переменными.
2. Зашифруйте отдельное значение `PaSSw0rd` для переменной `some_fact` паролем `netology`. Добавьте полученное значение в `group_vars/all/exmp.yml`.
3. Запустите `playbook`, убедитесь, что для нужных хостов применился новый `fact`.
4. Добавьте новую группу хостов `fedora`, самостоятельно придумайте для неё переменную. В качестве образа можно использовать [этот](https://hub.docker.com/r/pycontribs/fedora).
5. Напишите скрипт на bash: автоматизируйте поднятие необходимых контейнеров, запуск ansible-playbook и остановку контейнеров.
6. Все изменения должны быть зафиксированы и отправлены в вашей личный репозиторий.

---

### Ответ

1. 12
```
$ ansible-playbook site.yml -i ./inventory/test.yml 

PLAY [Print os facts] **********************************************************************************************************************************************************************

TASK [Gathering Facts] *********************************************************************************************************************************************************************
ok: [localhost]

TASK [Print OS] ****************************************************************************************************************************************************************************
ok: [localhost] => {
    "msg": "Ubuntu"
}

TASK [Print fact] **************************************************************************************************************************************************************************
ok: [localhost] => {
    "msg": 12
}

PLAY RECAP *********************************************************************************************************************************************************************************
localhost                  : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
```
2. 
```
$ ansible-playbook site.yml -i ./inventory/test.yml 

PLAY [Print os facts] **********************************************************************************************************************************************************************

TASK [Gathering Facts] *********************************************************************************************************************************************************************
ok: [localhost]

TASK [Print OS] ****************************************************************************************************************************************************************************
ok: [localhost] => {
    "msg": "Ubuntu"
}

TASK [Print fact] **************************************************************************************************************************************************************************
ok: [localhost] => {
    "msg": "all default fact"
}

PLAY RECAP *********************************************************************************************************************************************************************************
localhost                  : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
```
3. 2 докер контейнера, 1 centos:7 второй из ubuntu:20.04 c установленным python 3.9
dockerfile
```
FROM ubuntu:20.04
env DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install --no-install-recommends -y \ 
    python3.9 python3.9-dev python3.9-venv python3-pip && \
    apt-get clean && rm -rf /var/lib/apt/lists/
CMD ["/bin/bash"]
```
4. 
```bash
ansible-playbook site.yml -i ./inventory/prod.yml 

PLAY [Print os facts] ***********************************************************************************************************************************************

TASK [Gathering Facts] **********************************************************************************************************************************************
ok: [ubuntu]
ok: [centos7]

TASK [Print OS] *****************************************************************************************************************************************************
ok: [centos7] => {
    "msg": "CentOS"
}
ok: [ubuntu] => {
    "msg": "Ubuntu"
}

TASK [Print fact] ***************************************************************************************************************************************************
ok: [centos7] => {
    "msg": "el"
}
ok: [ubuntu] => {
    "msg": "deb"
}

PLAY RECAP **********************************************************************************************************************************************************
centos7                    : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
ubuntu                     : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

```
5. и 6. 
```bash
ansible-playbook site.yml -i ./inventory/prod.yml 

PLAY [Print os facts] ***********************************************************************************************************************************************

TASK [Gathering Facts] **********************************************************************************************************************************************
ok: [ubuntu]
ok: [centos7]

TASK [Print OS] *****************************************************************************************************************************************************
ok: [centos7] => {
    "msg": "CentOS"
}
ok: [ubuntu] => {
    "msg": "Ubuntu"
}

TASK [Print fact] ***************************************************************************************************************************************************
ok: [centos7] => {
    "msg": "el default fact"
}
ok: [ubuntu] => {
    "msg": "deb default fact"
}

PLAY RECAP **********************************************************************************************************************************************************
centos7                    : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
ubuntu                     : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

```
7. vault
```bash
$ ansible-vault encrypt ./group_vars/deb/* ./group_vars/el/*
```
8. Запуск с запросом пароля 
```
 ansible-playbook site.yml -i ./inventory/prod.yml --ask-vault-password
Vault password: 

PLAY [Print os facts] ***********************************************************************************************************************************************

TASK [Gathering Facts] **********************************************************************************************************************************************
ok: [ubuntu]
ok: [centos7]

TASK [Print OS] *****************************************************************************************************************************************************
ok: [centos7] => {
    "msg": "CentOS"
}
ok: [ubuntu] => {
    "msg": "Ubuntu"
}

TASK [Print fact] ***************************************************************************************************************************************************
ok: [centos7] => {
    "msg": "el default fact"
}
ok: [ubuntu] => {
    "msg": "deb default fact"
}

PLAY RECAP **********************************************************************************************************************************************************
centos7                    : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
ubuntu                     : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0  
```
9. local
```
ansible-doc -t connection -l
```
10. prod.yaml
```yaml

  el:
    hosts:
      centos7:
        ansible_connection: docker
  deb:
    hosts:
      ubuntu:
        ansible_connection: docker
  local:
    hosts:
      localhost:
        ansible_connection: local
```
11. Выполнение
```
ansible-playbook site.yml -i ./inventory/prod.yml --ask-vault-password
Vault password: 

PLAY [Print os facts] ***********************************************************************************************************************************************

TASK [Gathering Facts] **********************************************************************************************************************************************
ok: [localhost]
ok: [ubuntu]
ok: [centos7]

TASK [Print OS] *****************************************************************************************************************************************************
ok: [localhost] => {
    "msg": "Ubuntu"
}
ok: [centos7] => {
    "msg": "CentOS"
}
ok: [ubuntu] => {
    "msg": "Ubuntu"
}

TASK [Print fact] ***************************************************************************************************************************************************
ok: [localhost] => {
    "msg": "all default fact"
}
ok: [centos7] => {
    "msg": "el default fact"
}
ok: [ubuntu] => {
    "msg": "deb default fact"
}

PLAY RECAP **********************************************************************************************************************************************************
centos7                    : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
localhost                  : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
ubuntu                     : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

```

## Ответы на необязательную часть
1. Расшифровка
```bash
 ansible-vault decrypt ./group_vars/*/*

Vault password: 

Decryption successful

```
2. Шифрование переменной 
```bash
 ansible-vault encrypt_string PaSSw0rd --name some_fact

New Vault password: 

Confirm New Vault password: 

some_fact: !vault |

          $ANSIBLE_VAULT;1.1;AES256

          61623335393635663832643638373431313865336436376166336530303765616634373966663936

          6236656164616163643334373535343438386365363136370a666237326136343637373038636365

          33316337343639643231373232623530656666343831653961663732613766376564623239633632

          3039363733663763320a623335316263666333313936326336613334363334653134346338633666

          3531

Encryption successful

cat ./group_vars/all/exmp.yml 

---

some_fact: !vault |

          $ANSIBLE_VAULT;1.1;AES256

          61623335393635663832643638373431313865336436376166336530303765616634373966663936

          6236656164616163643334373535343438386365363136370a666237326136343637373038636365

          33316337343639643231373232623530656666343831653961663732613766376564623239633632

          3039363733663763320a623335316263666333313936326336613334363334653134346338633666

          3531
```
3. Проверка 
```bash
ansible-playbook site.yml -i ./inventory/prod.yml --ask-vault-password
Vault password: 

PLAY [Print os facts] ***********************************************************************************************************************************************

TASK [Gathering Facts] **********************************************************************************************************************************************
ok: [localhost]
ok: [ubuntu]
ok: [centos7]

TASK [Print OS] *****************************************************************************************************************************************************
ok: [localhost] => {
    "msg": "Ubuntu"
}
ok: [centos7] => {
    "msg": "CentOS"
}
ok: [ubuntu] => {
    "msg": "Ubuntu"
}

TASK [Print fact] ***************************************************************************************************************************************************
ok: [localhost] => {
    "msg": "PaSSw0rd"
}
ok: [centos7] => {
    "msg": "el default fact"
}
ok: [ubuntu] => {
    "msg": "deb default fact"
}

PLAY RECAP **********************************************************************************************************************************************************
centos7                    : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
localhost                  : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
ubuntu                     : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
```
4. Добавление fedora
```bash
ansible-playbook site.yml -i ./inventory/prod.yml --ask-vault-password
Vault password: 

PLAY [Print os facts] ***********************************************************************************************************************************************

TASK [Gathering Facts] **********************************************************************************************************************************************
ok: [localhost]
ok: [ubuntu]
ok: [centos7]

TASK [Print OS] *****************************************************************************************************************************************************
ok: [localhost] => {
    "msg": "Ubuntu"
}
ok: [centos7] => {
    "msg": "CentOS"
}
ok: [ubuntu] => {
    "msg": "Ubuntu"
}

TASK [Print fact] ***************************************************************************************************************************************************
ok: [localhost] => {
    "msg": "PaSSw0rd"
}
ok: [centos7] => {
    "msg": "el default fact"
}
ok: [ubuntu] => {
    "msg": "deb default fact"
}

PLAY RECAP **********************************************************************************************************************************************************
centos7                    : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
localhost                  : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
ubuntu                     : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

rkhozyainov@rkhozyainov-T530-ubuntu:~/devops/mnt-homeworks/08-ansible-01-base/playbook$ ansible-playbook site.yml -i ./inventory/prod.yml --ask-vault-password
Vault password: 

PLAY [Print os facts] ***********************************************************************************************************************************************

TASK [Gathering Facts] **********************************************************************************************************************************************
ok: [localhost]
ok: [ubuntu]
ok: [fedora]
ok: [centos7]

TASK [Print OS] *****************************************************************************************************************************************************
ok: [localhost] => {
    "msg": "Ubuntu"
}
ok: [centos7] => {
    "msg": "CentOS"
}
ok: [ubuntu] => {
    "msg": "Ubuntu"
}
ok: [fedora] => {
    "msg": "Fedora"
}

TASK [Print fact] ***************************************************************************************************************************************************
ok: [localhost] => {
    "msg": "PaSSw0rd"
}
ok: [centos7] => {
    "msg": "el default fact"
}
ok: [ubuntu] => {
    "msg": "deb default fact"
}
ok: [fedora] => {
    "msg": "fedora default fact"
}

PLAY RECAP **********************************************************************************************************************************************************
centos7                    : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
fedora                     : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
localhost                  : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
ubuntu                     : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
```
5.  Простой скрипт без проверок auto.sh
```bash
#!/bin/bash
docker stop $(docker ps -a -q)
docker rm $(docker ps -a -q)
docker run --rm -t -d --name ubuntu ubuntu:py3
docker run --rm -t -d --name centos7 centos:7
docker run --rm -t -d --name fedora pycontribs/fedora
ansible-playbook -i inventory/prod.yml --vault-pass-file pass site.yml
docker stop $(docker ps -a -q)

```

Проверка  

```bash
./auto.sh 

31df1257fdaa

"docker rm" requires at least 1 argument.

See 'docker rm --help'.



Usage:  docker rm [OPTIONS] CONTAINER [CONTAINER...]



Remove one or more containers

c1715204e5575b38317c5739ab53824ae625d989c89d57c343167c983648e605

842f57497407601c5e2e34d5b01977c73c0dde464ef39aebbf310d6e7ff87b5b

fc5df967cb0d355f72af1cd664e3499f0567cb0b2ec96c70fde185bf9fe48c5d



PLAY [Print os facts] *************************************************************************************************************************************************************************************



TASK [Gathering Facts] ************************************************************************************************************************************************************************************

ok: [localhost]

ok: [ubuntu]

ok: [fedora]

ok: [centos7]



TASK [Print OS] *******************************************************************************************************************************************************************************************

ok: [localhost] => {

    "msg": "Ubuntu"

}

ok: [ubuntu] => {

    "msg": "Ubuntu"

}

ok: [centos7] => {

    "msg": "CentOS"

}

ok: [fedora] => {

    "msg": "Fedora"

}



TASK [Print fact] *****************************************************************************************************************************************************************************************

ok: [localhost] => {

    "msg": "PaSSw0rd"

}

ok: [centos7] => {

    "msg": "el default fact"

}

ok: [ubuntu] => {

    "msg": "deb default fact"

}

ok: [fedora] => {

    "msg": "fedora default fact"

}



PLAY RECAP ************************************************************************************************************************************************************************************************

centos7                    : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

fedora                     : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

localhost                  : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

ubuntu                     : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   



fc5df967cb0d

842f57497407

c1715204e557

```

6. https://github.com/biker11rus/mnt-homeworks/tree/MNT-7/08-ansible-01-base/playbook
---