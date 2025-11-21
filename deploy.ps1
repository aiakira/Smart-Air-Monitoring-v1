# PowerShell Script untuk Deploy ke GitHub dan Vercel
# Jalankan: .\deploy.ps1

Write-Host "Smart Air Monitor - Deployment Script" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan
Write-Host ""

# Check if git is initialized
if (-not (Test-Path ".git")) {
    Write-Host "Initializing Git repository..." -ForegroundColor Yellow
    git init
    Write-Host "Git initialized" -ForegroundColor Green
} else {
    Write-Host "Git already initialized" -ForegroundColor Green
}

# Check git status
Write-Host ""
Write-Host "Checking git status..." -ForegroundColor Yellow
git status

# Ask for commit message
Write-Host ""
$commitMessage = Read-Host "Enter commit message (or press Enter for default)"
if ([string]::IsNullOrWhiteSpace($commitMessage)) {
    $commitMessage = "Deploy: Smart Air Monitor v1.0"
}

# Add all files
Write-Host ""
Write-Host "Adding files to git..." -ForegroundColor Yellow
git add .
Write-Host "Files added" -ForegroundColor Green

# Commit
Write-Host ""
Write-Host "Committing changes..." -ForegroundColor Yellow
git commit -m "$commitMessage"
Write-Host "Changes committed" -ForegroundColor Green

# Check if remote exists
$remoteExists = git remote | Select-String "origin"

if (-not $remoteExists) {
    Write-Host ""
    Write-Host "No remote repository found" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Please create a repository on GitHub first, then enter the URL:" -ForegroundColor Cyan
    Write-Host "Example: https://github.com/yourusername/smart-air-monitor.git" -ForegroundColor Gray
    Write-Host ""
    $repoUrl = Read-Host "GitHub repository URL"
    
    if (-not [string]::IsNullOrWhiteSpace($repoUrl)) {
        git remote add origin $repoUrl
        Write-Host "Remote added" -ForegroundColor Green
    } else {
        Write-Host "No URL provided. Skipping remote setup." -ForegroundColor Red
        exit
    }
}

# Get current branch
$currentBranch = git branch --show-current

# Push to GitHub
Write-Host ""
Write-Host "Pushing to GitHub..." -ForegroundColor Yellow
try {
    git push -u origin $currentBranch
    Write-Host "Successfully pushed to GitHub!" -ForegroundColor Green
} catch {
    Write-Host "Push failed. You may need to pull first or resolve conflicts." -ForegroundColor Red
    Write-Host "Try: git pull origin $currentBranch --rebase" -ForegroundColor Yellow
}

# Next steps
Write-Host ""
Write-Host "======================================" -ForegroundColor Cyan
Write-Host "Code uploaded to GitHub!" -ForegroundColor Green
Write-Host ""
Write-Host "Next Steps:" -ForegroundColor Cyan
Write-Host "1. Go to https://vercel.com" -ForegroundColor White
Write-Host "2. Click 'Add New...' -> 'Project'" -ForegroundColor White
Write-Host "3. Import your GitHub repository" -ForegroundColor White
Write-Host "4. Add environment variable:" -ForegroundColor White
Write-Host "   DATABASE_URL=your_database_url" -ForegroundColor Gray
Write-Host "5. Click 'Deploy'" -ForegroundColor White
Write-Host ""
Write-Host "Full guide: DEPLOYMENT_GUIDE.md" -ForegroundColor Cyan
Write-Host ""
Write-Host "Happy deploying!" -ForegroundColor Green
