<#
.SYNOPSIS
ChilleeeZDevments Ultimate One-Click Build & Deploy!
#>

Write-Host "===================================================" -ForegroundColor Green
Write-Host "Company NAme : ChilleeeZDevments" -ForegroundColor Green
Write-Host "Solgan : Hot DEVMENTS ONLY" -ForegroundColor Green
Write-Host "===================================================" -ForegroundColor Green
Write-Host ""

# Refresh paths just in case
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

# 1. Authenticate
Write-Host "[1/5] Checking GitHub Authentication..." -ForegroundColor Cyan
$authStatus = gh auth status 2>&1
if ($authStatus -match "not logged into any") {
    Write-Host "Please check your browser to login with GitHub." -ForegroundColor Yellow
    gh auth login --web -h github.com
}

$ghUser = gh api user -q .login
if (-not $ghUser) {
    Write-Host "[ERROR] Could not retrieve GitHub Username. Are you logged in?" -ForegroundColor Red
    Read-Host "Press Enter to exit..."
    exit
}
Write-Host "Logged in as $ghUser!" -ForegroundColor Green

# Security Fix: Request permission to create GitHub Actions workflows
Write-Host "Requesting 'workflow' action permissions. (Check your browser window if it pops up)..." -ForegroundColor Yellow
gh auth refresh -h github.com -s workflow

# Make git securely use GitHub CLI's active session without asking for password again
gh auth setup-git --force

# 2. Fork the repository
Write-Host "[2/5] Creating your personal fork..." -ForegroundColor Cyan
gh api repos/jokonotobot0/custom_recovery_samsung_a05s/forks -X POST -F name=custom_recovery_samsung_a05s --silent
Start-Sleep -Seconds 12

# Always override origin to the user's fork
$forkUrl = "https://github.com/$ghUser/custom_recovery_samsung_a05s"
git remote set-url origin "$forkUrl.git"
Write-Host "Updated your remote 'origin' to your fork: $forkUrl" -ForegroundColor Gray

# 3. Commit and Push
Write-Host "[3/5] Pushing ChilleeeZDevments build action to your fork..." -ForegroundColor Cyan
git add .
git commit -m "Trigger One-Click Build by ChilleeeZDevments"

$pushResult = git push -u origin twrp-12.1 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "[ERROR] Git Push failed: $pushResult" -ForegroundColor Red
    Write-Host "This means GitHub couldn't create your fork properly or you didn't grant permission in the browser." -ForegroundColor Yellow
    Read-Host "Press Enter to exit..."
    exit
}

# 4. Trigger Workflow
Write-Host "[4/5] Triggering the cloud build on GitHub Actions..." -ForegroundColor Cyan
Start-Sleep -Seconds 5 # Wait for github to register the commit
gh workflow run twrp_build.yml --ref twrp-12.1 --repo "$ghUser/custom_recovery_samsung_a05s" 2>&1

Write-Host "Waiting for GitHub servers to assign a build agent... (15 seconds)" -ForegroundColor Yellow
Start-Sleep -Seconds 15
$runId = gh run list --workflow twrp_build.yml --repo "$ghUser/custom_recovery_samsung_a05s" --limit 1 --json databaseId -q ".[0].databaseId"

if (-not $runId) {
    Write-Host "[ERROR] Could not track the workflow. Please visit $forkUrl/actions to view it manually." -ForegroundColor Red
    Read-Host "Press Enter to exit..."
    exit
}

Write-Host "Build started! Tracking progress... (This process takes ~15-25 minutes in the cloud)" -ForegroundColor Cyan
gh run watch $runId --repo "$ghUser/custom_recovery_samsung_a05s"

# 5. Download & Package
Write-Host "[5/5] Build finished! Downloading your new recovery image..." -ForegroundColor Green
gh run download $runId -n recovery-a05s --repo "$ghUser/custom_recovery_samsung_a05s"
if (Test-Path "recovery-a05s\recovery.img") {
    Move-Item -Path "recovery-a05s\recovery.img" -Destination ".\recovery.img" -Force
    Remove-Item -Recurse -Force "recovery-a05s"
}

if (-not (Test-Path "recovery.img")) {
    Write-Host "[ERROR] Build failed or artifact not found. Please review the logs on $forkUrl/actions" -ForegroundColor Red
    Read-Host "Press Enter to exit..."
    exit
}

Write-Host "Packaging recovery.img to recovery.tar for Odin..." -ForegroundColor Cyan
tar -H ustar -c -f recovery.tar recovery.img

Write-Host ""
Write-Host "===================================================" -ForegroundColor Green
Write-Host "               ONE-CLICK SUCCESS!!                 " -ForegroundColor Green
Write-Host "       Your recovery.tar is fully compiled.         " -ForegroundColor Green
Write-Host "===================================================" -ForegroundColor Green
Write-Host "To Finally 'Run' this Solution on your device:"
Write-Host "  1. Reboot Galaxy A05s to Download Mode."
Write-Host "     (Turn off -> Hold Vol Up & Vol Down -> Plug in USB)"
Write-Host "  2. Open Odin on your PC."
Write-Host "  3. Select your brand new 'recovery.tar' in the [AP] slot."
Write-Host "  4. UNCHECK 'Auto Reboot' in options."
Write-Host "  5. Press Start!"
Write-Host "  6. When finished, reboot immediately to TWRP (Vol Up + Power)."
Write-Host "Enjoy your Custom Recovery!" -ForegroundColor Yellow
Write-Host ""
Read-Host "Press Enter to finish and close this window..."
