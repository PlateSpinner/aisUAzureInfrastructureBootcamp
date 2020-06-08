Workflow StopStartVM
{ 
    Param 
    (    
        [Parameter(Mandatory=$true)][ValidateSet("Start","Stop")] 
        [String] 
        $Action,    
        [Parameter(Mandatory=$true)][ValidateSet("All","Inclusion","Exclusion")] 
        [String] 
        $vmSelectionMode,    
        [Parameter(Mandatory=$false)]
        [String] 
        $vmSelection
    )   
    #Connect to Azure
    $servicePrincipalConnection=Get-AutomationConnection -Name "AzureRunAsConnection"
    "Logging in to Azure..."
    Add-AzAccount -ServicePrincipal -TenantId $servicePrincipalConnection.TenantId -ApplicationId $servicePrincipalConnection.ApplicationId -CertificateThumbprint $servicePrincipalConnection.CertificateThumbprint
    #Turn VM selection into array
    if($vmSelection){
        $vmArray = $vmSelection.Replace(" ","").Split(",")
    }
    #Get VMs
    switch -CaseSensitive ($vmSelectionMode) {
        "All" {$vmObjectArray = Get-AzVM}
        "Inclusion" {$vmObjectArray = Get-AzVM | Where-Object {$vmArray -contains $_.Name}}
        "Exclusion" {$vmObjectArray = Get-AzVM | Where-Object {$vmArray -notcontains $_.Name}}
    }
    #VM Action
    Write-Output ("`r`n" + $Action + " " + [string](@($vmObjectArray).Count) + " VMs...`r`n")
    $actionOutput = foreach -parallel ($AzVM in $vmObjectArray) 
    {         
        if($Action -eq "Stop"){$VMAction = $AzVM | Stop-AzVM -Force}
        else{$VMAction = $AzVM | Start-AzVM}
        $OutputObject = New-Object -TypeName PSObject -Property @{"ResourceGroup"=$AzVM.ResourceGroupName;"VM"=$AzVM.Name;"Action"=$Action;"Status"=$VMAction.Status}                    
        $OutputObject | Select-Object ResourceGroup, VM, Action, Status
    }                    
    $outputDisplay = $actionOutput | Select-Object ResourceGroup, VM, Action, Status
    $outputDisplay
}