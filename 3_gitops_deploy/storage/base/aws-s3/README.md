Storage class, PVC, and Eample PV to use AWS Object based storage

Goal:
Create 10GB S3 storage bucket and bind it to OpenShift Cluster to consume.  Create this all in namespace  "openshift-backup"

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



