Import-Module test_mod 

Get-Help Out-UdfSpeech

Invoke-UdfSQLStatement -Server '(local)' -Database 'Development' -SQL 'select top 10 * from dbo.orders' -IsSelect 
