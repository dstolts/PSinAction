<#  
     Create Resources in Azure

     https://docs.microsoft.com/en-us/azure/virtual-machines/windows/sql/virtual-machines-windows-ps-sql-create

#>

Import-Module AzureRM 

# Log into the account.  Note:  Alias for Add-AzureRmAccount.
Login-AzureRmAccount  # Note:  Login properties returned to console.

# Create a credential for the local admin account...
$cred = Get-Credential -Message "Enter a username and password for the virtual machine."

<# Resource groups let us group resources together which
   reduces the imoact of Azure system maintenance, i.e. will leave one
   VM up while it does maintenance on another.
#>

# Create Variables for common values.  Note:  single quotes around strings do not expand embedded variables.
$resourceprefix = "demobpc4"  # let's just prefix everything to tie it together...
$resourceGroup = $resourceprefix + "RG"
$location = "East US 2"
$vmName = $resourceprefix + "VM"

# Create a new resource group as a container for the resources we're creating.
New-AzureRmResourceGroup -Name $resourceGroup -Location $location

<#

    Create a new VM

#>

# Create a subnet configuration - Note: Parenthesis below are critical! Using Verbose common parameter.
$subnetConfig = New-AzureRmVirtualNetworkSubnetConfig -Name ($resourceprefix + "Subnet1") -AddressPrefix 192.168.1.0/24 -Verbose
$subnetConfig

# Create a virtual network
$vnet = New-AzureRmVirtualNetwork -ResourceGroupName $resourceGroup -Location $location `
  -Name ($resourceprefix + "VNET1") -AddressPrefix 192.168.0.0/16 -Subnet $subnetConfig -Verbose
$vnet

# Create a public IP address and specify a DNS name

#  Let's get a somewhat random IPAddress Name...
$publicip = $resourceprefix +'publicdns' + $(Get-Random)

$publicIpAddress = New-AzureRmPublicIpAddress -ResourceGroupName $resourceGroup -Location $location `
  -Name $publicip -AllocationMethod Static -IdleTimeoutInMinutes 4 -Verbose
$publicIpAddress | Select-Object Name,IpAddress

# Create an inbound network security group rule for port 3389
$nsgRuleRDP = New-AzureRmNetworkSecurityRuleConfig -Name ($resourceprefix + 'NetworkSecurityGroupRuleRDP')  -Protocol Tcp `
  -Direction Inbound -Priority 1000 -SourceAddressPrefix * -SourcePortRange * -DestinationAddressPrefix * `
  -DestinationPortRange 3389 -Access Allow -Verbose
$nsgRuleRDP

# Create a network security group
$nsg = New-AzureRmNetworkSecurityGroup -ResourceGroupName $resourceGroup -Location $location `
  -Name ($resourceprefix + 'NetworkSecurityGroup1') -SecurityRules $nsgRuleRDP -Verbose
$nsg

# Create a virtual network card and associate with public IP address and NSG
$nic = New-AzureRmNetworkInterface -Name ($resourceprefix + 'Nic1') -ResourceGroupName $resourceGroup -Location $location `
  -SubnetId $vnet.Subnets[0].Id -PublicIpAddressId $publicIpAddress.Id -NetworkSecurityGroupId $nsg.Id -Verbose

# Pull it all together to create a virtual machine configuration
$vmConfig = New-AzureRmVMConfig -VMName $vmName -VMSize Standard_D1 |
  Set-AzureRmVMOperatingSystem -Windows -ComputerName $vmName -Credential $cred |
  Set-AzureRmVMSourceImage -PublisherName MicrosoftWindowsServer -Offer WindowsServer -Skus 2016-Datacenter -Version latest |
  Add-AzureRmVMNetworkInterface -Id $nic.Id -Verbose

$vmConfig  # Display VM Config Info...

## Create the VM in Azure
New-AzureRmVM  -ResourceGroupName $resourceGroup -Location $location -VM $vmConfig -Verbose

#  See the VM...
Get-AzureRmVM -Name $vmName -ResourceGroupName $resourceGroup
