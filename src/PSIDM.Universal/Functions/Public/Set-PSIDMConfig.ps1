function Set-PSIDMConfig {
    param(
        [ValidateSet('Module','Jobs')]
        [string] $Section = 'Module',
        [string] $Key,
        [string] $Value
    )
}