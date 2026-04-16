# setup-settings.ps1
# Generates settings.json from settings.template.json.
# Prompts for sensitive values; skipped values are omitted from output.

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$Template  = Join-Path $ScriptDir "settings.template.json"
$Output    = Join-Path $ScriptDir "settings.json"

function Write-Info { param($msg) Write-Host "[INFO]  $msg" -ForegroundColor Green }
function Write-Warn { param($msg) Write-Host "[WARN]  $msg" -ForegroundColor Yellow }
function Write-Err  { param($msg) Write-Host "[ERROR] $msg" -ForegroundColor Red }

# Require template
if (-not (Test-Path $Template)) {
    Write-Err "Template not found: $Template"
    exit 1
}

# Confirm overwrite
if (Test-Path $Output) {
    $confirm = Read-Host "`nsettings.json already exists. Overwrite? [y/N]"
    if ($confirm -notmatch '^[yY]') {
        Write-Info "Skipped. No changes made."
        exit 0
    }
}

# Load template
$config = Get-Content $Template -Raw | ConvertFrom-Json

# --- ANTHROPIC_AUTH_TOKEN ---
Write-Host "`nEnter your ANTHROPIC_AUTH_TOKEN (press Enter to skip):"
$secureToken = Read-Host -AsSecureString "> "
$bstr      = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($secureToken)
$authToken = [Runtime.InteropServices.Marshal]::PtrToStringAuto($bstr)
[Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstr)

if ($authToken -ne "") {
    $config.env | Add-Member -NotePropertyName "ANTHROPIC_AUTH_TOKEN" -NotePropertyValue $authToken -Force
    Write-Info "ANTHROPIC_AUTH_TOKEN set."
} else {
    Write-Warn "ANTHROPIC_AUTH_TOKEN skipped — key will not be present in settings.json."
}

# --- GovTech Claude Code tools ---
Write-Host ""
$gtConfirm = Read-Host "Install GovTech Claude Code tools? (runs: gt tools configure claude-code) [y/N]"
if ($gtConfirm -match '^[yY]') {
    Write-Info "Running: gt tools configure claude-code"
    if (Get-Command gt -ErrorAction SilentlyContinue) {
        # Write current config first so gt can merge into it
        $config | ConvertTo-Json -Depth 20 | Set-Content $Output -Encoding UTF8
        & gt tools configure claude-code
        Write-Info "GovTech tools configured. settings.json updated by gt."
        exit 0
    } else {
        Write-Err "'gt' command not found. Install GovTech tools first."
        Write-Host "  See: https://go.gov.sg/gt-cc-managed-settings"
    }
}

# Write output
$config | ConvertTo-Json -Depth 20 | Set-Content $Output -Encoding UTF8
Write-Info "settings.json written to: $Output"