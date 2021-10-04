#!/bin/bash

source ./00source_vars.sh
DIR=$(pwd)

#1. Create an HPA
runcmd "kubectl apply --namespace ratingsapp -f ${DIR}/yaml/${RATINGS_API_HPA_YAML}"

#2. Run a load test with the HPA
if [ ${ENABLE_APP_GATEWAY_INGRESS_CONTROLLER} == "true" ]; then
    INGRESS_HOSTNAME=$(az network public-ip show -g ${AZ_RG} -n ${AZ_APP_GW_PUBLIC_IP} --query "ipAddress" -o tsv | sed 's/\./-/g')
else
    INGRESS_HOSTNAME=$(kubectl get services --namespace ingress | grep -v -e NAME -e kubectl -e "controller\-admission" | awk '{print $4}' | sed -e 's/\./\-/g')
fi
LOADTEST_API_ENDPOINT="https://frontend.${INGRESS_HOSTNAME}.nip.io/api/loadtest"
printcmd "az container create \ -g ${AZ_RG} -n loadtest --cpu 4 --memory 1 --image azch/artillery --restart-policy Never --command-line \"artillery quick -r 500 -d 120 ${LOADTEST_API_ENDPOINT}\""
az container create \
-g ${AZ_RG} \
-n loadtest \
--cpu 4 \
--memory 1 \
--image azch/artillery \
--restart-policy Never \
--command-line "artillery quick -r 500 -d 120 ${LOADTEST_API_ENDPOINT}"