# Cleanup Antigravity Cache Script for Windows
# Run when Antigravity IDE is slow or consuming too much disk space

$ErrorActionPreference = "SilentlyContinue"

Write-Host "=== Antigravity Cache Cleanup (Windows) ===" -ForegroundColor Cyan
Write-Host ""

$GeminiDir = Join-Path $env:USERPROFILE ".gemini"
$AntigravityDir = Join-Path $GeminiDir "antigravity"
$BrowserProfileDir = Join-Path $GeminiDir "antigravity-browser-profile"

# Calculate initial size
function Get-FolderSize($path) {
    if (Test-Path $path) {
        $size = (Get-ChildItem -Path $path -Recurse -Force | Measure-Object -Property Length -Sum).Sum
        return [math]::Round($size / 1MB, 2)
    }
    return 0
}

$InitialSize = (Get-FolderSize $AntigravityDir) + (Get-FolderSize $BrowserProfileDir)
Write-Host "Initial cache size: $InitialSize MB" -ForegroundColor Yellow

# Clean browser recordings (older than 7 days)
Write-Host ""
Write-Host "Cleaning old browser recordings..." -ForegroundColor Yellow
$RecordingsDir = Join-Path $BrowserProfileDir "recordings"
if (Test-Path $RecordingsDir) {
    $OldFiles = Get-ChildItem -Path $RecordingsDir -Recurse -File |
        Where-Object { $_.LastWriteTime -lt (Get-Date).AddDays(-7) }
    $Count = ($OldFiles | Measure-Object).Count
    $OldFiles | Remove-Item -Force
    Write-Host "  Removed $Count old recording files" -ForegroundColor Green
}

# Clean brain sessions (keep last 5)
Write-Host ""
Write-Host "Cleaning old brain sessions..." -ForegroundColor Yellow
$BrainDir = Join-Path $AntigravityDir "brain"
if (Test-Path $BrainDir) {
    $Sessions = Get-ChildItem -Path $BrainDir -Directory |
        Sort-Object LastWriteTime -Descending |
        Select-Object -Skip 5
    $Count = ($Sessions | Measure-Object).Count
    $Sessions | Remove-Item -Recurse -Force
    Write-Host "  Removed $Count old brain sessions (kept 5 most recent)" -ForegroundColor Green
}

# Clean implicit memory (older than 7 days)
Write-Host ""
Write-Host "Cleaning old implicit memory..." -ForegroundColor Yellow
$MemoryDir = Join-Path $AntigravityDir "implicit-memory"
if (Test-Path $MemoryDir) {
    $OldFiles = Get-ChildItem -Path $MemoryDir -Recurse -File |
        Where-Object { $_.LastWriteTime -lt (Get-Date).AddDays(-7) }
    $Count = ($OldFiles | Measure-Object).Count
    $OldFiles | Remove-Item -Force
    Write-Host "  Removed $Count old memory files" -ForegroundColor Green
}

# Clean browser cache
Write-Host ""
Write-Host "Cleaning browser cache..." -ForegroundColor Yellow
$CacheDir = Join-Path $BrowserProfileDir "Default\Cache"
if (Test-Path $CacheDir) {
    $SizeBefore = Get-FolderSize $CacheDir
    Remove-Item -Path "$CacheDir\*" -Recurse -Force
    Write-Host "  Cleared $SizeBefore MB of browser cache" -ForegroundColor Green
}

# Clean Code Cache
$CodeCacheDir = Join-Path $BrowserProfileDir "Default\Code Cache"
if (Test-Path $CodeCacheDir) {
    $SizeBefore = Get-FolderSize $CodeCacheDir
    Remove-Item -Path "$CodeCacheDir\*" -Recurse -Force
    Write-Host "  Cleared $SizeBefore MB of code cache" -ForegroundColor Green
}

# Calculate final size
$FinalSize = (Get-FolderSize $AntigravityDir) + (Get-FolderSize $BrowserProfileDir)
$Saved = $InitialSize - $FinalSize

Write-Host ""
Write-Host "=== Cleanup Complete ===" -ForegroundColor Cyan
Write-Host "Final cache size: $FinalSize MB" -ForegroundColor Yellow
Write-Host "Space saved: $Saved MB" -ForegroundColor Green
Write-Host ""
