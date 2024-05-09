#This script will enable the processor compatibility for live migration.
#Execution of this script will requires downtime as it will power off the VM and perform the CPU compatibility changes

#Get the list of VMs
Get-VM | Select-Object -ExpandProperty Name | Sort-Object | Set-Content "<Path of the TXT file 1 which will save the output of the script>"

#Get the list of VMs which include name and the powerstate of the VMs
Get-VM | Select-Object Name, State | Sort-Object | Out-File "<Path of the TXT file 2 which will save the output of the script>"


$vms = Get-Content -Path "<Path of the TXT file 1 in which the output of the script is saved>"
foreach($vm in $vms)
{
    $vm
    Stop-VM -Name $vm -Force
    Set-VMProcessor $vm -CompatibilityForMigrationEnabled $true
    Start-VM -Name $vm
}