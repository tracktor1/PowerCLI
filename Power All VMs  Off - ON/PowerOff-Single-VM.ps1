<#
This script will power off selected powered-on VM.

DA-#>

#Variables
$viadmin = 'administrator@sso.indeni.com'
$viserver = '192.168.1.11'


# Connect to vcenter 
#-------------------
$credentials = Get-Credential -UserName $viadmin -Message "Enter your vCenter password"
Connect-VIServer $viserver -Credential $credentials

$VMHosts = Get-VMHost


$GetVMName = Read-Host '[+] Insert VM Name to shutdown'
$Combo = -Join("*",$GetVMName,"*")
$Getvm = get-vm -name $Combo

Foreach ($VM in $Getvm){
	write-host "[+] Shutdown $VM ?"
	$confirmation = Read-Host '[+] Press [Y] to confirm or any key to cancel'
	if ($confirmation -eq 'y') {
		Stop-VM -VM $VM -Confirm:$false
		Start-sleep -s 5
		}
	ELSE { 
		write-host $VM "Did Nothing" -ForegroundColor Yellow

	}
}
