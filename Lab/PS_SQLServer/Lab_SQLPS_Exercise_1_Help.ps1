Import-Module “sqlps” -DisableNameChecking

<#  
     Let's get the SQL Server Version of (local)...
#>

Invoke-Sqlcmd -Query "SELECT @@VERSION;" -QueryTimeout 3 -ServerInstance "(local)"
