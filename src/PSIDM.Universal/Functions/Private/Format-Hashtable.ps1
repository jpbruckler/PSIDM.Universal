function Format-Hashtable {
    param (
        [Parameter( Mandatory = $true,
                    valueFromPipeline = $true,
                    Position = 0 )]
        [Hashtable]$Hashtable,
        [int]$Indent = 0
    )

    $maxKeyLength = ($Hashtable.Keys | Measure-Object -Maximum -Property Length).Maximum

    foreach ($key in $Hashtable.Keys) {
        $value = $Hashtable[$key]
        $indentation = " " * $Indent
        $keyPadding = " " * ($maxKeyLength - $key.Length)

        if ($value -is [Hashtable]) {
            Write-Host "${indentation}${key}${keyPadding} :"
            Format-PrettyPrintHashtable -Hashtable $value -Indent ($Indent + 4)
        } elseif ($value -is [Array]) {
            Write-Host "${indentation}${key}${keyPadding} :"
            foreach ($item in $value) {
                Write-Host "${indentation}    ${item}"
            }
        } else {
            Write-Host "${indentation}${key}${keyPadding} : $value"
        }
    }
}
