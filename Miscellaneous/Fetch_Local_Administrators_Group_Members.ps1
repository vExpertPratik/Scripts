#This script will allow you to fetch all the users of the local administrators group members remotely of multiple servers

$computers = Get-Content -Path "<Path of the TXT file which contains list of server>"

$list = new-object -TypeName System.Collections.ArrayList

foreach ($computer in $computers) {
        $computer
        $admins = Get-WmiObject -Class win32_groupuser -ComputerName $computer | Where-Object {$_.groupcomponent -like '*"Administrators"'} 
        $obj = New-Object -TypeName PSObject -Property @{
            ComputerName = $computer
            LocalAdmins = $null
        }
        foreach ($admin in $admins) {
            $null = $admin.partcomponent -match '.+Domain\=(.+)\,Name\=(.+)$' 
            $null = $matches[1].trim('"') + '\' + $matches[2].trim('"') + "`n"
            $obj.Localadmins += $matches[1].trim('"') + '\' + $matches[2].trim('"') + ';' + "`n"
        }
        $null = $list.add($obj)
    }
    $list | Export-Csv -Path "<Path of the CSV file which will save the output of the script>" -Append -NoTypeInformation