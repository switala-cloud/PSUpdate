# Windows Update Automation for Packer (PSWindowsUpdate)

Reliable Windows Update automation for Packer/Azure builds using **PSWindowsUpdate**.  
Avoids legacy COM (`Microsoft.Update.Session`) and unreliable `UsoClient` behaviour on modern Windows (UUS).

## Features

- Deterministic update installs
- Title-based exclusions (e.g. Preview, .NET, Defender)
- Clean reboot handling via exit codes
- Repeatable image build pipelines

---

## Why this exists

Modern Windows (10/11 22H2+) uses the **Unified Update Stack (UUS)**.

Traditional approaches:
- ❌ COM API (`Microsoft.Update.Session`) → unstable mid-update
- ❌ `UsoClient` → non-deterministic, no feedback

This solution:
- ✅ Uses **PSWindowsUpdate**
- ✅ Handles retries and orchestration
- ✅ Works reliably in non-interactive environments (Packer/WinRM)

---

## Prerequisites

- Internet access to PowerShell Gallery  
- PowerShell 5.1+  
- Administrator privileges  

---

## Usage (PowerShell)

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force

Install-PackageProvider -Name NuGet -Force
Install-Module PSWindowsUpdate -Force -SkipPublisherCheck

Import-Module PSWindowsUpdate

Get-WindowsUpdate `
    -AcceptAll `
    -Install `
    -IgnoreReboot `
    -NotTitle "(?i)\.NET Framework|Malicious Software Removal Tool|Microsoft Defender|Preview"

if (Get-WURebootStatus) {
    exit 101
}

exit 0
