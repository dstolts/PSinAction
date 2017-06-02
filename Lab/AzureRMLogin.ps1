 # Sign-in with Azure account credentials
#Add-AzureAccount   # This adds (caches) your Azure account in PowerShell classic 
Add-AzureRmAccount # This adds (caches) your Azure account in PowerShell RM
Login-AzureRmAccount # This logs into Azure Resource Manager Account
# now you can run commands
Get-AzureRmSubscription
# to set the default subscription use
# Set-AzureRmContext -SubscriptionID <subscriptionId>
