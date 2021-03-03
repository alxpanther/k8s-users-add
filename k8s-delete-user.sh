#!/bin/bash

#
# Script is created by Alexander Fedorko AKA alx69 (c) 2021.03.03
# https://github.com/alxpanther/
#

# Use: ./name-of-script.sh <user> <environment>
# where <environment> is file. See 'example' file
# Example: ./k8s-delete-user.sh idl-support stage

source $2
#k="kubectl"


echo -e "\n"
echo -e "Отзываем роль и удаляем ее привязку"
$k delete -f $1.yaml
echo -e "\n"

echo "Удаляем запрос на сертификат: $1"
$k delete csr $1
echo -e "\n"

echo "Список запросов на сертификат после удаления:"
$k get csr
echo -e "\n"

echo "Удаляем пользователя: $1"
$k config delete-user $1
echo -e "\n"

echo "Список пользователей после удаления:"
$k config get-users
echo -e "\n"

echo "Удаляем контекст пользователя: $1-context"
$k config delete-context $1-context
echo -e "\n"

echo "Список контекстов после удаления:"
$k config get-contexts
echo -e "\n"
