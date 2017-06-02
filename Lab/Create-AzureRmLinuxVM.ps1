<#   
========= Create-AzureRmLinuxVM.ps1 ======================================= 
 Name: Create-AzureRmLinuxVM 
 Purpose: Create Linux (Ubuntu 16) VM and all supporting infrastructure on Azure using ResourceManager (without templates) 
    Also shows... 
       Using parameters and evaluating parameters - All parameters are optional
       Populating a GridView and allowing a user to select a subscription from list of available subs
       How to get various property values from the Azure subscription
       Overriding parameters with static values
       displaying -help content and using -help switch
       Creating Azure Network, NSG, Subnet, PublicIP
       Linking NSG to PublicIP
       Getting Credentials from user and converting text values to credentials
       Creating post machine script to run on a linux machine using CustomScriptExtension
       Demonstrates tracking how long a script takes
     
 Author: Dan Stolts - dstolts&microsoft.com - http://ITProGuru.com
         Script Home: http://ITProGuru.com/Scripts 
 Syntax/Execution: 
      Copy portion of script you want to use and paste into PowerShell (or ISE)  
      ./Create-AzureRmLinuxVM.ps1  
      ./Create-AzureRmLinuxVM.ps1  -help
      ./Create-AzureRmLinuxVM.ps1  <Add optional parameters see below> 
      -Optional Parameters... sequence not important. The user is prompted for all parameters not supplied. : 
                    -SubscriptionID 12345-6789...        # Pops a list 
                    -RGName myRgName                     # Pops List to select default, creates if user cancels
                    -StorageAccountName mystoragename    # Prompts user if not supplied
                    -Container myNewContainer            # Folder/Container to create on storage account Defaults to registry
                    -ScriptsContainer registry           # Folder/Container to create on storage account for storing scripts Defaults to scripts
                    -Location useast                     # Defaults to Location of Resource Group or pops a list for user to select
                    -$StorageSkuName 'Standard_LRS'      # Defaults to 'Standard_LRS'
                    -$VmName  myLinuxVMName              # Defaults to 'DockerRegHost'
                    -$VmDnsName AbcLinuxVM01             # Defaults to '<VMName>azvm'
                    -$AdminUser "linuxAdmin"             # Defaults to Prompt User
                    -$AdminPass "My5upperP@ss"           # Defaults to Prompt User
                    -$help                               # Display Help
       
 Disclaimer: Use at your own Risk!  See details at http://ITProGuru.com/privacy  
 Limitations:  
        * If you do not already have an Azure connection, unremark the line below Add-AzureAccount
        * Must Run PowerShell (or ISE)  
        * UAC may get in the way depending on your settings (See: http://ITProGuru.com/PS-UAC) 
# See Also http://itproguru.com/expert/2016/04/powershell-working-with-azure-resource-manager-rm-step-by-step-changing-rm-subscriptions/
 ================================================================================ 
#># 

#region Evaluate Parameters; Create Defaults Values

Param (
    [Parameter(Mandatory=$false)][string]$Location,               # Defaults to Location of Resource Group
    [Parameter(Mandatory=$false)][string]$RGName,                 # Pops List to select default
    [Parameter(Mandatory=$false)][string]$StorageAccountName,     # Defaults to prompt user
    [Parameter(Mandatory=$false)][string]$Container,              # Folder/Container to create on storage account Defaults to registry
    [Parameter(Mandatory=$false)][string]$ScriptsContainer,       # Folder/Container to create on storage account for storing scripts Defaults to scripts
    [Parameter(Mandatory=$false)][string]$StorageSkuName,         # Defaults to 'Standard_LRS'
    [Parameter(Mandatory=$false)][string]$VmName        ,         # Defaults to 'DockerRegHost'
    [Parameter(Mandatory=$false)][string]$VmDnsName        ,      # Defaults to '<VMName>azvm'
    [Parameter(Mandatory=$false)][string]$AdminUser        ,      # Defaults to Prompt User
    [Parameter(Mandatory=$false)][string]$AdminPass        ,      # Defaults to Prompt User
    [Parameter(Mandatory=$false)][string]$SubscriptionID ,        # Subscription to create storage in
    [Parameter(Mandatory=$false)][switch]$help                    # Display Help
) 
#Add-AzureRmAccount
Login-AzureRmAccount 

#  If you want to set the variables statically, just unremark this section (remove the < at the beginning and the > at the end) and change the variables
$Location = "eastus"    # Defaults to Location of Resource Group
$RGName =  "AzResearch-020517a"             # Pops List to select default
$StorageAccountName ="azresearch020517a"     # Defaults to prompt user
$Container = "registry"              # Defaults to registry
$ScriptsContainer = "scripts"      # Defaults to scripts
$StorageSkuName  = "Standard_LRS"          # Defaults to 'Standard_LRS'
$VmName    =   "AzResearch01"          # Defaults to 'DockerRegHost'
$VmDnsName  =  "azresearch01"       # Defaults to '<VMName>azvm'
$AdminUser  =      "guruadmin"     # Defaults to Prompt User
$AdminPass   =     "AzurePortalR0cks"      # Defaults to Prompt User
$SubscriptionID  = "1942a221-7d86-4e10-9e4b-d5af2688651c"        # Subscription to create storage in

$DefaultPath = $env:TEMP 
$DefaultPath = "C:\_Data\Github\Azure-Research" 
Set-Location $DefaultPath
#> # End Set static variables

# More Defaults...
$NicName = "GuruNic01"
$Subnet1Name = "Subnet01"
$VNetName = "VNet-linux01"
$VNetAddressPrefix = "10.0.0.0/16"
$VNetSubnetAddressPrefix = "10.0.0.0/24"
$nsgName = "LinuxTestVM_DSC"

## Compute
$VMSize = "Standard_D2_v2"
$OSDiskName = $VMName + "OSDisk"

## Compute
# Display help... coming soon.
If ($help) { 
Write-Host "Display help and Examples here..."
        Write-Host " 
========= Create-AzureRmLinuxVM.ps1 ======================================= 
 Name: Create-AzureRmLinuxVM 
 Purpose: Create Linux (Ubuntu 16) VM and all supporting infrastructure on Azure using ResourceManager (without templates) 
    Also shows... 
       Using parameters and evaluating parameters - All parameters are optional
       Populating a GridView and allowing a user to select a subscription from list of available subs
       How to get various property values from the Azure subscription
       Overriding parameters with static values
       displaying -help content and using -help switch
       Creating Azure Network, NSG, Subnet, PublicIP
       Linking NSG to PublicIP
       Getting Credentials from user and converting text values to credentials
       Creating post machine script to run on a linux machine using CustomScriptExtension
     
 Author: Dan Stolts - dstolts&microsoft.com - http://ITProGuru.com
         Script Home: http://ITProGuru.com/Scripts 
 Syntax/Execution: 
      Copy portion of script you want to use and paste into PowerShell (or ISE)  
      ./Create-AzureRmLinuxVM.ps1  
      ./Create-AzureRmLinuxVM.ps1  -help
      ./Create-AzureRmLinuxVM.ps1  <Add optional parameters see below> 
      -Optional Parameters... sequence not important. The user is prompted for all parameters not supplied. : 
                    -SubscriptionID 12345-6789...        `# Pops a list 
                    -RGName myRgName                     `# Pops List to select default, creates if user cancels
                    -StorageAccountName mystoragename    `# Prompts user if not supplied
                    -Container myNewContainer            `# Folder/Container to create on storage account Defaults to registry
                    -ScriptsContainer registry           `# Folder/Container to create on storage account for storing scripts Defaults to scripts
                    -Location useast                     `# Defaults to Location of Resource Group or pops a list for user to select
                    -StorageSkuName 'Standard_LRS'      `# Defaults to 'Standard_LRS'
                    -VmName  myLinuxVMName              `# Defaults to 'DockerRegHost'
                    -VmDnsName AbcLinuxVM01             `# Defaults to '<VMName>azvm'
                    -AdminUser `"linuxAdmin`"           `# Defaults to Prompt User
                    -AdminPass `"My5upperP@ss`"         `# Defaults to Prompt User
                    -help                               `# Display Help
       
 Disclaimer: Use at your own Risk!  See details at http://ITProGuru.com/privacy  
 Limitations:  
        * If you do not already have an Azure connection, unremark the line below Add-AzureAccount
        * Must Run PowerShell (or ISE)  
        * UAC may get in the way depending on your settings (See: http://ITProGuru.com/PS-UAC) 
# See Also http://itproguru.com/expert/2016/04/powershell-working-with-azure-resource-manager-rm-step-by-step-changing-rm-subscriptions/
 ================================================================================ 
     More help goes here :)...

    " -ForegroundColor Green
    Break    # lets break out since they are displaying help
}
$CrLf = "`r`n"
$Quote = '"'
$StartTime = Get-Date -format HH:mm:ss
 
#Check if parameters supplied  
If ($SubscriptionID -eq "") {
    $subscriptionId = 
        (Get-AzureRmSubscription |
         Out-GridView `
            -Title "Select an Azure Subscription …" `
            -PassThru).SubscriptionId
}
$mySubscription=Select-AzureRmSubscription -SubscriptionId $subscriptionId
$SubscriptionName = $mySubscription.Subscription.SubscriptionName
Set-AzureRmContext -SubscriptionID $subscriptionId
Write-Host "Subscription: $SubscriptionName $subscriptionId " -ForegroundColor Green
# Select Azure Resource Group 

If ($RGName -eq "") {
    # have user select RG
    $myRG = (Get-AzureRmResourceGroup |
         Out-GridView `
            -Title "Select an Azure Resource Group …" `
            -PassThru)
    If (!($myRG -eq $null)) {
        $RGName = $myRG.ResourceGroupName  # Grab the ResourceGroupName
        $Location = $myRG.Location       # Grab the ResourceGroupLocation (region)
    }  #else user pressed escape, will need to create RG 
} 

# make sure the RG exists
$RgExists = Get-AzureRmResourceGroup | Where {$_.ResourceGroupName -eq $RGName }  # See if the RG exists.  If user pressed escape on drop box or passed a name that does not exist

# Make sure the RG Exists.  Create it if it does not (user pressed cancel above)
If (!($RgExists)) {
  write-host "Need to create New Resource Group " -ForegroundColor Yellow
    $RGName = Read-Host -Prompt 'What Name would you like to give your new Resource Group?'
} 
Else 
{  # Need to grab the location from the RG
    $RGName = $RGExists.ResourceGroupName  # Grab the ResourceGroupName
    $Location = $RGExists.Location       # Grab the ResourceGroupLocation (region)
    Write-Host "ResourceGroup $RGName in $Location on Account $SubscriptionID" -ForegroundColor Green}

If ($Location -eq "") {
    Write-Host "Select Region from the list to use for Resource Group" -ForegroundColor Yellow
    # Select Azure regions
    $regions = Get-AzureRmLocation  
    $Location =  ($regions | 
            Out-GridView `
            -Title "Select Azure Datacenter Region …" `
            -PassThru).location
} Write-Host "Location: $Location " -ForegroundColor Green

# Get/Set Storage Account Name
If ($StorageAccountName -eq "") {
    # Need to add a loop to check name and re-enter if not valid...
    # (!(Test-AzureName -Name $StorageAccountName -Storage))
    # If (!(Test-AzureName -Name $StorageAccountName -Service))
    $DefaultStorageAccountName = "DemoRM2016a" 
    Write-Host "Using $DefaultStorageAccountName for the Default if nothing entered" -ForegroundColor Yellow
        Write-Host "Please Enter the name you would like to use for the Storage Account!" -ForegroundColor Green
    $StorageAccountName = Read-Host -Prompt 'What Name would you like to give your new Storage Account?'
    If ($StorageAccountName -eq "") {$StorageAccountName = $DefaultStorageAccountName}
    }
    $StorageAccountName = $StorageAccountName.ToLower()    # Convert To Lower Case
    Write-Host "Storage Account Name: $StorageAccountName " -ForegroundColor Green
# Get/Set Storage Container Name
If ($Container -eq "") {
    $DefaultContainer = "registry" 
    Write-Host "Using $DefaultContainer for the Registry Container Name if nothing entered!" -ForegroundColor Yellow
    Write-Host "Please Enter the name you would like to use for the Storage Account!" -ForegroundColor Green
    $Container = $Container = Read-Host -Prompt 'What Name would you like to give your new Container?'
    If ($Container -eq "") {$Container = $DefaultContainer}
    }    
    $Container.ToLower()    # Convert To Lower Case
    Write-Host "Container: $Container " -ForegroundColor Green
# Get/Set Storage SKU Name
If ($StorageSkuName -eq "") {
    $DefaultStorageSkuName = "Standard_LRS"
    Write-Host "Using $DefaultStorageSkuName for the Default if nothing entered" -ForegroundColor Yellow
    Write-Host "Please Enter the name you would like to use for the Storage SKU!" -ForegroundColor Green
    $StorageSkuName = Read-Host -Prompt 'What SKU would you use for your new storage'
    If ($StorageSkuName -eq "") {$StorageSkuName = $DefaultStorageSkuName}
}   Write-Host "SKU: $StorageSkuName " -ForegroundColor Green
    
# Get/Set VM Name
If ($VmName -eq "") {
    $DefaultVmName = "DockerRegHost"
    Write-Host "Using $DefaultVmName for the Default if nothing entered" -ForegroundColor Yellow
    Write-Host "Please Enter the name you would like to use for the Docker Host Virtual Machine!" -ForegroundColor Green
    $VmName = Read-Host -Prompt 'What Name would you use for your Docker Host'
    If ($VmName -eq "") {$VmName = $DefaultVmName}
}   Write-Host "VM To Be Created: $VmName " -ForegroundColor Green
# Get/Set VM Public DNS Name
If ($VmDnsName -eq "") {
    $DefaultVmDnsName =  $VMName + "azvm"
    Write-Host "Using $DefaultVmDnsName for the Default if nothing entered. It must conform to the following regular expression: ^[a-z][a-z0-9-]{1,61}[a-z0-9]$" -ForegroundColor Yellow
    Write-Host "Please Enter the Public DNS name you would like to use for the Docker Host Virtual Machine!" -ForegroundColor Green
    $VmDnsName = Read-Host -Prompt 'What Public DNS Name would you use for your Docker Host'
    If ($VmDnsName -eq "") {$VmDnsName = $DefaultVmDnsName}
}   
$VmDnsName = $VmDnsName.ToLower()    # Convert To Lower Case
Write-Host "VM Public DNS Name: $VmDnsName " -ForegroundColor Green
# Get/Set Admin User Credentials
If ($AdminUser -eq "" -or $AdminPass -eq "") {
    Write-host "In the popup box, Please enter username and password you would like to use for the Virtual Machine" -ForegroundColor Yellow
    $Credential = Get-Credential  
    # Get-Credential will crash if user presses escape
    If ( $Credential -eq $null ) { 
        Write-host "Unable to continue without machine credentials" -ForegroundColor Red
        break 
        #Exit
    } 
}
Else {
    $AdminUser = "mylinuxadmin"
    $AdminPass = 'My5upperP@ss'
    $securePassword = ConvertTo-SecureString $AdminPass -AsPlainText -Force
    $Credential = New-Object System.Management.Automation.PSCredential ($AdminUser, $securePassword)
    }
        Write-Host "Credentials Entered! " -ForegroundColor Green

Write-Host "Starting Processing: $StartTime" -ForegroundColor Green 

#Create ResourceGroup 
If (!($RgExists)) {
    Write-Host "Creating ResourceGroup $RGName in $Location on Account $SubscriptionID" -ForegroundColor Green
    $Result = New-AzureRmResourceGroup -Name $RGName -location $Location 
    Start-Sleep -Seconds 10
    Write-Host "Finished Creating ResourceGroup $RGName in $Location on Account $SubscriptionID" -ForegroundColor Green
    $Result
}

#endregion Parameters and defaults
#region Create Storage Account and Containers
If (!(Test-AzureName -Name $StorageAccountName -Storage)) { 
    Write-host "StorageAccountName $StorageAccountName Passed" 
    If (!(Test-AzureName -Name $StorageAccountName -Service)) {  
        Write-host "Test-AzureName $StorageAccountName -Service Passed"
        Write-Host "Creating Storage Account $StorageAccountName ..." -ForegroundColor Green  
        $StorageAccount = New-AzureRMStorageAccount -Location $Location -StorageAccountName $StorageAccountName -ResourceGroupName $rgName -SkuName $StorageSkuName
        Start-Sleep -Milliseconds 1000
        Write-Host "Creating Container... " $Container  -ForegroundColor Green 
        $StorageAccountKey = (Get-AzureRmStorageAccountKey -ResourceGroupName $rgName -StorageAccountName $StorageAccountName).Value[0]
        Write-Host "Storage Key: $StorageAccountKey"  -ForegroundColor Green  
        $StorageAccountContext = New-AzureStorageContext -StorageAccountName $StorageAccountName -StorageAccountKey $StorageAccountKey 
        Write-Host "Set Default Store ..." $StorageAccountName  -ForegroundColor Green  
        #Set-AzureSubscription –SubscriptionId $subscriptionId -CurrentStorageAccount $StorageAccountName 
        #creates the container in your storage account.  
        #I am not checking if container already exists.  # you can check by get-storagecontainer and check for errors. 
        Write-Host "Creating Container ..." $Container  -ForegroundColor Green  
        New-AzureStorageContainer $Container -Permission Container -Context $StorageAccountContext
        #Also create a folder for scripts...
        Write-host "Creating Container... scripts on Azure  ... " -ForegroundColor Green
        New-AzureStorageContainer "scripts" -Permission Container -Context $StorageAccountContext 
        $StorageBlob = $StorageAccountContext.BlobEndPoint 
        $StorageBlob 
        # Copy file to new container...
        # Create temp file - A list of running services.
        $fileName = "TestRun.txt"
        $service = Get-Service | where {$_.status -eq "Running" } 
        $service | Format-Table name, status -auto | Out-File $fileName
        $dir = Get-Location
        $fqFileName = "$dir\$filename"
        Write-host "Testing Upload of $fqFileName"
        Set-AzureStorageBlobContent -Blob $fileName -Container $Container -File $fqFileName -Context $StorageAccountContext -Force  
        Set-AzureStorageBlobContent -Blob $fileName -Container "scripts" -File $fqFileName -Context $StorageAccountContext -Force  
        $UriFileName = $StorageAccountContext.BlobEndPoint + "scripts/" + $filename 
        Write-host "Uploaded $UriFileName" -ForegroundColor Green
        $UriTempFile = $UriFileName
    } Else {write-host "Storage Service Name $StorageAccountName is already used or invalid. Please choose a different name!" -ForegroundColor Red}  
} Else {Write-Host "Azure Service Name $StorageAccountName is already used. Please choose a different name!" -ForegroundColor Red} 

#endregion Create Storage account and Containers

$UriEndpoint = $StorageAccountContext.BlobEndPoint
$UriEndpoint += "scripts"
$UriEndpoint

$fileName = $VMName+".sh" 
$UriFileName = $StorageAccountContext.BlobEndPoint + "scripts/" + $filename
$PostInstallScript = "`sudo apt-get install wget 
`# Make a directory
sudo mkdir $HostAdminScriptsLocation
`#  Install wget .... http://www.computerhope.com/unix/wget.htm
sudo apt-get install wget
sudo apt-get upgrade -upgrade -y
# Download a file
sudo wget $UriFileName -P $HostAdminScriptsLocation
"
#$PostInstallScript = $PostInstallScript.Replace($CrLf,"`n")
$fqFileName = "$dir\$filename"
Out-File  -InputObject $PostInstallScript -Encoding utf8  -Filepath $fqFileName -Force 
Write-host "Created $fqFileName Attempting to upload to Azure 'scripts' container..." -ForegroundColor Green
Set-AzureStorageBlobContent -Blob $fileName -Container "scripts" -File $fqFileName -Context $StorageAccountContext -Force  
$UriFileName = $StorageAccountContext.BlobEndPoint + "scripts/" + $filename 
$myResult = Set-AzureStorageBlobContent -Blob $fileName -Container "scripts" -File $fqFileName -Context $StorageAccountContext -Force  
$myResult
$ConfigScriptUri = $StorageAccountContext.BlobEndPoint + "scripts/"+$fileName    # Post deployment script that will be executed on the new VM
$ConfigScriptFileName =  $fileName
Write-host "Docker Configuration script uploaded to Azure...$ConfigScript" -ForegroundColor Green
Write-host "Uploaded $UriFileName" -ForegroundColor Green
notepad.exe $fqFileName
#endregion Create and Upload Scripts

#region Create Network Infrastructure 
# https://azure.microsoft.com/en-us/documentation/articles/virtual-machines-windows-ps-create/
# https://azure.microsoft.com/en-us/documentation/articles/virtual-network-deploy-static-pip-arm-ps/
Write-host "Creating Network in Azure..." -ForegroundColor Green
$SubnetConfig = New-AzureRmVirtualNetworkSubnetConfig -Name $Subnet1Name -AddressPrefix $VNetSubnetAddressPrefix
$VNet = New-AzureRmVirtualNetwork -Name $VNetName -ResourceGroupName $rgName -Location $Location -AddressPrefix $VNetAddressPrefix -Subnet $SubnetConfig
$PIp = New-AzureRmPublicIpAddress -Name $NicName -ResourceGroupName $rgName -Location $Location -AllocationMethod Dynamic -DomainNameLabel $VmDnsName 
$nic = New-AzureRmNetworkInterface -Name $NicName -ResourceGroupName $rgName -Location $Location -SubnetId $vnet.Subnets[0].Id  -PublicIpAddressId $PIp.Id
$VNet = Get-AzureRmVirtualNetwork -Name $VNetName -ResourceGroupName $rgName 
#endregion Create Network Infrastructure 

Write-host "Now Let's Configure our Host ... " -ForegroundColor Green
#Now let's create the VM
# Compute
#Get-AzureVMImage | format-table publishername, Label, RecommendedVMSize, ImageName |out-file "images.txt"
#notepad.exe "images.txt"
#Ubuntu from Canonical...
#Get-AzureRmVMImagePublisher -Location $Location #Find Publishers
#Get-AzureRmVMImageOffer -Location $Location -PublisherName "Canonical" #Find Offers for this publisher 
#Get-AzureRmVmImageSku -Location $Location -PublisherName "Canonical" -Offer "UbuntuServer" # Get Skus
## Setup local VM object
#$StorageAccount = Get-AzureRMStorageAccount  $StorageAccountName -ResourceGroupName $rgName 
Write-host "Creating Virtual Machine Configuration ... " -ForegroundColor Green
$VmConfig = New-AzureRmVMConfig -VMName $VmName -VMSize $VMSize
$VmConfig = Set-AzureRmVMOperatingSystem -VM $VmConfig -ComputerName $VMName -Linux -Credential $Credential
$VmConfig = Set-AzureRmVMSourceImage  -VM $VmConfig -PublisherName "Canonical" -Offer "UbuntuServer" -Skus "16.04.0-LTS" -Version "latest"
$vmConfig = Add-AzureRmVMNetworkInterface -VM $vmConfig -Id $nic.Id

$OSDiskUri = $StorageAccount.PrimaryEndpoints.Blob.ToString() + "vhds/" + $OSDiskName + ".vhd"
$VmConfig = Set-AzureRmVMOSDisk -VM $VmConfig -Name $OSDiskName -VhdUri $OSDiskUri -CreateOption FromImage

## Create the VM in Azure
Write-host "Creating Virtual Machine In Azure ... " -ForegroundColor Green
$vmStatus = New-AzureRmVM -ResourceGroupName $rgName  -VM $VmConfig -Location $Location
$vm = Get-AzureRMVM -ResourceGroupName $rgName -Name $VmName
Write-host "Virtual Machine $VMName created In Azure ... " -ForegroundColor Green
$vmStatus


#Install Azure VM Custom Extensions    #http://www.techdiction.com/2016/02/12/create-a-custom-script-extension-for-an-azure-resource-manager-vm-using-powershell/
Write-host "Install CustomScriptForLinux Extension for $VmName  ... " -ForegroundColor Green
$VmName = $vm.Name
$ExtensionName = 'CustomScriptForLinux'
$Publisher = 'Microsoft.OSTCExtensions'
$Version = '1.5'      # Latest version https://github.com/Azure/azure-linux-extensions/tree/master/CustomScript 

$PublicConf = '{
    "fileUris": ["$ConfigScriptUri"],
    "commandToExecute": "sh '+$ConfigScriptFileName+'"
}'
$PrivateConf = '{"storageAccountName": "'+$StorageAccount.StorageAccountName+'","storageAccountKey": "'+$StorageAccountKey+'"}'
<#
Set-AzureRmVMExtension -ResourceGroupName $rgName -VMName $VmName -Location $Location `
  -Name $ExtensionName -Publisher $Publisher `
  -ExtensionType $ExtensionName -TypeHandlerVersion $Version `
  -Settingstring $PublicConf -ProtectedSettingString $PrivateConf
#>

#region Create Network Security Group NSG
# Default rules will be created when we create the NSG 
Write-host "VM Post configuration is executing... Creating Network Security Group in Azure..." -ForegroundColor Green
New-AzureRmNetworkSecurityGroup -Location $Location -Name $nsgName -ResourceGroupName $rgName -Force  #Create NSG
Write-host "Network Security Group created, creating Firewall/NSG Rules in Azure..." -ForegroundColor Green

#Probably should optimize performance on this next section at some point 
# Enable ssh
Write-host "Creating ssh port 22 Firewall/NSG Rules in Azure... $nsgName" -ForegroundColor Green
Get-AzureRmNetworkSecurityGroup -Name $nsgName -ResourceGroupName $rgName | `
   Add-AzureRmNetworkSecurityRuleConfig -Name "SSH-Rule" -Description "Allow ssh" -Access "Allow" -Protocol "Tcp" -Direction "Inbound" -Priority 2010 -SourceAddressPrefix "Internet" -SourcePortRange "*" -DestinationAddressPrefix "*" -DestinationPortRange "22" | Set-AzureRmNetworkSecurityGroup
#Enable DSC 5896
Write-host "Creating DSC port 5896 Firewall/NSG Rules in Azure... $nsgName" -ForegroundColor Green
Get-AzureRmNetworkSecurityGroup -Name $nsgName -ResourceGroupName $rgName | `
   Add-AzureRmNetworkSecurityRuleConfig -Name "DSCLinux-HTTPS" -Description "Allow DSC HTTPS to 5896" -Access "Allow" -Protocol "Tcp" -Direction "Inbound" -Priority 2011 -SourceAddressPrefix "*" -SourcePortRange "*" -DestinationAddressPrefix "*" -DestinationPortRange "5896" | Set-AzureRmNetworkSecurityGroup
#Enable HTTPS IN 80
Write-host "Creating HTTP port 80 Inbound Firewall/NSG Rules in Azure... $nsgName" -ForegroundColor Green
Get-AzureRmNetworkSecurityGroup -Name $nsgName -ResourceGroupName $rgName | `
   Add-AzureRmNetworkSecurityRuleConfig -Name "HTTP-in" -Description "Allow HTTP 80 in" -Access "Allow" -Protocol "Tcp" -Direction "Inbound" -Priority 2031 -SourceAddressPrefix "Internet" -SourcePortRange "*" -DestinationAddressPrefix "*" -DestinationPortRange "80" | Set-AzureRmNetworkSecurityGroup
#Enable HTTPS IN 443
Write-host "Creating HTTPS port 443 Inbound Firewall/NSG Rules in Azure... $nsgName" -ForegroundColor Green
Get-AzureRmNetworkSecurityGroup -Name $nsgName -ResourceGroupName $rgName | `
   Add-AzureRmNetworkSecurityRuleConfig -Name "HTTPS-in" -Description "Allow HTTPS 443 in" -Access "Allow" -Protocol "Tcp" -Direction "Inbound" -Priority 2032 -SourceAddressPrefix "Internet" -SourcePortRange "*" -DestinationAddressPrefix "*" -DestinationPortRange "443" | Set-AzureRmNetworkSecurityGroup
#Enable HTTPS out 443
Write-host "Creating HTTPS port 443 Outbound Firewall/NSG Rules in Azure... $nsgName" -ForegroundColor Green
Get-AzureRmNetworkSecurityGroup -Name $nsgName -ResourceGroupName $rgName | `
   Add-AzureRmNetworkSecurityRuleConfig -Name "HTTPS-out" -Description "Allow HTTPS 443 out" -Access "Allow" -Protocol "Tcp" -Direction "Outbound" -Priority 2033 -SourceAddressPrefix "Internet" -SourcePortRange "*" -DestinationAddressPrefix "*" -DestinationPortRange "443" | Set-AzureRmNetworkSecurityGroup


Write-host "Linking NSG $nsgName to Subnet $Subnet1name in Azure..." -ForegroundColor Green
# Associate NSG to selected Subnet
$subnet = $vnet.Subnets | Where-Object Name -eq $Subnet1Name  # we will need the subnet to attach the NSG
Set-AzureRmVirtualNetworkSubnetConfig `
    -VirtualNetwork $vnet `
    -Name $subnet.Name `
    -AddressPrefix $subnet.AddressPrefix `
    -NetworkSecurityGroup $nsg |
Set-AzureRmVirtualNetwork
#
Write-host "Done Creating NSG and Rules ... $nsgName" -ForegroundColor Green
#endregion Create Network Security Group NSG

Write-host "Installation complete!  $VMName created and $ConfigScript is being executed  ... " -ForegroundColor Green
Write-host "It could take 10 mins or more for the script to fully configure. " -ForegroundColor Green
Write-host "You can login to your new machine using ssh on port 22 (with Putty or other ssh tool) with the credentials you supplied. " -ForegroundColor Green
Write-host "Your public connection information is:" ($pip.DnsSettings.Fqdn) -ForegroundColor Yellow


$FinishTime = Get-Date -format HH:mm:ss
$TimeDiff = New-TimeSpan $StartTime $FinishTime
	$Hrs = $TimeDiff.Hours
	$Mins = $TimeDiff.Minutes
	$Secs = $TimeDiff.Seconds 
$Difference = '{0:00}:{1:00}:{2:00}' -f $Hrs,$Mins,$Secs
Write-host "Total Duration hh:mm:sec $Difference"

