#If scheduled in the Task scheduler then, this script will allow you to notify set of users about the password expiry before 10, 5 and 1 days

$users = Get-Content -Path "<Path of the TXT file which contains list of users>"


$ten = (get-date).adddays(10).ToLongDateString()
$five = (get-date).adddays(5).ToLongDateString()
$one = (get-date).adddays(1).ToLongDateString()


$from    =  'PE-Notification@larsentoubro.com'
$cc      =  "<Email ID 1>, <Email ID 2>" #Update the Email IDs here
$subject =  'Service Account Password Expiry Notification'
$EmailStub1 = 'This mail is to inform you that the password for Service Account :- '
$EmailStub2 = 'will expire in'
$EmailStub3 = 'days on'
$EmailStub4 = '<br><b>Request you to get the needful done to reset the password of the mentioned Service Account.</b>' 
$EmailStub5 = '<br>***** This is auto generated mail so please DO NOT REPLY TO THIS EMAIL. *****'




foreach($user in $users)
{   

    $account = Get-ADUser $user -Properties "Name", "SamAccountName", "EmailAddress", "msDS-UserPasswordExpiryTimeComputed" | Select-Object -Property "Name", "SamAccountName", "EmailAddress", @{Name = "PasswordExpiry"; Expression = {[datetime]::FromFileTime($_."msDS-UserPasswordExpiryTimeComputed").tolongdatestring() }}

    if ($account.PasswordExpiry -eq $ten -and $account.PasswordExpiry -ne "")
    {
        $days = 10
        $to      =  $account.EmailAddress
        $accountName = $account.SamAccountName

        $body    =  "<hr>", "<br>", $EmailStub1, "<b>$accountName</b>", $EmailStub2, "<b>$days</b>", $EmailStub3, "<b><u>$ten.</u></b>", $EmailStub4, "<hr>", $EmailStub5 -join ' '
 
        $mail = New-Object System.Net.Mail.Mailmessage $from, $to, $subject, $body
        $mail.CC.Add($cc)
        $mail.IsBodyHTML=$true
        
        $server = "<SMTP Server Details>" #Update the SMTP Server details here
        $port   = 25
        $Smtp = New-Object System.Net.Mail.SMTPClient $server,$port

        $smtp.send($mail)
    }

    elseif ($account.PasswordExpiry -eq $five -and $account.PasswordExpiry -ne "")
    {
        $days = 5
        $to      =  $account.EmailAddress
        $accountName = $account.SamAccountName

        $body    =  "<hr>", "<br>", $EmailStub1, "<b>$accountName</b>", $EmailStub2, "<b>$days</b>", $EmailStub3, "<b><u>$five.</u></b>", $EmailStub4, "<hr>", $EmailStub5 -join ' '
 
        $mail = New-Object System.Net.Mail.Mailmessage $from, $to, $subject, $body
        $mail.CC.Add($cc)
        $mail.IsBodyHTML=$true
        
        $server = "<SMTP Server Details>" #Update the SMTP Server details here
        $port   = 25
        $Smtp = New-Object System.Net.Mail.SMTPClient $server,$port

        $smtp.send($mail)
    }

    elseif ($account.PasswordExpiry -eq $one -and $account.PasswordExpiry -ne "")
    {
        $days = 1
        $to      =  $account.EmailAddress
        $accountName = $account.SamAccountName

        $body    =  "<hr>", "<br>", $EmailStub1, "<b><u>$accountName</u></b>", $EmailStub2, "<b>$days</b>.", $EmailStub3, "<b><u>$one.</u></b>", $EmailStub4, "<hr>", $EmailStub5 -join ' '
 
        $mail = New-Object System.Net.Mail.Mailmessage $from, $to, $subject, $body
        $mail.CC.Add($cc)
        $mail.IsBodyHTML=$true
        
        $server = "<SMTP Server Details>" #Update the SMTP Server details here
        $port   = 25
        $Smtp = New-Object System.Net.Mail.SMTPClient $server,$port

        $smtp.send($mail)
    }
}
