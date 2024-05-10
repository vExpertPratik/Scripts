#This PowerCLI script will fetch the VM details and print it on the PowerShell Console.

cls
try
{
    #(Optional)Temporary addition of PowerCLI folder path in the PSModulePath
    #$env:PSModulePath = $env:PSModulePath + ";<Folder Path>\VMware-PowerCLI-13.0.0-20829139\"

    #Addition of VMware PS Snapin for older version of Windows
    Add-PSSnapin VMware.VimAutomation.Core
    #Import-Module VMware.VimAutomation.Core
    #[Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]'Ssl3,Tls,Tls11,Tls12'    #https://virtualhackey.wordpress.com/2018/12/26/powercli-vcenter-connection-error-the-underlying-connection-was-closed-an-unexpected-error-occurred-on-a-send-vmware-vsphere-6-7/

    #Security protocol enablement and enabling Windows Authentication
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    Set-PowerCLIConfiguration -Scope User -DisplayDeprecationWarnings $false -Confirm:$false

    #Remove any active PowerCLI VI connection
    if($global:DefaultVIServers)
    {
        Disconnect-VIServer -Server $global:DefaultVIServers.Name -Confirm:$false
    }
    cls


    #Connecting to respective vCenter server
    $vc = Read-Host "`nPlease select the appropriate region on which you want to work (1 or 2) : `n  1. <vCenter 1 Name>`n  2. <vCenter 2 Name>`nYour Selection "

    if($vc -match "1")
    {
        #$creds = Get-Credential
        Connect-VIServer <vCenter1 FQDN> #-Credential $creds
        cls

        Write-Host "`nSuccessfully Connected to vCenter [<vCenter1 FQDN>]" -BackgroundColor Green -ForegroundColor Black
    }

    elseif($vc -match "2")
    {
        #$creds = Get-Credential
        Connect-VIServer <vCenter2 FQDN> #-Credential $creds
        cls

        Write-Host "`nSuccessfully Connected to vCenter [<vCenter2 FQDN>]" -BackgroundColor Green -ForegroundColor Black
    }
    
    else
    {
        Write-Host "Please re-run the script & choose the valid response." -BackgroundColor Red -ForegroundColor White;

        Write-Host -NoNewLine 'Press any key to Exit from the console...';
        Write-Host 'Feel free to reach out to <Email ID> in case of any queries or concerns.'
        $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');
        break;
    }
}
Catch
{
    Write-Warning $Error[0];

    Write-Host 'Press any key to Exit from the console...';
    Write-Host 'Feel free to reach out to <Email ID> in case of any queries or concerns.';
    $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');
    break;
}
$name_input = Read-Host "`nPlease enter the VM Name for which you want to fetch the details " 
try
{
    try
    {
        Get-VM $name_input -ErrorAction Stop
        cls
    }
    catch
    {
        Write-Warning $Error[0];

        Write-Host 'Press any key to Exit from the console...';
        Write-Host 'Feel free to reach out to <Email ID> in case of any queries or concerns.';
        $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');
        break;
    }
    $VM = Get-View -ViewType VirtualMachine -Filter @{'Name' = $name_input}
    if($VM)
    {
        $placeholder = Get-VM $name_input | Where-Object {$_.ExtensionData.config.ManagedBy.extensionKey -notmatch "com.vmware.vcDr"}
        
    
        if(!$placeholder)
        {
            Write-Host "SRM is configured for this VM & Placeholder VM present in this datacenter, Please re-run the script & connect with appropriate vCenter Server." -BackgroundColor Red -ForegroundColor White;
        
            if($global:DefaultVIServers)
            {
                Disconnect-VIServer -Server $global:DefaultVIServers.Name -Confirm:$false
            }

            Write-Host 'Press any key to Exit from the console...';
            Write-Host 'Feel free to reach out to <Email ID> in case of any queries or concerns.';
            $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');
            break;
        }

        Write-Host "`nVM Display name : " $VM.Name -BackgroundColor Green -ForegroundColor Black
        Write-Host "`nVM Guest Hostname (FQDN/DNS) : " $VM.Guest.HostName -BackgroundColor Green -ForegroundColor Black
        Write-Host "`nVM Allocated CPU : " $VM.summary.config.numcpu -BackgroundColor Green -ForegroundColor Black
        Write-Host "`nVM Allocated Memory (MB) : " $VM.summary.config.memorysizemb -BackgroundColor Green -ForegroundColor Black
        Write-Host "`nVM hosted in Datacenter : " (Get-Datacenter -VM $name_input) -BackgroundColor Green -ForegroundColor Black

        #Started script Block for Resource Pool full Path
        $RP_path = (Get-VM -Name $name_input).Name
        $RP_parent = Get-View (Get-VM -Name $name_input).ExtensionData.ResourcePool
        while($RP_parent)
        {
            $RP_path = $RP_parent.Name + "/" + $RP_path
            if($RP_parent.Parent)
            {
                $RP_parent = Get-View $RP_parent.Parent
            }
            else{$RP_parent = $null}
        }

        Write-Host "`nVM Resource Pool (Full Path) : " $RP_path -BackgroundColor Green -ForegroundColor Black
        #Completed Script Block for Resource Pool full Path

        #Started script Block for VM Folder full Path
        $VF_path = (Get-VM -Name $name_input).Name
        $VF_parent = Get-View (Get-VM -Name $name_input).Folder
        while($VF_parent)
        {
            $VF_path = $VF_parent.Name + "/" + $VF_path
            if($VF_parent.Parent)
            {
                $VF_parent = Get-View $VF_parent.Parent
            }
            else{$VF_parent = $null}
        }

        Write-Host "`nVM Folder (Full Path) : " $VF_path -BackgroundColor Green -ForegroundColor Black
        #Completed Script Block for VM Folder full Path

        Write-Host "`nVM Assigned Datastore : " $VM.Config.DatastoreUrl.Name -BackgroundColor Green -ForegroundColor Black
        $datastoreFreeSize = (Get-Datastore ($VM.Config.DatastoreUrl.Name)).FreeSpaceGB
        $datastoreTotalSize = (Get-Datastore ($VM.Config.DatastoreUrl.Name)).CapacityGB
        Write-Host "`nAssigned datastore Free Space (in GB) : "  ([math]::Round($datastoreFreeSize,2)) -BackgroundColor Green -ForegroundColor Black
        Write-Host "`nAssigned datastore Total Space (in GB) : " ([math]::Round($datastoreTotalSize,2)) -BackgroundColor Green -ForegroundColor Black


        Write-Host "`nVM Disk Names : " (Get-VM -Name $name_input | Get-HardDisk).FileName -Separator "`n" -BackgroundColor Green -ForegroundColor Black
        Write-Host "`nVM Disk Size (Example, HD1_Size   HD2_Size) [GB] : " (Get-VM -Name $name_input | Get-HardDisk).CapacityGB -Separator "     " -BackgroundColor Green -ForegroundColor Black


        #Started script Block for VM Network full Path

        $VMmoref = ((Get-View (Get-VM -Name $name_input)).MoRef).Value
        $portgroups = (Get-NetworkAdapter -VM $name_input -WarningAction SilentlyContinue).NetworkName
        $networkView = Get-View -ViewType Network | Where-Object {$_.Vm -match $VMmoref}
        $PGFolder = (Get-Folder -Id $networkView.Parent).Name
        $switch = (Get-VirtualSwitch -VM $name_input -WarningAction SilentlyContinue).Name

        #$fullpath = @()
        #foreach($portgroup in $portgroups)
        #{
        #   $VMmoref = ((Get-View (Get-VM -Name $name_input)).MoRef).Value
        #    $networkView = Get-View -ViewType Network | Where-Object {$_.Vm -match $VMmoref}
        #    $PGFolder = (Get-Folder -Id $networkView.Parent).Name
        #    $switch = (Get-VirtualSwitch -VM $name_input).Name
        #
        #    $fullpath += (Get-VirtualSwitch -VM $name_input).Name | foreach {$PGFolder + "/" + $_ + "/" + $portgroup}
        #
        #    $networkView = Get-View -ViewType Network -Filter @{'Name' = $portgroup}
        #    $PGFolder = (Get-Folder -Id $networkView.Parent).Name
        #    $switch = (Get-VirtualSwitch | Where-Object {$_.ExtensionData.Summary.PortgroupName -match "$portgroup"}).Name
        #    $fullpath += $PGFolder + "/" + $switch + "/" + $portgroup + "`n"
        #    $switch | foreach {$fullpath += @([PSCustomObject] @{ Folder = $PGFolder; Switch = $_; Portgroup = $portgroup })}
        #}
    

        Write-Host "`nVM Network (Full Path) : " "`n"$PGFolder "------------------------------------------------`n" $switch "------------------------------------------------`n" $portgroups -Separator "`n" -BackgroundColor Green -ForegroundColor Black
    
        #Completed Script Block for VM Network full Path


        #Started script Block for VM Guest OS Details
        
        Write-Host "`nVM Guest IP Address : " (Get-VM -Name $name_input).Guest.IPAddress -Separator ", " -BackgroundColor Green -ForegroundColor Black
        $gateway = @($VM.Guest.ipstack.iprouteconfig.iproute.gateway.ipaddress)
        $gateway = $gateway | Select-Object -Unique
        Write-Host "`nVM Guest Default Gateway :" ([string]::Join(', ',($gateway))) -BackgroundColor Green -ForegroundColor Black
        Write-Host "`nVM Guest DNS IP Address :" ([string]::Join(', ',($VM.Guest.IpStack.DnsConfig.IpAddress))) -BackgroundColor Green -ForegroundColor Black


        $subnet = foreach($virtualmachine in (Get-VM -Name $name_input))
        {
            $virtualmachine.ExtensionData.Guest.Net | Select @{N="Mask";E=
            {
                $dec = [Convert]::ToUInt32($(("1" * $_.IpConfig.IpAddress[0].PrefixLength).PadRight(32, "0")), 2)
                $DottedIP = $( For ($i = 3; $i -gt -1; $i--)
                {
                    $Remainder = $dec % [Math]::Pow(256, $i)
                    ($dec - $Remainder) / [Math]::Pow(256, $i)
                    $dec = $Remainder
                })
                [String]::Join('.', $DottedIP) 
            }
            }
        }
        Write-Host "`nVM Guest Subnet Mask :" ([string]::Join(', ',($subnet.Mask))) -BackgroundColor Green -ForegroundColor Black
        Write-Host "`nVM Guest OS :" $VM.Config.GuestFullName -BackgroundColor Green -ForegroundColor Black

        #Completed script Block for VM Guest OS Details
        }
    else
    {
        Write-Host "Unable to find the VM in the vCenter Server" -BackgroundColor Red -ForegroundColor White;
        
        Write-Host 'Press any key to Exit from the console...';
        Write-Host 'Feel free to reach out to <Email ID> in case of any queries or concerns.';
        $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');
        break;
    }
}
Catch
{
    Write-Warning $Error[0];

    Write-Host 'Press any key to Exit from the console...';
    Write-Host 'Feel free to reach out to <Email ID> in case of any queries or concerns.';
    $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');
}

if($global:DefaultVIServers)
{
    Disconnect-VIServer -Server $global:DefaultVIServers.Name -Confirm:$false
}

Write-Host 'Press any key to Exit from the console...';
Write-Host 'Feel free to reach out to <Email ID> in case of any queries or concerns.';
$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');
