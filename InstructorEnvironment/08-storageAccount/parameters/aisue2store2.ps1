$storeRG = "AISU-E2-RG-01-001"
$storeName = "aisue2store2"
$keyVaultRG = "AISU-E2-RG-AKV"
$keyVaultName = "AISU-E2-AKV-01"
$keyVaultKeyName = "aisue2storekey"
#Create Key Vault Encryption Keyget-az
$StorageAccountKeyVaultKey = Get-AzKeyVaultKey -VaultName $keyVaultName -Name $keyVaultKeyName -ErrorAction:SilentlyContinue
if(!($StorageAccountKeyVaultKey)){
    $StorageAccountKeyVaultKey = Add-AzKeyVaultKey -VaultName $keyVaultName -Name $keyVaultKeyName -Destination Software
}
#Assign Identity to Storage Account
Set-AzStorageAccount -ResourceGroupName $storeRG -Name $storeName -AssignIdentity
$storageAccount = Get-AzStorageAccount -ResourceGroupName $storeRG -AccountName $storeName
#Add storage account principal to Key Vault Access Policy
Set-AzKeyVaultAccessPolicy -VaultName $keyVaultName -ObjectId $storageAccount.Identity.PrincipalId  -PermissionsToKeys wrapkey,unwrapkey,get
#Set storage account with BYOK encryption
$keyVaultObj = Get-AzKeyVault -VaultName $keyVaultName
Set-AzStorageAccount -ResourceGroupName $storeRG -AccountName $storeName -KeyvaultEncryption -KeyName $keyVaultKeyName -KeyVersion $StorageAccountKeyVaultKey.Version -KeyVaultUri $keyVaultObj.VaultUri