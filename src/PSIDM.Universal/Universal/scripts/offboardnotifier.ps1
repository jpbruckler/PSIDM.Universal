$job            = Get-PSUScript -Name 'offboard.ps1' | Get-PSUJob -OrderDirection Descending -First 1
$jobOutput      = Get-PSUJobOutput -Job $job
$jobPipeline    = Get-PSUJobPipelineOutput -Job $job

# offboard.ps1 is going to have to output status messages to the console and drop
# them into the pipeline. Then they can be retrieved.