param(
    [switch] $Rebase
)
$AppToken = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJodHRwOi8vc2NoZW1hcy54bWxzb2FwLm9yZy93cy8yMDA1LzA1L2lkZW50aXR5L2NsYWltcy9uYW1lIjoidTU1Mzk4YiIsImh0dHA6Ly9zY2hlbWFzLnhtbHNvYXAub3JnL3dzLzIwMDUvMDUvaWRlbnRpdHkvY2xhaW1zL2hhc2giOiIyZDUzZjI4Yy1jNzQ3LTQ3MjItOGE2Yy1hYzk0M2JlMTE2ZWUiLCJzdWIiOiJQb3dlclNoZWxsVW5pdmVyc2FsIiwiaHR0cDovL3NjaGVtYXMubWljcm9zb2Z0LmNvbS93cy8yMDA4LzA2L2lkZW50aXR5L2NsYWltcy9yb2xlIjoiQWRtaW5pc3RyYXRvciIsIm5iZiI6MTY5NDY5OTg1OCwiZXhwIjoyMTQ1OTM0ODAwLCJpc3MiOiJJcm9ubWFuU29mdHdhcmUiLCJhdWQiOiJQb3dlclNoZWxsVW5pdmVyc2FsIn0.Ts-HKq7NuKjWHgj1yAOu3-te3p93h_U3394wwHyD2UU'
$Url      = 'https://svr-psu-app.psudev.local'
$AppName  = 'PSIDM.Universal'
$SrcRoot  = "D:\dev\PSIDM.Universal\src\PSIDM.Universal\"
$DestRoot = "D:\UniversalAutomation\Repository\Modules"
$Manifest = Import-PowerShellDataFile (Resolve-Path $SrcRoot\*.psd1).Path

# Do not change below this line
# =============================================================================

$DestPath = "{0}\{1}\{2}" -f $DestRoot, ($SrcRoot | Split-Path -Leaf), $Manifest.ModuleVersion
Write-Information $DestPath -InformationAction Continue
if ($Rebase) {
    try {
        Remove-Item -Path ($DestPath | Split-Path -Parent) -Force -Recurse -ErrorAction Stop
        $null = New-Item -Path $DestPath -ItemType Directory
    }
    catch {
        $Message = 'Rebase switch specified, but unable to delete existing destination directory: {0}' -f ($DestPath | Split-Path -Parent)
        Write-Error $Message
        return 1
    }
}

Write-Information "Copying files from $SrcRoot to $DestPath..." -InformationAction Continue
Copy-Item -Path $SrcRoot -Destination $DestRoot -Recurse -Force

try {
    Write-Information -MessageData "Connecting to $Url..." -InformationAction Continue    
    $null = Connect-PSUServer -ComputerName $Url -AppToken $AppToken -ErrorAction Stop
}
catch {
    Write-Error "Unable to connect to Univeral Server. Run Connect-PSUServer locally for additional troubleshooting."
    return
}

if ([string]::IsNullOrEmpty($AppName) -eq $false) {
    Write-Information "Restarting '$AppName' app..." -InformationAction Continue
    Get-PSUapp -Name $AppName | Stop-PSUApp
    Get-PSUapp -Name $AppName | Start-PSUApp
}

Write-Information 'Complete.' -InformationAction Continue