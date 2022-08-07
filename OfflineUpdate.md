# Concepts

Online Server get updates
Export updates to USB HDD
Connect USB HDD to offline network
Import updates to appropriate servers


# Windows

## Sync with WSUS

Sync online WSUS

robocopy data

export metadata

## Import Updates to WSUS

## WSUSoffline

now community edition

# Linux

## RHEL / Rocky


## Ubuntu



# Routers

## pfSense

pfSense does not support a custom repository repo or any other way to upgrade from an isolated network.
Upgrades are performed by backing up the configuration, installing a new version, and importing the config.

/usr/local/share/pfsense/pkg/repos/pfsense-repo.conf

## OPNsense

go to website to find mirror

leaseweb has rysnc mirrors near you

rsync the repo to local disk 

*NTFS does not support symlinks and colons (:) in file paths, so recommend syncing via *nix/MacOS or WSL, then tar*

tar the dir

upload and untar to repo webserver

add to opnsense repo location

check for updates


# VMware vSphere

## vCenter

Download .zip file for vCenter

## ESXi

### UMDS

### Import .zip to vCenter & export form local path



