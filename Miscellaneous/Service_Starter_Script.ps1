#Method to restart the services and set the startup type of the remote server

$computers = Get-Content -Path "<Path of the TXT file which contains list of server>"
foreach($computer in $computers)
{
    $computer
    Get-Service -Name vds, VSS -ComputerName $computer | Set-Service -Status Running
    Get-Service -Name vmvss -ComputerName $computer | Set-Service -StartupType Disabled
}


#============================================================================================================================================================================#

#Alternate method to restart the services and set the startup type of the remote server


$computers = Get-Content -Path "<Path of the TXT file which contains list of server>"
foreach($computer in $computers)
{
    $computer
    $service = Get-Service -Name nxlog -ComputerName $computer
    $service.Stop()
    $service.Start()
    #$service.Refresh()
    Get-Service -Name nxlog -ComputerName $computer | Set-Service -StartupType Automatic
}