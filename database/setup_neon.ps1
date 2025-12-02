# Script untuk setup Neon PostgreSQL Database
# PowerShell Script

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Setup Neon PostgreSQL Database" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Cek apakah psql terinstall
$psqlInstalled = Get-Command psql -ErrorAction SilentlyContinue

if (-not $psqlInstalled) {
    Write-Host "❌ psql tidak ditemukan!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Anda bisa setup database dengan 2 cara:" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "CARA 1: Via Neon Console (Web)" -ForegroundColor Green
    Write-Host "1. Buka: https://console.neon.tech" -ForegroundColor White
    Write-Host "2. Login ke project Anda" -ForegroundColor White
    Write-Host "3. Klik 'SQL Editor'" -ForegroundColor White
    Write-Host "4. Copy paste isi file: setup_database.sql" -ForegroundColor White
    Write-Host "5. Klik 'Run'" -ForegroundColor White
    Write-Host ""
    Write-Host "CARA 2: Install psql dulu" -ForegroundColor Green
    Write-Host "Download: https://www.postgresql.org/download/windows/" -ForegroundColor White
    Write-Host ""
    pause
    exit
}

Write-Host "✓ psql ditemukan" -ForegroundColor Green
Write-Host ""

# Minta connection string
Write-Host "Masukkan Neon Connection String:" -ForegroundColor Yellow
Write-Host "Format: postgresql://user:pass@host/db?sslmode=require" -ForegroundColor Gray
Write-Host ""
$connectionString = Read-Host "Connection String"

if ([string]::IsNullOrWhiteSpace($connectionString)) {
    Write-Host "❌ Connection string tidak boleh kosong!" -ForegroundColor Red
    pause
    exit
}

Write-Host ""
Write-Host "Menjalankan setup script..." -ForegroundColor Yellow
Write-Host ""

# Jalankan SQL script
$sqlFile = Join-Path $PSScriptRoot "setup_database.sql"

if (-not (Test-Path $sqlFile)) {
    Write-Host "❌ File setup_database.sql tidak ditemukan!" -ForegroundColor Red
    pause
    exit
}

try {
    # Execute SQL file
    psql $connectionString -f $sqlFile
    
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Green
    Write-Host "  ✓ Database berhasil di-setup!" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor Yellow
    Write-Host "1. Update file backend/.env dengan connection string" -ForegroundColor White
    Write-Host "2. Jalankan: cd backend && npm install && npm start" -ForegroundColor White
    Write-Host "3. Test: http://localhost:3000/api/health" -ForegroundColor White
    Write-Host ""
    
} catch {
    Write-Host ""
    Write-Host "❌ Error saat setup database!" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    Write-Host ""
    Write-Host "Silakan setup manual via Neon Console:" -ForegroundColor Yellow
    Write-Host "https://console.neon.tech" -ForegroundColor White
    Write-Host ""
}

pause
