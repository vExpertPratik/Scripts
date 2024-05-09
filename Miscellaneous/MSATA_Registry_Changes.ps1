#This script will make the registry changes after taking the backup of the registry
$comps = Get-content -Path "<Path of the TXT file which contains list of server>"
foreach($comp in $comps)
{
    $comp
    Invoke-Command -ComputerName $comp -ScriptBlock {mkdir C:\REGBackup; reg export HKCR C:\REGBackup\HKCR.Reg /y; reg export HKCU C:\REGBackup\HKCU.Reg /y; reg export HKLM C:\REGBackup\HKLM.Reg /y; reg export HKU C:\REGBackup\HKU.Reg /y; reg export HKCC C:\RegBackHKCC.Reg /y;}
    Invoke-Command -ComputerName $comp -ScriptBlock {Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\.NETFramework\v4.0.30319" -Name "SystemDefaultTlsVersions" -Value 00000001 -Type "DWORD";
Set-ItemProperty -Path "HKLM:\SOFTWARE\Wow6432Node\Microsoft\.NETFramework\v4.0.30319" -Name "SystemDefaultTlsVersions" -Value 00000001 -Type "DWORD";
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\.NETFramework\v4.0.30319" -Name "SchUseStrongCrypto" -Value 00000001 -Type "DWORD";
Set-ItemProperty -Path "HKLM:\SOFTWARE\Wow6432Node\Microsoft\.NETFramework\v4.0.30319" -Name "SchUseStrongCrypto" -Value 00000001 -Type "DWORD";}
}