#!/bin/bash

source ./00source_vars.sh
DIR=$(pwd)

#1. Create ingress namespace
printcmd "Creating ingress namespace"
pruncmd "kubectl create namespace ingress"

#2. Install ingress controller
if [ ${ENABLE_APP_GATEWAY_INGRESS_CONTROLLER} == "true" ]; then
    printcmd "Installing APP Gateway ingress controller"
    printcmd "Creating APP Gateway Public IP"
    runcmd "az network public-ip create \
    -g ${AZ_RG} \
    -n ${AZ_APP_GW_PUBLIC_IP} \
    --allocation-method static \
    --sku standard"
    printcmd "Creating APP Gateway VNET"
    runcmd "az network vnet create \
    -g ${AZ_RG} \
    -n ${AZ_APP_GW_VNET} \
    --address-prefixes ${AZ_APP_GW_VNET_CIDR} \
    --subnet-name ${AZ_APP_GW_SUBNET} \
    --subnet-prefixes ${AZ_APP_GW_SUBNET_CIDR} \
    --location ${AZ_LOCATION}"
    printcmd "Creating App Gateway ${AZ_APP_GW_NAME}"
    runcmd "az network application-gateway create \
    -g ${AZ_RG} \
    -n ${AZ_APP_GW_NAME} \
    --vnet-name ${AZ_APP_GW_VNET} \
    --subnet ${AZ_APP_GW_SUBNET} \
    --public-ip-address ${AZ_APP_GW_PUBLIC_IP} \
    --sku Standard_v2 \
    --location ${AZ_LOCATION}"
    AKS_VNET_ID=$(az network vnet show -g ${AZ_RG} -n ${AZ_VNET} --query "id" -o tsv)
    APPGW_VNET_ID=$(az network vnet show -g ${AZ_RG} -n ${AZ_APP_GW_VNET} --query "id" -o tsv)
    printcmd "Peering between AKS VNET and APP Gateway VNET"
    runcmd "az network vnet peering create \
    -g ${AZ_RG} \
    -n ${AZ_APP_GW_TO_AKS_VNET_PEERING} \
    --vnet-name ${AZ_APP_GW_VNET} \
    --remote-vnet ${AKS_VNET_ID} \
    --allow-vnet-access"
    runcmd "az network vnet peering create \
    -g ${AZ_RG} \
    -n ${AZ_AKS_TO_APP_GW_VNET_PEERING} \
    --vnet-name ${AZ_VNET} \
    --remote-vnet ${APPGW_VNET_ID} \
    --allow-vnet-access"
    printcmd "Enabling APP Gateway Ingress Controller on AKS cluster"
    APP_GW_ID=$(az network application-gateway show -g ${AZ_RG} -n ${AZ_APP_GW_NAME} --query "id" -o tsv)
    runcmd "az aks enable-addons \
    -g ${AZ_RG} \
    -n ${AZ_AKS_CLUSTER} \
    --addons ingress-appgw \
    --appgw-id ${APP_GW_ID}"
else
    printcmd "Installing nginx ingress controller..."
    pruncmd "helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx"
    pruncmd "helm repo update"
    helm install nginx-ingress ingress-nginx/ingress-nginx \
    --namespace ingress \
    --set controller.replicaCount=2 \
    --set controller.nodeSelector."beta\.kubernetes\.io/os"=linux \
    --set defaultBackend.nodeSelector."beta\.kubernetes\.io/os"=linux
fi

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