# -----------------------
# Config
# -----------------------

$ExcludeTitles = @(
    ".NET Framework",
    "Malicious Software Removal Tool",
    "Microsoft Defender",
    "Preview"
)

# Build safe regex (auto-escaped)
$ExcludePattern = "(?i)" + (($ExcludeTitles | ForEach-Object {
    [regex]::Escape($_)
}) -join "|")

# -----------------------
# Functions
# -----------------------

function Test-RebootRequired {
    if (Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending") { return $true }
    if (Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired") { return $true }
    if (Test-Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\PendingFileRenameOperations") { return $true }
    return $false
}

# -----------------------
# Prereqs (idempotent)
# -----------------------

Write-Output "Checking prerequisites..."

Set-ExecutionPolicy Bypass -Scope Process -Force
$ConfirmPreference = 'None'

# NuGet provider
$nuget = Get-PackageProvider -Name NuGet -ErrorAction SilentlyContinue
if (-not $nuget) {
    Write-Output "Installing NuGet provider..."
    Install-PackageProvider -Name NuGet -Force
} else {
    Write-Output "NuGet already installed."
}

# PSWindowsUpdate module
$pswu = Get-Module -ListAvailable -Name PSWindowsUpdate
if (-not $pswu) {
    Write-Output "Installing PSWindowsUpdate module..."
    Install-Module PSWindowsUpdate -Force -SkipPublisherCheck
} else {
    Write-Output "PSWindowsUpdate already available."
}

Import-Module PSWindowsUpdate

# -----------------------
# Run Updates
# -----------------------

Write-Output "Running Windows Update..."

$updates = Get-WindowsUpdate `
    -AcceptAll `
    -Install `
    -IgnoreReboot `
    -NotTitle $ExcludePattern

# -----------------------
# Evaluate Results
# -----------------------

if ($updates) {

    Write-Output "Updates were processed. Evaluating results..."

    $installed = $updates | Where-Object {
        $_.Result -match "Installed|Succeeded"
    }

    if ($installed) {
        Write-Output "Updates installed successfully."

        if (Test-RebootRequired) {
            Write-Output "Reboot required. Exiting with code 101."
            exit 101
        } else {
            Write-Output "No reboot required after install."
            exit 0
        }
    }
    else {
        Write-Output "No updates were installed (all skipped or not applicable)."
        exit 0
    }
}
else {
    Write-Output "No updates found."
    exit 0
}
