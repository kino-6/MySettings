#Requires -Version 5.1
<#
.SYNOPSIS
    Deploys the Windows-side settings from this repository.

.DESCRIPTION
    Windows counterpart to mac-setup.sh / wsl-setup.sh. Uses the same
    backup-then-copy semantics: a destination that already matches the
    repository copy is left alone, anything else is moved aside to
    <name>.bak.<timestamp> before being replaced.

    Deploys:
      settings/windows/Microsoft.PowerShell_profile.ps1
        -> Documents\WindowsPowerShell\  (Windows PowerShell 5.1)
        -> Documents\PowerShell\         (PowerShell 7, only if pwsh is present)
      settings/windows-terminal/settings.json
        -> Windows Terminal LocalState   (unless -SkipTerminal)

    Installing packages is deliberately out of scope; this script only places
    configuration files.

.PARAMETER SkipTerminal
    Leave the Windows Terminal settings.json untouched.

.PARAMETER DryRun
    Report what would change without writing anything.

.EXAMPLE
    powershell -ExecutionPolicy Bypass -File .\windows-setup.ps1

.EXAMPLE
    powershell -ExecutionPolicy Bypass -File .\windows-setup.ps1 -DryRun
#>
[CmdletBinding()]
param(
    [switch]$SkipTerminal,
    [switch]$DryRun
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$RootDir   = Split-Path -Parent $MyInvocation.MyCommand.Definition
$Timestamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$Changed   = 0

function Backup-AndCopy {
    param(
        [Parameter(Mandatory)][string]$Source,
        [Parameter(Mandatory)][string]$Destination
    )

    if (-not (Test-Path -LiteralPath $Source)) {
        Write-Host "[MISS] source not found: $Source" -ForegroundColor Red
        return
    }

    if (Test-Path -LiteralPath $Destination) {
        $srcHash = (Get-FileHash -LiteralPath $Source      -Algorithm SHA256).Hash
        $dstHash = (Get-FileHash -LiteralPath $Destination -Algorithm SHA256).Hash
        if ($srcHash -eq $dstHash) {
            Write-Host "skip (same): $Destination"
            return
        }

        $backup = "$Destination.bak.$Timestamp"
        Write-Host "backup: $Destination -> $backup" -ForegroundColor Yellow
        if (-not $DryRun) { Move-Item -LiteralPath $Destination -Destination $backup }
    }

    $parent = Split-Path -Parent $Destination
    if (-not (Test-Path -LiteralPath $parent)) {
        Write-Host "mkdir:  $parent"
        if (-not $DryRun) { New-Item -ItemType Directory -Path $parent -Force | Out-Null }
    }

    Write-Host "copy:   $Source -> $Destination" -ForegroundColor Green
    if (-not $DryRun) { Copy-Item -LiteralPath $Source -Destination $Destination -Force }
    $script:Changed++
}

if ($DryRun) { Write-Host "-- dry run: no files will be written --`n" -ForegroundColor Cyan }

# --- PowerShell profiles ----------------------------------------------------
# GetFolderPath rather than a literal path, so a OneDrive-redirected Documents
# folder resolves correctly.
$documents  = [Environment]::GetFolderPath('MyDocuments')
$profileSrc = Join-Path $RootDir 'settings\windows\Microsoft.PowerShell_profile.ps1'

Write-Host 'Applying Windows PowerShell 5.1 profile...'
Backup-AndCopy -Source $profileSrc `
    -Destination (Join-Path $documents 'WindowsPowerShell\Microsoft.PowerShell_profile.ps1')

Write-Host 'Applying PowerShell 7 profile...'
if (Get-Command pwsh -ErrorAction SilentlyContinue) {
    Backup-AndCopy -Source $profileSrc `
        -Destination (Join-Path $documents 'PowerShell\Microsoft.PowerShell_profile.ps1')
} else {
    Write-Host 'skip: pwsh not installed (winget install Microsoft.PowerShell)'
}

# --- shared settings --------------------------------------------------------
# settings/common/ is deployed by all three setup scripts. Only the files that
# make sense on Windows are taken; the zsh pieces are skipped.
Write-Host 'Applying shared settings...'
Backup-AndCopy -Source (Join-Path $RootDir 'settings\common\.config\starship.toml') `
    -Destination (Join-Path $HOME '.config\starship.toml')

# --- Windows Terminal -------------------------------------------------------
if ($SkipTerminal) {
    Write-Host 'Skipping Windows Terminal settings (-SkipTerminal).'
} else {
    Write-Host 'Applying Windows Terminal settings...'
    $terminalDst = Join-Path $env:LOCALAPPDATA `
        'Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json'

    if (Test-Path -LiteralPath (Split-Path -Parent $terminalDst)) {
        Backup-AndCopy -Source (Join-Path $RootDir 'settings\windows-terminal\settings.json') `
            -Destination $terminalDst
    } else {
        Write-Host 'skip: Windows Terminal (Store package) not found'
    }
}

Write-Host ''
Write-Host "Done. $Changed file(s) updated."
if ($Changed -gt 0 -and -not $DryRun) {
    Write-Host 'Open a new shell (or run . $PROFILE) to pick up the changes.'
}
