scripts & tools used in day 3 of Azure Infrastructure Bootcamp


1. Log onto Azure Portal with your own (non-aisU) account and open up a Cloud Shell.<br>NOTE: if your account has access to more than one subscription, you may need to select the intended destination subscription with a "az account set--subscrition <yourSubscriptionName>" command.
2. Use the instructions here to set up a hello world App Service: https://docs.microsoft.com/en-us/azure/app-service/app-service-web-get-started-html<br><br>Use the Quickstart-Bash.sh as an alternative to commands. (edit the variable for resource group to suite you)  These commands add control to the rgp being used and attempts to personalize the index.html by adding your name to it. (also be aware it changed assumed location to "eastus2")
3. It will work because nothing in the cloud ever goes wrong.
4. Take that new App Service and enable it for authentication using the Express Settings (see "https://docs.microsoft.com/en-us/azure/app-service/configure-authentication-provider-aad#-configure-with-express-settings")
5. Go into AAD and configure it for permissions for all