#This will allow you to fetch and store the Share and NTFS Permission of the remote servers
#if Output comes in number
#268435456 - FullControl
#-536805376 - Modify, Synchronize
#-1610612736 - ReadAndExecute, Synchronize

#============================================================================================================================================================================#

$computers = Get-Content -Path "<Path of the TXT file which contains list of server>"
Get-SmbShare | Get-SmbShareAccess | Out-Null
foreach($computer in $computers)
{
    $computer
    $session = New-PsSession -ComputerName $computer
    $SP= Invoke-Command -Session $session {Get-SmbShare | Where-Object {(@('Remote Admin','Default share','Remote IPC','Printer Drivers') -notcontains $_.Description)}}
    $shares = Invoke-Command -Session $session {Get-SmbShare | Where-Object {(@('Remote Admin','Default share','Remote IPC','Printer Drivers') -notcontains $_.Description)} | Get-SmbShareAccess}
    $sharepermission = $shares | Select-Object PSComputerName, AccessControlType, AccessRight, AccountName, Name
    $sharepermission | Export-Csv -Path "<Path of the CSV file which will save the output of the SharePermission>" -Append -NoTypeInformation
    

    $paths = $SP | Select-Object path,Name
    foreach($path in $paths)
    {
        $fpath = $path.path.Replace(':\','$\')
        $SName = $path.name
        $RootPath = "\\" + $computer + "\" +  $fpath
        $NTFSPermission = $RootPath | Get-Acl | foreach {
            $path = $_.Path
            $_.Access | % {
            New-Object PSObject -Property @{
                Folder = $path.Replace("Microsoft.PowerShell.Core\FileSystem::","")
                Access = $_.FileSystemRights
                User = $_.IdentityReference
                Control = $_.AccessControlType
                Computer = $computer
                SName = $SName
                }
            } 
        } | select-object -Property SName, Folder, User, Control, Access | Export-Csv -Path "<Path of the CSV file which will save the output of the NTFS Permission>" -Append -NoTypeInformation
    }

}