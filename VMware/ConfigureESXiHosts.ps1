$esxiHosts = @(
    'host1.breakdown.lab'
    'host2.breakdown.lab'
    'host3.breakdown.lab'
)

$esxiPassword = 'VMware1!' | ConvertTo-SecureString -AsPlainText -Force
$esxiCreds = New-Object System.Management.Automation.PSCredential ('root', $esxiPassword)


Connect-VIServer -Server $esxiHosts -Credential $esxiCreds -Force

$VMHosts = Get-VMHost


# set NTP server
$ntpServer = '192.168.1.1'
Add-VMHostNtpServer -VMHost $VMHosts -NtpServer $ntpServer


# enable Services
$enabledServices = @(
    'ntpd'
    'TSM-SSH'
)

$enabledServices | ForEach-Object {
    Get-VMHostService -VMHost $VMHosts | Where-Object -Property Key -eq $_ | Start-VMHostService # start service
    Get-VMHostService -VMHost $VMHosts | Where-Object -Property Key -eq $_ | Set-VMHostService -Policy On # enable service to start upon boot
}

# mount NAS NFS datastore
$nfsServer = '192.168.178.30'
$nfsShare = '/vmware'

$VMHosts | ForEach-Object {
    New-Datastore -VMHost $_ -Name NAS -Nfs -NfsHost $nfsServer -Path $nfsShare -FileSystemVersion 4.1
}


# set vm network port group
$VPG = 'HLVM'
$vlan = 10

Get-VirtualSwitch -VMHost $VMHosts | New-VirtualPortGroup -Name $VPG -VLanId $vlan



Disconnect-VIServer -Confirm:$false

