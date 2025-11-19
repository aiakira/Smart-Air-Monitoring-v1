
Write-Host "=== Install Java JDK untuk Flutter ===" -ForegroundColor Cyan
Write-Host ""

Write-Host "Mengecek Java yang sudah terinstall..." -ForegroundColor Yellow
try {
    $javaVersion = java -version 2>&1 | Select-Object -First 1
    Write-Host "Java sudah terinstall: $javaVersion" -ForegroundColor Green
    Write-Host ""
    Write-Host "JAVA_HOME saat ini: $env:JAVA_HOME" -ForegroundColor Yellow
    
    if ($env:JAVA_HOME) {
        Write-Host ""
        Write-Host "Java sudah terkonfigurasi dengan baik!" -ForegroundColor Green
        Write-Host "Anda bisa langsung menjalankan: flutter build apk --release" -ForegroundColor Cyan
        exit 0
    } else {
        Write-Host "Java terinstall tapi JAVA_HOME belum diset" -ForegroundColor Yellow
    }
} catch {
    Write-Host "Java belum terinstall" -ForegroundColor Red
}

Write-Host ""
Write-Host "Menginstall Java JDK 17 menggunakan Chocolatey..." -ForegroundColor Yellow
Write-Host "Ini akan memakan waktu beberapa menit..." -ForegroundColor Yellow
Write-Host ""

try {
    choco install openjdk17 -y
    
    Write-Host ""
    Write-Host "Java berhasil diinstall!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Mengkonfigurasi JAVA_HOME..." -ForegroundColor Yellow
    
    $javaPath = "C:\Program Files\Eclipse Adoptium\jdk-17*"
    $javaDirs = Get-ChildItem -Path $javaPath -ErrorAction SilentlyContinue | Sort-Object Name -Descending
    
    if (-not $javaDirs) {
        $javaPath = "C:\Program Files\Microsoft\jdk-17*"
        $javaDirs = Get-ChildItem -Path $javaPath -ErrorAction SilentlyContinue | Sort-Object Name -Descending
    }
    
    if ($javaDirs) {
        $foundJava = $javaDirs[0].FullName
        Write-Host "Java ditemukan di: $foundJava" -ForegroundColor Green
        
        $env:JAVA_HOME = $foundJava
        $env:PATH = "$foundJava\bin;$env:PATH"
        
        Write-Host ""
        Write-Host "Mengkonfigurasi JAVA_HOME secara permanen..." -ForegroundColor Yellow
        
        [System.Environment]::SetEnvironmentVariable("JAVA_HOME", $foundJava, [System.EnvironmentVariableTarget]::Machine)
        
        $currentPath = [System.Environment]::GetEnvironmentVariable("Path", [System.EnvironmentVariableTarget]::Machine)
        $javaBin = "$foundJava\bin"
        
        if ($currentPath -notlike "*$javaBin*") {
            $newPath = "$javaBin;$currentPath"
            [System.Environment]::SetEnvironmentVariable("Path", $newPath, [System.EnvironmentVariableTarget]::Machine)
        }
        
        Write-Host ""
        Write-Host "=== Instalasi Selesai! ===" -ForegroundColor Green
        Write-Host ""
        Write-Host "PERHATIAN:" -ForegroundColor Yellow
        Write-Host "1. Tutup PowerShell ini dan buka PowerShell baru" -ForegroundColor Yellow
        Write-Host "2. Atau restart komputer Anda" -ForegroundColor Yellow
        Write-Host "3. Setelah itu, verifikasi dengan: java -version" -ForegroundColor Yellow
        Write-Host "4. Lalu jalankan: flutter build apk --release" -ForegroundColor Cyan
        
    } else {
        Write-Host "Java terinstall tapi lokasinya tidak ditemukan" -ForegroundColor Yellow
        Write-Host "Silakan set JAVA_HOME secara manual" -ForegroundColor Yellow
    }
    
} catch {
    Write-Host ""
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host ""
    Write-Host "Pastikan:" -ForegroundColor Yellow
    Write-Host "1. Anda menjalankan PowerShell sebagai Administrator" -ForegroundColor Yellow
    Write-Host "2. Chocolatey sudah terinstall dengan benar" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Atau install Java secara manual menggunakan panduan di CARA_INSTALL_JAVA.md" -ForegroundColor Cyan
}

