function ConvertTo-PSIDMObject {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [PSCustomObject] $CsvRow,

        [Array] $AdPropertyMap,

        [ValidateSet('user', 'group', 'organizationalUnit')]
        [string] $AdObjectClass = 'user',

        [ScriptBlock] $PreProcess,
        [ScriptBlock] $PostProcess
    )

    begin {
        $AllowedADProps = Import-PowerShellDataFile -Path (Join-Path (Get-PSIDMConfig -path Module.Paths.ModuleRoot) -ChildPath 'Private\resources\ADObjectProperties.psd1')
    }

    process {
        # Pre-processing
        if ($PreProcess) {
            $CsvRow = & $PreProcess $CsvRow
        }

        $adObject = @{}
        foreach ($map in $AdPropertyMap) {
            $adObject[$map.Destination] = $CsvRow.($map.Source)
        }

        # add remaining properties from CsvRow
        foreach ($prop in $CsvRow.PSObject.Properties) {
            if ($prop.Name -notin $adObject.Keys -and $prop.Name -in $AllowedADProps.$AdObjectClass) {
                $adObject[$prop.Name] = $prop.Value
            }
        }

        # Post-processing
        if ($PostProcess) {
            $adObject = & $PostProcess $adObject
        }

        return $adObject
    }
}