#!/bin/bash

source ./00source_vars.sh
DIR=$(pwd)

#1. Create cert-manager namespace
printcmd "Creating namespace for cert-manager"
runcmd "kubectl create namespace cert-manager"

#2. Install help repo and deploy cert-manager
printcmd "Installing jetstack helm repo"
pruncmd "helm repo add jetstack https://charts.jetstack.io"
runcmd "helm repo update"
printcmd "Install cert-manager..."
runcmd "kubectl apply --validate=false \
-f https://raw.githubusercontent.com/jetstack/cert-manager/release-0.14/deploy/manifests/00-crds.yaml"
printcmd "Installing cert-manager helm chart"
runcmd "helm install cert-manager \
--namespace cert-manager \
--version v0.14.0 \
jetstack/cert-manager"
printcmd "Waiting for cert-manager pods to come up..."
while true; do
  up=0
  while IFS= read -r out
  do
    ready=$(echo ${out} | awk '{print $2}')
    running=$(echo ${out} | awk '{print $3}')
    if [ ${ready} = "1/1" ] && [ ${running} = "Running" ]; then
      up=$((up + 1))
    fi
  done <<< $(kubectl get pods --namespace cert-manager | grep -v NAME)
  if [ "${up}" -eq 3 ]; then
    break
  fi
  sleep 3
done
printcmd "Getting status of cert-manager"
pruncmd "kubectl get pods --namespace cert-manager"

#3. Read in email address and deploy ClusterIssuer resource for Let's Encrypt
#regex="^[a-z0-9!#\$%&'*+/=?^_\`{|}~-]+(\.[a-z0-9!#$%&'*+/=?^_\`{|}~-]+)*@([a-z0-9]([a-z0-9-]*[a-z0-9])?\.)+[a-z0-9]([a-z0-9-]*[a-z0-9])?\$"
regex='(.+)@(.+)'

while true; do
  read -p "enter valid email address: " email_address
  if [[ ${email_address} =~ ${regex} ]] ; then
    export EMAIL_ADDRESS=${email_address}
    echo "using email address ${EMAIL_ADDRESS}"
    break
  else
    echo "ERROR: invalid email address!!!"
  fi
done
envsubst < ${DIR}/yaml/${CLUSTER_ISSUER_YAML} | kubectl apply --namespace ratingsapp -f -

#4. Enable TLS for web service on Ingress
printcmd "Enabling TLS for web service on ingress..."
if [ "$ENABLE_APP_GATEWAY_INGRESS_CONTROLLER" == "true" ]; then
    INGRESS_EXTERNAL_IP=$(az network public-ip show -g ${AZ_RG} -n ${AZ_APP_GW_PUBLIC_IP} --query "ipAddress" -o tsv)
else
  INGRESS_EXTERNAL_IP=$(kubectl get services --namespace ingress | grep -v -e NAME -e kubectl -e "controller\-admission" | awk '{print $4}')
fi
export INGRESS_HOST=$(echo ${INGRESS_EXTERNAL_IP} | sed -e 's/\./\-/g')
envsubst < ${DIR}/yaml/${RATINGS_WEB_INGRESS_TLS_YAML} | kubectl apply --namespace ratingsapp -f -
