This folder is about how to deploy and use a NetApp OnTap storage array with all protcol types
#  Documentation: https://docs.netapp.com/us-en/astra-control-service/get-started/add-private-self-managed-cluster.html

# Video https://docs.netapp.com/us-en/netapp-solutions/containers/rh-os-n_videos_and_demos.html

I think there are two paths here for deployment.  Astra which offers more "public cloud integration" but seems light on how to manage on prem.   Vs  Trident which is focused on prem.


Issue:
1) Astra seems to be framework but workflow on how to setup is not clear  https://docs.netapp.com/us-en/netapp-solutions/containers/tanzu_with_netapp/vtwn_overview_trident.html
2) Operator deployment with CI vs UI is also not clear or even documented
3) Need to work out how to save and reteave secrets for storage for consumption from keyvault
