#This script will fetch the group members of multiple domains (if two way domain trust is enabled)
$domain = Read-Host "`nYou want to fetch the members of which domain : `n`n 1) <Domain 1> `n 2) <Domain 2> `n`nPlease either choos 1 or 2 "

if ($domain -match "1")
{
    Write-Host "`nFetching the group members of domain <Domain 1>" -ForegroundColor Black -BackgroundColor White
    $groups = Get-Content -Path "<Path of the TXT File which contains all the respective Group Names>"
    #$groups
    foreach($group in $groups)
    {
        Write-Host "Fetching details for $group`:`n"
        Get-ADGroupMember $group | Where-Object {$_.objectClass -eq "user"} | Get-ADUser -Properties * | Select @{Name = 'Group Name'; Expression={$group}}, sAMAccountName, Name, Displayname, Description, EmailAddress, Enabled | export-csv -path "<CSV File Path and Name>-$((get-date).ToString('dd-MM-yyyy')).csv" -NoTypeInformation -Append
    }
}
else
{
    Write-Host "`nFetching the group members of domain <Domain 2>" -ForegroundColor Black -BackgroundColor White
    $groups = Get-Content -Path "<Path of the TXT File which contains all the respective Group Names>"
    #$groups
    foreach($group in $groups)
    {
        Write-Host "Fetching details for $group`:`n"
        Get-ADGroupMember $group | Where-Object {$_.objectClass -eq "user"} | Get-ADUser -Properties * | Select @{Name = 'Group Name'; Expression={$group}}, sAMAccountName, Name, Displayname, Description, EmailAddress, Enabled | export-csv -path "<Path of the CSV file in which the output of the script will be stored>-$((get-date).ToString('dd-MM-yyyy')).csv" -NoTypeInformation -Append
    }
}