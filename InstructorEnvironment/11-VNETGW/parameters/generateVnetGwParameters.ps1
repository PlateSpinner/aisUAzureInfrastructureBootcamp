#Generate VNETGW parameter file with student's Local VNET Gateway and Connection info
#Fabien Gilbert, AIS, 2019/08
#
#Select VNET GW parameter file
$currentFolder = Split-Path $script:MyInvocation.MyCommand.Path
Write-Output "Select the VNET GW JSON parameter file to complete in the gridview window (might be in the backgroun)"
$vnetGwParameterFile = Get-ChildItem -Path $currentFolder -Filter "*.json" -Recurse | Select-Object Name, FullName | Out-GridView -PassThru
#Select Attendees spreadsheet
Write-Output "Select the students/attendees' list spreadsheet in the dialog box (may be in the background)..."
Add-Type -AssemblyName System.Windows.Forms
$FileBrowser = New-Object System.Windows.Forms.OpenFileDialog -Property @{ 
    InitialDirectory = [Environment]::GetFolderPath('Desktop') 
    Filter = 'SpreadSheet (*.xlsx)|*.xlsx'
}   
$null = $FileBrowser.ShowDialog()
Write-Output ("Importing JSON file " + [char]34 + $vnetGwParameterFile.FullName + [char]34 + "...")
$vnetGwParameter = Get-Content -Path $vnetGwParameterFile.FullName | ConvertFrom-Json
$attendeesList = Import-Excel -Path $FileBrowser.FileName
if(!($vnetGwParameter -and $attendeesList)){Write-Error -Message "Could not open the VNET GW JSON Parameter file and/or the Attendees spreadsheet.";exit}
foreach($A in ($attendeesList | Where-Object {$_.username -and $_.supernet -and $_.Username -and $_.password -and $_.'VNET GW IP Address' -notlike "1.1.1*"})){
    $nameArray = $null;$lgwName = $null;$attendeeLGW = $null;$attendeeConnection = $null;$nameTag=$null;$nameTag1=$null;$nameTag2=$null
    $nameArray = $A.Username.Split("@")[0].Split(".")
    if($nameArray[0].Length -ge 3){$nameTag1=$nameArray[0].Substring(0,3).toUpper()}
    else{$nameTag1=$nameArray[0].toUpper()}    
    if($nameArray[1].Length -ge 3){$nameTag2=$nameArray[1].Substring(0,3).toUpper()}
    else{$nameTag2=$nameArray[1].toUpper()}
    $nameTag = ($nameTag1 + $nameTag2)
    $lgwName = ("LGW-" + $nameTag)
    $connectionName = ("TO-" + $nameTag)
    $attendeeLGW = $vnetGwParameter.parameters.localGateways.value | Where-Object -Property GatewayName -EQ -Value $lgwName
    if(!($attendeeLGW)){
        Write-Output ("`tAdding Local Network Gateway " + [char]34 + $lgwName + [char]34 + "..." )
        $vnetGwParameter.parameters.localGateways.value += New-Object -TypeName PSObject -Property @{
            "GatewayName" = $lgwName
            "GatewayIpAddress" = $A.'VNET GW IP Address'
            "LocalNetworkAddressPrefixes" = ([array]($A.supernet))
        }
    }
    $attendeeConnection = $vnetGwParameter.parameters.Connections.value | Where-Object -Property LocalNetworkGateway -EQ -Value $lgwName
    if(!($attendeeConnection)){
        Write-Output ("`tAdding Connection " + [char]34 + $connectionName + [char]34 + "..." )
        $vnetGwParameter.parameters.Connections.value += New-Object -TypeName PSObject -Property @{
            "LocalNetworkGateway" = $lgwName
            "ConnectionName" = $connectionName
            "PSK" = $A.password
        }
    }
}
Write-Output ("Exporting JSON file " + [char]34 + $vnetGwParameterFile.FullName + [char]34 + "...")
ConvertTo-Json -InputObject $vnetGwParameter -Depth 10 | Out-File -FilePath $vnetGwParameterFile.FullName