# Clawdbot Gateway Watchdog Script
# Monitors and auto-restarts the gateway if it crashes
#
# Usage: powershell -ExecutionPolicy Bypass -File clawdbot-watchdog.ps1
# Or run as scheduled task for persistent monitoring

$LogFile = "$env:TEMP\clawdbot-watchdog.log"
$CheckInterval = 30  # seconds between checks
$MaxRestarts = 5     # max restarts before giving up (reset after 1 hour)
$RestartCount = 0
$LastRestartTime = Get-Date

function Write-Log {
    param([string]$Message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$timestamp - $Message" | Tee-Object -FilePath $LogFile -Append
}

function Test-GatewayRunning {
    $process = Get-Process -Name "node" -ErrorAction SilentlyContinue |
        Where-Object { $_.CommandLine -like "*clawdbot*" }
    return $null -ne $process
}

function Start-Gateway {
    Write-Log "Starting Clawdbot Gateway..."
    Start-Process -FilePath "clawdbot" -ArgumentList "gateway" -WindowStyle Hidden
    Start-Sleep -Seconds 5

    if (Test-GatewayRunning) {
        Write-Log "Gateway started successfully"
        return $true
    } else {
        Write-Log "Failed to start gateway"
        return $false
    }
}

Write-Log "Clawdbot Watchdog started"
Write-Log "Check interval: $CheckInterval seconds"

while ($true) {
    # Reset restart count after 1 hour
    if ((Get-Date) - $LastRestartTime -gt [TimeSpan]::FromHours(1)) {
        $RestartCount = 0
    }

    if (-not (Test-GatewayRunning)) {
        Write-Log "Gateway not running!"

        if ($RestartCount -ge $MaxRestarts) {
            Write-Log "Max restarts ($MaxRestarts) reached. Waiting 1 hour before trying again."
            Start-Sleep -Seconds 3600
            $RestartCount = 0
        }

        if (Start-Gateway) {
            $RestartCount++
            $LastRestartTime = Get-Date
            Write-Log "Restart count: $RestartCount/$MaxRestarts"
        }
    }

    Start-Sleep -Seconds $CheckInterval
}
