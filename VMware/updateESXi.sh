#! /bin/bash

# if the system is connected to the internet, it will find the latest version of ESXi and upgrade to it

# put system in mainenance mode
esxcli system maintenanceMode set --enable=true

# allow firewall acces
esxcli network firewall ruleset set --enable=true --ruleset-id=httpClient

# grab latest esxi version
newversion=$(esxcli software sources profile list --depot=https://hostupdate.vmware.com/software/VUM/PRODUCTION/main/vmw-depot-index.xml | grep standard | tail -1 | awk '{ print $1 }')

# perform update
esxcli software profile update --depot=https://hostupdate.vmware.com/software/VUM/PRODUCTION/main/vmw-depot-index.xml --profile=$newversion 

# set firewall back
esxcli network firewall ruleset set -enable=false --=ruleset-id=httpClient

# reboot
esxcli system shutdown reboot --reason="updated to $newversion"
