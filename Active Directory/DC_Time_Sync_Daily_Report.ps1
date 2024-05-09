#This script can be scheduled in Task Scheduler which will allow daily update on whether the DC's clock is in Sync or not

$computers = Get-Content -Path "<Path of the TXT file which contains list of server>"
foreach($computer in $computers)
{
    $session = New-PSSession -ComputerName $computer
    $Data = Invoke-Command -Session $session -ScriptBlock{ Get-WmiObject Win32_LocalTime}
    $session | Remove-PSSession
    $Data | Select-Object -Property PSComputerName, Day, Month, Year, WeekInMonth, DayOfWeek, Hour, Minute, Second | Export-Csv -Path "<Path of the CSV file in which output needs to be stored>" -NoTypeInformation -Append
}

$file = "<Path of the CSV file in which output is stored>"

$smtpServer = "<SMTP Server Details>"
$att1 = new-object Net.Mail.Attachment($file)
$msg = new-object Net.Mail.MailMessage
$smtp = new-object Net.Mail.SmtpClient($smtpServer)
$msg.From = "<Any Random Email Address>"
$msg.To.Add("<Receptive recipient email address>")
$msg.Subject = "DC Time Sync Report"
$msg.Body = "Please find attached DC Time Sync Report"
$msg.Attachments.Add($att1)
$smtp.Send($msg)
$att1.Dispose()
rm $file