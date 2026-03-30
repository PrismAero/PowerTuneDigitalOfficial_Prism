param(
    [string]$QtPrefix,
    [switch]$PersistQtPrefix
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Test-Tool {
    param([Parameter(Mandatory = $true)][string]$Name)
    $cmd = Get-Command $Name -ErrorAction SilentlyContinue
    if ($null -eq $cmd) {
        return $null
    }
    return $cmd.Source
}

function Write-Check {
    param(
        [Parameter(Mandatory = $true)][string]$Label,
        [Parameter(Mandatory = $true)][string]$Value,
        [Parameter(Mandatory = $true)][bool]$Ok
    )

    $status = if ($Ok) { "[OK]" } else { "[MISSING]" }
    Write-Output ("{0} {1}: {2}" -f $status, $Label, $Value)
}

function Resolve-QtCandidates {
    $candidates = @()
    if (-not (Test-Path "C:\Qt")) {
        return $candidates
    }

    $majorDirs = Get-ChildItem "C:\Qt" -Directory -ErrorAction SilentlyContinue
    foreach ($major in $majorDirs) {
        $kits = Get-ChildItem $major.FullName -Directory -ErrorAction SilentlyContinue
        foreach ($kit in $kits) {
            $qtConfig = Join-Path $kit.FullName "lib\cmake\Qt6\Qt6Config.cmake"
            if (Test-Path $qtConfig) {
                $candidates += $kit.FullName
            }
        }
    }

    return $candidates
}

function Validate-QtPrefix {
    param([string]$PrefixPath)
    if ([string]::IsNullOrWhiteSpace($PrefixPath)) {
        return $false
    }
    $qtConfig = Join-Path $PrefixPath "lib\cmake\Qt6\Qt6Config.cmake"
    return (Test-Path $qtConfig)
}

function Resolve-QtToolPath {
    param(
        [Parameter(Mandatory = $true)][string]$QtPrefixPath,
        [Parameter(Mandatory = $true)][string]$ToolName
    )
    if ([string]::IsNullOrWhiteSpace($QtPrefixPath)) {
        return $null
    }
    $candidate = Join-Path $QtPrefixPath ("bin\{0}.exe" -f $ToolName)
    if (Test-Path $candidate) {
        return $candidate
    }
    return $null
}

Write-Output ""
Write-Output "PowerTune Windows Dev Bootstrap Check"
Write-Output "====================================="
Write-Output ""
Write-Output "Safety: this script does not install packages or modify production/build-server tooling."
Write-Output ""

$tools = @(
    "git",
    "cmake",
    "ninja",
    "cl",
    "qmake",
    "windeployqt",
    "winget"
)

foreach ($tool in $tools) {
    $path = Test-Tool -Name $tool
    if ($null -ne $path) {
        Write-Check -Label $tool -Value $path -Ok $true
    } else {
        $qtToolPath = $null
        if ($tool -in @("qmake", "windeployqt")) {
            if (-not [string]::IsNullOrWhiteSpace($env:POWERTUNE_QT_PREFIX)) {
                $qtToolPath = Resolve-QtToolPath -QtPrefixPath $env:POWERTUNE_QT_PREFIX -ToolName $tool
            }
            if ($null -eq $qtToolPath) {
                $profileQtPrefix = [Environment]::GetEnvironmentVariable("POWERTUNE_QT_PREFIX", "User")
                if (-not [string]::IsNullOrWhiteSpace($profileQtPrefix)) {
                    $qtToolPath = Resolve-QtToolPath -QtPrefixPath $profileQtPrefix -ToolName $tool
                }
            }
        }

        if ($null -ne $qtToolPath) {
            Write-Check -Label $tool -Value ("{0} (Qt kit, not on PATH)" -f $qtToolPath) -Ok $true
        } else {
            Write-Check -Label $tool -Value "not found in PATH" -Ok $false
        }
    }
}

Write-Output ""
$currentPrefix = $env:POWERTUNE_QT_PREFIX
$userPrefix = [Environment]::GetEnvironmentVariable("POWERTUNE_QT_PREFIX", "User")
Write-Output ("Current session POWERTUNE_QT_PREFIX: {0}" -f $(if ($currentPrefix) { $currentPrefix } else { "<unset>" }))
Write-Output ("User profile POWERTUNE_QT_PREFIX:   {0}" -f $(if ($userPrefix) { $userPrefix } else { "<unset>" }))

$qtCandidates = @(Resolve-QtCandidates)
if ($qtCandidates.Count -gt 0) {
    Write-Output ""
    Write-Output "Detected Qt 6 kit candidates:"
    foreach ($candidate in $qtCandidates) {
        Write-Output ("- {0}" -f $candidate)
    }
} else {
    Write-Output ""
    Write-Output "No Qt 6 kit candidates detected under C:\Qt."
}

if (-not [string]::IsNullOrWhiteSpace($QtPrefix)) {
    if (-not (Validate-QtPrefix -PrefixPath $QtPrefix)) {
        throw "Provided -QtPrefix is invalid. Expected to find lib\cmake\Qt6\Qt6Config.cmake under: $QtPrefix"
    }

    $env:POWERTUNE_QT_PREFIX = $QtPrefix
    Write-Output ""
    Write-Output ("Set current session POWERTUNE_QT_PREFIX to: {0}" -f $QtPrefix)

    if ($PersistQtPrefix) {
        [Environment]::SetEnvironmentVariable("POWERTUNE_QT_PREFIX", $QtPrefix, "User")
        Write-Output "Persisted POWERTUNE_QT_PREFIX for current user profile."
    }
}

Write-Output ""
Write-Output "Recommended install commands (run manually if missing):"
Write-Output "  winget install --id Kitware.CMake -e"
Write-Output "  winget install --id Ninja-build.Ninja -e"
Write-Output "  winget install --id Microsoft.VisualStudio.2022.BuildTools -e"
Write-Output "  # Install Qt 6 via Qt Online Installer, then set:"
Write-Output '  # $env:POWERTUNE_QT_PREFIX = "C:\Qt\6.x.x\msvc2022_64"'

Write-Output ""
Write-Output "After setup, build with:"
Write-Output "  cmake --preset windows-debug"
Write-Output "  cmake --build --preset windows-debug"
Write-Output ""
