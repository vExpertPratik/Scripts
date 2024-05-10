#This script will allow you to create the attribute AD object and map the attribute to AD Users schema
#Please update all the below details appropriately as AD Schema is something which should not be tweaked manually

#AD Schema Update :- https://learn.microsoft.com/en-us/answers/questions/888296/custom-attribute-not-show-in-aduc-and-powershell
#HOL-2281-01-HBD
Import-Module ActiveDirectory
$schemaPath = (Get-ADRootDSE).schemaNamingContext
$attributes = @{
      lDAPDisplayName = 'epasEnforcerMsg';
      attributeId = '1.3.6.1.4.1.49884.1.1.1';
      oMSyntax = 64; #https://learn.microsoft.com/en-us/previous-versions/windows/it-pro/windows-2000-server/cc961740(v=technet.10)?redirectedfrom=MSDN
      attributeSyntax = "2.5.5.12"; #https://learn.microsoft.com/en-us/previous-versions/windows/it-pro/windows-2000-server/cc961740(v=technet.10)?redirectedfrom=MSDN
      isSingleValued = $true;
      adminDescription = 'Password change failure reasons';
      rangeLower = 1; #https://learn.microsoft.com/en-us/windows-server/identity/ad-ds/deploy/schema-updates
      rangeUpper = 1024;
      #searchflags = 1
      }

$Error.Clear()

try
{
    New-ADObject -Name epasEnforcerMsg -Type attributeSchema -Path $schemapath -OtherAttributes $attributes -Verbose
    if($Error)
    {
        Write-Host "AD Schema Attribute creation failed, Please check the parameters & re-run the script.`nPlease reach out to <Email ID> for further clarification." -BackgroundColor Red -ForegroundColor White
    }
    else
    {
        Write-Host "AD Schema Attribute creation succeed, Fetching the newly created AD Schema Object." -BackgroundColor Green -ForegroundColor White
        Start-Sleep -Seconds 2

        Get-ADObject -SearchBase $schemaPath -Filter 'name -eq "epasEnforcerMsg"' -Properties * | Select-Object adminDescription, adminDisplayName, Created, attributeSyntax, attributeID, DistinguishedName | fl
    }
}
Catch
{
    Write-Warning $Error[0]
    Write-Host "Please reach out to <Email ID> for further clarification." -BackgroundColor Red -ForegroundColor White
    break;
}

Write-Host "`n`nMapping newly created Attribute to the User Class" -BackgroundColor White -ForegroundColor Black

try
{
    $userSchema = Get-ADObject -SearchBase $schemapath -Filter 'name -eq "user"'
    $userSchema | Set-ADObject -Add @{mayContain = 'epasEnforcerMsg'}

    Write-Host "`nAD Schema Attribute mapping with User Class has been succeed." -BackgroundColor Green -ForegroundColor White

    Write-Host "`n`nPlease use this syntax to check whether the Attribute is visible under User Class while fetching the data :- `n`n    Get-ADUser <User_Name> -Properties * | Select -Property SamAccountName, epasEnforcerMsg" -BackgroundColor White -ForegroundColor Black
}
catch
{
    Write-Warning $Error[0]
    Write-Host "Please reach out to <Email ID> for further clarification." -BackgroundColor Red -ForegroundColor White
    break;
}

#Get-ADUser <Username> -Properties * | Select -Property SamAccountName, epasEnforcerMsg
#Set-ADUser <Username> -Add @{epasEnforcerMsg = "test attribute successful"}

