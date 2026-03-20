@echo off
TITLE ChilleeeZDevments - Hot DEVMENTS ONLY
COLOR 0A

echo ===================================================
echo Company NAme : ChilleeeZDevments
echo Solgan : Hot DEVMENTS ONLY
echo ===================================================
echo.
echo Initiating One-Click Cloud Build...
echo.

:: Pushing changes to GitHub to trigger the automated build
git add .
git commit -m "One-Click Deploy Trigger by ChilleeeZDevments"
git push

echo.
echo [SUCCESS] Source code synced to GitHub!
echo.
echo The cloud build servers are now compiling your recovery image.
echo Please visit your GitHub Actions page to track progress and download it:
echo https://github.com/ChilleeeZ/custom_recovery_samsung_a05s/actions
echo.
echo Once the build is finished and you have downloaded 'recovery.img',
echo place it in this folder and run '2_OneClick_Flash.bat'.
echo.
pause
