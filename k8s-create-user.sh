#!/usr/bin/env bash

#
# Script is created by Alexander Fedorko AKA alx69 (c) 2021.03.03
# https://github.com/alxpanther/
#

# Requires:
# cfssl - on Debian/Ubuntu: 'apt install golang-cfssl'
#         on RedHat/Centos see in https://kubernetes.io/docs/tasks/administer-cluster/certificates/#cfssl or https://github.com/cloudflare/cfssl/

# Use: ./name-of-script.sh <user> <email> <environment>
# where <environment> is file. See 'example' file
# Example: ./ks8-create-user.sh idl-support support@indevlab.com stage

source $3
#k="kubectl"

# --- preparing files for cfssl ---
cat <<-EOF > $1.json
{
    "CN": "$1",
    "key": {
        "algo": "rsa",
        "size": 4096
    },
    "names": [{
        "O": "$1",
        "email": "$2"
    }]
}
EOF

# Set expiry in hours (default: 17520h = 2years)
cat <<-EOF > cfssl-config.json
{
    "signing": {
        "default": {
            "expiry": "17520h"
        }
    }
}
EOF

# ------------------------------------------- Start of script -------------------------------------------

cfssl genkey --config=cfssl-config.json $1.json  | cfssljson -bare $1

# Create certificate request in our Kubernetes
cat <<EOF | $k create -f -
apiVersion: certificates.k8s.io/v1beta1
kind: CertificateSigningRequest
metadata:
  name: $1
spec:
  groups:
  - system:authenticated
  - $1
  request: $(cat $1.csr | base64 | tr -d '\n')
  usages:
  - digital signature
  - key encipherment
  - client auth
EOF

# Approve certificate request in our Kubernetes
$k certificate approve $1

# Get certificate for user from our Kubernetes
$k get csr $1 -o jsonpath='{.status.certificate}' | base64 -d > $1.pem

#cat <<-EOF > $1-config-crt-in-file
#apiVersion: v1
#clusters:
#- cluster:
#    certificate-authority-data: $certificate_data
#    server: $server
#  name: $cluster_name
#contexts:
#- context:
#    cluster: $cluster_name
#    user: $1
#  name: $1-context
#current-context: $1-context
#kind: Config
#preferences: {}
#users:
#- name: $1
#  user:
#    client-certificate: $1.pem
#    client-key: $1-key.pem
#EOF

# Creating config file for user (renamie it and place into file ~./kube/config
# where ~ is a directory for user which we create access)
cat <<-EOF > $1-config
apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: $certificate_data
    server: $server
  name: $cluster_name
contexts:
- context:
    cluster: $cluster_name
    user: $1
  name: $1-context
current-context: $1-context
kind: Config
preferences: {}
users:
- name: $1
  user:
    client-certificate-data: $(cat $1.pem | base64 | tr -d '\n')
    client-key-data: $(cat $1-key.pem | base64 | tr -d '\n')
EOF

#Create the credentials inside our Kubernetes
$k config set-credentials $1 --client-certificate=$1.pem --client-key=$1-key.pem

#Create the context for the user inside our Kubernetes
$k config set-context $1-context --cluster=$cluster_name --user=$1

# Deleting temporary files (*.pem leave if you have uncommented lines above where the config file is created with the certificate files)
rm $1.csr $1.json cfssl-config.json *.pem
