#This will allow you to copy the file on the remote computer from source computer

$computers = Get-Content -Path "<Path of the TXT file which contains list of server>"
foreach($computer in $computers)
{
    $computer
    $session = New-PSSession –ComputerName $computer
    Get-ChildItem -Path "<SRC_Location>" | Copy-Item –Destination '<Destination_Location>' -Recurse –ToSession $session
    $session | Remove-PSSession
}