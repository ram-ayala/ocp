# How to cleanly tear down Openshift Deployment



### IPI Tear down


```
[ocpprod@osinstall openshift]$ cluster=ocpprod
[ocpprod@osinstall openshift]$ cd /home/core/$cluster
[root@osinstall os01]# ./openshift-install destroy cluster
INFO Destroyed                                     VirtualMachine=ocpprod-p26c2-rhcos
INFO Destroyed                                     VirtualMachine=ocpprod-p26c2-master-0
INFO Destroyed                                     VirtualMachine=ocpprod-p26c2-master-2
INFO Destroyed                                     VirtualMachine=ocpprod-p26c2-bootstrap
INFO Destroyed                                     VirtualMachine=ocpprod-p26c2-master-1
INFO Time elapsed: 1m34s
[root@osinstall os01]#


```


### Clean out DHCP leases if you have multiday and or set to long term leases

