#!/usr/bin/env pwsh
# Setup App Icon and Build APK Script

Write-Host "================================" -ForegroundColor Cyan
Write-Host "SAHAAYA App Icon Setup & Build" -ForegroundColor Cyan
Write-Host "================================" -ForegroundColor Cyan
Write-Host ""

# Check if logo exists
$logoPath = "assets/images/sahaaya_logo.png"

if (-Not (Test-Path $logoPath)) {
    Write-Host "❌ Logo file not found at: $logoPath" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please save your SAHAAYA logo PNG image to:" -ForegroundColor Yellow
    Write-Host "  $logoPath" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Instructions:" -ForegroundColor Cyan
    Write-Host "1. Right-click the logo image from your chat/download" -ForegroundColor White
    Write-Host "2. Save it as 'sahaaya_logo.png'" -ForegroundColor White
    Write-Host "3. Place it in the 'assets/images/' folder" -ForegroundColor White
    Write-Host "4. Run this script again" -ForegroundColor White
    Write-Host ""
    Write-Host "Press any key to exit..."
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit 1
}

Write-Host "✅ Logo file found!" -ForegroundColor Green
Write-Host ""

# Generate app icons
Write-Host "📱 Generating app icons..." -ForegroundColor Cyan
flutter pub run flutter_launcher_icons

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Failed to generate icons" -ForegroundColor Red
    exit 1
}

Write-Host "✅ Icons generated successfully!" -ForegroundColor Green
Write-Host ""

# Ask user what to build
Write-Host "What would you like to build?" -ForegroundColor Cyan
Write-Host "1. APK (for direct installation)" -ForegroundColor White
Write-Host "2. App Bundle (for Google Play Store)" -ForegroundColor White
Write-Host "3. Both" -ForegroundColor White
Write-Host ""
$choice = Read-Host "Enter your choice (1/2/3)"

Write-Host ""

if ($choice -eq "1" -or $choice -eq "3") {
    Write-Host "🔨 Building APK..." -ForegroundColor Cyan
    flutter build apk --release
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ APK built successfully!" -ForegroundColor Green
        Write-Host "📦 Location: build/app/outputs/flutter-apk/app-release.apk" -ForegroundColor Yellow
        Write-Host ""
    } else {
        Write-Host "❌ APK build failed" -ForegroundColor Red
        exit 1
    }
}

if ($choice -eq "2" -or $choice -eq "3") {
    Write-Host "🔨 Building App Bundle..." -ForegroundColor Cyan
    flutter build appbundle --release
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ App Bundle built successfully!" -ForegroundColor Green
        Write-Host "📦 Location: build/app/outputs/bundle/release/app-release.aab" -ForegroundColor Yellow
        Write-Host ""
    } else {
        Write-Host "❌ App Bundle build failed" -ForegroundColor Red
        exit 1
    }
}

Write-Host ""
Write-Host "================================" -ForegroundColor Cyan
Write-Host "✅ All tasks completed!" -ForegroundColor Green
Write-Host "================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Your SAHAAYA app is ready!" -ForegroundColor Green
Write-Host ""
