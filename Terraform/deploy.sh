#!/bin/bash

# Получаем IP адрес WordPress
WORDPRESS_IP=$(terraform output -raw wordpress_ip)
MYSQL_ENDPOINT=$(terraform output -raw mysql_endpoint)
REDIS_ENDPOINT=$(terraform output -raw redis_endpoint)

# Путь к директории с Ansible
ANSIBLE_DIR=../Ansible

# Запускаем Ansible playbook
ansible-playbook -i $ANSIBLE_DIR/hosts.ini $ANSIBLE_DIR/playbook.yml --extra-vars "mysql_endpoint=$MYSQL_ENDPOINT redis_endpoint=$REDIS_ENDPOINT" -vv