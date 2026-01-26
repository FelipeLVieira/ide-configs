# Create scheduled task for Clawdbot Watchdog
# Run this script once to set up automatic watchdog startup at login

$watchdogPath = "$env:USERPROFILE\.clawdbot\clawdbot-watchdog.ps1"

if (-not (Test-Path $watchdogPath)) {
    Write-Error "Watchdog script not found at $watchdogPath"
    Write-Host "Please copy clawdbot-watchdog.ps1 to $env:USERPROFILE\.clawdbot\ first"
    exit 1
}

$action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-ExecutionPolicy Bypass -WindowStyle Hidden -File `"$watchdogPath`""
$trigger = New-ScheduledTaskTrigger -AtLogon -User $env:USERNAME
$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -ExecutionTimeLimit ([TimeSpan]::Zero)
Register-ScheduledTask -TaskName "ClawdbotWatchdog" -Action $action -Trigger $trigger -Settings $settings -Force

# Start the task now
Start-ScheduledTask -TaskName "ClawdbotWatchdog"

Write-Host "Watchdog scheduled task created and started"
Write-Host "Logs: C:\tmp\clawdbot\watchdog.log"
