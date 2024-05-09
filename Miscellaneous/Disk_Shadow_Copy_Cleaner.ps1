#This script will clear all the respective shadow copies available on the server

$shadowCopies = Get-WMIObject -Class Win32_ShadowCopy -Computer <Server Name>
$shadowCopies | % {$_.DeviceObject}  # Lists out just the names of the copies
$shadowCopies | Get-Member -View All # Lists all members even hidden ones such as "delete"
$shadowCopies[0].Delete()            # Deletes the first shadow copy when more than one exists
$shadowCopies.Delete()               # Works when only a single shadow copy exists



#============================================================================================================================================================================#
#This script will show the space on C Drive

$disk = Get-WmiObject Win32_LogicalDisk -ComputerName <Server Name> -Filter "DeviceID='C:'" | Select-Object Size, FreeSpace
