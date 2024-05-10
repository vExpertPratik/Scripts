#This script will allow you to create the Active directory users with UNIX Attributes for Unix integration with AD
#First create a CSV file with column name as SamAccountNAme, Description, gidNumber
$groups = Import-Csv -Path "<Path of the CSV File which cotains all the details>"
foreach($group in $groups)
{
    try
    {
        $san = $group.SamAccountName
        $des = $group.Description
        $gid = $group.gidNumber


        New-ADGroup -Name $san -GroupCategory Security -GroupScope Global -Description $des
        Set-ADGroup -SamAccountName $san -Replace @{msSFU30NisDomain = '<NetBIOS Name of Domain>' ; gidnumber=$gid} 

    }
    catch
    {
        Write-Warning $Error[0]
    }
}