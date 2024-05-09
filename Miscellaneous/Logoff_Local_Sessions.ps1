#This will allow you to logoff the specific user session from the multiple servers remotely

$ComputerName =  Get-Content -Path "<Path of the TXT file which contains list of server>"
	foreach ($Computer in $ComputerName) {
		try {
			quser /Server:$Computer | Select-Object -Skip 1 | ForEach-Object {
				$CurrentLine = $_.Trim() -Replace '\s+', ' ' -Split '\s'
				$UserName = $CurrentLine[0]
				$UserID = $CurrentLine[1]
				$UserActivity = $CurrentLine[2]
				
				# If session is disconnected, all processes will be closed and the user logged out
				if ($UserName -match "sysadmin-l1" #Username can be mentioned here) {
					Write-Warning "Logging off user $UserName"
					Invoke-RDUserLogoff -HostServer $Computer -UnifiedSessionId $UserID -Force
				}
			}
		}
		catch {
			Write-Warning "Error occured - $($_.Exception.Message)"
		}
	}


QUser /server:192.168.193.189