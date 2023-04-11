$RsatTools = @(
    "Rsat.ActiveDirectory.DS-LDS.Tools"
#    "Rsat.AzureStack.HCI.Management.Tools"
    "Rsat.BitLocker.Recovery.Tools"
    "Rsat.CertificateServices.Tools"
#    "Rsat.DHCP.Tools"
    "Rsat.Dns.Tools"
    "Rsat.FailoverCluster.Management.Tools"
    "Rsat.FileServices.Tools"
    "Rsat.GroupPolicy.Management.Tools"
#    "Rsat.IPAM.Client.Tools"
#    "Rsat.LLDP.Tools"
#    "Rsat.NetworkController.Tools"
#    "Rsat.NetworkLoadBalancing.Tools                                                                                                                                                                                               Rsat.RemoteAccess.Management.Tools~~~~0.0.1.0                                                                                                                                          State : NotPresent                                                                                                                                                                                                                                                                                                                                                                            Rsat.RemoteDesktop.Services.Tools~~~~0.0.1.0                                                                                                                               "
    "Rsat.ServerManager.Tools"
    "Rsat.StorageMigrationService.Management.Tools"
    "Rsat.StorageReplica.Tools"
    "Rsat.SystemInsights.Management.Tools"
#    "Rsat.VolumeActivation.Tools"
    "Rsat.WSUS.Tools"
)

foreach ($tool in $RsatTools) {
    Get-WindowsCapability -Onine | Where-Object -Property Name -like "$tool*" | Add-WindowsCapability -Online 
}
