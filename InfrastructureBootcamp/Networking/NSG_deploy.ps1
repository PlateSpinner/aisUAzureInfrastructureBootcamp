#Deploy NSG through ARM template and parameters files
#Fabien Gilbert, February of 2020
#
$currentFolder = Split-Path $script:MyInvocation.MyCommand.Path
$armTemplateFile = "nsg_armTemplate.json"
$resourceType = "NSG"
$resourceNameProperty = "nsgNamePrefix"
$armTemplatePath = Join-Path -Path $currentFolder -ChildPath $armTemplateFile
#Select ARM parameter file(s)
$folderList=$null;$fileList=$null
$folderList = Get-ChildItem -Path $currentFolder -Recurse -Filter "*.json" | Where-Object -Property Name -Like -Value ("*" + $resourceType + ".json")
Write-Output ("Select " + $resourceType + " JSON parameter file(s) to deploy in the gridview window (may be in the background)")
$fileList = $folderList | Sort-Object -Property Name | Select-Object -Property Name, LastWriteTime, FullName | Out-GridView -PassThru
#Loop through ARM parameter files
foreach($paramFile in $fileList){
    $param = Get-Content -Path $paramFile.FullName | ConvertFrom-Json
    if(!($param)){Write-Output ("Failed " + $resourceType + " JSON parameter file " + [char]34 + $paramFile.FullName + [char]34 + ". Aborting.");break}
    Write-Output ("Deploying " + $resourceType + " " + [char]34 + $param.parameters.($resourceNameProperty).value + [char]34 + " in Resource Group " + [char]34 + $param.parameters.deploymentResourceGroup.value + [char]34 + "...")
    #Kick-off Resource Group ARM template deployment
    $deploy = New-AzResourceGroupDeployment -ResourceGroupName $param.parameters.deploymentResourceGroup.value -Name $param.parameters.($resourceNameProperty).value -TemplateFile $armTemplatePath -TemplateParameterFile $paramFile.FullName
    Write-Output ("`tdeployment " + $deploy.ProvisioningState)
}
# SIG # Begin signature block
# MIIHXAYJKoZIhvcNAQcCoIIHTTCCB0kCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQU75lbrYjUBfbOShByV6vpBjaJ
# Nu+gggS7MIIEtzCCA5+gAwIBAgITOgAAADbrtm8dtBjRgwAAAAAANjANBgkqhkiG
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
# 9w0BCQQxFgQUyN95S6ykeAMU77BLur9aaaoSloswDQYJKoZIhvcNAQEBBQAEggEA
# pawbmPhODhjFLWk67pYmZ4QiK3+OhdgjbX12tYIsotJGWpv1dC7jQr69Gz4QhcEt
# wNGfATQQI/ACFVOOw+HI1g0KLJYkbQ8wXMNMr2jDppWqEnUyfrdy/TQ6/sJN3jII
# m8JlmcXmlqVt962wwGRGXEZuUqiPABZA9P8KGKy5k+8Eul+wjxQBKRE1JLTmNfCK
# 5mIEL7rFws4YGmjCdAlT5L2hNlarZWzxRJs00UT/cDH7OyiCbQulnRUWRFimjAUS
# NTty4iTpVciSJ6K3cutOOJDgSMl5cw2o9wQNToU/BqzhoCCSNXpHWB5bfoRUgpOb
# QL8q2YcYgAuxyBCkzWe3Qg==
# SIG # End signature block
