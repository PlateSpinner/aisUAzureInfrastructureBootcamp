Configuration IISTZFW
{
    Import-DscResource -ModuleName 'PSDesiredStateConfiguration'
    Import-DSCResource -ModuleName 'ComputerManagementDsc'
    Import-DscResource -ModuleName 'NetworkingDsc'

    Node 'localhost' {#Install IIS
        WindowsFeature IIS {
            Ensure = "Present"
            Name = "Web-Server"
        }
        WindowsFeature IISManagementTools
        {
            Ensure = "Present"
            Name = "Web-Mgmt-Tools"
            DependsOn='[WindowsFeature]IIS'
        }
        #Change time zone
        TimeZone EasternTime
        {
            IsSingleInstance = 'Yes'
            TimeZone         = 'Eastern Standard Time'
        }
        #Disable Firewall Profiles
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
    }
}