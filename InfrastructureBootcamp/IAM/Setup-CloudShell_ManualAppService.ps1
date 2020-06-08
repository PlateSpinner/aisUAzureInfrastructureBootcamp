##### STOP RIGHT THERE!!!
#####  This stuff is intended for you to drop into a PowerShell Cloud Shell
#####   right in the browser. 
#####  You could run it locally but you would have to run the following
###Follow instructions to do device login
##az login
##az account set --subscription "AISU-SUB-HUB"


$myInitials = Read-Host "Enter your initials so we can try to make a unique name for your stuff."

# Replace the following URL with a public GitHub repo URL
$gitrepo="https://github.com/Azure-Samples/php-docs-hello-world"
$webappname="AISU-E2-APPSVC-$myInitials"
$rgpName = "AISU-E2-RG-APPSVC-$myInitials"


# Create a resource group.
az group create --location eastus2 --name $rgpName

# Create an App Service plan in STANDARD tier (minimum required by deployment slots).
az appservice plan create --name $webappname --resource-group $rgpName --sku S1

# Create a web app.
az webapp create --name $webappname --resource-group $rgpName --plan $webappname
##
##
##
##
##
##   IF YOU WANT TO GET A GOOD LOOK AT THE OUTPUT FROM THE COMMANDS, THEN
##    RUN THE COMMANDS ABOVE, TAKE A LOOK, THEN RUN THE STUFF BELOW.
##
## IF YOU DON'T CARE, JUST PASTE THE WHOLE THING IN.
##
##
##
##
#Create a deployment slot with the name "staging".
az webapp deployment slot create --name $webappname --resource-group $rgpName --slot staging

# Deploy sample code to "staging" slot from GitHub.
az webapp deployment source config --name $webappname --resource-group $rgpName --slot staging --repo-url $gitrepo --branch master --manual-integration

# Copy the result of the following command into a browser to see the staging slot.
Write-Host "https://$webappname-staging.azurewebsites.net"

# Swap the verified/warmed up staging slot into production.
az webapp deployment slot swap --name $webappname --resource-group $rgpName --slot staging

# Copy the result of the following command into a browser to see the web app in the production slot.
Write-Host "https://$webappname.azurewebsites.net"