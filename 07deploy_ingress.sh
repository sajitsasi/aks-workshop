#!/bin/bash

source ./00source_vars.sh
DIR=$(pwd)

#1. Create ingress namespace
printcmd "Creating ingress namespace"
pruncmd "kubectl create namespace ingress"

#2. Install nginx ingress controller
printcmd "Installing nginx ingress controller..."
pruncmd "helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx"
pruncmd "helm repo update"
helm install nginx-ingress ingress-nginx/ingress-nginx \
--namespace ingress \
--set controller.replicaCount=2 \
--set controller.nodeSelector."beta\.kubernetes\.io/os"=linux \
--set defaultBackend.nodeSelector."beta\.kubernetes\.io/os"=linux

#3. Get ingress external IP
INGRESS_EXTERNAL_IP=$(kubectl get services --namespace ingress | grep -v -e NAME -e kubectl -e "controller\-admission" | awk '{print $4}')
printcmd "Waiting for Ingress External IP"
while [ ${INGRESS_EXTERNAL_IP} = "<pending>" ]; do
    INGRESS_EXTERNAL_IP=$(kubectl get services --namespace ingress | grep -v -e NAME -e kubectl -e "controller\-admission" | awk '{print $4}')
    sleep 3
done
printcmd "ingress external IP is ${INGRESS_EXTERNAL_IP}"
export INGRESS_EXTERNAL_IP
export INGRESS_HOST=$(echo ${INGRESS_EXTERNAL_IP} | sed -e 's/\./\-/g')

#4. Delete the LoadBalancer service create ClusterIP
printcmd "Deleting ratings-web service to make way for ingress"
pruncmd "kubectl delete service --namespace ratingsapp ratings-web"
pruncmd "kubectl apply \
--namespace ratingsapp \
-f ${DIR}/yaml/${RATINGS_WEB_SERVICE_CLUSTERIP_YAML}"

#4. Create ingress and point to ClusterIP
envsubst < ${DIR}/yaml/${RATINGS_WEB_INGRESS_YAML} | kubectl apply --namespace ratingsapp -f -
printcmd "\n\nTest application with http://frontend.${INGRESS_HOST}.nip.io"