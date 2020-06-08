#!/bin/bash

rgpName=AISU-E2-RG-JF-QuickPaaS
appSvcName=aisUHelloWorld$RANDOM

# Create a resource group.
az group create --location eastus2 --name $rgpName

# Start from instructions
## In the Cloud Shell, create a quickstart directory and then change to it.
mkdir quickstart

cd $HOME/quickstart

## Next, run the following command to clone the sample app repository to your quickstart directory.
git clone https://github.com/Azure-Samples/html-docs-hello-world.git

## In the following example, replace <app_name> with a unique app name.
##! Note location is "eastus2" and specifying rgp 
cd html-docs-hello-world

sed -i "s/<h1>Azure App Service - /<h1>Azure App Service - $USER /g" index.html

az webapp up --location eastus2 --name $appSvcName --resource-group $rgpName --html