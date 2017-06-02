#login to your azure account
Login-AzureRmAccount


#variable for VM creation
$id = [Guid]::NewGuid().ToString("n").SubString(0,8)
$resourceGroupName = $id + "-rg"
$location = "eastus"
$vmName = $id + "-vm1"
$subnetName = "web"
$vnetName = $id + "-vnet"
$pipName = $id + "-pip"
$rdpRuleName = $id + "-rdp-allow"
$httpRuleName = $id + "-http-allow"
$webDeployRuleName = $id + "-webdeploy-allow"
$nsgName = $id + "-nsg"
$nicName = $id + "-nic"

#create a new resource group to use
New-AzureRmResourceGroup -Name $resourceGroupName -Location $location

# Create a subnet configuration
$subnetConfig = New-AzureRmVirtualNetworkSubnetConfig -Name $subnetName -AddressPrefix 192.168.1.0/24

# Create a virtual network
$vnet = New-AzureRmVirtualNetwork -ResourceGroupName $resourceGroupName -Location $location `
-Name $vnetName -AddressPrefix 192.168.0.0/16 -Subnet $subnetConfig

# Create a public IP address and specify a DNS name
$pip = New-AzureRmPublicIpAddress -ResourceGroupName $resourceGroupName -Location $location `
-AllocationMethod Static -IdleTimeoutInMinutes 4 -Name $pipName

# Create an inbound network security group rule for port 3389
$nsgRuleRDP = New-AzureRmNetworkSecurityRuleConfig -Name $rdpRuleName  -Protocol Tcp `
-Direction Inbound -Priority 1000 -SourceAddressPrefix * -SourcePortRange * -DestinationAddressPrefix * `
-DestinationPortRange 3389 -Access Allow

# Create an inbound network security group rule for port 80 for HTTP
$nsgRuleHttp = New-AzureRmNetworkSecurityRuleConfig -Name $httpRuleName  -Protocol Tcp `
-Direction Inbound -Priority 1010 -SourceAddressPrefix * -SourcePortRange * -DestinationAddressPrefix * `
-DestinationPortRange 80 -Access Allow

# Create an inbound network security group rule for port 8172 for WebDeploy
$nsgRuleWebDeploy = New-AzureRmNetworkSecurityRuleConfig -Name $webDeployRuleName  -Protocol Tcp `
-Direction Inbound -Priority 1020 -SourceAddressPrefix * -SourcePortRange * -DestinationAddressPrefix * `
-DestinationPortRange 8172 -Access Allow

# Create a network security group
$nsg = New-AzureRmNetworkSecurityGroup -ResourceGroupName $resourceGroupName -Location eastus `
-Name $nsgName -SecurityRules $nsgRuleRDP,$nsgRuleHttp,$nsgRuleWebDeploy

# Create a virtual network card and associate with public IP address and NSG
$nic = New-AzureRmNetworkInterface -Name $nicName -ResourceGroupName $resourceGroupName -Location $location `
-SubnetId $vnet.Subnets[0].Id -PublicIpAddressId $pip.Id -NetworkSecurityGroupId $nsg.Id

# Define a credential object
$cred = Get-Credential

# Create a virtual machine configuration
$vmConfig = New-AzureRmVMConfig -VMName $vmName -VMSize Standard_DS2 | `
Set-AzureRmVMOperatingSystem -Windows -ComputerName $vmName -Credential $cred | `
Set-AzureRmVMSourceImage -PublisherName MicrosoftWindowsServer -Offer WindowsServer -Skus 2016-Datacenter -Version latest | `
Add-AzureRmVMNetworkInterface -Id $nic.Id

New-AzureRmVM -ResourceGroupName $resourceGroupName -Location $location -VM $vmConfig

# Install IIS and WebDeploy
$PublicSettings = '{"ModulesURL":"https://github.com/JasonHaley/GlobalAzureBootcamp/raw/master/ConfigureWebServer.ps1.zip", "configurationFunction": "ConfigureWebServer.ps1\\Main", "Properties": {"nodeName": "' + $vmName + '"} }'

Set-AzureRmVMExtension -ExtensionName "DSC" -ResourceGroupName $resourceGroupName -VMName $vmName `
  -Publisher "Microsoft.Powershell" -ExtensionType "DSC" -TypeHandlerVersion 2.24 `
  -SettingString $PublicSettings -Location $location

$ipaddress = Get-AzureRmPublicIpAddress -ResourceGroupName $resourceGroupName | Select -ExpandProperty IpAddress

# Launch RDP session
mstsc /v:$ipaddress

# set variable for the location of your site package
$packagePath = "C:\Users\Jason\Desktop\PSInAction\WebApp.zip"
$user = $vmName + "\" + $cred.UserName
$password = $cred.GetNetworkCredential().Password

# requires Web Deploy to be installed!
$msdeploy = "C:\Program Files (x86)\IIS\Microsoft Web Deploy V3\msdeploy.exe"
$computerName = "https://" + $ipaddress + ":8172/msdeploy.axd?site=Default%20Web%20Site"

$nameParam = "IIS Web Application Name"
$nameValue = "Default Web Site"
$setParam = '-setParam:name="IIS', 'Web', 'Application', 'Name",value="Default', 'Web', 'Site"'

& $msdeploy -source:package=$packagePath -verb=sync -dest:auto,computerName=$computerName,userName=$user,password=$password,authType=Basic -allowUntrusted=true $setParam

$webUrl = "http://" + $ipaddress
Start-Process -FilePath $webUrl

# remove all resources in resource group
Remove-AzureRmResourceGroup -ResourceGroupName $resourceGroupName
