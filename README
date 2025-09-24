# Mooja Mobile

## Overview
Flutter mobile application for the Mooja protest coordination platform. Provides a login-free public feed for discovering verified protests and a comprehensive dashboard for verified organizations to manage their events and activities.

## Features
- **Public Protest Feed**: Browse verified protests without account creation
- **Country-based Filtering**: Location-relevant event discovery
- **Organization Verification Flow**: Social media-based verification system
- **Organization Dashboard**: Event management interface for verified organizations
- **Cross-platform Support**: iOS and Android compatibility

## Tech Stack
- **Framework**: Flutter
- **Language**: Dart
- **State Management**: BloC
- **HTTP Client**: DIO
- **Local Storage**: flutter_secure_storage
- **Routing**: Go_router

## Getting Started

### Prerequisites
- Flutter SDK (version 3.24.0 or higher)
- Dart SDK (version 3.8.0 or higher)
- Android Studio / Xcode for device testing
- Device/Emulator for testing

### Installation
```bash
# Clone the repository
git https://github.com/MoojaLabs/mooja-mobile.git
cd mooja-mobile

# Install dependencies
flutter pub get

# Run the app
flutter run
```

### Environment Variables
Create a `.env` file in the root directory:
```
API_BASE_URL=[your-api-url]/api
```

For development, this is currently set to a Railway deployment.

### Running the App
```bash
# Debug mode
flutter run

# Release mode
flutter run --release

# Specific platform
flutter run -d android
flutter run -d ios
```

## Live Demo
A live version of the app is available for testing at: https://appetize.io/app/b_p3fheprhq3wq6cmkjraieoioia

## Project Structure
```
lib/
├── main.dart                         # App entry point
├── core/                             # Shared functionality
│   ├── constants/                    # App constants
│   ├── di/                           # Dependency injection
│   ├── domain/                       # Domain layer & validation
│   ├── models/                       # Data models
│   ├── navigation/                   # Navigation utilities
│   ├── router/                       # App routing (GoRouter)
│   ├── services/                     # Core services (API, Auth, Storage)
│   ├── state/                        # Global state management
│   ├── themes/                       # Design system
│   └── widgets/                      # Reusable UI components
└── features/                         # Feature modules
    ├── auth/                         # Authentication flow
    ├── home/                         # Feed & protests
    ├── intro/                        # Onboarding
```

## Available Scripts
```bash
# Run tests
flutter test

# Build for production
flutter build apk          # Android
flutter build ios          # iOS

# Analyze code
flutter analyze

# Format code
dart format lib/
```

## API Integration
The app communicates with the Mooja server through RESTful APIs:
- Base URL configured via `API_BASE_URL` environment variable
- Authentication handling for organization accounts
- Real-time data fetching for protest feeds

## Contributing

### Code Style
- Follow Flutter/Dart conventions
- Use meaningful variable and function names
- Comment complex logic
- Maintain consistent formatting with `dart format`

### Pull Request Process
1. Fork the repository
2. Create a feature branch
3. Make your changes with appropriate tests
4. Ensure all tests pass
5. Submit a pull request with detailed description

## Deployment
- **Development**: Appetize.io for demo purposes
- **Production**: [App Store/Google Play deployment process to be documented]

## License
This project is licensed under the GNU Affero General Public License v3.0 (AGPL-3.0).