#Build Automation Account, import module, upload and compile DSC configurations
#Fabien Gilbert, AIS, 2019-08
function Import-AutoModule {
  # Requires that authentication to Azure is already established before running 
  param(
    [Parameter(Mandatory=$true)]
    [String] $ResourceGroupName,
  
    [Parameter(Mandatory=$true)]
    [String] $AutomationAccountName,
     
    [Parameter(Mandatory=$true)]
    [String] $ModuleName,
  
    # if not specified latest version will be imported
    [Parameter(Mandatory=$false)]
    [String] $ModuleVersion
  )  
  $Url = "https://www.powershellgallery.com/api/v2/Search()?`$filter=IsLatestVersion&searchTerm=%27$ModuleName $ModuleVersion%27&targetFramework=%27%27&includePrerelease=false&`$skip=0&`$top=40"
  $SearchResult = Invoke-RestMethod -Method Get -Uri $Url 
  $SearchResult = $SearchResult | Where-Object {$_.id -like ("*Id='" + $ModuleName + "'*")}
  if(!$SearchResult) {
    Write-Error "Could not find module '$ModuleName' on PowerShell Gallery."
  }
  elseif($SearchResult.C -and $SearchResult.Length -gt 1) {
    Write-Error "Module name '$ModuleName' returned multiple results. Please specify an exact module name."
  }
  else {
    $PackageDetails = Invoke-RestMethod -Method Get -Uri $SearchResult.id      
    if(!$ModuleVersion) {
        $ModuleVersion = $PackageDetails.entry.properties.version
    }  
    $ModuleContentUrl = "https://www.powershellgallery.com/api/v2/package/$ModuleName/$ModuleVersion"  
    # Test if the module/version combination exists
    try {
        Invoke-RestMethod $ModuleContentUrl -ErrorAction Stop | Out-Null
        $Stop = $False
    }
    catch {
        Write-Error "Module with name '$ModuleName' of version '$ModuleVersion' does not exist. Are you sure the version specified is correct?"
        $Stop = $True
    }  
    if(!$Stop) {
  
        # Find the actual blob storage location of the module
        do {
            $ActualUrl = $ModuleContentUrl
            $ModuleContentUrl = (Invoke-WebRequest -Uri $ModuleContentUrl -MaximumRedirection 0 -ErrorAction Ignore).Headers.Location 
        } while($ModuleContentUrl -ne $Null)
  
        New-AzAutomationModule `
            -ResourceGroupName $ResourceGroupName `
            -AutomationAccountName $AutomationAccountName `
            -Name $ModuleName `
            -ContentLink $ActualUrl
    }
  }  
}
$deploymentParameter = @{
  "deploymentResourceGroup"="AISU-E2-RG-AUTO"
  "AutomationAccountName"="AISU-E2-AUA"
  "AutomationAccountSku"="Free"}
$automationModules = "Name,Version
Az.Accounts,
Az.Automation,
Az.Compute,2.6.0
Az.KeyVault,
Az.Network,
Az.Resources,
Az.Storage,1.7.0" | ConvertFrom-Csv
#Build Automation Account
New-AzResourceGroupDeployment -Name ("Automation_"+ (Get-Date -UFormat %Y%m%d%H%M)) -ResourceGroupName $deploymentParameter.deploymentResourceGroup -TemplateFile "..\automationAccount_armTemplate.json" -TemplateParameterObject $deploymentParameter -Verbose
#Get Azure Automation Account
$autoAccount = Get-AzAutomationAccount -ResourceGroupName $deploymentParameter.deploymentResourceGroup -Name $deploymentParameter.AutomationAccountName
if(!($autoAccount)){Write-Error -Message ("Could not find Automation Account " + [char]34 + $deploymentParameter.AutomationAccountName + [char]34);exit}
###################################
#CREATE RUN AS ACCOUNT IN PORTAL  #
###################################
#Import Azure Automation Modules
Import-AutoModule -ResourceGroupName $AutoAccount.ResourceGroupName -AutomationAccountName $AutoAccount.AutomationAccountName -ModuleName PackageManagement
Import-AutoModule -ResourceGroupName $AutoAccount.ResourceGroupName -AutomationAccountName $AutoAccount.AutomationAccountName -ModuleName NetworkingDsc
Import-AutoModule -ResourceGroupName $AutoAccount.ResourceGroupName -AutomationAccountName $AutoAccount.AutomationAccountName -ModuleName ComputerManagementDsc -ModuleVersion "6.1.0.0"
Import-AutoModule -ResourceGroupName $AutoAccount.ResourceGroupName -AutomationAccountName $AutoAccount.AutomationAccountName -ModuleName StorageDsc
Import-AutoModule -ResourceGroupName $AutoAccount.ResourceGroupName -AutomationAccountName $AutoAccount.AutomationAccountName -ModuleName xWebAdministration
foreach($module in $automationModules){
  Import-AutoModule -ResourceGroupName $AutoAccount.ResourceGroupName -AutomationAccountName $AutoAccount.AutomationAccountName -ModuleName $module.Name -ModuleVersion $module.Version
}
#Upload DSC Configs
####################################
#Browse to DSC configuration folder#
####################################
$dscConfigFiles = Get-ChildItem -Filter "*.ps1"
foreach($dscConfigFile in $dscConfigFiles[3]){
  Write-Output ("Uploading DSC config " + [char]34 + $dscConfigFile.name + [char]34 + " to Automation Account " + [char]34 + $autoAccount.AutomationAccountName + [char]34 + "...")
  Import-AzAutomationDscConfiguration -ResourceGroupName $AutoAccount.ResourceGroupName -AutomationAccountName $AutoAccount.AutomationAccountName  -SourcePath $dscConfigFile.FullName -Published -Force
  Write-Output ("Compiling DSC config " + [char]34 + $dscConfigFile.name + [char]34 + " in Automation Account " + [char]34 + $autoAccount.AutomationAccountName + [char]34 + "...")
  $configName = $null;$configName = $dscConfigFile.Name.subString(0,$dscConfigFile.Name.LastIndexOf("."))
  Start-AzAutomationDscCompilationJob -ResourceGroupName $AutoAccount.ResourceGroupName -AutomationAccountName $AutoAccount.AutomationAccountName -ConfigurationName $configName
  Get-AzAutomationDscCompilationJob -ResourceGroupName $AutoAccount.ResourceGroupName -AutomationAccountName $AutoAccount.AutomationAccountName -ConfigurationName $configName
}