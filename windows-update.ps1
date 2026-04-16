# -----------------------
# Config
# -----------------------

$ExcludeTitles = @(
    ".NET Framework",
    "Malicious Software Removal Tool",
    "Microsoft Defender",
    "Preview"
)

$ExcludePattern = "(?i)" + (($ExcludeTitles | ForEach-Object {
    [regex]::Escape($_)
}) -join "|")

# -----------------------
# Prereqs (idempotent)
# -----------------------

Write-Output "Checking prerequisites..."

# Ensure execution policy for this session
Set-ExecutionPolicy Bypass -Scope Process -Force

# Check NuGet provider
$nuget = Get-PackageProvider -Name NuGet -ErrorAction SilentlyContinue
if (-not $nuget) {
    Write-Output "Installing NuGet provider..."
    Install-PackageProvider -Name NuGet -Force
} else {
    Write-Output "NuGet provider already installed."
}

# Check PSWindowsUpdate module
$pswu = Get-Module -ListAvailable -Name PSWindowsUpdate
if (-not $pswu) {
    Write-Output "Installing PSWindowsUpdate module..."
    Install-Module PSWindowsUpdate -Force -SkipPublisherCheck
} else {
    Write-Output "PSWindowsUpdate module already available."
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

        if (Get-WURebootStatus) {
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
