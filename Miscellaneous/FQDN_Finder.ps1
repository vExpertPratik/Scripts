#This will allow you to identify the respective domain name of the server

$Servers = Get-Content -Path "<Path of the TXT file which contains list of server>"
$Array = @()
 
Foreach($Server in $Servers)
{
    $DNSCheck = $null
    $Server = $Server.trim()
 
    $DNSCheck = ([System.Net.Dns]::GetHostByName(("$Server")))
 
    $Object = New-Object PSObject -Property ([ordered]@{ 
      
                "Server name"             = $Server
                "FQDN"                    = $DNSCheck.hostname
                "IP Address"              = $DNSCheck.AddressList[0]
 
    })
   
    # Add object to our array
    $Array += $Object
 
}
$Array
$Array | Export-Csv -Path "<Path of the CSV file which will save the output of the script>" -NoTypeInformation