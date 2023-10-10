function Merge-Object {
    <#
    .SYNOPSIS
        Merges properties from multiple objects or hashtables into a single
        PSCustomObject.

    .DESCRIPTION
        The Merge-Object function takes an array of objects or hashtables and combines
        their properties into a single PSCustomObject. If a property with the same
        name already exists, it will be overwritten with the new value.

    .PARAMETER Objects
        An array of objects or hashtables containing properties to merge.

    .EXAMPLE
        $object1 = @{ Name = "Alice"; Age = 25 }
        $object2 = [PSCustomObject]@{ Name = "Bob"; Address = "123 Main St" }
        $result = Merge-Object -Objects $object1, $object2

        This will create a new PSCustomObject with the properties Name, Age, and
        Address.

    .NOTES
        Any unsupported types will be ignored, and a warning will be issued for
        those instances.
    #>
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [object[]] $Objects
    )
    process {
        $result = New-Object PSCustomObject

        foreach ($object in $Objects) {
            if ($object -is [hashtable]) {
                $properties = $object.GetEnumerator()
            }
            elseif ($object -is [PSCustomObject]) {
                $properties = $object.PSObject.Properties
            }
            else {
                Write-Warning "Ignoring unsupported type: $($object.GetType().FullName)"
                continue
            }

            $properties | ForEach-Object {
                $name = $_.Name
                $value = $_.Value

                if ($result.PSObject.Properties.Name -contains $name) {
                    $result.$name = $value
                }
                else {
                    $result | Add-Member -MemberType NoteProperty -Name $name -Value $value
                }
            }
        }

        return $result
    }
}