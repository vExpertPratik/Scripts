$names = Get-Content "<Path of the TXT file which contains list of server>" 
        @(foreach ($name in $names) 
            { 
            if ( Test-Connection -ComputerName $name -Count 1 -ErrorAction SilentlyContinue )  
            { 
                $wmi = gwmi Win32_OperatingSystem -computer $name 
                $LBTime = $wmi.ConvertToDateTime($wmi.Lastbootuptime) 
                [TimeSpan]$uptime = New-TimeSpan $LBTime $(get-date) 
                Write-output "$name Uptime is  $($uptime.days) Days $($uptime.hours) Hours $($uptime.minutes) Minutes $($uptime.seconds) Seconds" 
            } 
            else
            { 
                Write-output "$name is not pinging" 
            } 
            }) | Out-file -FilePath "<Path of the CSV file which will save the output of the script>"