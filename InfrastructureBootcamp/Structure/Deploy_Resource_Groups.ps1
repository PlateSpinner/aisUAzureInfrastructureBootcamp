


New-AzDeployment -Location "EastUS" -Name "Deployment1" -TemplateFile ".\InfrastructureBootcamp\Structure\resourceGroup_armTemplate.json" -TemplateParameterFile ".\InfrastructureBootcamp\Structure\parameters\AISU-E-RGs.json"


New-AzDeployment -Location "EastUS2" -Name "Deployment2" -TemplateFile ".\InfrastructureBootcamp\Structure\resourceGroup_armTemplate.json" -TemplateParameterFile ".\InfrastructureBootcamp\Structure\parameters\AISU-E2-RGs.json"