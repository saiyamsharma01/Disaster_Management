@echo off
echo ========================================
echo   Fix Build + Get SHA Keys
echo ========================================
echo.

echo Step 1: Cleaning project...
flutter clean

echo.
echo Step 2: Getting dependencies...
flutter pub get

echo.
echo Step 3: Building Android app (this generates keystore)...
echo This will take 2-3 minutes...
echo.
flutter build apk --debug

echo.
echo Step 4: Getting SHA keys...
echo.

set KEYSTORE=%USERPROFILE%\.android\debug.keystore

if exist "%KEYSTORE%" (
    echo ✅ SUCCESS! Found keystore at: %KEYSTORE%
    echo.
    echo Your SHA Keys:
    echo ========================================
    keytool -list -v -alias androiddebugkey -keystore "%KEYSTORE%" -storepass android -keypass android | findstr "SHA1 SHA256"
    echo ========================================
    echo.
    echo ✅ COPY THE SHA-1 AND SHA-256 VALUES ABOVE!
    echo.
) else (
    echo ❌ ERROR: Keystore not found!
    echo.
    echo Please make sure:
    echo 1. Java is installed
    echo 2. Build completed successfully
    echo.
)

echo.
echo ========================================
echo   NEXT STEPS:
echo ========================================
echo.
echo 1. Copy SHA-1 from above
echo 2. Go to: https://console.firebase.google.com/
echo 3. Select: fir-tutorial-826a8
echo 4. Settings → Project settings → Your apps
echo 5. Click "Add fingerprint" → Paste SHA-1 → Save
echo 6. Click "Add fingerprint" → Paste SHA-256 → Save
echo.
echo 7. Go to: https://console.cloud.google.com/
echo 8. Select: fir-tutorial-826a8  
echo 9. APIs ^& Services → Credentials
echo 10. Create Credentials → OAuth client ID → Android
echo 11. Package name: com.example.cgc
echo 12. SHA-1: Paste the SHA-1 from above
echo 13. Create
echo.
echo 14. Back to Firebase → Download google-services.json
echo 15. Replace: android/app/google-services.json
echo.
echo 16. Run: flutter run
echo.
echo Google Sign-In will work! 🎉
echo.
pause
