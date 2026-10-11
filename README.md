# WeatherApp

A Flutter weather app — current conditions and forecast by city or device location,
targeting all six Flutter platforms.

## Features

- Current conditions by city name or GPS location
- Multi-day forecast
- Last-used location remembered via `shared_preferences`
- Builds for **Android, iOS, web, macOS, Windows and Linux**

Data from the [OpenWeatherMap](https://openweathermap.org) API.

## Setup

**Prerequisites:** Flutter SDK, and a free
[OpenWeatherMap API key](https://home.openweathermap.org/api_keys).

The key is supplied at build time and **is not stored in the repository**:

```bash
git clone https://github.com/Zephyr4772/WeatherApp.git
cd WeatherApp
flutter pub get
flutter run --dart-define=OWM_API_KEY=your_key_here
```

Building a release:

```bash
flutter build apk --dart-define=OWM_API_KEY=your_key_here
```

Without `OWM_API_KEY`, requests to OpenWeatherMap will fail.

> **Note on client-side keys:** in any shipped mobile or web build the key is
> recoverable from the bundle. For a published app, proxy the API through a backend
> and keep the key server-side.

## Layout

```
lib/
  screens/weather_screen.dart   main UI
  services/
    weather_service.dart        OpenWeatherMap client
    weather_provider.dart       ChangeNotifier state, geolocation
  models/weather_model.dart
```

State is managed with `ChangeNotifier` / `provider`; location via `geolocator`.

## Limitations

- Needs location permission for GPS mode; city search works without it.
- No offline cache — a connection is required.
- No tests.
