import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vantag/services/profile_service.dart';
import 'package:vantag/models/user_profile.dart';
import 'package:vantag/models/income_source.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ProfileService', () {
    late ProfileService service;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      service = ProfileService();
    });

    group('saveProfile', () {
      test('saves profile successfully', () async {
        final source = IncomeSource.salary(amount: 20000);
        final profile = UserProfile(
          id: 'test_user',
          name: 'Test User',
          incomeSources: [source],
          workDaysPerWeek: 5,
          workHoursPerDay: 8,
        );

        await service.saveProfile(profile);
        final loaded = await service.loadProfile();

        expect(loaded, isNotNull);
        expect(loaded!.name, 'Test User');
        expect(loaded.monthlyIncome, 20000);
      });
    });

    group('loadProfile', () {
      test('returns null when no profile saved', () async {
        final loaded = await service.loadProfile();
        expect(loaded, isNull);
      });

      test('loads saved profile correctly', () async {
        // Save first
        final source = IncomeSource.salary(amount: 25000);
        final profile = UserProfile(
          incomeSources: [source],
          workDaysPerWeek: 6,
          workHoursPerDay: 10,
          currency: 'USD',
        );
        await service.saveProfile(profile);

        // Then load
        final loaded = await service.loadProfile();

        expect(loaded, isNotNull);
        expect(loaded!.monthlyIncome, 25000);
        expect(loaded.workDaysPerWeek, 6);
        expect(loaded.workHoursPerDay, 10);
        expect(loaded.currency, 'USD');
      });
    });

    group('deleteProfile', () {
      test('deletes profile successfully', () async {
        // Save first
        final source = IncomeSource.salary(amount: 20000);
        final profile = UserProfile(
          incomeSources: [source],
          workDaysPerWeek: 5,
          workHoursPerDay: 8,
        );
        await service.saveProfile(profile);

        // Verify saved
        var loaded = await service.loadProfile();
        expect(loaded, isNotNull);

        // Delete
        await service.deleteProfile();

        // Verify deleted
        loaded = await service.loadProfile();
        expect(loaded, isNull);
      });
    });

    group('hasProfile', () {
      test('returns false when no profile', () async {
        final hasProfile = await service.hasProfile();
        expect(hasProfile, false);
      });

      test('returns true when profile exists', () async {
        final source = IncomeSource.salary(amount: 20000);
        final profile = UserProfile(
          incomeSources: [source],
          workDaysPerWeek: 5,
          workHoursPerDay: 8,
        );
        await service.saveProfile(profile);

        final hasProfile = await service.hasProfile();
        expect(hasProfile, true);
      });
    });
  });
}
