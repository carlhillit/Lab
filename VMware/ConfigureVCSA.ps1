#region variables & connection

$vCenter = 'vcsa.breakdown.lab'

$vcsaPassword = Read-Host -Prompt 'Enter the vSphere admin password' -AsSecureString
$vcsaCreds = New-Object System.Management.Automation.PSCredential ('administrator@vsphere.local', $vcsaPassword)

#esxi hosts
$esxiPassword = Read-Host -Prompt 'Enter the ESXi root password' -AsSecureString
$esxiCreds = New-Object System.Management.Automation.PSCredential ('root', $esxiPassword)

$esxiHosts = @(
    'nuc1.breakdown.lab'
    'nuc2.breakdown.lab'
    'nuc3.breakdown.lab'
)

Connect-VIServer -Server $vCenter -Credential $vcsaCreds -Force

$VMHosts = Get-VMHost

#endregion variables & connection

#region Datacenter
# New datacenter
$dataCenterName = 'HomeLab'
New-Datacenter -Name $dataCenterName -Location (Get-Folder -Name Datacenters)
$dataCenter = Get-Datacenter -Name $dataCenterName

#endregion Datacenter

#region Cluster

# New-Cluster
$clusterName = 'NUCs'
$clusterParams = @{
    #AcceptEULA = $true #not listed in documentation
    Name = $clusterName
    Location = $dataCenterName
    HAEnabled = $true
    HAIsolationResponse = 'PowerOff'
    DrsEnabled = $true
    DrsAutomationLevel = 'FullyAutomated'
}

New-Cluster @clusterParams 

$cluster = Get-Cluster

# add hosts to cluster
$esxiHosts | ForEach-Object {
    Add-VMHost -Name $_ -Location $cluster -Credential $esxiCreds -Force # force required for self-signed certs
}

#endregion Cluster



# create virtual distributed switch
$vMotionVdsName = 'VDS-vMotion'
New-VDSwitch -Location $dataCenter -Name $vMotionVdsName
$vmotionVDS = Get-VDSwitch -Name $vMotionVdsName

# create port group
$vMotionVpgName = 'PG-vMotion'
$vMotionVpgVlanID = 100
New-VDPortgroup -VDSwitch $vmotionVDS -Name $vMotionVpgName -VlanId $vMotionVpgVlanID
$vMotionVpg = Get-VDPortgroup -Name $vMotionVpgName

# add hosts to switch
$vmotionVDS | Add-VDSwitchVMHost -VMHost $VMHosts.Name # for some reason, $vmhosts.name works while $vmhosts does not

#add physical adapter
$vmhostNetworkAdapterName = 'vusb0'
$vmhostNetworkAdapter = $VMHosts | Get-VMHostNetworkAdapter -Physical -Name $vmhostNetworkAdapterName 
$vmotionVDS | Add-VDSwitchPhysicalNetworkAdapter -VMHostNetworkAdapter $vmhostNetworkAdapter -Confirm:$false

# add vmnics for vmotion
$csv = Import-Csv -Path /Users/karl/Lab/VMware/vmotionadapters.csv

foreach ($adapter in $csv) {

    $splat = @{
        PortGroup = $adapter.PortGroup
        VirtualSwitch = $adapter.VDS
        IP = $adapter.IPaddress
        SubnetMask = $adapter.SubnetMask
        VMotionEnabled = $true
    }

    Get-VMHost $adapter.Host | New-VMHostNetworkAdapter @splat

}

