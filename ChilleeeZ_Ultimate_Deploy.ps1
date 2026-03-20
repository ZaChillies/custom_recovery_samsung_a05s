<#
.SYNOPSIS
ChilleeeZDevments Ultimate One-Click Build & Deploy!
#>



Write-Host "===================================================" -ForegroundColor Green
Write-Host "Company NAme : ChilleeeZDevments" -ForegroundColor Green
Write-Host "Solgan : Hot DEVMENTS ONLY" -ForegroundColor Green
Write-Host "===================================================" -ForegroundColor Green
Write-Host ""

# 1. Check for GitHub CLI
if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
    Write-Host "[1/6] GitHub CLI not found. Installing via winget..." -ForegroundColor Yellow
    winget install --id GitHub.cli -e --source winget --accept-package-agreements --accept-source-agreements
    
    # Attempt to reload environment variables so gh is in path
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
}

# Double check if command works now
if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
    Write-Host "[ERROR] Could not install GitHub CLI automatically. Please install it from https://cli.github.com/ and re-run this script." -ForegroundColor Red
    Read-Host "Press Enter to exit..."
    exit
}

# 2. Authenticate
Write-Host "[2/6] Checking GitHub authentication..." -ForegroundColor Cyan
$ghAuth = gh auth status 2>&1
if ($ghAuth -match "You are not logged into any GitHub hosts") {
    Write-Host "You must authenticate with GitHub to trigger your free cloud builds." -ForegroundColor Yellow
    Write-Host "A browser window will open..."
    gh auth login --web -h github.com
}

# 3. Fork and update remote
Write-Host "[3/6] Ensuring you have a personal fork on GitHub..." -ForegroundColor Cyan
gh repo fork jokonotobot0/custom_recovery_samsung_a05s --remote=true 2>&1 | Out-Null
# Update git origin to your fork
$forkUrl = gh repo view --json url -q .url
if ($forkUrl) {
    git remote set-url origin "$forkUrl.git" 2>&1 | Out-Null
    Write-Host " -> Switched git remote to $forkUrl" -ForegroundColor Gray
}

# 4. Push workflow
Write-Host "[4/6] Pushing ChilleeeZDevments build action to your fork..." -ForegroundColor Cyan
git add .
git commit -m "Trigger One-Click Build by ChilleeeZDevments" 2>&1 | Out-Null
git push -u origin twrp-12.1 2>&1 | Out-Null

# 5. Trigger Workflow
Write-Host "[5/6] Triggering the cloud build on GitHub Actions..." -ForegroundColor Cyan
Start-Sleep -Seconds 5 # Wait for github to register the commit
gh workflow run twrp_build.yml --ref twrp-12.1 2>&1 | Out-Null

Write-Host "Waiting for GitHub servers to assign a build agent..." -ForegroundColor Yellow
Start-Sleep -Seconds 15 # Wait for run to appear in list
$runId = gh run list --workflow twrp_build.yml --limit 1 --json databaseId -q ".[0].databaseId"

if (-not $runId) {
    Write-Host "[ERROR] Could not find the workflow run! You may need to visit $forkUrl/actions to trigger it manually." -ForegroundColor Red
    Read-Host "Press Enter to exit..."
    exit
}

Write-Host "Build started! Tracking progress... (This process takes ~15-25 minutes in the cloud)" -ForegroundColor Cyan
gh run watch $runId

# 6. Download & Package
Write-Host "[6/6] Build finished! Downloading your new recovery image..." -ForegroundColor Green
gh run download $runId -n recovery-a05s
if (Test-Path "recovery-a05s\recovery.img") {
    Move-Item -Path "recovery-a05s\recovery.img" -Destination ".\recovery.img" -Force
    Remove-Item -Recurse -Force "recovery-a05s"
}

if (-not (Test-Path "recovery.img")) {
    Write-Host "[ERROR] Build failed or artifact not found. Please review the logs on GitHub Actions." -ForegroundColor Red
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
