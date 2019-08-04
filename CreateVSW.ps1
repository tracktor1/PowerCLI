<#
This script will create vswitches and portgroups on all ESXIs connected to Vcenter.
You need to add the vswitch name, portgroup name, vlan ID and Promiscuous mode in the CSV file VSW-List.csv.
Change the vcenter address and admin user in the variables section.

DA-#>

#Variables
$viadmin = 'administrator@sso.indeni.com'
$ESXAdmin = 'root'
$viserver = '192.168.1.11'
$vmhost = '192.168.1.19'

$VSWlist = Import-CSV .\VSW-List.csv

# Connect to vcenter 
#-------------------
#$credentials = Get-Credential -UserName $viadmin -Message "Enter your vCenter password"
#Connect-VIServer $viserver -Credential $credentials
# Connect to ESX 
#-------------------
$credentials = Get-Credential -UserName $ESXAdmin -Message "Enter your vCenter password"
Connect-VIServer $vmhost -Credential $credentials

$VMHosts = Get-VMHost

Foreach ($VMHost in $VMHosts){
	Foreach ($VSW in $VSWlist){
		$NewVSwitch = $VSW.VSWName
		$NewPGName = $VSW.PGName
		$NewVlan = $VSW.VLANID
		$NewPromis = $VSW.Promiscuous
		write-host $VMHost
		IF ((Get-VirtualSwitch -VMHost $VMHost -name $NewVSwitch -ErrorAction SilentlyContinue) -eq $null){
			Write-host "Creating Vswitch: $NewVSwitch on VMhost $VMHost" -ForegroundColor Green
			$createvs = New-VirtualSwitch -VMHost $vmhost -Name $NewVSwitch
			Write-host "Creating PortGroup: $NewPortSwitch on VMhost $VMHost" -ForegroundColor Yellow
			$VS = Get-VirtualSwitch -VMHost $VMHost -name $NewVSwitch
			New-VirtualPortGroup -VirtualSwitch $VS -Name $NewPGName
			}
		ELSE {
			IF ((Get-VirtualPortGroup -VMHost $VMHost -name $NewPGName -ErrorAction SilentlyContinue) -eq $null){
				Write-host "Creating PortGroup: $NewPortSwitch  on VMhost $VMHost" -ForegroundColor Yellow
				$VS = Get-VirtualSwitch -VMHost $VMHost -name $NewVSwitch
				$NewPG = New-VirtualPortGroup -VirtualSwitch $VS -name $NewPGName
				Set-VirtualPortGroup -VirtualPortGroup $NewPG -VLanId $NewVlan #Set VLAN ID on portgroup
				IF ($NewPromis -eq 1){
					$VS | Get-VirtualPortGroup -name $NewPGName | Get-SecurityPolicy | Set-SecurityPolicy -AllowPromiscuous $true
				}
				ELSE {
					$VS | Get-VirtualPortGroup -name $NewPGName | Get-SecurityPolicy | Set-SecurityPolicy -AllowPromiscuous $false
				}
			}
			ELSE {
				write-host "Portgroup: $NewPGName exists on $VMHost Checking Promiscuous Mode" -ForegroundColor Red
				$VS = Get-VirtualSwitch -VMHost $VMHost -name $NewVSwitch
				IF ($NewPromis -eq 1){
					$VS | Get-VirtualPortGroup -name $NewPGName | Get-SecurityPolicy | Set-SecurityPolicy -AllowPromiscuous $true
				}
				ELSE {
					$VS | Get-VirtualPortGroup -name $NewPGName | Get-SecurityPolicy | Set-SecurityPolicy -AllowPromiscuous $false
				}
			}
		}
	}
}
#Disconnect-VIServer -confirm:$false
