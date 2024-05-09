#This will allow you to verify the domain trust health

Get-CimInstance -Class Microsoft_DomainTrustStatus -Namespace root\microsoftactivedirectory
Test-ComputerSecureChannel
#============================================================================================================================================================================#
#This will allow you to find the hostname of the server

$servers = Get-Content -Path "C:\Patch\ID Removal\Jash_Servers.txt"

foreach($server in $servers)
{
    $server
    Get-WmiObject Win32_OperatingSystem -ComputerName $server | select-object @{Name = 'IP Address'; Expression={$server}}, PSComputerName, CSName, Caption | Export-Csv "<Path of the CSV file which will save the output of the script>" -Append
}

#============================================================================================================================================================================#