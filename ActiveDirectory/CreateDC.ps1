#Requires -Modules VMware.PowerCLI
<#
.SYNOPSIS
    Creates a Domain Controller from existing ESXi Windows VM.
.DESCRIPTION
    Invokes the necessary commands to provision a Windows VM in VMware ESXi or vSphere, into a domain controller.
.NOTES
    Invoke-VMScript from VMware.PowerCLI module is not fully supported on PowerShell Core / PowerShell version 7
    Upon Install of AD Forest, error is thrown: "A general system error occurred: vix error codes", but the AD forest seems to install successfully.
.EXAMPLE
    Test-MyTestFunction -Verbose
    Explanation of the function or its result. You can include multiple examples with additional .EXAMPLE lines
#>
[CmdletBinding()]
param (
    [Parameter()]
    [VirtualMachine]
    $VM,

    [Parameter()]
    [PSCredential]
    $GuestCredential,
    
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
    $SafeModeAdministratorPassword

)


# set ip address, netmask, gateway, dns server
$Phase1Text = @"

    New-NetIPAddress -InterfaceAlias "Ethernet0" -IPAddress $IPAddress -PrefixLength $SubnetLength -DefaultGateway $DefaultGateway
    Set-DnsClientServerAddress -InterfaceAlias "Ethernet0" -ServerAddresses $IPAddress

    Get-Disk -Number 1 | Initialize-Disk -PartitionStyle GPT -PassThru | New-Volume -FileSystem NTFS -DriveLetter E -FriendlyName 'NTDS'
    Get-Disk -Number 2 | Initialize-Disk -PartitionStyle GPT -PassThru | New-Volume -FileSystem NTFS -DriveLetter F -FriendlyName 'LOGS'

    Rename-Computer -NewName DC

"@


Invoke-VMScript -VM $VM -GuestCredential $GuestCredential -ScriptType Powershell -ScriptText $Phase1Text

Restart-VMGuest -VM $VM

$parvar = '$params'
$truevar = '$true'
$falsevar = '$false'

$Phase2Text = @"

    Add-WindowsFeature AD-Domain-Services

    $parvar = @{
        CreateDnsDelegation = $falsevar
        DatabasePath = "E:\NTDS"
        DomainName = "$DomainName"
        DomainNetbiosName = "$NetBiosName"
        InstallDns = $truevar
        LogPath = "F:\LOGS"
        SysvolPath = "C:\Windows\SYSVOL"
        SafeModeAdministratorPassword = ('$SafeModeAdministratorPassword' | ConvertTo-SecureString -AsPlainText -Force)
        Confirm = $falsevar
        NoRebootOnCompletion = $truevar
    }

    Install-ADDSForest @params

"@

Invoke-VMScript -VM $VM -GuestCredential $GuestCredential -ScriptType Powershell -ScriptText $Phase2Text

Restart-VMGuest -VM $VM