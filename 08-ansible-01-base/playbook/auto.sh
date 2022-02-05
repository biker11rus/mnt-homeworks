#!/bin/bash
docker stop $(docker ps -a -q)
docker rm $(docker ps -a -q)
docker run --rm -t -d --name ubuntu ubuntu:py3
docker run --rm -t -d --name centos7 centos:7
docker run --rm -t -d --name fedora pycontribs/fedora
ansible-playbook -i inventory/prod.yml --vault-pass-file pass site.yml
docker stop $(docker ps -a -q)