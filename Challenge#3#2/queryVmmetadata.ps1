<#

  The Azure Instance Metadata Service (IMDS) provides information about currently running virtual machine instances.
  You can use it to manage and configure your virtual machines. This information includes the SKU, storage,
  network configurations, and upcoming maintenance events.

   For getting the metadata information you need to execute this script from the inside of your Vm instance.

#>

$Vm_metadata=Invoke-RestMethod -Headers @{"Metadata"="true"} -Method GET -NoProxy -Uri "http://169.254.169.254/metadata/instance?api-version=2021-02-01" | ConvertTo-Json -Depth 64

#for getting network information query
$network= $Vm_metadata.network

#for  getting storage profile information query
$network=$Vm_metadata.compute.storageProfile

#for getting compute information query simply
$Vm_metadata.compute