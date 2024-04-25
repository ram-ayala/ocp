# This is Documentation on how to bind storage to your Kubernetes Cluster

<br>

1. [Select Your Storage](#Select-Your-Storage)
2. [Setup Base Storage Definitions with Kustomizations for each Cluster](#Setup-Base-Storage-Definitions-with-Kustomizations-for-each-Cluster)


<br>


The goal of this structure is to document various storage vendor's CNCF compliant CSI drivers.  To define storage classes for all storage types of that storage vendor.  And to, when possible export one RWX storage PVC (Persistent Volume Claim)

Create all storage by detault within k8 namesapce "openshift-storage" but kustomize if/as needed Ex:  S3 in namespace for backups 

<br>

## Select Your Storage

<br>

Under /base directory is a list of various storage vendors and offerings that meet CNCF compliance.  Choose the one(s) that fall within scope of customer resourecs and edit each to reflect site needs.  


~~~
./3_gitops_deploy/storage/
├── .images -> png images for documentation
├── base
│   ├── .images -> png images for documentation
│   ├── aws-s3 -> Object storage hosted in Amazon. Popular for backup of cluster configuration state
│   ├── azure-object -> Object storage hosted in Azure. Popular for backup of cluster configuration state
│   ├── linux-nfs -> Examples for how to use generic NFS. And fallback to hosted off linux VM for RWX
│   ├── netapp -> Examples for how to use classic NetApp FAS file and object storage for storage.
│   ├── nutanix -> Examples for how to use Nutanix HCI Storage of block, file and object storage CSI Storage.
│   ├── odf -> Examples for how to use Red Hat HCI Storage of block, to export NFS, Object,& Block storage via CSI HCI.
│   ├── portworx -> Examples for how to use Pure Portworx HCI Storage of block, to export NFS, Object,& Block storage via CSI HCI.
│   ├── pure-allflash -> Examples for how to use Pure iscsi or FC block via portworx CSI driver to pods.
│   ├── pure-flashblade -> Examples for how to use Pure AllFlash Storage array file and block via portworx CSI driver to pods.
│   ├── storage-infra-nodes -> Build out machine-set and deploy four nodes for hosting storage to be consumed by storage offerings that build HCI replicationg storage.  This is just the nodes and tains, not storage to them as workers.
│   └── vmware-vsan -> Examples for how to use Vmware vSAN Storage array file and block via CSI driver to pods.
├── overlays
│   ├── .images -> png images for documentation
│   ├── ocpprod -> kustomization that reflects consumption of above storage type(s), and as need customization for the production site production workload cluster
│   ├── ocpdev -> kustomization that reflects consumption of above storage type(s), and as need customization for the production site dev workload cluster
│   └── ocpdr -> kustomization that reflects consumption of above storage type(s), and as need customization for the dr site dr workload cluster
└── README.md - <you are here>
~~~

Note:
1) For each storage type, all allowed storage claim types are defined, though not all may be required.  Ex:  NetApp can do block, file via NFS and file via Object.  Though the cusotmer may only wish today to consume NFS... the storage claim types will be defined.
2) Each storage vendor which CAN export a volume claim that meets RWX compliance will do so for an example with PV called "$clustername-image-registry" to provide common expected mount path.  Ex:  ocpprod-image-registry  PV 300GB  Please see "imageregistry-ocp" kustomization for more details.

Within each storage folder that reflects vendor offering, please review README.md and then edit  all yaml files to meet deployment requirements and deploy as directed.




## Setup Base Storage Definitions with Kustomizations for each Cluster

<br>
Once you have made modifications for the base storage vendor sub folder, go into sub folder /overlay/ and define base and then cluster kustomization  

Ex:  odf/  for cluster ocpprod  

1) Edit files /odf  to deploy define all storage class, operators, security roles, and storage claim types for RedHat Open Data Foundation. 
2) Edit /overlays/ocprod/kustomize.yaml to reflect consumption of base storage within /base/odf/   with then modifications to reflect PV claim to be different size and name .. or NFS mount export name.
3) Optionaly you may need to add other storage configurations within other directories and storage claim types.  Ex:  iSCSI from Portworx would require a call to /base/portworx-allflash/  with its kustomizations if needed.


How to apply
```
oc kustomize --enable-helm storage/overlays/ocpprod/ |oc apply -f -
```

