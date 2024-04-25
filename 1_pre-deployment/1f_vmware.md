# Configuration for VMWare Environment for Openshift Deployment

## Documentation

<br>

## Steps for Deployment

- [ ] [vCenter Configuration](#vCenter-Configuration)
- [ ] [Limited User Account](#Limited-User-Account)
- [ ] [Optional Assets](#Optional-Assets)
- [ ] [Post Cluster Deployment Configurations](#Post-Cluster-Deployment-Configurations)

</br>

------
## <span style="color:green"><b> vCenter Configuation</span></b>

<br>

## <b> VMWare Cluster Table</b>

| <span style="color:gold">Resource | <span style="color:gold">Name | <span style="color:gold">Notes</span> | 
| :--------------- | :---- | :--------------- |
| vCenter FQDN|<span style="color:red"> vcenter01.acme.com | version 7.0.3 |
| Access |<span style="color:red"> openshift@acme.com | Roles defined and bound per above |
| Resource Pool|<span style="color:red"> Normal_VMs | Optional but helpful |
| Datacenter|<span style="color:red"> ProdDC | Datacenter location |
| Cluster |<span style="color:red"> ProdCluster | Cluster Name |
| VM Folder|<span style="color:red"> /openshift/ocpprod/ | Optional but helpful |
| Storage |<span style="color:red"> vSANProd01 | Shared VMFS Volume |
| Switch | <span style="color:red">dvSwitch00 | dvSwitch or common switch name for all esxi hosts |
| PortGroup | <span style="color:red">100_k8_prod | Port Group in above vSwitch |
# 
**All items in red need to be filled out before deployment can start


<br>



------
## <span style="color:green"><b> Limited User Account</span></b>

<br>
In deployment of production clusters within VMWare, you can use as a baseline the SSO Admin account but it is stronly discouraged.  Creation of limied user account limits down permissions, and also enables audit trail that tasks run via Bastion or CI pipleline automations are as a defined user.

Ex:  openshift@acme.com -> AD / LDAP / Okta account.
Ex:  openshift@vsphere.local -> local account in vCenter SSO. Avoids auth requirement to be external to function.

Documentation: https://docs.openshift.com/container-platform/4.13/installing/installing_vsphere/installing-vsphere-installer-provisioned.html#installation-vsphere-installer-infra-requirements_installing-vsphere-installer-provisioned

CDW has built out a shell script that can setup this limited account using user variables.  See: <acme.local>/k8_limited_deploy_vcenter_user/  for shell script.



<br>

---




## <span style="color:green"><b> Optional Assets</span></b>

<br>
- vSAN -> This can be used via file services for RWX (NFS Export) used by image registry, and Object based storage, used for backup of cluster

<br>

- High-Availability Grid Cluster

https://docs.vmware.com/en/VMware-vSphere/8.0/vsphere-with-tanzu-concepts-planning/GUID-376EE3F0-D881-4FF5-9CD3-41341F840035.html



<br>

------
## <span style="color:green"><b> Post Cluster Deployment Configurations</span></b>

Once a successful cluster is completed, the Openshift environment will have several tasks that are strongly recommended to complete and polish a productionr ready environment

- Anti-Host Afinity Groups:  Isolate masters and workers into independant afinity groups to isolate SPOF situation.
- Set Long term DHCP lease reservations
- Document and define process that reservation for DHCP MUST be resetup with new long term leases once cluster is upgraded.
- Clean out and check DHCP pool within deployment subnet
- When vCenter is upgarded, rights change on limited user accounts some times, Validate if post major vCenter upgrade.

