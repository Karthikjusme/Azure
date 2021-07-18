# Variables for common values

$rgname = "NilavembuRG_SEA"
$location = "southeastasia"
$lbname = "sea-lb1"
$lbpip = "sea-lb-pip1"
$vnetName = "vnet-sea"
$vmname1 = "sea-webserver1"
$vmname2 = "sea-webserver2"
$bpname = "lb-bp1"
$hpname = "lb-hp1"
$feipname = "lb-frontend1"
$lbrulename = "lb-rule1"

$vm1 = Get-AzResource -ResourceGroupName $rgname -Name $vmname1
$vm2 = Get-AzResource -ResourceGroupName $rgname -Name $vmname2



# Creating  public IP address
$publicIpLB = New-AzPublicIpAddress -ResourceGroupName $rgName -Name $lbpip -Location $location -AllocationMethod "Static"  -Sku 'Standard'


# Creating back-end & front-end address pools.
$bppool1 = New-AzLoadBalancerBackendAddressPoolConfig -Name $bpname


$frontendip = New-AzLoadBalancerFrontendIpConfig -Name $feipname -PublicIpAddress $publicIpLB

# Creating health probe on port 80.
$probe = New-AzLoadBalancerProbeConfig -Name $hpname -Protocol Http -Port 80 `
  -RequestPath / -IntervalInSeconds 360 -ProbeCount 5

# Creating load balancing rules.
$lbrule1 = New-AzLoadBalancerRuleConfig -Name $lbrulename -Protocol Tcp -DisableOutboundSNAT `
  -Probe $probe -FrontendPort 80 -BackendPort 80 `
  -FrontendIpConfiguration $frontendip -BackendAddressPool $bppool1 -LoadDistribution "SourceIP"
  

#$bp2 = New-AzLoadBalancerRuleConfig -Name 'lb-bp2' -Protocol Tcp `
 # -Probe $probe -FrontendPort 80 -BackendPort 22 `
 # -FrontendIpConfiguration $frontendip -BackendAddressPool $bppool2

# Creating the load balancer.
$lb = New-AzLoadBalancer -ResourceGroupName $rgName -Sku "Standard" -Name $lbname -Location $location `
  -FrontendIpConfiguration $frontendip -BackendAddressPool $bppool1 `
  -Probe $probe -LoadBalancingRule $lbrule1 

#Adding VNet and Required VM's to the backend pool

$virtualNetwork = Get-AzVirtualNetwork -Name $vnetName -ResourceGroupName $rgname 
#Getting IP:
$nic1 = Get-AzNetworkInterface -Name "$VMname1-nic" -ResourceGroupName $rgname
$nic2 = Get-AzNetworkInterface -Name "$VMname2-nic" -ResourceGroupName $rgname
$nicip1 =Get-AzNetworkInterfaceIpConfig -Name ipconfig1 -NetworkInterface $nic1
$nicip2 =Get-AzNetworkInterfaceIpConfig -Name ipconfig1 -NetworkInterface $nic2
 
$ip1 = New-AzLoadBalancerBackendAddressConfig -IpAddress $nicip1.PrivateIpAddress -Name "lp-bpaddress1" -VirtualNetworkId $virtualNetwork.Id
$ip2= New-AzLoadBalancerBackendAddressConfig -IpAddress $nicip2.PrivateIpAddress -Name "lp-bpaddress2" -VirtualNetworkId $virtualNetwork.Id 
$ips = @($ip1, $ip2)
$b2 = Get-AzLoadBalancerBackendAddressPool -ResourceGroupName $rgname -LoadBalancerName $lbname -Name $bpname

Set-AzLoadBalancerBackendAddressPool -ResourceGroupName $rgname -LoadBalancerName $lb.Name  -Name $b2.Name  -LoadBalancerBackendAddress $ips

#Adding INbound NAT rules for RDP to the backend servers
#$rgname = "NilavembuRG_SEA"
#$location = "southeastasia"
#$lbname = "sea-lb1"

#$lb1 = Get-AzLoadBalancer -ResourceGroupName $rgname -Name $lbname
#$lb1 | Add-AzLoadBalancerInboundNatRuleConfig -Name "RDPRule1" -FrontendIPConfiguration $lb1.FrontendIpConfigurations[0] -Protocol "SSH" -FrontendPort 30000 -BackendPort 22
#$lb1 | Add-AzLoadBalancerInboundNatRuleConfig -Name "RDPRule2" -FrontendIPConfiguration $lb1.FrontendIpConfigurations[0] -Protocol "SSH" -FrontendPort 30001 -BackendPort 22

#$natnic1 = Get-AzLoadBalancerInboundNatRuleConfig -LoadBalancer $lb1 -Name "RDPRule1"
#$natnic2 = Get-AzLoadBalancerInboundNatRuleConfig -LoadBalancer $lb1 -Name "RDPRule2"

#Set-AzNetworkInterfaceIpConfig -Name $nic1.IpConfigurations[0].Name -LoadBalancerInboundNatRule $natnic1.inboundnatrules.id -NetworkInterface $nic1
#Set-AzNetworkInterfaceIpConfig -Name $nic1.IpConfigurations[0].Name -LoadBalancerInboundNatRule $natnic2.inboundnatrules.id -NetworkInterface $nic2


