function Initialize-PSIDMConfig {
    param(
        [switch] $Force
    )
    $configDir  = (Split-Path $PSScriptRoot) -Replace 'Private','conf'
    $configPath = Join-Path $configDir -ChildPath 'config.json'

    if (-not (Test-Path $configPath) -or $Force) {
        $config = @{
            'PSIDM' = @{
                'AD' = @{
                    'Domain' = @{
                        'Name' = 'contoso.com'
                    }
                }
            }
        }
        $config | ConvertTo-Json | Out-File -FilePath $configPath -Force
    }
}