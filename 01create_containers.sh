#!/bin/bash

source ./00source_vars.sh

DIR=$(pwd)
#1. Build ratings-api container
printcmd "Building Docker container of ratings-api"
cd ${DIR}/src/mslearn-aks-workshop-ratings-api
docker build -t ratings-api:v1 .

#2. Build ratings-web container
printcmd "Building Docker container of ratings-api"
cd ${DIR}/src/mslearn-aks-workshop-ratings-web
docker build -t ratings-web:v1 .

#3. Create docker network to communicate between containers
printcmd "Creating docker network for communication between containers"
docker network create ratingsnetwork

#4. Run containers
printcmd "Starting ratings-api container..."
docker run -d -p 3000:3000 --name api --net ratingsnetwork ratings-api:v1

printcmd "Starting ratings-web container..."
docker run -d -p 8080:8080 --name web --net ratingsnetwork ratings-web:v1
