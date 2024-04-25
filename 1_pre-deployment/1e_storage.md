# Configuration of Environment Storage for Openshift Deployment

## Documentation

https://kubernetes.io/docs/concepts/storage/persistent-volumes/

<br>

## Steps for Deployment

- [ ] [Storage Needs Configuration](#Storage-Needs-Configuation)
- [ ] [RWX Storage](#RWX-Storage)
- [ ] [Object Storage](#Object-Storage)
- [ ] [Block Storage](#Block-Storage)
- [ ] [Site Table](#Site-Table)
</br>

------
## <span style="color:green"><b> Storage Needs Configuration</span></b>


Not all use cases of Kubenetes require the same sotrage needs. This reflects an opinionated reference design for what most customers need to host production grade applications, which have storage needs to supply data for applications. 

<br>

<b>Storage Opinions: </b>
- Most applicaitons in K8 today are ephemeral in nature, and so local JBOD disk mount points is all that is needed. This is classified as RWO storage.
- Most applications in K8 today are designed, if they need persistent storage to retain availability through applications which retain data avilabilty by replication over network replication. Ex: Transacton replication Postgres on RWO storage.
- Some storage needs to be shared, as the data is sourced once and written, and expected to be accessible by mulitple systems or services. Storage types RWX.  Ex:  Image registry on NFS file share mount
- High performance disk, weither in aspect of high IO (Ex: typically over 20k iops), or low latency (Ex: <3ms response). These kinds of data needs can be accomplished within Kubernetes, but requires more desgn and many times dedicated hardware.

<br>

------
## <span style="color:green"><b> RWX Storage</span></b>

<br>
Most clusters require this form of storage to enable NSPOF for Image Regisry services within the cluster.  By default Kubernetes vendors assume the customer will handle availabilty designs to match there use case.  Our opion in that image registry services must scale (3 copies, one per paster) and as such require RWX storage.

Examples:  NFS Share, Object Share.

This can be internal within the cluster and so under its support and automation, or external. 


------
## <span style="color:green"><b> Object Storage</span></b>

<br>
This storage type is more common in public cloud.  Most on-premise sites do not have this within datacenters so the use of this needs to be aligned with latency, data cost to save / retrieve, and capacity.  Most clusters this is required for backup of the cluster, and persistent volume claim data.  This can be a public cloud provider target, but has egreess and latancy design concerns.  For the main ETCD database this is very small concern, but as more application data is backed up, and has restore RPO / RTO, this will become more of a design concern.


------
## <span style="color:green"><b> Block Storage</span></b>

<br>
This is the most typical storage classifcation within a datacenter.  Most datacenters have complex and large investments in various block storage types.  Typical: VMFS (create vmdk JBOD disk file with worker nodes VM), iSCSI over ethernet,  Fiber channel disk,  NVMeOE, etc..

The scale of design and performance is large and complex and may require application to use case consulting.  Many storage vendors do NOT today have primitives within Kubernetes to handle block storage in its full function, and as such most applications are / should design for failure, then trying to retain data within data volume level replication / recovery.  Ex:  Snapshots and replication to remote sites CAN work, if their are a very clear and tested set of configurations, and the vendor has all the Kubernetes primitives created. Otherwise , the data will not be able to be recovered.

<br>

------
## <span style="color:green"><b> Site Table</span></b>

<br>
Complete below table for your site needs.

| <span style="color:gold"> Storage Role </span> | <span style="color:gold"> Type </span> | <span style="color:gold"> Customer Details | <span style="color:gold">Notes / Details</span> |
| :--------------- | :---- | :--------------- | :--------------- |
| Block Storage |<span style="color:red"> vmfs thin provision | <span style="color:red">/datastore_01 | VMFS thin provisioned disk, storage with VM |
| Image Regisry |<span style="color:red"> NFS |<span style="color:red"> nfs01.acme.local:/k8_ir | NetApp Storage Array 500GB share  |
| Backup |<span style="color:red"> Object |<span style="color:red">  'user1@example.com:auth_token'   https://swiftobjectstorage.us-1.cloud.com/v1/namespace-string/bucketname/acme-k8-backup.dmp | S3 Storage Array 500GB share  |