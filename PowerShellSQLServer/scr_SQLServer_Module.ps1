<#

  blog on error loading SQLServer module
  https://social.technet.microsoft.com/Forums/office/en-US/8bc448a7-3484-468c-905a-009a1d73d9ec/connecting-to-sql-server-through-powershell?forum=winserverpowershell

#>

Install-Module -Name SQLServer -Force

Import-Module SQlServer -Force

try {add-type -AssemblyName "Microsoft.SqlServer.ConnectionInfo, Version=10.0.0.0, Culture=neutral, PublicKeyToken=89845dcd8080cc91" -EA Stop}
catch {add-type -AssemblyName "Microsoft.SqlServer.ConnectionInfo"}

try {add-type -AssemblyName "Microsoft.SqlServer.Smo, Version=10.0.0.0, Culture=neutral, PublicKeyToken=89845dcd8080cc91" -EA Stop; $smoVersion = 10}
catch {add-type -AssemblyName "Microsoft.SqlServer.Smo"; $smoVersion = 9}

try
{
    try {add-type -AssemblyName "Microsoft.SqlServer.SMOExtended, Version=10.0.0.0, Culture=neutral, PublicKeyToken=89845dcd8080cc91" -EA Stop}
    catch {add-type -AssemblyName "Microsoft.SqlServer.SMOExtended" -EA Stop}
}
catch {Write-Warning "SMOExtended not available"}