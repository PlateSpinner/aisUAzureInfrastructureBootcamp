
#Build new AD Domain
Install-ADDSForest -DomainName "ad.aisu.cloud" -DomainNetbiosName "AISU" -DatabasePath F:\NTDS -LogPath F:\NTDS -SysvolPath F:\SYSVOL -SafeModeAdministratorPassword (ConvertTo-SecureString -AsPlainText -String "P@$$w0rd" -Force)

#Set DNS Forwarders
Set-DnsServerForwarder -IPAddress 168.63.129.16

#Create AD Sites
New-ADReplicationSite -Name AISU-E
New-ADReplicationSubnet -Name "10.154.0.0/16" -Site AISU-E
#New-ADReplicationSite -Name HUB-S
#New-ADReplicationSubnet -Name "10.24.64.32/19" -Site HUB-S
#New-ADReplicationSiteLink -Name "HUB-E-S" -SitesIncluded HUB-E, HUB-S  -Cost 100 -ReplicationFrequencyInMinutes 15
Remove-ADReplicationSite -Identity "Default-First-Site-Name" -Confirm:$false

#Create Reverse DNS Zones
$i=2
do{
    Add-DnsServerPrimaryZone -NetworkID ("10.154." + $i + ".0/24") -ReplicationScope "Forest"
    $i++
}until($i -gt 5)

#Create AD Structure & users
$domainRoot = "DC=ad,DC=aisu,DC=cloud"
New-ADOrganizationalUnit -Name "Servers" -Path $domainRoot
New-ADOrganizationalUnit -Name "Admins" -Path $domainRoot
New-ADOrganizationalUnit -Name "Security Groups" -Path $domainRoot
New-ADOrganizationalUnit -Name "Services Accounts" -Path $domainRoot
New-ADOrganizationalUnit -Name "User Accounts" -Path $domainRoot
#Create domain join user
New-ADUser -Name AzureDomainJoin -Path ("OU=Admins," + $domainRoot) -DisplayName "Azure Domain Join" -UserPrincipalName azureDomainJoin@ad.aisu.cloud -GivenName "Domain Join" -Surname "Azure"
Set-ADAccountPassword -Identity AzureDomainJoin
Set-ADUser -Enabled $true -Identity azuredomainjoin
#Delegate Domain Join permissions
$IdentityReference = [System.Security.Principal.NTAccount] "AzureDomainJoin"
$DistinguishedName = 'CN=AzureDomainJoin,OU=Admins,DC=id,DC=fabienlab,DC=com'
$SD = Get-Acl "AD:\$DistinguishedName"
# Validated write to DNS host name
$SD.AddAccessRule((New-Object System.DirectoryServices.ActiveDirectoryAccessRule (
    $IdentityReference,
    'Self',  # Validated Write access mask ([System.DirectoryServices.ActiveDirectoryRights])
    'Allow', # ACE type ([System.Security.AccessControl.AccessControlType])
    '72e39547-7b18-11d1-adef-00c04fd8d5cd',  # GUID for 'Validated write to DNS host name'
    'Descendents',  # ACE will only apply to child objects ([System.DirectoryServices.ActiveDirectorySecurityInheritance])
    'bf967a86-0de6-11d0-a285-00aa003049e2'  # Inherited object type (in this case in can apply to computers)
)))
# Validated write to service principal name
$SD.AddAccessRule((New-Object System.DirectoryServices.ActiveDirectoryAccessRule (
    $IdentityReference,
    'Self',  # Access mask
    'Allow',
    'f3a64788-5306-11d1-a9c5-0000f80367c1',  # GUID for 'Validated write to service principal name'
    'Descendents',
    'bf967a86-0de6-11d0-a285-00aa003049e2'
)))
# Write Account Restrictions
$SD.AddAccessRule((New-Object System.DirectoryServices.ActiveDirectoryAccessRule (
    $IdentityReference,
    'ReadProperty, WriteProperty',  # Access mask
    'Allow',
    '4c164200-20c0-11d0-a768-00aa006e0529',  # GUID for 'Account Restrictions' PropertySet
    'Descendents',
    'bf967a86-0de6-11d0-a285-00aa003049e2'
)))
# Create and Delete computer objects
$SD.AddAccessRule((New-Object System.DirectoryServices.ActiveDirectoryAccessRule (
    $IdentityReference,
    'CreateChild, DeleteChild',  # Access mask
    'Allow', 
    'bf967a86-0de6-11d0-a285-00aa003049e2',  # GUID for 'Computer' object
    'All',         # Object and ChildObjects
    [guid]::Empty  # Don't restrict objects this can apply to (You could restrict it to OUs)
)))
$SD | Set-Acl

#Create Fabien's account
New-ADUser -Name fabien1 -Path ("OU=Admins," + $domainRoot) -DisplayName "Fabien Gilbert Admin" -UserPrincipalName fabien1@ad.aisu.cloud -GivenName "Fabien" -Surname "Gilbert"
Set-ADAccountPassword -Identity fabien1
Set-ADUser -Enabled $true -Identity fabien1
Add-ADGroupMember -Identity "Domain Admins" -Members fabien1