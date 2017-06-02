
# Sign-in with Azure account credentials

Login-AzureRmAccount

# Select Azure Subscription

$subscriptionId = 
    (Get-AzureRmSubscription |
     Out-GridView `
        -Title "Select an Azure Subscription" `
        -PassThru).SubscriptionId

Select-AzureRmSubscription `
    -SubscriptionId $subscriptionId

# Select Azure Resource Group 

$rgName =
    (Get-AzureRmResourceGroup |
     Out-GridView `
        -Title "Select an Azure Resource Group" `
        -PassThru).ResourceGroupName

#Download Azure Public IP Address Ranges
#
#Next, you’ll need to download the list of Azure public IP address ranges in XML format.  
#From this raw XML, you can then extract the list of Azure regions and corresponding public IP address blocks.


# Download current list of Azure Public IP ranges
# See this link for latest list

$downloadUri = "https://www.microsoft.com/en-in/download/confirmation.aspx?id=41653"
$downloadPage = Invoke-WebRequest -Uri $downloadUri 
$xmlFileUri =   ($downloadPage.RawContent.Split('"') -like "https://*PublicIps*")[0]
$response =   Invoke-WebRequest -Uri $xmlFileUri

# Get list of regions & public IP ranges

[xml]$xmlResponse = [System.Text.Encoding]::UTF8.GetString($response.Content)
$regions = $xmlResponse.AzurePublicIpAddresses.Region
$regions



#Define NSG rules for Allowed Outbound Access
# Now that you have the raw Public IP Address ranges in a list that you can leverage, it’s pretty easy to select the appropriate Azure region and loop through creating an outbound rule for each related public IP address range.


# Select Azure regions for which to define NSG rules
$selectedRegions =  $regions.Name | 
     Out-GridView `
        -Title "Select Azure Datacenter Regions …" `
        -PassThru

$ipRange = ( $regions | where-object Name -In $selectedRegions ).IpRange
$ipRange[0]

# Build NSG rules
$rulesSave = @()
$rules = @()
$rulePriority = 1000

ForEach ($subnet in $ipRange.Subnet) {
    $ruleName = "Allow_Azure_Out_" + ($subnet.Replace("/","-"))
      write-host "$RulePriority Allow_Azure_Out_"$subnet.Replace("/","-")
    #Let's only grab the first 25 for performance reasons.  
    #but we will loop through all of them just to   
    if ($Rules.Count -lt 20 ){
        # Max 200 rules, we could just save the rules or create an array of the rules and process the array and then create additional NSGs if needed 
        #$rulesSave = $rules
        #$rules = @()
      $rules += New-AzureRmNetworkSecurityRuleConfig `
            -Name $ruleName `
            -Description "Allow outbound to Azure $subnet" `
            -Access Allow `
            -Protocol * `
            -Direction Outbound `
            -Priority $rulePriority `
            -SourceAddressPrefix VirtualNetwork `
            -SourcePortRange * `
            -DestinationAddressPrefix "$subnet" `
            -DestinationPortRange *
       }
    $rulePriority++
  }

$rules.count; $rulePriority



#Note: After defining these Azure-related outbound rules, you may need to add some additional rules to permit outbound access to other legitimate non-Azure services, 
#    such as public DNS servers, email services, APIs, etc, that your applications may also need to access.  Just add to the bottom of this script.
#Deny All Other Outbound Access to Internet

#After the “allow” rules are defined, you can add a final “deny” rule to block all other outbound Internet access – just make sure that this rule is created with a larger priority value than your “allow” rules above so that it doesn’t block legitimate outbound traffic.
# Define deny rule for all other traffic to Internet
$rules += 
    New-AzureRmNetworkSecurityRuleConfig `
        -Name "Deny_Internet_Out" `
        -Description "Deny outbound to Internet" `
        -Access Deny `
        -Protocol * `
        -Direction Outbound `
        -Priority 4001 `
        -SourceAddressPrefix VirtualNetwork `
        -SourcePortRange * `
        -DestinationAddressPrefix Internet `
        -DestinationPortRange *

#Create the Network Security Group
# After you’ve defined all the necessary rules, create the Network Security Group to include all of the rules as a single NSG.  
#    This makes it easy to apply all of these rules, as a group, to the necessary subnets and/or network interfaces.

# Set Azure region in which to create NSG

$location = "eastus"

# Create Network Security Group
$nsgName = "Allow_Azure_Out"
$nsg = New-AzureRmNetworkSecurityGroup -Name "$nsgName" -ResourceGroupName $rgName  -Location $Location  -SecurityRules $rules

#Associate the Network Security Group
#You’ve created a new custom NSG, and now you can use either the Azure Portal 
#  or Azure PowerShell to associate this NSG with the appropriate subnets 
#  or network interfaces within your VNET to restrict outbound access to 
#  only permitted public IP address ranges for Azure services in the selected region.

# Select VNET
$vnetName = (Get-AzureRmVirtualNetwork `
        -ResourceGroupName $rgName).Name |
     Out-GridView `
        -Title "Select an Azure VNET …" `
        -PassThru

$vnet = Get-AzureRmVirtualNetwork -ResourceGroupName $rgName -Name $vnetName

# Select Subnet 

$subnetName = 
    $vnet.Subnets.Name |
    Out-GridView `
        -Title "Select an Azure Subnet …" `
        -PassThru

$subnet = $vnet.Subnets | 
    Where-Object Name -eq $subnetName

# Associate NSG to selected Subnet

Set-AzureRmVirtualNetworkSubnetConfig `
    -VirtualNetwork $vnet `
    -Name $subnetName `
    -AddressPrefix $subnet.AddressPrefix `
    -NetworkSecurityGroup $nsg |
Set-AzureRmVirtualNetwork

#Alternatively, to associate the new NSG with a subnet or network interface via the Azure Portal, select Browse > Network Security Groups > select your NSG > All Settings, and then select either the Subnets blade to associate the NSG to a subnet or the Network interfaces blade to associate the NSG to a particular VM network interface.
