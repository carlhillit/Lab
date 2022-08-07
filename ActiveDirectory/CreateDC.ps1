

# set ip address, netmask, gateway, dns server
New-NetIPAddress -InterfaceIndex 2 -IPAddress 10.10.10.10 -PrefixLength 24 -DefaultGateway 10.10.10.1
Set-DnsClientServerAddress -InterfaceIndex 2 -ServerAddresses 10.10.10.10

# add & foramt disks
Get-Disk -Number 1 |
    Initialize-Disk -PartitionStyle GPT -PassThru |
        New-Volume -FileSystem NTFS -DriveLetter E -FriendlyName 'NTDS'

Get-Disk -Number 2 |
Initialize-Disk -PartitionStyle GPT -PassThru |
    New-Volume -FileSystem Logs -DriveLetter F -FriendlyName 'LOGS'
    

#initial server config
Rename-Computer -NewName DC -Restart:$false


Restart-Computer


# install AD domain services
Add-WindowsFeature AD-Domain-Services


# add forest and make domain controller
$DomainName = "karl.lab"
$NetBiosName = "KARL"
$adminpass =  Read-Host -AsSecureString

$ADDSparams = @{
    CreateDnsDelegation = $false
    DatabasePath  = "E:\NTDS"
    DomainMode = "WinThreshold"
    DomainName = $DomainName
    DomainNetbiosName = $NetBiosName
    ForestMode = "WinThreshold"
    InstallDns = $true
    LogPath = "F:\LOGS"
    NoRebootOnCompletion = $false
    SysvolPath = "C:\Windows\SYSVOL"
    SafeModeAdministratorPassword = $adminpass
    Force = $true
}

Install-ADDSForest @ADDSparams
