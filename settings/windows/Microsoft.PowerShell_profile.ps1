#
# MySettings - PowerShell profile
#
# Deployed by windows-setup.ps1 to Windows PowerShell 5.1 and, when present,
# PowerShell 7. Mirrors the zsh setup in settings/common/.zshrc.common.
#
# NOTE: keep this file ASCII-only. Windows PowerShell 5.1 decodes BOM-less
# files as the system ANSI codepage, so non-ASCII comments would be garbled.
#
# Every external tool is probed before use, so the profile is valid on a
# machine where nothing but PowerShell itself is installed. Features light up
# as tools get installed; no edit required.
#

function Test-Cmd([string]$Name) {
    # Ignore, not SilentlyContinue: SilentlyContinue still appends to $Error,
    # so probing for absent tools would leave junk in $Error at every startup.
    [bool](Get-Command $Name -ErrorAction Ignore)
}

# --- encoding ---------------------------------------------------------------
# UTF-8 for both console output and what native exes receive.
try {
    $OutputEncoding = [Console]::OutputEncoding = [Text.UTF8Encoding]::new($false)
} catch {
    # Some hosts (ISE, redirected stdout) refuse this; not fatal.
}
if ($PSVersionTable.PSVersion.Major -ge 6) {
    $PSDefaultParameterValues['*:Encoding'] = 'utf8'
}

# --- history and line editing ----------------------------------------------
# Mirrors HISTSIZE=10000 / HIST_IGNORE_DUPS / COMPLETE_IN_WORD from .zshrc.common.
if (Get-Module -ListAvailable PSReadLine) {
    Import-Module PSReadLine

    Set-PSReadLineOption -HistoryNoDuplicates
    Set-PSReadLineOption -MaximumHistoryCount 10000
    Set-PSReadLineOption -HistorySearchCursorMovesToEnd
    Set-PSReadLineKeyHandler -Key UpArrow   -Function HistorySearchBackward
    Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward

    # Inline prediction needs 2.1+; Windows PowerShell 5.1 ships 2.0.0.
    # It also needs a real console: PSReadLine throws when stdout is redirected
    # (scripted / non-interactive runs), so guard on that as well.
    $prlVersion = (Get-Module PSReadLine).Version
    $interactive = -not [Console]::IsOutputRedirected
    if ($interactive -and $prlVersion -ge [version]'2.1.0') {
        try {
            Set-PSReadLineOption -PredictionSource History
            if ($prlVersion -ge [version]'2.2.0') {
                Set-PSReadLineOption -PredictionViewStyle ListView
            }
        } catch {
            # Host does not support virtual terminal processing; keep going.
        }
    }
}

# --- listing ----------------------------------------------------------------
if (Test-Cmd eza) {
    # eza on Windows prints nothing when it is given no path at all, unlike on
    # Linux where it falls back to the current directory. Supply "." ourselves
    # so a bare ll behaves the way it does in the WSL aliases.
    # Append "." unless one of the arguments is an existing path. Testing for
    # a real path rather than just "does not start with -" keeps flag values
    # such as `lt -L 3` from being mistaken for a target.
    function Get-EzaTarget([object[]]$Passed) {
        foreach ($a in $Passed) {
            if ($a -notlike '-*' -and (Test-Path -LiteralPath $a -ErrorAction Ignore)) {
                return $Passed
            }
        }
        return $Passed + '.'
    }
    function ll { eza -l  --git --group-directories-first @(Get-EzaTarget $args) }
    function la { eza -la --git --group-directories-first @(Get-EzaTarget $args) }
    function lt { eza --tree --level=2 @(Get-EzaTarget $args) }
} else {
    function ll { Get-ChildItem @args }
    function la { Get-ChildItem -Force @args }
}

# --- search and view --------------------------------------------------------
# Defined as functions, not Set-Alias, so arguments pass through unchanged.
if (Test-Cmd rg) {
    function grep { rg @args }
} else {
    # Fallback carried over from the previous hand-written profile: pipeline
    # grep via Select-String, for machines without ripgrep.
    function grep {
        param([string]$Pattern)
        process { $_ | Select-String $Pattern }
    }
}
if (Test-Cmd bat) { function less { bat @args } }
if (Test-Cmd fd)  { function ff   { fd @args } }

# --- editor -----------------------------------------------------------------
if (Test-Cmd nvim) {
    function v { nvim @args }
    $env:EDITOR = 'nvim'
    $env:VISUAL = 'nvim'
}

# --- git shorthands ---------------------------------------------------------
function gs { git status @args }
function gd { git diff @args }
function gb { git branch @args }
function gl { git log --oneline --graph --decorate @args }

# --- fzf --------------------------------------------------------------------
if (Test-Cmd fzf) {
    $env:FZF_DEFAULT_OPTS = '--height 40% --layout=reverse --border'
    if (Test-Cmd fd) {
        $env:FZF_DEFAULT_COMMAND  = 'fd --type f --hidden --exclude .git'
        $env:FZF_CTRL_T_COMMAND   = $env:FZF_DEFAULT_COMMAND
        $env:FZF_ALT_C_COMMAND    = 'fd --type d --hidden --exclude .git'
    }

    if (Get-Module -ListAvailable PSFzf) {
        Import-Module PSFzf
        # Ctrl+t file picker, Ctrl+r history - same chords as the zsh bindings.
        Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+t' -PSReadlineChordReverseHistory 'Ctrl+r'
    }
}

# --- Chocolatey -------------------------------------------------------------
# Tab completion for choco. See https://ch0.co/tab-completion
if ($env:ChocolateyInstall) {
    $chocoProfile = Join-Path $env:ChocolateyInstall 'helpers\chocolateyProfile.psm1'
    if (Test-Path $chocoProfile) { Import-Module $chocoProfile }
}

# --- Kiro shell integration -------------------------------------------------
if ($env:TERM_PROGRAM -eq 'kiro' -and (Test-Cmd kiro)) {
    . "$(kiro --locate-shell-integration-path pwsh)"
}

# --- prompt -----------------------------------------------------------------
# starship, same prompt engine as WSL and macOS.
if (Test-Cmd starship) {
    $starshipConfig = Join-Path $HOME '.config\starship.toml'
    if (Test-Path $starshipConfig) { $env:STARSHIP_CONFIG = $starshipConfig }
    Invoke-Expression (& starship init powershell)
}
