Set-ExecutionPolicy RemoteSigned -Confirm:$False

Install-Module -Name Az -AllowClobber -Scope CurrentUser

Enable-AzureRMAlias

#current User All hosts profile:
if (!(Test-Path -Path $PROFILE.CurrentUserAllHosts))
{ New-Item -Type File -Path $PROFILE.CurrentUserAllHosts -ForegroundColor }

#Edit Existing Profile
psedit $PROFILE.CurrentUserAllHosts

import-module az

Get-help get-azvm

Write-Host -ForegroundColor White -BackgroundColor Red "Hello, World!"

$YourName = "Clint"

Write-Host -ForegroundColor White -BackgroundColor Red "Hello, $YourName!"

$Names = "Rob","David","Mark","Tony"

#Get-Member
$loc = Get-Location
$loc | Get-Member
$loc.drive.name

foreach($Name in $Names){
    Write-Host -ForegroundColor White -BackgroundColor Red "Hello, $Name!"
}

$AllStudents = (Import-Csv -Path "InfrastructureBootcamp\01-Tooling\students.csv").employee

foreach($Name in $AllStudents){
    write-host "Hello, $Name - Welcome to the Azure BootCamp!"
}

$ReadHost = read-host "Would you like to Write to the Console? Y/N?"

if($ReadHost -eq "Y") {
Write-host -BackgroundColor Blue -ForegroundColor white "You Selected to Write to the Console"
}else {
    Write-host -BackgroundColor Red -ForegroundColor white "Write to Console - Aborted" 
}

get-process | Export-Csv -path ./process.csv

$Process = import-csv -path "InfrastructureBootcamp\01-Tooling\process.csv" -Delimiter :

$Process

$Process | Format-Table

$Process | Where-Object {$_.Name -like "SVC*"} | Select-Object Name

Get-Command -Noun Variable | Format-Table -Property Name,Definition -AutoSize -Wrap

Get-Command -noun azvm

#Get Help
get-help az
get-help Get-AzVm

get-azvm | get-member

get-content -path "InfrastructureBootcamp\02-Structure\resourceGroup_armTemplate.json"

Get-AzVm
(get-azvm  | Where-Object {$_.Name -like "*CON*"}).location

#-WhatIf Demo
Get-ChildItem -path C:\Temp | Remove-Item -WhatIf

#Key Vault Demo
Get-AzKeyVault
$kv = Get-AzKeyVault
$kvresID = $kv.ResourceId
$kvresID

$secretvalue = ConvertTo-SecureString 'hVFkk965BuUv' -AsPlainText -Force
$secretvalueuser = ConvertTo-SecureString 'domain\clint.richardson' -AsPlainText -Force 

Set-AzKeyVaultSecret -VaultName $kv.vaultname -Name 'ExamplePassword' -SecretValue $secretvalue
Set-AzKeyVaultSecret -VaultName $kv.vaultname -Name 'ExampleUsername' -SecretValue $secretvalueuser

$SecurePassword = (Get-AzKeyVaultSecret -vaultName $kv.vaultname -name "ExamplePassword").SecretValueText
$SecureUsername = (Get-AzKeyVaultSecret -vaultName $kv.vaultname -name "ExampleUsername").SecretValueText

$SecurePassword
$SecureUsername


