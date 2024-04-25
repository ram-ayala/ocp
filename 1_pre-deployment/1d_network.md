# Configuration of Environment Network for Openshift Deployment

## <span style="color:green"><b>Documentation</span></b>



<br>

## Steps for Deployment

- [ ] [Network L2](#Network-L2)
- [ ] [Network L3](#Network-L3)
- [ ] [IPLB](#IPLB)
- [ ] [DR & HA](#DR-&-HA)
- [ ] [Service Mesh](#Service-Mesh)
- [ ] [DHCP Scope Table](#DHCP-Scope-Table)
- [ ] [Site Table](#Site-Table)

</br>

------
## <span style="color:green"><b> Network L2</span></b>


Kubenetes require at least one L2 subnet. Within this L2 broadcast domain you can host most resorces needed to run the cluster, but their are other networks that are typical.  A typical approach is one network for ingress and managment,  and one on back end that is for workloads. This Workload network is many times not even nessisary to have routing to other IT resources, and as such uses non-routable IP allocation.   

Most customer if they have one manament and one supervisor cluster, this is sufficient.  The size of the cluster can vary, but to enable scale, and more workload cluster resources, it is not unusual to consume an entire /24 for workload. Our opinion is to start smaller and as clusters are built out and get more complex, they can be adjusted, and as resources within the cluster are all dynamic and allocations are managed internally, this is not a major change.

<br>


------
## <span style="color:green"><b> Network L3</span></b>


Kubenetes require at least some form in ingress routing into the cluster. Typically one for API / Manamgent, and another IP or bank of IPs for applications. Different vendors handle this differntly. Many expect or assume the customer will provide external management and just expect CSI compliant control.  Most customers the managment network will need routability to IT resources as well as application resources within the cluster.  Direct workload routing is not required and not typical, so the workload cluster many times is not routable and is treated as an "overlay" network.  The excepts to this are around storage and Windows workers, but as these are not core to kubernetes designs, are treated as exceptions to the standard approach.

<br>

------
## <span style="color:green"><b> IPLB </span></b>

Kubenetes typically will employee some form of IP Load Balancer (IPLB). Different vendors handle this differntly. Many expect or assume the customer will provide external IPLB and just expect CSI compliant version. Openshift can and does work with this, but also deploys ingress IPLB services as a function within the cluster.  IPLB services then are a native service and managed function within the cluster.  The sizing and tuning for most workloads are not a concern, but if data throughput or latency is an application concen, then customizations can be made to significantly increase this.  OpenShift's IPLB is HAProxy as ann active/passive configuration, L4 services, but also runs as NSPOF serice on the infrastructure tagged nodes.

<br>


------
## <span style="color:green"><b> Service Mesh </span></b>

Kubenetes changes many aspects of application monitoring and security control. Most customers, in their first production deployment will avoid the complexity of a sevice mesh application deployment as it requires that each application delares all communications, east /west  as well as north/south.  This is a burdon that the development team will have to work with as they define and build / deploy applications.   Without this though, the security teams many times lack the audit and control they would have in a traditional "VM/Hardware" based system (agents, service trackers , firewalls), and as such, most customers end up coming back and putting in a sevice mesh before the application goes live.  

<br>


------
## <span style="color:green"><b> DHCP Scope Table</span></b>

<br>

Below are DHCP scope options that need to be leased out on Managment L2 network noted above.  Also note that each cluster deployment can consume up to 10 IPs, so if multiple deployments made, scope size will need to accomodate, and also have cleanup.   Post installation their is also requiremnt to set long term static leases for nodes.  

DHCP Scope Options Required:
- 002 TimeZone Offset 
- 003 router 
- 042 NTP server	
- 005 Name Server	
- 006 DNS Server	
- 015 DNS Domain Name	


<br>

------

## <span style="color:green"><b> Site Table</span></b>

<br>

Complete below table for your site needs.

| <span style="color:gold"> Network Role </span> | <span style="color:gold"> IP/Mask </span> | <span style="color:gold"> GW </span> |<span style="color:gold"> VLAN Name|<span style="color:gold"> DHCP Lease Range| <span style="color:gold"> Notes / Details</span> |
| :--------------- | :---- | :--------------- | :--------------- |:--------------- |:--------------- |
| Machine Network |<span style="color:red"> 10.100.100.0/24 | <span style="color:red">10.100.100.1 | <span style="color:red">10.100.100.1 |<span style="color:red"> 10-200 | IPLB, VM Mgmt, deployment , bastion host |
| Overlay Network(s) |<span style="color:red"> 172.16.0.0/16 | <span style="color:red"> NA| <span style="color:red"> 100_k8_prod | NA | Overlay network for internal cluster communication on same L2 as Production OCP has defaults and you can just leave these|

