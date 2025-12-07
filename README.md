# reviews_app

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
# Reviews App

## Overview
The Reviews App is a Flutter application designed to allow users to view, manage, and interact with reviews. The app features a clean and modern interface, supporting both light and dark themes.

## Features
- Home Screen: Displays a list of reviews.
- Details Screen: Provides detailed information about a specific review.
- Settings Screen: Allows users to modify application settings.
- Profile Screen: Enables users to view and edit their profile information.

## Project Structure
```
reviews_app
├── lib
│   ├── app.dart
│   ├── features
│   │   └── review
│   │       └── screens
│   │           ├── home
│   │           │   └── home.dart
│   │           ├── details
│   │           │   └── details_screen.dart
│   │           ├── settings
│   │           │   └── settings_screen.dart
│   │           └── profile
│   │               └── profile_screen.dart
│   ├── utils
│   │   ├── constants
│   │   │   └── text_strings.dart
│   │   └── theme
│   │       └── app_theme.dart
│   └── main.dart
└── README.md
```

## Setup Instructions
1. Clone the repository:
   ```
   git clone <repository-url>
   ```
2. Navigate to the project directory:
   ```
   cd reviews_app
   ```
3. Install the dependencies:
   ```
   flutter pub get
   ```
4. Run the application:
   ```
   flutter run
   ```

## Technologies Used
- Flutter: A UI toolkit for building natively compiled applications for mobile, web, and desktop from a single codebase.
- GetX: A powerful and lightweight solution for state management, dependency injection, and route management in Flutter.

## Contributing
Contributions are welcome! Please open an issue or submit a pull request for any enhancements or bug fixes.