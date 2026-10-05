@echo off
REM Get SHA Keys for Firebase Google Sign-In Setup

echo ========================================
echo   Firebase SHA Key Extractor
echo ========================================
echo.

echo Checking for Gradle wrapper...
echo.

if exist "android\gradlew.bat" (
    echo Found gradlew.bat, getting SHA keys...
    echo.
    cd android
    call gradlew.bat signingReport
    cd ..
) else if exist "android\gradle\wrapper\gradle-wrapper.jar" (
    echo Using gradle command directly...
    echo.
    cd android
    gradle signingReport
    cd ..
) else (
    echo Gradle wrapper not found!
    echo.
    echo Trying alternative method with keytool...
    echo.
    
    REM Try to find and use keytool directly
    set KEYSTORE_PATH=%USERPROFILE%\.android\debug.keystore
    
    if exist "%KEYSTORE_PATH%" (
        echo Found debug keystore at: %KEYSTORE_PATH%
        echo.
        keytool -list -v -alias androiddebugkey -keystore "%KEYSTORE_PATH%" -storepass android -keypass android 2>&1 | findstr "SHA1 SHA256"
    ) else (
        echo Debug keystore not found!
        echo.
        echo SOLUTION: Run your Flutter app once to generate the keystore:
        echo   flutter run
        echo.
        echo Then run this script again.
    )
)

echo.
echo ========================================
echo   COPY THE SHA VALUES ABOVE!
echo ========================================
echo.
echo Look for lines like:
echo   SHA1: XX:XX:XX:XX:XX:XX...
echo   SHA-256: XX:XX:XX:XX:XX:XX...
echo.
echo ========================================
echo   Next Steps:
echo ========================================
echo 1. Copy your SHA-1 fingerprint from above
echo 2. Go to: https://console.firebase.google.com/
echo 3. Select project: fir-tutorial-826a8
echo 4. Settings - Project settings - Your apps
echo 5. Click 'Add fingerprint' and paste SHA-1
echo 6. Click 'Add fingerprint' again and paste SHA-256
echo 7. Download new google-services.json
echo 8. Replace android/app/google-services.json
echo.
echo Package Name: com.example.cgc
echo.
pause
