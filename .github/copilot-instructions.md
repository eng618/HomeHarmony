<!-- Use this file to provide workspace-specific custom instructions to Copilot. For more details, visit https://code.visualstudio.com/docs/copilot/copilot-customization#_use-a-githubcopilotinstructionsmd-file -->

# Home Harmony Copilot Instructions

## Overview

This file provides specific instructions for GitHub Copilot to assist in developing the Home Harmony project, a Flutter application designed for family behavior management. The instructions include project structure, coding standards, and guidelines for implementing features and testing.

This project is a Flutter-based RESTful application for family behavior management (Family Rules & Rewards Manager). Please follow Flutter best practices, use RESTful API integration, and Material Design 3 guidelines. Include user management, rules, rewards, and consequence tracking features as described in the project requirements.

## Project Structure

Always setup code and project structure as follows:

```plaintext
lib/
  ├── main.dart
  ├── models/
  ├── services/
  ├── views/
  ├── widgets/
  └── utils/
```

## Coding Standards

Use the following guidelines when writing code:

- Document all public classes, methods, and properties using Dart's documentation comments.
- Use Dart's `async` and `await` for asynchronous operations.
- Implement state management using Riverpod.
- Use `http` package for RESTful API calls.
- Follow Material Design 3 guidelines for UI components.
- Use `flutter_lints` for linting and code quality.
- Use `intl` package for localization.
- Use `shared_preferences` for local storage.
- Don't use 'BuildContext's across async gaps
- Use lib/utils/logger for structured logging thoughout the application.

Always ensure the README.md file is updated with the latest project information, including features, setup instructions, and customization options.
Make sure to include the following sections in the README.md:

- Project title and description
- Architecture overview
  - Diagrams using Mermaid syntax
- Features list
- Getting started instructions
- Project structure overview
- Customization instructions
- License information
- Contribution guidelines
- Contact information for the project maintainers
- Acknowledgments or credits for any third-party libraries or resources used
- Changelog for tracking changes and updates

## Firebase Integration

If Firebase is used in the project, ensure to follow these guidelines:

- Use `firebase_core` for initializing Firebase.
- Use `cloud_firestore` for Firestore database operations.
- Use `firebase_auth` for user authentication.
- Use `firebase_messaging` for push notifications.
- Use `firebase_analytics` for analytics tracking.
- Ensure to configure Firebase in the `android/app/google-services.json` and `ios/Runner/GoogleService-Info.plist` files.
- Use `firebase_crashlytics` for crash reporting.

## Testing Guidelines

- Use `flutter_test` for unit and widget tests.
- Use fake_cloud_firestore for testing Firestore interactions.
- Test all features thoroughly, including edge cases.
- Create unit tests when adding new code.
- Add or update unit tests when modifying code.
- Write unit tests for all models and services.
- Write widget tests for all views and widgets.
- Use `mockito` for mocking dependencies in tests.
- Ensure all tests pass before committing code.
- Use `flutter test` to run tests locally.
- Use `flutter drive` for integration tests.
- Use `flutter analyze` to check for code quality issues.
- Use `flutter format` to format code according to Dart style guidelines.
- Use `flutter pub get` to install dependencies.
- Use `flutter pub upgrade` to update dependencies to the latest versions.
- Use `flutter pub outdated` to check for outdated dependencies.

## UI/UX Guidelines

- Follow Material Design 3 guidelines for UI components.
- Use consistent spacing and padding throughout the app.
- Ensure all text is legible with appropriate font sizes and colors.
- Use icons from the Material Icons library for consistency.
- Ensure all buttons and interactive elements have appropriate hover and focus states.
- Use animations sparingly to enhance user experience without causing distractions.
- Ensure the app is responsive and works well on different screen sizes and orientations.
- Use a consistent color palette throughout the app to create a cohesive look and feel.
- Ensure accessibility features are implemented, such as screen reader support and high contrast modes.

## Color Palette

- Primary: Forest green (#2A9D8F) for growth and stability.
- Secondary: Soft lavender (#E4C1F9) for creativity and calm.
- Accent: Bright orange (#F48C06) for energy and rewards.
- Neutral: Light gray (#E8ECEF) and deep navy (#264653) for backgrounds and text.
