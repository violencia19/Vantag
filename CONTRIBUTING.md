# Contributing to Vantag

Thank you for your interest in contributing to Vantag! This document provides guidelines and standards for contributing to the project.

## Code Standards

### Dart Style Guide
- Follow the official [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style)
- Use `dart format` before committing
- Run `flutter analyze` and fix all issues

### Naming Conventions
```dart
// Classes - PascalCase
class ExpenseService {}

// Files - snake_case
expense_service.dart

// Variables/Functions - camelCase
final totalExpenses = 0;
void calculateTotal() {}

// Constants - camelCase or SCREAMING_CAPS for truly constant values
const maxRetries = 3;
const API_BASE_URL = 'https://api.example.com';

// Private members - prefixed with underscore
final _privateField = '';
void _privateMethod() {}
```

### File Organization
```dart
// 1. Imports (sorted)
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/services.dart';

// 2. Part directives (if any)

// 3. Constants

// 4. Class definition
class MyWidget extends StatelessWidget {
  // 4a. Static fields
  // 4b. Instance fields
  // 4c. Constructors
  // 4d. Lifecycle methods
  // 4e. Build method
  // 4f. Private methods
}
```

### Widget Guidelines
- Prefer `const` constructors when possible
- Extract large widget trees into separate widgets
- Use `StatelessWidget` unless state is needed
- Add `Semantics` for accessibility

```dart
// Good
const MyWidget({super.key});

// Use const for static children
child: const Text('Hello'),

// Add semantics
Semantics(
  label: 'Close button',
  child: IconButton(...),
)
```

## Branch Naming

```
feature/description    # New features
fix/description        # Bug fixes
refactor/description   # Code refactoring
docs/description       # Documentation
test/description       # Tests
```

Examples:
- `feature/add-voice-input`
- `fix/currency-conversion-bug`
- `refactor/expense-service`
- `docs/api-documentation`

## Commit Messages

Follow [Conventional Commits](https://www.conventionalcommits.org/):

```
type(scope): description

[optional body]

[optional footer]
```

Types:
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation
- `style`: Formatting (no code change)
- `refactor`: Code restructuring
- `test`: Adding tests
- `chore`: Maintenance tasks

Examples:
```
feat(expense): add voice input for expense entry
fix(currency): correct TRY to USD conversion rate
docs(readme): update installation instructions
refactor(ai): extract tool handler to separate service
```

## Pull Request Process

### Before Creating PR
1. Run tests: `flutter test`
2. Run analyzer: `flutter analyze`
3. Format code: `dart format .`
4. Update documentation if needed

### PR Template
```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update

## Testing
- [ ] Unit tests added/updated
- [ ] Widget tests added/updated
- [ ] Manual testing completed

## Screenshots (if applicable)
Add screenshots for UI changes

## Checklist
- [ ] Code follows style guidelines
- [ ] Self-review completed
- [ ] Documentation updated
- [ ] No new warnings
```

### Review Process
1. At least one approval required
2. All CI checks must pass
3. No merge conflicts
4. Squash commits on merge

## Testing Requirements

### Unit Tests
```dart
// test/services/expense_service_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:vantag/services/expense_service.dart';

void main() {
  group('ExpenseService', () {
    late ExpenseService service;

    setUp(() {
      service = ExpenseService();
    });

    test('should calculate total correctly', () {
      final total = service.calculateTotal([100, 200, 300]);
      expect(total, equals(600));
    });
  });
}
```

### Widget Tests
```dart
// test/widgets/expense_card_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vantag/widgets/expense_card.dart';

void main() {
  testWidgets('ExpenseCard displays amount', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ExpenseCard(amount: 100),
      ),
    );

    expect(find.text('100'), findsOneWidget);
  });
}
```

## Localization

### Adding New Strings
1. Add to `lib/l10n/app_en.arb`:
```json
"newFeature": "New Feature",
"@newFeature": {
  "description": "Label for new feature"
}
```

2. Add Turkish translation in `lib/l10n/app_tr.arb`:
```json
"newFeature": "Yeni Ozellik"
```

3. Run `flutter gen-l10n`

4. Use in code:
```dart
final l10n = AppLocalizations.of(context);
Text(l10n.newFeature);
```

## Security

- Never commit API keys or secrets
- Use `.env` for sensitive configuration
- Use `SecurityUtils` for input validation
- Report security issues privately

## Getting Help

- Check existing issues first
- Use issue templates
- Join team discussions
- Ask in code review comments

## Code of Conduct

- Be respectful and inclusive
- Focus on constructive feedback
- Help others learn and grow
- Report inappropriate behavior
