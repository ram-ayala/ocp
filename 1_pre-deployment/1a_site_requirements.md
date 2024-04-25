# Site Requirements Document

 This document is to ensure site has materials and details nessisary for Openshift deployment 

All items in <span style="color:red">RED </span> must be filled out prior to deployment date starts.

</br>

## Openshift Install
- [ ] [Common Deployment Assets](#VMWare-IPI-Deploy)
- [ ] [VMWare IPI Deploy](#VMWare-IPI-Deploy)
- [ ] [VMWare UPI Deploy](#VMWare-UPI-Deploy)
- [ ] [Git Token](#Git-Token)
- [ ] [Bear Metal or Assisted Installer Deploy](#Bear-Metal-or-Assisted-Installer-)

</br>

---------------------

## <span style="color:lightblue"><b>  Common Deployment Assets for all Openshift Cluster Deployments </span></b>

### Login for RedHat Website with RHN subscription
RedHat Network Login ID. Its free... create one. This can / should be bound to company org ID to access keys and registrations.

https://cloud.redhat.com/openshift/install/vsphere/user-provisioned

![Redhat Account Login](./.images/redhat_account_login.png)

Click "Copy Pull Secret and save

![Redhat Pull Secret](./.images/redhat_pull_secret.png)

Review Cloud registered OCP clusters
https://console.redhat.com/openshift


<b>Network</b>
- DNS Server Primary
- DNS Server Secondary
- NTP Server Primary 
- NTP Server Secondary
- NTP Time Offset
- DNS Zone

</br>

---------------------

## <span style="color:green"><b>  VMWare IPI Deploy</span></b>
<br>

Diagram:
![Cluster Diagram](./.images/cluster_diagram.png)

## <span style="color:green"><b> -- Host Table</span></b>
<br>

| <span style="color:gold"> Hostname FQDN </span> | <span style="color:gold"> IP </span> | <span style="color:gold"> Gateway | <span style="color:gold">Notes / Details</span> |
| :--------------- | :---- | :--------------- | :--------------- |
| <span style="color:red">bastion.acme.com |<span style="color:red"> 10.0.0.10/24 | <span style="color:red">10.0.0.1 | Deployment bastion host running RHEL |
| <span style="color:red">vcenter.acme.com |<span style="color:red"> 10.0.0.11/24 |<span style="color:red"> 10.0.0.1 | vCenter server for hosting deployment  |
| <span style="color:red">dns01.acme.com |<span style="color:red"> 10.0.0.12/24 |<span style="color:red"> 10.0.0.1 | Primary Domain DNS server  |
| <span style="color:red">dns02.acme.com |<span style="color:red"> 10.0.0.13/24 |<span style="color:red"> 10.0.0.1 | Secondary Domain DNS server  |
| <span style="color:red">dns01.acme.com |<span style="color:red"> 10.0.0.12/24 | <span style="color:red">10.0.0.1 | Primary NTP server  |
| <span style="color:red">dns02.acme.com |<span style="color:red"> 10.0.0.13/24 | <span style="color:red">10.0.0.1 | Primary NTP server  |

## <span style="color:green"><b> -- vCenter Cluster Hardware Requirements</b>

<br>

Most customers will find successful for testing to reflect VMWare Resource available capacity of: 

- 32vCPU
- 128GB RAM
- 1TB SSD class Storage
- 1 Port Group (VLAN) with DHCP services routable to Internet
- limited user account. Ex: openshift@vshere.local


DHCP Scope Options Required:
- 002 TimeZone Offset 
- 003 router 
- 042 NTP server	
- 005 Name Server	
- 006 DNS Server	
- 015 DNS Domain Name	

## <span style="color:green"><b> -- DNS Record Table For Example Cluser</span></b>
<br>

Below is for one clsuter.  Ex:  ocpprod

Most sites will have three Ex: ocpprod, ocpdev, ocpdr 


| <span style="color:gold"> Record Type </span> | <span style="color:gold"> FQDN </span> | <span style="color:gold"> IP | <span style="color:gold">Notes / Details</span> |
| :--------------- | :---- | :--------------- | :--------------- |
| <span style="color:red"> Zone |<span style="color:red"> acme.com |  - | Base DNS domain for site |
| <span style="color:red"> Zone |<span style="color:red"> ocpprod.acme.com |  - | For cluster "ocpprod" A and PTR for API and Admin interface of cluster |
| <span style="color:red">A/PTR |<span style="color:red"> api.ocpprod.acme.com | <span style="color:red">10.0.0.21 | For cluster "ocpprod" A and PTR for API and Admin interface of cluster |
| <span style="color:red"> Zone |<span style="color:red"> apps.ocpprod.acme.com |  - | Subzone within zone for Openshift for applications |
| <span style="color:red"> A/PTR |<span style="color:red"> *.apps.ocpprod.acme.com | <span style="color:red">10.0.0.22 | Star record for applications within Openshift cluster |

</br>
Done.  Move on to next step...

</br>

---------------------

## <span style="color:green"><b>VMWare UPI Deploy</span></b>
<br>

<span style="color:orange"><b>Coming soon to a CDW customer near you !!</span></b>

</br>


</br>

---------------------

## <span style="color:green"><b>Git Token</span></b>

<br>
The cusotmer for CI / CD integration needs access a shared "service account" where they can create a Group or Personal Access token.  There are many workflows and options for how to do this and can be matched to meet the application team's requirements, but the customer needs to have login and rights to create these code repo and tokens at deployment time, or, know what they need and provide this before deployment starts.

Ex:

| <span style="color:gold"> Type </span> | <span style="color:gold"> Name </span> | <span style="color:gold"> Token | <span style="color:gold">Notes / Details</span> |
| :--------------- | :---- | :--------------- | :--------------- |
| <span style="color:red"> Git Lab Group Access Token |<span style="color:red"> GAT_gitlab_ocp_acme | <span style="color:red">  [insert long token ]| This can be a group token authorized for all projects / code repos under this group. Authorization to run and call then is high level for all CI/CD for different apps under single runner |

This will be used post cluster deployment for each cluster to bind to CI process / resources:  Jenkins, ArgoCD etc..




</br>

---------------------

## <span style="color:green"><b>Secrets Store</span></b>

<br>
Storage for key/values and secrets that is CNI compliant
https://github.com/external-secrets/external-secrets

Ex: Azure , Google, AWS, Hashi Vault, KLM Server, etc...
    



</br>

---------------------

## <span style="color:green"><b>Bear Metal or Assisted Installer Deploy</span></b>

<br>

    


<span style="color:orange"><b>
This is coming...  wait for it....  it will be super awsome and delicious!</span></b>

</br>