<#

Author:  Bryan Cafferky 2013-12-17 

Purpose:  Fun with SQL Server.  It's not what you expect.

#>

#  Import the SQL Server module
# remove-module “sqlps”
Import-Module “sqlps” -DisableNameChecking

<#  
     Let's look at the available cmdlets...
#>
Cls

Get-Command -Module sqlps | Out-GridView 


Invoke-Sqlcmd -Query "SELECT @@VERSION;" -QueryTimeout 3 -ServerInstance "(local)"

# Set where you are in SQL Server...
set-location SQLSERVER:\SQL\DESKTOP-TG2VLSU\DEFAULT\Databases\Adventureworks2016\Tables

Dir

Get-ChildItem | Out-Gridview

$outpath = $env:HOMEDRIVE + $env:HOMEPATH + "\Documents\tables.sql"

# Generate the table create statements...
 foreach ($Item in Get-ChildItem) {$Item.Script() | Out-File -Filepath $outpath -Append }

# List tables in the Sales schema...
Get-ChildItem | Where-Object {$_.Schema -eq "Sales"}

# get-help sqlserver > C:\Users\BryanCafferky\Documents\BI_UG\PowerShell\Examples\Data\ps_sqlserver.txt

#  Query the database...
Invoke-Sqlcmd -Query "SELECT top 100 * from person.person;" -QueryTimeout 3 | Out-GridView 

# Direct query results to CSV file...
$outpath2 = $env:HOMEDRIVE + $env:HOMEPATH + "\Documents\dataout.csv"

Invoke-Sqlcmd -Query "SELECT top 100 businessentityid, firstname, lastname  from person.person;" -QueryTimeout 3 | Export-CSV $outpath2 -notype

     
       