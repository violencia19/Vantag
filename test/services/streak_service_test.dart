import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vantag/services/streak_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('StreakService', () {
    late StreakService service;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      service = StreakService();
    });

    group('getStreakData', () {
      test('returns zero streak when no data exists', () async {
        final data = await service.getStreakData();
        expect(data.currentStreak, 0);
        expect(data.longestStreak, 0);
        expect(data.lastEntryDate, isNull);
        expect(data.isStale, false);
      });

      test('returns stored streak data', () async {
        // Set up initial data
        SharedPreferences.setMockInitialValues({
          'streak_current': 5,
          'streak_longest': 10,
          'streak_last_entry': DateTime.now().toIso8601String(),
        });
        service = StreakService();

        final data = await service.getStreakData();
        expect(data.currentStreak, 5);
        expect(data.longestStreak, 10);
        expect(data.lastEntryDate, isNotNull);
      });

      test('marks streak as stale when day is missed', () async {
        final twoDaysAgo = DateTime.now().subtract(const Duration(days: 2));
        SharedPreferences.setMockInitialValues({
          'streak_current': 5,
          'streak_longest': 5,
          'streak_last_entry': twoDaysAgo.toIso8601String(),
        });
        service = StreakService();

        final data = await service.getStreakData();
        expect(data.isStale, true);
        expect(data.displayStreak, 0);
      });
    });

    group('recordEntry', () {
      test('starts streak at 1 for first entry', () async {
        final data = await service.recordEntry();
        expect(data.currentStreak, 1);
        expect(data.longestStreak, 1);
      });

      test('does not change streak for same day entry', () async {
        await service.recordEntry();
        final secondEntry = await service.recordEntry();
        expect(secondEntry.currentStreak, 1);
      });

      test('increments streak for consecutive day', () async {
        final yesterday = DateTime.now().subtract(const Duration(days: 1));
        SharedPreferences.setMockInitialValues({
          'streak_current': 3,
          'streak_longest': 5,
          'streak_last_entry': yesterday.toIso8601String(),
        });
        service = StreakService();

        final data = await service.recordEntry();
        expect(data.currentStreak, 4);
      });

      test('resets streak when day is missed', () async {
        final twoDaysAgo = DateTime.now().subtract(const Duration(days: 2));
        SharedPreferences.setMockInitialValues({
          'streak_current': 5,
          'streak_longest': 10,
          'streak_last_entry': twoDaysAgo.toIso8601String(),
        });
        service = StreakService();

        final data = await service.recordEntry();
        expect(data.currentStreak, 1);
        expect(data.longestStreak, 10);
      });

      test('updates longest streak when current exceeds it', () async {
        final yesterday = DateTime.now().subtract(const Duration(days: 1));
        SharedPreferences.setMockInitialValues({
          'streak_current': 10,
          'streak_longest': 10,
          'streak_last_entry': yesterday.toIso8601String(),
        });
        service = StreakService();

        final data = await service.recordEntry();
        expect(data.currentStreak, 11);
        expect(data.longestStreak, 11);
      });
    });

    group('cleanupStaleStreak', () {
      test('cleans up stale streak', () async {
        final twoDaysAgo = DateTime.now().subtract(const Duration(days: 2));
        SharedPreferences.setMockInitialValues({
          'streak_current': 5,
          'streak_longest': 5,
          'streak_last_entry': twoDaysAgo.toIso8601String(),
        });
        service = StreakService();

        await service.cleanupStaleStreak();
        final data = await service.getStreakData();
        expect(data.currentStreak, 0);
      });

      test('does not clean up active streak', () async {
        SharedPreferences.setMockInitialValues({
          'streak_current': 5,
          'streak_longest': 5,
          'streak_last_entry': DateTime.now().toIso8601String(),
        });
        service = StreakService();

        await service.cleanupStaleStreak();
        final data = await service.getStreakData();
        expect(data.currentStreak, 5);
      });
    });

    group('resetAllStreakData', () {
      test('resets all streak data', () async {
        SharedPreferences.setMockInitialValues({
          'streak_current': 5,
          'streak_longest': 10,
          'streak_last_entry': DateTime.now().toIso8601String(),
        });
        service = StreakService();

        await service.resetAllStreakData();
        final data = await service.getStreakData();
        expect(data.currentStreak, 0);
        expect(data.longestStreak, 0);
        expect(data.lastEntryDate, isNull);
      });
    });
  });

  group('StreakData', () {
    test('hasStreak returns true when displayStreak > 0', () {
      const data = StreakData(currentStreak: 5, longestStreak: 5);
      expect(data.hasStreak, true);
    });

    test('hasStreak returns false when stale', () {
      const data = StreakData(
        currentStreak: 5,
        longestStreak: 5,
        isStale: true,
      );
      expect(data.hasStreak, false);
    });

    test('isNewRecord returns true when current equals longest', () {
      const data = StreakData(currentStreak: 5, longestStreak: 5);
      expect(data.isNewRecord, true);
    });

    test('isNewRecord returns false when stale', () {
      const data = StreakData(
        currentStreak: 5,
        longestStreak: 5,
        isStale: true,
      );
      expect(data.isNewRecord, false);
    });

    test('displayStreak returns 0 when stale', () {
      const data = StreakData(
        currentStreak: 5,
        longestStreak: 5,
        isStale: true,
      );
      expect(data.displayStreak, 0);
    });
  });
}
