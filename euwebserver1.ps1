#Variables

$User = "Karthick"
$Password = ConvertTo-SecureString "Aftertherain7" -AsPlainText -Force
$Loc = "eastus2"
$ResourceGroupName = "NilavembuRG_EUS"
$ComputerName = "EUS-webserver2"
$VMname = "EUS-webserver2"
$VMSize = "Standard_D2ds_v4"

$vnetname = "vnet-eus"
$NICName = "$vmname-nic"
$SubnetName = "eusubnet1"
$PublicIPAddressName = "$VMName-publicip"


#Keygeneration
#ssh-keygen -t rsa -b 4096

#Getting Vnet and Subnet ID/Info

$vnet= Get-AzVirtualNetwork -name $vnetname -ResourceGroupName $ResourceGroupName

$subnetid1 = Get-AzVirtualNetworkSubnetConfig -VirtualNetwork $vnet -Name $SubnetName
$PIP = New-AzPublicIpAddress -Name $PublicIPAddressName -ResourceGroupName $ResourceGroupName -Location $Loc -AllocationMethod Dynamic

$NIC = New-AzNetworkInterface -Name $NICName -ResourceGroupName $ResourceGroupName -Location $Loc -SubnetId $subnetid1.Id -PublicIpAddressId $PIP.Id

#Credentials

$Credential = New-Object System.Management.Automation.PSCredential ($User, $Password);

#VM Creation
$VirtualMachine = New-AzVMConfig -VMName $VMName -VMSize $VMSize
$VirtualMachine = Set-AzVMOperatingSystem -VM $VirtualMachine -Linux -ComputerName $ComputerName -Credential $Credential 
$VirtualMachine = Add-AzVMNetworkInterface -VM $VirtualMachine -Id $NIC.Id
$VirtualMachine = Set-AzVMSourceImage -VM $VirtualMachine -PublisherName "Canonical" -Offer "UbuntuServer" -Skus "18.04-LTS"  -Version "latest"

New-AzVM -ResourceGroupName $ResourceGroupName -Location $Loc -VM $VirtualMachine -Verbose 
