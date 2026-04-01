param(
    [Alias("f")]
    [switch]$Fresh,
    [switch]$Run,
    [switch]$NoDeploy
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Resolve-RepoRoot {
    if ($PSScriptRoot) {
        return (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
    }
    return (Get-Location).Path
}

function Resolve-VsDevCmd {
    $vswhere = Join-Path ${env:ProgramFiles(x86)} "Microsoft Visual Studio\Installer\vswhere.exe"
    if (-not (Test-Path $vswhere)) {
        throw "vswhere.exe not found at '$vswhere'. Install Visual Studio Build Tools 2022."
    }

    $installPath = & $vswhere -products * -latest -property installationPath
    if ([string]::IsNullOrWhiteSpace($installPath)) {
        throw "No Visual Studio installation found by vswhere."
    }

    $vsDevCmd = Join-Path $installPath "Common7\Tools\VsDevCmd.bat"
    if (-not (Test-Path $vsDevCmd)) {
        throw "VsDevCmd.bat not found at '$vsDevCmd'."
    }

    return $vsDevCmd
}

function Assert-Command {
    param([Parameter(Mandatory = $true)][string]$Name)
    if (-not (Get-Command $Name -ErrorAction SilentlyContinue)) {
        throw "Required tool '$Name' was not found in PATH."
    }
}

function Resolve-WinDeployQt {
    if (-not [string]::IsNullOrWhiteSpace($env:POWERTUNE_QT_PREFIX)) {
        $fromPrefix = Join-Path $env:POWERTUNE_QT_PREFIX "bin\windeployqt.exe"
        if (Test-Path $fromPrefix) {
            return $fromPrefix
        }
    }

    $cmd = Get-Command "windeployqt" -ErrorAction SilentlyContinue
    if ($null -ne $cmd) {
        return $cmd.Source
    }

    return $null
}

function Invoke-InVsDevCmd {
    param(
        [Parameter(Mandatory = $true)][string]$VsDevCmdPath,
        [Parameter(Mandatory = $true)][string]$InnerCommand
    )

    $wrapped = "`"$VsDevCmdPath`" -arch=amd64 -host_arch=amd64 && $InnerCommand"
    & cmd.exe /d /c $wrapped
    if ($LASTEXITCODE -ne 0) {
        exit $LASTEXITCODE
    }
}

$repoRoot = Resolve-RepoRoot
Set-Location $repoRoot

Assert-Command -Name "cmake"
Assert-Command -Name "ninja"
Write-Host "[init] Resolving Visual Studio build environment..."
$vsDevCmd = Resolve-VsDevCmd
Write-Host "[init] Using: $vsDevCmd"

$buildDir = Join-Path $repoRoot "build/windows-debug"

if ($Fresh -and (Test-Path $buildDir)) {
    Write-Host "[build] Removing existing build cache: $buildDir"
    Remove-Item -Recurse -Force $buildDir
}

if ([string]::IsNullOrWhiteSpace($env:POWERTUNE_QT_PREFIX)) {
    Write-Warning "POWERTUNE_QT_PREFIX is not set in this shell. CMake preset expects it."
}

Write-Host "[build] Configuring (windows-debug, Ninja)..."
Invoke-InVsDevCmd -VsDevCmdPath $vsDevCmd -InnerCommand "cmake --preset windows-debug"

Write-Host "[build] Building (windows-debug)..."
Invoke-InVsDevCmd -VsDevCmdPath $vsDevCmd -InnerCommand "cmake --build --preset windows-debug --config Debug"

$exe = Join-Path $repoRoot "build/windows-debug/PowerTuneQMLGui.exe"
if (-not (Test-Path $exe)) {
    throw "Build succeeded but executable not found at '$exe'."
}

if (-not $NoDeploy) {
    $windeployqt = Resolve-WinDeployQt
    if ([string]::IsNullOrWhiteSpace($windeployqt)) {
        throw "windeployqt.exe not found. Set POWERTUNE_QT_PREFIX or add Qt bin to PATH."
    }

    Write-Host "[deploy] Running windeployqt for debug runtime files..."
    & $windeployqt --debug --qmldir $repoRoot $exe
    if ($LASTEXITCODE -ne 0) {
        exit $LASTEXITCODE
    }
    Write-Host "[deploy] Qt runtime deployment complete."
}

if ($Run) {
    Write-Host "[run] Launching $exe"
    & $exe
}

Write-Host "[done] Windows Ninja build completed."
