import 'package:flutter_test/flutter_test.dart';
import 'package:vantag/models/pursuit.dart';

void main() {
  group('Pursuit', () {
    group('progressPercent', () {
      test('calculates 50% progress correctly', () {
        // Arrange
        final pursuit = Pursuit(
          id: 'test-1',
          name: 'iPhone',
          targetAmount: 10000,
          currency: 'TRY',
          savedAmount: 5000,
          emoji: '📱',
          category: PursuitCategory.tech,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // Act & Assert
        expect(pursuit.progressPercent, 0.5);
        expect(pursuit.progressPercentDisplay, 50);
      });

      test('returns 0 when no savings', () {
        // Arrange
        final pursuit = Pursuit(
          id: 'test-2',
          name: 'Travel',
          targetAmount: 5000,
          currency: 'TRY',
          savedAmount: 0,
          emoji: '✈️',
          category: PursuitCategory.travel,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // Act & Assert
        expect(pursuit.progressPercent, 0.0);
        expect(pursuit.progressPercentDisplay, 0);
      });

      test('clamps to 1.0 when savings exceed target', () {
        // Arrange: Saved more than target
        final pursuit = Pursuit(
          id: 'test-3',
          name: 'Watch',
          targetAmount: 1000,
          currency: 'TRY',
          savedAmount: 1500, // 150% saved
          emoji: '⌚',
          category: PursuitCategory.fashion,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // Act & Assert: Should be clamped to 1.0 (100%)
        expect(pursuit.progressPercent, 1.0);
        expect(pursuit.progressPercentDisplay, 100);
      });

      test('returns 0 when target amount is 0', () {
        // Arrange: Edge case - zero target
        final pursuit = Pursuit(
          id: 'test-4',
          name: 'Zero Target',
          targetAmount: 0,
          currency: 'TRY',
          savedAmount: 100,
          emoji: '📦',
          category: PursuitCategory.other,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // Act & Assert
        expect(pursuit.progressPercent, 0.0);
      });
    });

    group('remainingAmount', () {
      test('calculates remaining amount correctly', () {
        // Arrange
        final pursuit = Pursuit(
          id: 'test-5',
          name: 'Car',
          targetAmount: 500000,
          currency: 'TRY',
          savedAmount: 150000,
          emoji: '🚗',
          category: PursuitCategory.vehicle,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // Act & Assert
        expect(pursuit.remainingAmount, 350000);
      });

      test('returns 0 when target is reached', () {
        // Arrange
        final pursuit = Pursuit(
          id: 'test-6',
          name: 'Laptop',
          targetAmount: 30000,
          currency: 'TRY',
          savedAmount: 30000,
          emoji: '💻',
          category: PursuitCategory.tech,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // Act & Assert
        expect(pursuit.remainingAmount, 0);
      });

      test('returns 0 when savings exceed target (clamp)', () {
        // Arrange: Over-saved
        final pursuit = Pursuit(
          id: 'test-7',
          name: 'Camera',
          targetAmount: 20000,
          currency: 'TRY',
          savedAmount: 25000,
          emoji: '📷',
          category: PursuitCategory.tech,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // Act & Assert: Remaining should be 0, not negative
        expect(pursuit.remainingAmount, 0);
      });
    });

    group('hasReachedTarget', () {
      test('returns true when saved equals target', () {
        // Arrange
        final pursuit = Pursuit(
          id: 'test-8',
          name: 'Course',
          targetAmount: 5000,
          currency: 'TRY',
          savedAmount: 5000,
          emoji: '📚',
          category: PursuitCategory.education,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // Act & Assert
        expect(pursuit.hasReachedTarget, true);
      });

      test('returns true when saved exceeds target', () {
        // Arrange
        final pursuit = Pursuit(
          id: 'test-9',
          name: 'Gym Membership',
          targetAmount: 3000,
          currency: 'TRY',
          savedAmount: 3500,
          emoji: '💪',
          category: PursuitCategory.health,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // Act & Assert
        expect(pursuit.hasReachedTarget, true);
      });

      test('returns false when target not reached', () {
        // Arrange
        final pursuit = Pursuit(
          id: 'test-10',
          name: 'Furniture',
          targetAmount: 50000,
          currency: 'TRY',
          savedAmount: 25000,
          emoji: '🛋️',
          category: PursuitCategory.home,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // Act & Assert
        expect(pursuit.hasReachedTarget, false);
      });
    });

    group('isCompleted', () {
      test('returns true when completedAt is set', () {
        // Arrange
        final pursuit = Pursuit(
          id: 'test-11',
          name: 'Completed Pursuit',
          targetAmount: 10000,
          currency: 'TRY',
          savedAmount: 10000,
          emoji: '✅',
          category: PursuitCategory.other,
          createdAt: DateTime.now().subtract(const Duration(days: 30)),
          updatedAt: DateTime.now(),
          completedAt: DateTime.now(),
        );

        // Act & Assert
        expect(pursuit.isCompleted, true);
      });

      test('returns false when completedAt is null', () {
        // Arrange
        final pursuit = Pursuit(
          id: 'test-12',
          name: 'Ongoing Pursuit',
          targetAmount: 10000,
          currency: 'TRY',
          savedAmount: 5000,
          emoji: '⏳',
          category: PursuitCategory.other,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          completedAt: null,
        );

        // Act & Assert
        expect(pursuit.isCompleted, false);
      });
    });

    group('PursuitCategory', () {
      test('emoji returns correct values', () {
        expect(PursuitCategory.tech.emoji, '📱');
        expect(PursuitCategory.travel.emoji, '✈️');
        expect(PursuitCategory.home.emoji, '🏠');
        expect(PursuitCategory.fashion.emoji, '👗');
        expect(PursuitCategory.vehicle.emoji, '🚗');
        expect(PursuitCategory.education.emoji, '📚');
        expect(PursuitCategory.health.emoji, '💊');
        expect(PursuitCategory.other.emoji, '📦');
      });

      test('labelTr returns Turkish labels', () {
        expect(PursuitCategory.tech.labelTr, 'Teknoloji');
        expect(PursuitCategory.travel.labelTr, 'Seyahat');
        expect(PursuitCategory.education.labelTr, 'Eğitim');
      });

      test('labelEn returns English labels', () {
        expect(PursuitCategory.tech.labelEn, 'Tech');
        expect(PursuitCategory.travel.labelEn, 'Travel');
        expect(PursuitCategory.education.labelEn, 'Education');
      });
    });

    group('JSON serialization', () {
      test('toJson and fromJson roundtrip works correctly', () {
        // Arrange
        final original = Pursuit(
          id: 'json-test-1',
          name: 'Test Pursuit',
          targetAmount: 15000,
          currency: 'USD',
          savedAmount: 7500,
          emoji: '🎯',
          category: PursuitCategory.tech,
          createdAt: DateTime(2024, 1, 15),
          updatedAt: DateTime(2024, 1, 20),
          isArchived: false,
          sortOrder: 100,
        );

        // Act
        final json = original.toJson();
        final restored = Pursuit.fromJson(json);

        // Assert
        expect(restored.id, original.id);
        expect(restored.name, original.name);
        expect(restored.targetAmount, original.targetAmount);
        expect(restored.currency, original.currency);
        expect(restored.savedAmount, original.savedAmount);
        expect(restored.emoji, original.emoji);
        expect(restored.category, original.category);
        expect(restored.isArchived, original.isArchived);
        expect(restored.sortOrder, original.sortOrder);
      });

      test('encodeList and decodeList work correctly', () {
        // Arrange
        final pursuits = [
          Pursuit(
            id: 'list-1',
            name: 'First',
            targetAmount: 1000,
            currency: 'TRY',
            emoji: '1️⃣',
            category: PursuitCategory.other,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
          Pursuit(
            id: 'list-2',
            name: 'Second',
            targetAmount: 2000,
            currency: 'TRY',
            emoji: '2️⃣',
            category: PursuitCategory.other,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        ];

        // Act
        final encoded = Pursuit.encodeList(pursuits);
        final decoded = Pursuit.decodeList(encoded);

        // Assert
        expect(decoded.length, 2);
        expect(decoded[0].id, 'list-1');
        expect(decoded[1].id, 'list-2');
      });
    });
  });
}
