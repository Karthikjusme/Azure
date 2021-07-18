#Variables

$rgname = "NilavembuRG_SEA"
$loc = "southeastasia"
$vnet = "vnet-sea"
$subnet1 = "seawebsubnet1"
$subnet2 = "seajumpsubnet2"
$nsgname1 = "SEA-WEB-NSG"
$nsgname2 = "SEA-Jump-NSG"
$Availabilityset = "sea-availability-set"

#Resource Group Location
New-AzResourceGroup $rgname $loc


#Virtual Network Creation
$vnetwork = @{
    Name = $vnet
    ResourceGroupName = $rgname
    Location = $loc
    AddressPrefix = '10.10.0.0/16'    
}
$virtualNetwork = New-AzVirtualNetwork @vnetwork

#Availability Set
New-AzAvailabilitySet -ResourceGroupName $rgname -Name $Availabilityset -Location $loc -Sku "Aligned" -PlatformFaultDomainCount 2 -PlatformUpdateDomainCount 3


#NSG Creation

$rule1 = New-AzNetworkSecurityRuleConfig -Name allow-ssh -Description "Allow SSH" `
    -Access Allow -Protocol Tcp -Direction Inbound -Priority 1100 -SourceAddressPrefix `
    Internet -SourcePortRange * -DestinationAddressPrefix * -DestinationPortRange 22

$rule2 = New-AzNetworkSecurityRuleConfig -Name allow-http -Description "Allow HTTP" `
    -Access Allow -Protocol Tcp -Direction Inbound -Priority 1200 -SourceAddressPrefix `
    Internet -SourcePortRange * -DestinationAddressPrefix * -DestinationPortRange 80,443

    #$rule4 = New-AzNetworkSecurityRuleConfig -Name allow-selected-ip -Description "Allow Selected IP Access" `
    #-Access Allow -Protocol Tcp -Direction Inbound -Priority 1000 -SourceAddressPrefix `
    #Internet -SourcePortRange 100.0.0.0\24,120.0.0.0\24 -DestinationAddressPrefix * -DestinationPortRange 80,443

$webnsg = New-AzNetworkSecurityGroup -ResourceGroupName $rgname -Location $loc -Name `
    $nsgname1 -SecurityRules $rule1,$rule2

$rule3 = New-AzNetworkSecurityRuleConfig -Name allow-http -Description "Allow HTTP" `
    -Access Allow -Protocol Tcp -Direction Inbound -Priority 1000 -SourceAddressPrefix `
    Internet -SourcePortRange * -DestinationAddressPrefix * -DestinationPortRange 3389,80,443


$jumpnsg = New-AzNetworkSecurityGroup -ResourceGroupName $rgname -Location $loc -Name `
    $nsgname2 -SecurityRules $rule3

#Subnet creation
$subnet1 = @{
    Name = $subnet1
    VirtualNetwork = $virtualNetwork
    AddressPrefix = '10.10.10.0/24'
    NetworkSecurityGroup = $webnsg
}
Add-AzVirtualNetworkSubnetConfig @subnet1

$subnet2 = @{
    Name = $subnet2
    VirtualNetwork = $virtualNetwork
    AddressPrefix = '10.10.20.0/24'
    NetworkSecurityGroup = $jumpnsg
}
Add-AzVirtualNetworkSubnetConfig @subnet2

$virtualNetwork | Set-AzVirtualNetwork




