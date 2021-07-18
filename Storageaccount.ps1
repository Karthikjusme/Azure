#EUS Storage account using ZRS

$rgname = "NilavembuRG_EUS"
$loc = "eastus2"
$sname = "nilastorageeus22"

$storageacc1 = New-AzStorageAccount -ResourceGroupName $rgname `
  -Name $sname `
  -Location $loc `
  -SkuName Standard_ZRS `
  -Kind StorageV2 `
  -EnableHttpsTrafficOnly $true `
  -AllowSharedKeyAccess $true `
  

#SEA Storage account using GRS

  $rgname1 = "NilavembuRG_SEA"
  $loc1 = "southeastasia"
  $sname1 = "nilastoragesea111"

  $storageacc2 = New-AzStorageAccount -ResourceGroupName $rgname1 `
  -Name $sname1 `
  -Location $loc1 `
  -SkuName Standard_GRS `
  -Kind StorageV2


  #Get Access Key
  
  $storageKey = Get-AzStorageAccountKey -ResourceGroupName $rgname -Name $sname
  $storageKey
  
  $sKey = (Get-AzstorageAccountKey -ResourceGroupName $rgname -Name $sname | select -first 1).Value

#Creating File Share

  $storageContext = New-AzStorageContext -StorageAccountName $sname -StorageAccountKey $sKey
  New-AzStorageShare -Name sales-info -Context $storageContext
  
#Get URL  
$storageacc1.Context.ConnectionString

  
  