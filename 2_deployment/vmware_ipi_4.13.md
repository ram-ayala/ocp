# Basic deployment of cluster for NSPOF on VMWare via IPI process

## Documentation

<br>

## Steps for Deployment

- [ ] [Pre Deploy Notes](#Pre-Deploy-Notes)
- [ ] [vCenter Certificate](#vCenter-Certificate)
- [ ] [RedHat Pull Secret](#RedHat-Pull-Secret)
- [ ] [Deployment Configuration](#Deployment-Configuration)
- [ ] [Deployment](#Deployment)
- [ ] [Debug Notes](#Debug-Notes)
- [ ] [Destroy Notes](#Desroy-Notes)

</br>

------
## <span style="color:green"><b> Pre Deploy Notes</span></b>

<br>

- Most deployment issues relate to DNS, time sync, and network issues (firewall, internet blocked, subnet masks wrong etc..)  Please double check these before you start deployment !!!

<br>

- We recommend and document by use of variables for cluster within shell to encourage to use this as most customers will have a minimum three clusters [prod, dev, UAT/DR] and unification of deployment process and post deployment configuration is very important to support enviroments

<br>

- Deploy often.  Build out and test with operations team the skills to have confort within the team on deployment of clusters, as well as repair , upgrade and debug.  Do NOT deploy once and treat it as a pet, k8 clusters are cattle and should be treated as ephemeral assets.

<br>

- Open a ticket if you can up front.  Build out and test workflow to open a support ticket. Work out and document process for multiple people supporting the cluster(s) within your organ. Do not wait for emergancy to figure this process out!

</br>

------
## <span style="color:green"><b> vCenter Certificate</span></b>

<br>
Add vCenter root CA certificate to bastion host trust.

Ex:  vcenter01.acme.local pull token down to ocpbastion host

From ocpbastion as user core in git folder for specific cluster.  Ex: /home/core/git/ocp_poc/acme.local/ocpdev

```

wget http://vcenter01.acme.local/certs/download.zip --no-check-certificate
mv download.zip vcenter01_vCenter_cert.zip
unzip vcenter01_vCenter_cert.zip
sudo cp certs/lin/* /etc/pki/ca-trust/source/anchors
sudo update-ca-trust extract

```

</br>

------
## <span style="color:green"><b> RedHat Pull Secret</span></b>

<br>
Download site from RedHat. You will need login for site


https://cloud.redhat.com/openshift/install/vsphere/user-provisioned

![Redhat Pull Secret](./.images/redhat_pull_secret.png)

Now key is in copy buffer so you can "right click and paste" when asked during below wizard

<br>
<br>




------
## <span style="color:green"><b> Deployment Configuration</span></b>

Run RedHat Configuration CLI Wizard.  Run this as user "core"

```
cd ~
cluster=ocpprod
cd ~/$cluster

# Download client
wget https://mirror.openshift.com/pub/openshift-v4/x86_64/clients/ocp/latest/openshift-client-linux.tar.gz
tar -zxvf openshift-client-linux.tar.gz
sudo mv oc  /usr/local/bin/

# Download latest version Openshift
wget https://mirror.openshift.com/pub/openshift-v4/x86_64/clients/ocp/latest/openshift-install-linux.tar.gz
tar -zxvf openshift-install-linux.tar.gz
./openshift-install create install-config  --log-level=debug

-----------
 # << Wizard for creation of installation yaml file>>
? SSH Public Key  [Use arrows to move, enter to select, type to filter, ? for more help]
> /home/core/.ssh/id_rsa.pub
  <none>
? Platform  [Use arrows to move, enter to select, type to filter, ? for more help]
  aws
  azure
  gcp
  openstack
  ovirt
? Platform vsphere
? vCenter vcenter01.acme.local
? Username openshift@vsphere.local
? Password [? for help] ********
INFO Connecting to vCenter vcenter01.acme.local
INFO Defaulting to only available datacenter: datacenter
? Cluster cluster
? Default Datastore vsanDatastore
? Network production_100
? Virtual IP Address for API 172.16.100.61
? Virtual IP Address for Ingress 172.16.100.71
DEBUG   Generating Base Domain...
? Base Domain acme.local
DEBUG   Fetching Cluster Name...
DEBUG     Fetching Base Domain...
DEBUG     Reusing previously-fetched Base Domain
DEBUG     Fetching Platform...
DEBUG     Reusing previously-fetched Platform
DEBUG   Generating Cluster Name...
? Cluster Name ocpprod
DEBUG   Fetching Networking...
DEBUG     Fetching Platform...
DEBUG     Reusing previously-fetched Platform
DEBUG   Generating Networking...
DEBUG   Fetching Pull Secret...
DEBUG   Generating Pull Secret...
? Pull Secret [? for help] ***************DEBUG   Fetching Platform...
DEBUG   Reusing previously-fetched Platform
DEBUG Generating Install Config...
INFO Install-Config created in: .
-----------
[core@ocpbastion ocpprod]$

```


<br>
Review YAML And Modify.  

Ex:  
1) Set more RAM and hardware specs for masters and workers
2) Increase worker nodes to accomodate ODF. Increase CPU / RAM and replica count on worker nodes
3) Add folder path within vmware to keep deployments clean
4) Add in resource pool path within vmware to keep deployments clean


```
vi install-config.yaml

----------------
additionalTrustBundlePolicy: Proxyonly
apiVersion: v1
baseDomain: acme.local
compute:
- architecture: amd64
  hyperthreading: Enabled
  name: worker
  platform:
    vsphere:
      cpus: 4
      coresPerSocket: 4
      memoryMB: 12288
      osDisk:
        diskSizeGB: 120
  replicas: 6
controlPlane:
  architecture: amd64
  hyperthreading: Enabled
  name: master
  platform:
    vsphere:
      cpus: 4
      coresPerSocket: 4
      memoryMB: 16384
      osDisk:
        diskSizeGB: 120
  replicas: 3
metadata:
  creationTimestamp: null
  name: ocpdev
networking:
  clusterNetwork:
  - cidr: 172.42.0.0/16
    hostPrefix: 23
  machineNetwork:
  - cidr: 10.89.135.0/24
  networkType: OVNKubernetes
  serviceNetwork:
  - 172.32.0.0/16
platform:
  vsphere:
    apiVIPs:
    - 10.89.135.125
    failureDomains:
    - name: generated-failure-domain
      region: generated-region
      server: ps-vcenter-02.acme.local
      topology:
        computeCluster: /dc1/host/cluster01
        datacenter: dc1
        datastore: /dc1/datastore/cluster01
        networks:
        - k8135
        resourcePool: /dc1/host/cluster01//Resources/Normal_VMs  # name of resource pool within vcenter
        folder: /dc1/vm/redhat/openshift/ocpdev
      zone: generated-zone
    ingressVIPs:
    - 10.89.135.126
    vcenters:
    - datacenters:
      - dc1
      password: MyPassword
      port: 443
      server: vcenter-01.acme.local
      user: ocp@vsphere.local
      folder: /dc1/vm/ocpdev  # Broken for new 4.13 version
publish: External
pullSecret: '{"auths":{"cloud.openshift.com":{"auth":"b3BlbnNoa1dKSw==","email":"helpdesk@acme.com"},"registry.connect.redhat.com":{"auth":"NTI3MTUWN6Q192Yw==","email":"helpdesk@acme.com"},"registry.redhat.io":{"auth":"NTI3MTUzOTeWN6Q192Yw==","email":"helpdesk@acme.com"}}}'
sshKey: |
  ecdsa-sha2-nistp256 AAAAE2VjZHsgo27ajYAkyJGv0EP7dMXGJCkvSJrhuyn815O+LHsCSMnjLTjzE0ZfSw7go1UsjIj2TlwzS0ThIXvdI= helpdesk@acme.com
----------------


```
Now make backup within local directory as Terraform removes this YAML file during deploy.

```
cp install-config.yaml "install-config_`date +%y%m%d%H%M%S`.yaml"

```

<br>

------
## <span style="color:green"><b> Deployment</span></b>

<br>

Run Deployment in tmux so you can reconnect or return shell to debug. This deployment takes 20-30 minutes.

```
tmux new -s ocpdev
./openshift-install create cluster --log-level=debug
```

Once deployment complete output will indicate login details as well as generated password.

Example successful Deployment.

```
...
DEBUG Still waiting for the cluster to initialize: Cluster operator authentication is not available 
DEBUG Still waiting for the cluster to initialize: Cluster operator authentication is not available 
DEBUG Cluster is initialized                       
INFO Checking to see if there is a route at openshift-console/console... 
DEBUG Route found in openshift-console namespace: console 
DEBUG OpenShift console route is admitted          
INFO Install complete!                            
INFO To access the cluster as the system:admin user when using 'oc', run 'export KUBECONFIG=/home/core/git/gitlab/ocp_poc/acme.local/ocpdev/auth/kubeconfig' 
INFO Access the OpenShift web-console here: https://console-openshift-console.apps.ocpdev.acme.local 
INFO Login to the console with user: "kubeadmin", and password: "wryRN-wnoyR-qRZxi-4Wngx" 
DEBUG Time elapsed per stage:                      
DEBUG      pre-bootstrap: 47s                      
DEBUG          bootstrap: 1m4s                     
DEBUG             master: 1m38s                    
DEBUG Bootstrap Complete: 24m19s                   
DEBUG                API: 1m47s                    
DEBUG  Bootstrap Destroy: 1m54s                    
DEBUG  Cluster Operators: 26m14s                   
INFO Time elapsed: 56m4s                          
[core@ocpbastion ocpdev]$ export KUBECONFIG=/home/core/git/gitlab/ocp_poc/penguinpages.local/ocpdev/auth/kubeconfig
[core@ocpbastion ocpdev]$ oc get nodes
NAME                          STATUS   ROLES                  AGE   VERSION
ocpdev-mnhrv-master-0         Ready    control-plane,master   49m   v1.26.6+6bf3f75
ocpdev-mnhrv-master-1         Ready    control-plane,master   48m   v1.26.6+6bf3f75
ocpdev-mnhrv-master-2         Ready    control-plane,master   49m   v1.26.6+6bf3f75
ocpdev-mnhrv-worker-0-bw9ln   Ready    worker                 23m   v1.26.6+6bf3f75
ocpdev-mnhrv-worker-0-f8dhn   Ready    worker                 23m   v1.26.6+6bf3f75
ocpdev-mnhrv-worker-0-ndg2d   Ready    worker                 23m   v1.26.6+6bf3f75
ocpdev-mnhrv-worker-0-v85h6   Ready    worker                 23m   v1.26.6+6bf3f75
ocpdev-mnhrv-worker-0-xnpw5   Ready    worker                 21m   v1.26.6+6bf3f75
[core@ocpbastion ocpdev]$ 

```

------
## <span style="color:green"><b> Debug Notes</span></b>

<br>
If you watch vcneter you will roughly see in order of deployment and rough times:

From vCenter: Review the VMs as deployed.
- Template iamge deployed (<5min)
- fist ignition master deployed and all YAML / TF files copied over (<5min)
   - See IP binding  from DHCP and VIP for API (<10min)
- This master deploys three more masters (or count noted above)(<10min)
   - See IP binds to workers from DHCP (<10min)
- Deployment of three workers (ore count noted above)(<15min)
   - See IP binds to workers from DHCP(<15min)
- Destroy first ignition master(<30min)

<br>


<br>

------
## <span style="color:green"><b> Post Deployment Test</span></b>

<br>

CLI Example  
```
export KUBECONFIG=/home/core/git/gitlab/ocp_poc/penguinpages.local/ocpprod/auth/kubeconfig" >> ~/.bash_profile


[core@ocpbastion ocpprod]$ oc get nodes
NAME                           STATUS   ROLES                  AGE   VERSION
ocpprod-slkw6-master-0         Ready    control-plane,master   57m   v1.27.8+4fab27b
ocpprod-slkw6-master-1         Ready    control-plane,master   30m   v1.27.8+4fab27b
ocpprod-slkw6-master-2         Ready    control-plane,master   70m   v1.27.8+4fab27b
ocpprod-slkw6-worker-0-bcxpk   Ready    worker                 14m   v1.27.8+4fab27b
ocpprod-slkw6-worker-0-l9fbr   Ready    worker                 20m   v1.27.8+4fab27b
ocpprod-slkw6-worker-0-mhp5f   Ready    worker                 20m   v1.27.8+4fab27b
```


#Test with web browser
https://console-openshift-console.apps.ocpprod.ps.labs.local/

Username	kubeadmin
Password	<output from cat kubeadmin-password cat /home/core/git/gitlab/ocp_poc/penguinpages.local/ocpprod/auth/kubeconfig/auth/kubeadmin-password"> 


