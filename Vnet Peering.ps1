#Variables
$rgname1 = "NilavembuRG_SEA"
$rgname2 = "NilavembuRG_EUS"
$vnet1 = "vnet-sea"
$vnet2 = "vnet-eus"

#Getting Vnet info

$seavnet= Get-AzVirtualNetwork -name $vnet1 -ResourceGroupName $rgname1
$euvnet = Get-AzVirtualNetwork -name $vnet2 -ResourceGroupName $rgname2



Add-AzVirtualNetworkPeering `
  -Name vnetsea-vneteus `
  -VirtualNetwork $seavnet `
  -RemoteVirtualNetworkId $euvnet.Id

  Add-AzVirtualNetworkPeering `
  -Name vneteus-vnetsea `
  -VirtualNetworkn $euvnet `
  -RemoteVirtualNetworkId $seavnet.Id

 
  Get-AzVirtualNetworkPeering `
  -ResourceGroupName $rgname1 `
  -VirtualNetworkName $seavnet.Name `
  | Select PeeringState