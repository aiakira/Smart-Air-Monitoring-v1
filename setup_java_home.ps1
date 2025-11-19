# Script untuk setup JAVA_HOME dari Java yang sudah terinstall via Chocolatey

Write-Host "=== Setup JAVA_HOME ===" -ForegroundColor Cyan
Write-Host ""

# Lokasi umum Java
$possiblePaths = @(
    "C:\Program Files\Eclipse Adoptium\jdk-*",
    "C:\Program Files\Microsoft\jdk-*",
    "C:\Program Files\Java\jdk-*",
    "C:\Program Files (x86)\Java\jdk-*",
    "$env:LOCALAPPDATA\Programs\Eclipse Adoptium\jdk-*"
)

$foundJava = $null

Write-Host "Mencari instalasi Java..." -ForegroundColor Yellow

foreach ($path in $possiblePaths) {
    $dirs = Get-ChildItem -Path $path -ErrorAction SilentlyContinue | Sort-Object Name -Descending
    if ($dirs) {
        $foundJava = $dirs[0].FullName
        Write-Host "✅ Java ditemukan di: $foundJava" -ForegroundColor Green
        break
    }
}

# Cek juga di Chocolatey lib
if (-not $foundJava) {
    $chocoPath = "C:\ProgramData\chocolatey\lib\openjdk*\tools\jdk*"
    $dirs = Get-ChildItem -Path $chocoPath -ErrorAction SilentlyContinue | Sort-Object Name -Descending
    if ($dirs) {
        $foundJava = $dirs[0].FullName
        Write-Host "✅ Java ditemukan di: $foundJava" -ForegroundColor Green
    }
}

if (-not $foundJava) {
    Write-Host ""
    Write-Host "❌ Java tidak ditemukan!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Silakan install Java secara manual:" -ForegroundColor Yellow
    Write-Host "1. Download dari: https://adoptium.net/temurin/releases/?version=17" -ForegroundColor Cyan
    Write-Host "2. Install Java JDK 17" -ForegroundColor Cyan
    Write-Host "3. Jalankan script ini lagi" -ForegroundColor Cyan
    exit 1
}

Write-Host ""
Write-Host "Mengkonfigurasi JAVA_HOME..." -ForegroundColor Yellow

# Set JAVA_HOME untuk sesi ini
$env:JAVA_HOME = $foundJava
$env:PATH = "$foundJava\bin;$env:PATH"

Write-Host "JAVA_HOME diset ke: $env:JAVA_HOME" -ForegroundColor Green

# Test Java
Write-Host ""
Write-Host "Testing Java..." -ForegroundColor Yellow
try {
    $version = java -version 2>&1 | Select-Object -First 1
    Write-Host "✅ Java version: $version" -ForegroundColor Green
} catch {
    Write-Host "❌ Java tidak bisa dijalankan" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "=== Set JAVA_HOME Permanen ===" -ForegroundColor Cyan
Write-Host ""
$setPermanent = Read-Host "Apakah Anda ingin set JAVA_HOME secara permanen? (Y/N)"

if ($setPermanent -eq "Y" -or $setPermanent -eq "y") {
    try {
        # Set JAVA_HOME secara permanen
        [System.Environment]::SetEnvironmentVariable("JAVA_HOME", $foundJava, [System.EnvironmentVariableTarget]::Machine)
        Write-Host "✅ JAVA_HOME berhasil diset secara permanen!" -ForegroundColor Green
        
        # Tambahkan ke PATH
        $currentPath = [System.Environment]::GetEnvironmentVariable("Path", [System.EnvironmentVariableTarget]::Machine)
        $javaBin = "$foundJava\bin"
        
        if ($currentPath -notlike "*$javaBin*") {
            $newPath = "$javaBin;$currentPath"
            [System.Environment]::SetEnvironmentVariable("Path", $newPath, [System.EnvironmentVariableTarget]::Machine)
            Write-Host "✅ Java bin berhasil ditambahkan ke PATH!" -ForegroundColor Green
        } else {
            Write-Host "ℹ️  Java bin sudah ada di PATH" -ForegroundColor Yellow
        }
        
        Write-Host ""
        Write-Host "⚠️  PERHATIAN: Anda perlu restart PowerShell atau komputer untuk perubahan berlaku!" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "Setelah restart, jalankan:" -ForegroundColor Cyan
        Write-Host "  flutter run" -ForegroundColor White
    } catch {
        Write-Host "❌ Error: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host "Pastikan Anda menjalankan PowerShell sebagai Administrator!" -ForegroundColor Yellow
    }
} else {
    Write-Host ""
    Write-Host "JAVA_HOME hanya diset untuk sesi ini." -ForegroundColor Yellow
    Write-Host "Untuk set permanen, jalankan script ini lagi dan pilih Y" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "=== Selesai ===" -ForegroundColor Green

