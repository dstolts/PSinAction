# Lab 1 - Reuse - Creating an Advanced Function

function Out-udfHelloWorld
{ 
 [CmdletBinding()]
        param ( )

   Write-Host "Always Displays"

   Write-Verbose "Hello World"
  
}

# Call the function...
Out-udfHelloWorld -Verbose