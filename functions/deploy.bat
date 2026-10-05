@echo off
echo 🚀 Deploying Flood Alert Cloud Functions...

echo 📦 Installing dependencies...
npm install

echo 🔨 Building TypeScript...
npm run build

echo ☁️ Deploying to Firebase...
firebase deploy --only functions

echo ✅ Deployment complete!
echo.
echo 📋 Available endpoints:
echo   - storeFCMToken: Store FCM token for notifications
echo   - createFloodAlert: Create and send flood alert
echo   - sendEvacuationAlert: Send evacuation alert
echo   - sendWeatherWarning: Send weather warning
echo   - getFloodAlerts: Get active flood alerts
echo.
echo 🔧 Don't forget to:
echo   1. Update the _baseUrl in lib/services/flood_alert_api_service.dart
echo   2. Replace 'your-project-id' with your actual Firebase project ID
echo   3. Test the endpoints with your FCM token: BItyI84YBWgMtjlgGodn0aWjTc4z3Un-XjoPTp6_dQbTvBKyhNGPkyEJaPGEKC5FKdVrqGbkJXItO8zbAYu5Azc

pause
