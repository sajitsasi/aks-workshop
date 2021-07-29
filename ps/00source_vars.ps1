
if (Test-Path -Path ..\.key -PathType leaf) {
    $KEY=Get-Content ..\.key
} else {
    $KEY=Get-Random -Maximum 10000
    $KEY | Out-File -FilePath ..\.key
}

$AZ_LOCATION="eastus"
$AZ_RG="aks-wks-$KEY-rg"
$AZ_AKS_SUBNET="aks-subnet"
$AZ_VM_SUBNET="vm-subnet"
$AZ_PE_SUBNET="pe-subnet"
$AZ_VNET="aks-wks-vnet"
$AZ_VNET_CIDR="10.125.0.0/16"
$AZ_AKS_CLUSTER="aks-wks-$KEY"
$AZ_AKS_SUBNET_CIDR="10.125.0.0/20"
$AZ_VM_SUBNET_CIDR="10.125.16.0/24"
$AZ_PE_SUBNET_CIDR="10.125.18.0/24"
$AZ_AKS_SVC_CIDR="10.125.17.0/24"
$AZ_AKS_DNS_IP="10.125.17.10"
$AZ_ACR_NAME="acr$KEY"

$RATINGS_API_DEPLOY_YAML="ratings-api-deployment.yaml"
$RATINGS_API_SERVICE_YAML="ratings-api-service.yaml"
$RATINGS_WEB_DEPLOY_YAML="ratings-web-deployment.yaml"
$RATINGS_WEB_SERVICE_YAML="ratings-web-service.yaml"
$RATINGS_WEB_SERVICE_CLUSTERIP_YAML="ratings-web-service-clusterip.yaml"
$RATINGS_WEB_INGRESS_YAML="ratings-web-ingress.yaml"
$RATINGS_WEB_INGRESS_TLS_YAML="ratings-web-ingress-tls.yaml"
$CLUSTER_ISSUER_YAML="cluster-issuer.yaml"

Write-Host "variable sourcing complete" -ForegroundColor green 