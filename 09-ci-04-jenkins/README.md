# Домашнее задание к занятию "09.04 Jenkins"

## Подготовка к выполнению

1. Создать 2 VM: для jenkins-master и jenkins-agent.
2. Установить jenkins при помощи playbook'a.
3. Запустить и проверить работоспособность.
4. Сделать первоначальную настройку.
   
### ВМ созданы в яндекс облаке 

## Основная часть

1. Сделать Freestyle Job, который будет запускать `molecule test` из любого вашего репозитория с ролью.
   
    ```
    cd kibana_role
    pip3 install -r tox-requirements.txt
    ansible-galaxy collection install community.docker
    ansible-galaxy collection install community.general
    molecule test
    ```
2. Сделать Declarative Pipeline Job, который будет запускать `molecule test` из любого вашего репозитория с ролью.

    ```
    pipeline {
        agent {
            label 'centos'
        }
        stages {
            stage('checkout') {
                steps{
                    git credentialsId: '09839795-e2da-4765-b6b7-9741b360b426', url: 'git@github.com:biker11rus/kibana-role.git'
                }
            }
            stage('requirements') {
                steps{
                    sh "pip3 install -r requirements.txt" 
                    sh "ansible-galaxy collection install community.docker"
                    sh "ansible-galaxy collection install community.general"
                }
            }
            stage('molecule'){
                steps{
                    sh "molecule test"
                }
            }
        }
    }
    ```
3. Перенести Declarative Pipeline в репозиторий в файл `Jenkinsfile`.

    ```Jenkinsfile
    pipeline {
        agent {
            label 'centos'
        }
        stages {
            stage('requirements') {
                steps{
                sh "pip3 install -r tox-requirements.txt" 
                sh "ansible-galaxy collection install community.docker"
                sh "ansible-galaxy collection install community.general"
                }
            }
            stage('molecule'){
                steps{
                    sh "molecule test"
                }
            }
        }
    }
    ```

4. Создать Multibranch Pipeline на запуск `Jenkinsfile` из репозитория.
   
   Такой же Jenkinsfile 
   
5. Создать Scripted Pipeline, наполнить его скриптом из [pipeline](./pipeline).
6. Внести необходимые изменения, чтобы Pipeline запускал `ansible-playbook` без флагов `--check --diff`, если не установлен параметр при запуске джобы (prod_run = True), по умолчанию параметр имеет значение False и запускает прогон с флагами `--check --diff`.
7. Проверить работоспособность, исправить ошибки, исправленный Pipeline вложить в репозиторий в файл `ScriptedJenkinsfile`. Цель: получить собранный стек ELK в Ya.Cloud.
   
    Создана ВМ в яндекс облаке для elk
    В jenkins добавлен плагин ansible и Credentials для подключения ssh к ВМ 
    Создан pipeline c булевым параметром prod_run
    ScriptedJenkinsfile
    ```
    node('centos'){
        stage("Git checkout"){
            git credentialsId: '09839795-e2da-4765-b6b7-9741b360b426', url: 'git@github.com:biker11rus/elk-ansible-jenkins.git'
        }
        stage("Install dependencies"){
            sh 'ansible-galaxy install -r requirements.yml -p roles'
            }
        if (params.prod_run){
            stage("Run playbook"){
                ansiblePlaybook credentialsId: '0ff298f4-8da0-4770-9f07-81dc1e0c7bb3', disableHostKeyChecking: true, inventory: 'inventory/hosts.yml', playbook: 'site.yml'
                }
        } else {
            stage('Run playbook check'){
                ansiblePlaybook credentialsId: '0ff298f4-8da0-4770-9f07-81dc1e0c7bb3', disableHostKeyChecking: true, extras: '--check --diff', inventory: 'inventory/hosts.yml', playbook: 'site.yml'
            }
                
        }
    }
    ```

8. Отправить две ссылки на репозитории в ответе: с ролью и Declarative Pipeline и c плейбукой и Scripted Pipeline.

    [Роль с jenkinsfile](https://github.com/biker11rus/kibana-role)  
    [Playbook c ScriptedJenkinsfile](https://github.com/biker11rus/elk-ansible-jenkins)


## Необязательная часть

1. Создать скрипт на groovy, который будет собирать все Job, которые завершились хотя бы раз неуспешно. Добавить скрипт в репозиторий с решеним с названием `AllJobFailure.groovy`.
2. Дополнить Scripted Pipeline таким образом, чтобы он мог сначала запустить через Ya.Cloud CLI необходимое количество инстансов, прописать их в инвентори плейбука и после этого запускать плейбук. Тем самым, мы должны по нажатию кнопки получить готовую к использованию систему.

---

### Как оформить ДЗ?

Выполненное домашнее задание пришлите ссылкой на .md-файл в вашем репозитории.

---
