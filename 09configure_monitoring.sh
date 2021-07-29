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
pruncmd "az aks enable-addons \
-g ${AZ_RG} \
-n ${AZ_AKS_CLUSTER} \
--addons monitoring \
--workspace-resource-id ${AKS_LAW_WORKSPACE_ID}"
printcmd "please give 10 minutes before monitoring data is written to LA workspace..."