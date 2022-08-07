# Switching
TP-Link 16 port managed

* Port 1 trunk port (uplink)

| Network | VLAN ID |
|---|---|
| VM Network | 10 |
| vSAN | 80 |
| ESXi Management | 90 |
| vMotion | 100 |



# Routing

Install OPNsense

Configure VLANs
Configure interfaces
Config DHCP
config DNS

For faster boot, set System > Settings > Administration:
Primary Console: Serial Console
Secondary Console: 


# VM Hosts

## Install ESXi

Download ESXi iso, image USB w/ rufus
Add ks.cfg to usb

Install



## HA

Configure HA > advanced

> das.ignoreRedundantNetWarning    true

Right-click each host "Reconfigure for vSphere HA"





# Creating Repos

| System | Link | Description | Notes | 
|---|---|---|---|
| VMware ESXi | | for VMware Lifecycle Manger | can be HTTP |
| VMware vCenter | | VAMI | must be HTTPS |
| Rocky Linux | | downloaded via reposync | downloaded from internet connected NAS |
| OPNsense | rsync://mirror.ams1.nl.leaseweb.net/opnsense/FreeBSD:13:amd64/22.1 |

## Create Repo VM

Install Rocky Linux 8.5 (repo vm)

add disk
partition
format
add to /etc/fstab
mount

rsync/scp from usb to repo vm

mkdir /repo
chmod 2775 /repo

````
[appstream]
name=Rocky Linux $releasever - AppStream
#mirrorlist=https://mirrors.rockylinux.org/mirrorlist?arch=$basearch&repo=AppStream-$releasever
#baseurl=http://dl.rockylinux.org/$contentdir/$releasever/AppStream/$basearch/os/
baseurl=file:///repo/$contentdir/$releasever/AppStream/$basearch/os/
gpgcheck=1
enabled=1
countme=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-rockyofficial

````

### Install nginx

    dnf install -y nginx
    systemctl enable --now nginx

#### firewall

firewall-cmd --permanent --add-service={http,https}
firewall-cmd --reload

#### selinux

setsebool -P httpd_read_user_content 1

chcon -Rt httpd_sys_content_t /repo


configure nginx

    vim /etc/nginx/nginx.conf

````
 server {
        listen       80 default_server;
        listen       [::]:80 default_server;
        server_name  _;
        root         /repo;

        # Load configuration files for the default server block.
        include /etc/nginx/default.d/*.conf;

        location / {
		autoindex on;
        }

        error_page 404 /404.html;
            location = /40x.html {
        }

        error_page 500 502 503 504 /50x.html;
            location = /50x.html {
        }
    }
````


## Configure Repos

````
[appstream]
name=Rocky Linux $releasever - AppStream
#mirrorlist=https://mirrors.rockylinux.org/mirrorlist?arch=$basearch&repo=AppStream-$releasever
#baseurl=http://dl.rockylinux.org/$contentdir/$releasever/AppStream/$basearch/os/
baseurl=http://repo.breakdown.lab/$contentdir/$releasever/AppStream/$basearch/os/
gpgcheck=1
enabled=1
countme=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-rockyofficial

````

# Syslog VM

mkdir /logs
partition
format
fstab

systemctl status rsyslog.service


vi /etc/rsyslog.conf

uncomment:
module(load="imudp") # needs to be done just once
input(type="imudp" port="514")

module(load="imtcp") # needs to be done just once
input(type="imtcp" port="514")

global(workDirectory="/logs")


systemctl restart rsyslog.service

firewall-cmd --permanent --add-port={514/tcp,514/udp}
firewall-cmd --reload


chmod u+rwx /logs
semanage fcontext -a -t syslogd_var_lib_t /logs
restorecon -R -v /logs

vim /etc/rsyslog.d/01-server.conf

$template server, "/logs/%HOSTNAME%/%SYSLOGFACILITY-TEXT%.log"
*.* ?server


## vCenter
vami > syslog

syslog.breakdown.lab TCP 514

## host profile
extract host profile

syslog
Syslog.global.LogHost

coredump
VMkernel.Boot.allowCoreDumpOnUsb    true

network configuration > network coredump settings
check
nic: vmk0
ip: 192.168.10.10
port: 6500

enable service in vami





## OPNsense

system > settings > logging/targets
add destination:
Enabled (checked)
Transport: TCP(4)
Hostname: syslog.breakdown.lab
Port: 514
Save
Apply





# VMware Updates
vsan hcl db
http://partnerweb.vmware.com/service/vsan/all.json.gz

vsan release catalog
https://kb.vmware.com/s/article/58891


Download from internet via UMDS

Set Lifecycle Manager > Patch Setup
New source
http://repo.breakdown.lab/vmware/esxi/hostupdate/__hostupdate20-consolidated-index__.xml

