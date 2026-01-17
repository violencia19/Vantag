import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('tr'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Vantag'**
  String get appTitle;

  /// No description provided for @appSlogan.
  ///
  /// In en, this message translates to:
  /// **'Your Financial Edge'**
  String get appSlogan;

  /// No description provided for @navExpenses.
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get navExpenses;

  /// No description provided for @navReports.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get navReports;

  /// No description provided for @navAchievements.
  ///
  /// In en, this message translates to:
  /// **'Achievements'**
  String get navAchievements;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @totalBalance.
  ///
  /// In en, this message translates to:
  /// **'Total Balance'**
  String get totalBalance;

  /// No description provided for @monthlyIncome.
  ///
  /// In en, this message translates to:
  /// **'Monthly Income'**
  String get monthlyIncome;

  /// No description provided for @totalIncome.
  ///
  /// In en, this message translates to:
  /// **'Total Income'**
  String get totalIncome;

  /// No description provided for @totalSpent.
  ///
  /// In en, this message translates to:
  /// **'Total Spent'**
  String get totalSpent;

  /// No description provided for @totalSaved.
  ///
  /// In en, this message translates to:
  /// **'Total Saved'**
  String get totalSaved;

  /// No description provided for @workHours.
  ///
  /// In en, this message translates to:
  /// **'Work Hours'**
  String get workHours;

  /// No description provided for @workDays.
  ///
  /// In en, this message translates to:
  /// **'Work Days'**
  String get workDays;

  /// No description provided for @expenses.
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get expenses;

  /// No description provided for @addExpense.
  ///
  /// In en, this message translates to:
  /// **'Add Expense'**
  String get addExpense;

  /// No description provided for @amount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// No description provided for @amountTL.
  ///
  /// In en, this message translates to:
  /// **'Amount (₺)'**
  String get amountTL;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @descriptionHint.
  ///
  /// In en, this message translates to:
  /// **'e.g: Migros, Spotify, Shell...'**
  String get descriptionHint;

  /// No description provided for @descriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Description (Store/Product)'**
  String get descriptionLabel;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @weekdayMon.
  ///
  /// In en, this message translates to:
  /// **'Mon'**
  String get weekdayMon;

  /// No description provided for @weekdayTue.
  ///
  /// In en, this message translates to:
  /// **'Tue'**
  String get weekdayTue;

  /// No description provided for @weekdayWed.
  ///
  /// In en, this message translates to:
  /// **'Wed'**
  String get weekdayWed;

  /// No description provided for @weekdayThu.
  ///
  /// In en, this message translates to:
  /// **'Thu'**
  String get weekdayThu;

  /// No description provided for @weekdayFri.
  ///
  /// In en, this message translates to:
  /// **'Fri'**
  String get weekdayFri;

  /// No description provided for @weekdaySat.
  ///
  /// In en, this message translates to:
  /// **'Sat'**
  String get weekdaySat;

  /// No description provided for @weekdaySun.
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get weekdaySun;

  /// No description provided for @monthJan.
  ///
  /// In en, this message translates to:
  /// **'January'**
  String get monthJan;

  /// No description provided for @monthFeb.
  ///
  /// In en, this message translates to:
  /// **'February'**
  String get monthFeb;

  /// No description provided for @monthMar.
  ///
  /// In en, this message translates to:
  /// **'March'**
  String get monthMar;

  /// No description provided for @monthApr.
  ///
  /// In en, this message translates to:
  /// **'April'**
  String get monthApr;

  /// No description provided for @monthMay.
  ///
  /// In en, this message translates to:
  /// **'May'**
  String get monthMay;

  /// No description provided for @monthJun.
  ///
  /// In en, this message translates to:
  /// **'June'**
  String get monthJun;

  /// No description provided for @monthJul.
  ///
  /// In en, this message translates to:
  /// **'July'**
  String get monthJul;

  /// No description provided for @monthAug.
  ///
  /// In en, this message translates to:
  /// **'August'**
  String get monthAug;

  /// No description provided for @monthSep.
  ///
  /// In en, this message translates to:
  /// **'September'**
  String get monthSep;

  /// No description provided for @monthOct.
  ///
  /// In en, this message translates to:
  /// **'October'**
  String get monthOct;

  /// No description provided for @monthNov.
  ///
  /// In en, this message translates to:
  /// **'November'**
  String get monthNov;

  /// No description provided for @monthDec.
  ///
  /// In en, this message translates to:
  /// **'December'**
  String get monthDec;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @twoDaysAgo.
  ///
  /// In en, this message translates to:
  /// **'2 Days Ago'**
  String get twoDaysAgo;

  /// No description provided for @daysAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} Days Ago'**
  String daysAgo(int count);

  /// No description provided for @bought.
  ///
  /// In en, this message translates to:
  /// **'Bought'**
  String get bought;

  /// No description provided for @thinking.
  ///
  /// In en, this message translates to:
  /// **'Thinking'**
  String get thinking;

  /// No description provided for @passed.
  ///
  /// In en, this message translates to:
  /// **'Passed'**
  String get passed;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @change.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get change;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @update.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update;

  /// No description provided for @calculate.
  ///
  /// In en, this message translates to:
  /// **'Calculate'**
  String get calculate;

  /// No description provided for @giveUp.
  ///
  /// In en, this message translates to:
  /// **'Give Up'**
  String get giveUp;

  /// No description provided for @select.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get select;

  /// No description provided for @decision.
  ///
  /// In en, this message translates to:
  /// **'Decision'**
  String get decision;

  /// No description provided for @hoursRequired.
  ///
  /// In en, this message translates to:
  /// **'{hours} hours'**
  String hoursRequired(String hours);

  /// No description provided for @daysRequired.
  ///
  /// In en, this message translates to:
  /// **'{days} days'**
  String daysRequired(String days);

  /// No description provided for @minutesRequired.
  ///
  /// In en, this message translates to:
  /// **'{minutes} minutes'**
  String minutesRequired(int minutes);

  /// No description provided for @hoursEquivalent.
  ///
  /// In en, this message translates to:
  /// **'{hours} hours equivalent'**
  String hoursEquivalent(String hours);

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @selectCurrency.
  ///
  /// In en, this message translates to:
  /// **'Select Currency'**
  String get selectCurrency;

  /// No description provided for @currency.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get currency;

  /// No description provided for @turkish.
  ///
  /// In en, this message translates to:
  /// **'Turkish'**
  String get turkish;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @incomeInfo.
  ///
  /// In en, this message translates to:
  /// **'Income Information'**
  String get incomeInfo;

  /// No description provided for @dailyWorkHours.
  ///
  /// In en, this message translates to:
  /// **'Daily Work Hours'**
  String get dailyWorkHours;

  /// No description provided for @weeklyWorkDays.
  ///
  /// In en, this message translates to:
  /// **'Weekly Work Days'**
  String get weeklyWorkDays;

  /// No description provided for @workingDaysPerWeek.
  ///
  /// In en, this message translates to:
  /// **'Working {count} days per week'**
  String workingDaysPerWeek(int count);

  /// No description provided for @hours.
  ///
  /// In en, this message translates to:
  /// **'hours'**
  String get hours;

  /// No description provided for @incomeSources.
  ///
  /// In en, this message translates to:
  /// **'{count} sources'**
  String incomeSources(int count);

  /// No description provided for @detailedEntry.
  ///
  /// In en, this message translates to:
  /// **'Detailed Entry'**
  String get detailedEntry;

  /// No description provided for @googleAccount.
  ///
  /// In en, this message translates to:
  /// **'Google Account'**
  String get googleAccount;

  /// No description provided for @googleLinked.
  ///
  /// In en, this message translates to:
  /// **'Google Linked'**
  String get googleLinked;

  /// No description provided for @linkWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Link with Google'**
  String get linkWithGoogle;

  /// No description provided for @linking.
  ///
  /// In en, this message translates to:
  /// **'Linking...'**
  String get linking;

  /// No description provided for @backupAndSecure.
  ///
  /// In en, this message translates to:
  /// **'Backup and secure your data'**
  String get backupAndSecure;

  /// No description provided for @googleLinkedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Google account linked successfully!'**
  String get googleLinkedSuccess;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcome;

  /// No description provided for @welcomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your information to measure expenses in time'**
  String get welcomeSubtitle;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @offlineMode.
  ///
  /// In en, this message translates to:
  /// **'Offline mode - Data will be synced'**
  String get offlineMode;

  /// No description provided for @reports.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get reports;

  /// No description provided for @monthlyReport.
  ///
  /// In en, this message translates to:
  /// **'Monthly Report'**
  String get monthlyReport;

  /// No description provided for @categoryReport.
  ///
  /// In en, this message translates to:
  /// **'Category Report'**
  String get categoryReport;

  /// No description provided for @thisMonth.
  ///
  /// In en, this message translates to:
  /// **'This Month'**
  String get thisMonth;

  /// No description provided for @lastMonth.
  ///
  /// In en, this message translates to:
  /// **'Last Month'**
  String get lastMonth;

  /// No description provided for @thisWeek.
  ///
  /// In en, this message translates to:
  /// **'This Week'**
  String get thisWeek;

  /// No description provided for @allTime.
  ///
  /// In en, this message translates to:
  /// **'All Time'**
  String get allTime;

  /// No description provided for @achievements.
  ///
  /// In en, this message translates to:
  /// **'Achievements'**
  String get achievements;

  /// No description provided for @badges.
  ///
  /// In en, this message translates to:
  /// **'Badges'**
  String get badges;

  /// No description provided for @progress.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get progress;

  /// No description provided for @unlocked.
  ///
  /// In en, this message translates to:
  /// **'Unlocked'**
  String get unlocked;

  /// No description provided for @locked.
  ///
  /// In en, this message translates to:
  /// **'Locked'**
  String get locked;

  /// No description provided for @streak.
  ///
  /// In en, this message translates to:
  /// **'Streak'**
  String get streak;

  /// No description provided for @currentStreak.
  ///
  /// In en, this message translates to:
  /// **'Current Streak'**
  String get currentStreak;

  /// No description provided for @bestStreak.
  ///
  /// In en, this message translates to:
  /// **'Best Streak'**
  String get bestStreak;

  /// No description provided for @streakDays.
  ///
  /// In en, this message translates to:
  /// **'{count} days'**
  String streakDays(int count);

  /// No description provided for @subscriptions.
  ///
  /// In en, this message translates to:
  /// **'Subscriptions'**
  String get subscriptions;

  /// No description provided for @subscriptionsDescription.
  ///
  /// In en, this message translates to:
  /// **'Track your recurring subscriptions like Netflix, Spotify here.'**
  String get subscriptionsDescription;

  /// No description provided for @addSubscription.
  ///
  /// In en, this message translates to:
  /// **'Add Subscription'**
  String get addSubscription;

  /// No description provided for @monthlyTotal.
  ///
  /// In en, this message translates to:
  /// **'Monthly Total'**
  String get monthlyTotal;

  /// No description provided for @yearlyTotal.
  ///
  /// In en, this message translates to:
  /// **'Yearly Total'**
  String get yearlyTotal;

  /// No description provided for @nextPayment.
  ///
  /// In en, this message translates to:
  /// **'Next Payment'**
  String get nextPayment;

  /// No description provided for @renewalWarning.
  ///
  /// In en, this message translates to:
  /// **'Renewal in {days} days'**
  String renewalWarning(int days);

  /// No description provided for @activeSubscriptions.
  ///
  /// In en, this message translates to:
  /// **'{count} active subscriptions'**
  String activeSubscriptions(int count);

  /// No description provided for @monthlySubscriptions.
  ///
  /// In en, this message translates to:
  /// **'Monthly Subscriptions'**
  String get monthlySubscriptions;

  /// No description provided for @habitCalculator.
  ///
  /// In en, this message translates to:
  /// **'Habit Calculator'**
  String get habitCalculator;

  /// No description provided for @selectHabit.
  ///
  /// In en, this message translates to:
  /// **'Select a Habit'**
  String get selectHabit;

  /// No description provided for @enterAmount.
  ///
  /// In en, this message translates to:
  /// **'Enter Amount'**
  String get enterAmount;

  /// No description provided for @dailyAmount.
  ///
  /// In en, this message translates to:
  /// **'Daily Amount'**
  String get dailyAmount;

  /// No description provided for @yearlyCost.
  ///
  /// In en, this message translates to:
  /// **'Yearly Cost'**
  String get yearlyCost;

  /// No description provided for @workDaysEquivalent.
  ///
  /// In en, this message translates to:
  /// **'Work Days Equivalent'**
  String get workDaysEquivalent;

  /// No description provided for @shareResult.
  ///
  /// In en, this message translates to:
  /// **'Share Result'**
  String get shareResult;

  /// No description provided for @habitQuestion.
  ///
  /// In en, this message translates to:
  /// **'How many days does your habit cost?'**
  String get habitQuestion;

  /// No description provided for @calculateAndShock.
  ///
  /// In en, this message translates to:
  /// **'Calculate and be shocked →'**
  String get calculateAndShock;

  /// No description provided for @appTour.
  ///
  /// In en, this message translates to:
  /// **'App Tour'**
  String get appTour;

  /// No description provided for @repeatTour.
  ///
  /// In en, this message translates to:
  /// **'Repeat App Tour'**
  String get repeatTour;

  /// No description provided for @tourCompleted.
  ///
  /// In en, this message translates to:
  /// **'Tour Completed'**
  String get tourCompleted;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @notificationSettings.
  ///
  /// In en, this message translates to:
  /// **'Notification Settings'**
  String get notificationSettings;

  /// No description provided for @streakReminder.
  ///
  /// In en, this message translates to:
  /// **'Streak Reminder'**
  String get streakReminder;

  /// No description provided for @weeklyInsights.
  ///
  /// In en, this message translates to:
  /// **'Weekly Insights'**
  String get weeklyInsights;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// No description provided for @warning.
  ///
  /// In en, this message translates to:
  /// **'Warning'**
  String get warning;

  /// No description provided for @info.
  ///
  /// In en, this message translates to:
  /// **'Info'**
  String get info;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @noData.
  ///
  /// In en, this message translates to:
  /// **'No data available'**
  String get noData;

  /// No description provided for @noExpenses.
  ///
  /// In en, this message translates to:
  /// **'No expenses yet'**
  String get noExpenses;

  /// No description provided for @noExpensesHint.
  ///
  /// In en, this message translates to:
  /// **'Enter an amount above to start'**
  String get noExpensesHint;

  /// No description provided for @noAchievements.
  ///
  /// In en, this message translates to:
  /// **'No achievements yet'**
  String get noAchievements;

  /// No description provided for @recordToEarnBadge.
  ///
  /// In en, this message translates to:
  /// **'Record expenses to earn badges'**
  String get recordToEarnBadge;

  /// No description provided for @notEnoughDataForReports.
  ///
  /// In en, this message translates to:
  /// **'Not enough data for reports'**
  String get notEnoughDataForReports;

  /// No description provided for @confirmDelete.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete?'**
  String get confirmDelete;

  /// No description provided for @deleteConfirmation.
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone.'**
  String get deleteConfirmation;

  /// No description provided for @categoryFood.
  ///
  /// In en, this message translates to:
  /// **'Food'**
  String get categoryFood;

  /// No description provided for @categoryTransport.
  ///
  /// In en, this message translates to:
  /// **'Transport'**
  String get categoryTransport;

  /// No description provided for @categoryEntertainment.
  ///
  /// In en, this message translates to:
  /// **'Entertainment'**
  String get categoryEntertainment;

  /// No description provided for @categoryShopping.
  ///
  /// In en, this message translates to:
  /// **'Shopping'**
  String get categoryShopping;

  /// No description provided for @categoryBills.
  ///
  /// In en, this message translates to:
  /// **'Bills'**
  String get categoryBills;

  /// No description provided for @categoryHealth.
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get categoryHealth;

  /// No description provided for @categoryEducation.
  ///
  /// In en, this message translates to:
  /// **'Education'**
  String get categoryEducation;

  /// No description provided for @categoryDigital.
  ///
  /// In en, this message translates to:
  /// **'Digital'**
  String get categoryDigital;

  /// No description provided for @categoryOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get categoryOther;

  /// No description provided for @categoryClothing.
  ///
  /// In en, this message translates to:
  /// **'Clothing'**
  String get categoryClothing;

  /// No description provided for @categoryElectronics.
  ///
  /// In en, this message translates to:
  /// **'Electronics'**
  String get categoryElectronics;

  /// No description provided for @categorySubscription.
  ///
  /// In en, this message translates to:
  /// **'Subscription'**
  String get categorySubscription;

  /// No description provided for @weekdayMonday.
  ///
  /// In en, this message translates to:
  /// **'Monday'**
  String get weekdayMonday;

  /// No description provided for @weekdayTuesday.
  ///
  /// In en, this message translates to:
  /// **'Tuesday'**
  String get weekdayTuesday;

  /// No description provided for @weekdayWednesday.
  ///
  /// In en, this message translates to:
  /// **'Wednesday'**
  String get weekdayWednesday;

  /// No description provided for @weekdayThursday.
  ///
  /// In en, this message translates to:
  /// **'Thursday'**
  String get weekdayThursday;

  /// No description provided for @weekdayFriday.
  ///
  /// In en, this message translates to:
  /// **'Friday'**
  String get weekdayFriday;

  /// No description provided for @weekdaySaturday.
  ///
  /// In en, this message translates to:
  /// **'Saturday'**
  String get weekdaySaturday;

  /// No description provided for @weekdaySunday.
  ///
  /// In en, this message translates to:
  /// **'Sunday'**
  String get weekdaySunday;

  /// No description provided for @shareTitle.
  ///
  /// In en, this message translates to:
  /// **'Check out my savings with Vantag!'**
  String get shareTitle;

  /// No description provided for @shareMessage.
  ///
  /// In en, this message translates to:
  /// **'I saved {amount} TL this month with Vantag!'**
  String shareMessage(String amount);

  /// No description provided for @currencyRates.
  ///
  /// In en, this message translates to:
  /// **'Currency Rates'**
  String get currencyRates;

  /// No description provided for @currencyRatesDescription.
  ///
  /// In en, this message translates to:
  /// **'Current USD, EUR and gold prices. Tap for details.'**
  String get currencyRatesDescription;

  /// No description provided for @gold.
  ///
  /// In en, this message translates to:
  /// **'Gold'**
  String get gold;

  /// No description provided for @dollar.
  ///
  /// In en, this message translates to:
  /// **'Dollar'**
  String get dollar;

  /// No description provided for @euro.
  ///
  /// In en, this message translates to:
  /// **'Euro'**
  String get euro;

  /// No description provided for @moneySavedInPocket.
  ///
  /// In en, this message translates to:
  /// **'Money stayed in your pocket!'**
  String get moneySavedInPocket;

  /// No description provided for @greatDecision.
  ///
  /// In en, this message translates to:
  /// **'Great decision!'**
  String get greatDecision;

  /// No description provided for @freedomCloser.
  ///
  /// In en, this message translates to:
  /// **'Money stayed in pocket, you\'re {hours} closer to freedom!'**
  String freedomCloser(String hours);

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @termsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfService;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @dangerZone.
  ///
  /// In en, this message translates to:
  /// **'Danger Zone'**
  String get dangerZone;

  /// No description provided for @appVersion.
  ///
  /// In en, this message translates to:
  /// **'App Version'**
  String get appVersion;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOut;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccount;

  /// No description provided for @greetingMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning'**
  String get greetingMorning;

  /// No description provided for @greetingAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon'**
  String get greetingAfternoon;

  /// No description provided for @greetingEvening.
  ///
  /// In en, this message translates to:
  /// **'Good evening'**
  String get greetingEvening;

  /// No description provided for @financialStatus.
  ///
  /// In en, this message translates to:
  /// **'Financial Status'**
  String get financialStatus;

  /// No description provided for @financialSummary.
  ///
  /// In en, this message translates to:
  /// **'Financial Summary'**
  String get financialSummary;

  /// No description provided for @financialSummaryDescription.
  ///
  /// In en, this message translates to:
  /// **'Your monthly income, expenses and saved money here. All data updates in real-time.'**
  String get financialSummaryDescription;

  /// No description provided for @newExpense.
  ///
  /// In en, this message translates to:
  /// **'New Expense'**
  String get newExpense;

  /// No description provided for @expenseHistory.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get expenseHistory;

  /// No description provided for @recordCount.
  ///
  /// In en, this message translates to:
  /// **'{count} records'**
  String recordCount(int count);

  /// No description provided for @recordCountLimited.
  ///
  /// In en, this message translates to:
  /// **'{shown} of {total} records'**
  String recordCountLimited(int shown, int total);

  /// No description provided for @unlockFullHistory.
  ///
  /// In en, this message translates to:
  /// **'Unlock Full History'**
  String get unlockFullHistory;

  /// No description provided for @proHistoryDescription.
  ///
  /// In en, this message translates to:
  /// **'Free users can view last 30 days. Upgrade to Pro for unlimited history.'**
  String proHistoryDescription(int count);

  /// No description provided for @upgradeToPro.
  ///
  /// In en, this message translates to:
  /// **'Upgrade to Pro'**
  String get upgradeToPro;

  /// No description provided for @streakTracking.
  ///
  /// In en, this message translates to:
  /// **'Streak Tracking'**
  String get streakTracking;

  /// No description provided for @streakTrackingDescription.
  ///
  /// In en, this message translates to:
  /// **'Your streak increases with daily entries. Regular tracking is key to mindful spending!'**
  String get streakTrackingDescription;

  /// No description provided for @pastDateSelection.
  ///
  /// In en, this message translates to:
  /// **'Past Date Selection'**
  String get pastDateSelection;

  /// No description provided for @pastDateSelectionDescription.
  ///
  /// In en, this message translates to:
  /// **'You can also enter expenses from yesterday or previous days. Tap the calendar icon to select any date.'**
  String get pastDateSelectionDescription;

  /// No description provided for @amountEntry.
  ///
  /// In en, this message translates to:
  /// **'Amount Entry'**
  String get amountEntry;

  /// No description provided for @amountEntryDescription.
  ///
  /// In en, this message translates to:
  /// **'Enter the expense amount here. Use the receipt scan button to read from receipt automatically.'**
  String get amountEntryDescription;

  /// No description provided for @smartMatching.
  ///
  /// In en, this message translates to:
  /// **'Smart Matching'**
  String get smartMatching;

  /// No description provided for @smartMatchingDescription.
  ///
  /// In en, this message translates to:
  /// **'Type the store or product name. Migros, A101, Starbucks... The app will automatically suggest a category!'**
  String get smartMatchingDescription;

  /// No description provided for @categorySelection.
  ///
  /// In en, this message translates to:
  /// **'Category Selection'**
  String get categorySelection;

  /// No description provided for @categorySelectionDescription.
  ///
  /// In en, this message translates to:
  /// **'If smart matching doesn\'t find it or you want to change, you can manually select here.'**
  String get categorySelectionDescription;

  /// No description provided for @selectCategory.
  ///
  /// In en, this message translates to:
  /// **'Select Category'**
  String get selectCategory;

  /// No description provided for @autoSelected.
  ///
  /// In en, this message translates to:
  /// **'Auto-selected: {category}'**
  String autoSelected(String category);

  /// No description provided for @pleaseSelectCategory.
  ///
  /// In en, this message translates to:
  /// **'Please select a category'**
  String get pleaseSelectCategory;

  /// No description provided for @subCategoryOptional.
  ///
  /// In en, this message translates to:
  /// **'Sub-category (optional)'**
  String get subCategoryOptional;

  /// No description provided for @recentlyUsed.
  ///
  /// In en, this message translates to:
  /// **'Recently used'**
  String get recentlyUsed;

  /// No description provided for @suggestions.
  ///
  /// In en, this message translates to:
  /// **'Suggestions'**
  String get suggestions;

  /// No description provided for @scanReceipt.
  ///
  /// In en, this message translates to:
  /// **'Scan receipt'**
  String get scanReceipt;

  /// No description provided for @cameraCapture.
  ///
  /// In en, this message translates to:
  /// **'Capture with camera'**
  String get cameraCapture;

  /// No description provided for @selectFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Select from gallery'**
  String get selectFromGallery;

  /// No description provided for @amountFound.
  ///
  /// In en, this message translates to:
  /// **'Amount found: {amount} ₺'**
  String amountFound(String amount);

  /// No description provided for @amountNotFound.
  ///
  /// In en, this message translates to:
  /// **'Amount not found. Enter manually.'**
  String get amountNotFound;

  /// No description provided for @scanError.
  ///
  /// In en, this message translates to:
  /// **'Scan error. Try again.'**
  String get scanError;

  /// No description provided for @selectExpenseDate.
  ///
  /// In en, this message translates to:
  /// **'Select Expense Date'**
  String get selectExpenseDate;

  /// No description provided for @decisionUpdatedBought.
  ///
  /// In en, this message translates to:
  /// **'Decision updated: Bought'**
  String get decisionUpdatedBought;

  /// No description provided for @decisionSaved.
  ///
  /// In en, this message translates to:
  /// **'You passed, saved {amount} TL!'**
  String decisionSaved(String amount);

  /// No description provided for @keepThinking.
  ///
  /// In en, this message translates to:
  /// **'Keep thinking'**
  String get keepThinking;

  /// No description provided for @expenseUpdated.
  ///
  /// In en, this message translates to:
  /// **'Expense updated'**
  String get expenseUpdated;

  /// No description provided for @validationEnterAmount.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid amount'**
  String get validationEnterAmount;

  /// No description provided for @validationAmountPositive.
  ///
  /// In en, this message translates to:
  /// **'Amount must be greater than 0'**
  String get validationAmountPositive;

  /// No description provided for @validationAmountTooHigh.
  ///
  /// In en, this message translates to:
  /// **'Amount seems too high'**
  String get validationAmountTooHigh;

  /// No description provided for @simulationSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved as Simulation'**
  String get simulationSaved;

  /// No description provided for @simulationDescription.
  ///
  /// In en, this message translates to:
  /// **'This amount was saved as simulation because it\'s large.'**
  String get simulationDescription;

  /// No description provided for @simulationInfo.
  ///
  /// In en, this message translates to:
  /// **'Does not affect your statistics, just for reference.'**
  String get simulationInfo;

  /// No description provided for @understood.
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get understood;

  /// No description provided for @monthJanuary.
  ///
  /// In en, this message translates to:
  /// **'January'**
  String get monthJanuary;

  /// No description provided for @monthFebruary.
  ///
  /// In en, this message translates to:
  /// **'February'**
  String get monthFebruary;

  /// No description provided for @monthMarch.
  ///
  /// In en, this message translates to:
  /// **'March'**
  String get monthMarch;

  /// No description provided for @monthApril.
  ///
  /// In en, this message translates to:
  /// **'April'**
  String get monthApril;

  /// No description provided for @monthJune.
  ///
  /// In en, this message translates to:
  /// **'June'**
  String get monthJune;

  /// No description provided for @monthJuly.
  ///
  /// In en, this message translates to:
  /// **'July'**
  String get monthJuly;

  /// No description provided for @monthAugust.
  ///
  /// In en, this message translates to:
  /// **'August'**
  String get monthAugust;

  /// No description provided for @monthSeptember.
  ///
  /// In en, this message translates to:
  /// **'September'**
  String get monthSeptember;

  /// No description provided for @monthOctober.
  ///
  /// In en, this message translates to:
  /// **'October'**
  String get monthOctober;

  /// No description provided for @monthNovember.
  ///
  /// In en, this message translates to:
  /// **'November'**
  String get monthNovember;

  /// No description provided for @monthDecember.
  ///
  /// In en, this message translates to:
  /// **'December'**
  String get monthDecember;

  /// No description provided for @categoryDistribution.
  ///
  /// In en, this message translates to:
  /// **'Category Distribution'**
  String get categoryDistribution;

  /// No description provided for @moreCategories.
  ///
  /// In en, this message translates to:
  /// **'+{count} more categories'**
  String moreCategories(int count);

  /// No description provided for @expenseCount.
  ///
  /// In en, this message translates to:
  /// **'Expense Count'**
  String get expenseCount;

  /// No description provided for @boughtPassed.
  ///
  /// In en, this message translates to:
  /// **'{bought} bought, {passed} passed'**
  String boughtPassed(int bought, int passed);

  /// No description provided for @passRate.
  ///
  /// In en, this message translates to:
  /// **'Pass Rate'**
  String get passRate;

  /// No description provided for @doingGreat.
  ///
  /// In en, this message translates to:
  /// **'You\'re doing great!'**
  String get doingGreat;

  /// No description provided for @canDoBetter.
  ///
  /// In en, this message translates to:
  /// **'You can do better'**
  String get canDoBetter;

  /// No description provided for @statistics.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statistics;

  /// No description provided for @avgDailyExpense.
  ///
  /// In en, this message translates to:
  /// **'Average Daily Expense'**
  String get avgDailyExpense;

  /// No description provided for @highestSingleExpense.
  ///
  /// In en, this message translates to:
  /// **'Highest Single Expense'**
  String get highestSingleExpense;

  /// No description provided for @mostDeclinedCategory.
  ///
  /// In en, this message translates to:
  /// **'Most Declined Category'**
  String get mostDeclinedCategory;

  /// No description provided for @times.
  ///
  /// In en, this message translates to:
  /// **'{count} times'**
  String times(int count);

  /// No description provided for @trend.
  ///
  /// In en, this message translates to:
  /// **'Trend'**
  String get trend;

  /// No description provided for @trendSpentThisPeriod.
  ///
  /// In en, this message translates to:
  /// **'You spent {amount} TL this {period}'**
  String trendSpentThisPeriod(String amount, String period);

  /// No description provided for @trendSameAsPrevious.
  ///
  /// In en, this message translates to:
  /// **'Same spending as last {period}'**
  String trendSameAsPrevious(String period);

  /// No description provided for @trendSpentLess.
  ///
  /// In en, this message translates to:
  /// **'You spent {percent}% less than last {period}'**
  String trendSpentLess(String percent, String period);

  /// No description provided for @trendSpentMore.
  ///
  /// In en, this message translates to:
  /// **'You spent {percent}% more than last {period}'**
  String trendSpentMore(String percent, String period);

  /// No description provided for @periodWeek.
  ///
  /// In en, this message translates to:
  /// **'week'**
  String get periodWeek;

  /// No description provided for @periodMonth.
  ///
  /// In en, this message translates to:
  /// **'month'**
  String get periodMonth;

  /// No description provided for @subCategoryDetail.
  ///
  /// In en, this message translates to:
  /// **'Sub-Category Detail'**
  String get subCategoryDetail;

  /// No description provided for @comparedToPrevious.
  ///
  /// In en, this message translates to:
  /// **'Compared to previous period'**
  String get comparedToPrevious;

  /// No description provided for @increased.
  ///
  /// In en, this message translates to:
  /// **'increased'**
  String get increased;

  /// No description provided for @decreased.
  ///
  /// In en, this message translates to:
  /// **'decreased'**
  String get decreased;

  /// No description provided for @subCategoryChange.
  ///
  /// In en, this message translates to:
  /// **'This {period} your {subCategory} spending {changeText} by {percent}% compared to last {previousPeriod}.'**
  String subCategoryChange(
    String period,
    String subCategory,
    String changeText,
    String percent,
    String previousPeriod,
  );

  /// No description provided for @listView.
  ///
  /// In en, this message translates to:
  /// **'List View'**
  String get listView;

  /// No description provided for @calendarView.
  ///
  /// In en, this message translates to:
  /// **'Calendar View'**
  String get calendarView;

  /// No description provided for @subscription.
  ///
  /// In en, this message translates to:
  /// **'subscription'**
  String get subscription;

  /// No description provided for @workDaysPerMonth.
  ///
  /// In en, this message translates to:
  /// **'work days/month'**
  String get workDaysPerMonth;

  /// No description provided for @everyMonthDay.
  ///
  /// In en, this message translates to:
  /// **'Every {day}th of month'**
  String everyMonthDay(int day);

  /// No description provided for @noSubscriptionsYet.
  ///
  /// In en, this message translates to:
  /// **'No subscriptions yet'**
  String get noSubscriptionsYet;

  /// No description provided for @addSubscriptionsLikeNetflix.
  ///
  /// In en, this message translates to:
  /// **'Add your subscriptions like Netflix, Spotify'**
  String get addSubscriptionsLikeNetflix;

  /// No description provided for @monthlyTotalAmount.
  ///
  /// In en, this message translates to:
  /// **'Monthly total: {amount} TL'**
  String monthlyTotalAmount(String amount);

  /// No description provided for @dayOfMonth.
  ///
  /// In en, this message translates to:
  /// **'Every {day}th'**
  String dayOfMonth(int day);

  /// No description provided for @addSubscriptionHint.
  ///
  /// In en, this message translates to:
  /// **'Press + button to add a new subscription'**
  String get addSubscriptionHint;

  /// No description provided for @tomorrow.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow'**
  String get tomorrow;

  /// No description provided for @daysLater.
  ///
  /// In en, this message translates to:
  /// **'in {days} days'**
  String daysLater(int days);

  /// No description provided for @perMonth.
  ///
  /// In en, this message translates to:
  /// **'/month'**
  String get perMonth;

  /// No description provided for @enterSubscriptionName.
  ///
  /// In en, this message translates to:
  /// **'Enter subscription name'**
  String get enterSubscriptionName;

  /// No description provided for @enterValidAmount.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid amount'**
  String get enterValidAmount;

  /// No description provided for @editSubscription.
  ///
  /// In en, this message translates to:
  /// **'Edit Subscription'**
  String get editSubscription;

  /// No description provided for @newSubscription.
  ///
  /// In en, this message translates to:
  /// **'New Subscription'**
  String get newSubscription;

  /// No description provided for @subscriptionName.
  ///
  /// In en, this message translates to:
  /// **'Subscription Name'**
  String get subscriptionName;

  /// No description provided for @subscriptionNameHint.
  ///
  /// In en, this message translates to:
  /// **'Netflix, Spotify...'**
  String get subscriptionNameHint;

  /// No description provided for @monthlyAmount.
  ///
  /// In en, this message translates to:
  /// **'Monthly Amount'**
  String get monthlyAmount;

  /// No description provided for @renewalDay.
  ///
  /// In en, this message translates to:
  /// **'Renewal Day'**
  String get renewalDay;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @passivesNotIncluded.
  ///
  /// In en, this message translates to:
  /// **'Passive subscriptions not included in notifications'**
  String get passivesNotIncluded;

  /// No description provided for @autoRecord.
  ///
  /// In en, this message translates to:
  /// **'Auto Record'**
  String get autoRecord;

  /// No description provided for @autoRecordDescription.
  ///
  /// In en, this message translates to:
  /// **'Create expense record on renewal'**
  String get autoRecordDescription;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @subscriptionCount.
  ///
  /// In en, this message translates to:
  /// **'{count} subscriptions, {amount} ₺/month'**
  String subscriptionCount(int count, String amount);

  /// No description provided for @viewSubscriptionsInCalendar.
  ///
  /// In en, this message translates to:
  /// **'View your subscriptions in calendar'**
  String get viewSubscriptionsInCalendar;

  /// No description provided for @urgentRenewalWarning.
  ///
  /// In en, this message translates to:
  /// **'Urgent Renewal Warning!'**
  String get urgentRenewalWarning;

  /// No description provided for @upcomingRenewals.
  ///
  /// In en, this message translates to:
  /// **'Upcoming Renewals'**
  String get upcomingRenewals;

  /// No description provided for @renewsWithinOneHour.
  ///
  /// In en, this message translates to:
  /// **'{name} - renews within 1 hour'**
  String renewsWithinOneHour(String name);

  /// No description provided for @renewsWithinHours.
  ///
  /// In en, this message translates to:
  /// **'{name} - in {hours} hours'**
  String renewsWithinHours(String name, int hours);

  /// No description provided for @renewsToday.
  ///
  /// In en, this message translates to:
  /// **'{name} - renews today'**
  String renewsToday(String name);

  /// No description provided for @renewsTomorrow.
  ///
  /// In en, this message translates to:
  /// **'{name} - renews tomorrow'**
  String renewsTomorrow(String name);

  /// No description provided for @subscriptionsRenewingSoon.
  ///
  /// In en, this message translates to:
  /// **'{count} subscriptions renewing soon'**
  String subscriptionsRenewingSoon(int count);

  /// No description provided for @amountPerMonth.
  ///
  /// In en, this message translates to:
  /// **'{amount} ₺/month'**
  String amountPerMonth(String amount);

  /// No description provided for @hiddenBadges.
  ///
  /// In en, this message translates to:
  /// **'Hidden Badges'**
  String get hiddenBadges;

  /// No description provided for @badgesEarned.
  ///
  /// In en, this message translates to:
  /// **'{unlocked} / {total} badges earned'**
  String badgesEarned(int unlocked, int total);

  /// No description provided for @percentComplete.
  ///
  /// In en, this message translates to:
  /// **'{percent}% complete'**
  String percentComplete(String percent);

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed!'**
  String get completed;

  /// No description provided for @startRecordingForFirstBadge.
  ///
  /// In en, this message translates to:
  /// **'Record an expense to earn your first badge!'**
  String get startRecordingForFirstBadge;

  /// No description provided for @greatStartKeepGoing.
  ///
  /// In en, this message translates to:
  /// **'Great start, keep going!'**
  String get greatStartKeepGoing;

  /// No description provided for @halfwayThere.
  ///
  /// In en, this message translates to:
  /// **'Halfway there, keep it up!'**
  String get halfwayThere;

  /// No description provided for @doingVeryWell.
  ///
  /// In en, this message translates to:
  /// **'You\'re doing very well!'**
  String get doingVeryWell;

  /// No description provided for @almostDone.
  ///
  /// In en, this message translates to:
  /// **'Almost there!'**
  String get almostDone;

  /// No description provided for @allBadgesEarned.
  ///
  /// In en, this message translates to:
  /// **'All badges earned, congratulations!'**
  String get allBadgesEarned;

  /// No description provided for @hiddenBadge.
  ///
  /// In en, this message translates to:
  /// **'Hidden Badge'**
  String get hiddenBadge;

  /// No description provided for @discoverHowToUnlock.
  ///
  /// In en, this message translates to:
  /// **'Discover how to unlock!'**
  String get discoverHowToUnlock;

  /// No description provided for @difficultyEasy.
  ///
  /// In en, this message translates to:
  /// **'Easy'**
  String get difficultyEasy;

  /// No description provided for @difficultyMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get difficultyMedium;

  /// No description provided for @difficultyHard.
  ///
  /// In en, this message translates to:
  /// **'Hard'**
  String get difficultyHard;

  /// No description provided for @difficultyLegendary.
  ///
  /// In en, this message translates to:
  /// **'Legendary'**
  String get difficultyLegendary;

  /// No description provided for @earnedToday.
  ///
  /// In en, this message translates to:
  /// **'Earned today!'**
  String get earnedToday;

  /// No description provided for @earnedYesterday.
  ///
  /// In en, this message translates to:
  /// **'Earned yesterday'**
  String get earnedYesterday;

  /// No description provided for @daysAgoEarned.
  ///
  /// In en, this message translates to:
  /// **'{count} days ago'**
  String daysAgoEarned(int count);

  /// No description provided for @weeksAgoEarned.
  ///
  /// In en, this message translates to:
  /// **'{count} weeks ago'**
  String weeksAgoEarned(int count);

  /// No description provided for @tapToAddPhoto.
  ///
  /// In en, this message translates to:
  /// **'Tap to add photo'**
  String get tapToAddPhoto;

  /// No description provided for @dailyWork.
  ///
  /// In en, this message translates to:
  /// **'Daily Work'**
  String get dailyWork;

  /// No description provided for @weeklyWorkingDays.
  ///
  /// In en, this message translates to:
  /// **'Weekly Working Days'**
  String get weeklyWorkingDays;

  /// No description provided for @hourlyEarnings.
  ///
  /// In en, this message translates to:
  /// **'Hourly Earnings'**
  String get hourlyEarnings;

  /// No description provided for @hourAbbreviation.
  ///
  /// In en, this message translates to:
  /// **'h'**
  String get hourAbbreviation;

  /// No description provided for @days.
  ///
  /// In en, this message translates to:
  /// **'days'**
  String get days;

  /// No description provided for @resetData.
  ///
  /// In en, this message translates to:
  /// **'Reset Data'**
  String get resetData;

  /// No description provided for @resetDataDebug.
  ///
  /// In en, this message translates to:
  /// **'Reset Data (DEBUG)'**
  String get resetDataDebug;

  /// No description provided for @resetDataTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset Data'**
  String get resetDataTitle;

  /// No description provided for @resetDataMessage.
  ///
  /// In en, this message translates to:
  /// **'All app data will be deleted. This action cannot be undone.'**
  String get resetDataMessage;

  /// No description provided for @notificationTypes.
  ///
  /// In en, this message translates to:
  /// **'Notification Types'**
  String get notificationTypes;

  /// No description provided for @awarenessReminder.
  ///
  /// In en, this message translates to:
  /// **'Awareness Reminder'**
  String get awarenessReminder;

  /// No description provided for @awarenessReminderDesc.
  ///
  /// In en, this message translates to:
  /// **'6-12 hours after high-value purchases'**
  String get awarenessReminderDesc;

  /// No description provided for @giveUpCongrats.
  ///
  /// In en, this message translates to:
  /// **'Pass Congratulation'**
  String get giveUpCongrats;

  /// No description provided for @giveUpCongratsDesc.
  ///
  /// In en, this message translates to:
  /// **'Same day motivation when you pass'**
  String get giveUpCongratsDesc;

  /// No description provided for @streakReminderDesc.
  ///
  /// In en, this message translates to:
  /// **'Evening, before streak breaks'**
  String get streakReminderDesc;

  /// No description provided for @weeklySummary.
  ///
  /// In en, this message translates to:
  /// **'Weekly Summary'**
  String get weeklySummary;

  /// No description provided for @weeklySummaryDesc.
  ///
  /// In en, this message translates to:
  /// **'Sunday weekly insight'**
  String get weeklySummaryDesc;

  /// No description provided for @nightModeNotice.
  ///
  /// In en, this message translates to:
  /// **'No notifications during night hours (22:00-08:00). We won\'t disturb your sleep.'**
  String get nightModeNotice;

  /// No description provided for @on.
  ///
  /// In en, this message translates to:
  /// **'On'**
  String get on;

  /// No description provided for @off.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get off;

  /// No description provided for @lastUpdate.
  ///
  /// In en, this message translates to:
  /// **'Last Update'**
  String get lastUpdate;

  /// No description provided for @rates.
  ///
  /// In en, this message translates to:
  /// **'Rates'**
  String get rates;

  /// No description provided for @usDollar.
  ///
  /// In en, this message translates to:
  /// **'US Dollar'**
  String get usDollar;

  /// No description provided for @gramGold.
  ///
  /// In en, this message translates to:
  /// **'Gram Gold'**
  String get gramGold;

  /// No description provided for @tcmbNotice.
  ///
  /// In en, this message translates to:
  /// **'Rates are from TCMB (Central Bank of the Republic of Turkey). Gold prices reflect real-time market data.'**
  String get tcmbNotice;

  /// No description provided for @buy.
  ///
  /// In en, this message translates to:
  /// **'Buy'**
  String get buy;

  /// No description provided for @sell.
  ///
  /// In en, this message translates to:
  /// **'Sell'**
  String get sell;

  /// No description provided for @createOwnCategory.
  ///
  /// In en, this message translates to:
  /// **'Create Your Own Category'**
  String get createOwnCategory;

  /// No description provided for @selectEmoji.
  ///
  /// In en, this message translates to:
  /// **'Select Emoji'**
  String get selectEmoji;

  /// No description provided for @categoryName.
  ///
  /// In en, this message translates to:
  /// **'Category Name'**
  String get categoryName;

  /// No description provided for @categoryNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g: Starbucks'**
  String get categoryNameHint;

  /// No description provided for @continueButton.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;

  /// No description provided for @howManyDaysForHabit.
  ///
  /// In en, this message translates to:
  /// **'How many days do you work for what?'**
  String get howManyDaysForHabit;

  /// No description provided for @selectHabitShock.
  ///
  /// In en, this message translates to:
  /// **'Select a habit, be shocked'**
  String get selectHabitShock;

  /// No description provided for @addMyOwnCategory.
  ///
  /// In en, this message translates to:
  /// **'Add my own category'**
  String get addMyOwnCategory;

  /// No description provided for @whatIsYourSalary.
  ///
  /// In en, this message translates to:
  /// **'What\'s Your Monthly Salary?'**
  String get whatIsYourSalary;

  /// No description provided for @enterNetAmount.
  ///
  /// In en, this message translates to:
  /// **'Enter net take-home amount'**
  String get enterNetAmount;

  /// No description provided for @howMuchPerTime.
  ///
  /// In en, this message translates to:
  /// **'How much TL do you spend per time?'**
  String get howMuchPerTime;

  /// No description provided for @tl.
  ///
  /// In en, this message translates to:
  /// **'TL'**
  String get tl;

  /// No description provided for @howOften.
  ///
  /// In en, this message translates to:
  /// **'How often?'**
  String get howOften;

  /// No description provided for @whatIsYourIncome.
  ///
  /// In en, this message translates to:
  /// **'What\'s your monthly income?'**
  String get whatIsYourIncome;

  /// No description provided for @exampleAmount.
  ///
  /// In en, this message translates to:
  /// **'e.g: 50000'**
  String get exampleAmount;

  /// No description provided for @dontWantToSay.
  ///
  /// In en, this message translates to:
  /// **'I don\'t want to say'**
  String get dontWantToSay;

  /// No description provided for @resultDays.
  ///
  /// In en, this message translates to:
  /// **'{value} DAYS'**
  String resultDays(String value);

  /// No description provided for @yearlyHabitCost.
  ///
  /// In en, this message translates to:
  /// **'You work this many days\njust for {habit} yearly'**
  String yearlyHabitCost(String habit);

  /// No description provided for @monthlyYearlyCost.
  ///
  /// In en, this message translates to:
  /// **'Monthly: {monthly} • Yearly: {yearly}'**
  String monthlyYearlyCost(String monthly, String yearly);

  /// No description provided for @shareOnStory.
  ///
  /// In en, this message translates to:
  /// **'Share on Story'**
  String get shareOnStory;

  /// No description provided for @tryAnotherHabit.
  ///
  /// In en, this message translates to:
  /// **'Try another habit'**
  String get tryAnotherHabit;

  /// No description provided for @trackAllExpenses.
  ///
  /// In en, this message translates to:
  /// **'Track all my expenses'**
  String get trackAllExpenses;

  /// No description provided for @editIncomes.
  ///
  /// In en, this message translates to:
  /// **'Edit Incomes'**
  String get editIncomes;

  /// No description provided for @addIncome.
  ///
  /// In en, this message translates to:
  /// **'Add Income'**
  String get addIncome;

  /// No description provided for @daysPerWeek.
  ///
  /// In en, this message translates to:
  /// **'days/week'**
  String get daysPerWeek;

  /// No description provided for @doYouHaveOtherIncome.
  ///
  /// In en, this message translates to:
  /// **'Do You Have\nOther Income?'**
  String get doYouHaveOtherIncome;

  /// No description provided for @otherIncomeDescription.
  ///
  /// In en, this message translates to:
  /// **'You can add additional incomes like\nfreelance, rental, investment income'**
  String get otherIncomeDescription;

  /// No description provided for @yesAddIncome.
  ///
  /// In en, this message translates to:
  /// **'Yes, I Want to Add'**
  String get yesAddIncome;

  /// No description provided for @noOnlySalary.
  ///
  /// In en, this message translates to:
  /// **'No, Only My Salary'**
  String get noOnlySalary;

  /// No description provided for @addAdditionalIncome.
  ///
  /// In en, this message translates to:
  /// **'+ Add Additional Income'**
  String get addAdditionalIncome;

  /// No description provided for @additionalIncomeQuestion.
  ///
  /// In en, this message translates to:
  /// **'Do you have additional income?'**
  String get additionalIncomeQuestion;

  /// No description provided for @budgetSettings.
  ///
  /// In en, this message translates to:
  /// **'Budget Settings'**
  String get budgetSettings;

  /// No description provided for @budgetSettingsHint.
  ///
  /// In en, this message translates to:
  /// **'Optional. If not set, it will be calculated based on your income.'**
  String get budgetSettingsHint;

  /// No description provided for @monthlySpendingLimit.
  ///
  /// In en, this message translates to:
  /// **'Monthly Spending Limit'**
  String get monthlySpendingLimit;

  /// No description provided for @monthlySpendingLimitHint.
  ///
  /// In en, this message translates to:
  /// **'How much do you want to spend this month?'**
  String get monthlySpendingLimitHint;

  /// No description provided for @monthlySavingsGoal.
  ///
  /// In en, this message translates to:
  /// **'Monthly Savings Goal'**
  String get monthlySavingsGoal;

  /// No description provided for @monthlySavingsGoalHint.
  ///
  /// In en, this message translates to:
  /// **'How much do you want to save each month?'**
  String get monthlySavingsGoalHint;

  /// No description provided for @budgetInfoMessage.
  ///
  /// In en, this message translates to:
  /// **'The progress bar is calculated based on your remaining budget after mandatory expenses.'**
  String get budgetInfoMessage;

  /// No description provided for @linkWithGoogleTitle.
  ///
  /// In en, this message translates to:
  /// **'Link with Google'**
  String get linkWithGoogleTitle;

  /// No description provided for @linkWithGoogleDescription.
  ///
  /// In en, this message translates to:
  /// **'Securely access your data from all devices'**
  String get linkWithGoogleDescription;

  /// No description provided for @skipForNow.
  ///
  /// In en, this message translates to:
  /// **'Skip for now'**
  String get skipForNow;

  /// No description provided for @incomeType.
  ///
  /// In en, this message translates to:
  /// **'Income Type'**
  String get incomeType;

  /// No description provided for @descriptionOptional.
  ///
  /// In en, this message translates to:
  /// **'Description (Optional)'**
  String get descriptionOptional;

  /// No description provided for @descriptionOptionalHint.
  ///
  /// In en, this message translates to:
  /// **'e.g: Upwork Project'**
  String get descriptionOptionalHint;

  /// No description provided for @addedIncomes.
  ///
  /// In en, this message translates to:
  /// **'Added Incomes'**
  String get addedIncomes;

  /// No description provided for @incomeSummary.
  ///
  /// In en, this message translates to:
  /// **'Income Summary'**
  String get incomeSummary;

  /// No description provided for @totalMonthlyIncome.
  ///
  /// In en, this message translates to:
  /// **'Total Monthly Income'**
  String get totalMonthlyIncome;

  /// No description provided for @incomeSource.
  ///
  /// In en, this message translates to:
  /// **'income source'**
  String get incomeSource;

  /// No description provided for @complete.
  ///
  /// In en, this message translates to:
  /// **'Complete'**
  String get complete;

  /// No description provided for @editMyIncomes.
  ///
  /// In en, this message translates to:
  /// **'Edit My Incomes'**
  String get editMyIncomes;

  /// No description provided for @goBack.
  ///
  /// In en, this message translates to:
  /// **'Go Back'**
  String get goBack;

  /// No description provided for @notBudgetApp.
  ///
  /// In en, this message translates to:
  /// **'This is not a budget app'**
  String get notBudgetApp;

  /// No description provided for @showRealCost.
  ///
  /// In en, this message translates to:
  /// **'Show the real cost of expenses: your time.'**
  String get showRealCost;

  /// No description provided for @everyExpenseDecision.
  ///
  /// In en, this message translates to:
  /// **'Every expense is a decision'**
  String get everyExpenseDecision;

  /// No description provided for @youDecide.
  ///
  /// In en, this message translates to:
  /// **'Bought, thinking, or passed. You decide.'**
  String get youDecide;

  /// No description provided for @oneExpenseEnough.
  ///
  /// In en, this message translates to:
  /// **'One expense today is enough'**
  String get oneExpenseEnough;

  /// No description provided for @startSmall.
  ///
  /// In en, this message translates to:
  /// **'Start small, awareness grows.'**
  String get startSmall;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @start.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get start;

  /// No description provided for @whatIsYourDecision.
  ///
  /// In en, this message translates to:
  /// **'What\'s your decision?'**
  String get whatIsYourDecision;

  /// No description provided for @netBalance.
  ///
  /// In en, this message translates to:
  /// **'NET BALANCE'**
  String get netBalance;

  /// No description provided for @sources.
  ///
  /// In en, this message translates to:
  /// **'{count} sources'**
  String sources(int count);

  /// No description provided for @income.
  ///
  /// In en, this message translates to:
  /// **'INCOME'**
  String get income;

  /// No description provided for @expense.
  ///
  /// In en, this message translates to:
  /// **'EXPENSE'**
  String get expense;

  /// No description provided for @saved.
  ///
  /// In en, this message translates to:
  /// **'SAVED'**
  String get saved;

  /// No description provided for @budgetUsage.
  ///
  /// In en, this message translates to:
  /// **'BUDGET USAGE'**
  String get budgetUsage;

  /// No description provided for @startToday.
  ///
  /// In en, this message translates to:
  /// **'Start today!'**
  String get startToday;

  /// No description provided for @dayStreak.
  ///
  /// In en, this message translates to:
  /// **'{count} Day Streak!'**
  String dayStreak(int count);

  /// No description provided for @startStreak.
  ///
  /// In en, this message translates to:
  /// **'Start Your Streak!'**
  String get startStreak;

  /// No description provided for @keepStreakMessage.
  ///
  /// In en, this message translates to:
  /// **'Keep your streak by recording expenses daily!'**
  String get keepStreakMessage;

  /// No description provided for @startStreakMessage.
  ///
  /// In en, this message translates to:
  /// **'Record at least 1 expense daily and build a streak!'**
  String get startStreakMessage;

  /// No description provided for @longestStreak.
  ///
  /// In en, this message translates to:
  /// **'Longest streak: {count} days'**
  String longestStreak(int count);

  /// No description provided for @newRecord.
  ///
  /// In en, this message translates to:
  /// **'New Record!'**
  String get newRecord;

  /// No description provided for @withThisAmount.
  ///
  /// In en, this message translates to:
  /// **'With this {amount} TL you could have bought:'**
  String withThisAmount(String amount);

  /// No description provided for @goldGrams.
  ///
  /// In en, this message translates to:
  /// **'{grams}g gold'**
  String goldGrams(String grams);

  /// No description provided for @ratesLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading rates...'**
  String get ratesLoading;

  /// No description provided for @ratesLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load rates'**
  String get ratesLoadFailed;

  /// No description provided for @goldPriceNotUpdated.
  ///
  /// In en, this message translates to:
  /// **'Gold price could not be updated'**
  String get goldPriceNotUpdated;

  /// No description provided for @monthAbbreviations.
  ///
  /// In en, this message translates to:
  /// **'Jan,Feb,Mar,Apr,May,Jun,Jul,Aug,Sep,Oct,Nov,Dec'**
  String get monthAbbreviations;

  /// No description provided for @updateYourDecision.
  ///
  /// In en, this message translates to:
  /// **'Update your decision'**
  String get updateYourDecision;

  /// No description provided for @simulation.
  ///
  /// In en, this message translates to:
  /// **'Simulation'**
  String get simulation;

  /// No description provided for @tapToUpdate.
  ///
  /// In en, this message translates to:
  /// **'Tap to update'**
  String get tapToUpdate;

  /// No description provided for @swipeToEditOrDelete.
  ///
  /// In en, this message translates to:
  /// **'Swipe to edit or delete'**
  String get swipeToEditOrDelete;

  /// No description provided for @pleaseEnterValidAmount.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid amount'**
  String get pleaseEnterValidAmount;

  /// No description provided for @amountTooHigh.
  ///
  /// In en, this message translates to:
  /// **'Amount seems too high'**
  String get amountTooHigh;

  /// No description provided for @pleaseSelectExpenseGroup.
  ///
  /// In en, this message translates to:
  /// **'Please select expense group first'**
  String get pleaseSelectExpenseGroup;

  /// No description provided for @categorySelectionRequired.
  ///
  /// In en, this message translates to:
  /// **'Category selection is required'**
  String get categorySelectionRequired;

  /// No description provided for @expenseGroup.
  ///
  /// In en, this message translates to:
  /// **'Expense Group'**
  String get expenseGroup;

  /// No description provided for @required.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get required;

  /// No description provided for @detail.
  ///
  /// In en, this message translates to:
  /// **'Detail'**
  String get detail;

  /// No description provided for @optional.
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get optional;

  /// No description provided for @editYourCard.
  ///
  /// In en, this message translates to:
  /// **'Edit Your Card'**
  String get editYourCard;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @youSaved.
  ///
  /// In en, this message translates to:
  /// **'saved!'**
  String get youSaved;

  /// No description provided for @noSavingsYet.
  ///
  /// In en, this message translates to:
  /// **'No savings yet'**
  String get noSavingsYet;

  /// No description provided for @categorySports.
  ///
  /// In en, this message translates to:
  /// **'Sports'**
  String get categorySports;

  /// No description provided for @categoryCommunication.
  ///
  /// In en, this message translates to:
  /// **'Communication'**
  String get categoryCommunication;

  /// No description provided for @subscriptionNameExample.
  ///
  /// In en, this message translates to:
  /// **'e.g: Netflix, Spotify'**
  String get subscriptionNameExample;

  /// No description provided for @monthlyAmountExample.
  ///
  /// In en, this message translates to:
  /// **'e.g: 99.99'**
  String get monthlyAmountExample;

  /// No description provided for @color.
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get color;

  /// No description provided for @autoRecordOnRenewal.
  ///
  /// In en, this message translates to:
  /// **'Record as expense on renewal day'**
  String get autoRecordOnRenewal;

  /// No description provided for @deleteSubscription.
  ///
  /// In en, this message translates to:
  /// **'Delete Subscription'**
  String get deleteSubscription;

  /// No description provided for @deleteSubscriptionConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete {name} subscription?'**
  String deleteSubscriptionConfirm(String name);

  /// No description provided for @subscriptionDuration.
  ///
  /// In en, this message translates to:
  /// **'Subscription Duration'**
  String get subscriptionDuration;

  /// No description provided for @subscriptionDurationDays.
  ///
  /// In en, this message translates to:
  /// **'{days} days'**
  String subscriptionDurationDays(int days);

  /// No description provided for @totalPaid.
  ///
  /// In en, this message translates to:
  /// **'Total Paid'**
  String get totalPaid;

  /// No description provided for @workHoursAmount.
  ///
  /// In en, this message translates to:
  /// **'{hours} hours'**
  String workHoursAmount(String hours);

  /// No description provided for @workDaysAmount.
  ///
  /// In en, this message translates to:
  /// **'{days} days'**
  String workDaysAmount(String days);

  /// No description provided for @autoRecordEnabled.
  ///
  /// In en, this message translates to:
  /// **'Auto expense recording enabled'**
  String get autoRecordEnabled;

  /// No description provided for @autoRecordDisabled.
  ///
  /// In en, this message translates to:
  /// **'Auto expense recording disabled'**
  String get autoRecordDisabled;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// No description provided for @weekdayAbbreviations.
  ///
  /// In en, this message translates to:
  /// **'Mon,Tue,Wed,Thu,Fri,Sat,Sun'**
  String get weekdayAbbreviations;

  /// No description provided for @homePage.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get homePage;

  /// No description provided for @analysis.
  ///
  /// In en, this message translates to:
  /// **'Analysis'**
  String get analysis;

  /// No description provided for @reportsDescription.
  ///
  /// In en, this message translates to:
  /// **'View monthly and category-based expense analysis here.'**
  String get reportsDescription;

  /// No description provided for @quickAdd.
  ///
  /// In en, this message translates to:
  /// **'Quick Add'**
  String get quickAdd;

  /// No description provided for @quickAddDescription.
  ///
  /// In en, this message translates to:
  /// **'Use this button to quickly add expenses from anywhere. Practical and fast!'**
  String get quickAddDescription;

  /// No description provided for @badgesDescription.
  ///
  /// In en, this message translates to:
  /// **'Earn badges as you reach your savings goals. Keep your motivation high!'**
  String get badgesDescription;

  /// No description provided for @profileAndSettings.
  ///
  /// In en, this message translates to:
  /// **'Profile & Settings'**
  String get profileAndSettings;

  /// No description provided for @profileAndSettingsDescription.
  ///
  /// In en, this message translates to:
  /// **'Edit income info, manage notification preferences and access app settings.'**
  String get profileAndSettingsDescription;

  /// No description provided for @addSubscriptionButton.
  ///
  /// In en, this message translates to:
  /// **'Add subscriptions like Netflix, Spotify'**
  String get addSubscriptionButton;

  /// No description provided for @shareError.
  ///
  /// In en, this message translates to:
  /// **'An error occurred while sharing'**
  String get shareError;

  /// No description provided for @pleaseEnterValidSalary.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid salary'**
  String get pleaseEnterValidSalary;

  /// No description provided for @pleaseEnterValidIncomeAmount.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid amount'**
  String get pleaseEnterValidIncomeAmount;

  /// No description provided for @atLeastOneIncomeRequired.
  ///
  /// In en, this message translates to:
  /// **'You must add at least one income source'**
  String get atLeastOneIncomeRequired;

  /// No description provided for @incomesUpdated.
  ///
  /// In en, this message translates to:
  /// **'Incomes updated'**
  String get incomesUpdated;

  /// No description provided for @incomesSaved.
  ///
  /// In en, this message translates to:
  /// **'Incomes saved'**
  String get incomesSaved;

  /// No description provided for @saveError.
  ///
  /// In en, this message translates to:
  /// **'An error occurred while saving'**
  String get saveError;

  /// No description provided for @incomeSourceCount.
  ///
  /// In en, this message translates to:
  /// **'{count} income sources'**
  String incomeSourceCount(int count);

  /// No description provided for @freedTime.
  ///
  /// In en, this message translates to:
  /// **'Freed'**
  String get freedTime;

  /// No description provided for @savedAmountLabel.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get savedAmountLabel;

  /// No description provided for @dayLabel.
  ///
  /// In en, this message translates to:
  /// **'Day'**
  String get dayLabel;

  /// No description provided for @zeroMinutes.
  ///
  /// In en, this message translates to:
  /// **'0 Minutes'**
  String get zeroMinutes;

  /// No description provided for @zeroAmount.
  ///
  /// In en, this message translates to:
  /// **'0 ₺'**
  String get zeroAmount;

  /// No description provided for @shareCardDays.
  ///
  /// In en, this message translates to:
  /// **'{days} DAYS'**
  String shareCardDays(int days);

  /// No description provided for @shareCardDescription.
  ///
  /// In en, this message translates to:
  /// **'I work this many days yearly\njust for {category}'**
  String shareCardDescription(String category);

  /// No description provided for @shareCardQuestion.
  ///
  /// In en, this message translates to:
  /// **'How many days for you?'**
  String get shareCardQuestion;

  /// No description provided for @shareCardDuration.
  ///
  /// In en, this message translates to:
  /// **'Duration ({days} days)'**
  String shareCardDuration(int days);

  /// No description provided for @shareCardAmountLabel.
  ///
  /// In en, this message translates to:
  /// **'Amount (₺{amount})'**
  String shareCardAmountLabel(String amount);

  /// No description provided for @shareCardFrequency.
  ///
  /// In en, this message translates to:
  /// **'Frequency ({frequency})'**
  String shareCardFrequency(String frequency);

  /// No description provided for @unsavedChanges.
  ///
  /// In en, this message translates to:
  /// **'Unsaved Changes'**
  String get unsavedChanges;

  /// No description provided for @unsavedChangesConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to exit without saving?'**
  String get unsavedChangesConfirm;

  /// No description provided for @discardChanges.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get discardChanges;

  /// No description provided for @thinkingTime.
  ///
  /// In en, this message translates to:
  /// **'Thinking time...'**
  String get thinkingTime;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @riskLevelNone.
  ///
  /// In en, this message translates to:
  /// **'Safe'**
  String get riskLevelNone;

  /// No description provided for @riskLevelLow.
  ///
  /// In en, this message translates to:
  /// **'Low Risk'**
  String get riskLevelLow;

  /// No description provided for @riskLevelMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium Risk'**
  String get riskLevelMedium;

  /// No description provided for @riskLevelHigh.
  ///
  /// In en, this message translates to:
  /// **'High Risk'**
  String get riskLevelHigh;

  /// No description provided for @riskLevelExtreme.
  ///
  /// In en, this message translates to:
  /// **'Critical Risk'**
  String get riskLevelExtreme;

  /// No description provided for @savedTimeHoursDays.
  ///
  /// In en, this message translates to:
  /// **'{hours} hours = {days} days saved'**
  String savedTimeHoursDays(String hours, String days);

  /// No description provided for @savedTimeHours.
  ///
  /// In en, this message translates to:
  /// **'{hours} hours saved'**
  String savedTimeHours(String hours);

  /// No description provided for @savedTimeMinutes.
  ///
  /// In en, this message translates to:
  /// **'{minutes} minutes saved'**
  String savedTimeMinutes(int minutes);

  /// No description provided for @couldBuyGoldGrams.
  ///
  /// In en, this message translates to:
  /// **'With this money you could buy {grams} grams of gold'**
  String couldBuyGoldGrams(String grams);

  /// No description provided for @equivalentWorkDays.
  ///
  /// In en, this message translates to:
  /// **'This equals {days} days of work'**
  String equivalentWorkDays(String days);

  /// No description provided for @equivalentWorkHours.
  ///
  /// In en, this message translates to:
  /// **'This equals {hours} hours of work'**
  String equivalentWorkHours(String hours);

  /// No description provided for @savedDollars.
  ///
  /// In en, this message translates to:
  /// **'You saved exactly {amount} dollars'**
  String savedDollars(String amount);

  /// No description provided for @or.
  ///
  /// In en, this message translates to:
  /// **'OR'**
  String get or;

  /// No description provided for @goldGramsShort.
  ///
  /// In en, this message translates to:
  /// **'{grams}g gold'**
  String goldGramsShort(String grams);

  /// No description provided for @amountRequired.
  ///
  /// In en, this message translates to:
  /// **'Amount is required'**
  String get amountRequired;

  /// No description provided for @everyMonth.
  ///
  /// In en, this message translates to:
  /// **'Every month'**
  String get everyMonth;

  /// No description provided for @daysCount.
  ///
  /// In en, this message translates to:
  /// **'{count} days'**
  String daysCount(int count);

  /// No description provided for @hoursCount.
  ///
  /// In en, this message translates to:
  /// **'{count} hours'**
  String hoursCount(String count);

  /// No description provided for @daysCountDecimal.
  ///
  /// In en, this message translates to:
  /// **'{count} days'**
  String daysCountDecimal(String count);

  /// No description provided for @autoRecordOn.
  ///
  /// In en, this message translates to:
  /// **'Auto record enabled'**
  String get autoRecordOn;

  /// No description provided for @autoRecordOff.
  ///
  /// In en, this message translates to:
  /// **'Auto record disabled'**
  String get autoRecordOff;

  /// No description provided for @monthlyAmountTl.
  ///
  /// In en, this message translates to:
  /// **'{amount} TL/month'**
  String monthlyAmountTl(String amount);

  /// No description provided for @nameRequired.
  ///
  /// In en, this message translates to:
  /// **'Name is required'**
  String get nameRequired;

  /// No description provided for @amountHint.
  ///
  /// In en, this message translates to:
  /// **'e.g: 99.99'**
  String get amountHint;

  /// No description provided for @updateDecision.
  ///
  /// In en, this message translates to:
  /// **'Update your decision'**
  String get updateDecision;

  /// No description provided for @categoryRequired.
  ///
  /// In en, this message translates to:
  /// **'Category is required'**
  String get categoryRequired;

  /// No description provided for @monthlyAmountLabel.
  ///
  /// In en, this message translates to:
  /// **'Monthly Amount (TL)'**
  String get monthlyAmountLabel;

  /// No description provided for @withThisAmountYouCouldBuy.
  ///
  /// In en, this message translates to:
  /// **'With {amount} TL you could buy:'**
  String withThisAmountYouCouldBuy(String amount);

  /// No description provided for @workHoursDistribution.
  ///
  /// In en, this message translates to:
  /// **'Work Hours Distribution'**
  String get workHoursDistribution;

  /// No description provided for @workHoursDistributionDesc.
  ///
  /// In en, this message translates to:
  /// **'See how many hours you work for each category'**
  String get workHoursDistributionDesc;

  /// No description provided for @hoursShort.
  ///
  /// In en, this message translates to:
  /// **'{hours}h'**
  String hoursShort(String hours);

  /// No description provided for @categoryHoursBar.
  ///
  /// In en, this message translates to:
  /// **'{hours} hours ({percent}%)'**
  String categoryHoursBar(String hours, String percent);

  /// No description provided for @monthComparison.
  ///
  /// In en, this message translates to:
  /// **'Month Comparison'**
  String get monthComparison;

  /// No description provided for @vsLastMonth.
  ///
  /// In en, this message translates to:
  /// **'vs Last Month'**
  String get vsLastMonth;

  /// No description provided for @noLastMonthData.
  ///
  /// In en, this message translates to:
  /// **'No last month data'**
  String get noLastMonthData;

  /// No description provided for @decreasedBy.
  ///
  /// In en, this message translates to:
  /// **'↓ {percent}% decreased'**
  String decreasedBy(String percent);

  /// No description provided for @increasedBy.
  ///
  /// In en, this message translates to:
  /// **'↑ {percent}% increased'**
  String increasedBy(String percent);

  /// No description provided for @noChange.
  ///
  /// In en, this message translates to:
  /// **'No change'**
  String get noChange;

  /// No description provided for @greatProgress.
  ///
  /// In en, this message translates to:
  /// **'Great progress!'**
  String get greatProgress;

  /// No description provided for @watchOut.
  ///
  /// In en, this message translates to:
  /// **'Watch out!'**
  String get watchOut;

  /// No description provided for @smartInsights.
  ///
  /// In en, this message translates to:
  /// **'Smart Insights'**
  String get smartInsights;

  /// No description provided for @mostExpensiveDay.
  ///
  /// In en, this message translates to:
  /// **'Most Expensive Day'**
  String get mostExpensiveDay;

  /// No description provided for @mostExpensiveDayValue.
  ///
  /// In en, this message translates to:
  /// **'{day} (avg. {amount} TL)'**
  String mostExpensiveDayValue(String day, String amount);

  /// No description provided for @mostPassedCategory.
  ///
  /// In en, this message translates to:
  /// **'Most Passed Category'**
  String get mostPassedCategory;

  /// No description provided for @mostPassedCategoryValue.
  ///
  /// In en, this message translates to:
  /// **'{category} ({count} times)'**
  String mostPassedCategoryValue(String category, int count);

  /// No description provided for @savingsOpportunity.
  ///
  /// In en, this message translates to:
  /// **'Savings Opportunity'**
  String get savingsOpportunity;

  /// No description provided for @savingsOpportunityValue.
  ///
  /// In en, this message translates to:
  /// **'Cut {category} by 20% = {hours}h saved/month'**
  String savingsOpportunityValue(String category, String hours);

  /// No description provided for @weeklyTrend.
  ///
  /// In en, this message translates to:
  /// **'Weekly Trend'**
  String get weeklyTrend;

  /// No description provided for @weeklyTrendValue.
  ///
  /// In en, this message translates to:
  /// **'Last 4 weeks: {trend}'**
  String weeklyTrendValue(String trend);

  /// No description provided for @overallDecreasing.
  ///
  /// In en, this message translates to:
  /// **'Overall decreasing'**
  String get overallDecreasing;

  /// No description provided for @overallIncreasing.
  ///
  /// In en, this message translates to:
  /// **'Overall increasing'**
  String get overallIncreasing;

  /// No description provided for @stableTrend.
  ///
  /// In en, this message translates to:
  /// **'Stable'**
  String get stableTrend;

  /// No description provided for @noTrendData.
  ///
  /// In en, this message translates to:
  /// **'Not enough data'**
  String get noTrendData;

  /// No description provided for @yearlyView.
  ///
  /// In en, this message translates to:
  /// **'Yearly View'**
  String get yearlyView;

  /// No description provided for @yearlyHeatmap.
  ///
  /// In en, this message translates to:
  /// **'Expense Heatmap'**
  String get yearlyHeatmap;

  /// No description provided for @yearlyHeatmapDesc.
  ///
  /// In en, this message translates to:
  /// **'Your spending intensity throughout the year'**
  String get yearlyHeatmapDesc;

  /// No description provided for @lowSpending.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get lowSpending;

  /// No description provided for @highSpending.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get highSpending;

  /// No description provided for @noSpending.
  ///
  /// In en, this message translates to:
  /// **'No spending'**
  String get noSpending;

  /// No description provided for @tapDayForDetails.
  ///
  /// In en, this message translates to:
  /// **'Tap a day for details'**
  String get tapDayForDetails;

  /// No description provided for @selectedDayExpenses.
  ///
  /// In en, this message translates to:
  /// **'{date}: {amount} TL ({count} expenses)'**
  String selectedDayExpenses(String date, String amount, int count);

  /// No description provided for @proBadge.
  ///
  /// In en, this message translates to:
  /// **'PRO'**
  String get proBadge;

  /// No description provided for @proFeature.
  ///
  /// In en, this message translates to:
  /// **'Pro Feature'**
  String get proFeature;

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming Soon'**
  String get comingSoon;

  /// No description provided for @mindfulChoice.
  ///
  /// In en, this message translates to:
  /// **'Mindful Choice'**
  String get mindfulChoice;

  /// No description provided for @mindfulChoiceExpandedDesc.
  ///
  /// In en, this message translates to:
  /// **'What were you originally planning to buy?'**
  String get mindfulChoiceExpandedDesc;

  /// No description provided for @mindfulChoiceCollapsedDesc.
  ///
  /// In en, this message translates to:
  /// **'Were you going to buy something more expensive?'**
  String get mindfulChoiceCollapsedDesc;

  /// No description provided for @mindfulChoiceAmountLabel.
  ///
  /// In en, this message translates to:
  /// **'Amount in Mind (₺)'**
  String get mindfulChoiceAmountLabel;

  /// No description provided for @mindfulChoiceAmountHint.
  ///
  /// In en, this message translates to:
  /// **'e.g: {amount}'**
  String mindfulChoiceAmountHint(String amount);

  /// No description provided for @mindfulChoiceSavings.
  ///
  /// In en, this message translates to:
  /// **'{amount} TL savings'**
  String mindfulChoiceSavings(String amount);

  /// No description provided for @mindfulChoiceSavingsDesc.
  ///
  /// In en, this message translates to:
  /// **'Stays in your pocket with mindful choice'**
  String get mindfulChoiceSavingsDesc;

  /// No description provided for @tierBronze.
  ///
  /// In en, this message translates to:
  /// **'Bronze'**
  String get tierBronze;

  /// No description provided for @tierSilver.
  ///
  /// In en, this message translates to:
  /// **'Silver'**
  String get tierSilver;

  /// No description provided for @tierGold.
  ///
  /// In en, this message translates to:
  /// **'Gold'**
  String get tierGold;

  /// No description provided for @tierPlatinum.
  ///
  /// In en, this message translates to:
  /// **'Platinum'**
  String get tierPlatinum;

  /// No description provided for @achievementCategoryStreak.
  ///
  /// In en, this message translates to:
  /// **'Streak'**
  String get achievementCategoryStreak;

  /// No description provided for @achievementCategorySavings.
  ///
  /// In en, this message translates to:
  /// **'Savings'**
  String get achievementCategorySavings;

  /// No description provided for @achievementCategoryDecision.
  ///
  /// In en, this message translates to:
  /// **'Decision'**
  String get achievementCategoryDecision;

  /// No description provided for @achievementCategoryRecord.
  ///
  /// In en, this message translates to:
  /// **'Record'**
  String get achievementCategoryRecord;

  /// No description provided for @achievementCategoryHidden.
  ///
  /// In en, this message translates to:
  /// **'Hidden'**
  String get achievementCategoryHidden;

  /// No description provided for @achievementStreakB1Title.
  ///
  /// In en, this message translates to:
  /// **'Getting Started'**
  String get achievementStreakB1Title;

  /// No description provided for @achievementStreakB1Desc.
  ///
  /// In en, this message translates to:
  /// **'Record for 3 days in a row'**
  String get achievementStreakB1Desc;

  /// No description provided for @achievementStreakB2Title.
  ///
  /// In en, this message translates to:
  /// **'Keeping Going'**
  String get achievementStreakB2Title;

  /// No description provided for @achievementStreakB2Desc.
  ///
  /// In en, this message translates to:
  /// **'Record for 7 days in a row'**
  String get achievementStreakB2Desc;

  /// No description provided for @achievementStreakB3Title.
  ///
  /// In en, this message translates to:
  /// **'Building Routine'**
  String get achievementStreakB3Title;

  /// No description provided for @achievementStreakB3Desc.
  ///
  /// In en, this message translates to:
  /// **'Record for 14 days in a row'**
  String get achievementStreakB3Desc;

  /// No description provided for @achievementStreakS1Title.
  ///
  /// In en, this message translates to:
  /// **'Determination'**
  String get achievementStreakS1Title;

  /// No description provided for @achievementStreakS1Desc.
  ///
  /// In en, this message translates to:
  /// **'Record for 30 days in a row'**
  String get achievementStreakS1Desc;

  /// No description provided for @achievementStreakS2Title.
  ///
  /// In en, this message translates to:
  /// **'Habit'**
  String get achievementStreakS2Title;

  /// No description provided for @achievementStreakS2Desc.
  ///
  /// In en, this message translates to:
  /// **'Record for 60 days in a row'**
  String get achievementStreakS2Desc;

  /// No description provided for @achievementStreakS3Title.
  ///
  /// In en, this message translates to:
  /// **'Discipline'**
  String get achievementStreakS3Title;

  /// No description provided for @achievementStreakS3Desc.
  ///
  /// In en, this message translates to:
  /// **'Record for 90 days in a row'**
  String get achievementStreakS3Desc;

  /// No description provided for @achievementStreakG1Title.
  ///
  /// In en, this message translates to:
  /// **'Strong Will'**
  String get achievementStreakG1Title;

  /// No description provided for @achievementStreakG1Desc.
  ///
  /// In en, this message translates to:
  /// **'Record for 150 days in a row'**
  String get achievementStreakG1Desc;

  /// No description provided for @achievementStreakG2Title.
  ///
  /// In en, this message translates to:
  /// **'Unshakeable'**
  String get achievementStreakG2Title;

  /// No description provided for @achievementStreakG2Desc.
  ///
  /// In en, this message translates to:
  /// **'Record for 250 days in a row'**
  String get achievementStreakG2Desc;

  /// No description provided for @achievementStreakG3Title.
  ///
  /// In en, this message translates to:
  /// **'Consistency'**
  String get achievementStreakG3Title;

  /// No description provided for @achievementStreakG3Desc.
  ///
  /// In en, this message translates to:
  /// **'Record for 365 days in a row'**
  String get achievementStreakG3Desc;

  /// No description provided for @achievementStreakPTitle.
  ///
  /// In en, this message translates to:
  /// **'Persistence'**
  String get achievementStreakPTitle;

  /// No description provided for @achievementStreakPDesc.
  ///
  /// In en, this message translates to:
  /// **'Record for 730 days in a row'**
  String get achievementStreakPDesc;

  /// No description provided for @achievementSavingsB1Title.
  ///
  /// In en, this message translates to:
  /// **'First Savings'**
  String get achievementSavingsB1Title;

  /// No description provided for @achievementSavingsB1Desc.
  ///
  /// In en, this message translates to:
  /// **'Saved 250 TL'**
  String get achievementSavingsB1Desc;

  /// No description provided for @achievementSavingsB2Title.
  ///
  /// In en, this message translates to:
  /// **'Starting to Save'**
  String get achievementSavingsB2Title;

  /// No description provided for @achievementSavingsB2Desc.
  ///
  /// In en, this message translates to:
  /// **'Saved 500 TL'**
  String get achievementSavingsB2Desc;

  /// No description provided for @achievementSavingsB3Title.
  ///
  /// In en, this message translates to:
  /// **'On the Right Path'**
  String get achievementSavingsB3Title;

  /// No description provided for @achievementSavingsB3Desc.
  ///
  /// In en, this message translates to:
  /// **'Saved 1,000 TL'**
  String get achievementSavingsB3Desc;

  /// No description provided for @achievementSavingsS1Title.
  ///
  /// In en, this message translates to:
  /// **'Mindful Spending'**
  String get achievementSavingsS1Title;

  /// No description provided for @achievementSavingsS1Desc.
  ///
  /// In en, this message translates to:
  /// **'Saved 2,500 TL'**
  String get achievementSavingsS1Desc;

  /// No description provided for @achievementSavingsS2Title.
  ///
  /// In en, this message translates to:
  /// **'In Control'**
  String get achievementSavingsS2Title;

  /// No description provided for @achievementSavingsS2Desc.
  ///
  /// In en, this message translates to:
  /// **'Saved 5,000 TL'**
  String get achievementSavingsS2Desc;

  /// No description provided for @achievementSavingsS3Title.
  ///
  /// In en, this message translates to:
  /// **'Consistent'**
  String get achievementSavingsS3Title;

  /// No description provided for @achievementSavingsS3Desc.
  ///
  /// In en, this message translates to:
  /// **'Saved 10,000 TL'**
  String get achievementSavingsS3Desc;

  /// No description provided for @achievementSavingsG1Title.
  ///
  /// In en, this message translates to:
  /// **'Strong Savings'**
  String get achievementSavingsG1Title;

  /// No description provided for @achievementSavingsG1Desc.
  ///
  /// In en, this message translates to:
  /// **'Saved 25,000 TL'**
  String get achievementSavingsG1Desc;

  /// No description provided for @achievementSavingsG2Title.
  ///
  /// In en, this message translates to:
  /// **'Financial Awareness'**
  String get achievementSavingsG2Title;

  /// No description provided for @achievementSavingsG2Desc.
  ///
  /// In en, this message translates to:
  /// **'Saved 50,000 TL'**
  String get achievementSavingsG2Desc;

  /// No description provided for @achievementSavingsG3Title.
  ///
  /// In en, this message translates to:
  /// **'Solid Foundation'**
  String get achievementSavingsG3Title;

  /// No description provided for @achievementSavingsG3Desc.
  ///
  /// In en, this message translates to:
  /// **'Saved 100,000 TL'**
  String get achievementSavingsG3Desc;

  /// No description provided for @achievementSavingsP1Title.
  ///
  /// In en, this message translates to:
  /// **'Long-term Thinking'**
  String get achievementSavingsP1Title;

  /// No description provided for @achievementSavingsP1Desc.
  ///
  /// In en, this message translates to:
  /// **'Saved 250,000 TL'**
  String get achievementSavingsP1Desc;

  /// No description provided for @achievementSavingsP2Title.
  ///
  /// In en, this message translates to:
  /// **'Financial Clarity'**
  String get achievementSavingsP2Title;

  /// No description provided for @achievementSavingsP2Desc.
  ///
  /// In en, this message translates to:
  /// **'Saved 500,000 TL'**
  String get achievementSavingsP2Desc;

  /// No description provided for @achievementSavingsP3Title.
  ///
  /// In en, this message translates to:
  /// **'Big Picture'**
  String get achievementSavingsP3Title;

  /// No description provided for @achievementSavingsP3Desc.
  ///
  /// In en, this message translates to:
  /// **'Saved 1,000,000 TL'**
  String get achievementSavingsP3Desc;

  /// No description provided for @achievementDecisionB1Title.
  ///
  /// In en, this message translates to:
  /// **'First Decision'**
  String get achievementDecisionB1Title;

  /// No description provided for @achievementDecisionB1Desc.
  ///
  /// In en, this message translates to:
  /// **'Passed 3 times'**
  String get achievementDecisionB1Desc;

  /// No description provided for @achievementDecisionB2Title.
  ///
  /// In en, this message translates to:
  /// **'Resistance'**
  String get achievementDecisionB2Title;

  /// No description provided for @achievementDecisionB2Desc.
  ///
  /// In en, this message translates to:
  /// **'Passed 7 times'**
  String get achievementDecisionB2Desc;

  /// No description provided for @achievementDecisionB3Title.
  ///
  /// In en, this message translates to:
  /// **'Control'**
  String get achievementDecisionB3Title;

  /// No description provided for @achievementDecisionB3Desc.
  ///
  /// In en, this message translates to:
  /// **'Passed 15 times'**
  String get achievementDecisionB3Desc;

  /// No description provided for @achievementDecisionS1Title.
  ///
  /// In en, this message translates to:
  /// **'Determination'**
  String get achievementDecisionS1Title;

  /// No description provided for @achievementDecisionS1Desc.
  ///
  /// In en, this message translates to:
  /// **'Passed 30 times'**
  String get achievementDecisionS1Desc;

  /// No description provided for @achievementDecisionS2Title.
  ///
  /// In en, this message translates to:
  /// **'Clarity'**
  String get achievementDecisionS2Title;

  /// No description provided for @achievementDecisionS2Desc.
  ///
  /// In en, this message translates to:
  /// **'Passed 60 times'**
  String get achievementDecisionS2Desc;

  /// No description provided for @achievementDecisionS3Title.
  ///
  /// In en, this message translates to:
  /// **'Strong Choices'**
  String get achievementDecisionS3Title;

  /// No description provided for @achievementDecisionS3Desc.
  ///
  /// In en, this message translates to:
  /// **'Passed 100 times'**
  String get achievementDecisionS3Desc;

  /// No description provided for @achievementDecisionG1Title.
  ///
  /// In en, this message translates to:
  /// **'Willpower'**
  String get achievementDecisionG1Title;

  /// No description provided for @achievementDecisionG1Desc.
  ///
  /// In en, this message translates to:
  /// **'Passed 200 times'**
  String get achievementDecisionG1Desc;

  /// No description provided for @achievementDecisionG2Title.
  ///
  /// In en, this message translates to:
  /// **'Composure'**
  String get achievementDecisionG2Title;

  /// No description provided for @achievementDecisionG2Desc.
  ///
  /// In en, this message translates to:
  /// **'Passed 400 times'**
  String get achievementDecisionG2Desc;

  /// No description provided for @achievementDecisionG3Title.
  ///
  /// In en, this message translates to:
  /// **'Top Level Control'**
  String get achievementDecisionG3Title;

  /// No description provided for @achievementDecisionG3Desc.
  ///
  /// In en, this message translates to:
  /// **'Passed 700 times'**
  String get achievementDecisionG3Desc;

  /// No description provided for @achievementDecisionPTitle.
  ///
  /// In en, this message translates to:
  /// **'Total Mastery'**
  String get achievementDecisionPTitle;

  /// No description provided for @achievementDecisionPDesc.
  ///
  /// In en, this message translates to:
  /// **'Passed 1,000 times'**
  String get achievementDecisionPDesc;

  /// No description provided for @achievementRecordB1Title.
  ///
  /// In en, this message translates to:
  /// **'Started'**
  String get achievementRecordB1Title;

  /// No description provided for @achievementRecordB1Desc.
  ///
  /// In en, this message translates to:
  /// **'5 expense records'**
  String get achievementRecordB1Desc;

  /// No description provided for @achievementRecordB2Title.
  ///
  /// In en, this message translates to:
  /// **'Tracking'**
  String get achievementRecordB2Title;

  /// No description provided for @achievementRecordB2Desc.
  ///
  /// In en, this message translates to:
  /// **'15 expense records'**
  String get achievementRecordB2Desc;

  /// No description provided for @achievementRecordB3Title.
  ///
  /// In en, this message translates to:
  /// **'Organized'**
  String get achievementRecordB3Title;

  /// No description provided for @achievementRecordB3Desc.
  ///
  /// In en, this message translates to:
  /// **'30 expense records'**
  String get achievementRecordB3Desc;

  /// No description provided for @achievementRecordS1Title.
  ///
  /// In en, this message translates to:
  /// **'Detailed Tracking'**
  String get achievementRecordS1Title;

  /// No description provided for @achievementRecordS1Desc.
  ///
  /// In en, this message translates to:
  /// **'60 expense records'**
  String get achievementRecordS1Desc;

  /// No description provided for @achievementRecordS2Title.
  ///
  /// In en, this message translates to:
  /// **'Analytical'**
  String get achievementRecordS2Title;

  /// No description provided for @achievementRecordS2Desc.
  ///
  /// In en, this message translates to:
  /// **'120 expense records'**
  String get achievementRecordS2Desc;

  /// No description provided for @achievementRecordS3Title.
  ///
  /// In en, this message translates to:
  /// **'Systematic'**
  String get achievementRecordS3Title;

  /// No description provided for @achievementRecordS3Desc.
  ///
  /// In en, this message translates to:
  /// **'200 expense records'**
  String get achievementRecordS3Desc;

  /// No description provided for @achievementRecordG1Title.
  ///
  /// In en, this message translates to:
  /// **'Depth'**
  String get achievementRecordG1Title;

  /// No description provided for @achievementRecordG1Desc.
  ///
  /// In en, this message translates to:
  /// **'350 expense records'**
  String get achievementRecordG1Desc;

  /// No description provided for @achievementRecordG2Title.
  ///
  /// In en, this message translates to:
  /// **'Mastery'**
  String get achievementRecordG2Title;

  /// No description provided for @achievementRecordG2Desc.
  ///
  /// In en, this message translates to:
  /// **'600 expense records'**
  String get achievementRecordG2Desc;

  /// No description provided for @achievementRecordG3Title.
  ///
  /// In en, this message translates to:
  /// **'Archive'**
  String get achievementRecordG3Title;

  /// No description provided for @achievementRecordG3Desc.
  ///
  /// In en, this message translates to:
  /// **'1,000 expense records'**
  String get achievementRecordG3Desc;

  /// No description provided for @achievementRecordPTitle.
  ///
  /// In en, this message translates to:
  /// **'Long-term Record'**
  String get achievementRecordPTitle;

  /// No description provided for @achievementRecordPDesc.
  ///
  /// In en, this message translates to:
  /// **'2,000 expense records'**
  String get achievementRecordPDesc;

  /// No description provided for @achievementHiddenNightTitle.
  ///
  /// In en, this message translates to:
  /// **'Night Record'**
  String get achievementHiddenNightTitle;

  /// No description provided for @achievementHiddenNightDesc.
  ///
  /// In en, this message translates to:
  /// **'Record between 00:00-05:00'**
  String get achievementHiddenNightDesc;

  /// No description provided for @achievementHiddenEarlyTitle.
  ///
  /// In en, this message translates to:
  /// **'Early Bird'**
  String get achievementHiddenEarlyTitle;

  /// No description provided for @achievementHiddenEarlyDesc.
  ///
  /// In en, this message translates to:
  /// **'Record between 05:00-07:00'**
  String get achievementHiddenEarlyDesc;

  /// No description provided for @achievementHiddenWeekendTitle.
  ///
  /// In en, this message translates to:
  /// **'Weekend Routine'**
  String get achievementHiddenWeekendTitle;

  /// No description provided for @achievementHiddenWeekendDesc.
  ///
  /// In en, this message translates to:
  /// **'5 records on Saturday-Sunday'**
  String get achievementHiddenWeekendDesc;

  /// No description provided for @achievementHiddenOcrTitle.
  ///
  /// In en, this message translates to:
  /// **'First Scan'**
  String get achievementHiddenOcrTitle;

  /// No description provided for @achievementHiddenOcrDesc.
  ///
  /// In en, this message translates to:
  /// **'First receipt OCR usage'**
  String get achievementHiddenOcrDesc;

  /// No description provided for @achievementHiddenBalancedTitle.
  ///
  /// In en, this message translates to:
  /// **'Balanced Week'**
  String get achievementHiddenBalancedTitle;

  /// No description provided for @achievementHiddenBalancedDesc.
  ///
  /// In en, this message translates to:
  /// **'7 days in a row with 0 \"Bought\"'**
  String get achievementHiddenBalancedDesc;

  /// No description provided for @achievementHiddenCategoriesTitle.
  ///
  /// In en, this message translates to:
  /// **'Category Completion'**
  String get achievementHiddenCategoriesTitle;

  /// No description provided for @achievementHiddenCategoriesDesc.
  ///
  /// In en, this message translates to:
  /// **'Record in all 6 categories'**
  String get achievementHiddenCategoriesDesc;

  /// No description provided for @achievementHiddenGoldTitle.
  ///
  /// In en, this message translates to:
  /// **'Gold Equivalent'**
  String get achievementHiddenGoldTitle;

  /// No description provided for @achievementHiddenGoldDesc.
  ///
  /// In en, this message translates to:
  /// **'Saved money equals 1 gram of gold'**
  String get achievementHiddenGoldDesc;

  /// No description provided for @achievementHiddenUsdTitle.
  ///
  /// In en, this message translates to:
  /// **'Currency Equivalent'**
  String get achievementHiddenUsdTitle;

  /// No description provided for @achievementHiddenUsdDesc.
  ///
  /// In en, this message translates to:
  /// **'Saved money equals \$100'**
  String get achievementHiddenUsdDesc;

  /// No description provided for @achievementHiddenSubsTitle.
  ///
  /// In en, this message translates to:
  /// **'Subscription Control'**
  String get achievementHiddenSubsTitle;

  /// No description provided for @achievementHiddenSubsDesc.
  ///
  /// In en, this message translates to:
  /// **'Track 5 subscriptions'**
  String get achievementHiddenSubsDesc;

  /// No description provided for @achievementHiddenNoSpendTitle.
  ///
  /// In en, this message translates to:
  /// **'No-Spend Month'**
  String get achievementHiddenNoSpendTitle;

  /// No description provided for @achievementHiddenNoSpendDesc.
  ///
  /// In en, this message translates to:
  /// **'0 \"Bought\" for 1 month'**
  String get achievementHiddenNoSpendDesc;

  /// No description provided for @achievementHiddenGoldKgTitle.
  ///
  /// In en, this message translates to:
  /// **'High Value Savings'**
  String get achievementHiddenGoldKgTitle;

  /// No description provided for @achievementHiddenGoldKgDesc.
  ///
  /// In en, this message translates to:
  /// **'Saved money equals 1 kg of gold'**
  String get achievementHiddenGoldKgDesc;

  /// No description provided for @achievementHiddenUsd10kTitle.
  ///
  /// In en, this message translates to:
  /// **'Major Currency Equivalent'**
  String get achievementHiddenUsd10kTitle;

  /// No description provided for @achievementHiddenUsd10kDesc.
  ///
  /// In en, this message translates to:
  /// **'Saved money equals \$10,000'**
  String get achievementHiddenUsd10kDesc;

  /// No description provided for @achievementHiddenAnniversaryTitle.
  ///
  /// In en, this message translates to:
  /// **'Usage Anniversary'**
  String get achievementHiddenAnniversaryTitle;

  /// No description provided for @achievementHiddenAnniversaryDesc.
  ///
  /// In en, this message translates to:
  /// **'365 days of usage'**
  String get achievementHiddenAnniversaryDesc;

  /// No description provided for @achievementHiddenEarlyAdopterTitle.
  ///
  /// In en, this message translates to:
  /// **'Early Adopter'**
  String get achievementHiddenEarlyAdopterTitle;

  /// No description provided for @achievementHiddenEarlyAdopterDesc.
  ///
  /// In en, this message translates to:
  /// **'Installed the app 2 years ago'**
  String get achievementHiddenEarlyAdopterDesc;

  /// No description provided for @achievementHiddenUltimateTitle.
  ///
  /// In en, this message translates to:
  /// **'Long-term Discipline'**
  String get achievementHiddenUltimateTitle;

  /// No description provided for @achievementHiddenUltimateDesc.
  ///
  /// In en, this message translates to:
  /// **'1,000,000 TL + 365 day streak at once'**
  String get achievementHiddenUltimateDesc;

  /// No description provided for @achievementHiddenCollectorTitle.
  ///
  /// In en, this message translates to:
  /// **'Collector'**
  String get achievementHiddenCollectorTitle;

  /// No description provided for @achievementHiddenCollectorDesc.
  ///
  /// In en, this message translates to:
  /// **'Collected all badges except Platinum'**
  String get achievementHiddenCollectorDesc;

  /// No description provided for @easterEgg5Left.
  ///
  /// In en, this message translates to:
  /// **'5 more...'**
  String get easterEgg5Left;

  /// No description provided for @easterEggAlmost.
  ///
  /// In en, this message translates to:
  /// **'Almost...'**
  String get easterEggAlmost;

  /// No description provided for @achievementUnlocked.
  ///
  /// In en, this message translates to:
  /// **'Achievement Unlocked!'**
  String get achievementUnlocked;

  /// No description provided for @curiousCatTitle.
  ///
  /// In en, this message translates to:
  /// **'Too Curious'**
  String get curiousCatTitle;

  /// No description provided for @curiousCatDescription.
  ///
  /// In en, this message translates to:
  /// **'You found the hidden Easter Egg!'**
  String get curiousCatDescription;

  /// No description provided for @great.
  ///
  /// In en, this message translates to:
  /// **'Great!'**
  String get great;

  /// No description provided for @achievementHiddenCuriousCatTitle.
  ///
  /// In en, this message translates to:
  /// **'Too Curious'**
  String get achievementHiddenCuriousCatTitle;

  /// No description provided for @achievementHiddenCuriousCatDesc.
  ///
  /// In en, this message translates to:
  /// **'You found the hidden Easter Egg!'**
  String get achievementHiddenCuriousCatDesc;

  /// No description provided for @recentExpenses.
  ///
  /// In en, this message translates to:
  /// **'Recent Expenses'**
  String get recentExpenses;

  /// No description provided for @seeMore.
  ///
  /// In en, this message translates to:
  /// **'See More'**
  String get seeMore;

  /// No description provided for @tapPlusToAdd.
  ///
  /// In en, this message translates to:
  /// **'Tap + to add your first expense'**
  String get tapPlusToAdd;

  /// No description provided for @expenseAdded.
  ///
  /// In en, this message translates to:
  /// **'Expense added successfully'**
  String get expenseAdded;

  /// No description provided for @duplicateExpenseWarning.
  ///
  /// In en, this message translates to:
  /// **'This expense already seems to exist'**
  String get duplicateExpenseWarning;

  /// No description provided for @duplicateExpenseDetails.
  ///
  /// In en, this message translates to:
  /// **'{amount} {category}'**
  String duplicateExpenseDetails(String amount, String category);

  /// No description provided for @addAnyway.
  ///
  /// In en, this message translates to:
  /// **'Do you still want to add it?'**
  String get addAnyway;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @timeAgoNow.
  ///
  /// In en, this message translates to:
  /// **'just now'**
  String get timeAgoNow;

  /// No description provided for @timeAgoMinutes.
  ///
  /// In en, this message translates to:
  /// **'{count} minutes ago'**
  String timeAgoMinutes(int count);

  /// No description provided for @timeAgoHours.
  ///
  /// In en, this message translates to:
  /// **'{count} hours ago'**
  String timeAgoHours(int count);

  /// No description provided for @timeAgoDays.
  ///
  /// In en, this message translates to:
  /// **'{count} days ago'**
  String timeAgoDays(int count);

  /// No description provided for @exportToExcel.
  ///
  /// In en, this message translates to:
  /// **'Export to Excel'**
  String get exportToExcel;

  /// No description provided for @exportReport.
  ///
  /// In en, this message translates to:
  /// **'Export Report'**
  String get exportReport;

  /// No description provided for @exporting.
  ///
  /// In en, this message translates to:
  /// **'Exporting...'**
  String get exporting;

  /// No description provided for @exportSuccess.
  ///
  /// In en, this message translates to:
  /// **'Report exported successfully'**
  String get exportSuccess;

  /// No description provided for @exportError.
  ///
  /// In en, this message translates to:
  /// **'Export failed'**
  String get exportError;

  /// No description provided for @financialReport.
  ///
  /// In en, this message translates to:
  /// **'Financial Summary Report'**
  String get financialReport;

  /// No description provided for @createdAt.
  ///
  /// In en, this message translates to:
  /// **'Created'**
  String get createdAt;

  /// No description provided for @savingsRate.
  ///
  /// In en, this message translates to:
  /// **'Savings Rate'**
  String get savingsRate;

  /// No description provided for @hourlyRate.
  ///
  /// In en, this message translates to:
  /// **'Hourly Rate'**
  String get hourlyRate;

  /// No description provided for @workHoursEquivalent.
  ///
  /// In en, this message translates to:
  /// **'Work Hours Equivalent'**
  String get workHoursEquivalent;

  /// No description provided for @transactionCount.
  ///
  /// In en, this message translates to:
  /// **'Transaction Count'**
  String get transactionCount;

  /// No description provided for @average.
  ///
  /// In en, this message translates to:
  /// **'Average'**
  String get average;

  /// No description provided for @percentage.
  ///
  /// In en, this message translates to:
  /// **'Percentage'**
  String get percentage;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @monthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get monthly;

  /// No description provided for @yearly.
  ///
  /// In en, this message translates to:
  /// **'Yearly'**
  String get yearly;

  /// No description provided for @changePercent.
  ///
  /// In en, this message translates to:
  /// **'Change %'**
  String get changePercent;

  /// No description provided for @month.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get month;

  /// No description provided for @originalAmount.
  ///
  /// In en, this message translates to:
  /// **'Original Amount'**
  String get originalAmount;

  /// No description provided for @nextRenewal.
  ///
  /// In en, this message translates to:
  /// **'Next Renewal'**
  String get nextRenewal;

  /// No description provided for @yearlyAmount.
  ///
  /// In en, this message translates to:
  /// **'Yearly Amount'**
  String get yearlyAmount;

  /// No description provided for @badge.
  ///
  /// In en, this message translates to:
  /// **'Badge'**
  String get badge;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @earnedDate.
  ///
  /// In en, this message translates to:
  /// **'Earned Date'**
  String get earnedDate;

  /// No description provided for @totalBadges.
  ///
  /// In en, this message translates to:
  /// **'Total Badges'**
  String get totalBadges;

  /// No description provided for @proFeatureExport.
  ///
  /// In en, this message translates to:
  /// **'Excel Export is a Pro feature'**
  String get proFeatureExport;

  /// No description provided for @upgradeForExport.
  ///
  /// In en, this message translates to:
  /// **'Upgrade to Pro to export your financial data'**
  String get upgradeForExport;

  /// No description provided for @pendingCategorization.
  ///
  /// In en, this message translates to:
  /// **'{count} expenses pending categorization'**
  String pendingCategorization(int count);

  /// No description provided for @suggestionsAvailable.
  ///
  /// In en, this message translates to:
  /// **'{count} suggestions available'**
  String suggestionsAvailable(int count);

  /// No description provided for @reviewExpenses.
  ///
  /// In en, this message translates to:
  /// **'Review Expenses'**
  String get reviewExpenses;

  /// No description provided for @swipeToCategorizeTip.
  ///
  /// In en, this message translates to:
  /// **'Tap a category to categorize'**
  String get swipeToCategorizeTip;

  /// No description provided for @rememberMerchant.
  ///
  /// In en, this message translates to:
  /// **'Remember this merchant'**
  String get rememberMerchant;

  /// No description provided for @suggestionLabel.
  ///
  /// In en, this message translates to:
  /// **'Suggestion: {name}'**
  String suggestionLabel(String name);

  /// No description provided for @suggested.
  ///
  /// In en, this message translates to:
  /// **'Suggested'**
  String get suggested;

  /// No description provided for @allCategorized.
  ///
  /// In en, this message translates to:
  /// **'All Done!'**
  String get allCategorized;

  /// No description provided for @categorizedCount.
  ///
  /// In en, this message translates to:
  /// **'{processed} categorized, {skipped} skipped'**
  String categorizedCount(int processed, int skipped);

  /// No description provided for @importStatement.
  ///
  /// In en, this message translates to:
  /// **'Import Statement'**
  String get importStatement;

  /// No description provided for @importCSV.
  ///
  /// In en, this message translates to:
  /// **'Import CSV'**
  String get importCSV;

  /// No description provided for @importFromBank.
  ///
  /// In en, this message translates to:
  /// **'Import from Bank'**
  String get importFromBank;

  /// No description provided for @selectCSVFile.
  ///
  /// In en, this message translates to:
  /// **'Select CSV file'**
  String get selectCSVFile;

  /// No description provided for @importingExpenses.
  ///
  /// In en, this message translates to:
  /// **'Importing expenses...'**
  String get importingExpenses;

  /// No description provided for @importSuccess.
  ///
  /// In en, this message translates to:
  /// **'Import completed successfully'**
  String get importSuccess;

  /// No description provided for @importError.
  ///
  /// In en, this message translates to:
  /// **'Import failed'**
  String get importError;

  /// No description provided for @recognizedExpenses.
  ///
  /// In en, this message translates to:
  /// **'{count} recognized'**
  String recognizedExpenses(int count);

  /// No description provided for @pendingExpenses.
  ///
  /// In en, this message translates to:
  /// **'{count} pending review'**
  String pendingExpenses(int count);

  /// No description provided for @importSummary.
  ///
  /// In en, this message translates to:
  /// **'Import Summary'**
  String get importSummary;

  /// No description provided for @autoMatched.
  ///
  /// In en, this message translates to:
  /// **'Auto-matched'**
  String get autoMatched;

  /// No description provided for @needsReview.
  ///
  /// In en, this message translates to:
  /// **'Needs Review'**
  String get needsReview;

  /// No description provided for @startReview.
  ///
  /// In en, this message translates to:
  /// **'Start Review'**
  String get startReview;

  /// No description provided for @learnedMerchants.
  ///
  /// In en, this message translates to:
  /// **'Learned Merchants'**
  String get learnedMerchants;

  /// No description provided for @noLearnedMerchants.
  ///
  /// In en, this message translates to:
  /// **'No learned merchants yet'**
  String get noLearnedMerchants;

  /// No description provided for @learnedMerchantsDescription.
  ///
  /// In en, this message translates to:
  /// **'Merchants you categorize will appear here'**
  String get learnedMerchantsDescription;

  /// No description provided for @merchantCount.
  ///
  /// In en, this message translates to:
  /// **'{count} merchants learned'**
  String merchantCount(int count);

  /// No description provided for @deleteMerchant.
  ///
  /// In en, this message translates to:
  /// **'Delete Merchant'**
  String get deleteMerchant;

  /// No description provided for @deleteMerchantConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this merchant?'**
  String get deleteMerchantConfirm;

  /// No description provided for @voiceInput.
  ///
  /// In en, this message translates to:
  /// **'Voice Input'**
  String get voiceInput;

  /// No description provided for @listening.
  ///
  /// In en, this message translates to:
  /// **'Listening...'**
  String get listening;

  /// No description provided for @voiceNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Voice input is not available on this device'**
  String get voiceNotAvailable;

  /// No description provided for @microphonePermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Microphone permission denied'**
  String get microphonePermissionDenied;

  /// No description provided for @voiceExpenseAdded.
  ///
  /// In en, this message translates to:
  /// **'{amount}₺ {description} added'**
  String voiceExpenseAdded(String amount, String description);

  /// No description provided for @voiceConfirmExpense.
  ///
  /// In en, this message translates to:
  /// **'Confirm Expense'**
  String get voiceConfirmExpense;

  /// No description provided for @voiceDetectedAmount.
  ///
  /// In en, this message translates to:
  /// **'Detected: {amount}₺'**
  String voiceDetectedAmount(String amount);

  /// No description provided for @tapToSpeak.
  ///
  /// In en, this message translates to:
  /// **'Tap to speak'**
  String get tapToSpeak;

  /// No description provided for @speakExpense.
  ///
  /// In en, this message translates to:
  /// **'Say your expense (e.g. \"50 lira coffee\")'**
  String get speakExpense;

  /// No description provided for @voiceParsingFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not understand. Please try again.'**
  String get voiceParsingFailed;

  /// No description provided for @voiceHighConfidence.
  ///
  /// In en, this message translates to:
  /// **'Auto-saved'**
  String get voiceHighConfidence;

  /// No description provided for @voiceMediumConfidence.
  ///
  /// In en, this message translates to:
  /// **'Tap to edit'**
  String get voiceMediumConfidence;

  /// No description provided for @voiceLowConfidence.
  ///
  /// In en, this message translates to:
  /// **'Please confirm'**
  String get voiceLowConfidence;

  /// No description provided for @undo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;

  /// No description provided for @assistantSetupTitle.
  ///
  /// In en, this message translates to:
  /// **'Google Assistant Setup'**
  String get assistantSetupTitle;

  /// No description provided for @assistantSetupHeadline.
  ///
  /// In en, this message translates to:
  /// **'Add expenses without saying \"Vantag\"'**
  String get assistantSetupHeadline;

  /// No description provided for @assistantSetupSubheadline.
  ///
  /// In en, this message translates to:
  /// **'After this setup, just say\n\"Hey Google, add expense\"'**
  String get assistantSetupSubheadline;

  /// No description provided for @assistantSetupComplete.
  ///
  /// In en, this message translates to:
  /// **'Great! Now you can say \"Hey Google, add expense\"'**
  String get assistantSetupComplete;

  /// No description provided for @assistantSetupStep1Title.
  ///
  /// In en, this message translates to:
  /// **'Open Google Assistant'**
  String get assistantSetupStep1Title;

  /// No description provided for @assistantSetupStep1Desc.
  ///
  /// In en, this message translates to:
  /// **'Say \"Hey Google, settings\" or open the Google Assistant app.'**
  String get assistantSetupStep1Desc;

  /// No description provided for @assistantSetupStep1Tip.
  ///
  /// In en, this message translates to:
  /// **'Tap the profile icon in the bottom right corner.'**
  String get assistantSetupStep1Tip;

  /// No description provided for @assistantSetupStep2Title.
  ///
  /// In en, this message translates to:
  /// **'Go to Routines'**
  String get assistantSetupStep2Title;

  /// No description provided for @assistantSetupStep2Desc.
  ///
  /// In en, this message translates to:
  /// **'Find and tap \"Routines\" in the settings.'**
  String get assistantSetupStep2Desc;

  /// No description provided for @assistantSetupStep2Tip.
  ///
  /// In en, this message translates to:
  /// **'May also appear as \"Shortcuts\" on some devices.'**
  String get assistantSetupStep2Tip;

  /// No description provided for @assistantSetupStep3Title.
  ///
  /// In en, this message translates to:
  /// **'Create New Routine'**
  String get assistantSetupStep3Title;

  /// No description provided for @assistantSetupStep3Desc.
  ///
  /// In en, this message translates to:
  /// **'Tap the \"+\" or \"New routine\" button.'**
  String get assistantSetupStep3Desc;

  /// No description provided for @assistantSetupStep3Tip.
  ///
  /// In en, this message translates to:
  /// **'Usually in the bottom right corner.'**
  String get assistantSetupStep3Tip;

  /// No description provided for @assistantSetupStep4Title.
  ///
  /// In en, this message translates to:
  /// **'Add Voice Command'**
  String get assistantSetupStep4Title;

  /// No description provided for @assistantSetupStep4Desc.
  ///
  /// In en, this message translates to:
  /// **'Tap \"When I say\" and add a voice command.\n\nType \"add expense\".'**
  String get assistantSetupStep4Desc;

  /// No description provided for @assistantSetupStep4Tip.
  ///
  /// In en, this message translates to:
  /// **'You can also use \"log expense\" or \"record spending\".'**
  String get assistantSetupStep4Tip;

  /// No description provided for @assistantSetupStep5Title.
  ///
  /// In en, this message translates to:
  /// **'Add Action'**
  String get assistantSetupStep5Title;

  /// No description provided for @assistantSetupStep5Desc.
  ///
  /// In en, this message translates to:
  /// **'\"Add action\" → \"Open app\" → Select \"Vantag\".'**
  String get assistantSetupStep5Desc;

  /// No description provided for @assistantSetupStep5Tip.
  ///
  /// In en, this message translates to:
  /// **'Search for Vantag if not visible in the list.'**
  String get assistantSetupStep5Tip;

  /// No description provided for @assistantSetupStep6Title.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get assistantSetupStep6Title;

  /// No description provided for @assistantSetupStep6Desc.
  ///
  /// In en, this message translates to:
  /// **'Tap \"Save\" in the top right corner.'**
  String get assistantSetupStep6Desc;

  /// No description provided for @assistantSetupStep6Tip.
  ///
  /// In en, this message translates to:
  /// **'You may be asked to name the routine.'**
  String get assistantSetupStep6Tip;

  /// No description provided for @step.
  ///
  /// In en, this message translates to:
  /// **'Step'**
  String get step;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @laterButton.
  ///
  /// In en, this message translates to:
  /// **'I\'ll do it later'**
  String get laterButton;

  /// No description provided for @monthlySpendingBreakdown.
  ///
  /// In en, this message translates to:
  /// **'Monthly Spending Breakdown'**
  String get monthlySpendingBreakdown;

  /// No description provided for @mandatoryExpenses.
  ///
  /// In en, this message translates to:
  /// **'Mandatory'**
  String get mandatoryExpenses;

  /// No description provided for @discretionaryExpenses.
  ///
  /// In en, this message translates to:
  /// **'Discretionary'**
  String get discretionaryExpenses;

  /// No description provided for @remainingHoursToSpend.
  ///
  /// In en, this message translates to:
  /// **'{hours} hours left to spend'**
  String remainingHoursToSpend(String hours);

  /// No description provided for @budgetExceeded.
  ///
  /// In en, this message translates to:
  /// **'You exceeded your budget by {amount}!'**
  String budgetExceeded(String amount);

  /// No description provided for @activeInstallments.
  ///
  /// In en, this message translates to:
  /// **'Active Installments'**
  String get activeInstallments;

  /// No description provided for @installmentCount.
  ///
  /// In en, this message translates to:
  /// **'{count} installments'**
  String installmentCount(int count);

  /// No description provided for @moreInstallments.
  ///
  /// In en, this message translates to:
  /// **'+{count} more installments'**
  String moreInstallments(int count);

  /// No description provided for @monthlyBurden.
  ///
  /// In en, this message translates to:
  /// **'Monthly Burden'**
  String get monthlyBurden;

  /// No description provided for @remainingDebt.
  ///
  /// In en, this message translates to:
  /// **'Remaining Debt'**
  String get remainingDebt;

  /// No description provided for @totalInterestCost.
  ///
  /// In en, this message translates to:
  /// **'Total interest: {amount} ({hours} hours)'**
  String totalInterestCost(String amount, String hours);

  /// No description provided for @monthAbbreviation.
  ///
  /// In en, this message translates to:
  /// **'mo'**
  String get monthAbbreviation;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
