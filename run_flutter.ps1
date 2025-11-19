$env:JAVA_HOME = "C:\Program Files\Eclipse Adoptium\jdk-17.0.17.10-hotspot"
$env:PATH = "$env:JAVA_HOME\bin;$env:PATH"

Write-Host "Verifying Java..." -ForegroundColor Cyan
java -version

Write-Host ""
Write-Host "JAVA_HOME: $env:JAVA_HOME" -ForegroundColor Green
Write-Host ""

if ($args.Count -eq 0) {
    Write-Host "Usage: .\run_flutter.ps1 [flutter_command]" -ForegroundColor Yellow
    Write-Host "Examples:" -ForegroundColor Yellow
    Write-Host "  .\run_flutter.ps1 run" -ForegroundColor Cyan
    Write-Host "  .\run_flutter.ps1 build apk --release" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Running default: flutter run" -ForegroundColor Yellow
    flutter run
} else {
    $command = $args -join " "
    Write-Host "Running: flutter $command" -ForegroundColor Cyan
    flutter $command
}

