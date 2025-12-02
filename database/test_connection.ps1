# Test Connection to Neon PostgreSQL Database
# Usage: .\database\test_connection.ps1

Write-Host "🔍 Testing Neon Database Connection..." -ForegroundColor Cyan
Write-Host ""

# Check if Node.js is installed
try {
    $nodeVersion = node --version
    Write-Host "✅ Node.js version: $nodeVersion" -ForegroundColor Green
} catch {
    Write-Host "❌ Node.js not found! Please install Node.js first." -ForegroundColor Red
    Write-Host "   Download from: https://nodejs.org" -ForegroundColor Yellow
    exit 1
}

# Check if pg module is installed
Write-Host "📦 Checking pg module..." -ForegroundColor Cyan

$pgInstalled = $false
if (Test-Path "node_modules/pg") {
    $pgInstalled = $true
    Write-Host "✅ pg module found" -ForegroundColor Green
} else {
    Write-Host "⚠️  pg module not found. Installing..." -ForegroundColor Yellow
    npm install pg
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ pg module installed successfully" -ForegroundColor Green
        $pgInstalled = $true
    } else {
        Write-Host "❌ Failed to install pg module" -ForegroundColor Red
        exit 1
    }
}

Write-Host ""
Write-Host "🚀 Running connection test..." -ForegroundColor Cyan
Write-Host ""

# Run the test script
node database/test_connection.js

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "✅ Connection test completed!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor Yellow
    Write-Host "1. Jika schema belum ada, jalankan: database/setup_database.sql" -ForegroundColor White
    Write-Host "2. Start backend server: cd backend && npm start" -ForegroundColor White
    Write-Host "3. Test API: curl http://localhost:3000/api/data/terbaru" -ForegroundColor White
} else {
    Write-Host ""
    Write-Host "❌ Connection test failed!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Troubleshooting:" -ForegroundColor Yellow
    Write-Host "1. Check DATABASE_URL in backend/.env" -ForegroundColor White
    Write-Host "2. Check internet connection" -ForegroundColor White
    Write-Host "3. Check Neon project is active at https://console.neon.tech" -ForegroundColor White
    Write-Host "4. Verify connection string format" -ForegroundColor White
}
