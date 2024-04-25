This is for documentation on how to use Pure Portworx

This path can choose one of several workflows which are based on "spec" file that defines "Storage Cluster":
- portworx-storage-cluster-vmfs-cloud-drive-spec.yaml -> VMWare "Cloud Drive"  VMFS automated deploy of Portworx  NOTE:  Has con that other storage vendor integration would be problematic!
- portworx-storage-cluster-pureallflash-spec.yaml -> PureAllFlash iSCSI + Portworx CSI Driver fully automated allocation and managed
- portworx-storage-cluster-pureflashblade-spec.yaml -> Pureflashblade iSCSI + Portworx CSI Driver fully automated allocation and managed: object (COSI), NFS "passthrough", Block for portworx...  not very clear here
- portworx-storage-cluster-pre-allocated-spec.yaml -> General pre-allocated Storage (such as FC or other vendor but you have to know and build spec file to knwo device IDs and is not dynamic)

<<<not sure if / how this will work>>>
- portworx-storage-cluster-pureallflash-spec.yaml -> PureAllFlash iSCSI + Portworx CSI Driver for pod direct allocation 


Initially it will define and consume existing worker nodes within the cluster, but a option does exist for dedicated nodes: https://docs.portworx.com/portworx-enterprise/install-portworx/disaggregated
Issues:
1) Operator install UI vs YAML is very unclear and or broken
2) Complex workflow of if PURE storage to use CSI driver from Portworx, vs DAS / VMFS needs some clarification
3) How are we saving keys and certs are stored and retreived from keyvault