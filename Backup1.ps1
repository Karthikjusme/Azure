
$rgname = "NilavembuRG_SEA"
$loc = "southeastasia"
$VMname = "sea-webserver1"
$RSV = "sea-vmbackupvault"

Register-AzResourceProvider -ProviderNamespace "Microsoft.RecoveryServices"

New-AzRecoveryServicesVault `
    -ResourceGroupName $rgname `
    -Name $RSV `
-Location $loc

Get-AzRecoveryServicesVault `
    -Name $RSV | Set-AzRecoveryServicesVaultContext

    Get-AzRecoveryServicesVault `
    -Name $RSV | Set-AzRecoveryServicesBackupProperty -BackupStorageRedundancy LocallyRedundant

    $policy = Get-AzRecoveryServicesBackupProtectionPolicy     -Name "DefaultPolicy"

    Enable-AzRecoveryServicesBackupProtection `
    -ResourceGroupName $rgname `
    -Name $VMname `
    -Policy $policy

    $backupcontainer = Get-AzRecoveryServicesBackupContainer `
    -ContainerType "AzureVM" `
    -FriendlyName $VMname

$item = Get-AzRecoveryServicesBackupItem `
    -Container $backupcontainer `
    -WorkloadType "AzureVM"

Backup-AzRecoveryServicesBackupItem -Item $item

Get-AzRecoveryservicesBackupJob


##Disable-AzRecoveryServicesBackupProtection -Item $item -RemoveRecoveryPoints
#$vault = Get-AzRecoveryServicesVault -Name $RSV
#Remove-AzRecoveryServicesVault -Vault $vault
#Remove-AzResourceGroup -Name $rgname




