@echo off
echo ========================================
echo   Create Keystore + Get SHA Keys
echo ========================================
echo.

set KEYSTORE_DIR=%USERPROFILE%\.android
set KEYSTORE_PATH=%KEYSTORE_DIR%\debug.keystore

echo Checking if .android directory exists...
if not exist "%KEYSTORE_DIR%" (
    echo Creating .android directory...
    mkdir "%KEYSTORE_DIR%"
)

echo.
echo Checking for existing keystore...
if exist "%KEYSTORE_PATH%" (
    echo ✅ Keystore already exists at: %KEYSTORE_PATH%
    echo.
) else (
    echo Creating debug keystore...
    echo This will take a moment...
    echo.
    
    keytool -genkey -v -keystore "%KEYSTORE_PATH%" -storepass android -alias androiddebugkey -keypass android -keyalg RSA -keysize 2048 -validity 10000 -dname "CN=Android Debug,O=Android,C=US"
    
    if exist "%KEYSTORE_PATH%" (
        echo ✅ Keystore created successfully!
    ) else (
        echo ❌ Failed to create keystore!
        echo Make sure Java/keytool is installed and in your PATH.
        pause
        exit /b 1
    )
)

echo.
echo ========================================
echo   Getting SHA Keys...
echo ========================================
echo.

keytool -list -v -alias androiddebugkey -keystore "%KEYSTORE_PATH%" -storepass android -keypass android | findstr "SHA1 SHA256"

echo.
echo ========================================
echo   ✅ SUCCESS!
echo ========================================
echo.
echo Copy the SHA-1 and SHA-256 values above
echo.
echo ========================================
echo   NEXT STEPS:
echo ========================================
echo.
echo 1. Copy SHA-1 from above
echo.
echo 2. Firebase Console:
echo    https://console.firebase.google.com/
echo    - Select: fir-tutorial-826a8
echo    - Settings → Project settings → Your apps
echo    - Click "Add fingerprint" → Paste SHA-1 → Save
echo    - Click "Add fingerprint" → Paste SHA-256 → Save
echo.
echo 3. Google Cloud Console:
echo    https://console.cloud.google.com/
echo    - Select: fir-tutorial-826a8
echo    - APIs ^& Services → Credentials
echo    - Create Credentials → OAuth client ID → Android
echo    - Package name: com.example.cgc
echo    - SHA-1: Paste your SHA-1
echo    - Create
echo.
echo 4. Download google-services.json:
echo    - Firebase Console → Project settings
echo    - Download google-services.json
echo    - Replace: android/app/google-services.json
echo.
echo 5. Run your app:
echo    flutter clean
echo    flutter pub get
echo    flutter run
echo.
echo Google Sign-In will work! 🎉
echo.
pause
