Connect-ServiceFabricCluster localhost:19000

#Test-ServiceFabricApplicationPackage -ApplicationPackagePath "C:\Temp\WordCount\" -ApplicationParameter @{ "WordCountWebService_InstanceCount"="-1"}

## Copy and register
Copy-ServiceFabricApplicationPackage C:\Temp\WordCount\ -ImageStoreConnectionString file:C:\SfDevCluster\Data\ImageStoreShare -ApplicationPackagePathInImageStore WordCount
Register-ServiceFabricApplicationType WordCount
# Get-ServiceFabricApplicationType

### Create a new service
New-ServiceFabricApplication fabric:/WordCount WordCount 1.0.0
#Get-ServiceFabricApplication | Get-ServiceFabricService

### Rolling upgrade
Copy-ServiceFabricApplicationPackage C:\Temp\WordCountV2\ -ImageStoreConnectionString file:C:\SfDevCluster\Data\ImageStoreShare -ApplicationPackagePathInImageStore WordCountV2
Register-ServiceFabricApplicationType WordCountV2
Start-ServiceFabricApplicationUpgrade -ApplicationName fabric:/WordCount -ApplicationTypeVersion 2.0.0 -HealthCheckStableDurationSec 60 `
                                      -UpgradeDomainTimeoutSec 1200 -UpgradeTimeout 3000  -FailureAction Rollback -Monitored

### Monitor upgrade
Get-ServiceFabricApplicationUpgrade fabric:/WordCount

### Test the Service
$timeToRun = 3
$maxStabilizationTimeSecs = 60
$concurrentFaults = 5
$waitTimeBetweenIterationsSec = 20
$now = [System.DateTime]::UtcNow

Start-ServiceFabricChaos -TimeToRunMinute $timeToRun -MaxConcurrentFaults $concurrentFaults -MaxClusterStabilizationTimeoutSec $maxStabilizationTimeSecs `
                         -EnableMoveReplicaFaults -WaitTimeBetweenIterationsSec $waitTimeBetweenIterationsSec

Get-ServiceFabricChaosReport -StartTimeUtc $now -EndTimeUtc ([System.DateTime]::MaxValue)

Stop-ServiceFabricChaos

### Remove the service
Remove-ServiceFabricApplication fabric:/WordCount
Unregister-ServiceFabricApplicationType WordCount 1.0.0
Unregister-ServiceFabricApplicationType WordCount 2.0.0
Remove-ServiceFabricApplicationPackage -ImageStoreConnectionString file:C:\SfDevCluster\Data\ImageStoreShare -ApplicationPackagePathInImageStore WordCount
Remove-ServiceFabricApplicationPackage -ImageStoreConnectionString file:C:\SfDevCluster\Data\ImageStoreShare -ApplicationPackagePathInImageStore WordCountV2
