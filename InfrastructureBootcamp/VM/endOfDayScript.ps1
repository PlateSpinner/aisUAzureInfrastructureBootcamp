#Upload VM information to instructors' storage account
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
$userFileName = ("day05_vmInfo_" + $username + "_" + (Get-Date -UFormat %Y%m%d%H%M%S) + ".json")
$userFilePath = Join-Path -Path $env:TMP -ChildPath $userFileName
#Get Resource Groups
$rgps = Get-AzResourceGroup
#Get VM Resource Group
$vmResourceGroup = $rgps | Where-Object {$_.ResourceGroupName -like "*01"}
#Get resource group ARM deployments information
$vmDeployments = Get-AzResourceGroupDeployment -ResourceGroupName $vmResourceGroup.ResourceGroupName | Where-Object {$_.Timestamp -ge ([datetime]::Now).AddDays(-1)} | Select-Object DeploymentName, ProvisioningState, Timestamp
#Get VMs
$vms = Get-AzVM -ResourceGroupName $vmResourceGroup.ResourceGroupName
#Convert context and resource group information to JSON
$ctxJson = $ctx | Select-Object @{l="AccountId";e={$_.Account.Id}},
                                @{l="SubscriptionName";e={$_.Subscription.Name}},
                                @{l="SubscriptionId";e={$_.Subscription.Id}},
                                @{l="TenantId";e={$_.Tenant.Id}},
                                @{l="vmDeployments";e={$vmDeployments}},       
                                @{l="virtualMachines";e={$vms }} | ConvertTo-Json -Depth 10
#Export JSON to temp file
$ctxJson | Out-File -FilePath $userFilePath
#Upload JSON file to storage account
Write-Output ("Uploading file " + [char]34 + $userFilePath + [char]34 + " to storage account " + [char]34 + $storeName  + [char]34 + "...")
$storeContext = New-AzStorageContext -SasToken $storeSasToken -StorageAccountName $storeName
$setBlob = $null
$setBlob = Set-AzStorageBlobContent -Context $storeContext -Container $containerName -Blob $userFileName -File $userFilePath -Force
if($setBlob){Write-Output ("Successfully uploaded blob " + [char]34 + $setBlob.Name + [char]34 + " length " + $setBlob.Length + " to storage account " + [char]34 +  $setBlob.Context.StorageAccountName + [char]34 + "...")}
else{Write-Error -Message ("Uploading failed")}
# SIG # Begin signature block
# MIIHXAYJKoZIhvcNAQcCoIIHTTCCB0kCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUJdofbNi1hPif3PcTsFHMZBJN
# J8mgggS7MIIEtzCCA5+gAwIBAgITOgAAADbrtm8dtBjRgwAAAAAANjANBgkqhkiG
# 9w0BAQsFADBTMRUwEwYKCZImiZPyLGQBGRYFY2xvdWQxFDASBgoJkiaJk/IsZAEZ
# FgRhaXN1MRIwEAYKCZImiZPyLGQBGRYCYWQxEDAOBgNVBAMTB0FJU1UtQ0EwHhcN
# MjAwMzA0MTQ0ODM0WhcNMjIwMzA0MTQ0ODM0WjBxMRUwEwYKCZImiZPyLGQBGRYF
# Y2xvdWQxFDASBgoJkiaJk/IsZAEZFgRhaXN1MRIwEAYKCZImiZPyLGQBGRYCYWQx
# DzANBgNVBAsTBkFkbWluczEdMBsGA1UEAxMURmFiaWVuIEdpbGJlcnQgQWRtaW4w
# ggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQC+Qdo4lItj73UIfAPdm8tk
# rEyKSLBSA1mT+KtZ1kYCmYt5wpUrZ6IkTBchCfm6CwVURGeqxIlA3u+7bSqZHNDJ
# YzbDv8eRHlXcnB8j0702q+wxEmD3i5VmMKp803pJ54Mbv7Q9axEDUC+uIWTGoC8U
# 25isU2LYXOfLdkrt3TKW46fn1g5J0V9ovbhNAsFuy522CQ0boBAk/18dHqBsQ+7J
# HUxAP+DCfImk84KRuOObMGJIGIOLNmDZY5OCF5lL9EW6WIUwZWs9H0Inmygnk8IX
# UIlESIbL+ZhxRpbNMAIo+G04MyGmwVfHRmQvA/ZHQbnqiT/al6grrplIRgYfkx9Z
# AgMBAAGjggFkMIIBYDA9BgkrBgEEAYI3FQcEMDAuBiYrBgEEAYI3FQiD6cF/geTd
# BIKFgzmC9+1ch4euHYF1geeMS9fJCQIBZAIBAjATBgNVHSUEDDAKBggrBgEFBQcD
# AzAOBgNVHQ8BAf8EBAMCB4AwGwYJKwYBBAGCNxUKBA4wDDAKBggrBgEFBQcDAzAd
# BgNVHQ4EFgQUuymP/tXMge5skF4vnvPeSpRHMiowHwYDVR0jBBgwFoAUKXSwK2XO
# TJcsgn9Ai/QQG0N3UX4wNgYDVR0fBC8wLTAroCmgJ4YlaHR0cDovL2NybC5haXN1
# LmNsb3VkL2NybC9BSVNVLUNBLmNybDA2BggrBgEFBQcBAQQqMCgwJgYIKwYBBQUH
# MAGGGmh0dHA6Ly9jcmwuYWlzdS5jbG91ZC9vY3NwMC0GA1UdEQQmMCSgIgYKKwYB
# BAGCNxQCA6AUDBJmYWJpZW4xQGFpc3UuY2xvdWQwDQYJKoZIhvcNAQELBQADggEB
# AJUDFK4F3O6myZShZYCVrkxLtOnaLAQ342QT4qsh6jR/CzmHivWlmEW1TKsONTOL
# soOLF8kMVzgFTrxQdwrUQduoa1Ke71AUxDYdZALDAxx2Y7LPgkMp5huVljUiz17+
# ofN2XrApPCqnHKRhIN9Xis8hv67GXWFmpVcWES56ErDb+Hp0BJlj3V0wpiJneHkB
# dv/WMdlVXy/6y+rStGovBqh+cJ4RF8xrZlZaEWt97g0sbCD7Ou22EzxdtKKbZCyS
# ONfQ8yq6rBnWCRDrOlM0Vqn4AihkrgPdJMvWN+KPxc38PR7c7MS+69WRNTnEpn1n
# u1hUChT8GRPhF92F9hinBxAxggILMIICBwIBATBqMFMxFTATBgoJkiaJk/IsZAEZ
# FgVjbG91ZDEUMBIGCgmSJomT8ixkARkWBGFpc3UxEjAQBgoJkiaJk/IsZAEZFgJh
# ZDEQMA4GA1UEAxMHQUlTVS1DQQITOgAAADbrtm8dtBjRgwAAAAAANjAJBgUrDgMC
# GgUAoHgwGAYKKwYBBAGCNwIBDDEKMAigAoAAoQKAADAZBgkqhkiG9w0BCQMxDAYK
# KwYBBAGCNwIBBDAcBgorBgEEAYI3AgELMQ4wDAYKKwYBBAGCNwIBFTAjBgkqhkiG
# 9w0BCQQxFgQUS8EoPPlX/O+BEgzUwIEtGttMfb8wDQYJKoZIhvcNAQEBBQAEggEA
# hMAXZGFq/xreOp9v6cVWk60Znk8bvh+NDtEweFZ9/jDIyVExoLNyKNcd/j8MqUgC
# aQ278Rdl8l6CdoLDeUXQREpVEICqEFkuQsYMMfsjbSmPMjHiV73pur2RM0jdEijx
# WjrcExJz5LU7A8X8ImMa11G09Z7v+nwyY7y/Hrl3OmeV5z1Lc6XVVkounySiyN7p
# 2Wl7l0GuW3eGAJIsamoF8bEDPVLddTJCE14KHCD02uh8wVJtu3MWxFU008kbL9af
# eWt+pZjzkTFRhV9x4BWQWkHtZkKrfxnMp30yffvi6g3FxGN2frvxvpxGrrO6vdX3
# yH3zlxU6AJvEeOMrq2it/Q==
# SIG # End signature block
