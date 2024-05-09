#First fetch the group members (all the server name) using below command
(Get-ADGroup <gMSA Group Name> -Properties *).members | ForEach-Object {
    $comp = (Get-ADObject $_ -Properties *).Name
    $comp | Out-File -Append "<Path and File name to store group member server names in TXT File>"}


#============================================================================================================================================================================#
#Now we will remotely check whether the respective target servers are reflecting the new group membership using gpresult /r output


$computers = Get-Content -Path "<Path and File name of the TXT File in which all the server names are stored>" 
$result = foreach($computer in $computers)
{
    Invoke-Command -ComputerName $computer -ScriptBlock {
        $gpr = (gpresult /r).split("
        ")
        if (($gpr -match "SQLgMSAUNVRGRP") -or ($gpr -match "SQLgMSACorpGRP"))
        {
            $status = "Membership updated"
        }
        else
        {
            $status = "Membership is not updated for"
        }
        [PSCustomObject]@{
	Server = $computer
        Status = $status
        }
    }
}
$result | Export-Csv -Path "<Path and File name to store the result in CSV File>" -NoTypeInformation