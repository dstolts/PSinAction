# Clear Cached Azure Accounts (Remove old accounts from your PowerShell) 
Get-AzureAccount | ForEach-Object { Remove-AzureAccount $_.ID -Force } 
Get-AzureSubscription
# To add an account back in use Add-AzureAccount
Write-Host " Script Home: http://ITProGuru.com/Scripts" -ForegroundColor Red
# See Also http://itproguru.com/expert/2016/04/powershell-working-with-azure-resource-manager-rm-step-by-step-changing-rm-subscriptions/
