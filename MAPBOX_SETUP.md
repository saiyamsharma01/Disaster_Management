# Mapbox Maps Integration Guide

This project now uses Mapbox Maps SDK for Flutter to display interactive maps across all pages.

## Setup Complete ✅

The following has been configured:

1. **Dependency Added**: `mapbox_maps_flutter: ^2.0.0` in `pubspec.yaml`
2. **Access Token Configuration**: Set up in `.vscode/launch.json`
3. **Mapbox Initialization**: Configured in `lib/main.dart`
4. **Reusable Widget**: Created `lib/widgets/mapbox_widget.dart`
5. **Page Updates**: All map-using pages now use Mapbox

## Running the Application

### Option 1: Using VS Code

Simply press `F5` or click the "Run and Debug" button. The access token is automatically passed via
the launch configuration.

### Option 2: Command Line

Run the app with the `--dart-define` flag:

```bash
flutter run --dart-define ACCESS_TOKEN=YOUR_MAPBOX_ACCESS_TOKEN
```

### Option 3: Building for Release

When building for release, include the access token:

```bash
flutter build apk --dart-define ACCESS_TOKEN=YOUR_MAPBOX_ACCESS_TOKEN
```

## Updated Pages

The following pages now use Mapbox instead of flutter_map:

1. **Nearby Shelter Page** (`lib/pages/nearby_shelter_page.dart`)
    - Displays multiple shelter locations with markers
    - Interactive zoom controls
    - Custom marker icons

2. **Report Map Page** (`lib/pages/report_map_page.dart`)
    - Shows different types of reports (emergency, food/shelter, volunteer)
    - Colored markers based on report type
    - Info panel with report statistics

3. **IVR Outcome Page** (`lib/pages/ivr_outcome_page.dart`)
    - Displays crisis response locations
    - Multiple marker types for different needs
    - Interactive spot listing

4. **SOS Page** (`lib/pages/sos_page.dart`)
    - Real-time SOS alert visualization
    - Hotspot detection with circle overlays
    - Live Firestore integration
    - Circle annotations for danger zones

## Reusable Mapbox Widget

Use the `ReusableMapboxWidget` for new map implementations:

```dart
import 'package:sahaaya/widgets/mapbox_widget.dart';

ReusableMapboxWidget(
  latitude: 31.6340,
  longitude: 74.8723,
  zoom: 13.0,
  markers: [
    MapMarker(
      latitude: 31.6375,
      longitude: 74.8752,
      iconImage: "marker",
      iconSize: 1.5,
      color: Colors.red,
      title: "Location Title",
      description: "Location Description",
    ),
  ],
  showUserLocation: true,
  onMapCreated: (mapboxMap) {
    // Handle map creation
  },
  onMapTap: (position) {
    // Handle map tap
  },
)
```

## Features

- ✅ Interactive maps with smooth animations
- ✅ Custom markers and annotations
- ✅ Circle overlays for zones
- ✅ Zoom controls
- ✅ Location tracking
- ✅ Responsive design (narrow/wide layouts)
- ✅ Real-time data integration with Firestore

## Mapbox Styles

The maps use the default Mapbox Streets style. To customize:

```dart
MapWidget(
  styleUri: MapboxStyles.SATELLITE, // or DARK, LIGHT, OUTDOORS, etc.
  cameraOptions: CameraOptions(...),
)
```

## Advanced Features

### Adding Custom Markers

```dart
final pointAnnotationManager = await mapboxMap.annotations.createPointAnnotationManager();

final pointAnnotationOptions = PointAnnotationOptions(
  geometry: Point(coordinates: Position(longitude, latitude)),
  iconImage: "custom-icon",
  iconSize: 1.5,
  iconColor: Colors.blue.value,
);

await pointAnnotationManager.create(pointAnnotationOptions);
```

### Adding Circle Overlays

```dart
final circleAnnotationManager = await mapboxMap.annotations.createCircleAnnotationManager();

final circleOptions = CircleAnnotationOptions(
  geometry: Point(coordinates: Position(longitude, latitude)),
  circleRadius: 100.0,
  circleColor: Colors.red.withOpacity(0.3).value,
  circleStrokeColor: Colors.red.value,
  circleStrokeWidth: 2.0,
);

await circleAnnotationManager.create(circleOptions);
```

### Camera Animation

```dart
await mapboxMap.flyTo(
  CameraOptions(
    center: Point(coordinates: Position(longitude, latitude)),
    zoom: 15,
    bearing: 0,
    pitch: 0,
  ),
  MapAnimationOptions(duration: 1000, startDelay: 0),
);
```

## Troubleshooting

### Issue: Map not showing

- Ensure the access token is being passed correctly
- Check that `MapboxOptions.setAccessToken()` is called in `main.dart`
- Verify internet connection (maps require network access)

### Issue: Markers not appearing

- Ensure marker coordinates are valid (lat/lng)
- Check that `createPointAnnotationManager()` is called after map creation
- Verify `iconImage` is a valid Mapbox icon name

### Issue: Build errors

Run `flutter clean` and `flutter pub get` to refresh dependencies.

## Security Note

🔒 The access token in `.vscode/launch.json` is for development only. For production:

1. Store tokens in environment variables
2. Use different tokens for different environments
3. Set up token restrictions in your Mapbox account
4. Never commit sensitive tokens to version control

## Additional Resources

- [Mapbox Maps SDK for Flutter Documentation](https://docs.mapbox.com/android/maps/guides/)
- [Mapbox Studio](https://studio.mapbox.com/) - Create custom map styles
- [Mapbox API Documentation](https://docs.mapbox.com/api/)

## Support

For issues specific to this implementation, refer to the original Mapbox documentation or the code
comments in the widget files.
