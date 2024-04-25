## Steps for Bastion VM host Setup

- [ ] [Base OS Requirements](#base-os-equirements)
- [ ] [Tools](#tools)
- [ ] [Download Checks](#download-checks)
- [ ] [Create Deployment User](#Create-eployment-User)
</br>

---------------------

## <b> Base OS Requirements </b>


- RHEL 7-9 OS
- 4vCPU 8GB RAM 30GB Disk space free
- root or sudo acces account
- SELINUX permisive or disabled
- Network 
    - Routable to internet for downloads
    - Able to communicate to VLAN/Network host workload nodes
    - vCenter Access via SSH /https

</br>


---------------------

## <b> Create Deployment User </b>


Create user used to compile bootstrap files and also have key related to name of OCP instance to allow clear deliniation

```

useradd core
usermod -aG wheel core
su - core
id
```

Validate your in wheel:  Ex: "gid=1003(core) groups=1003(core),10(wheel)"


Generate ECDSA Key 

```
ssh-keygen -t ecdsa

```

We also expect you will deploy several clusters.  A such we try to keep it simple and use shell variable to call and work with clusters. This is just a simple shell variable. Ex:  ocpdev

```
cluster=ocpdev

```

</br>

---------------------

## <b> Tools </b>

Required:
- ssh
- ssh-keygen
- bind-utils
- sudo
- git
- curl
- tcpdump

Recommended:
- openldap-clients
- tmux
- nmap

```
sudo yum install bind-utils git curl tcpdump openldap-clients tmux nmap 
```

</br>

---------------------

## <b> Download Checks </b>

Check downloads and network access to different systems


Download files from redhat

```
[root@ocpbastion ~]# curl -I https://access.redhat.com/downloads
HTTP/2 200
server: Apache/2.4.37 (Red Hat Enterprise Linux) OpenSSL/1.1.1k
content-language: en
x-frame-options: SAMEORIGIN
x-content-type-options: nosniff
x-ua-compatible: IE=edge
link: <https://access.redhat.com/downloads>; rel="canonical",<https://access.redhat.com/node/468693>; rel="shortlink"
x-myvhost: executed
access-control-allow-origin: *.redhat.com
x-isphp: executed
content-type: text/html; charset=utf-8
cache-control: no-cache, must-revalidate
expires: Mon, 12 Jun 2023 12:15:11 GMT
date: Mon, 12 Jun 2023 12:15:11 GMT
x-rh-edge-request-id: 2a127cb8
x-rh-edge-reference-id: 0.cc386368.1686572111.2a127cb8
x-rh-edge-cache-status: Hit from child

[root@ocpbastion ~]#
```
Simple download web certificate from vcenter to bastion. Shows communiction from bastion to vcenter API

```
wget https://vcenter01.acme.local/certs/download.zip --no-check-certificate
mv download.zip vcenter01_vCenter_cert.zip

```

check time sync from local ntp

```
[root@ocpbastion ~]# timedatectl
               Local time: Mon 2023-06-12 08:13:14 EDT
           Universal time: Mon 2023-06-12 12:13:14 UTC
                 RTC time: Mon 2023-06-12 12:13:14
                Time zone: America/New_York (EDT, -0400)
System clock synchronized: yes
              NTP service: active
          RTC in local TZ: no
[root@ocpbastion ~]#


```

Check DNS Cluster Records Options.  Ex: VIP should respond back IP if DNS is setup correct

```
> ^C[root@ocpbastion ~]# nslookup test.apps.ocpprod.acme.local
Server:         172.16.103.241
Address:        10.10.11.32#53

Name:   test.apps.ocpprod.acme.local
Address: 10.10.11.32

[root@ocpbastion ~]#

```
*Test the other A and PTR records from requirements checklist

Check DHCP lease Options  ## Meh.. workong on this test :) ##

```


```

-----

