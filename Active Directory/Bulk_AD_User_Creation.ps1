#First create the CSV file with columns DisplayName, SamAccountName, EmailAddress, Phone, Department, Title, Company, Password, OU, officephone and UserPrincipalName (Username@FQDN of Domain).

$users = Import-Csv -Path "<Path and Name of the CSV File>" 
Foreach ($user in $users)
{
    $gn = $user.DisplayName
    $san = $user.SamAccountName
    $mail = $user.EmailAddress
    $Phone = $user.Phone
    $dept = $user.Department
    $title = $user.Title
    $company = $user.Company
    $pass = $user.Password
    $ou =$user.OU
    $officephone = $user.officephone
    $upn = $user.UserPrincipalName
    
    
    

    New-ADUser -SamAccountName $san -Name $gn -DisplayName $gn -GivenName $gn -Enabled $True -EmailAddress $mail -MobilePhone $Phone -OfficePhone $officephone -Department $dept -Title $title -Company $company -UserPrincipalName $upn -Path $ou -AccountPassword (convertto-securestring $pass -AsPlainText -Force) -ChangePasswordAtLogon $False
}



#============================================================================================================================================================================#

#To set Password related policies on respective AD Account

$users = Get-Content "<TXT File containing the Usernames>"

foreach ($user in $users)
{
    Get-ADUser $user | Set-ADUser -CannotChangePassword:$false -PasswordNeverExpires:$false -ChangePasswordAtLogon:$true
}


#============================================================================================================================================================================#

#To set the password expiration on the respective AD Account

$days = Get-Date
$ex = $days.AddDays(365) #This will set 1 year password expiry
$users = get-content -Path "<Path of the TXT File which contains respective accounts>"
foreach($user in $users){Set-ADAccountExpiration $user -DateTime $ex}
