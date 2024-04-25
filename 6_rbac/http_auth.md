# This is how to use basic HTTP authentication files for Role Bindings using local accounts.

## Steps for Deployment  - Choose one from below

- [ ] [Local Groups and Users](#Local-Groups-and-Users)
- [ ] [Create Groups and Users](#Create-Groups-and-Users])
- [ ] [RBAC](#RBAC)
- [ ] [Validate Login to SuSE](#Validate-Login-to-SuSE])

Customer must fill out all items in <span style="color:red">RED </span> to complete site prerequisit documentation before schedule start of services.

<br>

------------- 

## <span style="color:green"><b> Local Groups and Users</b></span>

<br>

Workflow for a new applcation would create a test set of local users and place them into groups to demonstrate example role bindings and control by group to a project / namespace

Ex:  TestApp01  New Project

| <span style="color:gold"> Local User </span> | <span style="color:gold"> Local Group </span> | <span style="color:gold">Notes / Details</span> |
| :--------------- | :--------------- | :--------------- |
| <span style="color:red">TestApp01_admin1 |<span style="color:red"> TestApp01_admin | test admin account in group for admin tasks for application |
| <span style="color:red">TestApp01_admin2 |<span style="color:red"> TestApp01_admin | Second test admin account in group for admin tasks for application |
| <span style="color:red">TestApp01_dev1 |<span style="color:red"> TestApp01_dev | test developer account in group for developers tasks for application |
| <span style="color:red">TestApp01_dev1 |<span style="color:red"> TestApp01_dev | Second test developer account in group for developers tasks for application |
| <span style="color:red">ocpadmin1 |<span style="color:red"> ocp_admin | Second test developer account in group for developers tasks for application |

**Red above is customer to fill in for there customization / example

<br>

------------- 

## <span style="color:green"><b> Create Example Groups and Users</b></span>

<br>

Create Groups

```
oc adm groups new TestApp01_admin
oc adm groups new TestApp01_dev
oc adm groups new ocp_admin
```

<br>

Create Users and bind to groups 

```
oc adm groups add-users TestApp01_admin TestApp01_admin1 TestApp01_admin2
oc adm groups add-users TestApp01_dev TestApp01_dev1 TestApp01_dev2
oc adm groups add-users ocp_admin ocpadmin1

```

## Binding within Openshift

Bind Groups to roles within cluster.  Ex:  Ability to publish to Image Registry.  And also admins of cluster

```
oc policy add-role-to-user registry-viewer TestApp01_dev
oc policy add-role-to-user registry-editor  TestApp01_admin
oc adm policy add-cluster-role-to-group basic-user  ocp_admin devimagecreator devimagereader 
oc adm policy add-cluster-role-to-group cluster-admin  ocp_admin
```

## Set user Passwords

vi /home/core/rbac/htpasswd  # Password can be set by user or  default to same password as kubeadmin

```
htpasswd -Bb htpasswd ocpadmin1 CDW@1lab
htpasswd -Bb htpasswd ocpadmin2 CDW@1lab
htpasswd -Bb htpasswd ocpuser1 CDW@1lab
htpasswd -Bb htpasswd ocpuser2 CDW@1lab
htpasswd -Bb htpasswd devimagereader CDW@1lab
htpasswd -Bb htpasswd devimagecreator CDW@1lab

```

Apply passwords to users

```
oc --user=admin create secret generic htpasswd --from-file=/home/core/rbac/htpasswd -n openshift-config secret/htpasswd created
```

## Testing


```


```


<br>

## Audit and Logging

