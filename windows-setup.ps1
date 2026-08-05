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

    -ImportTerminal reverses the Windows Terminal direction: it copies the live
    settings.json back into the repository. Windows Terminal rewrites that file
    whenever a setting is changed through its UI, so this is how a deliberate UI
    change gets captured instead of being reverted by the next deploy.

.PARAMETER SkipTerminal
    Leave the Windows Terminal settings.json untouched.

.PARAMETER ImportTerminal
    Copy the live Windows Terminal settings.json into the repository and do
    nothing else. Mutually exclusive with -SkipTerminal.

.PARAMETER DryRun
    Report what would change without writing anything.

.EXAMPLE
    powershell -ExecutionPolicy Bypass -File .\windows-setup.ps1

.EXAMPLE
    powershell -ExecutionPolicy Bypass -File .\windows-setup.ps1 -DryRun

.EXAMPLE
    powershell -ExecutionPolicy Bypass -File .\windows-setup.ps1 -ImportTerminal
#>
[CmdletBinding()]
param(
    [switch]$SkipTerminal,
    [switch]$ImportTerminal,
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

$TerminalLive = Join-Path $env:LOCALAPPDATA `
    'Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json'
$TerminalRepo = Join-Path $RootDir 'settings\windows-terminal\settings.json'

# Pull the live Windows Terminal settings back into the repository. The copy is
# verbatim: Windows Terminal owns the formatting of this file, so normalising it
# here would only produce churn the next time the app rewrites it.
#
# No .bak is written next to the repository copy - that is git's job, and stray
# backup files inside the repo would end up committed.
function Import-TerminalSettings {
    if (-not (Test-Path -LiteralPath $TerminalLive)) {
        Write-Host '[MISS] Windows Terminal settings not found:' -ForegroundColor Red
        Write-Host "       $TerminalLive"
        return
    }

    try {
        $parsed = Get-Content -LiteralPath $TerminalLive -Raw | ConvertFrom-Json
    } catch {
        Write-Host '[FAIL] live settings.json does not parse; refusing to import.' -ForegroundColor Red
        Write-Host "       $_"
        return
    }

    if ((Test-Path -LiteralPath $TerminalRepo) -and
        (Get-FileHash -LiteralPath $TerminalLive).Hash -eq (Get-FileHash -LiteralPath $TerminalRepo).Hash) {
        Write-Host "skip (same): $TerminalRepo"
        return
    }

    # Work out what this import adds before overwriting the repository copy.
    # Profiles carrying a "source" are produced by Windows Terminal's own
    # generators (WSL distributions, Visual Studio, and so on): they are
    # machine-specific and reappear on their own, so newly arriving ones are
    # worth flagging before the result gets committed.
    $addedGenerated = @()
    if (Test-Path -LiteralPath $TerminalRepo) {
        try {
            $knownGuids = (Get-Content -LiteralPath $TerminalRepo -Raw | ConvertFrom-Json).profiles.list.guid
            $addedGenerated = @($parsed.profiles.list | Where-Object {
                    $_.PSObject.Properties.Name -contains 'source' -and $_.guid -notin $knownGuids
                })
        } catch {
            # Existing repository copy is unreadable; nothing to compare against.
        }
    }

    Write-Host "import: $TerminalLive" -ForegroundColor Green
    Write-Host "     -> $TerminalRepo"
    if (-not $DryRun) { Copy-Item -LiteralPath $TerminalLive -Destination $TerminalRepo -Force }
    $script:Changed++

    if ($addedGenerated.Count) {
        Write-Host ''
        Write-Host "note: $($addedGenerated.Count) newly auto-generated profile(s) came along." -ForegroundColor Yellow
        Write-Host '      These are machine-specific and regenerate by themselves, so they'
        Write-Host '      are usually not worth committing:'
        $addedGenerated | ForEach-Object { Write-Host "        $($_.name)" }
    }
}

if ($ImportTerminal -and $SkipTerminal) {
    throw '-ImportTerminal and -SkipTerminal are mutually exclusive.'
}

if ($DryRun) { Write-Host "-- dry run: no files will be written --`n" -ForegroundColor Cyan }

if ($ImportTerminal) {
    Write-Host 'Importing Windows Terminal settings into the repository...'
    Import-TerminalSettings
    Write-Host ''
    Write-Host "Done. $Changed file(s) updated."
    if ($Changed -gt 0 -and -not $DryRun) {
        Write-Host 'Review with: git diff settings/windows-terminal/settings.json'
    }
    return
}

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
    if (Test-Path -LiteralPath (Split-Path -Parent $TerminalLive)) {
        Backup-AndCopy -Source $TerminalRepo -Destination $TerminalLive
    } else {
        Write-Host 'skip: Windows Terminal (Store package) not found'
    }
}

Write-Host ''
Write-Host "Done. $Changed file(s) updated."
if ($Changed -gt 0 -and -not $DryRun) {
    Write-Host 'Open a new shell (or run . $PROFILE) to pick up the changes.'
}
