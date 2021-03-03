# Скрипты создания и удаления пользователей в Kubernetes

Описание файлов:
* **k8s-create-user.sh** - создание пользователя в Kubernetes кластере и создания config'а для пользователя. При этом делается запрос подписания сертификата в кластер, делается approve, забирается сертификат и на основе него+ключа+некоторых данных создается config файл.
* **k8s-delete-user.sh** - удаляется пользователь в Kubernetes кластере. Удаляется запрос на сертификат, удаляются контекст пользователя и т.д.
* **example** - пример environment где прописываются некоторые параметры:
```
certificate_data="LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSURKe......." - основной сертификат кластера - береться из config admin'а (например)
server="https://xxxxxxxx.k8s.ondigitalocean.com" - собственно, url самого кластера - брать все из того же config'а admin'а
cluster_name="do-ams3-xxxx-staging" - имя кластера (брать там же)
k="kubectl --kubeconfig=/home/XXX/config-stage" - строка для запуска kubectl (например, файл config'а называется или дежит не в ~./kube/config), если все стантарто, то просто записать: k="kubectl"
```
* **user.yaml** - пример роли и ее биндинга. Применять: `kubectl apply -f user.yaml`

#### Как запускать?

##### Создание пользователя
`k8s-create-user.sh <user> <email> <environment>`

где:

`<user>` - имя пользвателя, которое нужно создать

`<email>` - E-Mail пользователя, которого создаем

`<environment>` - файл (отредактировать и переименовать файл example) параметров. Например у нас среда dev и среда prod - можем создать для них 2 файла с такими же именами, но с разными `server`, `ertificate_data` и `cluster_name` для конкретных сред.

##### Удаление пользователя
`k8s-delete-user.sh <user> <environment>`

где:

`<user>` - имя пользвателя, которое нужно создать

`<environment>` - файл (отредактировать и переименовать файл example) параметров. Например у нас среда dev и среда prod - можем создать для них 2 файла с такими же именами, но с разными `server`, `ertificate_data` и `cluster_name` для конкретных сред. В данном случае, из этого файла нам нужная переменная `k`, т.к. в ней может указываться путь к config'у, в кластере которого мы будем удалять пользователя