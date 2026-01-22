import 'package:flutter_test/flutter_test.dart';
import 'package:vantag/models/subscription.dart';

void main() {
  group('Subscription', () {
    group('constructor', () {
      test('creates subscription with required parameters', () {
        final subscription = Subscription(
          id: 'sub_1',
          name: 'Netflix',
          amount: 99.99,
          renewalDay: 15,
          category: 'Eğlence',
          createdAt: DateTime(2024, 1, 1),
        );

        expect(subscription.id, 'sub_1');
        expect(subscription.name, 'Netflix');
        expect(subscription.amount, 99.99);
        expect(subscription.renewalDay, 15);
        expect(subscription.category, 'Eğlence');
        expect(subscription.isActive, true);
        expect(subscription.autoRecord, true);
        expect(subscription.colorIndex, 0);
      });

      test('creates subscription with all parameters', () {
        final subscription = Subscription(
          id: 'sub_2',
          name: 'Spotify',
          amount: 59.99,
          renewalDay: 1,
          category: 'Eğlence',
          colorIndex: 2,
          createdAt: DateTime(2024, 1, 1),
          isActive: false,
          autoRecord: false,
          notes: 'Family plan',
        );

        expect(subscription.colorIndex, 2);
        expect(subscription.isActive, false);
        expect(subscription.autoRecord, false);
        expect(subscription.notes, 'Family plan');
      });
    });

    group('color', () {
      test('returns correct color from palette', () {
        final subscription = Subscription(
          id: 'sub_1',
          name: 'Test',
          amount: 100,
          renewalDay: 1,
          category: 'Test',
          colorIndex: 0,
          createdAt: DateTime(2024, 1, 1),
        );

        expect(subscription.color, SubscriptionColors.palette[0]);
      });

      test('handles different color indices', () {
        for (int i = 0; i < SubscriptionColors.count; i++) {
          final subscription = Subscription(
            id: 'sub_$i',
            name: 'Test',
            amount: 100,
            renewalDay: 1,
            category: 'Test',
            colorIndex: i,
            createdAt: DateTime(2024, 1, 1),
          );
          expect(subscription.color, SubscriptionColors.palette[i]);
        }
      });
    });

    group('nextRenewalDate', () {
      test('returns future date when renewal is later this month', () {
        final subscription = Subscription(
          id: 'sub_1',
          name: 'Netflix',
          amount: 100,
          renewalDay: 28,
          category: 'Eğlence',
          createdAt: DateTime(2024, 1, 1),
        );

        final now = DateTime.now();
        final renewal = subscription.nextRenewalDate;

        // Should be on day 28 of current or next month
        expect(renewal.day, lessThanOrEqualTo(28));
        expect(renewal.isAfter(now.subtract(const Duration(days: 1))), true);
      });
    });

    group('getRenewalDayForMonth', () {
      test('clamps day for short months', () {
        final subscription = Subscription(
          id: 'sub_1',
          name: 'Test',
          amount: 100,
          renewalDay: 31,
          category: 'Test',
          createdAt: DateTime(2024, 1, 1),
        );

        // February 2024 has 29 days (leap year)
        expect(subscription.getRenewalDayForMonth(2024, 2), 29);

        // February 2023 has 28 days
        expect(subscription.getRenewalDayForMonth(2023, 2), 28);

        // April has 30 days
        expect(subscription.getRenewalDayForMonth(2024, 4), 30);

        // January has 31 days - no clamping needed
        expect(subscription.getRenewalDayForMonth(2024, 1), 31);
      });
    });

    group('daysUntilRenewal', () {
      test('returns non-negative value', () {
        final subscription = Subscription(
          id: 'sub_1',
          name: 'Test',
          amount: 100,
          renewalDay: 15,
          category: 'Test',
          createdAt: DateTime(2024, 1, 1),
        );

        expect(subscription.daysUntilRenewal, greaterThanOrEqualTo(0));
      });
    });

    group('isRenewalTomorrow', () {
      test('returns boolean', () {
        final subscription = Subscription(
          id: 'sub_1',
          name: 'Test',
          amount: 100,
          renewalDay: 15,
          category: 'Test',
          createdAt: DateTime(2024, 1, 1),
        );

        expect(subscription.isRenewalTomorrow, isA<bool>());
      });
    });

    group('isRenewalToday', () {
      test('returns boolean', () {
        final subscription = Subscription(
          id: 'sub_1',
          name: 'Test',
          amount: 100,
          renewalDay: DateTime.now().day,
          category: 'Test',
          createdAt: DateTime(2024, 1, 1),
        );

        expect(subscription.isRenewalToday, isA<bool>());
      });
    });

    group('daysSinceSubscription', () {
      test('calculates days correctly', () {
        final now = DateTime.now();
        final tenDaysAgo = now.subtract(const Duration(days: 10));

        final subscription = Subscription(
          id: 'sub_1',
          name: 'Test',
          amount: 100,
          renewalDay: 1,
          category: 'Test',
          createdAt: tenDaysAgo,
        );

        expect(subscription.daysSinceSubscription, greaterThanOrEqualTo(10));
      });
    });

    group('JSON serialization', () {
      test('toJson and fromJson round trip', () {
        final original = Subscription(
          id: 'sub_1',
          name: 'Netflix',
          amount: 99.99,
          renewalDay: 15,
          category: 'Eğlence',
          colorIndex: 3,
          createdAt: DateTime(2024, 1, 1),
          isActive: true,
          autoRecord: true,
          notes: 'Test note',
        );

        final json = original.toJson();
        final restored = Subscription.fromJson(json);

        expect(restored.id, original.id);
        expect(restored.name, original.name);
        expect(restored.amount, original.amount);
        expect(restored.renewalDay, original.renewalDay);
        expect(restored.category, original.category);
        expect(restored.colorIndex, original.colorIndex);
        expect(restored.isActive, original.isActive);
        expect(restored.autoRecord, original.autoRecord);
        expect(restored.notes, original.notes);
      });

      test('fromJson handles missing optional fields', () {
        final json = {
          'id': 'sub_1',
          'name': 'Test',
          'amount': 100.0,
          'renewalDay': 15,
          'category': 'Test',
          'createdAt': '2024-01-01T00:00:00.000',
        };

        final subscription = Subscription.fromJson(json);
        expect(subscription.isActive, true);
        expect(subscription.autoRecord, true);
        expect(subscription.colorIndex, 0);
        expect(subscription.notes, isNull);
      });

      test('encodeList and decodeList round trip', () {
        final subscriptions = [
          Subscription(
            id: 'sub_1',
            name: 'Netflix',
            amount: 100,
            renewalDay: 15,
            category: 'Eğlence',
            createdAt: DateTime(2024, 1, 1),
          ),
          Subscription(
            id: 'sub_2',
            name: 'Spotify',
            amount: 50,
            renewalDay: 1,
            category: 'Müzik',
            createdAt: DateTime(2024, 1, 1),
          ),
        ];

        final encoded = Subscription.encodeList(subscriptions);
        final decoded = Subscription.decodeList(encoded);

        expect(decoded.length, 2);
        expect(decoded[0].name, 'Netflix');
        expect(decoded[1].name, 'Spotify');
      });
    });

    group('copyWith', () {
      late Subscription baseSubscription;

      setUp(() {
        baseSubscription = Subscription(
          id: 'sub_1',
          name: 'Netflix',
          amount: 99.99,
          renewalDay: 15,
          category: 'Eğlence',
          createdAt: DateTime(2024, 1, 1),
        );
      });

      test('copies with new name', () {
        final copied = baseSubscription.copyWith(name: 'Disney+');
        expect(copied.name, 'Disney+');
        expect(copied.amount, 99.99);
        expect(copied.id, 'sub_1');
      });

      test('copies with new amount', () {
        final copied = baseSubscription.copyWith(amount: 149.99);
        expect(copied.amount, 149.99);
        expect(copied.name, 'Netflix');
      });

      test('copies with new active status', () {
        final copied = baseSubscription.copyWith(isActive: false);
        expect(copied.isActive, false);
      });

      test('copies with new autoRecord', () {
        final copied = baseSubscription.copyWith(autoRecord: false);
        expect(copied.autoRecord, false);
      });

      test('copies with new notes', () {
        final copied = baseSubscription.copyWith(notes: 'New note');
        expect(copied.notes, 'New note');
      });

      test('preserves original values when no changes specified', () {
        final copied = baseSubscription.copyWith();
        expect(copied.id, baseSubscription.id);
        expect(copied.name, baseSubscription.name);
        expect(copied.amount, baseSubscription.amount);
        expect(copied.renewalDay, baseSubscription.renewalDay);
        expect(copied.category, baseSubscription.category);
        expect(copied.createdAt, baseSubscription.createdAt);
      });
    });
  });

  group('SubscriptionColors', () {
    test('palette has 8 colors', () {
      expect(SubscriptionColors.palette.length, 8);
    });

    test('count returns palette length', () {
      expect(SubscriptionColors.count, 8);
    });

    test('get returns correct color for index', () {
      for (int i = 0; i < 8; i++) {
        expect(SubscriptionColors.get(i), SubscriptionColors.palette[i]);
      }
    });

    test('get wraps around for index >= 8', () {
      expect(SubscriptionColors.get(8), SubscriptionColors.palette[0]);
      expect(SubscriptionColors.get(9), SubscriptionColors.palette[1]);
      expect(SubscriptionColors.get(15), SubscriptionColors.palette[7]);
    });
  });
}
