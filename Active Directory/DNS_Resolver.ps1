#This script will allow you to perform quick health check on DNS resolution

$domains = @('Domain1','Domain2', 'Domain3', 'Domain4', 'Domain5')
$servers = Get-Content -Path "<Path of TXT file which contains List of DNS servers>"

$FinalResult = @()
foreach($domain in $domains)
{
    foreach($server in $servers)
    {
        $tempObj = "" | Select-Object Name, Domain, IPAddress,Status,ErrorMessage    
	    try 
	    {
            $dnsRecord = Resolve-DnsName $domain -Server $server -ErrorAction Stop
            $tempObj.Name = $server
            $tempObj.Domain = $domain
            $tempObj.IPAddress = ($dnsRecord.IPAddress -join ',')        
            $tempObj.Status = 'OK' 
            $tempObj.ErrorMessage = ''    
        }
        catch
        {        
            $tempObj.Name = $server
            $tempObj.Domain = $domain
            $tempObj.IPAddress = ''
            $tempObj.Status = 'NOT_OK'
            $tempObj.ErrorMessage = $_.Exception.Message    
        }    
        $FinalResult += $tempObj
    }
}

return $FinalResult | Export-Csv -Path "<Path and File name of CSV file in which result will be stored>" -NoTypeInformation