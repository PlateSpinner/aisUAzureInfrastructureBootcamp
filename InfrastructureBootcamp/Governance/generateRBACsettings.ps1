$sheet = Import-Excel -Path "C:\Users\Fabien.Gilbert.APPLIEDIS\Documents\Internal\OCTO\AIS Azure Bootcamp\2020-03 Attendees.xlsx" -WorksheetName "sheet1"
$produsers = $sheet | where {$_.MGP -eq "PROD-MGP"}
$prodrbac = @()
foreach($pu in $produsers){
    $aadObj = $null
    $aadObj = Get-AzADUser -UserPrincipalName $pu.'AIS Email'
    $prodrbac += @{
        "Role Definition Name"= "Contributor"
        "AAD Object Name"=($pu.givenName + " " + $pu.surname)
        "AAD Object Id"=$aadObj.Id
    }
}
$prodrbac | ConvertTo-Json
$devusers = $sheet | where {$_.MGP -eq "DEV-MGP"}
$devrbac = @()
foreach($pu in $devusers){
    $aadObj = $null
    $aadObj = Get-AzADUser -UserPrincipalName $pu.'AIS Email'
    $devrbac += @{
        "Role Definition Name"= "Contributor"
        "AAD Object Name"=($pu.givenName + " " + $pu.surname)
        "AAD Object Id"=$aadObj.Id
    }
}
$devrbac | ConvertTo-Json