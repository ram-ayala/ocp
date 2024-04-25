# Generic NFS Storage CSI Driver Integration


## Documentation

https://docs.openshift.com/container-platform/4.13/storage/persistent_storage/persistent-storage-nfs.html


<br>

## Steps for Deployment
- [ ] [NFS RBAC](#NFS-RBAC)
- [ ] [NFS Client Provisioner](#NFS-Client-Provisioner)
- [ ] [Storage Class](#Storage-Class)
- [ ] [Storage Client Provisioner](#Storage-Client-Provisioner)
- [ ] [Persistent Volume Claim](#Persistent-Volume-Claim)

</br>
</br>

<b> Note:</b>  Steps below are performed within namespace openshift-image-registry to allow it to be consumed by those services.

<br>

------
## <span style="color:green"><b>NFS RBAC</span></b>

<br>

Define rbac roles for NFS tasks and mount 

```
vi /home/core/storage/nfs/nfs-rbac.yaml

-----------------
apiVersion: v1
kind: ServiceAccount
metadata:
  name: nfs-client-provisioner
  # replace with namespace where provisioner is deployed
  namespace: openshift-image-registry
---
kind: ClusterRole
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: nfs-client-provisioner-runner
rules:
  - apiGroups: [""]
    resources: ["nodes"]
    verbs: ["get", "list", "watch"]
  - apiGroups: [""]
    resources: ["persistentvolumes"]
    verbs: ["get", "list", "watch", "create", "delete"]
  - apiGroups: [""]
    resources: ["persistentvolumeclaims"]
    verbs: ["get", "list", "watch", "update"]
  - apiGroups: ["storage.k8s.io"]
    resources: ["storageclasses"]
    verbs: ["get", "list", "watch"]
  - apiGroups: [""]
    resources: ["events"]
    verbs: ["create", "update", "patch"]
---
kind: ClusterRoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: run-nfs-client-provisioner
subjects:
  - kind: ServiceAccount
    name: nfs-client-provisioner
    # replace with namespace where provisioner is deployed
    namespace: openshift-image-registry
roleRef:
  kind: ClusterRole
  name: nfs-client-provisioner-runner
  apiGroup: rbac.authorization.k8s.io
---
kind: Role
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: leader-locking-nfs-client-provisioner
  # replace with namespace where provisioner is deployed
  namespace: openshift-image-registry
rules:
  - apiGroups: [""]
    resources: ["endpoints"]
    verbs: ["get", "list", "watch", "create", "update", "patch"]
---
kind: RoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: leader-locking-nfs-client-provisioner
  # replace with namespace where provisioner is deployed
  namespace: openshift-image-registry
subjects:
  - kind: ServiceAccount
    name: nfs-client-provisioner
    # replace with namespace where provisioner is deployed
    namespace: openshift-image-registry
roleRef:
  kind: Role
  name: leader-locking-nfs-client-provisioner
  apiGroup: rbac.authorization.k8s.io


-----------------
```

Apply RBAC roles for NFS

```
oc apply -f /home/core/storage/nfs/nfs-rbac.yaml
```



<br>

------
## <span style="color:green"><b>NFS Client Provisioner</span></b>

<br>

Define Client Provisioner

```
vi /home/core/storage/nfs/nfs-client-provisioner-nas00.yaml

---------------------


---apiVersion: apps/v1
kind: Deployment
metadata:
  name: nfs-client-provisioner
  labels:
    app: nfs-client-provisioner
  # replace with namespace where provisioner is deployed
  namespace: openshift-image-registry
spec:
  replicas: 1
  strategy:
    type: Recreate
  selector:
    matchLabels:
      app: nfs-client-provisioner
  template:
    metadata:
      labels:
        app: nfs-client-provisioner
    spec:
      serviceAccountName: nfs-client-provisioner
      containers:
        - name: nfs-client-provisioner
          image: k8s.gcr.io/sig-storage/nfs-subdir-external-provisioner:v4.0.2
          volumeMounts:
            - name: nfs-client-root
              mountPath: /persistentvolumes
          env:
            - name: PROVISIONER_NAME
              value: k8s-sigs.io/nfs-subdir-external-provisioner
            - name: NFS_SERVER
              value: nas00.acme.local
            - name: NFS_PATH
              value: /media/md0/images
      volumes:
        - name: nfs-client-root
          nfs:
            server: nas00.acme.local
            path: /media/md0/images


```

Apply Client Provisioner role for NFS

```
oc apply -f /home/core/storage/nfs/nfs-client-provisioner-nas00.yaml

```

<br>

------
## <span style="color:green"><b>Storage Class</span></b>

<br>

Define storage class.  NFS provides classification of RWX storage where multiple pods /worker nodes can mount a given volume and write and read from it.  This is a file based share storage system.

Edit storage class for NFS Ex: nas00 host with volume exported called "/media/md0/images
Note: A and PTR DNS needs to be created within DNS


```
vi /home/core/storage/nfs/nfs-storage_class.yaml

--------------------


apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: nfs-client
  nameSpace: openshift-image-registry
provisioner: k8s-sigs.io/nfs-subdir-external-provisioner
parameters:
  archiveOnDelete: "false"

```


Apply NFS Storage class

```
oc apply -f /home/core/storage/nfs/nfs-storage_class.yaml

```

<b> ERROR:  The StorageClass "nfs-client" is invalid: provisioner: Forbidden: updates to provisioner are forbidden.

!!!!!!!!!!!!!!!!!!!!!!!

</br>

------
## <span style="color:green"><b>Persistent Volume Claim</span></b>

<br>

Edit storage claim for new storage class created above.

```
vi /home/core/storage/nfs/nfs-pvc-nas00.yaml


----------
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: pvc-nfs-nas00
  nameSpace: openshift-image-registry
spec:
  StorageClassName: nfs-client
  accessModes:
    - ReadWriteMany
  resources:
    requests:
      storage: 150Gi

--------------

```


Apply storage claim

```
oc apply -f /home/core/storage/nfs/nfs-pvc-nas00.yaml

```


