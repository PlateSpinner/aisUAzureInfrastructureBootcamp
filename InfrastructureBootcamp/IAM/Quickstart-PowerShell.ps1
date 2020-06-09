$rgpName="AISU-E2-RG-01"
$appSvcName="aisUHelloWorld"+(Get-Random)

# Create a resource group.
#az group create --location eastus2 --name $rgpName

# Start from instructions
## In the Cloud Shell, create a quickstart directory and then change to it.
mkdir quickstart

cd $HOME/quickstart

## Next, run the following command to clone the sample app repository to your quickstart directory.
git clone https://github.com/Azure-Samples/html-docs-hello-world.git

## In the following example, replace <app_name> with a unique app name.
##! Note location is "eastus2" and specifying rgp 
cd html-docs-hello-world

## Find the title and h1 lines in the index.html file and add this user's name to it.
((Get-Content -Path .\index.html -Raw) -replace "Azure App Service - Sample Static HTML Site","Azure App Service - $env:USER Sample Static HTML Site") | Set-Content -Path .\index.html

## look for the site in this current directory, load it as an app service and just TURN IT ON
az webapp up --location eastus2 --name $appSvcName --resource-group $rgpName --html
