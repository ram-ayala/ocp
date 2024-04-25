# Role Based binding and control using basic Okta OAuth


## Steps for Deployment  - Choose one from below

- [ ] [Network Communication Requirements](#Network-Communication-Requirements)
- [ ] [Documentation](#Documentation])
- [ ] [Prerequisites - setup TLS certificates](#Prerequisites-setup-TLS-certificates)
- [ ] [Setup Okta for OAuth](#Setup-Okta-for-OAuth])
- [ ] [Setup group sync with Okta](#Setup-group-sync-with-Okta])
- [ ] [Troubleshooting](#Troubleshooting])

Customer must fill out all items in <span style="color:red">RED </span> to complete site prerequisit documentation before schedule start of services.

<br>

------------- 

## <span style="color:green"><b> Network Communication Requirements</b></span>

<br>

Communication from cluster API service VIP out to  https://developer.okta.com/

<br>

## <span style="color:green"><b> Documentation</b></span>

* Users from identity providers get created after the first time they login
* Documentation
	* Really good blog article - follow this
		* <https://cloud.redhat.com/blog/how-to-configure-okta-as-an-identity-provider-for-openshift>
	* Crappy official doc - it's generic and covers all OIDC providers (not specific to Okta), so only use this for looking up fields or troubleshooting
		* <https://docs.openshift.com/container-platform/4.13/authentication/identity_providers/configuring-oidc-identity-provider.html>
	* Group Sync Operator setup
		* <https://mobb.ninja/docs/idp/okta-grp-sync/>

<br>

## <span style="color:green"><b> Prerequisites - setup TLS certificates </b></span>

<br>

* Reference: <https://docs.openshift.com/container-platform/4.13/security/certificates/replacing-default-ingress-certificate.html>


1. Store the CA certificate chain that OpenShift should trust in a ConfigMap
```
oc create configmap custom-ca --from-file=ca-bundle.crt=</path/to/example-ca.crt> -n openshift-config

oc patch proxy/cluster --type=merge --patch='{"spec":{"trustedCA":{"name":"custom-ca"}}}'
```
2. Add a trusted TLS certificate for the OpenShift ingress
	* By default you get a self-signed wildcard certificate for ingress:
		\*.apps.mycluster.example.com
		
	* The secret name can be anything (**ingress-certificate** in this example) - just be sure it matches in both commands
		* If the secret is set to expire, you might want to include the expiry date in the name
```
oc create secret tls ingress-certificate \
--cert=</path/to/cert.crt> \
--key=</path/to/cert.key> \
-n openshift-ingress

oc patch ingresscontroller.operator default \
--type=merge -p \
'{"spec":{"defaultCertificate": {"name": "ingress-certificate"}}}' \
-n openshift-ingress-operator
```
3. Connect to the OpenShift console and make sure that the browser gets the correct TLS certificate


## <span style="color:green"><b> Setup Okta for OAuth </b></span>

* Really good blog article - follow this
	* <https://cloud.redhat.com/blog/how-to-configure-okta-as-an-identity-provider-for-openshift>
1. The blog article walks you through creating a Web app in Okta.
	* Create the URI for the “Login redirect URI” and “Initiate login URI” fields in Okta
	* The `okta` at the end of the URI must match `spec.identityProviders[0].name` in okta-idp.yaml
```
https://oauth-openshift.apps.<cluster-name>.<cluster-domain>/oauth2callback/okta
```
2. From the Web app in Okta you will need
	1. Client ID
	2. Client Secret
	3. Okta URL (usually <https://<company>.okta.com>)
3. Create a K8s secret with the Client Secret
```
oc create secret generic openid-okta-secret --from-literal=clientSecret=6LKCbxG5ZpzAKNyUFsxUFnRv6D4purjnlVnM4ECl -n openshift-config
```
4. Create an OAuth configuration YAML
	* Notes: 
		* You can create this in the UI or follow the [Red Hat documentation](https://docs.openshift.com/container-platform/4.13/authentication/identity_providers/configuring-oidc-identity-provider.html) but in both cases the resulting YAML is missing some of the fields needed for Okta!
		* It's best to use the [blog article](https://cloud.redhat.com/blog/how-to-configure-okta-as-an-identity-provider-for-openshift) noted above, which in includes the extra fields for Okta under `claims` and `extraScopes`
		* If you **_really_** want use the UI, there are the 2 places where you can do it. But be **_sure_** to add the missing fields from the okta-idp.yaml detailed below
			* Administration -> Cluster Settings -> Configuration tab -> OAuth, then under the Identity Providers section, select Okta from the Add drop-down menu.
			* User Management -> Users -> "Add IDP" button, then scroll down to "Identity Providers" and click Add -> OpenID Connect
	* okta-idp.yaml
```
apiVersion: config.openshift.io/v1
kind: OAuth
metadata:
  name: cluster
spec:
  identityProviders:
    - mappingMethod: claim
      name: okta
      openID:
        claims:
          email:
          - email
          name:
          - name
          - email
          preferredUsername:
          - preferred_username
          - email
        clientID: 0oai0uwwCEri5EMEI5d5
        clientSecret:
          name: openid-okta-secret
        extraScopes:
        - email
        - profile
        issuer: https://<company>.okta.com                     
      type: OpenID
```
* The only fields you need to update in this YAML are:
	* clientID
	* issuer
* The `spec.identityProviders[0].name` field value (`okta`) must match URI we provided to Okta in Step 1
* If Okta is self-hosted (not SaaS):
	* I think you will need to store its root CA cert in a new ConfigMap and then add a `spec.identityProviders[0].openID.ca` field to okta-idp.yaml (above) to trust it. 
	* Here are links to the [ca field](https://docs.openshift.com/container-platform/4.13/authentication/identity_providers/configuring-oidc-identity-provider.html#identity-provider-oidc-CR_configuring-oidc-identity-provider) and the [ConfigMag](https://docs.openshift.com/container-platform/4.13/authentication/identity_providers/configuring-oidc-identity-provider.html#identity-provider-creating-configmap_configuring-oidc-identity-provider) format.
5. Apply the OAuth configuration yaml
```
oc apply -f okta-idp.yaml
```


## <span style="color:green"><b> Setup group sync with Okta  </b></span>

* Reference: <https://mobb.ninja/docs/idp/okta-grp-sync/>
1. Create the groups in Okta that you want to sync to OpenShift
	- It's usually good start with OpenShift-Admin group and OpenShift-ReadOnly groups
	- In our case at Kwik Trip we created the groups in Active Directory, and then Erin sync'd them into Okta
2. Install the Group Sync Operator from the OpenShift Operator Hub
	* OpenShift UI -> Operators -> OperatorHub
	* Search for "Group Sync Operator"
	* Install with the default options:
		* namespace = group-sync-operator
		* Update approval = Automatic (you can change this to manual if you want to approve all upgrades)
3. In Okta create an API token with read-only access for syncing group memberships
4. Create a secret with this token
```
oc create secret generic okta-api-token --from-literal='okta-api-token=${API_TOKEN}' -n group-sync-operator
```
5. Create a GroupSync YAML
	* okta-group-sync.yaml
```
apiVersion: redhatcop.redhat.io/v1alpha1
kind: GroupSync
metadata:
  name: okta-sync
spec:
  schedule: "*/1 * * * *"
  providers:
    - name: okta
      okta:
        credentialsSecret:
          name: okta-api-token
          namespace: group-sync-operator
        groups:
          - ocp-admins
          - ocp-restricted-users
        prune: true
        url: https://<company>.okta.com
        appId: <Okta AppID here>
```
<br>

* Fields to modify:
	* **schedule** - enter your preferred cron string. I recommend leaving the default (above) of every minute, until you have successfully verified that syncing is working correctly
	* **groups** - list your groups here
		* in our case at Kwik Trip, these were listed exactly as they appeared in AD
	* **url** - enter the issuer URL from the OAuth resource we create previously
	* **appId** - enter the clientID from the OAuth resource we create previously
6. Apply the GroupSync YAML
	* Be sure to specify the **namespace**! This isn't included in the blog article.
```
oc apply -f okta-group-sync.yaml -n group-sync-operator
```
7. Verify the sync in OpenShift
	* OpenShift UI -> Operators -> Installed Operators -> group-sync-operator -> Group Sync tab -> check the status
	* OpenShift UI -> Groups -> Your Okta Group -> make sure the group members are all here
	* If not, see Troubleshooting, below
8. Create ClusterRoleBindings
```
oc adm policy add-cluster-role-to-group cluster-admin <groupname>
oc adm policy add-cluster-role-to-group cluster-reader <groupname>
```
9. Log into the OpenShift console with a user from the admin group
	* Make sure you can see all the things in OpenShift
	* If not, see Troubleshooting, below
10. After you've verified everything is working, you can change the cron schedule to every hour if you like: `0 * * * *`  . To do this, edit your yaml file and re-apply it.


## <span style="color:green"><b> Troubleshooting </b></span>

* Check OAuth settings from the UI
	*  Administration -> Cluster Settings -> Configuration tab -> OAuth
* Check authentication for problems
	* After a user tries to login, a user should be created, which you can see in the UI
		* OpenShift UI -> User Management -> Users
	* Check for auth errors. Events aren't very reliable, so use the logs:
```
oc get pods -n openshift-authentication
oc logs -n openshift-authentication oauth-openshift-...
```
* If authentication is failing, make sure the clientSecret does not contain extra characters, such as a newline on the end
```
oc get secret -n openshift-config openid-okta-secret -o jsonpath={.data.clientSecret} | base64 -d
```
* If a single user seems to be out of sync, and cannot login, delete their user and identity
	* Afterwards, the should be able to login and have OIDC create a fresh user for them
```
oc get user
oc delete user <username>
oc get identity
oc delete identity <identity>
```
* Check group sync for problems
	* Note: Usually the **manager** container has more useful info than the default **kube-rbac-proxy** container
```
oc get pods -n group-sync-operator
oc logs -n group-sync-operator group-sync-operator-controller-manager-... -c manager
```




