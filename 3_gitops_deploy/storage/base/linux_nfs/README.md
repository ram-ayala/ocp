This is basic NFS hosted off of deployment Linux Bastion host.

This is not supported as official NFS operator or type for production OCP cluster, but as a simple / fallback method to enable RWX storage and allow the operations or security issues to be remediated while moving the deployment forward.

Example for target system in diagram would be called  ocpbastion  but is intechangable for any NFS hostin Linux system and distribution.

Creating Export:

You will need disk volume with 300GB as that is expected by OpenShift.  This example uses /media as root folder to create each example sub folder for each cluster.

Also note that this storage example does NOT create a namespace but is defined to use image registry default namespace for OCP.

Setup NFS on bastion
```
sudo yum install  nfs-utils -y
sudo systemctl enable --now nfs-server rpcbind
echo "/media/ocpprod-image-registry *(rw,no_root_squash,subtree_check,no_wdelay,insecure)" >> /etc/exportfs
systemctl restart nfs-server.service 
exportfs
```


Test mount on bastion via loopback mount
```
mkdir /media/nfs
echo "ocpbastion.ps.labs.local:/media/ocpprod-image-registry      /media/nfs      nfs     defaults,rw,relatime,vers=3,rsize=1048576,wsize=1048576,namlen=255,hard,proto=tcp,timeo=600,retrans=2,sec=sys,local_lock=none 0 0" >> /etc/fstab
mount -t nfs ocpbastion.ps.labs.local:/media/ocpprod-image-registry      /media/nfs

```
