#Delete Connectioms, Local Network Gateways and VNETGW
$NetworkRG = "AISU-E2-RG-NETWORK"
$connections = Get-AzVirtualNetworkGatewayConnection -ResourceGroupName $NetworkRG
$lgws = Get-AzLocalNetworkGateway -ResourceGroupName $NetworkRG
$vnetgws = Get-AzVirtualNetworkGateway -ResourceGroupName $NetworkRG
Write-Output ("Deleting " + $connections.count + " Virtual Network Gateway Connections below...")
$connections | Select-Object -ExpandProperty Name
$connections | Remove-AzVirtualNetworkGatewayConnection -Force -Confirm:$false
Write-Output ("Deleting " + $lgws.count + " Local Network Gateways below...")
$lgws | Select-Object Name, GatewayIpAddress
$lgws | Remove-AzLocalNetworkGateway -Force -Confirm:$false
Write-Output ("Deleting " + $vnetgws.count + " Virtual Network Gateways below...")
$vnetgws | Select Name, @{l="SKU";e={$_.Sku.Tier}}
$vnetgws | Remove-AzVirtualNetworkGateway -Force -Confirm:$false
$pip = Get-AzPublicIpAddress -ResourceGroupName $NetworkRG | Where-Object -Property Id -eq $vnetgws.IpConfigurations.PublicIPAddress.Id
Write-Output ("Deleting Public IP" + $pip.Name + "...")
$pip | Remove-AzPublicIpAddress -Force -Confirm:$false