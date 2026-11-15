# Publish self-contained win-x64 and build the Inno Setup installer.
# Version stamp matches HUD/s16n-scope: YYYYMMDD-<7-char git hash> (UTC).
param(
    [ValidateSet("Debug", "Release")]
    [string]$Configuration = "Release",
    [string]$Version = "",
    [switch]$SkipPublish,
    [string]$IsccPath = ""
)

$ErrorActionPreference = "Stop"
$root = Split-Path $PSScriptRoot -Parent
Set-Location $root

$Version = & (Join-Path $PSScriptRoot "Get-VersionStamp.ps1") -Version $Version -RepoRoot $root
if ([string]::IsNullOrWhiteSpace($Version)) {
    throw "Failed to resolve version stamp."
}
Write-Host "Version stamp: $Version"

if (-not $SkipPublish) {
    $env:SIMPIT_VERSION = $Version
    try {
        & (Join-Path $root "publish.ps1") -Configuration $Configuration
        if ($LASTEXITCODE -ne 0) {
            throw "publish.ps1 failed with exit code $LASTEXITCODE"
        }
    }
    finally {
        Remove-Item Env:SIMPIT_VERSION -ErrorAction SilentlyContinue
    }
}

$publishDir = Join-Path $root "artifacts\publish\win-x64"
if (-not (Test-Path (Join-Path $publishDir "SimpitLauncher.exe"))) {
    throw "Missing published app at $publishDir — run without -SkipPublish first."
}

if (-not $IsccPath) {
    $candidates = @(
        "${env:LocalAppData}\Programs\Inno Setup 6\ISCC.exe",
        "${env:ProgramFiles(x86)}\Inno Setup 6\ISCC.exe",
        "${env:ProgramFiles}\Inno Setup 6\ISCC.exe"
    )
    $IsccPath = $candidates | Where-Object { Test-Path $_ } | Select-Object -First 1
}

if (-not $IsccPath -or -not (Test-Path $IsccPath)) {
    throw "Inno Setup 6 ISCC.exe not found. Install from https://jrsoftware.org/isinfo.php"
}

$outDir = Join-Path $root "artifacts\installer"
New-Item -ItemType Directory -Force -Path $outDir | Out-Null
$publishAbs = (Resolve-Path $publishDir).Path

Write-Host "Compiling installer with $IsccPath ..."
& $IsccPath `
    "/DMyAppVersion=$Version" `
    "/DPublishDir=$publishAbs" `
    (Join-Path $root "installer\SimpitLauncher.iss")
if ($LASTEXITCODE -ne 0) {
    throw "ISCC failed with exit code $LASTEXITCODE"
}

$versioned = Join-Path $outDir "SimpitLauncherSetup-$Version.exe"
$stable = Join-Path $outDir "SimpitLauncherSetup.exe"
if (-not (Test-Path $versioned)) {
    throw "Missing installer: $versioned"
}

Copy-Item $versioned $stable -Force
Write-Host "Installer -> $versioned"
Write-Host "Also copied -> $stable"
