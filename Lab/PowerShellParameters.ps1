# Working with PowerShell Parameters
# you could use positional values or specifically call them out by name. see help below

 Param (
    [Parameter(Mandatory=$false)][string]$myString1,              # Defaults to Location of Resource Group
    [Parameter(Mandatory=$false)][string]$myString2,              # another string
    [Parameter(Mandatory=$false)][switch]$help                    # switch... If -help it is there, the value will be $true
)  

Write-host "Evaluate parameters"
If ($myString1 -eq "") {
    # do something
    Write-Host "Parameter myString1 is empty"
    }
Write-Host "myString1 is: $myString1"

If ($myString2 -eq "") { # do something  
Write-Host "Parameter myString2 is empty"  }
Write-Host "myString2 is: $myString2"

# Display help... coming soon.
If ($help) { 
    Write-Host "Display help and Examples here..."
    Write-Host "...
       ./PowerShellParameters.ps1 "String1 Value" "String 2 Value" -help 
       ./PowerShellParameters.ps1 -myString2 "String 2 Value" -help -myString1 "String 1 Value" 
        
       [Parameter(Mandatory=$false)][string]$myString1,  `# A string value  
       [Parameter(Mandatory=$false)][string]$myString2,  `# another string  
       [Parameter(Mandatory=$false)][switch]$helpÂ       `# switch... If it is there, the value will be $true
    " -ForegroundColor Green
} 

