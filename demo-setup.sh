#!/bin/bash

# Links
# Code, Deploy, and Scale Java Your Way - https://cdn.graph.office.net/prod/media/java/code-deploy-scale-java-your-way.pdf?ocid=aid3054636_RequestedResources_ThankYou_DevComm&eventId=JDDConferencePoland_Rr46RUGhxaBI
# How Microsoft applies Java - https://cdn.graph.office.net/prod/media/java/how-microsoft-applies-java.pdf?v={1/string}&ocid=eml_pg360385_gdc_comm_az&mkt_tok=MTU3LUdRRS0zODIAAAGG_dbt3yZ3i3-xnrMaZLrP1nttpxSl-sKTdXkh2Dku6tj-svgkbr5MG71nryzn80tPuJh6KgdaVx9LQlR0xlJN704LYVanDqkSkYav7rLk66wUFsfx1DOqUxA
# MS Build OpenJDK - https://www.microsoft.com/openjdk
# Container Images for OpenJDK - https://learn.microsoft.com/en-us/java/openjdk/containers
# VS Code Remote Try Java - https://github.com/Microsoft/vscode-remote-try-java

# Variables
PREFIX="jddconf"
RG="${PREFIX}-rg"
LOC="westeurope"
DATE=$(date +%Y%m%d)
#DATE=20221003
NAME="${PREFIX}${DATE}"
# And A Couple Extra for PostgreSQL
PGNAME="${NAME}pgsqlsvr"
PG_ADMIN="myadmin"
PG_PASSWORD=""
# Azure Container Registry
ACR_NAME="${PREFIX}acr"
# Load Balancer DNS Names
API_DNS="${PREFIX}${DATE}api"
UI_DNS="${PREFIX}${DATE}ui"
# Azure Spring Apps API App
ASA_API_NAME="jdd2022-tutorials"
# Azure Spring Apps UI App
ASA_UI_NAME="jdd2022-ui"

# Set JAVA_HOME
export JAVA_HOME=/usr/lib/jvm/msopenjdk-current/

# Create PostgreSQL Resource Group
az group create --name $RG --location $LOC

# Create ACR
az acr create -g $RG -n $ACR_NAME --sku Premium --admin-enabled
az acr login --name $ACR_NAME
ACR_USERNAME=$(az acr credential show -g $RG -n $ACR_NAME --query "username" -o tsv)
echo $ACR_USERNAME
ACR_PASSWORD=$(az acr credential show -g $RG -n $ACR_NAME --query "passwords[0].value" -o tsv)
echo $ACR_PASSWORD

# Create Azure Spring Apps Environment
az spring create -g $RG -n $NAME --sku standard

# Create PostgreSQL Server
az postgres flexible-server create -g $RG -n $PGNAME -l $LOC \
  --admin-user $PG_ADMIN \
  --admin-password $PG_PASSWORD \
  --public-access 0.0.0.0 \
  --sku-name Standard_B1ms \
  --tier Burstable \
  --storage-size 32 \
  --version 13

# Get Details
az postgres flexible-server show -g $RG -n $PGNAME
# Get Parameters
az postgres flexible-server parameter list -g $RG --server-name $PGNAME
# Disable SSL - Avoids Downloading TLS Cert
az postgres flexible-server parameter set -g $RG --server-name $PGNAME --name require_secure_transport --value off
# Add Firewall Rule
az postgres flexible-server firewall-rule create -g $RG --name $PGNAME --rule-name AllowMyIP --start-ip-address 0.0.0.0 --end-ip-address 255.255.255.255

# Connect to PostgreSQL DB with CLI
# Try with psql CLI
psql --host=localhost --port=5432 --username=postgres --dbname=postgres
quit
psql --host="${PGNAME}.postgres.database.azure.com" --port=5432 \
  --username="${PG_ADMIN}" \
  --dbname=postgres

# Setup Tutorials Database
# List Databases
\l
# List Tables, Views, Sequences
\d
# Create New DB
CREATE DATABASE tutorials;
\c tutorials
\l
# Quit
\quit

# Get Application Insights Connection String
az monitor app-insights component show -g $RG --app $NAME -o tsv --query 'connectionString'
AI_CONNECTION_STRING=$(az monitor app-insights component show -g $RG --app $NAME -o tsv --query 'connectionString')
echo $AI_CONNECTION_STRING
# Update Instrumentation Key to applicationinsights.json
cd /workspace/api
cat applicationinsights.json
# Update Instrumentation Key to config.js
cd /workspace/ui
cat public/config.js

# Run API App Locally
cd /workspace/api
./mvnw spring-boot:run
# OR
./mvnw clean install spring-boot:repackage
java -jar target/jdd2022-0.0.1-SNAPSHOT.jar
# Download App Insights Agent v3.3.1
curl https://github.com/microsoft/ApplicationInsights-Java/releases/download/3.3.1/applicationinsights-agent-3.3.1.jar -o applicationinsights-agent-3.3.1.jar
# Run with App Insights Agent
./mvnw spring-boot:run -Dspring-boot.run.jvmArguments="-javaagent:applicationinsights-agent-3.3.1.jar"
java -javaagent:applicationinsights-agent-3.3.1.jar -jar target/jdd2022-0.0.1-SNAPSHOT.jar

# Open New Terminal & Run UI App Locally
cd /workspace/ui
npm install
npm run serve

# Close locally running apps with ctrl + c

# Deploy Solution to Azure
# 1. Create Azure Spring Apps
# 2. Build UI Custom Container
# 3. Deploy API
# 4. Deploy UI

# 1. Create Azure Spring Apps
# Create Java API App
az spring app create --name $ASA_API_NAME --resource-group $RG --service $NAME --runtime-version "Java_17" \
  --assign-endpoint true \
  --env "SPRING_DATASOURCE_URL=jdbc:postgresql://${PGNAME}.postgres.database.azure.com:5432/tutorials"
# Create SPA UI App
az spring app create --name $ASA_UI_NAME --resource-group $RG --service $NAME --assign-endpoint true
# List Apps
az spring app list -g $RG -s $NAME -o table
# List Endpoints
API_URL=$(az spring app show --name $ASA_API_NAME --resource-group $RG --service $NAME --query "properties.url" -o tsv)
echo $API_URL
UI_URL=$(az spring app show --name $ASA_UI_NAME --resource-group $RG --service $NAME --query "properties.url" -o tsv)
echo $UI_URL
# Update VUE_APP_APIURL in config.js to match API App (outputted from creating app above)
cat public/config.js

# 2. Build UI Custom Container
# Build UI Container
cd /workspace/ui
az acr build --registry $ACR_NAME --image jddconf/ui:v1 --file Dockerfile .
# Test Locally if Desired
docker run -it -p 8085:1025 --rm --name jddconf-ui $ACR_NAME.azurecr.io/jddconf/ui:v1

# 3. Deploy API
cd /workspace/api
./mvnw clean package -DskipTests
# Update needed Environment Variables
az spring app update --name $ASA_API_NAME --resource-group $RG --service $NAME \
  --env SPRING_DATASOURCE_URL="jdbc:postgresql://${PGNAME}.postgres.database.azure.com:5432/tutorials" \
        SPRING_DATASOURCE_USERNAME="${PG_ADMIN}" \
        SPRING_DATASOURCE_PASSWORD="${PG_PASSWORD}" \
        APPLICATIONINSIGHTS_CONNECTION_STRING="${AI_CONNECTION_STRING}" \
        MY_CORS_ALLOWED_ORIGINS="${UI_URL}"
# Deploy Spring Boot App
az spring app deploy --name $ASA_API_NAME --service $NAME --resource-group $RG --artifact-path target/jdd2022-0.0.1-SNAPSHOT.jar
# Check Logs
az spring app logs --name $ASA_API_NAME --service $NAME --resource-group $RG
# Test Endpoint
echo "${API_URL}"

# 4. Deploy UI
# Deploy UI Custom Container with VueJS + nginx
az spring app deploy --name $ASA_UI_NAME --service $NAME --resource-group $RG \
  --container-registry "${ACR_NAME}.azurecr.io" \
  --container-image "jddconf/ui:v1" \
  --registry-username "${ACR_USERNAME}" \
  --registry-password "${ACR_PASSWORD}" \
  --deployment "default"
# Check Logs
az spring app logs --name $ASA_UI_NAME --service $NAME --resource-group $RG
# Test Endpoint
echo "${UI_URL}"
