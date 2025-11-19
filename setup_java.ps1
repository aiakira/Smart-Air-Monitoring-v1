# Script PowerShell untuk Setup Java JDK untuk Flutter
# Jalankan sebagai Administrator

Write-Host "=== Setup Java JDK untuk Flutter Android Build ===" -ForegroundColor Cyan
Write-Host ""

# Cek apakah sudah ada Java
Write-Host "Mengecek Java yang sudah terinstall..." -ForegroundColor Yellow
try {
    $javaVersion = java -version 2>&1 | Select-Object -First 1
    Write-Host "Java sudah terinstall: $javaVersion" -ForegroundColor Green
    Write-Host ""
    Write-Host "JAVA_HOME saat ini: $env:JAVA_HOME" -ForegroundColor Yellow
    exit 0
} catch {
    Write-Host "Java belum terinstall atau tidak ada di PATH" -ForegroundColor Red
}

Write-Host ""
Write-Host "Mencari Java JDK yang sudah terinstall..." -ForegroundColor Yellow

# Lokasi umum Java JDK
$possibleJavaPaths = @(
    "C:\Program Files\Java\jdk-*",
    "C:\Program Files\Eclipse Adoptium\jdk-*",
    "C:\Program Files\Microsoft\jdk-*",
    "C:\Program Files (x86)\Java\jdk-*"
)

$foundJava = $null

foreach ($path in $possibleJavaPaths) {
    $dirs = Get-ChildItem -Path $path -ErrorAction SilentlyContinue | Sort-Object Name -Descending
    if ($dirs) {
        $foundJava = $dirs[0].FullName
        Write-Host "Ditemukan Java di: $foundJava" -ForegroundColor Green
        break
    }
}

if (-not $foundJava) {
    Write-Host ""
    Write-Host "Java JDK tidak ditemukan!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Silakan install Java JDK terlebih dahulu:" -ForegroundColor Yellow
    Write-Host "1. Menggunakan Winget (disarankan):" -ForegroundColor Cyan
    Write-Host "   winget install Microsoft.OpenJDK.17" -ForegroundColor White
    Write-Host ""
    Write-Host "2. Atau download dari: https://adoptium.net/" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Setelah install, jalankan script ini lagi." -ForegroundColor Yellow
    exit 1
}

Write-Host ""
Write-Host "Mengkonfigurasi JAVA_HOME..." -ForegroundColor Yellow

# Set JAVA_HOME untuk sesi ini
$env:JAVA_HOME = $foundJava
$env:PATH = "$foundJava\bin;$env:PATH"

Write-Host "JAVA_HOME diset ke: $env:JAVA_HOME" -ForegroundColor Green

# Tanya apakah ingin set permanen
Write-Host ""
$setPermanent = Read-Host "Apakah Anda ingin set JAVA_HOME secara permanen? (Y/N)"

if ($setPermanent -eq "Y" -or $setPermanent -eq "y") {
    try {
        # Set JAVA_HOME secara permanen
        [System.Environment]::SetEnvironmentVariable("JAVA_HOME", $foundJava, [System.EnvironmentVariableTarget]::Machine)
        Write-Host "JAVA_HOME berhasil diset secara permanen!" -ForegroundColor Green
        
        # Tambahkan ke PATH
        $currentPath = [System.Environment]::GetEnvironmentVariable("Path", [System.EnvironmentVariableTarget]::Machine)
        $javaBin = "$foundJava\bin"
        
        if ($currentPath -notlike "*$javaBin*") {
            $newPath = "$javaBin;$currentPath"
            [System.Environment]::SetEnvironmentVariable("Path", $newPath, [System.EnvironmentVariableTarget]::Machine)
            Write-Host "Java bin berhasil ditambahkan ke PATH!" -ForegroundColor Green
        } else {
            Write-Host "Java bin sudah ada di PATH" -ForegroundColor Yellow
        }
        
        Write-Host ""
        Write-Host "PERHATIAN: Anda perlu restart PowerShell atau komputer untuk perubahan berlaku!" -ForegroundColor Yellow
    } catch {
        Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host "Pastikan Anda menjalankan PowerShell sebagai Administrator!" -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "Verifikasi instalasi..." -ForegroundColor Yellow
try {
    $version = java -version 2>&1 | Select-Object -First 1
    Write-Host "Java version: $version" -ForegroundColor Green
    Write-Host ""
    Write-Host "Setup selesai! Sekarang Anda bisa menjalankan:" -ForegroundColor Green
    Write-Host "  flutter build apk --release" -ForegroundColor Cyan
} catch {
    Write-Host "Error: Java tidak bisa dijalankan. Pastikan instalasi benar." -ForegroundColor Red
}

