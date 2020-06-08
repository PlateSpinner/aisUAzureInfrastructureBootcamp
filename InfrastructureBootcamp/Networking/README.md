# Azure Network Resource Deployment

## Network Security Groups

1. Copy original parameter file "FABIEN-E2-NSG.json" into your own file. For instance "BOB-E2-NSG.json"
2. Edit your NSG parameter file and edit parameters accordingly:
	* "nsgNamePrefix": Edit the NSG name prefix with your name.
	* "edAddressPrefix", "apAddressPrefix" and "dbAddressPrefix": do a Find & Replace (CTRL+H) on 10.171. and replace with your own supernet that was assigned to you in spreadsheet "2020-03 Attendees.xslx" in the Teams channel files, for instance 10.161.
3. Deploy the NSG files using script "NSG_deploy.ps1". Just run it (F5) and it will ask you to choose which parameter file to deploy.

## Virtual Network

1. Copy original parameter file "FABIEN-E2-VNET.json" into your own file. For instance "BOB-E2-VNET.json"
2. Edit your VNET parameter file and edit parameters accordingly:
	* "vnetName": Edit the VNET name prefix with your name.
	* "vnetAddressPrefix" and "subnets": do a Find & Replace (CTRL+H) on 10.171. and replace with your own supernet that was assigned to you in spreadsheet "2020-03 Attendees.xslx" in the Teams channel files, for instance 10.161.
	* "subnets": for each subnet:
		* "SubnetName": Rename with your name.
		* "NsgResourceGroup" and "NsgName": adjust reference to the NSG as needed.
3. Deploy the VNET using script "VNET_deploy.ps1". Just run it (F5) and it will ask you to choose which parameter file to deploy.

## Virtual Network Gateway

1. Copy original parameter file "FABIEN-E2-VNETGW.json" into your own file. For instance "BOB-E2-VNETGW.json"
2. Edit your VNEt Gateway parameter file and edit parameters accordingly:
	* "VNETName", "gatewayPublicIPName" and "gatewayName": Edit with your own name.
	* "Connections"/"PSK": Edit with your own password that was assigned to you in spreadsheet "2020-03 Attendees.xslx" in the Teams channel files.
3. Deploy the VNET Gateway using script "VNETGW_deploy.ps1". Just run it (F5) and it will ask you to choose which parameter file to deploy.