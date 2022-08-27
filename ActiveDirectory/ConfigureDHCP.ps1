# placeholder


[CmdletBinding()]
param (
    [Parameter()]
    [string]
    $ComputerName


)

    Add-WindowsFeature DCHP




    # security groups
    netsh dhcp add securitygroups

    Restart-Service dhcpserver

    #authorize dhcp in AD
    Add-DhcpServerInDC -DnsName $env:fqdn -IPAddress $localIPaddress

    # configure dynamic dns updates
    Set-DhcpServerv4DnsSetting -ComputerName "DHCP1.corp.contoso.com" -DynamicUpdates "Always" -DeleteDnsRRonLeaseExpiry $True

    # add scopes

    Add-DhcpServerv4Scope -name "Corpnet" -StartRange 10.0.0.1 -EndRange 10.0.0.254 -SubnetMask 255.255.255.0 -State Active
Add-DhcpServerv4ExclusionRange -ScopeID 10.0.0.0 -StartRange 10.0.0.1 -EndRange 10.0.0.15
Set-DhcpServerv4OptionValue -OptionID 3 -Value 10.0.0.1 -ScopeID 10.0.0.0 -ComputerName DHCP1.corp.contoso.com
Set-DhcpServerv4OptionValue -DnsDomain corp.contoso.com -DnsServer 10.0.0.2