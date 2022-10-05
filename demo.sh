#!/bin/bash

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
PG_PASSWORD="P@ssw0rd"
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
echo $JAVA_HOME

# Get Application Insights Connection String
AI_CONNECTION_STRING=$(az monitor app-insights component show -g $RG --app $NAME -o tsv --query 'connectionString')
echo $AI_CONNECTION_STRING

# Get App URLs
API_URL=$(az spring app show --name $ASA_API_NAME --resource-group $RG --service $NAME --query "properties.url" -o tsv)
echo $API_URL
UI_URL=$(az spring app show --name $ASA_UI_NAME --resource-group $RG --service $NAME --query "properties.url" -o tsv)
echo $UI_URL

# Get ACR Creds
ACR_USERNAME=$(az acr credential show -g $RG -n $ACR_NAME --query "username" -o tsv)
echo $ACR_USERNAME
ACR_PASSWORD=$(az acr credential show -g $RG -n $ACR_NAME --query "passwords[0].value" -o tsv)
echo $ACR_PASSWORD




# Demo #1 - Review Codespaces setup
cat .devcontainer/devcontainer.json
cat .devcontainer/Dockerfile
cat .devcontainer/docker-compose.yml

# Demo #2 - Locally running tools
java --version
mvn --version
gradle --version
kubectl version --client=true
minikube version
docker --version
curl --version
git --version
node --version
npm --version

# Demo #3 - Local PostgreSQL DB
# Connect to PostgreSQL DB with CLI
# Connect to local PostgreSQL DB
psql --host=localhost --port=5432 --username=postgres --dbname=postgres
# List Databases
\l
# Change to Tutorials DB
\c tutorials
# List Tables, Views, Sequences
\d
# Check for Tables + Data
SELECT * FROM tutorial;
# Quit
\quit
# Connect to Azure PostgreSQL DB
psql --host="${PGNAME}.postgres.database.azure.com" --port=5432 \
  --username="${PG_ADMIN}" \
  --dbname=postgres
# Quit
\quit

# Demo #4 - Run Apps locally & Highlight port forwarding
# Make Codespaces Ports Public
# Update CORS in application.properties with Codespaces UI URL - eg. https://kevingbb-jdd2022-wr65546gwpqf9x6g-8081.githubpreview.dev
# Run API App via Maven
cd /workspace/api
./mvnw spring-boot:run
# Run API App via command line
./mvnw clean package -DskipTests
java -jar target/jdd2022-0.0.1-SNAPSHOT.jar
# Run API App with Application Insights auto-instrumentation
./mvnw spring-boot:run -Dspring-boot.run.jvmArguments="-javaagent:applicationinsights-agent-3.3.1.jar"
java -javaagent:applicationinsights-agent-3.3.1.jar -jar target/jdd2022-0.0.1-SNAPSHOT.jar
# Open New Terminal & Run UI App Locally
# Update VUE_APP_APIURL in config.js with Codespaces API URL - eg. https://kevingbb-jdd2022-wr65546gwpqf9x6g-8080.githubpreview.dev/
cd /workspace/ui
npm run serve

# Demo #5 - Extension & Portal Walkthrough
# Walkthrough Azure Spring Apps Extension
# Walkthrough Azure Portal Overview

# Demo #6 - Deploy Apps to Azure Spring Apps
# Test Endpoints
echo "${API_URL}"
echo "${UI_URL}"
# Deploy API App
# Update CORS in application.properties with ASA UI URL - eg. https://jddconf20221003-jdd2022-ui.azuremicroservices.io
cd /workspace/api
./mvnw clean package -DskipTests
az spring app deployment create -n green --app $ASA_API_NAME --service $NAME --resource-group $RG --artifact-path target/jdd2022-0.0.1-SNAPSHOT.jar
# az spring app deploy --name $ASA_API_NAME --service $NAME --resource-group $RG --artifact-path target/jdd2022-0.0.1-SNAPSHOT.jar
# Check Logs
az spring app logs --name $ASA_API_NAME --service $NAME --resource-group $RG
# Deploy SPA UI App
# Update VUE_APP_APIURL in config.js with ASA API URL - eg. https://jddconf20221003-jdd2022-tutorials.azuremicroservices.io/
az acr build --registry $ACR_NAME --image jddconf/ui:v2 --file Dockerfile .
az spring app deployment create -n green --app $ASA_UI_NAME --service $NAME --resource-group $RG \
  --container-registry "${ACR_NAME}.azurecr.io" \
  --container-image "jddconf/ui:v2" \
  --registry-username "${ACR_USERNAME}" \
  --registry-password "${ACR_PASSWORD}"
# Check Logs
az spring app logs --name $ASA_UI_NAME --service $NAME --resource-group $RG

# Demo #7
# Azure Portal Instrumentation
