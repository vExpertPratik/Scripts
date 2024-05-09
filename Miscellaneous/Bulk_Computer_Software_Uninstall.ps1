#This will give the installed software containing "HP"

Get-WmiObject -Class Win32_Product -ComputerName <Computer_Name> | where {$_.name -match "HP"}

#============================================================================================================================================================================#
#This will provide all the installed software in Bulk Computers


$computers = Get-Content -Path <Path of the TXT file which contains list of server>

foreach ($computer in $computers)
{
    Write-Host "Processing $computer"
	Get-WmiObject -Class Win32_Product -ComputerName $computer | select ___Server, Name, Version -ErrorAction SilentlyContinue
}



#============================================================================================================================================================================#
#This will uninstall the software "VASCO DIGIPASS Authentication for Windows Logon" from Bulk Computer

$computers = Get-Content -Path <Path of the TXT file which contains list of server>

foreach ($computer in $computers)
{
	Write-Host "Processing $computer"
	$app = Get-WmiObject Win32_Product -ComputerName $computer | where { $_.name -eq "VASCO DIGIPASS Authentication for Windows Logon" }
	$app.Uninstall()
}