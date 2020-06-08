#Read student's end of day files and creates a spreadsheet
#
#Settings file name
$settingsFile = "readStudentFiles.json"
#Check for import excel module
if(!(Get-Module -Name ImportExcel -ListAvailable)){Write-Output "ImportExcel module required. Please install it.";exit}
#Import JSON settings file
$currentFolder = Split-Path $script:MyInvocation.MyCommand.Path
$settingsFilepath = Join-Path -Path $currentFolder -ChildPath $settingsFile
$settings = Get-Content -Path $settingsFilepath | ConvertFrom-Json
if(!($settings)){Write-Output ("Could not open JSON file" + [char]34 + $settingsFile + [char]34 + ". Aborting.");exit}
#List storage account container content
$ctx=$null;$store=$null;$blob1=$null
$ctx = Get-AzContext
if($ctx.Subscription.Id -ne $settings.storageAccount.subscriptionId){Write-Output ("Current context not set to subscription ID " + $settings.storageAccount.subscriptionId + ". Aborting.");exit}
$store1 = Get-AzStorageAccount -ResourceGroupName $settings.storageAccount.resourceGroup -Name $settings.storageAccount.name
$blob1 = Get-AzStorageBlob -Context $store1.Context -Container $settings.storageAccount.container
Write-Output "Select group of files to process in gridview window (may be in the background)"
$blob2 = $blob1 | Select-Object @{l="Group";e={$_.Name.Split("_")[0]}}, Name | Group-Object -Property Group | Out-GridView -PassThru
#Download Student Blobs
$list1 = @()
foreach($b in $blob2.Group){
    #Download blob
    $tmpBlobPath = $null;$downloadBlob=$null;$blobContent=$null
    $tmpBlobPath = (Join-Path -Path $env:TMP -ChildPath $b.Name)
    Write-Output ("downloading blob name " + [char]34 + $b.Name + [char]34 + "...")
    $downloadBlob = Get-AzStorageBlobContent -Context $store1.Context -Container $settings.storageAccount.container -Blob $b.Name -Destination $tmpBlobPath
    #Converting blob to JSON
    $blobContent = Get-Content -Path $tmpBlobPath | ConvertFrom-Json
    $blobContent | Add-Member -NotePropertyName "fileName" -NotePropertyValue $b.Name
    #Filter out instructors files
    if($blobContent){$list1 += $blobContent}
    else{Write-Output ("`tcould not import JSON file " + [char]34 + $tmpBlobPath + [char]34 + "...")}
    Remove-Item -Path $tmpBlobPath -Force -Confirm:$false
}
#Build success array
$list2 = @()
foreach($s in $settings.studentList){
    $ls = $null;$entry = $null
    $ls = $list1 | Where-Object -Property AccountId -Like ($s.givenName + "." + $s.surname + "*") | Sort-Object -Property fileName -Descending | Select-Object -First 1
    if($ls){
        $ls | Add-Member -MemberType NoteProperty -Name givenName -Value $s.givenName
        $ls | Add-Member -MemberType NoteProperty -Name surname -Value $s.surname
        $ls | Add-Member -MemberType NoteProperty -Name fileUploaded -Value "YES"
    }
    else{
        $s | Add-Member -MemberType NoteProperty -Name fileUploaded -Value "NO"
        $ls = $s
    }
    $list2 += $ls
}
#Add unrecognized accounts
$list2AccountIds = $list2 | Where-Object {$_.AccountId} | Select-Object -ExpandProperty AccountId
foreach($a in ($list1 | Where-Object {$list2AccountIds -notcontains $_.AccountId})){
    #Filter out instructors
    if(!($settings.instructorsList | Where-Object {($_.givenname + "." + $_.surname + "@appliedis.com") -eq $a.AccountId})){
        $list2 += $a
    }
}
#add success rate
$list2 += New-Object -TypeName PSObject -Property @{"givenName"="SUCCESS RATE"
                                                    "surname"=([string]([math]::Round(((($list2 | Where-Object {$_.fileUploaded -EQ "YES"}).Count * 100) / $list2.Count),0)) + "%")}                                                    
#Export to spreadsheet
$sheetPath = Join-Path -Path $currentFolder -ChildPath ($blob2.Name + "_successBoard.xlsx")
#format depending in the day
$successReport = $null
switch ($blob2.Name) {
    "day01" {$successReport=$list2 | Select-Object -Property givenName, surname, fileUploaded, fileName, AccountId, SubscriptionName, SubscriptionId, TenantId}
    "day02" {
        foreach($r in $list2){
            $rgpList = $null
            $rgps = $r.ResourceGroups.value
            foreach($rgp in $rgps){
                $rgpList += $rgp.ResourceGroupName
                $arrayIndex = [array]::IndexOf($rgps,$rgp)
                if(($arrayIndex+1) -lt @($rgps).Count){$rgpList+=","}
            }
            $r | Add-Member -MemberType NoteProperty -Name resourceGroupNames -Value $rgpList
            $r | Add-Member -MemberType NoteProperty -Name resourceGroupCount -Value $rgps.Count
            $r | Add-Member -MemberType NoteProperty -Name subscriptionDeploymentsCount -Value $r.subscriptionDeployments.value.Count
        }
        $successReport=$list2 | Select-Object -Property givenName, surname, fileUploaded, fileName, AccountId, SubscriptionName, SubscriptionId, TenantId, subscriptionDeploymentsCount, resourceGroupCount, resourceGroupNames 
    }    
    "day03" {
        foreach($r in $list2){
            $nsgList = $null
            $nsgs = $r.nsgList.value
            foreach($nsg in $nsgs){
                $nsgList += $nsg.Name
                $arrayIndex = [array]::IndexOf($nsgs,$nsg)
                if(($arrayIndex+1) -lt @($nsgs).Count){$nsgList+=","}
            }
            $vnetList = $null
            $vnets = $r.vnet.value
            foreach($vnet in $vnets){
                $vnetList += $vnet.Name
                $arrayIndex = [array]::IndexOf($vnets,$vnet)
                if(($arrayIndex+1) -lt @($vnets).Count){$vnetList+=","}
            }
            $r | Add-Member -MemberType NoteProperty -Name nsgDeploymentsCount -Value @($r.nsgDeployments).Count            
            $r | Add-Member -MemberType NoteProperty -Name nsgNames -Value $nsgList
            $r | Add-Member -MemberType NoteProperty -Name networkDeploymentsCount -Value @($r.networkDeployments).Count
            $r | Add-Member -MemberType NoteProperty -Name vnetNames -Value $vnetList
        }
        $successReport=$list2 | Select-Object -Property givenName, surname, fileUploaded, fileName, AccountId, SubscriptionName, SubscriptionId, TenantId, nsgDeploymentsCount, nsgNames, networkDeploymentsCount, vnetNames 
    }   
    "day04" {
        foreach($r in $list2){
            $r | Add-Member -MemberType NoteProperty -Name keyVaultName -Value $r.keyVault.VaultName
            $r | Add-Member -MemberType NoteProperty -Name logAnalyticsWorkspaceName -Value $r.logAnalyticsWorkspace.Name            
            $r | Add-Member -MemberType NoteProperty -Name automationAccountName -Value $r.automationAccount.AutomationAccountName
            $r | Add-Member -MemberType NoteProperty -Name logDeploymentsCount -Value @($r.logDeployments).Count
            $r | Add-Member -MemberType NoteProperty -Name akvDeploymentsCount -Value @($r.akvDeployments).Count
            $r | Add-Member -MemberType NoteProperty -Name autoDeploymentsCount -Value @($r.autoDeployments).Count
        }
        $successReport=$list2 | Select-Object -Property givenName, surname, fileUploaded, fileName, AccountId, SubscriptionName, SubscriptionId, TenantId, keyVaultName, logAnalyticsWorkspaceName, automationAccountName, logDeploymentsCount, akvDeploymentsCount, autoDeploymentsCount
    } 
    "day05" {
        foreach($r in $list2){
            $vmList = $null
            $vmExtensions = @()            
            $vmExtensionList = $null
            $vms = $r.virtualMachines.value
            foreach($vm in $vms){
                $vmList += $vm.Name
                $arrayIndex = [array]::IndexOf($vms,$vm)
                if(($arrayIndex+1) -lt @($vms).Count){$vmList+=","}
                foreach($evm in ($vm.Extensions | Select-Object -ExpandProperty Id)){
                    $ext = $null
                    $ext = ($evm.Split("/"))[-1]
                    if($vmExtensions -notcontains $ext){$vmExtensions+=$ext}
                }
            }
            foreach($vmExt in $vmExtensions){
                $vmExtensionList += $vmExt
                $arrayIndex = [array]::IndexOf($vmExtensions,$vmExt)
                if(($arrayIndex+1) -lt @($vmExtensions).Count){$vmExtensionList+=","}
            }
            $r | Add-Member -MemberType NoteProperty -Name vmDeploymentsCount -Value $r.vmDeployments.Count
            $r | Add-Member -MemberType NoteProperty -Name vmNames -Value $vmList            
            $r | Add-Member -MemberType NoteProperty -Name vmExtensions -Value $vmExtensionList
        }
        $successReport=$list2 | Select-Object -Property givenName, surname, fileUploaded, fileName, AccountId, SubscriptionName, SubscriptionId, TenantId, vmDeploymentsCount, vmNames, vmExtensions
    }
}
$successReport | Export-Excel -Path $sheetPath -AutoSize
#Apply Formating
$ExcelObj = Open-ExcelPackage -Path $sheetPath 
$sheetDimension = $ExcelObj.Workbook.Worksheets[1].Dimension
$DataRange = "A2:" + $sheetDimension.End.Address
Set-ExcelRow -Worksheet $ExcelObj.Workbook.Worksheets[1] -Row 1 -BackgroundColor ([System.Drawing.Color]::FromArgb(0,112,192)) -Bold -FontSize 12 -FontColor White
Set-ExcelRow -Worksheet $ExcelObj.Workbook.Worksheets[1] -Row $sheetDimension.Rows -BackgroundColor ([System.Drawing.Color]::FromArgb(0,112,192)) -Bold -FontSize 12 -FontColor White
Set-ExcelRange -WorkSheet $ExcelObj.Workbook.Worksheets[1] -Range $DataRange -BorderRight Thin -BorderLeft Thin -BorderBottom Thin -BorderTop Thin -BorderColor ([System.Drawing.Color]::FromArgb(0,112,192))
$ExcelObj.Save()
Write-Output ("`r`nSuccess rate spreadsheet exported to: " + $sheetPath)