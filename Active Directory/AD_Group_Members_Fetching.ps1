#This will allow you to store all the member users of the respective AD Group

$Table = @()

$Record = [ordered]@{
"Group Name" = ""
"Name" = ""
"Username" = ""
}

$Groups = Get-Content "<Path of the TXT file in which group names will be present>"

Foreach ($Group in $Groups)
{

$Arrayofmembers = Get-ADGroupMember -identity $Group | select name,samaccountname

foreach ($Member in $Arrayofmembers)
{
$Record."Group Name" = $Group
$Record."Name" = $Member.name
$Record."UserName" = $Member.samaccountname
$objRecord = New-Object PSObject -property $Record
$Table += $objrecord

}

}

$Table | export-csv "<Path and Name of the CSV in which the result will be saved>" -NoTypeInformation