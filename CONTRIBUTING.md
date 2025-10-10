# Contributing to FloatIT

Thank you for your interest in contributing to FloatIT! This document provides guidelines and best practices for contributing to the project.

## Code of Conduct

- Be respectful and inclusive
- Focus on constructive feedback
- Help maintain a welcoming environment for all contributors

## Development Workflow

### Branching Strategy

- `main` - Production branch (auto-deploys to GitHub Pages)
- `dev` - Development branch for testing features before release
- `feature/*` - Feature branches created from `dev`

### Making Changes

1. **Create a feature branch**
   ```bash
   git checkout dev
   git pull origin dev
   git checkout -b feature/your-feature-name
   ```

2. **Make your changes**
   - Follow the existing code style and structure
   - Keep changes focused and atomic
   - Write clear, descriptive commit messages

3. **Test your changes**
   ```bash
   flutter analyze  # Check for any issues
   flutter run -d chrome  # Test locally
   ```

4. **Commit your changes**
   ```bash
   git add .
   git commit -m "feat: Add your feature description"
   ```

5. **Push and create a pull request**
   ```bash
   git push origin feature/your-feature-name
   ```
   - Open a PR targeting the `dev` branch
   - Provide a clear description of your changes
   - Reference any related issues

6. **Code review**
   - Address any feedback from reviewers
   - Make requested changes in new commits
   - Once approved, your PR will be merged to `dev`

7. **Release**
   - Tested features in `dev` are periodically merged to `main`
   - Merging to `main` triggers automatic deployment

## Code Guidelines

### Flutter/Dart Style

- Follow the [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style)
- Run `flutter analyze` before committing
- Use meaningful variable and function names
- Add comments for complex logic

### File Organization

```
lib/src/
├── *_page.dart        # Full-screen pages
├── *_provider.dart    # State management providers
├── *_service.dart     # Business logic services
└── widgets/           # Reusable UI components
    └── *_widget.dart
```

### Import Organization

```dart
// 1. Flutter/Dart imports
import 'package:flutter/material.dart';

// 2. Package imports
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

// 3. Local imports
import 'package:floatit/src/widgets/your_widget.dart';
import 'user_service.dart';
```

### State Management

- Use `Provider` for app-wide state
- Keep providers focused on a single responsibility
- Call `notifyListeners()` after state changes

### Firebase Best Practices

- Always use security rules to validate data
- Use transactions for atomic operations
- Minimize read/write operations (stay in free tier)
- Handle offline scenarios gracefully

## Testing

### Manual Testing Checklist

Before submitting a PR, test:

- [ ] Authentication flow (login/logout)
- [ ] Event creation and joining
- [ ] Profile updates
- [ ] Admin features (if applicable)
- [ ] Mobile responsiveness
- [ ] Rate limiting works as expected

### Automated Testing

- Unit tests: `flutter test`
- Widget tests: `flutter test`
- (Integration tests are currently not configured)

## Commit Message Format

Use conventional commits format:

```
<type>(<scope>): <subject>

<body>

<footer>
```

### Types

- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting, etc.)
- `refactor`: Code refactoring without feature changes
- `perf`: Performance improvements
- `test`: Adding or updating tests
- `chore`: Build process or auxiliary tool changes

### Examples

```
feat(events): Add waiting list functionality

- Users can join waiting list when event is full
- Automatically promote from waiting list when space opens
- Show waiting list position to users

Closes #123
```

```
fix(auth): Extract first name from Microsoft account on login

- Now correctly extracts first name from displayName
- Falls back to "User" if name unavailable
- Updates placeholder names on subsequent logins
```

## Security Guidelines

- **Never commit secrets or API keys**
- **Never hardcode credentials**
- Use Firebase security rules for all data validation
- Validate user input on both client and server side
- Keep dependencies up to date

## Getting Help

- Check existing issues and PRs first
- Ask questions in issue comments or discussions
- Tag maintainers for urgent matters
- Be patient - maintainers are volunteers

## License

By contributing, you agree that your contributions will be licensed under the same license as the project.

## Recognition

Contributors will be recognized in release notes and the project README. Thank you for helping make FloatIT better!
