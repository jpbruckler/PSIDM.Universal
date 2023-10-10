{
    param([object] $User, [object]$JobInfo)
    $obj = [ordered]@{
        p1 = $User
        p2 = $JobInfo
    }
    $obj | ConvertTo-Json -Depth 5 | Out-File c:\temp\test.txt
}