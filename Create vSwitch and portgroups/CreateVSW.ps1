<#
This script will create vswitches and portgroups on all ESXIs connected to Vcenter.
You need to add th e vswitch name, portgroup name and vlan ID in the CSV file VSW-List.csv.
Change the vcenter address and credentials in the variables section.

#>

#Variables
$viadmin = 'root'
$viserver = '192.168.100.41'
$VSWlist = Import-CSV .\VSW-List.csv

# Connect to vcenter 
#-------------------
$credentials = Get-Credential -UserName $viadmin -Message "Enter your vCenter password"
Connect-VIServer $viserver -Credential $credentials

$VMHosts = Get-VMHost

Foreach ($VMHost in $VMHosts){
	Foreach ($VSW in $VSWlist){
		$NewVSwitch = $VSW.VSWName
		$NewPGName = $VSW.PGName
		write-host $VMHost
		IF ((Get-VirtualSwitch -VMHost $VMHost -name $NewVSwitch -ErrorAction SilentlyContinue) -eq $null){
			Write-host "Creating Vswitch: $NewVSwitch on VMhost $VMHost" -ForegroundColor Green
			$createvs = New-VirtualSwitch -VMHost $vmhost -Name $NewVSwitch
			Write-host "Creating PortGroup: $NewPGName under $NewVSwitch @ VMhost: $VMHost" -ForegroundColor Yellow
			$VS = Get-VirtualSwitch -VMHost $VMHost -name $NewVSwitch
			New-VirtualPortGroup -VirtualSwitch $VS -Name $NewPGName
			}
		ELSE {
			IF ((Get-VirtualPortGroup -VMHost $VMHost -name $NewPGName -ErrorAction SilentlyContinue) -eq $null){
			Write-host "Creating PortGroup: $NewPGName under $NewVSwitch @ VMhost: $VMHost" -ForegroundColor Yellow
			$VS = Get-VirtualSwitch -VMHost $VMHost -name $NewVSwitch
			New-VirtualPortGroup -VirtualSwitch $VS -Name $NewPGName
			}
			ELSE {write-host "Portgroup: $NewPGName exists on $VMHost" -ForegroundColor Red}
		}
	}
}
Disconnect-VIServer -server $viserver -confirm:$false
