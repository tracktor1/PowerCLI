<#
This script will power on all poweredoff VMs on all ESXIs connected to Vcenter.
Change the vcenter address and admin user in the variables section.

DA-#>

#Variables
$viadmin = 'root'
$viserver = '192.168.100.41'

# Connect to vcenter 
#-------------------
$credentials = Get-Credential -UserName $viadmin -Message "Enter your vCenter password"
Connect-VIServer $viserver -Credential $credentials

$VMHosts = Get-VMHost
$AllVMs = get-vm

Foreach ($VM in $AllVMs){
	$Pstate = $VM.PowerState
	$VMName = $VM.Name
	#write-host $VMName power state is $Pstate
	IF ($Pstate -eq 'PoweredOff'){
		write-host Powering ON $VMName -ForegroundColor Green
		Start-VM -VM $VMName -Confirm:$false
		Start-sleep -s 5
		}
	ELSE { 
		IF ($Pstate -eq 'PoweredOn'){
		write-host $VMName is already powered ON -ForegroundColor Yellow
		}
	}
}

Disconnect-VIServer -confirm:$false