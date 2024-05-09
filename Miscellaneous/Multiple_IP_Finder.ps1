#This will allow you to fetch all the available IPs of the servers With WMI Object calling method

$computer = Get-Content -Path "<Path of the TXT file which contains list of server>"
foreach($co in $computer)
{
    $co
    Get-WmiObject win32_networkadapterconfiguration -filter "ipenabled = 'True'" -ComputerName $co |
    Select PSComputername,
    @{Name = "IPAddress";Expression = {
    [regex]$rx = "(\d{1,3}(\.?)){4}"
    $rx.matches($_.IPAddress).Value}},MACAddress | Export-csv -Path "<Path of the CSV file which will save the output of the script>" -Append
}

#============================================================================================================================================================================#
#This will allow you to fetch all the available IPs of the servers With CIM Session method

$Computers = Get-Content -Path "<Path of the TXT file which contains list of server>"

foreach($computer in $Computers)
{
    Get-NetIPAddress -CimSession $computer -AddressFamily IPv4  | Where {$_.InterfaceAlias -notmatch 'Loopback' } |
    select PSComputername, IPAddress, @{Name = "MACAddress"; Expression = {($_ | Get-NetAdapter).MacAddress}} | Export-csv -Path "<Path of the CSV file which will save the output of the script>" -Append
}
