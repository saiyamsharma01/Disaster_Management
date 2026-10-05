@echo off
echo ========================================
echo   Getting SHA Keys - Simple Method
echo ========================================
echo.

echo Step 1: Building Android app to generate keystore...
echo This will take a minute...
echo.

flutter build apk --debug

echo.
echo Step 2: Getting SHA keys from generated keystore...
echo.

set KEYSTORE=%USERPROFILE%\.android\debug.keystore

if exist "%KEYSTORE%" (
    echo Found keystore! Getting SHA keys...
    echo.
    keytool -list -v -alias androiddebugkey -keystore "%KEYSTORE%" -storepass android -keypass android | findstr "SHA1 SHA256"
    echo.
    echo ========================================
    echo   SUCCESS! Copy the SHA values above
    echo ========================================
) else (
    echo ERROR: Keystore not found at: %KEYSTORE%
    echo.
    echo Please make sure Java/keytool is installed.
)

echo.
echo ========================================
echo   Next Steps:
echo ========================================
echo 1. Copy SHA-1 and SHA-256 from above
echo 2. Add them to Firebase Console
echo    https://console.firebase.google.com/
echo    Project: fir-tutorial-826a8
echo 3. Create Android OAuth client with same SHA-1
echo    https://console.cloud.google.com/
echo 4. Download new google-services.json
echo 5. Replace android/app/google-services.json
echo.
pause
