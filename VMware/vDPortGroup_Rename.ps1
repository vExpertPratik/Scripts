#Method 1 to rename the distributed port groups

foreach($dvpg in (Get-VDSwitch "<Name_Of_the_switch>" | Get-VDPortGroup))
{
	Write-Host "Renaming the VLAN :- $dvpg" -ForegroundColor Black -BackgroundColor White
	Set-VDPortGroup -VDPortgroup $dvpg -Name "$($pg.Name)_old" -Confirm:$false -Verbose
}


#============================================================================================================================================================================#

#Method 2 to rename the distributed port groups

$OGNames = Get-VDSwitch "<Name_of_the_switch>" | Get-VDPortGroup

foreach($newname in $OGNames)
{
	Write-Host "Renaming the VLAN :- $newname" -ForegroundColor Black -BackgroundColor White
	$newdvpname = $newname -replace '_old', ""
	$newdvpnames += $newdvpname
}
