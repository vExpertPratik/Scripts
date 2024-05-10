#This script will allow you to create the Active directory users with UNIX Attributes for Unix integration with AD
#First create a CSV file with column name as SamAccountNAme, Password, Description, OU, gidNumber, uid, uidNumber
$users = Import-Csv -Path "<Path of the CSV File which cotains all the details>"
foreach($user in $users)
{
    try
    {
        $san = $user.SamAccountName
        $pass = $user.Password
        $des = $user.Description
        $ou = $user.OU
        $gid = $user.gidNumber
        $uidname = $user.uid
        $uid = $user.uidNumber


        New-ADUser -SamAccountName $san -Name $san -DisplayName $san -GivenName $san -Description $des -Path $ou `
        -AccountPassword (ConvertTo-SecureString $pass -AsPlainText -Force) -ChangePasswordAtLogon $False -PasswordNeverExpires $True -Enabled $True


			Clear-ADAccountExpiration -Identity $san
        Set-ADUser -Identity $san -Replace @{mssfu30nisdomain = '<NetBIOS Name of Domain>'}
        Set-ADUser -identity $san -Replace @{gidnumber=$gid ; uid=$uidName ; uidnumber=$uid ; loginShell = "/bin/bash" ; unixHomeDirectory="/home/$san"}
    }
    catch
    {
        Write-Warning $Error[0]
    }
}	
