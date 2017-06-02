#login to your azure account
Login-AzureRmAccount

#variable for Db creation
$id = [Guid]::NewGuid().ToString("n").SubString(0,8)
$resourceGroupName = $id + "-rg"
$location = "eastus"
$serverName = "dbserver" + $id
$databaseName = "db" + $id
$adminlogin = "ServerAdmin"
$password = "ChangeYourAdminPassword1"

#Get your client ip
$externalIp = Invoke-WebRequest ifconfig.me/ip | Select -ExpandProperty Content 
$externalIp = $externalIp -replace "`t|`n|`r",""
$externalIp =  $externalIp -replace  " ;|; ",";"

#create a new resource group to use
New-AzureRmResourceGroup -Name $resourceGroupName -Location $location

# Create the server
New-AzureRmSqlServer -ResourceGroupName $resourceGroupName `
    -ServerName $serverName `
    -Location $location `
    -SqlAdministratorCredentials $(New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $adminlogin, $(ConvertTo-SecureString -String $password -AsPlainText -Force))

# Add a firewall rule
New-AzureRmSqlServerFirewallRule -ResourceGroupName $resourceGroupName `
    -ServerName $serverName `
    -FirewallRuleName "AllowSome" -StartIpAddress $externalIp -EndIpAddress $externalIp

# Create a new database
New-AzureRmSqlDatabase  -ResourceGroupName $resourceGroupName `
    -ServerName $serverName `
    -DatabaseName $databaseName `
    -RequestedServiceObjectiveName "S0"

# requires Sql Server Management Tools/Studio to be installed
Import-Module SQLPS

# Use PowerShell to create a login for the web app
$serverConnection = new-object Microsoft.SqlServer.Management.Common.ServerConnection
$serverConnection.ServerInstance=$serverName + ‘.database.windows.net’
$serverConnection.LoginSecure = $false
$serverConnection.Login = $adminlogin
$serverConnection.Password = $password

[System.Reflection.Assembly]::LoadWithPartialName('Microsoft.SqlServer.SMO') | Out-Null
$SqlServer = New-Object 'Microsoft.SqlServer.Management.Smo.Server' ($serverName + ‘.database.windows.net’)

Add-Type -Path "C:\Program Files\Microsoft SQL Server\130\SDK\Assemblies\Microsoft.SqlServer.Smo.dll"
$SqlServer = New-Object Microsoft.SqlServer.Management.Smo.Server($mySrvConn)

# get all of the current logins and their types
$SqlServer.Logins | Select-Object Name, LoginType, Parent

# create a new login by prompting for new credentials
$NewLoginCredentials = Get-Credential -Message "Enter credentials for the new login"
$NewLogin = New-Object Microsoft.SqlServer.Management.Smo.Login($serverName, $NewLoginCredentials.UserName)
$NewLogin.LoginType = [Microsoft.SqlServer.Management.Smo.LoginType]::SqlLogin
$NewLogin.Create($NewLoginCredentials.Password)
 
# create a new database user for the newly created login
$NewUser = New-Object Microsoft.SqlServer.Management.Smo.User($SqlServer.Databases[$databaseName], $NewLoginCredentials.UserName)
$NewUser.Login = $NewLoginCredentials.UserName
$NewUser.Create()
$NewUser.AddToRole("db_datareader") 
$NewUser.AddToRole("db_datawriter") 
$NewUser.AddToRole("db_ddladmin") 

# remove all resources in resource group
Remove-AzureRmResourceGroup -ResourceGroupName $resourceGroupName
