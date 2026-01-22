import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vantag/services/subscription_service.dart';
import 'package:vantag/models/subscription.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SubscriptionService', () {
    late SubscriptionService service;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      service = SubscriptionService();
    });

    Subscription createTestSubscription({
      String? id,
      String name = 'Netflix',
      double amount = 99.99,
      bool isActive = true,
      int renewalDay = 15,
    }) {
      return Subscription(
        id: id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        amount: amount,
        renewalDay: renewalDay,
        category: 'Eğlence',
        createdAt: DateTime(2024, 1, 1),
        isActive: isActive,
      );
    }

    group('getSubscriptions', () {
      test('returns empty list when no subscriptions', () async {
        final subs = await service.getSubscriptions();
        expect(subs, isEmpty);
      });
    });

    group('addSubscription', () {
      test('adds subscription successfully', () async {
        final sub = createTestSubscription(name: 'Netflix');
        await service.addSubscription(sub);

        final subs = await service.getSubscriptions();
        expect(subs.length, 1);
        expect(subs.first.name, 'Netflix');
      });

      test('adds multiple subscriptions', () async {
        await service.addSubscription(createTestSubscription(name: 'Netflix'));
        await service.addSubscription(createTestSubscription(name: 'Spotify'));
        await service.addSubscription(createTestSubscription(name: 'Disney+'));

        final subs = await service.getSubscriptions();
        expect(subs.length, 3);
      });
    });

    group('getActiveSubscriptions', () {
      test('returns only active subscriptions', () async {
        await service.addSubscription(createTestSubscription(name: 'Active1', isActive: true));
        await service.addSubscription(createTestSubscription(name: 'Active2', isActive: true));
        await service.addSubscription(createTestSubscription(name: 'Inactive', isActive: false));

        final active = await service.getActiveSubscriptions();
        expect(active.length, 2);
        expect(active.every((s) => s.isActive), true);
      });
    });

    group('updateSubscription', () {
      test('updates subscription successfully', () async {
        final sub = createTestSubscription(id: 'sub_1', name: 'Netflix', amount: 99.99);
        await service.addSubscription(sub);

        final updated = sub.copyWith(amount: 149.99);
        await service.updateSubscription('sub_1', updated);

        final subs = await service.getSubscriptions();
        expect(subs.first.amount, 149.99);
      });

      test('does not update non-existent subscription', () async {
        final sub = createTestSubscription(id: 'sub_1');
        await service.addSubscription(sub);

        final updated = sub.copyWith(amount: 149.99);
        await service.updateSubscription('non_existent', updated);

        final subs = await service.getSubscriptions();
        expect(subs.first.amount, 99.99);
      });
    });

    group('deleteSubscription', () {
      test('deletes subscription successfully', () async {
        final sub = createTestSubscription(id: 'sub_1');
        await service.addSubscription(sub);

        await service.deleteSubscription('sub_1');

        final subs = await service.getSubscriptions();
        expect(subs, isEmpty);
      });

      test('does not affect other subscriptions when deleting', () async {
        await service.addSubscription(createTestSubscription(id: 'sub_1', name: 'Netflix'));
        await service.addSubscription(createTestSubscription(id: 'sub_2', name: 'Spotify'));

        await service.deleteSubscription('sub_1');

        final subs = await service.getSubscriptions();
        expect(subs.length, 1);
        expect(subs.first.name, 'Spotify');
      });
    });

    group('getTotalMonthlyAmount', () {
      test('returns 0 when no subscriptions', () async {
        final total = await service.getTotalMonthlyAmount();
        expect(total, 0);
      });

      test('calculates total of active subscriptions', () async {
        await service.addSubscription(createTestSubscription(amount: 100, isActive: true));
        await service.addSubscription(createTestSubscription(amount: 50, isActive: true));
        await service.addSubscription(createTestSubscription(amount: 200, isActive: false));

        final total = await service.getTotalMonthlyAmount();
        expect(total, 150);
      });
    });

    group('getActiveCount', () {
      test('returns correct count', () async {
        await service.addSubscription(createTestSubscription(isActive: true));
        await service.addSubscription(createTestSubscription(isActive: true));
        await service.addSubscription(createTestSubscription(isActive: false));

        final count = await service.getActiveCount();
        expect(count, 2);
      });
    });

    group('generateId', () {
      test('generates unique IDs', () async {
        final id1 = service.generateId();
        await Future.delayed(const Duration(milliseconds: 2));
        final id2 = service.generateId();

        expect(id1, isNot(equals(id2)));
      });
    });

    group('getNextColorIndex', () {
      test('returns 0 when no subscriptions', () async {
        final index = await service.getNextColorIndex();
        expect(index, 0);
      });
    });
  });
}
