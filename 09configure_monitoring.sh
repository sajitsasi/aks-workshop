#!/bin/bash

source ./00source_vars.sh
DIR=$(pwd)

#1. Create a Log Analytics Workspace
printcmd "Creating Log Analytics Workspace ${AKS_LAW_WORKSPACE}"
printcmd "az resource create  --resource-type Microsoft.OperationalInsights/workspaces  --name ${AKS_LAW_WORKSPACE}  -g ${AZ_RG}  --location ${AZ_LOCATION}  --properties '{}' -o table"
az resource create \
--resource-type Microsoft.OperationalInsights/workspaces \
--name ${AKS_LAW_WORKSPACE} \
-g ${AZ_RG} \
--location ${AZ_LOCATION} \
--properties '{}' -o table

#2. Enable AKS Monitoring Add-on for your cluster
printcmd "Enabling AKS Monitoring Add-on for ${AZ_AKS_CLUSTER}"
AKS_LAW_WORKSPACE_ID=$(az resource show \
--resource-type Microsoft.OperationalInsights/workspaces \
--name ${AKS_LAW_WORKSPACE} \
-g ${AZ_RG} \
--query id -o tsv)
runcmd "az aks enable-addons \
-g ${AZ_RG} \
--name ${AZ_AKS_CLUSTER} \
--addons monitoring \
--workspace-resource-id ${AKS_LAW_WORKSPACE_ID}"
printcmd "please give 10 minutes before monitoring data is written to LA workspace..."

#3. Add log reader RBAC to the AKS cluster
printcmd "Adding log reader RBAC to AKS cluster ${AZ_AKS_CLUSTER}"
runcmd "kubectl apply -f ${LOGREADER_RBAC_YAML}"