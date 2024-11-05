# Script Name: Demote_DC_Replacement.ps1
# Description: Demotes a domain controller to prepare for server replacement, keeping the domain intact
# Author: XZeroScorpionX
# Date: 05-11-2024
# Version: 1.0

# Display a clear warning message
Write-Host "WARNING: This script will demote this server from being a Domain Controller and automatically reboot it after completion." -ForegroundColor Red
Write-Host "Ensure you have transferred any FSMO roles if needed and that all data is replicated." -ForegroundColor Yellow

# Prompt for confirmation before proceeding
$confirmation = Read-Host "Type 'YES' to confirm you want to proceed with the demotion and automatic reboot"
if ($confirmation -ne 'YES') {
    Write-Host "Operation canceled."
    exit
}

# Cancel any pending shutdowns to ensure a fresh start
shutdown /a

# Check if the Active Directory module is installed
if (-not (Get-Module -ListAvailable -Name ActiveDirectory)) {
    Write-Host "Active Directory module is not installed. Please install it before running this script." -ForegroundColor Red
    exit
}

# Import Active Directory module
Import-Module ActiveDirectory

# Set local administrator password for post-demotion
$LocalAdminPassword = Read-Host "Enter a password for the local Administrator account after demotion" -AsSecureString

# Demote the Domain Controller
try {
    Write-Host "Starting domain controller demotion process..." -ForegroundColor Yellow

    Uninstall-ADDSDomainController `
        -LocalAdministratorPassword $LocalAdminPassword `
        -DemoteOperationMasterRole `
        -Force

    Write-Host "Domain controller demoted successfully." -ForegroundColor Green
} catch {
    Write-Host "An error occurred during the demotion process: $_" -ForegroundColor Red
    exit
}

# Force restart the server after demotion
try {
    Write-Host "Forcing server to restart to complete the demotion process..." -ForegroundColor Yellow
    shutdown /r /t 0 /f
} catch {
    Write-Host "An error occurred while forcing the server to restart: $_" -ForegroundColor Red
}
