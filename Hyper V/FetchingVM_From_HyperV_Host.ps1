#This is the first file which will allow you to enter the Hyper-V host FQDN
#This script should be run from SCVMM server
#After running this script the output file will get generated at the defined location
#Later feed the same location to second file which is "Migration_Of_Multiple_VMs_Hyper-V.ps1" to live migrate multiple VMs

$h= Read-Host -Prompt "Please Type the Host name "

Get-SCVirtualMachine -VMHost "$h" | Select-Object -ExpandProperty Name | Sort-Object | Set-Content "<Path of the TXT file which will save the output of the script>"