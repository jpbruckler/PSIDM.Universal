function New-PSIDMJobInfo {
    param(
        [psobject] $UAJob,
        [psobject] $UAScript
    )

    $Obj = New-Object PSIDMJobInfo

    if ($PSBoundParameters.ContainsKey('UAJob')) {
        $Obj.UAJob = $UAJob
    }
    if ($PSBoundParameters.ContainsKey('UAScript')) {
        $Obj.UAScript = $UAScript
    }
    $null = $Obj.SetIDs()
    return $Obj
}