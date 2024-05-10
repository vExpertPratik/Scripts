#This PowerCLI Script will allow you to fetch datastore name, NAA ID, Runtime Name (LUN Details), HBA MAC of all the available datastores mapped with respective ESXi Host
#Get-VMHost vaaesxbufl84.apdc.mgmt.axa-tech.intraxa | Get-Datastore | Get-ScsiLun | Select-Object -Property *

Add-PSSnapin VMware.VimAutomation.Core
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Connect-VIServer "<vCenter1>"
$datastores = (Get-VMHost "<ESXi Hostname>" | Get-Datastore).Name
foreach($datastore in $datastores)
{
    Get-Datastore $datastore | Get-ScsiLun | Get-ScsiLunPath | Select-Object -Property `
    @{N="Datastore"; E={$datastore}}, @{N="NAA ID"; E={$ScsiLun}}, @{N="Runtime Name"; E={$_.LunPath}}, @{N="HBA MAC"; E={$_.SanId}} | Export-Csv -Path "<Path of CSV File in which script output will be stored>"
}