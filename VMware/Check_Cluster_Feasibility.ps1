#The first part of the script will allow you to input the VMware vSphere Cluster name and fetch all the storage datastores and network portgroups details mapped to it
#The second part of the script will check whether the Datastores and Portgroups of the VMs and accordingly check the compatibility with the cluster
#The third part of the script will save the output in a file
#RED means datastore and portgroup used by VM is not mapped with respective cluster
#Green means datastore and portgroup used by VM is mapped with respective cluster


[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Set-PowerCLIConfiguration -Scope User -DisplayDeprecationWarnings $false -Confirm:$false
#Disconnect all the active sessions of PowerCLI VI Connections
if($global:DefaultVIServers)
{
    Disconnect-VIServer -Server $global:DefaultVIServers.Name -Confirm:$false
}
cls
Connect-VIServer <vCenter 1>,<vCenter 2>

$table = @()
$arrayofdata = [ordered]@{
"Server" = ""
"Datastore" = ""
"Port Groups" = ""
"Target Cluster" = ""
"Target Cluster Validation (Datastore)" = ""
"Target Cluster Validation (Portgroup)" = ""
}
cls
$targetcluster = Read-Host "Enter the Target Cluster details : (For e.g. <Cluster Name>)"

#FIRST PART
#PG List for target Cluster
Write-Host "`nFetching Network Portgroup Details of the target cluster $targetcluster....Please wait" -BackgroundColor White -ForegroundColor Black
$networkspg = (Get-Cluster $targetcluster).ExtensionData.Network
$pgclusterlist = foreach($networkpg in $networkspg){Get-View $networkpg -Property Name | Select-Object -ExpandProperty Name}
Write-Host "Fetched Network Portgroup Details of the target cluster $targetcluster." -BackgroundColor Green -ForegroundColor Black
 
 
#DS List for target Cluster
Write-Host "`nFetching Datastore Details of the target cluster $targetcluster....Please wait" -BackgroundColor White -ForegroundColor Black
$datastores = (Get-Cluster $targetcluster).ExtensionData.Datastore
$datastorelist = foreach($datastore in $datastores){Get-View $datastore -Property Name | Select-Object -ExpandProperty Name}
Write-Host "Fetched Datastore Details of the target cluster $targetcluster." -BackgroundColor Green -ForegroundColor Black
 

#SECOND PART
$vmnames = Get-Content -Path "<Path of TXT File which contains all the VM which needs to be migrated to above cluster>"
foreach($vmname in $vmnames)
{
    $vm = Get-View -ViewType VirtualMachine -Filter @{'Name' = "$vmname"} -ErrorAction Stop
    $vmDatastores = $vm.Config.DatastoreUrl.Name -join ", "
    $vmPortgroups = (Get-NetworkAdapter -VM "$vmname").NetworkName -join ", "
 
    #Network Porgroup Validation
    Write-Host "`nPerforming Network Validation of the VM $vmname for the target cluster $targetcluster....Please wait" -BackgroundColor White -ForegroundColor Black
    $vmPortgroupsdetails = (Get-NetworkAdapter -VM "$vmname").NetworkName
    foreach($vmPortgroupdetail in $vmPortgroupsdetails)
    {
        if($pgclusterlist -contains "$vmPortgroupdetail")
        {
            Write-Host "Validation successful for network $vmPortgroupdetail, VM can be placed on $targetcluster." -BackgroundColor Green -ForegroundColor Black
            $validationforPG = "GREEN"
        }
        else
        {
            Write-Host "Validation failed for network $vmPortgroupdetail, VM can not be placed on $targetcluster." -BackgroundColor Red -ForegroundColor Black
            $validationforPG = "RED"
        }
    }
 
 
    #Datastore Validation
    Write-Host "`nPerforming Datastore Validation of the VM $vmname for the target cluster $targetcluster....Please wait" -BackgroundColor White -ForegroundColor Black
    $vmDatastoresdetails = $vm.Config.DatastoreUrl.Name
    foreach($vmDatastoresdetail in $vmDatastoresdetails)
    {
        if($datastorelist -contains "$vmDatastoresdetail")
        {
            Write-Host "Validation successful for Datastore $vmDatastoresdetail, VM $vmname can be placed on $targetcluster`n" -BackgroundColor Green -ForegroundColor Black
            $validationforDS = "GREEN"
        }
        else
        {
            Write-Host "Validation failed for Datastore $vmDatastoresdetail, VM $vmname can not be placed on $targetcluster`n" -BackgroundColor Red -ForegroundColor Black
            $validationforDS = "RED"
        }
    }
 
    
    $arrayofdata.Server = $vmname
    $arrayofdata.Datastore = $vmDatastores
    $arrayofdata.'Port Groups' = $vmPortgroups
    $arrayofdata.'Target Cluster' = $targetcluster
    $arrayofdata.'Target Cluster Validation (Datastore)' = $validationforDS
    $arrayofdata.'Target Cluster Validation (Portgroup)' = $validationforPG

 
    $objRecord = New-Object PSObject -Property $arrayofdata
    $table += $objRecord
}
 

#THIRD PART
Write-Host "`nReport is generated on <CSV File Path in which script output will be stored>, Please check." -BackgroundColor White -ForegroundColor Black
 
$table | Export-Csv -Path "<CSV File Path in which script output will be stored>" -NoTypeInformation -Append