# Image Registry 


Use of local OCP image registry with NSPOF design will nessesitate use of RWX storage. NFS is a very popular storage for customers on premise to accomodate this.  Red Hat's supported NFS vendor list can be found on webiste.  CDW base workflow is each storage of RWX class will define PV called "$clustername-image-registry" to provide common expected mount path.  Ex:  ocpprod-image-registry  PV 300GB 

But to provid baseline / fall back of proper workflow to test, below is examle of a deployment / bastion host running temporarily from bastion host. This will demonistrate workflow to direct resources to this HA IR design.

Each cluster will have its own Image registry but can use common NFS mount, or sub directories. For our example we will use common export

Ex: /media/ocpprod-image-registry 10.89.0.0(rw,no_root_squash,subtree_check,no_wdelay,insecure)


How to use this kustomize repo
1) Edit /base to reflect main and environment wide definitions for storage, security and mount type/point needs for image registry
2) Create folder for each cluster and add kustomization file to reflect to use simple /base  configuration, or modification to reflect specific cluster needs
3) Run command from bastion host or other node to activate argo tracking of deployment

Ex: run test build of image registry edits for dev cluster

```
oc kustomize --enable-helm imageregistry-ocp/overlays/ocpdev/  | oc apply -f -

```
