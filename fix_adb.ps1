Write-Host "ADB Troubleshooting Script" -ForegroundColor Cyan
Write-Host "=========================" -ForegroundColor Cyan
Write-Host ""

$adbPath = "C:\Users\LENOVO\AppData\Local\Android\sdk\platform-tools\adb.exe"

Write-Host "1. Killing ADB server..." -ForegroundColor Yellow
try {
    & $adbPath kill-server
    Write-Host "   ✅ ADB server killed" -ForegroundColor Green
} catch {
    Write-Host "   ❌ Failed to kill ADB server" -ForegroundColor Red
}

Write-Host ""
Write-Host "2. Starting ADB server..." -ForegroundColor Yellow
try {
    & $adbPath start-server
    Write-Host "   ✅ ADB server started" -ForegroundColor Green
} catch {
    Write-Host "   ❌ Failed to start ADB server" -ForegroundColor Red
}

Write-Host ""
Write-Host "3. Checking connected devices..." -ForegroundColor Yellow
try {
    $devices = & $adbPath devices
    Write-Host "   📱 Connected devices:" -ForegroundColor Green
    $devices | ForEach-Object { Write-Host "      $_" -ForegroundColor Gray }
} catch {
    Write-Host "   ❌ Failed to list devices" -ForegroundColor Red
}

Write-Host ""
Write-Host "4. Checking Flutter devices..." -ForegroundColor Yellow
try {
    flutter devices
} catch {
    Write-Host "   ❌ Flutter devices command failed" -ForegroundColor Red
}

Write-Host ""
Write-Host "🔧 Troubleshooting Tips:" -ForegroundColor Cyan
Write-Host "• Pastikan USB Debugging aktif di Android" -ForegroundColor White
Write-Host "• Coba cabut dan colok ulang kabel USB" -ForegroundColor White
Write-Host "• Restart Android device jika perlu" -ForegroundColor White
Write-Host "• Gunakan kabel USB yang bagus (bukan charging-only)" -ForegroundColor White
Write-Host ""

Write-Host "Press Enter to exit..." -ForegroundColor Yellow
Read-Host