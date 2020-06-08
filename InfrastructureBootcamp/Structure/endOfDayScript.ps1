#Upload resource group information to instructors' storage account
#Fabien Gilbert, AIS, 02-2020
#
#
$storeName = "aisue2store1"
$storeSasToken = "?sv=2019-02-02&sr=c&sig=6NAXjG7OqLQSo6URrspKoWQFvN3jJ3y8EmbWgtk%2FR0A%3D&st=2020-02-27T19%3A13%3A59Z&se=2021-02-27T19%3A13%3A59Z&sp=w"
$containerName = "students"
#Get context info
$ctx = Get-AzContext
#Temp path for file to upload
$username = $ctx.Account.Id.Split("@")[0]
$userFileName = ("day02_resourceGroupInfo_" + $username + "_" + (Get-Date -UFormat %Y%m%d%H%M%S) + ".json")
$userFilePath = Join-Path -Path $env:TMP -ChildPath $userFileName
#Get Resource Group Info
$rgps = Get-AzResourceGroup
#Get subscription ARM deployments information
$subDeployments = Get-AzDeployment
$recentSubDeployments = $subDeployments | Where-Object {$_.Timestamp -ge ([datetime]::Now).AddDays(-1)} | Select-Object DeploymentName, location, ProvisioningState, Timestamp
#Convert context and resource group information to JSON
$ctxJson = $ctx | Select-Object @{l="AccountId";e={$_.Account.Id}}, @{l="SubscriptionName";e={$_.Subscription.Name}}, @{l="SubscriptionId";e={$_.Subscription.Id}}, @{l="TenantId";e={$_.Tenant.Id}}, @{l="ResourceGroups";e={$rgps | Select-Object -Property ResourceGroupName, Location}}, @{l="subscriptionDeployments";e={$recentSubDeployments}} | ConvertTo-Json
#Export JSON to temp file
$ctxJson | Out-File -FilePath $userFilePath
#Upload JSON file to storage account
Write-Output ("Uploading file " + [char]34 + $userFilePath + [char]34 + " to storage account " + [char]34 + $storeName  + [char]34 + "...")
$storeContext = New-AzStorageContext -SasToken $storeSasToken -StorageAccountName $storeName
$setBlob = $null
$setBlob = Set-AzStorageBlobContent -Context $storeContext -Container $containerName -Blob $userFileName -File $userFilePath -Force
if($setBlob){Write-Output ("Successfully uploaded blob " + [char]34 + $setBlob.Name + [char]34 + " length " + $setBlob.Length + " to storage account " + [char]34 +  $setBlob.Context.StorageAccountName + [char]34 + "...")}
else{Write-Error -Message ("Uploading failed")}