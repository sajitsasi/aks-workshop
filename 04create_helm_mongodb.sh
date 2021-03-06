#!/bin/bash

source ./00source_vars.sh

#1. Add bitnami repo
printcmd "Adding bitnami repository"
helm repo add bitnami https://charts.bitnami.com/bitnami
kubectl create namespace ratingsapp

#2. Install MongoDB Helm chart
printcmd "Installing MongoDB Helm chart"
if [[ ${OSTYPE} == "darwin"* ]]; then
    MD5SUM=md5
else
    MD5SUM=md5sum
fi
MONGO_USER=azureuser
MONGO_PASS=$(${MD5SUM} .key | awk '{print $1}')
runcmd "helm install ratings bitnami/mongodb \
--namespace ratingsapp \
--set auth.username=${MONGO_USER},auth.password=${MONGO_PASS},auth.database=ratingsdb"

#3. Store the MongoDB username, password, and endpoint in a kubernetes secret
printcmd "Storing MongoDB secrets in kubernetes"
kubectl create secret generic mongosecret \
--namespace ratingsapp \
--from-literal=MONGOCONNECTION="mongodb://${MONGO_USER}:${MONGO_PASS}@ratings-mongodb.ratingsapp:27017/ratingsdb"
printcmd "Checking secret in kubernetes"
kubectl describe secret mongosecret --namespace ratingsapp
echo "done"
