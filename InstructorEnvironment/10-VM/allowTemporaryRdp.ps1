#Temporary attaches a public IP to a VM and open RDP in NSG.
#Fabien Gilbert, AIS, November of 2019
$networkRg = "AISU-E2-RG-NETWORK"
$nicRg = "AISU-E2-RG-01-001"
$nicName = "AISU-E2-JUMP-NIC-001"
$nsgRg = "AISU-E2-RG-NSG"
$nsgName = "AISU-E2-NSG-JP"
$ipName = "AISU-E2-PIP-02"
$pip = $null
$nic = $null
$nsg = $null
$secRule = $null
$revertprompt = $null
#get public IP
$ipInfoJson = Invoke-WebRequest -Uri http://ipinfo.io/json
$ipInfo = $ipInfoJson.Content | ConvertFrom-Json
#get IP
$pip = Get-AzPublicIpAddress -ResourceGroupName $networkRg -Name $ipName
if(!($pip)){Write-Error -Message ("Could not get Public IP Address  " + [char]34 + $pip + [char]34 + ". Aborting.");exit}
#get NIC
Write-Output ("Getting NIC " + [char]34 + $nicName + [char]34 + "...")
$nic = Get-AzNetworkInterface -ResourceGroupName $nicRg -Name $nicName
if(!($nic)){Write-Error -Message ("Could not get NIC " + [char]34 + $nicName + [char]34 + ". Aborting.");exit}
if($nic.IpConfigurations[0].PublicIpAddress.Id -ne $pip.Id){
    Write-Output ("Setting Public IP name " + [char]34 + $pip.Name + [char]34 + " FQDN " + [char]34 + $pip.DnsSettings.Fqdn + [char]34 + " on NIC " + [char]34 + $nic.Name + [char]34 + "...")
    $setPIP = Set-AzNetworkInterfaceIpConfig -NetworkInterface $nic -PublicIpAddress $pip -Name $nic.IpConfigurations[0].Name
    $setNIC = Set-AzNetworkInterface -NetworkInterface $nic
    Write-Output ("provisioning completed with status " + $setNIC.ProvisioningState + "...")
}
#get NSG
Write-Output ("Getting NSG " + [char]34 + $nsgName + [char]34 + "...")
$nsg = Get-AzNetworkSecurityGroup -ResourceGroupName $nsgRg -Name $nsgName
if(!($nsg)){Write-Error -Message ("Could not get NSG " + [char]34 + $nsgName + [char]34 + ". Aborting.");exit}
#build security rules
$secRule = New-AzNetworkSecurityRuleConfig -Access "Allow" `
                                           -Direction "inbound" `
                                           -Priority 190 `
                                           -Name "AllowInBoundRDPfromInternet" `
                                           -Description ("Allow temporary InBound RDP from " + $ipInfo.ip + ". Created on " + (Get-Date -UFormat %Y-%m-%d) + " at " + (Get-Date -UFormat %H:%M) + ".") `
                                           -Protocol "tcp" `
                                           -SourceAddressPrefix $ipInfo.ip `
                                           -DestinationAddressPrefix $nic.IpConfigurations[0].PrivateIpAddress `
                                           -SourcePortRange "*" `
                                           -DestinationPortRange "3389"
if(!($nsg.SecurityRules | Where-Object {$_.DestinationPortRange -eq $secrule.destinationPortRange -and $_.Priority -eq $secrule.Priority -and $_.SourceAddressPrefix -eq $ipInfo.ip})){
    Write-Output ("Adding Security Rule below to NSG " + [char]34 + $nsgName + [char]34 + "...")
    $secRule
    $nsg.SecurityRules += $secRule
    $nsgSave = $nsg | Set-AzNetworkSecurityGroup
    Write-Output ("Security Rule addition completed with status " + $nsgSave.ProvisioningState + ".")
}
Write-Output ("`r`n" + $ipInfo.ip + " should now be able to RDP into " + [char]34 + $pip.DnsSettings.Fqdn + [char]34 + ".")
do{
    $revertprompt = Read-Host -Prompt "`r`nEnter Y when ready to revert or N to keep as is and exit"
}until($revertprompt -eq "Y" -or $revertprompt -eq "N")
if($revertprompt -eq "N"){exit}
#Revert configuration
#get NSG
Write-Output ("Getting NSG " + [char]34 + $nsgName + [char]34 + "...")
$nsg = Get-AzNetworkSecurityGroup -ResourceGroupName $nsgRg -Name $nsgName
if(!($nsg)){Write-Error -Message ("Could not get NSG " + [char]34 + $nsgName + [char]34 + ". Aborting.");exit}
Write-Output ("Removing Security Rule from NSG " + [char]34 + $nsgName + [char]34 + "...")
$nsg.SecurityRules = $nsg.SecurityRules | Where-Object {!($_.DestinationPortRange -eq $secrule.destinationPortRange -and $_.Priority -eq $secrule.Priority -and $_.SourceAddressPrefix -eq $ipInfo.ip)}
$nsgSave = $nsg | Set-AzNetworkSecurityGroup
#get NIC
$nic = Get-AzNetworkInterface -ResourceGroupName $nicRg -Name $nicName
if(!($nic)){Write-Error -Message ("Could not get NIC " + [char]34 + $nicName + [char]34 + ". Aborting.");exit}
Write-Output ("Removing Public IP name " + [char]34 + $pip.Name + [char]34 + " from NIC " + [char]34 + $nic.Name + [char]34 + "...")
$nic.IpConfigurations[0].PublicIpAddress = $null
$setNIC = Set-AzNetworkInterface -NetworkInterface $nic
Write-Output ("provisioning completed with status " + $setNIC.ProvisioningState + "...")