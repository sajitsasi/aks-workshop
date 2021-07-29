#!/bin/bash

source ./00source_vars.sh
DIR=$(pwd)

#1. Create deployment for ratings-web
printcmd "Deploying ratings-web to cluster ${AKS_CLUSTER}"
envsubst < ${DIR}/yaml/${RATINGS_WEB_DEPLOY_YAML} | kubectl apply --namespace ratingsapp -f -

printcmd "Get current status of ratings-web pod"
pruncmd "kubectl get pods --namespace ratingsapp -l app=ratings-web"
echo -e "run '${GREEN}kubectl get pods --watch --namespace ratingsapp -l app=ratings-web'${NOCOL} to watch deployment"

printcmd "Getting status of deployment"
pruncmd "kubectl get deployment ratings-web --namespace ratingsapp"

#2. Create service for ratings-web
printcmd "Creating LoadBalancer service for ratings-web"
pruncmd "kubectl apply \
--namespace ratingsapp \
-f ${DIR}/yaml/${RATINGS_WEB_SERVICE_YAML}"
printcmd "Get current status of ratings-web service"
pruncmd "kubectl get service ratings-web --namespace ratingsapp"