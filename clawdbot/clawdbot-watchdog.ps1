# Clawdbot Gateway Watchdog Script
# Monitors and auto-restarts the gateway if it crashes
#
# Usage: powershell -ExecutionPolicy Bypass -File clawdbot-watchdog.ps1

$LogFile = "C:\tmp\clawdbot\watchdog.log"
$CheckInterval = 30  # seconds between checks
$MaxRestarts = 10    # max restarts before giving up (reset after 1 hour)
$RestartCount = 0
$LastRestartTime = Get-Date

# Ensure log directory exists
$logDir = Split-Path $LogFile -Parent
if (-not (Test-Path $logDir)) {
    New-Item -ItemType Directory -Path $logDir -Force | Out-Null
}

function Write-Log {
    param([string]$Message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $line = "$timestamp - $Message"
    Write-Host $line
    Add-Content -Path $LogFile -Value $line -ErrorAction SilentlyContinue
}

function Test-GatewayRunning {
    try {
        $response = Invoke-WebRequest -Uri "http://127.0.0.1:18789/health" -UseBasicParsing -TimeoutSec 5 -ErrorAction Stop
        return $response.StatusCode -eq 200
    } catch {
        return $false
    }
}

function Start-Gateway {
    Write-Log "Starting Clawdbot Gateway..."
    try {
        # Use full path since scheduled tasks don't have user PATH
        $clawdbotCmd = "C:\Users\felip\AppData\Roaming\npm\clawdbot.cmd"
        Start-Process -FilePath $clawdbotCmd -ArgumentList "gateway" -WindowStyle Hidden -ErrorAction Stop
        Start-Sleep -Seconds 10

        if (Test-GatewayRunning) {
            Write-Log "Gateway started successfully"
            return $true
        } else {
            Write-Log "Gateway did not respond after start"
            return $false
        }
    } catch {
        Write-Log "Error starting gateway: $_"
        return $false
    }
}

Write-Log "========================================="
Write-Log "Clawdbot Watchdog started (PID: $PID)"
Write-Log "Check interval: $CheckInterval seconds"
Write-Log "Max restarts: $MaxRestarts per hour"
Write-Log "========================================="

# Initial check
if (-not (Test-GatewayRunning)) {
    Write-Log "Gateway not running on startup, starting it..."
    Start-Gateway | Out-Null
}

while ($true) {
    try {
        # Reset restart count after 1 hour
        if ((Get-Date) - $LastRestartTime -gt [TimeSpan]::FromHours(1)) {
            if ($RestartCount -gt 0) {
                Write-Log "Resetting restart count (1 hour passed)"
            }
            $RestartCount = 0
        }

        if (-not (Test-GatewayRunning)) {
            Write-Log "Gateway not running!"

            if ($RestartCount -ge $MaxRestarts) {
                Write-Log "Max restarts ($MaxRestarts) reached. Waiting 1 hour before trying again."
                Start-Sleep -Seconds 3600
                $RestartCount = 0
                continue
            }

            if (Start-Gateway) {
                $RestartCount++
                $LastRestartTime = Get-Date
                Write-Log "Restart count: $RestartCount/$MaxRestarts"
            } else {
                $RestartCount++
                Write-Log "Failed to start gateway. Restart count: $RestartCount/$MaxRestarts"
            }
        }
    } catch {
        Write-Log "Error in watchdog loop: $_"
    }

    Start-Sleep -Seconds $CheckInterval
}
