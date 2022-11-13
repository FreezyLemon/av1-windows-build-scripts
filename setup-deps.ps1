# We don't want to download/extract stuff anywhere else
Push-Location $PSScriptRoot

function Install {
    Param (
        [string]$Cmd,
        [string]$InstalledPath,
        [string]$InstallScript
    )

    try {
        Write-Host -NoNewline "Checking for $cmd... "
        Get-Command -ErrorAction Stop $cmd | Out-Null
        Write-Host -ForegroundColor Green "found"
    } catch {
        # don't re-download
        if (Test-Path $InstalledPath) {
            Write-Host -ForegroundColor Green "found (already downloaded)"
            $env:Path += ";$InstalledPath"
        } else {
            Write-Host "not found"
            Write-Host "Installing ${cmd}..."
            & $InstallScript
        }
    }
}

# Disable progress bars for Invoke-WebRequest
$ProgressPreference = "SilentlyContinue"

.\install-build-tools.ps1
Install -Cmd 'git' -InstalledPath "$PSScriptRoot\deps\git\bin" -InstallScript ".\install-git.ps1"
Install -Cmd 'yasm' -InstalledPath "$PSScriptRoot\deps\yasm" -InstallScript ".\install-yasm.ps1"
Install -Cmd 'perl' -InstalledPath "$PSScriptRoot\deps\perl\perl\bin" -InstallScript ".\install-perl.ps1"
Install -Cmd 'cmake' -InstalledPath "$PSScriptRoot\deps\cmake\bin" -InstallScript ".\install-cmake.ps1"

Pop-Location
