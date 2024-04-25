# Bootstrap Steps

- [Bootstrap Steps](#bootstrap-steps)
  - [Create Kustomize overlays](#create-kustomize-overlays)
  - [Authentication Prerequisites](#authentication-prerequisites)
  - [Install Argo CD](#install-argo-cd)
  - [Apply the initial Argo CD Git credential](#apply-the-initial-argo-cd-git-credential)
  - [Apply the initial secret provider credential](#apply-the-initial-secret-provider-credential)
        - [Azure Key Vault example](#azure-key-vault-example)
        - [AWS Secrets Manager example](#aws-secrets-manager-example)
  - [Optional: Install Kustomize on bastion host](#optional-install-kustomize-on-bastion-host)

## Create Kustomize overlays

Add a Kustomize overlay for your new environment/cluster to each subdirectory (argocd, authentication, etc).

Tips
- Use Kustomize file naming convention: `<kind>-<resource-name>`
- To double check new overlays:

```bash
cd 3_gitops_deploy

ENVIRONMENT=<MY-ENVIRONMENT>
APP_LIST="argocd authentication external-secrets ocp-tls-certificates"

for APP in $(echo $APP_LIST)
do
   echo "Checking environment $ENVIRONMENT, app $APP..."
   kustomize build --enable-helm $APP/overlays/$ENVIRONMENT | grep replace_in_overlay
done
```

## Authentication Prerequisites

- Create a PAT in your Git system.
	- Note: if creating a token in GitLab, set its Role to at least Developer; Guest will not work.
- Create the following secrets in your secrets provider
  - Note: For Azure Key Vault, follow [this guide](https://learn.microsoft.com/en-us/azure/key-vault/secrets/multiline-secrets) for creating multi-line secrets.
  - ingress-tls-crt
  - ingress-tls-key
  - htpasswd-file
  - ldap-bind-dn
  - ldap-bind-password
- Create a service account with access to your secrets provider
- Create the following additional secrets if one of these services is used
  - px-pure-api-key (Used for Pure storage)

## Install Argo CD

Apply the kustomize to install Argo CD. **WARNING:** do NOT pre-create the `openshift-gitops` namespace, as this will prevent the operater from installing multiple Argo CD services.

```bash
git clone https://gitlab.com/ignw1/internal/labs/presales-lab/applicationmodernization/ocp_poc.git
cd ocp_poc
ENVIRONMENT=<MY-ENVIRONMENT>
oc apply -k 3_gitops_deploy/argocd/overlays/$ENVIRONMENT
```

You will see a few errors related to the namespace not being created yet - that's OK.

```
clusterrole.rbac.authorization.k8s.io/openshift-gitops-create-global-resources unchanged
clusterrolebinding.rbac.authorization.k8s.io/openshift-gitops-create-global-resources unchanged
subscription.operators.coreos.com/openshift-gitops-operator created
Error from server (NotFound): error when creating "argocd/overlays/poc/": namespaces "openshift-gitops" not found
Error from server (NotFound): error when creating "argocd/overlays/poc/": namespaces "openshift-gitops" not found
Error from server (NotFound): error when creating "argocd/overlays/poc/": namespaces "openshift-gitops" not found
Error from server (NotFound): error when creating "argocd/overlays/poc/": namespaces "openshift-gitops" not found
```

## Apply the initial Argo CD Git credential

Make sure OpenShift GitOps controller shows Successful.
```bash
oc describe sub openshift-gitops-operator -n openshift-operators | grep Conditions -A5
```
It should look like this:
```
  Conditions:
    Last Transition Time:   2023-09-12T01:04:02Z
    Message:                all available catalogsources are healthy
    Reason:                 AllCatalogSourcesHealthy
    Status:                 False
    Type:                   CatalogSourcesUnhealthy
```

Create a secret for your Git credential, label it for Argo CD, and then re-apply the kustomize to finish the install.

```bash
oc create secret generic cluster-config-git -n openshift-gitops \
  --from-literal=url=https://gitlab.com/my-example-group/my-example-cluster.git \
  --from-literal=type=git \
  --from-literal=password=topsecret \
  --from-literal=username=supersecret

oc label secret cluster-config-git -n openshift-gitops argocd.argoproj.io/secret-type=repository

oc apply -k 3_gitops_deploy/argocd/overlays/$ENVIRONMENT
```

## Apply the initial secret provider credential

##### Azure Key Vault example

```bash
# Use the `appId` and `password` from the output of when you created your Service Principal.

oc create secret generic external-secrets-azure -n external-secrets \
  --from-literal=ClientID=$APP_ID \
  --from-literal=ClientSecret=$PASSWORD
```

##### AWS Secrets Manager example
```bash
oc create secret generic external-secrets-aws -n external-secrets \
  --from-literal=ClientID=$AWS_ACCESS_KEY_ID \
  --from-literal=ClientSecret=$AWS_SECRET_ACCESS_KEY
```




## Optional: Install Kustomize on bastion host
https://kubectl.docs.kubernetes.io/installation/kustomize/

Red Hat OpenShift includes kuztomize as sub command for oc.  
<b>Ex: </b>  oc kustomize --enable-helm blah/overlays/ocpprod/ | oc apply -f - 


```
curl -s "https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh"  | bash
sudo mv kustomize /usr/local/bin/
kustomize build 3_gitops_deploy/storage-nfs/base/  # test if it works :)
```