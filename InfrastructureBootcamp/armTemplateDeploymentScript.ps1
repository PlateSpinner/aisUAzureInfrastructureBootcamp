#Deploy ARM Templates
#Fabien Gilbert, AIS, 2019/08
$currentFolder = Split-Path $script:MyInvocation.MyCommand.Path
Write-Output "Select the arm template file and the parameter file in the gridview window (might be in the backgroun)"
$jsonFiles = Get-ChildItem -Path $currentFolder -Filter "*.json" -Recurse | Select-Object Name, FullName | Out-GridView -PassThru
$armTemplatePath = $jsonFiles | Where-Object -Property Name -Like -Value "*armTemplate.json"
$armParameterPath = $jsonFiles | Where-Object -Property FullName -NE $armTemplatePath.FullName
$armTemplate = Get-Content -Path $armTemplatePath.FullName -Raw | ConvertFrom-Json
$armParameter = Get-Content -Path $armParameterPath.FullName -Raw | ConvertFrom-Json
$deploymentName = ($armTemplatePath.Name.Substring(0,$armTemplatePath.Name.LastIndexOf("_")) + (Get-Date -UFormat %Y%m%d%H%M))
if($armTemplate.parameters.deploymentLocation){
    Write-Output ("Deploying template " + [char]34 + $armTemplatePath.Name + [char]34 + " parameters " + [char]34 + $armParameterPath.Name + [char]34 + " to subscription " + [char]34 + (Get-AzContext).Subscription.Name + [char]34 + " location " + [char]34 + $armParameter.parameters.deploymentLocation.value + [char]34 + "...")    
    New-AzDeployment -Location $armParameter.parameters.deploymentLocation.value -Name $deploymentName -TemplateFile $armTemplatePath.FullName -TemplateParameterFile $armParameterPath.FullName -Verbose
}
if($armTemplate.parameters.deploymentResourceGroup){
    Write-Output ("Deploying template " + [char]34 + $armTemplatePath.Name + [char]34 + " parameters " + [char]34 + $armParameterPath.Name + [char]34 + " to resource group " + [char]34 + $armParameter.parameters.deploymentResourceGroup.value + [char]34 + "...")
    New-AzResourceGroupDeployment -Name $deploymentName -ResourceGroupName $armParameter.parameters.deploymentResourceGroup.value -TemplateFile $armTemplatePath.FullName -TemplateParameterFile $armParameterPath.FullName -Verbose
}