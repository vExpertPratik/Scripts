#This script will get the server and account list and verify whether the respective account is present on the server or not.
#Get-CimInstance Win32_UserAccount -Filter "name = '<Account1>' OR name = '<Account2>' OR name= '<Account3>'" -ComputerName <Server Name> | Select-Object PSComputerName, Name, Disabled, Caption

$servers = Get-Content -Path "<Server FQDN TXT File>"
$accounts = @("Account1", "Account2", "Account3", "Account4", "Account5", "Account6")
foreach($server in $servers)
{
    Write-Host "Currently working on the server $server" -BackgroundColor White -ForegroundColor Black
    try
    {
        $instance = [ADSI]"WinNT://$server"   #[ADSI]"WinNT://<Server FQDN>"
        $users = $instance.Children | Where {$_.SchemaClassName -eq 'user'}
    
        if($users)
        {
            if($users -in $accounts)
            {
                Write-Host "Username is Present locally on server $server." -BackgroundColor Green -ForegroundColor Black

                $users | Select-Object @{name="Computername";Expression={$server}},
                    @{name="User";Expression={$_.psbase.properties.name.value}},
                    @{Name="Description";Expression={$_.psbase.properties.description.value}} | Export-Csv -Path "<CSV File Path and Name>" -Append -NoTypeInformation
                    #@{name="Enabled";Expression={if ($_.psbase.properties.item("userflags").value -band $ADS_UF_ACCOUNTDISABLE) {$False} else {$True}}}

                Write-Host "Fetched all the local users present on the server $server." -BackgroundColor Green -ForegroundColor Black
            }
            else
            {
                Write-Host "Username is not present locally on server $server." -BackgroundColor Red -ForegroundColor White

                $users | Select-Object @{name="Computername";Expression={$server}},
                    @{name="User";Expression={$_.psbase.properties.name.value}},
                    @{Name="Description";Expression={$_.psbase.properties.description.value}} | Export-Csv -Path "<CSV File Path and Name>" -Append -NoTypeInformation
                    #@{name="Enabled";Expression={if ($_.psbase.properties.item("userflags").value -band $ADS_UF_ACCOUNTDISABLE) {$False}else {$True}}}

                Write-Host "Fetching all the local users present on the server $server." -BackgroundColor Green -ForegroundColor Black
            }
        }
        else
        {
            Write-Host "Unable to connect to the server $server." -BackgroundColor Red -ForegroundColor White
            $notabletoconnect = New-Object PsObject -Property @{Server = "$server"; Error = "Unable to connect to the server."}
            Export-Csv -Path "<CSV File Path and Name for Errors>" -InputObject $notabletoconnect -Append -Force -NoTypeInformation
            #"{0},{1}" -f $server,"Unable to connect to the server." | Add-Content -path "D:\temp\Pratik\test\LocalUserDetails.csv"
            #Select-Object @{Name="Server"; Expression={$server}}, @{Name="Users"; Expression={}} | Export-Csv -Path "<CSV File Path and Name for Errors>" -Append -NoTypeInformation
        }
    }
    catch
    {
        Write-Warning $Error[0]
        $runtimeerror = New-Object PsObject -Property @{Server = "$server"; Error = "$Error[0]"}
        Export-Csv -Path "<CSV File Path and Name for Errors>" -InputObject $runtimeerror -Append -Force -NoTypeInformation
        #Select-Object @{Name="Server"; Expression={$server}}, @{Name="Error"; Expression={$Error[0]}} | Export-Csv -Path "<CSV File Path and Name for Errors>" -Append -NoTypeInformation
    }
}