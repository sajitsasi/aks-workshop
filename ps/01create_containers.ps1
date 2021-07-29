source./00source_vars.sh

$DIR= Get-Location
#1. Build ratings-api container
Write-Output "Building Docker container of ratings-api"
Set-Location ${DIR}/src/mslearn-aks-workshop-ratings-api
docker build -t ratings-api:v1 .

#2. Build ratings-web container
Write-Output "Building Docker container of ratings-api"
Set-Location ${DIR}/src/mslearn-aks-workshop-ratings-web
docker build -t ratings-web:v1 .

#3. Create docker network to communicate between containers
Write-Output "Creating docker network for communication between containers"
docker network create ratingsnetwork

#4. Run containers
Write-Output "Starting ratings-api container..."
docker run -d -p 3000:3000 --name api --net ratingsnetwork ratings-api:v1

Write-Output "Starting ratings-web container..."
docker run -d -p 8080:8080 --name web --net ratingsnetwork ratings-web:v1
