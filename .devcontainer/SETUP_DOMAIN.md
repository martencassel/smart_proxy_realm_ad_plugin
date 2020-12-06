# Setup domain controllers

## Install virtual machines

```bash
sudo virt-install --name=dc01 --ram=8096 \
  --cpu=host --vcpus=4 \
  --os-type=windows --os-variant=win2k19 \
  --cdrom ~/Downloads/en_windows_server_2019_updated_nov_2020_x64_dvd_8600b05f.iso \
  --network default
```

```bash
sudo virt-install --name=dc02 --ram=4096 \
  --cpu=host --vcpus=2 \
  --os-type=windows --os-variant=win2k19 \
  --cdrom ~/Downloads/en_windows_server_2019_updated_nov_2020_x64_dvd_8600b05f.iso \
  --network default
```

## Set computer names

```powershell
dc01 > Rename-Computer dc01 -Force
dc02 > Rename-Computer dc02 -Force
```

## Disable the local firewall

```powershell
Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled False
```
## Update Windows

```powershell
Install-Module PSWindowsUpdate -Force
Install-WindowsUpdate -ForceDownload
```

## Install OpenSSH

```powershell
Add-WindowsCapability -Online -Name OpenSSH.Client~~~~0.0.1.0
Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0
Start-Service sshd
Set-Service -Name sshd -StartupType 'Automatic'
New-NetFirewallRule -Name sshd -DisplayName 'OpenSSH Server (sshd)' -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 22
```

## Update /etc/hosts on the linux host

```bash
$ cat /etc/hosts
dc01 192.168.122.X
dc02 192.168.122.Y
```

## Login with SSH
```bash
ssh Administrator@192.168.122.209
> powershell.exe
```

## Install the first domain controller for example.com

```powershell
Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled False

Install-WindowsFeature -name AD-Domain-Services -IncludeManagementTools
Install-ADDSForest -DomainName "example.com" -InstallDNS

# Add the second server to the domain
Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled False

$key = "HKLM:\SOFTWARE\Microsoft\PowerShell\1\ShellIds"
Set-ItemProperty $key ConsolePrompting True

$IfIndex = Get-NetAdapter|Select ifIndex -ExpandProperty IfIndex
Set-DnsClientServerAddress -InterfaceIndex $IfIndex -ServerAddresses ("192.168.122.208")

$Cred = Get-Credential "example\Administrator"
Add-Computer -DomainName example.com -DomainCredential $Cred

# Login from the dc01 to dc02
dc01 > Enter-PSSession dc02

# Install the second domain controller
$key = "HKLM:\SOFTWARE\Microsoft\PowerShell\1\ShellIds"
Set-ItemProperty $key ConsolePrompting True

Install-WindowsFeature AD-Domain-Services -IncludeManagementTools
$Cred = Get-Credential "example\Administrator"

Install-ADDSDomainController -DomainName "example.com" -InstallDns -Credential $Cred

Restart-Computer -Force
```

## Configure Domain discovery for the linux host
```bash
sudo systemctl stop systemd-resolved
sudo systemctl disable systemd-resolved
```

$ cat /etc/resolv.conf
domain example.com
search example.com
nameserver 192.168.122.209
nameserver 8.8.8.8

## Domain discovery

```bash
dnf -y install adcli
adcli info --domain example.com -v
```
  
## Start dev container

```bash
docker build -f Dockerfile-foreman-proxy.c7 -t smart-proxy-c7:stable .
docker container rm -f smart-proxy
docker run --name=smart-proxy -d -p 3000:3000 smart-proxy-c7:stable
```

## Create keytab file 

```bash
docker exec -it smart-proxy /bin/bash
> ktutil
ktutil: addent -password -p Administrator@EXAMPLE.COM -k 1 -e RC4-HMAC
Password for Administrator@EXAMPLE.COM: ******
ktutil: wkt realm_ad.keytab
ktutil: quit
cp realm_ad.keytab  /etc/foreman-proxy/realm_ad.keytab

# Login using the keytab file
kinit Administrator@EXAMPLE.COM -k -t /etc/foreman-proxy/realm_ad.keytab
klist
kdestroy
```
