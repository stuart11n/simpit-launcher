# Returns the HUD/s16n-scope version stamp: YYYYMMDD-<7-char git hash>[-dirty] (UTC).
# Override with -Version or $env:SIMPIT_VERSION.
param(
    [string]$Version = "",
    [string]$RepoRoot = ""
)

$ErrorActionPreference = "Stop"

if (-not [string]::IsNullOrWhiteSpace($Version)) {
    Write-Output $Version.Trim()
    exit 0
}

if (-not [string]::IsNullOrWhiteSpace($env:SIMPIT_VERSION)) {
    Write-Output $env:SIMPIT_VERSION.Trim()
    exit 0
}

if ([string]::IsNullOrWhiteSpace($RepoRoot)) {
    $RepoRoot = Split-Path $PSScriptRoot -Parent
}

$day = [DateTime]::UtcNow.ToString("yyyyMMdd")
$hash = "nogit"
$dirty = $false

Push-Location $RepoRoot
try {
    $prev = $ErrorActionPreference
    $ErrorActionPreference = "Continue"
    try {
        $hashOut = (git rev-parse --short=7 HEAD 2>$null)
        if ($LASTEXITCODE -eq 0 -and -not [string]::IsNullOrWhiteSpace($hashOut)) {
            $hash = $hashOut.Trim()
        }

        $status = (git status --porcelain --untracked-files=no 2>$null)
        if ($LASTEXITCODE -eq 0 -and -not [string]::IsNullOrWhiteSpace($status)) {
            $dirty = $true
        }
    }
    finally {
        $ErrorActionPreference = $prev
    }
}
finally {
    Pop-Location
}

$stamp = "{0}-{1}" -f $day, $hash
if ($dirty) {
    $stamp += "-dirty"
}

Write-Output $stamp
