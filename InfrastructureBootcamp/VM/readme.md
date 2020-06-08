scripts & tools used in day 7 of Azure Infrastructure Bootcamp
# Prerequisites <h1>

	VNET with correct Address space, DNS
	Verify your VNET DNS servers are set to:
		10.154.4.4
		10.154.4.5
	Subnet 
	VPN Gateway including Successful Connection
	key vault Secrets:
		Account and password used to join instructor environment domain
			azuredomainjoin
			4Tj(&1pS)Yp1

		Local administrator account on VM 
			localman
			1234!@#$qwerQWER  (this can be whatever password value you want to set)

		Create a self signed certificate using PowerShell
			$cert = New-SelfSignedCertificate -certstorelocation cert:\localmachine\my -dnsname <yourname>.contoso.test
			$pwd = ConvertTo-SecureString -String 'passw0rd!' -Force -AsPlainText
			$path = 'cert:\localMachine\my\' + $cert.thumbprint Export-PfxCertificate -cert $path -FilePath c:\cert.pfx -Password $pwd
			
			Import the self signed certificate into key vault
	Storage Account 

# Virtual Machine Deployment by ARM Template <h1>
1. Copy original parameter file "STEVEN_WEBVMs.json" into your own file. For instance "BOB-E2-VNET.json"

2. Edit your VNET parameter file and edit parameters accordingly:
	* "availabilitySets" : Edit the value name prefix with your name.
	* "vnetName": Edit the VNET name prefix with your name.
	* "keyVaultName" : Edit the value prefix with your name.
	* "workspaceName" : Edit the value prefix with your name.
	* "vmSettings" : Each vmName, dataDisks, subnetName, and vmAvailabilitySetName edit the value prefix with your name
	* "sslCertificate" : Edit the value prefix with your name.
	* "privateIPAddress" : The first two octets of your address should be within your assigned subnet (ex. 10.172.) 
	* "vmName" : total legnth cannot be longer than 15 characters

3. Verify you have an NSG rule that allows 443 outbound (maybe not needed?)

4. Connect to Azure and deploy

``` PowerShell
Test-AzResourceGroupDeployment -TemplateFile .\vm_armTemplate.json -TemplateParameterFile .\parameters\<yourFullFirstName>_WEBVMs.json -ResourceGroupName "AISU-E2-RG-01" -Debug
New-AzResourceGroupDeployment -TemplateFile .\vm_armTemplate.json -TemplateParameterFile .\parameters\<yourFullFirstName>_WEBVMs.json -ResourceGroupName "AISU-E2-RG-01"
```


# End of Day Goal <h1>

* Deployed Virtual Machines: 
* Deployed VMs using ARM Template.  
* DSC configuration applied. 
* Disks configured (custom script). 
* Log Analytics Workspace joined. 
* Anti-malware installed. 
* SSL Certificate imported. 
* Remoted to VMs from Jump Server through RDP 
