# Script PowerShell untuk membuat file .env
# Jalankan di folder backend/

$envContent = @"
PORT=3000
# Recommended for most uses (with connection pooling)
DATABASE_URL=postgresql://neondb_owner:npg_M6CXs9WzouNa@ep-calm-sea-a1mu5wbo-pooler.ap-southeast-1.aws.neon.tech/neondb?sslmode=require

# For uses requiring a connection without pgbouncer (unpooled)
# DATABASE_URL_UNPOOLED=postgresql://neondb_owner:npg_M6CXs9WzouNa@ep-calm-sea-a1mu5wbo.ap-southeast-1.aws.neon.tech/neondb?sslmode=require
"@

$envPath = Join-Path $PSScriptRoot ".env"

if (Test-Path $envPath) {
    Write-Host "File .env sudah ada!" -ForegroundColor Yellow
    $overwrite = Read-Host "Apakah Anda ingin menimpa? (Y/N)"
    if ($overwrite -ne "Y" -and $overwrite -ne "y") {
        Write-Host "Dibatalkan." -ForegroundColor Red
        exit
    }
}

try {
    $envContent | Out-File -FilePath $envPath -Encoding utf8 -NoNewline
    Write-Host "✅ File .env berhasil dibuat di: $envPath" -ForegroundColor Green
    Write-Host ""
    Write-Host "Langkah selanjutnya:" -ForegroundColor Cyan
    Write-Host "1. Setup database schema di Neon Console (jalankan database/schema.sql)" -ForegroundColor Yellow
    Write-Host "2. Install dependencies: npm install" -ForegroundColor Yellow
    Write-Host "3. Jalankan server: npm start" -ForegroundColor Yellow
} catch {
    Write-Host "❌ Error: $($_.Exception.Message)" -ForegroundColor Red
}

