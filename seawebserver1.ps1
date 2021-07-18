#Variables

$User = "Karthick"
$Password = ConvertTo-SecureString "Aftertherain7" -AsPlainText -Force
$Loc = "southeastasia"
$ResourceGroupName = "NilavembuRG_SEA"
$ComputerName = "sea-webserver1"
$VMname = "sea-webserver1"
$VMSize = "Standard_B1s"

$vnetname = "vnet-sea"
$NICName = "$vmname-nic"
$SubnetName = "seawebsubnet1"
$Availabilityset = "sea-availability-set"

#Keygeneration
#ssh-keygen -t rsa -b 4096

#Getting Vnet and Subnet ID/Info

$vnet= Get-AzVirtualNetwork -name $vnetname -ResourceGroupName $ResourceGroupName

$subnetid1 = Get-AzVirtualNetworkSubnetConfig -VirtualNetwork $vnet -Name $SubnetName
$availset = Get-AzAvailabilitySet -Name $Availabilityset

$NIC = New-AzNetworkInterface -Name $NICName -ResourceGroupName $ResourceGroupName -Location $Loc -SubnetId $subnetid1.Id

#Credentials

$Credential = New-Object System.Management.Automation.PSCredential ($User, $Password);

#VM Creation
$VirtualMachine = New-AzVMConfig -VMName $VMName -VMSize $VMSize -AvailabilitySetId $availset.Id
$VirtualMachine = Set-AzVMOperatingSystem -VM $VirtualMachine -Linux -ComputerName $ComputerName -Credential $Credential 
$VirtualMachine = Add-AzVMNetworkInterface -VM $VirtualMachine -Id $NIC.Id
$VirtualMachine = Set-AzVMSourceImage -VM $VirtualMachine -PublisherName "Canonical" -Offer "UbuntuServer" -Skus "18.04-LTS"  -Version "latest"

New-AzVM -ResourceGroupName $ResourceGroupName -Location $Loc -VM $VirtualMachine -Verbose 
