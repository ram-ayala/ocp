# Basic deployment of cluster for NSPOF on VMWare via IPI process

## Documentation

<br>

## Steps for Deployment

- [ ] [Local ETCD Backup](#Local-ETCD-Backup)
- [ ] [Velaro Backup](#Velaro-Backup)

</br>

------
## <span style="color:green"><b> Local ETCD Backup</span></b>

<br>

This backup reverts cluster state to a point in time.  This is NOT to recover any pods or nodes.  This is just to restore cluster to a working state.



```
---
apiVersion: v1
kind: Namespace
metadata:
  name: ocp-etcd-backup
---
kind: ServiceAccount
apiVersion: v1
metadata:
  name: openshift-backup
  namespace: ocp-etcd-backup
  labels:
    app: openshift-backup
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: cluster-etcd-backup
rules:
- apiGroups: [""]
  resources:
     - "nodes"
  verbs: ["get", "list"]
- apiGroups: [""]
  resources:
     - "pods"
     - "pods/log"
  verbs: ["get", "list", "create", "delete", "watch"]
- apiGroups: [""]
  resources:
     - "namespaces"
  verbs: ["get", "list", "create"]
---
kind: ClusterRoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: openshift-backup
  labels:
    app: openshift-backup
subjects:
  - kind: ServiceAccount
    name: openshift-backup
    namespace: ocp-etcd-backup
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-etcd-backup
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: system:openshift:scc:privileged
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: system:openshift:scc:privileged
subjects:
- kind: ServiceAccount
  name: openshift-backup
  namespace: ocp-etcd-backup
---
kind: CronJob
apiVersion: batch/v1
metadata:
  name: openshift-backup
  namespace: ocp-etcd-backup
  labels:
    app: openshift-backup
spec:
  schedule: "0 0 * * 0"
  concurrencyPolicy: Forbid
  successfulJobsHistoryLimit: 5
  failedJobsHistoryLimit: 5
  jobTemplate:
    metadata:
      labels:
        app: openshift-backup
    spec:
      backoffLimit: 0
      template:
        metadata:
          labels:
            app: openshift-backup
        spec:
          containers:
            - name: backup
              image: "registry.redhat.io/openshift4/ose-cli"
              command:
                - "/bin/bash"
                - "-c"
                - oc get no -l node-role.kubernetes.io/master --no-headers -o name | xargs -I {} --  oc debug {} -- bash -c 'chroot /host sudo -E /usr/local/bin/cluster-backup.sh /home/core/backup/ && chroot /host sudo -E find /home/core/backup/ -type f -mmin +"1" -delete'
          restartPolicy: "Never"
          terminationGracePeriodSeconds: 30
          activeDeadlineSeconds: 500
          dnsPolicy: "ClusterFirst"
          serviceAccountName: "openshift-backup"
          serviceAccount: "openshift-backup"

```

Compute and apply rulesets for Roles and Bindings first

```
oc auth reconcile -f etcd-backup.yaml
oc apply -f etcd-backup.yaml

```

Run backup.  Test it works

```
oc create job backup-test --from=cronjob/openshift-backup
oc get pods -n ocp-etcd-backup
oc logs -n ocp-etcd-backup backup-test-bwcqr  | less

```

</br>

------
## <span style="color:green"><b> Velaro Backup</span></b>

<br>





