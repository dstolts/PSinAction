<#

Creating an application service principal...

https://docs.microsoft.com/en-us/azure/azure-resource-manager/resource-group-authenticate-service-principal


Find in Portal under Active Directory/App Registrations.

Note:  To use a profile to log in see the link below.

   https://ronbokleman.wordpress.com/2016/04/05/azure-powershell-arm-profile-3/

#>

function New-udfAzureServicePrincipal   
{
   [CmdletBinding()] 
   Param (
   
    # Use to set scope to resource group. If no value is provided, scope is set to subscription.
    [Parameter(Mandatory=$false)]
    [String] $ResourceGroup,
   
    # Use to set subscription. If no value is provided, default subscription is used. 
    [Parameter(Mandatory=$false)]
    [String] $SubscriptionId,
   
    [Parameter(Mandatory=$true)]
    [String] $ApplicationDisplayName,
   
    [Parameter(Mandatory=$true)]
    [String] $Password
    )

   # Add-AzureRmAccount

    Import-Module AzureRM.Resources
    
    if ($SubscriptionId -eq "") 
    {
       $SubscriptionId = (Get-AzureRmContext).Subscription.SubscriptionId
    }
    else
    {
       Set-AzureRmContext -SubscriptionId $SubscriptionId
    }
    
    if ($ResourceGroup -eq "")
    {
       $Scope = "/subscriptions/" + $SubscriptionId
    }
    else
    {
       $Scope = (Get-AzureRmResourceGroup -Name $ResourceGroup -ErrorAction Stop).ResourceId
    }
    
    # Create Active Directory application with password
    $Application = New-AzureRmADApplication -DisplayName $ApplicationDisplayName -HomePage ("http://" + $ApplicationDisplayName) -IdentifierUris ("http://" + $ApplicationDisplayName) -Password $Password -Verbose
    
    # Create Service Principal for the AD app
    $ServicePrincipal = New-AzureRMADServicePrincipal -ApplicationId $Application.ApplicationId 
    Get-AzureRmADServicePrincipal -ObjectId $ServicePrincipal.Id 
    
    $NewRole = $null
    $Retries = 0;

    While ($NewRole -eq $null -and $Retries -le 6)
    {
       # Sleep here for a few seconds to allow the service principal application to become active (should only take a couple of seconds normally)
       Sleep 15
       New-AzureRMRoleAssignment -RoleDefinitionName Owner -ServicePrincipalName $Application.ApplicationId -Scope $Scope | Write-Verbose -ErrorAction SilentlyContinue
       $NewRole = Get-AzureRMRoleAssignment -ServicePrincipalName $Application.ApplicationId -ErrorAction SilentlyContinue
       $Retries++;
    }

    Return $Application

 }

Clear-Host

$ApplicationDisplayName = "DemoApp1"
$Password = "DemoApp1?"
 
#  We need to get the Application object so we can get the ApplicationID
$myapp = New-udfAzureServicePrincipal -ApplicationDisplayName $ApplicationDisplayName -Password $Password      

#  The returned application object can give us the ApplicationID which we need.

<#

DisplayName                    Type                           ObjectId                               
-----------                    ----                           --------                               
DemoApp                        ServicePrincipal               5e5d252b-c780-4cb6-a7aa-e8eace52b35e   



ApplicationID = 9e12341c-4644-4261-8609-14822051df39

$myapp.ApplicationID

$tenantid = (Get-AzureRmSubscription -SubscriptionName "Free Trial").TenantId

$creds = Get-Credential

Add-AzureRmAccount -Credential $creds -ServicePrincipal -TenantId $tenantid

Stop-AzureRmVM -Name 'Demo3VM' -ResourceGroupName "Demo3RG" -Force

#>

