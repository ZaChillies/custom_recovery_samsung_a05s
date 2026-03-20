@echo off
TITLE ChilleeeZDevments - Package Recovery for Odin
COLOR 0C

echo ===================================================
echo Company NAme : ChilleeeZDevments
echo Solgan : Hot DEVMENTS ONLY
echo ===================================================
echo.

IF NOT EXIST recovery.img (
    echo [ERROR] 'recovery.img' not found in this folder!
    echo Please download it from your GitHub Actions page first!
    echo https://github.com/ZaChillies/custom_recovery_samsung_a05s/actions
    echo.
    pause
    exit
)

echo Packaging recovery.img to recovery.tar for Samsung Odin...
tar -H ustar -c -f recovery.tar recovery.img

echo.
echo [SUCCESS] recovery.tar has been securely created!
echo.
echo ---------------------------------------------------
echo FINAL DEVICE DEPLOYMENT STEPS:
echo 1. Ensure your bootloader is unlocked.
echo 2. Reboot your Galaxy A05s to Download Mode (Turn off, hold Vol Up + Vol Down, plug in USB).
echo 3. Open Odin on your PC.
echo 4. Load 'recovery.tar' into the [AP] slot.
echo 5. UNCHECK "Auto Reboot" in Odin options.
echo 6. Click Start!
echo 7. When PASS appears, hold Vol Down + Power to turn off, then immediately hold Vol Up + Power to boot directly into TWRP.
echo ---------------------------------------------------
echo.
pause
