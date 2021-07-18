#Variables

$rgname = "NilavembuRG_EUS"
$loc = "eastus2"
$vnet = "vnet-eus"
$subnet1 = "eusubnet1"
$nsgname1 = "EUS-NSG"

#Resource Group Location
New-AzResourceGroup $rgname $loc


#Virtual Network Creation
$vnetwork = @{
    Name = $vnet
    ResourceGroupName = $rgname
    Location = $loc
    AddressPrefix = '10.20.0.0/16'    
}
$virtualNetwork = New-AzVirtualNetwork @vnetwork

#NSG Creation

$rule1 = New-AzNetworkSecurityRuleConfig -Name allow-access -Description "Allow Access" `
    -Access Allow -Protocol Tcp -Direction Inbound -Priority 1000 -SourceAddressPrefix `
    Internet -SourcePortRange * -DestinationAddressPrefix * -DestinationPortRange 22,80,443


$eusnsg = New-AzNetworkSecurityGroup -ResourceGroupName $rgname -Location $loc -Name `
    $nsgname1 -SecurityRules $rule1

#Subnet creation
$subnet = @{
    Name = $subnet1
    VirtualNetwork = $virtualNetwork
    AddressPrefix = '10.20.10.0/24'
    NetworkSecurityGroup = $eusnsg
}
Add-AzVirtualNetworkSubnetConfig @subnet

$virtualNetwork | Set-AzVirtualNetwork




