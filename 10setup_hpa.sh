#!/bin/bash

source ./00source_vars.sh
DIR=$(pwd)

#1. Create an HPA
runcmd "kubectl apply --namespace ratingsapp -f ${DIR}/yaml/${RATINGS_API_HPA_YAML}"

#2. Run a load test with the HPA
INGRESS_EXTERNAL_IP=$(kubectl get services --namespace ingress | grep -v -e NAME -e kubectl -e "controller\-admission" | awk '{print $4}')
LOADTEST_API_ENDPOINT="https://${INGRESS_EXTERNAL_IP}/api/loadtest"
runcmd "az container create \
-g ${AZ_RG} \
-n loadtest \
--cpu 4 \
--memory 1 \
--image azch/artillery \
--restart-policy Never \
--command-line \"artillery quick -r 500 -d 120 ${LOADTEST_API_ENDPOINT}\""