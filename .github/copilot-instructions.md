<!-- Use this file to provide workspace-specific custom instructions to Copilot. For more details, visit https://code.visualstudio.com/docs/copilot/copilot-customization#_use-a-githubcopilotinstructionsmd-file -->

This project is a Flutter-based RESTful application for family behavior management (Family Rules & Rewards Manager). Please follow Flutter best practices, use RESTful API integration, and Material Design 3 guidelines. Include user management, rules, rewards, and consequence tracking features as described in the project requirements.

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

Use the following guidelines when writing code:

- Use Dart's `async` and `await` for asynchronous operations.
- Implement state management using Provider or Riverpod.
- Use `http` package for RESTful API calls.
- Follow Material Design 3 guidelines for UI components.
- Use `flutter_test` for unit and widget tests.
- Test all features thoroughly, including edge cases.
- Use `flutter_lints` for linting and code quality.
- Use `intl` package for localization.
- Use `shared_preferences` for local storage.
