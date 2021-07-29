#!/bin/bash

source ./00source_vars.sh
DIR=$(pwd)

#1. Create deployment for ratings-api
printcmd "Deploying ratings-api to cluster ${AKS_CLUSTER}"
envsubst < ${DIR}/yaml/${RATINGS_API_DEPLOY_YAML} | kubectl apply --namespace ratingsapp -f -

printcmd "Get current status of ratings-api pod"
pruncmd "kubectl get pods --namespace ratingsapp -l app=ratings-api"
echo -e "run '${GREEN}kubectl get pods --watch --namespace ratingsapp -l app=ratings-api'${NOCOL} to watch deployment"

printcmd "Getting status of deployment"
pruncmd "kubectl get deployment ratings-api --namespace ratingsapp"

#2. Create service for ratings-api
printcmd "Creating ClusterIP service for ratings-api"
pruncmd "kubectl apply \
--namespace ratingsapp \
-f ${DIR}/yaml/${RATINGS_API_SERVICE_YAML}"
printcmd "Get current status of ratings-api service"
pruncmd "kubectl get service ratings-api --namespace ratingsapp"
printcmd "Service endpoints info for ratings-api"
pruncmd "kubectl get endpoints ratings-api --namespace ratingsapp"