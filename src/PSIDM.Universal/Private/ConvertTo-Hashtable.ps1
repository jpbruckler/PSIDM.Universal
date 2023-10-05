function ConvertTo-Hashtable {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [PSCustomObject] $Object,

        [Parameter(Mandatory = $false)]
        [int] $Depth = [int] 10
    )

    process {
        if ($Depth -lt 0) {
            return $Object
        }

        $hash = @{}
        $Object.PSObject.Properties | ForEach-Object {
            $key = $_.Name
            $value = $_.Value

            if ($value -is [PSCustomObject]) {
                $hash[$key] = ConvertTo-Hashtable -Object $value -Depth ($Depth - 1)
            }
            elseif ($value -is [Array]) {
                $hash[$key] = @($value | ForEach-Object {
                    if ($value -is [string] -or $value -is [int] -or $value -is [double] -or $value -is [bool]) {
                        $hash[$key] = $value
                    }
                    elseif ($_ -is [PSCustomObject]) {
                        ConvertTo-Hashtable -Object $_ -Depth ($Depth - 1)
                    }
                    else {
                        $_
                    }
                })
            }
            else {
                $hash[$key] = $value
            }
        }
        return $hash
    }
}
