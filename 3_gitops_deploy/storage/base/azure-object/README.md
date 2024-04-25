Storage class, PVC, and Eample PV to use Azure Object based storage

https://access.redhat.com/documentation/en-us/red_hat_openshift_container_storage/4.8/html/deploying_openshift_container_storage_using_microsoft_azure_and_azure_red_hat_openshift/deploying-openshift-container-storage-on-azure-red-hat-openshift_azuree#installing-openshift-container-storage-operator-using-the-operator-hub_azuree


Goal:
Create 10GB Object storage bucket and bind it to OpenShift Cluster to consume.  Create this all in namespace  "openshift-backup"

Create AWS Bucket

```
aws s3api create-bucket \
   --bucket <YOUR_BUCKET> \
   --region <YOUR_REGION> \
   --create-bucket-configuration LocationConstraint=<YOUR_REGION>
```

Create AWS User for IAM

```
aws iam create-user --user-name velero
```



