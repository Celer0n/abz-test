#!/bin/bash

# Получаем IP адрес WordPress
WORDPRESS_IP=$(terraform output -raw wordpress_ip)
MYSQL_ENDPOINT=$(terraform output -raw mysql_endpoint)
REDIS_ENDPOINT=$(terraform output -raw redis_endpoint)

# Запускаем Ansible playbook
ansible-playbook -i $WORDPRESS_IP, ansible/playbook.yml --extra-vars "mysql_endpoint=$MYSQL_ENDPOINT redis_endpoint=$REDIS_ENDPOINT"