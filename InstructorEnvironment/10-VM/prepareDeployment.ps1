#Prepare VM ARM Parameter file for deployment. Upload disk config file to storage account and create key encryption key
#Fabien Gilbert, AIS, 2019/08
$CustomScriptName = "CustomScriptDiskConfig.ps1"
#
#Function to generate password
function Get-RandomPassword {
    param (
        $pLength
    )    
    $SegmentTypes = "[
        {
            'Number': 1,
            'MinimumRandom': 65,
            'MaximumRandom': 91
        },
        {
            'Number': 2,
            'MinimumRandom': 97,
            'MaximumRandom': 122
        },
        {
            'Number': 3,
            'MinimumRandom': 48,
            'MaximumRandom': 58
        },
        {
            'Number': 4,
            'MinimumRandom': 37,
            'MaximumRandom': 47
        }
    ]" | ConvertFrom-Json
    $PasswordSegments = @()
    do{
        $Fourtet = @()    
        do{
            $SegmentsToAdd = @()
            foreach($SegmentType in $SegmentTypes){
                if($Fourtet -notcontains $SegmentType.Number){$SegmentsToAdd+=$SegmentType.Number}
            }
            $RandomSegment = Get-Random -InputObject $SegmentsToAdd
            $Fourtet += $RandomSegment
            $PasswordSegments += $RandomSegment
        }until($Fourtet.Count -ge 4 -or $PasswordSegments.Count -ge $pLength)    
    }until($PasswordSegments.Count -ge $pLength)
    $RandomPassword = $null
    foreach($PasswordSegment in $PasswordSegments){
        $SegmentType=$null;$SegmentType = $SegmentTypes | Where-Object -Property Number -EQ -Value $PasswordSegment    
        $RandomPassword += [char](Get-Random -Minimum $SegmentType.MinimumRandom -Maximum $SegmentType.MaximumRandom)
    }
    $RandomPassword
}
#
$currentFolder = Split-Path $script:MyInvocation.MyCommand.Path
Write-Output "Select the VM arm parameter file in the gridview window (might be in the backgroun)"
$paramFilePath = Get-ChildItem -Path ($currentFolder + "\parameters") -Filter "*.json" -Recurse | Select-Object Name, FullName | Out-GridView -PassThru
$paramFile=$null;$paramFile = Get-Content -Path $paramFilePath.FullName | ConvertFrom-Json
if(!($paramFile)){Write-Error -Message ("could not import JSON parameter file " + [char]34 + $paramFilePath.FullName + [char]34 + ".");exit}
$paramFile = Get-Content -Path $paramFilePath.FullName | ConvertFrom-Json
#Create and upload disk configuration file
#Get custom script storage account context
$StorObj = Get-AzStorageAccount -ResourceGroupName $paramFile.parameters.customScriptStorageResourceGroup.value -Name $paramFile.parameters.customScriptStorageAccount.value
#Prepare ARM parameters for script extension
foreach($vmSettings in $paramFile.parameters.VmSettings.value){
    $vmDisks = $vmSettings.DataDisks
    $CustomScriptDiskFile = "DiskConfig_" + $vmSettings.VmName + ".json"
    $CustomScriptDiskFilePath = $env:TEMP + "\" + $CustomScriptDiskFile
    $diskArray = $vmDisks | Select-Object @{l="LUN";e={[array]::IndexOf($VmDisks,$_)}}, @{l="DiskLabel";e={$_."name"}}, @{l="DiskLetter";e={$_."letter"}}
    ConvertTo-Json -InputObject ([array]$diskArray)  | Out-File -FilePath $CustomScriptDiskFilePath
    Write-Output ("Uploading " + $CustomScriptDiskFile + " to " + $paramFile.parameters.customScriptStorageAccount.value + "...")
    Set-AzureStorageBlobContent -Context $StorObj.Context -Container $paramFile.parameters.customScriptStorageContainer.value -File $CustomScriptDiskFilePath -Blob $CustomScriptDiskFile      
    Remove-Item -Path $CustomScriptDiskFilePath -Force -Confirm:$false
    $vmSettings.customScriptFiles = (@($CustomScriptName,$CustomScriptDiskFile))
    $vmSettings.customScriptCommand = ($CustomScriptName)
    $vmSettings.customScriptTimeStamp = ([int](Get-Date -UFormat %Y%m%d%H))
    #Create Key Vault Encryption Key
    if($vmSettings.diskEncryptionUseKek -eq "kek"){
        $keyVaultKeyName = $vmSettings.vmName + "-KEY"
        $vmKeyVaultKey = Get-AzKeyVaultKey -VaultName $paramFile.parameters.keyVaultName.value -Name $keyVaultKeyName -ErrorAction:SilentlyContinue
        if(!($vmKeyVaultKey)){
            $vmKeyVaultKey = Add-AzKeyVaultKey -VaultName $paramFile.parameters.keyVaultName.value -Name $keyVaultKeyName -Destination Software
        }
        $vmSettings.diskEncryptionKekUrl = $vmKeyVaultKey.Id
    }
    #Create Key Vault Secret
    $keyVaultSecret = Get-AzKeyVaultSecret -VaultName $paramFile.parameters.keyVaultName.value -Name $paramFile.parameters.vmLocalUsername.value -ErrorAction:SilentlyContinue
    if(!($keyVaultSecret)){
        #Generate random password
        Write-Output ("generating random password for username " + [char]34 + $paramFile.parameters.vmLocalUsername.value + [char]34 + " and saving it to key vault " + [char]34 + $paramFile.parameters.keyVaultName.value + [char]34 + "...")
        $randomPassword = Get-RandomPassword -pLength 12
        $secureRandomPassword = ConvertTo-SecureString -String $randomPassword -AsPlainText -Force
        $keyVaultSecret = Set-AzKeyVaultSecret -VaultName $paramFile.parameters.keyVaultName.value -Name $paramFile.parameters.vmLocalUsername.value -SecretValue $secureRandomPassword
    }
}
#Export ARM parameters with Custom Script parameters
$paramFile | ConvertTo-Json -Depth 10 | Out-File -FilePath $paramFilePath.FullName