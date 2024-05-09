#This is the second file which will allow you to migrate multiple VMs hosted on Hyper-V host
#This script should be run from SCVMM server
#It requires the output file path of the first script "FetchingVM_From_HyperV_Host.ps1" as a input

$Filename = Read-Host "Eneter FQDN from which you want to Transfer the VMs (Source Hyper-V Host)"
$hostname = Read-Host "Enter FQDN on which you want to Receive the VMs (Target Hyper-V Host)"

$computers = Get-Content -path "<Path of the TXT file which was created by first script "FetchingVM_From_HyperV_Host.ps1">"

foreach($computer in $computers){
$vm = Get-SCVirtualMachine -Name $computer
$vmHost = Get-SCVMHost | where { $_.Name -eq "$hostname" }
Move-SCVirtualMachine -VM $vm -VMHost $vmHost -HighlyAvailable $true -RunAsynchronously -UseDiffDiskOptimization | Select ComputerNameString, HostName, Name | Export-Csv -Append -Path "<Path of the CSV file which will save the output of the script>"
}

Remove-Item -Path "<Path of the TXT file which was created by first script "FetchingVM_From_HyperV_Host.ps1">"