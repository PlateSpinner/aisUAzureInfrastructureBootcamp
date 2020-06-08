Configuration TZFWJUMP
{
    Import-DscResource -ModuleName 'PSDesiredStateConfiguration'
    Import-DscResource -ModuleName 'NetworkingDsc'    
    Import-DSCResource -ModuleName 'ComputerManagementDsc'    
    Import-DscResource -ModuleName 'PackageManagement' -ModuleVersion 1.4.5

    Node 'localhost' {
        # Install PowerShell Az Module
        PackageManagementSource SourceRepository
        {
            Ensure      = "Present"
            Name        = "MyNuget"
            ProviderName= "Nuget"
            SourceLocation   = "http://nuget.org/api/v2/"
            InstallationPolicy ="Trusted"
        }    
        PackageManagementSource PSGallery
        {
            Ensure      = "Present"
            Name        = "psgallery"
            ProviderName= "PowerShellGet"
            SourceLocation   = "https://www.powershellgallery.com/api/v2"
            InstallationPolicy ="Trusted"
        }
        PackageManagement PsAzAccountModule
        {
            Ensure    = "Present"
            Name      = "Az.Accounts"
            Source    = "PSGallery"
            DependsOn = "[PackageManagementSource]PSGallery"
        }
        PackageManagement PsAzAutoModule
        {
            Ensure    = "Present"
            Name      = "Az.Automation"
            Source    = "PSGallery"
            DependsOn = "[PackageManagementSource]PSGallery"
        }
        PackageManagement PsAzComputeModule
        {
            Ensure    = "Present"
            Name      = "Az.Compute"
            Source    = "PSGallery"
            DependsOn = "[PackageManagementSource]PSGallery"
        }
        PackageManagement PsAzKeyVaultModule
        {
            Ensure    = "Present"
            Name      = "Az.KeyVault"
            Source    = "PSGallery"
            DependsOn = "[PackageManagementSource]PSGallery"
        }   
        PackageManagement PsAzNetworkModule
        {
            Ensure    = "Present"
            Name      = "Az.Network"
            Source    = "PSGallery"
            DependsOn = "[PackageManagementSource]PSGallery"
        }
        PackageManagement PsAzResourceModule
        {
            Ensure    = "Present"
            Name      = "Az.Resources"
            Source    = "PSGallery"
            DependsOn = "[PackageManagementSource]PSGallery"
        }
        PackageManagement PsAzStorageModule
        {
            Ensure    = "Present"
            Name      = "Az.Storage"
            Source    = "PSGallery"
            DependsOn = "[PackageManagementSource]PSGallery"
        }
        # Change time zone
        TimeZone EasternTime
        {
            IsSingleInstance = 'Yes'
            TimeZone         = 'Eastern Standard Time'
        }
        # Disable Firewall Profiles
        FirewallProfile FirewallProfileDomain
        {
            Name = 'Domain'
            Enabled = 'False'
        }
        FirewallProfile FirewallProfilePrivate
        {
            Name = 'Private'
            Enabled = 'False'
        }
        FirewallProfile FirewallProfilePublic
        {
            Name = 'Public'
            Enabled = 'False'
        }
        # Install Windows Roles & Features
        WindowsFeature DOTNET {
            Ensure = "Present"
            Name = "NET-Framework-Core" 
        }
        WindowsFeature GPManagementTools
        {
            Ensure = "Present"
            Name = "GPMC"            
        }
        WindowsFeature ADManagementTools
        {
            Ensure = "Present"
            Name = "RSAT-AD-Tools"
            IncludeAllSubFeature = $true
        }
        WindowsFeature CSManagementTools
        {
            Ensure = "Present"
            Name = "RSAT-ADCS"
            IncludeAllSubFeature = $true
        }
        WindowsFeature RDS
        {
            Ensure = "Present"
            Name = "Remote-Desktop-Services"
        }        
        WindowsFeature RDCB
        {
            Ensure = "Present"
            Name = "RDS-Connection-Broker"
        }                
        WindowsFeature RDServer
        {
            Ensure = "Present"
            Name = "RDS-RD-Server"
        }                        
        WindowsFeature RDW
        {
            Ensure = "Present"
            Name = "RDS-Web-Access"
        }         
        WindowsFeature RDG
        {
            Ensure = "Present"
            Name = "RDS-Gateway"
        } 
        WindowsFeature RDSManagementTools
        {
            Ensure = "Present"
            Name = "RSAT-RDS-Tools"
        }
        WindowsFeature RDLManagementTools
        {
            Ensure = "Present"
            Name = "RSAT-RDS-Licensing-Diagnosis-UI"   
        }
        WindowsFeature RDGManagementTools
        {
            Ensure = "Present"
            Name = "RSAT-RDS-Gateway"            
        }
        WindowsFeature DNSManagementTools
        {
            Ensure = "Present"
            Name = "RSAT-DNS-Server"            
        }
        WindowsFeature IISManagementTools
        {
            Ensure = "Present"
            Name = "Web-Mgmt-Tools"
            IncludeAllSubFeature = $true           
        }
    }
}