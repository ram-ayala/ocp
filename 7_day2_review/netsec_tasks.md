#  Day 2 Tasks that typically fall within scope of Network and Security Team



- [ ] [Image Registry Control](#Image-Registry-Control)
- [ ] [Logs and Audit](#Logs-and-Audit])
- [ ] [Ingress Control](#Ingress-Control)
- [ ] [Build and Code Scan](#Build-and-Code-Scan])
- [ ] [Side Cars](#Side-Cars])
- [ ] [Servce Mesh](#Servce-Mesh])


This section is a review of the cluster deployment state from perspective of the Developer's Post deployment optimization tasks


<br>

------------- 

## <span style="color:green"><b>Image Registry Control</b></span>

<br>


<br>

------------- 

## <span style="color:green"><b>Logs and Audit</b></span>

<br>


------------- 

## <span style="color:green"><b>Ingress Control</b></span>

<br>



------------- 

## <span style="color:green"><b>Build and Code Scan</b></span>

<br>


------------- 

## <span style="color:green"><b>Side Cars</b></span>

<br>



------------- 

## <span style="color:green"><b>Servce Mesh</b></span>

<br>

------------- 

## <span style="color:green"><b>etcd Encryption</b></span>

### References
  - https://docs.openshift.com/container-platform/4.11/security/encrypting-etcd.html

### 1. Enabling Encryption
```
oc patch apiserver -p '{"spec":{"encryption":{"type":"aescbc"}}}'
```

### 2. Check Encruption status
This can take up-to 20minutes to complete.

The result should show: "EncryptionCompleted"
```
oc get openshiftapiserver -o=jsonpath='{range .items[0].status.conditions[?(@.type=="Encrypted")]}{.reason}{"\n"}{.message}{"\n"}'
```

### 3. Disabling Encruption
To disable/decrypt etcd after encruption has been enabled.
```
oc patch apiserver -p '{"spec":{"encryption":{"type":"identity"}}}'
```

You can check the encryption status again after decrupting it. It should show "DecryptionCompleted"

<br>
