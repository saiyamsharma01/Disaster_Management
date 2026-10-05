#!/usr/bin/env pwsh
# Get SHA Keys for Firebase Google Sign-In Setup
# Run this script in PowerShell from your project root

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Firebase SHA Key Extractor" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Method 1: Try to get SHA from existing debug keystore
Write-Host "Method 1: Checking for existing debug keystore..." -ForegroundColor Yellow
$debugKeystore = "$env:USERPROFILE\.android\debug.keystore"

if (Test-Path $debugKeystore) {
    Write-Host "✅ Debug keystore found!" -ForegroundColor Green
    Write-Host "Location: $debugKeystore" -ForegroundColor Gray
    Write-Host ""
    Write-Host "Getting SHA keys..." -ForegroundColor Yellow
    Write-Host ""
    
    keytool -list -v -alias androiddebugkey -keystore $debugKeystore -storepass android -keypass android 2>&1 | Select-String -Pattern "SHA1:|SHA256:"
    
    Write-Host ""
    Write-Host "✅ Copy the SHA1 value above and add it to Firebase Console!" -ForegroundColor Green
} else {
    Write-Host "❌ Debug keystore not found at: $debugKeystore" -ForegroundColor Red
    Write-Host ""
    Write-Host "Method 2: Using Gradle to get SHA keys..." -ForegroundColor Yellow
    Write-Host ""
    
    # Check if we're in the right directory
    if (Test-Path "android\gradlew.bat") {
        Write-Host "Running Gradle signing report..." -ForegroundColor Yellow
        Write-Host ""
        
        Set-Location android
        .\gradlew.bat signingReport
        Set-Location ..
        
        Write-Host ""
        Write-Host "✅ Look for 'SHA1:' and 'SHA-256:' in the output above!" -ForegroundColor Green
    } else {
        Write-Host "❌ Error: Not in Flutter project root directory" -ForegroundColor Red
        Write-Host "Please run this script from your project root (where pubspec.yaml is)" -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Next Steps:" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "1. Copy your SHA-1 fingerprint from above" -ForegroundColor White
Write-Host "2. Go to https://console.firebase.google.com/" -ForegroundColor White
Write-Host "3. Select project: fir-tutorial-826a8" -ForegroundColor White
Write-Host "4. Settings → Project settings → Your apps" -ForegroundColor White
Write-Host "5. Click 'Add fingerprint' and paste SHA-1" -ForegroundColor White
Write-Host "6. Click 'Add fingerprint' again and paste SHA-256" -ForegroundColor White
Write-Host "7. Download new google-services.json" -ForegroundColor White
Write-Host "8. Replace android/app/google-services.json" -ForegroundColor White
Write-Host ""
Write-Host "Package Name: com.example.cgc" -ForegroundColor Yellow
Write-Host ""
Write-Host "Press any key to exit..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
