#Requires -Modules VMware.PowerCLI
<#
.SYNOPSIS
    Creates a Domain Controller from existing ESXi Windows VM.
.DESCRIPTION
    Invokes the necessary commands to provision a Windows VM in VMware ESXi or vSphere, into a domain controller.
.NOTES
    Information or caveats about the function e.g. 'This function is not supported in Linux'
.EXAMPLE
    Test-MyTestFunction -Verbose
    Explanation of the function or its result. You can include multiple examples with additional .EXAMPLE lines
#>
[CmdletBinding()]
param (
    [Parameter()]
    [string]
    $VM,
    
    [Parameter()]
    [string]
    $IPAddress,

    [Parameter()]
    [string]
    $DefaultGateway,

    [Parameter()]
    [ValidateRange(1,34)]
    [Int32]
    $SubnetLength,

    [Parameter()]
    [string]
    $DomainName = "karl.lab",

    [Parameter()]
    [string]
    $NetBiosName = "KARL",

    [Parameter()]
    [securestring]
    $AdminPass

)


Invoke-VMScript -VM $VM -ScriptText {

    # set ip address, netmask, gateway, dns server
    New-NetIPAddress -InterfaceIndex 2 -IPAddress $using:IPAddress -PrefixLength $using:SubnetLength -DefaultGateway $using:DefaultGateway
    Set-DnsClientServerAddress -InterfaceIndex 2 -ServerAddresses $using:IPAddress

    # add & foramt disks
    Get-Disk -Number 1 | Initialize-Disk -PartitionStyle GPT -PassThru | New-Volume -FileSystem NTFS -DriveLetter E -FriendlyName 'NTDS'

    Get-Disk -Number 2 | Initialize-Disk -PartitionStyle GPT -PassThru | New-Volume -FileSystem Logs -DriveLetter F -FriendlyName 'LOGS'


    #initial server config
    Rename-Computer -NewName DC -Restart:$false

}

Get-VM $VM | Restart-VMGuest

Invoke-VMScript -VM $VM -ScriptText {
    # install AD domain services
    Add-WindowsFeature AD-Domain-Services


    # add forest and make domain controller

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

}