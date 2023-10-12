[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions','')]
[CmdletBinding()]
param()

# this psm1 is for local testing and development use only

# dot source the parent import for local development variables
. $PSScriptRoot\Imports.ps1

# discover all ps1 file(s) in Public and Private paths

$itemSplat = @{
    Filter      = '*.ps1'
    Recurse     = $false
    ErrorAction = 'Stop'
}

try {
    $public     = @(Get-ChildItem -Path "$PSScriptRoot\Functions\Public" @itemSplat -Verbose)
    $private    = @(Get-ChildItem -Path "$PSScriptRoot\Functions\Private" @itemSplat -Verbose)
}
catch {
    Write-Error $_
    throw "Unable to get get file information from Public & Private src."
}

# dot source all .ps1 file(s) found
foreach ($file in @($public + $private)) {
    try {
        Write-Verbose "Dot sourcing $($file.FullName)"
        . $file.FullName
    }
    catch {
        throw "Unable to dot source [$($file.FullName)]"
    }
}

# Import configuration and setup script-scoped variables.
# This makes configuration available via Get-PSIDMConfig.
try {
    Import-PSIDMConfig
}
catch [System.IO.FileNotFoundException] {
    Write-Warning 'Configuration file not found. Initializing with default values.'
    Initialize-PSIDMConfig -Force
    Write-Error "Error encountered: $_"
}


$export = $public + $private

# export all public functions
Export-ModuleMember -Function $export.BaseName

# Class definitions
class PSIDMJobInfo {
    [psobject] $UAJob
    [psobject] $UAScript
    [string] $Identity
    [int] $JobID
    [int] $ScriptID
    [string] $ScriptName

    PSIDMJobInfo() { }

    PSIDMJobInfo([psobject]$UABuiltInVar) {
        if ($UABuiltInVar.ToString() -ne 'PowerShellUniversal.BuiltInVariable') {
            # argument passed is a script object
            $this.UAScript = $UABuiltInVar
        }
        else {
            # argument passed is a job object
            $this.UAJob = $UABuiltInVar
        }
        $null = $this.SetIDs()
    }

    PSIDMJobInfo([psobject] $UAJob, [psobject] $UAScript) {
        if ($UAJob.ToString() -ne 'PowerShellUniversal.Job') {
            throw 'UAJob must be of type PowerShellUniversal.Job'
        }

        $this.UAJob     = $UAJob
        $this.UAScript  = $UAScript
        $null = $this.SetIDs()
    }

    [psobject] SetIDs() {
        $status = [pscustomobject]@{
            IsSuccessful  = $false
            SetProperties = @()
            Message       = ""
        }

        if ($this.UAJob) {
            $this.Identity = $this.UAJob.Identity.Name
            $this.JobID    = $this.UAJob.Id
            $status.SetProperties += 'Identity', 'JobID'
        }

        if ($this.UAScript) {
            $this.ScriptID = $this.UAScript.Id
            $this.ScriptName = $this.UAScript.Name
            $status.SetProperties += 'ScriptID'
        }

        if ($status.SetProperties.Count -gt 0) {
            $status.IsSuccessful = $true
            $status.Message = "Properties set: $($status.SetProperties -join ', ')"
        }
        else {
            $status.Message = "No properties set."
        }

        return $status
    }
}