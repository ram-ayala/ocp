#  Pure All Flash - iSCSI Storage

Goal is to build out storage block allocation for the kubernetes cluster. The CSI driver for Pure storage systems is now within the Portworx operator.  For the full Portworx deployment it will automatically provision required block iSCSI storage but for other "general purpose" needs for iSCSI, as well as use cases of block for other storage such as Red Hat ODF, many iSCSI storage disk will need to be provisioned.

This deployment documents this more complex workflow of allocation of many disk to a worker against which you can limit down, or modify for your site needs.  

Ex:  A total of four "storage-node tainted infra nodes each with five iSCSI disk mapped. With deployment of required software and configurations for NSPOF.


### Documentation Portworx

https: //docs.portworx.com/portworx-enterprise/operations/operate-kubernetes/storage-operations/create-pvcs/pure-flashblade 


#### Pure JSON File Generation


Setup API key and bind within Pure1 web portal to which the stoage is registered:  https: //pure1.purestorage.com/

Generate SSH key And import

```
openssl genrsa --out pure-api.pem 2048
openssl rsa -in pure-api.pem -pubout -out pure-api.crt

```

This will publish the Pure1 API Token.

API Token: pure1:apikey: 6zWk9oc2TS0zmhVq

Use this template to create site JSON file

https: //docs.portworx.com/portworx-enterprise/reference/pure-reference/pure-json-reference
Note: Pure1 Token I am not sure is correct path vs each controller to generate its own API token.

Fore Pure "All flash" array. you get / create token within array, NOT in PureOne portal. Use same SSH public key .. Hmmm.. seems odd. and.. 1 day token??? <sigh> and don't forget to "enable" token.. default is disable


Take JSON file with tokens, and store as secret.  
Note: See Various examples for secrets storage in repository main README.md


Ex: Azure 
```
az login
vault= "<your-unique-keyvault-name typically cluster name>"  # Ex: ocpprod-acme-local
az keyvault secret set --vault-name $vault --name "px-pure-api-key" --file "./storage/base/pure_allflash/pure.json"
az keyvault secret set --vault-name $vault --name "px-pure-ssh-key-priv" --file "./storage/base/pure_allflash/pure-api.crt"
az keyvault secret set --vault-name $vault --name "px-pure-ssh-key-pub" --file "./storage/base/pure_allflash/pure-api.pem"

```

### iSCSI for Kubernetes node allocation
https://docs.openshift.com/container-platform/4.8/storage/persistent_storage/persistent-storage-iscsi.html


