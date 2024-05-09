#This script will allow you to add the domain user in local group

$servers = Get-Content "<Path of the TXT file which contains list of servers>"
$UserName = "<Username of the Domain Account>"
$DomainName = "<Domain Name>"

"Name`tStatus" | Out-File -FilePath "<Path of the TXT file which will save the output of the script>"
foreach ($server in $servers){
 try{
  $adminGroup = [ADSI]"WinNT://$server/Administrators" #The last part of this cmdlet will decide the group name (For eg., Administrators)
  $adminGroup.add("WinNT://$DomainName/$UserName")
  "$server`tSuccess"
  "$server`tSuccess" | Out-File -FilePath "<Path of the TXT file which will save the output of the script>" -Append
 }
 catch{
  "$server`t" + $_.Exception.Message.ToString().Split(":")[1].Replace("`n","")
  "$server`t" + $_.Exception.Message.ToString().Split(":")[1].Replace("`n","") | Out-File -FilePath "<Path of the TXT file which will save the output of the script>" -Append
 }
}