

$bkp_dir = 'C:\ESXI-Backup'
$tt = Get-Date -UFormat "%Y-%m-%d"
$VMHosts = Get-VMHost


Foreach ($VMHost in $VMHosts){
	If(!(test-path $bkp_dir\$VMHost\$tt\)) {
			New-Item -ItemType Directory -Force -Path $bkp_dir\$VMHost\$tt\
		}
	$BackupPath = "$bkp_dir\$VMHost\$tt\"
	write-host $BackupPath
	Get-VMHostFirmware -VMHost $VMHost -BackupConfiguration -DestinationPath $bkp_dir\$VMHost\$tt
	Get-VMHost -Name $VMHost | Select Name,Version,Build | Out-File ($BackupPath + $tt + '_' + 'info.txt')
}