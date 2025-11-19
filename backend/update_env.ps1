# Script PowerShell untuk update file .env dengan connection string baru
# Jalankan di folder backend/

$envContent = @"
PORT=3000
# Recommended for most uses (with connection pooling)
DATABASE_URL=postgresql://neondb_owner:npg_U7IHN4rFmCVs@ep-lucky-darkness-a15k13s2-pooler.ap-southeast-1.aws.neon.tech/neondb?sslmode=require

# For uses requiring a connection without pgbouncer (unpooled)
# DATABASE_URL_UNPOOLED=postgresql://neondb_owner:npg_U7IHN4rFmCVs@ep-lucky-darkness-a15k13s2.ap-southeast-1.aws.neon.tech/neondb?sslmode=require
"@

$envPath = Join-Path $PSScriptRoot ".env"

try {
    $envContent | Out-File -FilePath $envPath -Encoding utf8 -NoNewline -Force
    Write-Host "✅ File .env berhasil diupdate!" -ForegroundColor Green
    Write-Host "   Connection string baru sudah disimpan" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Langkah selanjutnya:" -ForegroundColor Yellow
    Write-Host "1. Setup database schema di Neon Console (jalankan database/schema.sql)" -ForegroundColor White
    Write-Host "2. Jalankan server: npm start" -ForegroundColor White
} catch {
    Write-Host "❌ Error: $($_.Exception.Message)" -ForegroundColor Red
}
