#Requires -Modules VMware.PowerCLI
<#
.SYNOPSIS
    Creates a Domain Controller from existing ESXi Windows VM.
.DESCRIPTION
    Invokes the necessary commands to provision a Windows VM in VMware ESXi or vSphere, into a domain controller.
.NOTES
    Invoke-VMScript from VMware.PowerCLI module is not fully supported on PowerShell Core / PowerShell version 7
    Upon Install of AD Forest, error is thrown: "A general system error occurred: vix error codes", but the AD forest seems to install successfully.
    Must be connect to vSphere server or ESXi host.
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
    [PSCredential]
    $DomainCredential,
    
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
    $DomainName,

    [Parameter()]
    [string]
    $NewName,

    [Parameter()]
    [string]
    $OUPath

)

# set ip address, netmask, gateway, dns server
$configure = @"

    New-NetIPAddress -InterfaceAlias "Ethernet0" -IPAddress $IPAddress -PrefixLength $SubnetLength -DefaultGateway $DefaultGateway
    Set-DnsClientServerAddress -InterfaceAlias "Ethernet0" -ServerAddresses $IPAddress

    Get-Disk -Number 1 | Initialize-Disk -PartitionStyle GPT -PassThru | New-Volume -FileSystem NTFS -DriveLetter E -FriendlyName 'DATA'

"@


Invoke-VMScript -VM $VM -GuestCredential $GuestCredential -ScriptType Powershell -ScriptText $configure

# rename & join to domain
Add-Computer -ComputerName $IPAddress -DomainName $DomainName -NewName $NewName -OUPath $OUPath -Credential $DomainCredential -Restart:$false

# final reboot
Restart-VMGuest -VM $VM

