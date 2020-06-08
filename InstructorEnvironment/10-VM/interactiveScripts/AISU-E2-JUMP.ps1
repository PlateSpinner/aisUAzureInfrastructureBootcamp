#Configure RDG
Import-Module RemoteDesktopServices
New-Item -Path RDS:\GatewayServer\RAP -Name "RDG Computers" -UserGroups "RDGW Users@ad.aisu.cloud" -ComputerGroupType 2
New-Item -Path RDS:\GatewayServer\CAP -Name "RDG Users" -UserGroups "RDGW Users@ad.aisu.cloud" -AuthMethod 1