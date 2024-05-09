#This script will add new records in Configuration file of nxlog for Sysvol

$computers = Get-content -Path <Path of the TXT file which contains list of server>
foreach ($computer in $computers)
{
    $computer
    $FileName = "\\$computer\C$\Program Files (x86)\nxlog\conf\nxlog.conf" #Fetching the Server names
    $Pattern = "</Query>"
    [System.Collections.ArrayList]$file = Get-Content $FileName
    $insert = @() #Creation of Array

    #Performing For loop for all the txt Content
    for ($i=0; $i -lt $file.count; $i++)
    {
        if ($file[$i] -match $pattern)
        {
            $insert += $i #Record the position of the line before this one
        }
    }

    #Now loop the recorded array positions and insert the new text
    $insert | Sort-Object -Descending | ForEach-Object { $file.insert($_,'<Select Path="Security">*[System[(EventID=4649)]]</Select>\') }

    Set-Content $FileName $file

    $insert | Sort-Object -Descending | ForEach-Object { $file.insert($_,'<Select Path="Security">*[System[(EventID=4794)]]</Select>\') }

    Set-Content $FileName $file

}

#============================================================================================================================================================================#

#This script will show the respective log file


$computers = Get-Content -Path "<Path of the TXT file which contains list of server>"

foreach($computer in $computers)
{
    $computer
    Get-Content "\\$computer\C$\Program Files (x86)\nxlog\data\nxlog.log" -Tail 5
}