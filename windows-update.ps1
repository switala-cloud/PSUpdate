# -----------------------
# Prereqs
# -----------------------

Write-Output "Setting execution policy..."
Set-ExecutionPolicy Bypass -Scope Process -Force

Write-Output "Installing NuGet provider..."
Install-PackageProvider -Name NuGet -Force -ErrorAction SilentlyContinue

Write-Output "Installing PSWindowsUpdate module..."
Install-Module PSWindowsUpdate -Force -SkipPublisherCheck -ErrorAction SilentlyContinue

Import-Module PSWindowsUpdate

# -----------------------
# Run Windows Updates
# -----------------------

Write-Output "Starting Windows Update scan/install..."

Get-WindowsUpdate `
    -AcceptAll `
    -Install `
    -IgnoreReboot `
    -NotTitle "(?i)\.NET Framework|Malicious Software Removal Tool|Microsoft Defender|Preview"

# -----------------------
# Reboot Handling
# -----------------------

Write-Output "Checking reboot status..."

if (Get-WURebootStatus) {
    Write-Output "Reboot required. Exiting with code 101..."
    exit 101
}

Write-Output "No reboot required. Exiting cleanly..."
exit 0
