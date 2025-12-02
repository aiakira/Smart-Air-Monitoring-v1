Write-Host "========================================" -ForegroundColor Cyan
Write-Host "   Smart Air Monitoring - Run Config" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Fungsi untuk mendapatkan IP lokal
function Get-LocalIP {
    try {
        $ip = (Get-NetIPAddress -AddressFamily IPv4 -InterfaceAlias "Wi-Fi*" | Where-Object {$_.IPAddress -like "192.168.*" -or $_.IPAddress -like "10.*"})[0].IPAddress
        if (-not $ip) {
            $ip = (Get-NetIPAddress -AddressFamily IPv4 | Where-Object {$_.IPAddress -like "192.168.*" -or $_.IPAddress -like "10.*"})[0].IPAddress
        }
        return $ip
    }
    catch {
        return "192.168.1.100"
    }
}

$localIP = Get-LocalIP
Write-Host "IP komputer Anda terdeteksi: $localIP" -ForegroundColor Yellow
Write-Host ""

Write-Host "Pilih platform untuk menjalankan aplikasi:" -ForegroundColor Green
Write-Host ""
Write-Host "1. Web Browser (Chrome)" -ForegroundColor White
Write-Host "2. Windows Desktop" -ForegroundColor White
Write-Host "3. Android Device/Emulator" -ForegroundColor White
Write-Host "4. Custom URL" -ForegroundColor White
Write-Host ""

$choice = Read-Host "Pilih opsi (1-5)"

switch ($choice) {
    "1" {
        Write-Host ""
        Write-Host "Menjalankan di Web Browser..." -ForegroundColor Green
        flutter run -d chrome
    }
    "2" {
        Write-Host ""
        Write-Host "Menjalankan di Windows Desktop..." -ForegroundColor Green
        flutter run -d windows
    }
    "3" {
        Write-Host ""
        Write-Host "Menjalankan di Android..." -ForegroundColor Green
        flutter run
    }
    "4" {
        Write-Host ""
        $url = Read-Host "Masukkan URL API (contoh: https://api.example.com)"
        Write-Host "Menjalankan dengan URL: $url" -ForegroundColor Green
        flutter run --dart-define=API_BASE_URL=$url
    }
    default {
        Write-Host "Pilihan tidak valid!" -ForegroundColor Red
        exit 1
    }
}

Write-Host ""
Write-Host "Tekan Enter untuk keluar..." -ForegroundColor Yellow
Read-Host