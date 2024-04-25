# This is workflow examples of how to create a dedicated set of nodes for hosting storage within a kubernetes cluster

# Workflow will require selection of:
- Machine Set Type
     - VM (default)  ---> needs work on calling deployment common variables
     - Bear metal
     - Public Cloud
- Required storage services installed.  Options are:
     - vmfs
     - iSCSI (default)
     - Object
     - NVMEoE
     - MPIO
     - FCoE
- Storage drives added per storage-node-<vendor>


# Collect Openshift Cluster Variables for MachineSet
https://docs.openshift.com/container-platform/4.14/machine_management/creating-infrastructure-machinesets.html

```
oc get -o jsonpath='{.status.infrastructureName}{"\n"}' infrastructure cluster

```
# Publish Base  machine-set-storage  



```


```

# Deploy various types of storage nodes per site requirements


### storage-nodes-portworx
These four nodes are just set with basic machine-set and taints.  The rest of the magic is in the Portworx CSI Driver

PortWorx Requirements:
Four infra nodes to meet minimum of 30VCPU so 4 nodes x 8VCPU 16GB RAM each.

<br>
<br>

### storage-nodes-odf

This will need setup basic machine-set and taints.  The rest of the setup will be allocation of raw block storage to each of the four nodes

ODF Requirements:
Goal is to build out using block iSCSI, storage with NPOF for infra nodes set tain "storage-nodes"
Four infra nodes to meet minimum HCI (ODF) of 30VCPU so 4 nodes x 8VCPU 16GB RAM each. 
ODF maximum is 8 raw disk per ODF node and 4TB max per target device.

Example Disk layout for each of the four storage tained infra nodes:
```
/dev/sda  ->  100GB for HCI cache
/dev/sdb-g -> 200GB for HCI for data 
```
<br>
<br>




# How to create a node, taint it for "storage", and install iSCSI components
# Issues:  How much of below is handled by OEM CSI driver?
# 1) How to setup MPIO for bear metal
# 2) How to add in kernel shim divers or hardware drivers for bear metal
# 3) How to validate MPIO table build correctly
# 

