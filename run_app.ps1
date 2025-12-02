Write-Host "Smart Air Monitoring v2.0 - Health & Wellness Edition" -ForegroundColor Cyan
Write-Host "Backend: Vercel (https://smart-air-monitoring-v2.vercel.app)" -ForegroundColor Green
Write-Host ""
Write-Host "🆕 Fitur Lengkap:" -ForegroundColor Yellow
Write-Host "  • 🎨 Dark Mode & 4 Custom Themes" -ForegroundColor White
Write-Host "  • 🔊 Noise Level Monitoring (6 kategori)" -ForegroundColor White
Write-Host "  • 🏥 Health Score & Wellness Tracking" -ForegroundColor White
Write-Host "  • 😷 Symptom Tracker (12 jenis gejala)" -ForegroundColor White
Write-Host "  • 💪 Exercise Recommendations" -ForegroundColor White
Write-Host "  • 😴 Sleep Quality Analysis" -ForegroundColor White
Write-Host "  • 🚨 Emergency Alerts & Auto-Call" -ForegroundColor White
Write-Host "  • 💊 Medication Reminders" -ForegroundColor White
Write-Host "  • 📋 Doctor Report Generator" -ForegroundColor White
Write-Host "  • 👨‍⚕️ Complete Medical Profile" -ForegroundColor White
Write-Host ""

# Restart ADB jika diperlukan
Write-Host "Checking ADB connection..." -ForegroundColor Yellow
try {
    & "C:\Users\LENOVO\AppData\Local\Android\sdk\platform-tools\adb.exe" devices | Out-Null
} catch {
    Write-Host "Restarting ADB..." -ForegroundColor Yellow
    & "C:\Users\LENOVO\AppData\Local\Android\sdk\platform-tools\adb.exe" kill-server | Out-Null
    & "C:\Users\LENOVO\AppData\Local\Android\sdk\platform-tools\adb.exe" start-server | Out-Null
}

Write-Host "Pilih platform:" -ForegroundColor Yellow
Write-Host "1. Web Browser (Chrome)" -ForegroundColor White
Write-Host "2. Windows Desktop" -ForegroundColor White  
Write-Host "3. Android Device" -ForegroundColor White
Write-Host ""

$choice = Read-Host "Pilih (1-3)"

switch ($choice) {
    "1" {
        Write-Host "Menjalankan di Web Browser..." -ForegroundColor Green
        Write-Host "Tunggu sebentar, Chrome akan terbuka..." -ForegroundColor Yellow
        flutter run -d chrome
    }
    "2" {
        Write-Host "Menjalankan di Windows Desktop..." -ForegroundColor Green
        flutter run -d windows
    }
    "3" {
        Write-Host "Menjalankan di Android Device..." -ForegroundColor Green
        Write-Host "Pastikan USB Debugging aktif dan device terhubung..." -ForegroundColor Yellow
        flutter run
    }
    default {
        Write-Host "Pilihan tidak valid!" -ForegroundColor Red
        exit 1
    }
}