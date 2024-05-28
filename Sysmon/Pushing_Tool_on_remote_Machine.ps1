#This Script will help to install the Sysmon agent on multiple server remotely

$DCs = Get-Content -Path "<Path of the TXT file which contains list of server>"

foreach($DC in $DCs)
{  
    $DC
    $session = New-PSSession -ComputerName $DC
    Invoke-Command -Session $session -ScriptBlock{
	    $Foldername = "<Folder path of destination server (for e.g., C:\sysmon)>";
            if (Test-Path $Foldername) 
                {
                    Write-Host "Folder was present & We are deleting the same"
                    Remove-Item $Foldername -Recurse
                }
                else
                {
                   Write-Host "Folder is not present, We are proceeding further"
                };
            Get-ChildItem -Path '<Path in which the installers are located>' | Copy-Item –Destination 'C:\' -Recurse;
            cd C:\Sysmon;
            C:\Sysmon\Sysmon.exe -i -accepteula;
            C:\Sysmon\Sysmon.exe -c C:\Sysmon\sysmonconfig-export.xml;
            Remove-Item 'C:\Sysmon' -Recurse;
        }
    $session | Remove-PSSession
}
