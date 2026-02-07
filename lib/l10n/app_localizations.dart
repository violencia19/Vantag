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

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @profileSavedTime.
  ///
  /// In en, this message translates to:
  /// **'Time Saved with Vantag'**
  String get profileSavedTime;

  /// No description provided for @profileHours.
  ///
  /// In en, this message translates to:
  /// **'{hours} Hours'**
  String profileHours(String hours);

  /// No description provided for @profileMemberSince.
  ///
  /// In en, this message translates to:
  /// **'Member Since'**
  String get profileMemberSince;

  /// No description provided for @profileDays.
  ///
  /// In en, this message translates to:
  /// **'{days} Days'**
  String profileDays(int days);

  /// No description provided for @profileBadgesEarned.
  ///
  /// In en, this message translates to:
  /// **'Badges Earned'**
  String get profileBadgesEarned;

  /// No description provided for @profileGoogleConnected.
  ///
  /// In en, this message translates to:
  /// **'Google Account Connected'**
  String get profileGoogleConnected;

  /// No description provided for @profileGoogleNotConnected.
  ///
  /// In en, this message translates to:
  /// **'Google Account Not Connected'**
  String get profileGoogleNotConnected;

  /// No description provided for @profileSignOut.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get profileSignOut;

  /// No description provided for @profileSignOutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to sign out?'**
  String get profileSignOutConfirm;

  /// No description provided for @proMember.
  ///
  /// In en, this message translates to:
  /// **'Pro Member'**
  String get proMember;

  /// No description provided for @proMemberToast.
  ///
  /// In en, this message translates to:
  /// **'You are a Pro Member ✓'**
  String get proMemberToast;

  /// No description provided for @settingsGeneral.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get settingsGeneral;

  /// No description provided for @settingsCurrency.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get settingsCurrency;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @settingsTheme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get settingsTheme;

  /// No description provided for @settingsThemeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get settingsThemeDark;

  /// No description provided for @settingsThemeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get settingsThemeLight;

  /// No description provided for @settingsThemeAutomatic.
  ///
  /// In en, this message translates to:
  /// **'Automatic'**
  String get settingsThemeAutomatic;

  /// No description provided for @simpleMode.
  ///
  /// In en, this message translates to:
  /// **'Simple Mode'**
  String get simpleMode;

  /// No description provided for @simpleModeDescription.
  ///
  /// In en, this message translates to:
  /// **'Streamlined experience with essential features only'**
  String get simpleModeDescription;

  /// No description provided for @simpleModeEnabled.
  ///
  /// In en, this message translates to:
  /// **'Simple mode is enabled'**
  String get simpleModeEnabled;

  /// No description provided for @simpleModeDisabled.
  ///
  /// In en, this message translates to:
  /// **'Simple mode is disabled'**
  String get simpleModeDisabled;

  /// No description provided for @simpleModeHint.
  ///
  /// In en, this message translates to:
  /// **'Turn off Simple Mode to access all features like AI chat, achievements, and pursuits'**
  String get simpleModeHint;

  /// No description provided for @simpleTransactions.
  ///
  /// In en, this message translates to:
  /// **'Transactions'**
  String get simpleTransactions;

  /// No description provided for @simpleStatistics.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get simpleStatistics;

  /// No description provided for @simpleSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get simpleSettings;

  /// No description provided for @simpleIncome.
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get simpleIncome;

  /// No description provided for @simpleExpense.
  ///
  /// In en, this message translates to:
  /// **'Expense'**
  String get simpleExpense;

  /// No description provided for @simpleExpenses.
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get simpleExpenses;

  /// No description provided for @simpleBalance.
  ///
  /// In en, this message translates to:
  /// **'Balance'**
  String get simpleBalance;

  /// No description provided for @simpleTotal.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get simpleTotal;

  /// No description provided for @simpleTotalIncome.
  ///
  /// In en, this message translates to:
  /// **'Total Income'**
  String get simpleTotalIncome;

  /// No description provided for @simpleIncomeTab.
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get simpleIncomeTab;

  /// No description provided for @simpleIncomeSources.
  ///
  /// In en, this message translates to:
  /// **'Income Sources'**
  String get simpleIncomeSources;

  /// No description provided for @simpleNoTransactions.
  ///
  /// In en, this message translates to:
  /// **'No transactions this month'**
  String get simpleNoTransactions;

  /// No description provided for @simpleNoData.
  ///
  /// In en, this message translates to:
  /// **'No data for this month'**
  String get simpleNoData;

  /// No description provided for @settingsNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get settingsNotifications;

  /// No description provided for @settingsReminders.
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get settingsReminders;

  /// No description provided for @settingsSoundEffects.
  ///
  /// In en, this message translates to:
  /// **'Sound Effects'**
  String get settingsSoundEffects;

  /// No description provided for @settingsSoundVolume.
  ///
  /// In en, this message translates to:
  /// **'Volume'**
  String get settingsSoundVolume;

  /// No description provided for @settingsProPurchases.
  ///
  /// In en, this message translates to:
  /// **'Pro & Purchases'**
  String get settingsProPurchases;

  /// No description provided for @settingsVantagPro.
  ///
  /// In en, this message translates to:
  /// **'Vantag Pro'**
  String get settingsVantagPro;

  /// No description provided for @settingsRestorePurchases.
  ///
  /// In en, this message translates to:
  /// **'Restore Purchases'**
  String get settingsRestorePurchases;

  /// No description provided for @settingsRestoreSuccess.
  ///
  /// In en, this message translates to:
  /// **'Purchases restored'**
  String get settingsRestoreSuccess;

  /// No description provided for @settingsRestoreNone.
  ///
  /// In en, this message translates to:
  /// **'No purchases to restore'**
  String get settingsRestoreNone;

  /// No description provided for @settingsDataPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Data & Privacy'**
  String get settingsDataPrivacy;

  /// No description provided for @settingsExportData.
  ///
  /// In en, this message translates to:
  /// **'Export Data'**
  String get settingsExportData;

  /// No description provided for @settingsImportStatement.
  ///
  /// In en, this message translates to:
  /// **'Import Statement'**
  String get settingsImportStatement;

  /// No description provided for @settingsImportStatementDesc.
  ///
  /// In en, this message translates to:
  /// **'Upload your bank statement (PDF/CSV)'**
  String get settingsImportStatementDesc;

  /// No description provided for @importStatementTitle.
  ///
  /// In en, this message translates to:
  /// **'Import Statement'**
  String get importStatementTitle;

  /// No description provided for @importStatementSelectFile.
  ///
  /// In en, this message translates to:
  /// **'Select File'**
  String get importStatementSelectFile;

  /// No description provided for @importStatementSupportedFormats.
  ///
  /// In en, this message translates to:
  /// **'Supported formats: PDF, CSV'**
  String get importStatementSupportedFormats;

  /// No description provided for @importStatementDragDrop.
  ///
  /// In en, this message translates to:
  /// **'Tap to select your bank statement'**
  String get importStatementDragDrop;

  /// No description provided for @importStatementProcessing.
  ///
  /// In en, this message translates to:
  /// **'Processing statement...'**
  String get importStatementProcessing;

  /// No description provided for @importStatementSuccess.
  ///
  /// In en, this message translates to:
  /// **'Successfully imported {count} transactions'**
  String importStatementSuccess(int count);

  /// No description provided for @importStatementError.
  ///
  /// In en, this message translates to:
  /// **'Error importing statement'**
  String get importStatementError;

  /// No description provided for @importStatementNoTransactions.
  ///
  /// In en, this message translates to:
  /// **'No transactions found in statement'**
  String get importStatementNoTransactions;

  /// No description provided for @importStatementUnsupportedFormat.
  ///
  /// In en, this message translates to:
  /// **'Unsupported file format'**
  String get importStatementUnsupportedFormat;

  /// No description provided for @importStatementMonthlyLimit.
  ///
  /// In en, this message translates to:
  /// **'{remaining} imports remaining this month'**
  String importStatementMonthlyLimit(int remaining);

  /// No description provided for @importStatementLimitReached.
  ///
  /// In en, this message translates to:
  /// **'Monthly import limit reached'**
  String get importStatementLimitReached;

  /// No description provided for @importStatementLimitReachedDesc.
  ///
  /// In en, this message translates to:
  /// **'You\'ve used all your imports for this month. Upgrade to Pro for more imports.'**
  String get importStatementLimitReachedDesc;

  /// No description provided for @importStatementProLimit.
  ///
  /// In en, this message translates to:
  /// **'10 imports/month'**
  String get importStatementProLimit;

  /// No description provided for @importStatementFreeLimit.
  ///
  /// In en, this message translates to:
  /// **'1 import/month'**
  String get importStatementFreeLimit;

  /// No description provided for @importStatementReviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Review Transactions'**
  String get importStatementReviewTitle;

  /// No description provided for @importStatementReviewDesc.
  ///
  /// In en, this message translates to:
  /// **'Select transactions to import'**
  String get importStatementReviewDesc;

  /// No description provided for @importStatementImportSelected.
  ///
  /// In en, this message translates to:
  /// **'Import Selected ({count})'**
  String importStatementImportSelected(int count);

  /// No description provided for @importStatementSelectAll.
  ///
  /// In en, this message translates to:
  /// **'Select All'**
  String get importStatementSelectAll;

  /// No description provided for @importStatementDeselectAll.
  ///
  /// In en, this message translates to:
  /// **'Deselect All'**
  String get importStatementDeselectAll;

  /// No description provided for @settingsPrivacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get settingsPrivacyPolicy;

  /// No description provided for @settingsAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get settingsAbout;

  /// No description provided for @settingsVersion.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get settingsVersion;

  /// No description provided for @settingsContactUs.
  ///
  /// In en, this message translates to:
  /// **'Contact Us'**
  String get settingsContactUs;

  /// No description provided for @settingsGrowth.
  ///
  /// In en, this message translates to:
  /// **'Invite & get 3 days Premium free!'**
  String get settingsGrowth;

  /// No description provided for @settingsInviteFriends.
  ///
  /// In en, this message translates to:
  /// **'Invite Friends'**
  String get settingsInviteFriends;

  /// No description provided for @settingsInviteMessage.
  ///
  /// In en, this message translates to:
  /// **'I\'m tracking my expenses with Vantag! You should try it too:'**
  String get settingsInviteMessage;

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
  /// **'Description'**
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
  /// **'Jan'**
  String get monthJan;

  /// No description provided for @monthFeb.
  ///
  /// In en, this message translates to:
  /// **'Feb'**
  String get monthFeb;

  /// No description provided for @monthMar.
  ///
  /// In en, this message translates to:
  /// **'Mar'**
  String get monthMar;

  /// No description provided for @monthApr.
  ///
  /// In en, this message translates to:
  /// **'Apr'**
  String get monthApr;

  /// No description provided for @monthMay.
  ///
  /// In en, this message translates to:
  /// **'May'**
  String get monthMay;

  /// No description provided for @monthJun.
  ///
  /// In en, this message translates to:
  /// **'Jun'**
  String get monthJun;

  /// No description provided for @monthJul.
  ///
  /// In en, this message translates to:
  /// **'Jul'**
  String get monthJul;

  /// No description provided for @monthAug.
  ///
  /// In en, this message translates to:
  /// **'Aug'**
  String get monthAug;

  /// No description provided for @monthSep.
  ///
  /// In en, this message translates to:
  /// **'Sep'**
  String get monthSep;

  /// No description provided for @monthOct.
  ///
  /// In en, this message translates to:
  /// **'Oct'**
  String get monthOct;

  /// No description provided for @monthNov.
  ///
  /// In en, this message translates to:
  /// **'Nov'**
  String get monthNov;

  /// No description provided for @monthDec.
  ///
  /// In en, this message translates to:
  /// **'Dec'**
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

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

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

  /// No description provided for @googleNotLinked.
  ///
  /// In en, this message translates to:
  /// **'Google Not Linked'**
  String get googleNotLinked;

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

  /// No description provided for @dataNotBackedUp.
  ///
  /// In en, this message translates to:
  /// **'Your data is not backed up'**
  String get dataNotBackedUp;

  /// No description provided for @googleLinkedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Google account linked successfully!'**
  String get googleLinkedSuccess;

  /// No description provided for @googleLinkFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to link Google account'**
  String get googleLinkFailed;

  /// No description provided for @appleAccount.
  ///
  /// In en, this message translates to:
  /// **'Apple Account'**
  String get appleAccount;

  /// No description provided for @appleLinked.
  ///
  /// In en, this message translates to:
  /// **'Apple Linked'**
  String get appleLinked;

  /// No description provided for @appleNotLinked.
  ///
  /// In en, this message translates to:
  /// **'Apple Not Linked'**
  String get appleNotLinked;

  /// No description provided for @linkWithApple.
  ///
  /// In en, this message translates to:
  /// **'Link with Apple'**
  String get linkWithApple;

  /// No description provided for @profileAppleConnected.
  ///
  /// In en, this message translates to:
  /// **'Apple Account Connected'**
  String get profileAppleConnected;

  /// No description provided for @profileAppleNotConnected.
  ///
  /// In en, this message translates to:
  /// **'Apple Account Not Connected'**
  String get profileAppleNotConnected;

  /// No description provided for @appleLinkedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Apple account linked successfully!'**
  String get appleLinkedSuccess;

  /// No description provided for @appleLinkFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to link Apple account'**
  String get appleLinkFailed;

  /// No description provided for @appleSignInNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Apple Sign In is not available on this device'**
  String get appleSignInNotAvailable;

  /// No description provided for @editWorkHours.
  ///
  /// In en, this message translates to:
  /// **'Work Hours'**
  String get editWorkHours;

  /// No description provided for @editWorkHoursSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your daily work hours for time calculations'**
  String get editWorkHoursSubtitle;

  /// No description provided for @hoursPerDay.
  ///
  /// In en, this message translates to:
  /// **'{hours} hours/day'**
  String hoursPerDay(String hours);

  /// No description provided for @workHoursUpdated.
  ///
  /// In en, this message translates to:
  /// **'Work hours updated'**
  String get workHoursUpdated;

  /// No description provided for @freeCurrencyNote.
  ///
  /// In en, this message translates to:
  /// **'Free users can only use TRY. Upgrade to Pro for all currencies.'**
  String get freeCurrencyNote;

  /// No description provided for @currencyLockNote.
  ///
  /// In en, this message translates to:
  /// **'Selected currency will be locked. Pro users can change anytime.'**
  String get currencyLockNote;

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

  /// No description provided for @noInternet.
  ///
  /// In en, this message translates to:
  /// **'No Internet Connection'**
  String get noInternet;

  /// No description provided for @offline.
  ///
  /// In en, this message translates to:
  /// **'Offline'**
  String get offline;

  /// No description provided for @offlineMessage.
  ///
  /// In en, this message translates to:
  /// **'Data will sync when connection is restored'**
  String get offlineMessage;

  /// No description provided for @backOnline.
  ///
  /// In en, this message translates to:
  /// **'Back Online'**
  String get backOnline;

  /// No description provided for @dataSynced.
  ///
  /// In en, this message translates to:
  /// **'Data synced successfully'**
  String get dataSynced;

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
  /// **'Notifications'**
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
  /// **'Delete My Account'**
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

  /// No description provided for @editExpense.
  ///
  /// In en, this message translates to:
  /// **'Edit Expense'**
  String get editExpense;

  /// No description provided for @deleteExpense.
  ///
  /// In en, this message translates to:
  /// **'Delete Expense'**
  String get deleteExpense;

  /// No description provided for @deleteExpenseConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this expense?'**
  String get deleteExpenseConfirm;

  /// No description provided for @updateExpense.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get updateExpense;

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
  /// **'Understood'**
  String get understood;

  /// No description provided for @largeAmountTitle.
  ///
  /// In en, this message translates to:
  /// **'Large Amount'**
  String get largeAmountTitle;

  /// No description provided for @largeAmountMessage.
  ///
  /// In en, this message translates to:
  /// **'Is this a real expense or a simulation?'**
  String get largeAmountMessage;

  /// No description provided for @realExpenseButton.
  ///
  /// In en, this message translates to:
  /// **'Real Expense'**
  String get realExpenseButton;

  /// No description provided for @simulationButton.
  ///
  /// In en, this message translates to:
  /// **'Simulation'**
  String get simulationButton;

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
  /// **'Day {day}'**
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
  /// **'Expense will be automatically added on billing date'**
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

  /// No description provided for @deleteAccountWarningTitle.
  ///
  /// In en, this message translates to:
  /// **'You Are About to Delete Your Account'**
  String get deleteAccountWarningTitle;

  /// No description provided for @deleteAccountWarningMessage.
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone! All your data will be permanently deleted:\n\n• Expenses\n• Income\n• Installments\n• Achievements\n• Settings'**
  String get deleteAccountWarningMessage;

  /// No description provided for @deleteAccountConfirmPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Type \'I confirm\' to confirm'**
  String get deleteAccountConfirmPlaceholder;

  /// No description provided for @deleteAccountConfirmWord.
  ///
  /// In en, this message translates to:
  /// **'I confirm'**
  String get deleteAccountConfirmWord;

  /// No description provided for @deleteAccountButton.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccountButton;

  /// No description provided for @deleteAccountSuccess.
  ///
  /// In en, this message translates to:
  /// **'Your account has been successfully deleted'**
  String get deleteAccountSuccess;

  /// No description provided for @deleteAccountError.
  ///
  /// In en, this message translates to:
  /// **'An error occurred while deleting your account'**
  String get deleteAccountError;

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
  /// **'e.g: 20,000'**
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

  /// No description provided for @habitCatCoffee.
  ///
  /// In en, this message translates to:
  /// **'Coffee'**
  String get habitCatCoffee;

  /// No description provided for @habitCatSmoking.
  ///
  /// In en, this message translates to:
  /// **'Smoking'**
  String get habitCatSmoking;

  /// No description provided for @habitCatEatingOut.
  ///
  /// In en, this message translates to:
  /// **'Eating Out'**
  String get habitCatEatingOut;

  /// No description provided for @habitCatGaming.
  ///
  /// In en, this message translates to:
  /// **'Gaming'**
  String get habitCatGaming;

  /// No description provided for @habitCatClothing.
  ///
  /// In en, this message translates to:
  /// **'Clothing'**
  String get habitCatClothing;

  /// No description provided for @habitCatTaxi.
  ///
  /// In en, this message translates to:
  /// **'Taxi/Uber'**
  String get habitCatTaxi;

  /// No description provided for @freqOnceDaily.
  ///
  /// In en, this message translates to:
  /// **'Once daily'**
  String get freqOnceDaily;

  /// No description provided for @freqTwiceDaily.
  ///
  /// In en, this message translates to:
  /// **'Twice daily'**
  String get freqTwiceDaily;

  /// No description provided for @freqEveryTwoDays.
  ///
  /// In en, this message translates to:
  /// **'Every 2 days'**
  String get freqEveryTwoDays;

  /// No description provided for @freqOnceWeekly.
  ///
  /// In en, this message translates to:
  /// **'Once weekly'**
  String get freqOnceWeekly;

  /// No description provided for @freqTwoThreeWeekly.
  ///
  /// In en, this message translates to:
  /// **'2-3x weekly'**
  String get freqTwoThreeWeekly;

  /// No description provided for @freqFewMonthly.
  ///
  /// In en, this message translates to:
  /// **'Few per month'**
  String get freqFewMonthly;

  /// No description provided for @habitSharePreText.
  ///
  /// In en, this message translates to:
  /// **'This habit takes'**
  String get habitSharePreText;

  /// No description provided for @habitShareWorkDays.
  ///
  /// In en, this message translates to:
  /// **'WORK DAYS'**
  String get habitShareWorkDays;

  /// No description provided for @habitSharePostText.
  ///
  /// In en, this message translates to:
  /// **'of work per year'**
  String get habitSharePostText;

  /// No description provided for @habitSharePerYear.
  ///
  /// In en, this message translates to:
  /// **'/year'**
  String get habitSharePerYear;

  /// No description provided for @habitShareCTA.
  ///
  /// In en, this message translates to:
  /// **'How many days are your habits?'**
  String get habitShareCTA;

  /// No description provided for @habitShareText.
  ///
  /// In en, this message translates to:
  /// **'How many days are your habits? 👀 vantag.app'**
  String get habitShareText;

  /// No description provided for @habitShareTextWithLink.
  ///
  /// In en, this message translates to:
  /// **'How many days are your habits? 👀 {link}'**
  String habitShareTextWithLink(String link);

  /// No description provided for @habitMonthlyDetail.
  ///
  /// In en, this message translates to:
  /// **'{days} days {hours} hours'**
  String habitMonthlyDetail(int days, int hours);

  /// No description provided for @editIncomes.
  ///
  /// In en, this message translates to:
  /// **'Edit Incomes'**
  String get editIncomes;

  /// No description provided for @editIncome.
  ///
  /// In en, this message translates to:
  /// **'Edit Income'**
  String get editIncome;

  /// No description provided for @addIncome.
  ///
  /// In en, this message translates to:
  /// **'Add Income'**
  String get addIncome;

  /// No description provided for @changePhoto.
  ///
  /// In en, this message translates to:
  /// **'Photo'**
  String get changePhoto;

  /// No description provided for @takePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take Photo'**
  String get takePhoto;

  /// No description provided for @chooseFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from Gallery'**
  String get chooseFromGallery;

  /// No description provided for @removePhoto.
  ///
  /// In en, this message translates to:
  /// **'Remove Photo'**
  String get removePhoto;

  /// No description provided for @photoSelectError.
  ///
  /// In en, this message translates to:
  /// **'Could not select photo'**
  String get photoSelectError;

  /// No description provided for @editSalary.
  ///
  /// In en, this message translates to:
  /// **'Salary'**
  String get editSalary;

  /// No description provided for @editSalarySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Update your monthly salary'**
  String get editSalarySubtitle;

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
  /// **'Income type'**
  String get incomeType;

  /// No description provided for @incomeCategorySalary.
  ///
  /// In en, this message translates to:
  /// **'Salary'**
  String get incomeCategorySalary;

  /// No description provided for @incomeCategoryFreelance.
  ///
  /// In en, this message translates to:
  /// **'Freelance'**
  String get incomeCategoryFreelance;

  /// No description provided for @incomeCategoryRental.
  ///
  /// In en, this message translates to:
  /// **'Rental Income'**
  String get incomeCategoryRental;

  /// No description provided for @incomeCategoryPassive.
  ///
  /// In en, this message translates to:
  /// **'Passive Income'**
  String get incomeCategoryPassive;

  /// No description provided for @incomeCategoryOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get incomeCategoryOther;

  /// No description provided for @incomeCategorySalaryDesc.
  ///
  /// In en, this message translates to:
  /// **'Monthly regular salary'**
  String get incomeCategorySalaryDesc;

  /// No description provided for @incomeCategoryFreelanceDesc.
  ///
  /// In en, this message translates to:
  /// **'Self-employment income'**
  String get incomeCategoryFreelanceDesc;

  /// No description provided for @incomeCategoryRentalDesc.
  ///
  /// In en, this message translates to:
  /// **'Property, vehicle rental income'**
  String get incomeCategoryRentalDesc;

  /// No description provided for @incomeCategoryPassiveDesc.
  ///
  /// In en, this message translates to:
  /// **'Investment, dividends, interest etc.'**
  String get incomeCategoryPassiveDesc;

  /// No description provided for @incomeCategoryOtherDesc.
  ///
  /// In en, this message translates to:
  /// **'Other income sources'**
  String get incomeCategoryOtherDesc;

  /// No description provided for @mainSalary.
  ///
  /// In en, this message translates to:
  /// **'Main Salary'**
  String get mainSalary;

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
  /// **'SPENT'**
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

  /// No description provided for @sharing.
  ///
  /// In en, this message translates to:
  /// **'Sharing...'**
  String get sharing;

  /// No description provided for @frequency.
  ///
  /// In en, this message translates to:
  /// **'Frequency'**
  String get frequency;

  /// No description provided for @daysAbbrev.
  ///
  /// In en, this message translates to:
  /// **'days'**
  String get daysAbbrev;

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
  /// **'Auto-record enabled'**
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

  /// No description provided for @shareVia.
  ///
  /// In en, this message translates to:
  /// **'Share via'**
  String get shareVia;

  /// No description provided for @saveToGallery.
  ///
  /// In en, this message translates to:
  /// **'Save to Gallery'**
  String get saveToGallery;

  /// No description provided for @savedToGallery.
  ///
  /// In en, this message translates to:
  /// **'Saved to gallery'**
  String get savedToGallery;

  /// No description provided for @otherApps.
  ///
  /// In en, this message translates to:
  /// **'Other Apps'**
  String get otherApps;

  /// No description provided for @expenseDeleted.
  ///
  /// In en, this message translates to:
  /// **'Expense deleted'**
  String get expenseDeleted;

  /// No description provided for @undo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;

  /// No description provided for @choosePlatform.
  ///
  /// In en, this message translates to:
  /// **'Choose Platform'**
  String get choosePlatform;

  /// No description provided for @savingToGallery.
  ///
  /// In en, this message translates to:
  /// **'Saving...'**
  String get savingToGallery;

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
  /// **'Spending Trend'**
  String get yearlyHeatmap;

  /// No description provided for @yearlyHeatmapDesc.
  ///
  /// In en, this message translates to:
  /// **'Your monthly spending over the last 12 months'**
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

  /// No description provided for @tapMonthForDetails.
  ///
  /// In en, this message translates to:
  /// **'Tap a month for details'**
  String get tapMonthForDetails;

  /// No description provided for @selectedDayExpenses.
  ///
  /// In en, this message translates to:
  /// **'{date}: {amount} TL ({count} expenses)'**
  String selectedDayExpenses(String date, String amount, int count);

  /// No description provided for @selectedMonthExpenses.
  ///
  /// In en, this message translates to:
  /// **'{month}: {amount} ({count} expenses)'**
  String selectedMonthExpenses(String month, String amount, int count);

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

  /// No description provided for @exportComplete.
  ///
  /// In en, this message translates to:
  /// **'Export Complete'**
  String get exportComplete;

  /// No description provided for @exportShareOption.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get exportShareOption;

  /// No description provided for @exportSaveOption.
  ///
  /// In en, this message translates to:
  /// **'Save to Files'**
  String get exportSaveOption;

  /// No description provided for @exportSavedToDownloads.
  ///
  /// In en, this message translates to:
  /// **'Saved to Downloads/Vantag'**
  String get exportSavedToDownloads;

  /// No description provided for @exportChooseAction.
  ///
  /// In en, this message translates to:
  /// **'What would you like to do with the file?'**
  String get exportChooseAction;

  /// No description provided for @csvHeaderDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get csvHeaderDate;

  /// No description provided for @csvHeaderTime.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get csvHeaderTime;

  /// No description provided for @csvHeaderAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get csvHeaderAmount;

  /// No description provided for @csvHeaderCurrency.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get csvHeaderCurrency;

  /// No description provided for @csvHeaderCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get csvHeaderCategory;

  /// No description provided for @csvHeaderSubcategory.
  ///
  /// In en, this message translates to:
  /// **'Subcategory'**
  String get csvHeaderSubcategory;

  /// No description provided for @csvHeaderDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get csvHeaderDescription;

  /// No description provided for @csvHeaderProduct.
  ///
  /// In en, this message translates to:
  /// **'Product'**
  String get csvHeaderProduct;

  /// No description provided for @csvHeaderDecision.
  ///
  /// In en, this message translates to:
  /// **'Decision'**
  String get csvHeaderDecision;

  /// No description provided for @csvHeaderWorkHours.
  ///
  /// In en, this message translates to:
  /// **'Work Hours'**
  String get csvHeaderWorkHours;

  /// No description provided for @csvHeaderInstallment.
  ///
  /// In en, this message translates to:
  /// **'Installment'**
  String get csvHeaderInstallment;

  /// No description provided for @csvHeaderMandatory.
  ///
  /// In en, this message translates to:
  /// **'Mandatory'**
  String get csvHeaderMandatory;

  /// No description provided for @csvSummarySection.
  ///
  /// In en, this message translates to:
  /// **'SUMMARY'**
  String get csvSummarySection;

  /// No description provided for @csvTotalExpense.
  ///
  /// In en, this message translates to:
  /// **'Total Expense'**
  String get csvTotalExpense;

  /// No description provided for @csvCategoryTotals.
  ///
  /// In en, this message translates to:
  /// **'Category Totals'**
  String get csvCategoryTotals;

  /// No description provided for @csvDailyAverage.
  ///
  /// In en, this message translates to:
  /// **'Daily Average'**
  String get csvDailyAverage;

  /// No description provided for @csvWeeklyAverage.
  ///
  /// In en, this message translates to:
  /// **'Weekly Average'**
  String get csvWeeklyAverage;

  /// No description provided for @csvTopCategory.
  ///
  /// In en, this message translates to:
  /// **'Top Category'**
  String get csvTopCategory;

  /// No description provided for @csvLargestExpense.
  ///
  /// In en, this message translates to:
  /// **'Largest Expense'**
  String get csvLargestExpense;

  /// No description provided for @csvTotalWorkHours.
  ///
  /// In en, this message translates to:
  /// **'Total Work Hours'**
  String get csvTotalWorkHours;

  /// No description provided for @csvPeriod.
  ///
  /// In en, this message translates to:
  /// **'Period'**
  String get csvPeriod;

  /// No description provided for @csvYes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get csvYes;

  /// No description provided for @csvNo.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get csvNo;

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

  /// No description provided for @importPremiumOnly.
  ///
  /// In en, this message translates to:
  /// **'Import is a Pro feature'**
  String get importPremiumOnly;

  /// No description provided for @upgradeForImport.
  ///
  /// In en, this message translates to:
  /// **'Upgrade to Pro to import your bank statements'**
  String get upgradeForImport;

  /// No description provided for @receiptScanned.
  ///
  /// In en, this message translates to:
  /// **'Receipt scanned successfully'**
  String get receiptScanned;

  /// No description provided for @noAmountFound.
  ///
  /// In en, this message translates to:
  /// **'No amount found in the image'**
  String get noAmountFound;

  /// No description provided for @saveAllRecognized.
  ///
  /// In en, this message translates to:
  /// **'Save All ({count})'**
  String saveAllRecognized(int count);

  /// No description provided for @saveAllRecognizedSuccess.
  ///
  /// In en, this message translates to:
  /// **'{count} expenses saved successfully'**
  String saveAllRecognizedSuccess(int count);

  /// No description provided for @budgets.
  ///
  /// In en, this message translates to:
  /// **'Budgets'**
  String get budgets;

  /// No description provided for @budget.
  ///
  /// In en, this message translates to:
  /// **'Budget'**
  String get budget;

  /// No description provided for @addBudget.
  ///
  /// In en, this message translates to:
  /// **'Add Budget'**
  String get addBudget;

  /// No description provided for @editBudget.
  ///
  /// In en, this message translates to:
  /// **'Edit Budget'**
  String get editBudget;

  /// No description provided for @deleteBudget.
  ///
  /// In en, this message translates to:
  /// **'Delete Budget'**
  String get deleteBudget;

  /// No description provided for @deleteBudgetConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this budget?'**
  String get deleteBudgetConfirm;

  /// No description provided for @monthlyLimit.
  ///
  /// In en, this message translates to:
  /// **'Monthly Limit'**
  String get monthlyLimit;

  /// No description provided for @budgetProgress.
  ///
  /// In en, this message translates to:
  /// **'Budget Progress'**
  String get budgetProgress;

  /// No description provided for @totalBudget.
  ///
  /// In en, this message translates to:
  /// **'Total Budget'**
  String get totalBudget;

  /// No description provided for @remainingAmount.
  ///
  /// In en, this message translates to:
  /// **'{amount} remaining'**
  String remainingAmount(String amount);

  /// No description provided for @overBudgetAmount.
  ///
  /// In en, this message translates to:
  /// **'{amount} over!'**
  String overBudgetAmount(String amount);

  /// No description provided for @ofBudget.
  ///
  /// In en, this message translates to:
  /// **'{spent} of {total}'**
  String ofBudget(String spent, String total);

  /// No description provided for @onTrack.
  ///
  /// In en, this message translates to:
  /// **'On track'**
  String get onTrack;

  /// No description provided for @nearLimit.
  ///
  /// In en, this message translates to:
  /// **'Near limit'**
  String get nearLimit;

  /// No description provided for @overLimit.
  ///
  /// In en, this message translates to:
  /// **'Over limit'**
  String get overLimit;

  /// No description provided for @noBudgetsYet.
  ///
  /// In en, this message translates to:
  /// **'No budgets yet'**
  String get noBudgetsYet;

  /// No description provided for @noBudgetsDescription.
  ///
  /// In en, this message translates to:
  /// **'Set budgets to track your spending by category'**
  String get noBudgetsDescription;

  /// No description provided for @budgetHelperText.
  ///
  /// In en, this message translates to:
  /// **'Set a monthly spending limit for this category'**
  String get budgetHelperText;

  /// No description provided for @budgetExceededTitle.
  ///
  /// In en, this message translates to:
  /// **'Budget Exceeded!'**
  String get budgetExceededTitle;

  /// No description provided for @budgetExceededMessage.
  ///
  /// In en, this message translates to:
  /// **'You\'ve exceeded your {category} budget by {amount}'**
  String budgetExceededMessage(String category, String amount);

  /// No description provided for @budgetNearLimit.
  ///
  /// In en, this message translates to:
  /// **'Approaching budget limit'**
  String get budgetNearLimit;

  /// No description provided for @budgetNearLimitMessage.
  ///
  /// In en, this message translates to:
  /// **'You\'ve used {percent}% of your {category} budget'**
  String budgetNearLimitMessage(String percent, String category);

  /// No description provided for @categoriesOnTrack.
  ///
  /// In en, this message translates to:
  /// **'{count} on track'**
  String categoriesOnTrack(int count);

  /// No description provided for @categoriesOverBudget.
  ///
  /// In en, this message translates to:
  /// **'{count} over budget'**
  String categoriesOverBudget(int count);

  /// No description provided for @categoriesNearLimit.
  ///
  /// In en, this message translates to:
  /// **'{count} near limit'**
  String categoriesNearLimit(int count);

  /// No description provided for @categories.
  ///
  /// In en, this message translates to:
  /// **'categories'**
  String get categories;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get viewAll;

  /// No description provided for @viewBudgetsInReports.
  ///
  /// In en, this message translates to:
  /// **'View budget details in Reports tab'**
  String get viewBudgetsInReports;

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
  /// **'{count} expenses imported successfully'**
  String importSuccess(int count);

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

  /// No description provided for @importAIParsed.
  ///
  /// In en, this message translates to:
  /// **'AI Parsed Transactions'**
  String get importAIParsed;

  /// No description provided for @importNoTransactions.
  ///
  /// In en, this message translates to:
  /// **'No transactions found in this file'**
  String get importNoTransactions;

  /// No description provided for @importSelected.
  ///
  /// In en, this message translates to:
  /// **'Save {count} Selected'**
  String importSelected(int count);

  /// No description provided for @transactions.
  ///
  /// In en, this message translates to:
  /// **'transactions'**
  String get transactions;

  /// No description provided for @selectAll.
  ///
  /// In en, this message translates to:
  /// **'Select All'**
  String get selectAll;

  /// No description provided for @selectNone.
  ///
  /// In en, this message translates to:
  /// **'Select None'**
  String get selectNone;

  /// No description provided for @selected.
  ///
  /// In en, this message translates to:
  /// **'selected'**
  String get selected;

  /// No description provided for @saving.
  ///
  /// In en, this message translates to:
  /// **'Saving...'**
  String get saving;

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

  /// No description provided for @microphonePermissionRequired.
  ///
  /// In en, this message translates to:
  /// **'Microphone permission required'**
  String get microphonePermissionRequired;

  /// No description provided for @networkRequired.
  ///
  /// In en, this message translates to:
  /// **'Internet connection required'**
  String get networkRequired;

  /// No description provided for @understanding.
  ///
  /// In en, this message translates to:
  /// **'Understanding...'**
  String get understanding;

  /// No description provided for @couldNotUnderstandTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Could not understand, try again'**
  String get couldNotUnderstandTryAgain;

  /// No description provided for @couldNotUnderstandSayAgain.
  ///
  /// In en, this message translates to:
  /// **'Could not understand, say again'**
  String get couldNotUnderstandSayAgain;

  /// No description provided for @sayAgain.
  ///
  /// In en, this message translates to:
  /// **'Say again'**
  String get sayAgain;

  /// No description provided for @yesSave.
  ///
  /// In en, this message translates to:
  /// **'Yes, save'**
  String get yesSave;

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

  /// No description provided for @speakYourExpense.
  ///
  /// In en, this message translates to:
  /// **'Speak your expense'**
  String get speakYourExpense;

  /// No description provided for @longPressForVoice.
  ///
  /// In en, this message translates to:
  /// **'Long-press for voice input'**
  String get longPressForVoice;

  /// No description provided for @didYouKnow.
  ///
  /// In en, this message translates to:
  /// **'Did you know?'**
  String get didYouKnow;

  /// No description provided for @voiceTipMessage.
  ///
  /// In en, this message translates to:
  /// **'Add expenses faster! Long-press + button and say: \"50 lira coffee\"'**
  String get voiceTipMessage;

  /// No description provided for @gotIt.
  ///
  /// In en, this message translates to:
  /// **'Got It'**
  String get gotIt;

  /// No description provided for @tryNow.
  ///
  /// In en, this message translates to:
  /// **'Try Now'**
  String get tryNow;

  /// No description provided for @voiceAndShortcuts.
  ///
  /// In en, this message translates to:
  /// **'Voice & Shortcuts'**
  String get voiceAndShortcuts;

  /// No description provided for @newBadge.
  ///
  /// In en, this message translates to:
  /// **'NEW'**
  String get newBadge;

  /// No description provided for @voiceInputHint.
  ///
  /// In en, this message translates to:
  /// **'Long-press + button for voice'**
  String get voiceInputHint;

  /// No description provided for @howToUseVoice.
  ///
  /// In en, this message translates to:
  /// **'How to Use Voice'**
  String get howToUseVoice;

  /// No description provided for @voiceLimitReachedTitle.
  ///
  /// In en, this message translates to:
  /// **'Daily Limit Reached'**
  String get voiceLimitReachedTitle;

  /// No description provided for @voiceLimitReachedFree.
  ///
  /// In en, this message translates to:
  /// **'You\'ve used your daily voice input. Upgrade to Pro for unlimited access or try again tomorrow.'**
  String get voiceLimitReachedFree;

  /// No description provided for @voiceServerBusyTitle.
  ///
  /// In en, this message translates to:
  /// **'Servers Busy'**
  String get voiceServerBusyTitle;

  /// No description provided for @voiceServerBusyMessage.
  ///
  /// In en, this message translates to:
  /// **'Voice servers are busy right now. Please try again shortly.'**
  String get voiceServerBusyMessage;

  /// No description provided for @longPressFab.
  ///
  /// In en, this message translates to:
  /// **'Long-Press + Button'**
  String get longPressFab;

  /// No description provided for @longPressFabHint.
  ///
  /// In en, this message translates to:
  /// **'Hold for 1 second'**
  String get longPressFabHint;

  /// No description provided for @micButton.
  ///
  /// In en, this message translates to:
  /// **'Microphone Button'**
  String get micButton;

  /// No description provided for @micButtonHint.
  ///
  /// In en, this message translates to:
  /// **'Tap mic when adding expense'**
  String get micButtonHint;

  /// No description provided for @exampleCommands.
  ///
  /// In en, this message translates to:
  /// **'Example Commands'**
  String get exampleCommands;

  /// No description provided for @voiceExample1.
  ///
  /// In en, this message translates to:
  /// **'\"50 dollars for coffee\"'**
  String get voiceExample1;

  /// No description provided for @voiceExample2.
  ///
  /// In en, this message translates to:
  /// **'\"Spent 200 on groceries\"'**
  String get voiceExample2;

  /// No description provided for @voiceExample3.
  ///
  /// In en, this message translates to:
  /// **'\"Taxi was 150\"'**
  String get voiceExample3;

  /// No description provided for @voiceExamplesMultiline.
  ///
  /// In en, this message translates to:
  /// **'\"50 dollars coffee\"\n\"spent 200 on groceries\"\n\"taxi was 150\"'**
  String get voiceExamplesMultiline;

  /// No description provided for @somethingWentWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get somethingWentWrong;

  /// No description provided for @errorLoadingData.
  ///
  /// In en, this message translates to:
  /// **'Error loading data'**
  String get errorLoadingData;

  /// No description provided for @errorSaving.
  ///
  /// In en, this message translates to:
  /// **'Error saving. Please try again.'**
  String get errorSaving;

  /// No description provided for @networkError.
  ///
  /// In en, this message translates to:
  /// **'Network error. Check your connection.'**
  String get networkError;

  /// No description provided for @errorLoadingRates.
  ///
  /// In en, this message translates to:
  /// **'Could not load exchange rates'**
  String get errorLoadingRates;

  /// No description provided for @errorLoadingSubscriptions.
  ///
  /// In en, this message translates to:
  /// **'Could not load subscriptions'**
  String get errorLoadingSubscriptions;

  /// No description provided for @autoRecorded.
  ///
  /// In en, this message translates to:
  /// **'Auto'**
  String get autoRecorded;

  /// No description provided for @autoRecordedExpenses.
  ///
  /// In en, this message translates to:
  /// **'{count} subscription(s) auto-recorded'**
  String autoRecordedExpenses(int count);

  /// No description provided for @security.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get security;

  /// No description provided for @pinLock.
  ///
  /// In en, this message translates to:
  /// **'PIN Lock'**
  String get pinLock;

  /// No description provided for @pinLockDescription.
  ///
  /// In en, this message translates to:
  /// **'Require PIN to open app'**
  String get pinLockDescription;

  /// No description provided for @biometricUnlock.
  ///
  /// In en, this message translates to:
  /// **'Biometric Unlock'**
  String get biometricUnlock;

  /// No description provided for @biometricDescription.
  ///
  /// In en, this message translates to:
  /// **'Use fingerprint or Face ID'**
  String get biometricDescription;

  /// No description provided for @enterPin.
  ///
  /// In en, this message translates to:
  /// **'Enter PIN'**
  String get enterPin;

  /// No description provided for @createPin.
  ///
  /// In en, this message translates to:
  /// **'Create PIN'**
  String get createPin;

  /// No description provided for @createPinDescription.
  ///
  /// In en, this message translates to:
  /// **'Choose a 4-digit PIN'**
  String get createPinDescription;

  /// No description provided for @confirmPin.
  ///
  /// In en, this message translates to:
  /// **'Confirm PIN'**
  String get confirmPin;

  /// No description provided for @confirmPinDescription.
  ///
  /// In en, this message translates to:
  /// **'Enter your PIN again'**
  String get confirmPinDescription;

  /// No description provided for @wrongPin.
  ///
  /// In en, this message translates to:
  /// **'Wrong PIN. Try again.'**
  String get wrongPin;

  /// No description provided for @pinMismatch.
  ///
  /// In en, this message translates to:
  /// **'PINs don\'t match. Try again.'**
  String get pinMismatch;

  /// No description provided for @pinSet.
  ///
  /// In en, this message translates to:
  /// **'PIN set successfully'**
  String get pinSet;

  /// No description provided for @useBiometric.
  ///
  /// In en, this message translates to:
  /// **'Use Biometric'**
  String get useBiometric;

  /// No description provided for @unlockWithBiometric.
  ///
  /// In en, this message translates to:
  /// **'Unlock Vantag'**
  String get unlockWithBiometric;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

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
  /// **'Active Payment Plans'**
  String get activeInstallments;

  /// No description provided for @installmentCount.
  ///
  /// In en, this message translates to:
  /// **'{count} payments'**
  String installmentCount(int count);

  /// No description provided for @moreInstallments.
  ///
  /// In en, this message translates to:
  /// **'+{count} more plans'**
  String moreInstallments(int count);

  /// No description provided for @monthlyBurden.
  ///
  /// In en, this message translates to:
  /// **'Monthly Burden'**
  String get monthlyBurden;

  /// No description provided for @remainingDebt.
  ///
  /// In en, this message translates to:
  /// **'Remaining Balance'**
  String get remainingDebt;

  /// No description provided for @totalInterestCost.
  ///
  /// In en, this message translates to:
  /// **'Total fees: {amount} ({hours} hours)'**
  String totalInterestCost(String amount, String hours);

  /// No description provided for @monthAbbreviation.
  ///
  /// In en, this message translates to:
  /// **'mo'**
  String get monthAbbreviation;

  /// No description provided for @installmentsLabel.
  ///
  /// In en, this message translates to:
  /// **'payments'**
  String get installmentsLabel;

  /// No description provided for @remaining.
  ///
  /// In en, this message translates to:
  /// **'Remaining'**
  String get remaining;

  /// No description provided for @paywallTitle.
  ///
  /// In en, this message translates to:
  /// **'Upgrade to Premium'**
  String get paywallTitle;

  /// No description provided for @paywallSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Unlock all features and achieve your financial freedom'**
  String get paywallSubtitle;

  /// No description provided for @subscribeToPro.
  ///
  /// In en, this message translates to:
  /// **'Subscribe to Pro'**
  String get subscribeToPro;

  /// No description provided for @startFreeTrial.
  ///
  /// In en, this message translates to:
  /// **'Start 7-Day Free Trial'**
  String get startFreeTrial;

  /// No description provided for @freeTrialBanner.
  ///
  /// In en, this message translates to:
  /// **'7 DAYS FREE'**
  String get freeTrialBanner;

  /// No description provided for @freeTrialDescription.
  ///
  /// In en, this message translates to:
  /// **'First 7 days completely free, cancel anytime'**
  String get freeTrialDescription;

  /// No description provided for @trialThenPrice.
  ///
  /// In en, this message translates to:
  /// **'Then {price}/month after trial'**
  String trialThenPrice(String price);

  /// No description provided for @noPaymentNow.
  ///
  /// In en, this message translates to:
  /// **'No payment required now'**
  String get noPaymentNow;

  /// No description provided for @restorePurchases.
  ///
  /// In en, this message translates to:
  /// **'Restore purchases'**
  String get restorePurchases;

  /// No description provided for @feature.
  ///
  /// In en, this message translates to:
  /// **'Feature'**
  String get feature;

  /// No description provided for @featureAiChat.
  ///
  /// In en, this message translates to:
  /// **'AI Chat'**
  String get featureAiChat;

  /// No description provided for @featureAiChatFree.
  ///
  /// In en, this message translates to:
  /// **'4/day'**
  String get featureAiChatFree;

  /// No description provided for @featureHistory.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get featureHistory;

  /// No description provided for @featureHistory30Days.
  ///
  /// In en, this message translates to:
  /// **'30 days'**
  String get featureHistory30Days;

  /// No description provided for @featureExport.
  ///
  /// In en, this message translates to:
  /// **'Excel Export'**
  String get featureExport;

  /// No description provided for @featureWidgets.
  ///
  /// In en, this message translates to:
  /// **'Widgets'**
  String get featureWidgets;

  /// No description provided for @featureAds.
  ///
  /// In en, this message translates to:
  /// **'Ads'**
  String get featureAds;

  /// No description provided for @featureUnlimited.
  ///
  /// In en, this message translates to:
  /// **'Unlimited'**
  String get featureUnlimited;

  /// No description provided for @featureYes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get featureYes;

  /// No description provided for @featureNo.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get featureNo;

  /// No description provided for @weekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get weekly;

  /// No description provided for @week.
  ///
  /// In en, this message translates to:
  /// **'week'**
  String get week;

  /// No description provided for @year.
  ///
  /// In en, this message translates to:
  /// **'year'**
  String get year;

  /// No description provided for @bestValue.
  ///
  /// In en, this message translates to:
  /// **'Best Value'**
  String get bestValue;

  /// No description provided for @yearlySavings.
  ///
  /// In en, this message translates to:
  /// **'Save up to 50%'**
  String get yearlySavings;

  /// No description provided for @cancelAnytime.
  ///
  /// In en, this message translates to:
  /// **'Cancel anytime'**
  String get cancelAnytime;

  /// No description provided for @aiLimitReached.
  ///
  /// In en, this message translates to:
  /// **'Daily AI limit reached'**
  String get aiLimitReached;

  /// No description provided for @aiLimitMessage.
  ///
  /// In en, this message translates to:
  /// **'You\'ve used {used}/{limit} AI chats today. Upgrade to Pro for unlimited access.'**
  String aiLimitMessage(int used, int limit);

  /// No description provided for @historyLimitReached.
  ///
  /// In en, this message translates to:
  /// **'History limit reached'**
  String get historyLimitReached;

  /// No description provided for @historyLimitMessage.
  ///
  /// In en, this message translates to:
  /// **'Free plan only shows last 30 days. Upgrade to Pro for full history access.'**
  String get historyLimitMessage;

  /// No description provided for @exportProOnly.
  ///
  /// In en, this message translates to:
  /// **'Excel export is a Pro feature'**
  String get exportProOnly;

  /// No description provided for @remainingAiUses.
  ///
  /// In en, this message translates to:
  /// **'{count} AI uses left'**
  String remainingAiUses(int count);

  /// No description provided for @lifetime.
  ///
  /// In en, this message translates to:
  /// **'Lifetime'**
  String get lifetime;

  /// No description provided for @lifetimeDescription.
  ///
  /// In en, this message translates to:
  /// **'Pay once, use forever • 100 AI credits/month'**
  String get lifetimeDescription;

  /// No description provided for @oneTime.
  ///
  /// In en, this message translates to:
  /// **'one-time'**
  String get oneTime;

  /// No description provided for @forever.
  ///
  /// In en, this message translates to:
  /// **'FOREVER'**
  String get forever;

  /// No description provided for @mostPopular.
  ///
  /// In en, this message translates to:
  /// **'MOST POPULAR'**
  String get mostPopular;

  /// No description provided for @monthlyCredits.
  ///
  /// In en, this message translates to:
  /// **'{count} AI credits/month'**
  String monthlyCredits(int count);

  /// No description provided for @proMonthlyCredits.
  ///
  /// In en, this message translates to:
  /// **'{remaining}/{limit} monthly credits'**
  String proMonthlyCredits(int remaining, int limit);

  /// No description provided for @aiLimitFreeTitleEmoji.
  ///
  /// In en, this message translates to:
  /// **'🔒 Daily AI Limit Reached!'**
  String get aiLimitFreeTitleEmoji;

  /// No description provided for @aiLimitProTitleEmoji.
  ///
  /// In en, this message translates to:
  /// **'⏳ Monthly AI Limit Reached!'**
  String get aiLimitProTitleEmoji;

  /// No description provided for @aiLimitFreeMessage.
  ///
  /// In en, this message translates to:
  /// **'You\'ve used all 4 AI questions for today.'**
  String get aiLimitFreeMessage;

  /// No description provided for @aiLimitProMessage.
  ///
  /// In en, this message translates to:
  /// **'You\'ve used all 500 AI questions this month.'**
  String get aiLimitProMessage;

  /// No description provided for @aiLimitLifetimeMessage.
  ///
  /// In en, this message translates to:
  /// **'You\'ve used all 200 AI credits this month.'**
  String get aiLimitLifetimeMessage;

  /// No description provided for @aiLimitResetDate.
  ///
  /// In en, this message translates to:
  /// **'Limit resets on {month} {day} ({days} days left)'**
  String aiLimitResetDate(String day, String month, int days);

  /// No description provided for @aiLimitUpgradeToPro.
  ///
  /// In en, this message translates to:
  /// **'🚀 Upgrade to Pro - Unlimited AI'**
  String get aiLimitUpgradeToPro;

  /// No description provided for @aiLimitBuyCredits.
  ///
  /// In en, this message translates to:
  /// **'🔋 Buy Extra Credit Pack'**
  String get aiLimitBuyCredits;

  /// No description provided for @aiLimitTryTomorrow.
  ///
  /// In en, this message translates to:
  /// **'or try again tomorrow'**
  String get aiLimitTryTomorrow;

  /// No description provided for @aiLimitOrWaitDays.
  ///
  /// In en, this message translates to:
  /// **'or wait {days} days for reset'**
  String aiLimitOrWaitDays(int days);

  /// No description provided for @creditPurchaseTitle.
  ///
  /// In en, this message translates to:
  /// **'Buy Credits'**
  String get creditPurchaseTitle;

  /// No description provided for @creditPurchaseHeader.
  ///
  /// In en, this message translates to:
  /// **'Top Up AI Credits'**
  String get creditPurchaseHeader;

  /// No description provided for @creditPurchaseSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Purchase extra credits for AI queries beyond your monthly limit.'**
  String get creditPurchaseSubtitle;

  /// No description provided for @creditCurrentBalance.
  ///
  /// In en, this message translates to:
  /// **'Current Balance'**
  String get creditCurrentBalance;

  /// No description provided for @creditAmount.
  ///
  /// In en, this message translates to:
  /// **'{credits} Credits'**
  String creditAmount(int credits);

  /// No description provided for @creditPackTitle.
  ///
  /// In en, this message translates to:
  /// **'{credits} Credits'**
  String creditPackTitle(int credits);

  /// No description provided for @creditPackPricePerCredit.
  ///
  /// In en, this message translates to:
  /// **'₺{price} per credit'**
  String creditPackPricePerCredit(String price);

  /// No description provided for @creditPackPopular.
  ///
  /// In en, this message translates to:
  /// **'MOST POPULAR'**
  String get creditPackPopular;

  /// No description provided for @creditPackBestValue.
  ///
  /// In en, this message translates to:
  /// **'BEST VALUE'**
  String get creditPackBestValue;

  /// No description provided for @creditNeverExpire.
  ///
  /// In en, this message translates to:
  /// **'Credits never expire, use them anytime'**
  String get creditNeverExpire;

  /// No description provided for @creditPurchaseSuccess.
  ///
  /// In en, this message translates to:
  /// **'{credits} credits added to your account!'**
  String creditPurchaseSuccess(int credits);

  /// No description provided for @pursuits.
  ///
  /// In en, this message translates to:
  /// **'My Dreams'**
  String get pursuits;

  /// No description provided for @myPursuits.
  ///
  /// In en, this message translates to:
  /// **'My Dreams'**
  String get myPursuits;

  /// No description provided for @navPursuits.
  ///
  /// In en, this message translates to:
  /// **'Dreams'**
  String get navPursuits;

  /// No description provided for @createPursuit.
  ///
  /// In en, this message translates to:
  /// **'New Dream'**
  String get createPursuit;

  /// No description provided for @pursuitName.
  ///
  /// In en, this message translates to:
  /// **'What are you saving for?'**
  String get pursuitName;

  /// No description provided for @pursuitNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g: iPhone 16, Maldives Vacation...'**
  String get pursuitNameHint;

  /// No description provided for @targetAmount.
  ///
  /// In en, this message translates to:
  /// **'Target Amount'**
  String get targetAmount;

  /// No description provided for @savedAmount.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get savedAmount;

  /// No description provided for @addSavings.
  ///
  /// In en, this message translates to:
  /// **'Add Money'**
  String get addSavings;

  /// No description provided for @pursuitProgress.
  ///
  /// In en, this message translates to:
  /// **'{percent}% complete'**
  String pursuitProgress(int percent);

  /// No description provided for @daysToGoal.
  ///
  /// In en, this message translates to:
  /// **'≈ {days} work days'**
  String daysToGoal(int days);

  /// No description provided for @pursuitCompleted.
  ///
  /// In en, this message translates to:
  /// **'Your Dream Came True!'**
  String get pursuitCompleted;

  /// No description provided for @congratulations.
  ///
  /// In en, this message translates to:
  /// **'Congratulations!'**
  String get congratulations;

  /// No description provided for @pursuitCompletedMessage.
  ///
  /// In en, this message translates to:
  /// **'You saved {amount} in {days} days!'**
  String pursuitCompletedMessage(int days, String amount);

  /// No description provided for @shareProgress.
  ///
  /// In en, this message translates to:
  /// **'Share Progress'**
  String get shareProgress;

  /// No description provided for @activePursuits.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get activePursuits;

  /// No description provided for @completedPursuits.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completedPursuits;

  /// No description provided for @archivePursuit.
  ///
  /// In en, this message translates to:
  /// **'Archive'**
  String get archivePursuit;

  /// No description provided for @deletePursuit.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deletePursuit;

  /// No description provided for @editPursuit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get editPursuit;

  /// No description provided for @deletePursuitConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this dream?'**
  String get deletePursuitConfirm;

  /// No description provided for @pursuitCategoryTech.
  ///
  /// In en, this message translates to:
  /// **'Tech'**
  String get pursuitCategoryTech;

  /// No description provided for @pursuitCategoryTravel.
  ///
  /// In en, this message translates to:
  /// **'Travel'**
  String get pursuitCategoryTravel;

  /// No description provided for @pursuitCategoryHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get pursuitCategoryHome;

  /// No description provided for @pursuitCategoryFashion.
  ///
  /// In en, this message translates to:
  /// **'Fashion'**
  String get pursuitCategoryFashion;

  /// No description provided for @pursuitCategoryVehicle.
  ///
  /// In en, this message translates to:
  /// **'Vehicle'**
  String get pursuitCategoryVehicle;

  /// No description provided for @pursuitCategoryEducation.
  ///
  /// In en, this message translates to:
  /// **'Education'**
  String get pursuitCategoryEducation;

  /// No description provided for @pursuitCategoryHealth.
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get pursuitCategoryHealth;

  /// No description provided for @pursuitCategoryOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get pursuitCategoryOther;

  /// No description provided for @emptyPursuitsTitle.
  ///
  /// In en, this message translates to:
  /// **'Take a Step Toward Your Dream'**
  String get emptyPursuitsTitle;

  /// No description provided for @emptyPursuitsMessage.
  ///
  /// In en, this message translates to:
  /// **'Add your first dream and start saving!'**
  String get emptyPursuitsMessage;

  /// No description provided for @addFirstPursuit.
  ///
  /// In en, this message translates to:
  /// **'Add Your First Dream'**
  String get addFirstPursuit;

  /// No description provided for @pursuitLimitReached.
  ///
  /// In en, this message translates to:
  /// **'Upgrade to Pro for unlimited dreams'**
  String get pursuitLimitReached;

  /// No description provided for @quickAmounts.
  ///
  /// In en, this message translates to:
  /// **'Quick Amounts'**
  String get quickAmounts;

  /// No description provided for @addNote.
  ///
  /// In en, this message translates to:
  /// **'Add note (optional)'**
  String get addNote;

  /// No description provided for @pursuitCreated.
  ///
  /// In en, this message translates to:
  /// **'Dream created!'**
  String get pursuitCreated;

  /// No description provided for @savingsAdded.
  ///
  /// In en, this message translates to:
  /// **'Added!'**
  String get savingsAdded;

  /// No description provided for @workHoursRemaining.
  ///
  /// In en, this message translates to:
  /// **'{hours} work hours remaining'**
  String workHoursRemaining(String hours);

  /// No description provided for @pursuitInitialSavings.
  ///
  /// In en, this message translates to:
  /// **'Initial Savings'**
  String get pursuitInitialSavings;

  /// No description provided for @pursuitInitialSavingsHint.
  ///
  /// In en, this message translates to:
  /// **'Amount you\'ve already saved'**
  String get pursuitInitialSavingsHint;

  /// No description provided for @pursuitSelectCategory.
  ///
  /// In en, this message translates to:
  /// **'Select Category'**
  String get pursuitSelectCategory;

  /// No description provided for @redirectSavings.
  ///
  /// In en, this message translates to:
  /// **'Redirect Savings to Dream'**
  String get redirectSavings;

  /// No description provided for @redirectSavingsMessage.
  ///
  /// In en, this message translates to:
  /// **'Which dream would you like to add the {amount} you saved?'**
  String redirectSavingsMessage(String amount);

  /// No description provided for @skipRedirect.
  ///
  /// In en, this message translates to:
  /// **'Skip for Now'**
  String get skipRedirect;

  /// No description provided for @pursuitTransactionHistory.
  ///
  /// In en, this message translates to:
  /// **'Transaction History'**
  String get pursuitTransactionHistory;

  /// No description provided for @noTransactions.
  ///
  /// In en, this message translates to:
  /// **'No transactions yet'**
  String get noTransactions;

  /// No description provided for @transactionSourceManual.
  ///
  /// In en, this message translates to:
  /// **'Manual Entry'**
  String get transactionSourceManual;

  /// No description provided for @transactionSourcePool.
  ///
  /// In en, this message translates to:
  /// **'Pool Transfer'**
  String get transactionSourcePool;

  /// No description provided for @transactionSourceExpense.
  ///
  /// In en, this message translates to:
  /// **'Cancelled Expense'**
  String get transactionSourceExpense;

  /// No description provided for @savingsPool.
  ///
  /// In en, this message translates to:
  /// **'Savings Pool'**
  String get savingsPool;

  /// No description provided for @savingsPoolAvailable.
  ///
  /// In en, this message translates to:
  /// **'available'**
  String get savingsPoolAvailable;

  /// No description provided for @savingsPoolDebt.
  ///
  /// In en, this message translates to:
  /// **'You owe'**
  String get savingsPoolDebt;

  /// No description provided for @shadowDebtMessage.
  ///
  /// In en, this message translates to:
  /// **'You borrowed {amount} from your future self'**
  String shadowDebtMessage(String amount);

  /// No description provided for @budgetShiftQuestion.
  ///
  /// In en, this message translates to:
  /// **'Where did this {amount} come from?'**
  String budgetShiftQuestion(String amount);

  /// No description provided for @jokerUsed.
  ///
  /// In en, this message translates to:
  /// **'You used this month\'s joker'**
  String get jokerUsed;

  /// No description provided for @jokerAvailable.
  ///
  /// In en, this message translates to:
  /// **'You have a joker available!'**
  String get jokerAvailable;

  /// No description provided for @allocatedToDreams.
  ///
  /// In en, this message translates to:
  /// **'{amount} allocated to dreams'**
  String allocatedToDreams(String amount);

  /// No description provided for @extraIncome.
  ///
  /// In en, this message translates to:
  /// **'I earned extra income'**
  String get extraIncome;

  /// No description provided for @useJoker.
  ///
  /// In en, this message translates to:
  /// **'Use Joker (1/month)'**
  String get useJoker;

  /// No description provided for @budgetShiftFromFood.
  ///
  /// In en, this message translates to:
  /// **'From my food budget'**
  String get budgetShiftFromFood;

  /// No description provided for @budgetShiftFromEntertainment.
  ///
  /// In en, this message translates to:
  /// **'From my entertainment budget'**
  String get budgetShiftFromEntertainment;

  /// No description provided for @budgetShiftFromClothing.
  ///
  /// In en, this message translates to:
  /// **'From my clothing budget'**
  String get budgetShiftFromClothing;

  /// No description provided for @budgetShiftFromTransport.
  ///
  /// In en, this message translates to:
  /// **'From my transport budget'**
  String get budgetShiftFromTransport;

  /// No description provided for @budgetShiftFromShopping.
  ///
  /// In en, this message translates to:
  /// **'From my shopping budget'**
  String get budgetShiftFromShopping;

  /// No description provided for @budgetShiftFromHealth.
  ///
  /// In en, this message translates to:
  /// **'From my health budget'**
  String get budgetShiftFromHealth;

  /// No description provided for @budgetShiftFromEducation.
  ///
  /// In en, this message translates to:
  /// **'From my education budget'**
  String get budgetShiftFromEducation;

  /// No description provided for @insufficientFunds.
  ///
  /// In en, this message translates to:
  /// **'Insufficient funds'**
  String get insufficientFunds;

  /// No description provided for @insufficientFundsMessage.
  ///
  /// In en, this message translates to:
  /// **'Pool has {available}, you want {requested}'**
  String insufficientFundsMessage(String available, String requested);

  /// No description provided for @createShadowDebt.
  ///
  /// In en, this message translates to:
  /// **'Add anyway (create debt)'**
  String get createShadowDebt;

  /// No description provided for @debtRepaidMessage.
  ///
  /// In en, this message translates to:
  /// **'{amount} paid towards your debt!'**
  String debtRepaidMessage(String amount);

  /// No description provided for @poolSummaryTotal.
  ///
  /// In en, this message translates to:
  /// **'Total Savings'**
  String get poolSummaryTotal;

  /// No description provided for @poolSummaryAllocated.
  ///
  /// In en, this message translates to:
  /// **'Allocated to Dreams'**
  String get poolSummaryAllocated;

  /// No description provided for @poolSummaryAvailable.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get poolSummaryAvailable;

  /// No description provided for @overAllocationTitle.
  ///
  /// In en, this message translates to:
  /// **'Insufficient Pool Balance'**
  String get overAllocationTitle;

  /// No description provided for @overAllocationMessage.
  ///
  /// In en, this message translates to:
  /// **'Pool has {available}. You want to add {requested}.'**
  String overAllocationMessage(String available, String requested);

  /// No description provided for @fromMyPocket.
  ///
  /// In en, this message translates to:
  /// **'Add from my pocket'**
  String get fromMyPocket;

  /// No description provided for @fromMyPocketDesc.
  ///
  /// In en, this message translates to:
  /// **'Zero out pool + add {difference} from pocket'**
  String fromMyPocketDesc(String difference);

  /// No description provided for @deductFromFuture.
  ///
  /// In en, this message translates to:
  /// **'Deduct from future savings'**
  String get deductFromFuture;

  /// No description provided for @deductFromFutureDesc.
  ///
  /// In en, this message translates to:
  /// **'Pool will go negative by {amount}'**
  String deductFromFutureDesc(String amount);

  /// No description provided for @transferAvailableOnly.
  ///
  /// In en, this message translates to:
  /// **'Transfer only {amount}'**
  String transferAvailableOnly(String amount);

  /// No description provided for @transferAvailableOnlyDesc.
  ///
  /// In en, this message translates to:
  /// **'Add only what\'s available in the pool'**
  String get transferAvailableOnlyDesc;

  /// No description provided for @oneTimeIncomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Where is this money from?'**
  String get oneTimeIncomeTitle;

  /// No description provided for @oneTimeIncomeDesc.
  ///
  /// In en, this message translates to:
  /// **'Your pool is in debt. Choose the source:'**
  String get oneTimeIncomeDesc;

  /// No description provided for @oneTimeIncomeOption.
  ///
  /// In en, this message translates to:
  /// **'One-time income'**
  String get oneTimeIncomeOption;

  /// No description provided for @oneTimeIncomeOptionDesc.
  ///
  /// In en, this message translates to:
  /// **'Doesn\'t affect the pool, goes directly to goal'**
  String get oneTimeIncomeOptionDesc;

  /// No description provided for @fromSavingsOption.
  ///
  /// In en, this message translates to:
  /// **'From my savings'**
  String get fromSavingsOption;

  /// No description provided for @fromSavingsOptionDesc.
  ///
  /// In en, this message translates to:
  /// **'Pool will go further negative'**
  String get fromSavingsOptionDesc;

  /// No description provided for @debtWarningOnPurchase.
  ///
  /// In en, this message translates to:
  /// **'You owe {amount} to your dreams!'**
  String debtWarningOnPurchase(String amount);

  /// No description provided for @debtReminderNotification.
  ///
  /// In en, this message translates to:
  /// **'Don\'t forget to pay off your debt to your dreams!'**
  String get debtReminderNotification;

  /// No description provided for @aiThinking.
  ///
  /// In en, this message translates to:
  /// **'Thinking...'**
  String get aiThinking;

  /// No description provided for @aiSuggestion1.
  ///
  /// In en, this message translates to:
  /// **'Where did I spend this month?'**
  String get aiSuggestion1;

  /// No description provided for @aiSuggestion2.
  ///
  /// In en, this message translates to:
  /// **'Where can I save money?'**
  String get aiSuggestion2;

  /// No description provided for @aiSuggestion3.
  ///
  /// In en, this message translates to:
  /// **'What\'s my most expensive habit?'**
  String get aiSuggestion3;

  /// No description provided for @aiSuggestion4.
  ///
  /// In en, this message translates to:
  /// **'How far am I from my goal?'**
  String get aiSuggestion4;

  /// No description provided for @aiPremiumUpsell.
  ///
  /// In en, this message translates to:
  /// **'Get detailed analysis and personal savings plan with Premium'**
  String get aiPremiumUpsell;

  /// No description provided for @aiPremiumButton.
  ///
  /// In en, this message translates to:
  /// **'Go Premium'**
  String get aiPremiumButton;

  /// No description provided for @aiInputPlaceholderFree.
  ///
  /// In en, this message translates to:
  /// **'Ask your own question 🔒'**
  String get aiInputPlaceholderFree;

  /// No description provided for @aiInputPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Ask something...'**
  String get aiInputPlaceholder;

  /// No description provided for @onboardingTryTitle.
  ///
  /// In en, this message translates to:
  /// **'Let\'s Try!'**
  String get onboardingTryTitle;

  /// No description provided for @onboardingTrySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Curious how long you\'d work for something?'**
  String get onboardingTrySubtitle;

  /// No description provided for @onboardingTryButton.
  ///
  /// In en, this message translates to:
  /// **'Calculate'**
  String get onboardingTryButton;

  /// No description provided for @onboardingTryDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'This was just to show how abstract money is and how concrete time is.'**
  String get onboardingTryDisclaimer;

  /// No description provided for @onboardingTryNotSaved.
  ///
  /// In en, this message translates to:
  /// **'Don\'t worry, this wasn\'t saved to your expenses.'**
  String get onboardingTryNotSaved;

  /// No description provided for @onboardingContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue to App'**
  String get onboardingContinue;

  /// No description provided for @onboardingTryResult.
  ///
  /// In en, this message translates to:
  /// **'This expense takes {hours} hours from your life'**
  String onboardingTryResult(String hours);

  /// No description provided for @subscriptionPriceHint.
  ///
  /// In en, this message translates to:
  /// **'\$9.99'**
  String get subscriptionPriceHint;

  /// No description provided for @currencyUpdatePopup.
  ///
  /// In en, this message translates to:
  /// **'Currency updating: {oldAmount} {oldCurrency} ≈ {newAmount} {newCurrency}'**
  String currencyUpdatePopup(
    String oldAmount,
    String oldCurrency,
    String newAmount,
    String newCurrency,
  );

  /// No description provided for @currencyConverting.
  ///
  /// In en, this message translates to:
  /// **'Converting currency...'**
  String get currencyConverting;

  /// No description provided for @currencyConversionFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not fetch exchange rate, values unchanged'**
  String get currencyConversionFailed;

  /// No description provided for @requiredExpense.
  ///
  /// In en, this message translates to:
  /// **'Required Expense'**
  String get requiredExpense;

  /// No description provided for @installmentPurchase.
  ///
  /// In en, this message translates to:
  /// **'Payment Plan'**
  String get installmentPurchase;

  /// No description provided for @installmentInfo.
  ///
  /// In en, this message translates to:
  /// **'Payment Plan Details'**
  String get installmentInfo;

  /// No description provided for @cashPrice.
  ///
  /// In en, this message translates to:
  /// **'Original Price'**
  String get cashPrice;

  /// No description provided for @cashPriceHint.
  ///
  /// In en, this message translates to:
  /// **'Price without financing'**
  String get cashPriceHint;

  /// No description provided for @numberOfInstallments.
  ///
  /// In en, this message translates to:
  /// **'Number of Payments'**
  String get numberOfInstallments;

  /// No description provided for @totalInstallmentPrice.
  ///
  /// In en, this message translates to:
  /// **'Total with Financing'**
  String get totalInstallmentPrice;

  /// No description provided for @totalWithInterestHint.
  ///
  /// In en, this message translates to:
  /// **'Total including fees'**
  String get totalWithInterestHint;

  /// No description provided for @installmentSummary.
  ///
  /// In en, this message translates to:
  /// **'PAYMENT PLAN SUMMARY'**
  String get installmentSummary;

  /// No description provided for @willBeSavedAsRequired.
  ///
  /// In en, this message translates to:
  /// **'Will be saved as required expense'**
  String get willBeSavedAsRequired;

  /// No description provided for @creditCardOrStoreInstallment.
  ///
  /// In en, this message translates to:
  /// **'Buy Now Pay Later (Affirm, Klarna, etc.)'**
  String get creditCardOrStoreInstallment;

  /// No description provided for @vantagAI.
  ///
  /// In en, this message translates to:
  /// **'Vantag AI'**
  String get vantagAI;

  /// No description provided for @professionalMode.
  ///
  /// In en, this message translates to:
  /// **'Professional mode'**
  String get professionalMode;

  /// No description provided for @friendlyMode.
  ///
  /// In en, this message translates to:
  /// **'Friendly mode'**
  String get friendlyMode;

  /// No description provided for @errorTryAgain.
  ///
  /// In en, this message translates to:
  /// **'An error occurred, try again?'**
  String get errorTryAgain;

  /// No description provided for @aiFallbackOverBudget.
  ///
  /// In en, this message translates to:
  /// **'Budget seems a bit tight.\nLet\'s see what we can do together?'**
  String get aiFallbackOverBudget;

  /// No description provided for @aiFallbackHighUsage.
  ///
  /// In en, this message translates to:
  /// **'End of month approaching, let\'s be careful.\nHow can I help?'**
  String get aiFallbackHighUsage;

  /// No description provided for @aiFallbackMediumUsage.
  ///
  /// In en, this message translates to:
  /// **'Budget is holding up.\nWant to ask something?'**
  String get aiFallbackMediumUsage;

  /// No description provided for @aiFallbackLowUsage.
  ///
  /// In en, this message translates to:
  /// **'Your budget is looking great!\nWhat should we analyze?'**
  String get aiFallbackLowUsage;

  /// No description provided for @aiInsights.
  ///
  /// In en, this message translates to:
  /// **'AI Insights'**
  String get aiInsights;

  /// No description provided for @mostSpendingDay.
  ///
  /// In en, this message translates to:
  /// **'Busiest Spending Day'**
  String get mostSpendingDay;

  /// No description provided for @biggestCategory.
  ///
  /// In en, this message translates to:
  /// **'Biggest Category'**
  String get biggestCategory;

  /// No description provided for @thisMonthVsLast.
  ///
  /// In en, this message translates to:
  /// **'This Month vs Last Month'**
  String get thisMonthVsLast;

  /// No description provided for @monday.
  ///
  /// In en, this message translates to:
  /// **'Monday'**
  String get monday;

  /// No description provided for @tuesday.
  ///
  /// In en, this message translates to:
  /// **'Tuesday'**
  String get tuesday;

  /// No description provided for @wednesday.
  ///
  /// In en, this message translates to:
  /// **'Wednesday'**
  String get wednesday;

  /// No description provided for @thursday.
  ///
  /// In en, this message translates to:
  /// **'Thursday'**
  String get thursday;

  /// No description provided for @friday.
  ///
  /// In en, this message translates to:
  /// **'Friday'**
  String get friday;

  /// No description provided for @saturday.
  ///
  /// In en, this message translates to:
  /// **'Saturday'**
  String get saturday;

  /// No description provided for @sunday.
  ///
  /// In en, this message translates to:
  /// **'Sunday'**
  String get sunday;

  /// No description provided for @securePayment.
  ///
  /// In en, this message translates to:
  /// **'Secure Payment'**
  String get securePayment;

  /// No description provided for @encrypted.
  ///
  /// In en, this message translates to:
  /// **'Encrypted'**
  String get encrypted;

  /// No description provided for @syncing.
  ///
  /// In en, this message translates to:
  /// **'Syncing data...'**
  String get syncing;

  /// No description provided for @pendingSync.
  ///
  /// In en, this message translates to:
  /// **'{count} changes pending sync'**
  String pendingSync(int count);

  /// No description provided for @pendingLabel.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pendingLabel;

  /// No description provided for @insightMinutes.
  ///
  /// In en, this message translates to:
  /// **'This expense took {minutes} minutes of your life.'**
  String insightMinutes(int minutes);

  /// No description provided for @insightHours.
  ///
  /// In en, this message translates to:
  /// **'This expense took {hours} hours of your life.'**
  String insightHours(String hours);

  /// No description provided for @insightAlmostDay.
  ///
  /// In en, this message translates to:
  /// **'You worked almost a full day for this expense.'**
  String get insightAlmostDay;

  /// No description provided for @insightDays.
  ///
  /// In en, this message translates to:
  /// **'This expense took {days} days of your life.'**
  String insightDays(String days);

  /// No description provided for @insightDaysWorked.
  ///
  /// In en, this message translates to:
  /// **'You had to work {days} days for this expense.'**
  String insightDaysWorked(String days);

  /// No description provided for @insightAlmostMonth.
  ///
  /// In en, this message translates to:
  /// **'This expense cost you almost a month of work.'**
  String get insightAlmostMonth;

  /// No description provided for @insightCategoryDays.
  ///
  /// In en, this message translates to:
  /// **'This month you worked {days} days for {category}.'**
  String insightCategoryDays(String category, String days);

  /// No description provided for @insightCategoryHours.
  ///
  /// In en, this message translates to:
  /// **'This month you worked {hours} hours for {category}.'**
  String insightCategoryHours(String category, String hours);

  /// No description provided for @insightMonthlyAlmost.
  ///
  /// In en, this message translates to:
  /// **'You worked almost the entire month for this month\'s expenses.'**
  String get insightMonthlyAlmost;

  /// No description provided for @insightMonthlyDays.
  ///
  /// In en, this message translates to:
  /// **'You worked {days} days for this month\'s expenses.'**
  String insightMonthlyDays(String days);

  /// No description provided for @msgShort1.
  ///
  /// In en, this message translates to:
  /// **'A few hours of work, for a fleeting desire?'**
  String get msgShort1;

  /// No description provided for @msgShort2.
  ///
  /// In en, this message translates to:
  /// **'Easy to spend what you earned in such short time, hard to earn it back.'**
  String get msgShort2;

  /// No description provided for @msgShort3.
  ///
  /// In en, this message translates to:
  /// **'You went to work this morning, this money will be gone before lunch.'**
  String get msgShort3;

  /// No description provided for @msgShort4.
  ///
  /// In en, this message translates to:
  /// **'You earned it in a coffee break, it\'ll be gone with one click.'**
  String get msgShort4;

  /// No description provided for @msgShort5.
  ///
  /// In en, this message translates to:
  /// **'Half a day\'s work, don\'t let it become a full day of regret.'**
  String get msgShort5;

  /// No description provided for @msgShort6.
  ///
  /// In en, this message translates to:
  /// **'Think about the hours you worked for this item.'**
  String get msgShort6;

  /// No description provided for @msgShort7.
  ///
  /// In en, this message translates to:
  /// **'Looks small but makes a big difference in total.'**
  String get msgShort7;

  /// No description provided for @msgShort8.
  ///
  /// In en, this message translates to:
  /// **'If not now, tomorrow works too.'**
  String get msgShort8;

  /// No description provided for @msgMedium1.
  ///
  /// In en, this message translates to:
  /// **'Is your week\'s work worth this item?'**
  String get msgMedium1;

  /// No description provided for @msgMedium2.
  ///
  /// In en, this message translates to:
  /// **'It took days to save this money, seconds to spend it.'**
  String get msgMedium2;

  /// No description provided for @msgMedium3.
  ///
  /// In en, this message translates to:
  /// **'Would you accept if you were investing a week into this?'**
  String get msgMedium3;

  /// No description provided for @msgMedium4.
  ///
  /// In en, this message translates to:
  /// **'Days of effort, a split-second decision.'**
  String get msgMedium4;

  /// No description provided for @msgMedium5.
  ///
  /// In en, this message translates to:
  /// **'A weekend getaway or this item?'**
  String get msgMedium5;

  /// No description provided for @msgMedium6.
  ///
  /// In en, this message translates to:
  /// **'Remember what you worked for all those days.'**
  String get msgMedium6;

  /// No description provided for @msgMedium7.
  ///
  /// In en, this message translates to:
  /// **'Did you work Monday to Friday for this?'**
  String get msgMedium7;

  /// No description provided for @msgMedium8.
  ///
  /// In en, this message translates to:
  /// **'Does it make sense to spend your weekly budget in one go?'**
  String get msgMedium8;

  /// No description provided for @msgLong1.
  ///
  /// In en, this message translates to:
  /// **'You need to work for weeks for this. Is it really worth it?'**
  String get msgLong1;

  /// No description provided for @msgLong2.
  ///
  /// In en, this message translates to:
  /// **'Saving this money could take months.'**
  String get msgLong2;

  /// No description provided for @msgLong3.
  ///
  /// In en, this message translates to:
  /// **'You might be delaying one of your long-term goals.'**
  String get msgLong3;

  /// No description provided for @msgLong4.
  ///
  /// In en, this message translates to:
  /// **'Does the time you\'ll spend on this affect your vacation plans?'**
  String get msgLong4;

  /// No description provided for @msgLong5.
  ///
  /// In en, this message translates to:
  /// **'Is this an investment or an expense?'**
  String get msgLong5;

  /// No description provided for @msgLong6.
  ///
  /// In en, this message translates to:
  /// **'How would future you evaluate this decision?'**
  String get msgLong6;

  /// No description provided for @msgLong7.
  ///
  /// In en, this message translates to:
  /// **'Working this long should be for something lasting.'**
  String get msgLong7;

  /// No description provided for @msgLong8.
  ///
  /// In en, this message translates to:
  /// **'How will you view this decision at month\'s end?'**
  String get msgLong8;

  /// No description provided for @msgSim1.
  ///
  /// In en, this message translates to:
  /// **'This amount isn\'t just spending anymore, it\'s a serious investment decision.'**
  String get msgSim1;

  /// No description provided for @msgSim2.
  ///
  /// In en, this message translates to:
  /// **'For such a large sum, decide with your vision, not your emotions.'**
  String get msgSim2;

  /// No description provided for @msgSim3.
  ///
  /// In en, this message translates to:
  /// **'It\'s hard to even calculate the time equivalent of this amount.'**
  String get msgSim3;

  /// No description provided for @msgSim4.
  ///
  /// In en, this message translates to:
  /// **'Could this be that big step you\'ve been dreaming of?'**
  String get msgSim4;

  /// No description provided for @msgSim5.
  ///
  /// In en, this message translates to:
  /// **'Managing such a large amount requires patience and strategy.'**
  String get msgSim5;

  /// No description provided for @msgSim6.
  ///
  /// In en, this message translates to:
  /// **'You\'re at a point that will affect your future, not just your wallet.'**
  String get msgSim6;

  /// No description provided for @msgSim7.
  ///
  /// In en, this message translates to:
  /// **'Big numbers bring big responsibilities. Are you ready?'**
  String get msgSim7;

  /// No description provided for @msgSim8.
  ///
  /// In en, this message translates to:
  /// **'Is this amount just a number to you, or a turning point?'**
  String get msgSim8;

  /// No description provided for @msgYes1.
  ///
  /// In en, this message translates to:
  /// **'Recorded. Hope it\'s worth it.'**
  String get msgYes1;

  /// No description provided for @msgYes2.
  ///
  /// In en, this message translates to:
  /// **'Let\'s see if you\'ll regret it.'**
  String get msgYes2;

  /// No description provided for @msgYes3.
  ///
  /// In en, this message translates to:
  /// **'Okay, it\'s your money.'**
  String get msgYes3;

  /// No description provided for @msgYes4.
  ///
  /// In en, this message translates to:
  /// **'You bought it, congratulations.'**
  String get msgYes4;

  /// No description provided for @msgYes5.
  ///
  /// In en, this message translates to:
  /// **'As you wish.'**
  String get msgYes5;

  /// No description provided for @msgYes6.
  ///
  /// In en, this message translates to:
  /// **'Alright, it\'s on the record.'**
  String get msgYes6;

  /// No description provided for @msgYes7.
  ///
  /// In en, this message translates to:
  /// **'If it\'s a need, no problem.'**
  String get msgYes7;

  /// No description provided for @msgYes8.
  ///
  /// In en, this message translates to:
  /// **'Sometimes spending is necessary too.'**
  String get msgYes8;

  /// No description provided for @msgNo1.
  ///
  /// In en, this message translates to:
  /// **'Great decision. You saved this money.'**
  String get msgNo1;

  /// No description provided for @msgNo2.
  ///
  /// In en, this message translates to:
  /// **'You chose the hard path, your future self will thank you.'**
  String get msgNo2;

  /// No description provided for @msgNo3.
  ///
  /// In en, this message translates to:
  /// **'Willpower won.'**
  String get msgNo3;

  /// No description provided for @msgNo4.
  ///
  /// In en, this message translates to:
  /// **'Smart move. You\'ll need this money.'**
  String get msgNo4;

  /// No description provided for @msgNo5.
  ///
  /// In en, this message translates to:
  /// **'Passing is also a win.'**
  String get msgNo5;

  /// No description provided for @msgNo6.
  ///
  /// In en, this message translates to:
  /// **'The urge passed, the money stayed.'**
  String get msgNo6;

  /// No description provided for @msgNo7.
  ///
  /// In en, this message translates to:
  /// **'You actually invested in yourself.'**
  String get msgNo7;

  /// No description provided for @msgNo8.
  ///
  /// In en, this message translates to:
  /// **'Hard decision, right decision.'**
  String get msgNo8;

  /// No description provided for @msgThink1.
  ///
  /// In en, this message translates to:
  /// **'Thinking is free, spending isn\'t.'**
  String get msgThink1;

  /// No description provided for @msgThink2.
  ///
  /// In en, this message translates to:
  /// **'Not rushing is smart.'**
  String get msgThink2;

  /// No description provided for @msgThink3.
  ///
  /// In en, this message translates to:
  /// **'Sleep on it, look again tomorrow.'**
  String get msgThink3;

  /// No description provided for @msgThink4.
  ///
  /// In en, this message translates to:
  /// **'Wait 24 hours, come back if you still want it.'**
  String get msgThink4;

  /// No description provided for @msgThink5.
  ///
  /// In en, this message translates to:
  /// **'If you\'re hesitating, it\'s probably not necessary.'**
  String get msgThink5;

  /// No description provided for @msgThink6.
  ///
  /// In en, this message translates to:
  /// **'Time is the best advisor.'**
  String get msgThink6;

  /// No description provided for @msgThink7.
  ///
  /// In en, this message translates to:
  /// **'If it\'s not urgent, don\'t rush.'**
  String get msgThink7;

  /// No description provided for @msgThink8.
  ///
  /// In en, this message translates to:
  /// **'If you\'re not sure, the answer is probably no.'**
  String get msgThink8;

  /// No description provided for @savingMsg1.
  ///
  /// In en, this message translates to:
  /// **'Great decision! 💪'**
  String get savingMsg1;

  /// No description provided for @savingMsg2.
  ///
  /// In en, this message translates to:
  /// **'You protected your money! 🛡️'**
  String get savingMsg2;

  /// No description provided for @savingMsg3.
  ///
  /// In en, this message translates to:
  /// **'Future you will thank you!'**
  String get savingMsg3;

  /// No description provided for @savingMsg4.
  ///
  /// In en, this message translates to:
  /// **'Smart choice! 🧠'**
  String get savingMsg4;

  /// No description provided for @savingMsg5.
  ///
  /// In en, this message translates to:
  /// **'Saving is power!'**
  String get savingMsg5;

  /// No description provided for @savingMsg6.
  ///
  /// In en, this message translates to:
  /// **'One step closer to your goal!'**
  String get savingMsg6;

  /// No description provided for @savingMsg7.
  ///
  /// In en, this message translates to:
  /// **'Willpower! 💎'**
  String get savingMsg7;

  /// No description provided for @savingMsg8.
  ///
  /// In en, this message translates to:
  /// **'This money is now yours!'**
  String get savingMsg8;

  /// No description provided for @savingMsg9.
  ///
  /// In en, this message translates to:
  /// **'Financial discipline! 🎯'**
  String get savingMsg9;

  /// No description provided for @savingMsg10.
  ///
  /// In en, this message translates to:
  /// **'You\'re building wealth!'**
  String get savingMsg10;

  /// No description provided for @savingMsg11.
  ///
  /// In en, this message translates to:
  /// **'Strong decision! 💪'**
  String get savingMsg11;

  /// No description provided for @savingMsg12.
  ///
  /// In en, this message translates to:
  /// **'Your wallet thanks you!'**
  String get savingMsg12;

  /// No description provided for @savingMsg13.
  ///
  /// In en, this message translates to:
  /// **'That\'s how champions save! 🏆'**
  String get savingMsg13;

  /// No description provided for @savingMsg14.
  ///
  /// In en, this message translates to:
  /// **'Money saved = Freedom earned!'**
  String get savingMsg14;

  /// No description provided for @savingMsg15.
  ///
  /// In en, this message translates to:
  /// **'Impressive self-control! ⭐'**
  String get savingMsg15;

  /// No description provided for @spendingMsg1.
  ///
  /// In en, this message translates to:
  /// **'Recorded! ✓'**
  String get spendingMsg1;

  /// No description provided for @spendingMsg2.
  ///
  /// In en, this message translates to:
  /// **'You\'re tracking, that\'s important.'**
  String get spendingMsg2;

  /// No description provided for @spendingMsg3.
  ///
  /// In en, this message translates to:
  /// **'Every record is awareness.'**
  String get spendingMsg3;

  /// No description provided for @spendingMsg4.
  ///
  /// In en, this message translates to:
  /// **'Knowing your spending is power.'**
  String get spendingMsg4;

  /// No description provided for @spendingMsg5.
  ///
  /// In en, this message translates to:
  /// **'Logged! Keep going.'**
  String get spendingMsg5;

  /// No description provided for @spendingMsg6.
  ///
  /// In en, this message translates to:
  /// **'Tracking builds control.'**
  String get spendingMsg6;

  /// No description provided for @spendingMsg7.
  ///
  /// In en, this message translates to:
  /// **'Noted! Awareness is key.'**
  String get spendingMsg7;

  /// No description provided for @spendingMsg8.
  ///
  /// In en, this message translates to:
  /// **'Good job tracking!'**
  String get spendingMsg8;

  /// No description provided for @spendingMsg9.
  ///
  /// In en, this message translates to:
  /// **'Data is power! 📊'**
  String get spendingMsg9;

  /// No description provided for @spendingMsg10.
  ///
  /// In en, this message translates to:
  /// **'Stay aware, stay in control.'**
  String get spendingMsg10;

  /// No description provided for @tourAmountTitle.
  ///
  /// In en, this message translates to:
  /// **'Amount Entry'**
  String get tourAmountTitle;

  /// No description provided for @tourAmountDesc.
  ///
  /// In en, this message translates to:
  /// **'Enter the expense amount here. You can automatically scan it from a receipt using the scan button.'**
  String get tourAmountDesc;

  /// No description provided for @tourDescriptionTitle.
  ///
  /// In en, this message translates to:
  /// **'Smart Matching'**
  String get tourDescriptionTitle;

  /// No description provided for @tourDescriptionDesc.
  ///
  /// In en, this message translates to:
  /// **'Enter the store or product name. Like Migros, A101, Starbucks... The app will automatically suggest a category!'**
  String get tourDescriptionDesc;

  /// No description provided for @tourCategoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Category Selection'**
  String get tourCategoryTitle;

  /// No description provided for @tourCategoryDesc.
  ///
  /// In en, this message translates to:
  /// **'If smart matching doesn\'t find it or you want to change it, you can manually select from here.'**
  String get tourCategoryDesc;

  /// No description provided for @tourDateTitle.
  ///
  /// In en, this message translates to:
  /// **'Past Date Selection'**
  String get tourDateTitle;

  /// No description provided for @tourDateDesc.
  ///
  /// In en, this message translates to:
  /// **'You can also enter expenses from yesterday or previous days. Click the calendar icon to select any date.'**
  String get tourDateDesc;

  /// No description provided for @tourSnapshotTitle.
  ///
  /// In en, this message translates to:
  /// **'Financial Summary'**
  String get tourSnapshotTitle;

  /// No description provided for @tourSnapshotDesc.
  ///
  /// In en, this message translates to:
  /// **'Your monthly income, expenses, and saved money are here. All data updates in real-time.'**
  String get tourSnapshotDesc;

  /// No description provided for @tourCurrencyTitle.
  ///
  /// In en, this message translates to:
  /// **'Exchange Rates'**
  String get tourCurrencyTitle;

  /// No description provided for @tourCurrencyDesc.
  ///
  /// In en, this message translates to:
  /// **'Current USD, EUR, and gold prices. Tap for detailed information.'**
  String get tourCurrencyDesc;

  /// No description provided for @tourStreakTitle.
  ///
  /// In en, this message translates to:
  /// **'Streak Tracking'**
  String get tourStreakTitle;

  /// No description provided for @tourStreakDesc.
  ///
  /// In en, this message translates to:
  /// **'Your streak increases every day you record an expense. Regular tracking is the key to mindful spending!'**
  String get tourStreakDesc;

  /// No description provided for @tourSubscriptionTitle.
  ///
  /// In en, this message translates to:
  /// **'Subscriptions'**
  String get tourSubscriptionTitle;

  /// No description provided for @tourSubscriptionDesc.
  ///
  /// In en, this message translates to:
  /// **'Track your regular subscriptions like Netflix, Spotify here. You\'ll get notifications for upcoming payments.'**
  String get tourSubscriptionDesc;

  /// No description provided for @tourReportTitle.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get tourReportTitle;

  /// No description provided for @tourReportDesc.
  ///
  /// In en, this message translates to:
  /// **'View monthly and category-based spending analysis here.'**
  String get tourReportDesc;

  /// No description provided for @tourAchievementsTitle.
  ///
  /// In en, this message translates to:
  /// **'Badges'**
  String get tourAchievementsTitle;

  /// No description provided for @tourAchievementsDesc.
  ///
  /// In en, this message translates to:
  /// **'Earn badges as you reach savings goals. Keep your motivation high!'**
  String get tourAchievementsDesc;

  /// No description provided for @tourProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile & Settings'**
  String get tourProfileTitle;

  /// No description provided for @tourProfileDesc.
  ///
  /// In en, this message translates to:
  /// **'Edit income info, manage notification preferences, and access app settings.'**
  String get tourProfileDesc;

  /// No description provided for @tourQuickAddTitle.
  ///
  /// In en, this message translates to:
  /// **'Quick Add'**
  String get tourQuickAddTitle;

  /// No description provided for @tourQuickAddDesc.
  ///
  /// In en, this message translates to:
  /// **'Use this button to quickly add expenses from anywhere. Practical and fast!'**
  String get tourQuickAddDesc;

  /// No description provided for @notifChannelName.
  ///
  /// In en, this message translates to:
  /// **'Vantag Notifications'**
  String get notifChannelName;

  /// No description provided for @notifChannelDescription.
  ///
  /// In en, this message translates to:
  /// **'Financial tracking notifications'**
  String get notifChannelDescription;

  /// No description provided for @notifTitleThinkAboutIt.
  ///
  /// In en, this message translates to:
  /// **'Think about it'**
  String get notifTitleThinkAboutIt;

  /// No description provided for @notifTitleCongratulations.
  ///
  /// In en, this message translates to:
  /// **'Congratulations'**
  String get notifTitleCongratulations;

  /// No description provided for @notifTitleStreakWaiting.
  ///
  /// In en, this message translates to:
  /// **'Your streak is waiting'**
  String get notifTitleStreakWaiting;

  /// No description provided for @notifTitleWeeklySummary.
  ///
  /// In en, this message translates to:
  /// **'Weekly summary'**
  String get notifTitleWeeklySummary;

  /// No description provided for @notifTitleSubscriptionReminder.
  ///
  /// In en, this message translates to:
  /// **'Subscription reminder'**
  String get notifTitleSubscriptionReminder;

  /// No description provided for @aiGreeting.
  ///
  /// In en, this message translates to:
  /// **'Hello! I\'m Vantag.\nReady to answer your financial questions.'**
  String get aiGreeting;

  /// No description provided for @aiServiceUnavailable.
  ///
  /// In en, this message translates to:
  /// **'AI assistant is currently unavailable. Please try again later.'**
  String get aiServiceUnavailable;

  /// No description provided for @onboardingHookTitle.
  ///
  /// In en, this message translates to:
  /// **'This coffee is 47 minutes'**
  String get onboardingHookTitle;

  /// No description provided for @onboardingHookSubtitle.
  ///
  /// In en, this message translates to:
  /// **'See the real cost of every purchase'**
  String get onboardingHookSubtitle;

  /// No description provided for @pursuitOnboardingTitle.
  ///
  /// In en, this message translates to:
  /// **'What\'s your goal?'**
  String get pursuitOnboardingTitle;

  /// No description provided for @pursuitOnboardingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Pick something to save for'**
  String get pursuitOnboardingSubtitle;

  /// No description provided for @pursuitOnboardingAirpods.
  ///
  /// In en, this message translates to:
  /// **'AirPods'**
  String get pursuitOnboardingAirpods;

  /// No description provided for @pursuitOnboardingIphone.
  ///
  /// In en, this message translates to:
  /// **'iPhone'**
  String get pursuitOnboardingIphone;

  /// No description provided for @pursuitOnboardingVacation.
  ///
  /// In en, this message translates to:
  /// **'Vacation'**
  String get pursuitOnboardingVacation;

  /// No description provided for @pursuitOnboardingCustom.
  ///
  /// In en, this message translates to:
  /// **'My own goal'**
  String get pursuitOnboardingCustom;

  /// No description provided for @pursuitOnboardingCta.
  ///
  /// In en, this message translates to:
  /// **'I want this'**
  String get pursuitOnboardingCta;

  /// No description provided for @pursuitOnboardingSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip for now'**
  String get pursuitOnboardingSkip;

  /// No description provided for @pursuitOnboardingHours.
  ///
  /// In en, this message translates to:
  /// **'{hours} hours'**
  String pursuitOnboardingHours(int hours);

  /// No description provided for @celebrationTitle.
  ///
  /// In en, this message translates to:
  /// **'Congratulations!'**
  String get celebrationTitle;

  /// No description provided for @celebrationSubtitle.
  ///
  /// In en, this message translates to:
  /// **'You reached your {goalName} goal!'**
  String celebrationSubtitle(String goalName);

  /// No description provided for @celebrationTotalSaved.
  ///
  /// In en, this message translates to:
  /// **'Total saved: {hours} hours'**
  String celebrationTotalSaved(String hours);

  /// No description provided for @celebrationDuration.
  ///
  /// In en, this message translates to:
  /// **'Duration: {days} days'**
  String celebrationDuration(int days);

  /// No description provided for @celebrationShare.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get celebrationShare;

  /// No description provided for @celebrationNewGoal.
  ///
  /// In en, this message translates to:
  /// **'New Goal'**
  String get celebrationNewGoal;

  /// No description provided for @celebrationDismiss.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get celebrationDismiss;

  /// No description provided for @widgetTodayLabel.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get widgetTodayLabel;

  /// No description provided for @widgetHoursAbbrev.
  ///
  /// In en, this message translates to:
  /// **'h'**
  String get widgetHoursAbbrev;

  /// No description provided for @widgetMinutesAbbrev.
  ///
  /// In en, this message translates to:
  /// **'m'**
  String get widgetMinutesAbbrev;

  /// No description provided for @widgetSetGoal.
  ///
  /// In en, this message translates to:
  /// **'Set a goal'**
  String get widgetSetGoal;

  /// No description provided for @widgetNoData.
  ///
  /// In en, this message translates to:
  /// **'Open app to start'**
  String get widgetNoData;

  /// No description provided for @widgetSmallTitle.
  ///
  /// In en, this message translates to:
  /// **'Daily Spending'**
  String get widgetSmallTitle;

  /// No description provided for @widgetSmallDesc.
  ///
  /// In en, this message translates to:
  /// **'See today\'s spending in hours'**
  String get widgetSmallDesc;

  /// No description provided for @widgetMediumTitle.
  ///
  /// In en, this message translates to:
  /// **'Spending + Goal'**
  String get widgetMediumTitle;

  /// No description provided for @widgetMediumDesc.
  ///
  /// In en, this message translates to:
  /// **'Track spending and goal progress'**
  String get widgetMediumDesc;

  /// No description provided for @accessibilityTodaySpending.
  ///
  /// In en, this message translates to:
  /// **'Today you spent {amount}, equal to {hours} hours {minutes} minutes of work'**
  String accessibilityTodaySpending(String amount, int hours, int minutes);

  /// No description provided for @accessibilitySpendingProgress.
  ///
  /// In en, this message translates to:
  /// **'Spending progress: {percentage} percent of budget used'**
  String accessibilitySpendingProgress(int percentage);

  /// No description provided for @accessibilityExpenseItem.
  ///
  /// In en, this message translates to:
  /// **'{category} expense of {amount}, took {hours} hours, status: {decision}'**
  String accessibilityExpenseItem(
    String category,
    String amount,
    String hours,
    String decision,
  );

  /// No description provided for @accessibilityPursuitCard.
  ///
  /// In en, this message translates to:
  /// **'{name} goal, {saved} of {target} saved, {percentage} percent complete'**
  String accessibilityPursuitCard(
    String name,
    String saved,
    String target,
    int percentage,
  );

  /// No description provided for @accessibilityAddExpense.
  ///
  /// In en, this message translates to:
  /// **'Add new expense'**
  String get accessibilityAddExpense;

  /// No description provided for @accessibilityDecisionYes.
  ///
  /// In en, this message translates to:
  /// **'Purchased'**
  String get accessibilityDecisionYes;

  /// No description provided for @accessibilityDecisionNo.
  ///
  /// In en, this message translates to:
  /// **'Passed'**
  String get accessibilityDecisionNo;

  /// No description provided for @accessibilityDecisionThinking.
  ///
  /// In en, this message translates to:
  /// **'Thinking'**
  String get accessibilityDecisionThinking;

  /// No description provided for @accessibilityDashboard.
  ///
  /// In en, this message translates to:
  /// **'Financial dashboard showing income, expenses and balance'**
  String get accessibilityDashboard;

  /// No description provided for @accessibilityNetBalance.
  ///
  /// In en, this message translates to:
  /// **'Net balance: {amount}, {status}'**
  String accessibilityNetBalance(String amount, String status);

  /// No description provided for @accessibilityBalanceHealthy.
  ///
  /// In en, this message translates to:
  /// **'in the green'**
  String get accessibilityBalanceHealthy;

  /// No description provided for @accessibilityBalanceNegative.
  ///
  /// In en, this message translates to:
  /// **'in the red'**
  String get accessibilityBalanceNegative;

  /// No description provided for @accessibilityIncomeTotal.
  ///
  /// In en, this message translates to:
  /// **'Total income: {amount}'**
  String accessibilityIncomeTotal(String amount);

  /// No description provided for @accessibilityExpenseTotal.
  ///
  /// In en, this message translates to:
  /// **'Total expenses: {amount}'**
  String accessibilityExpenseTotal(String amount);

  /// No description provided for @accessibilityAddSavings.
  ///
  /// In en, this message translates to:
  /// **'Add savings to this goal'**
  String get accessibilityAddSavings;

  /// No description provided for @accessibilityDeleteExpense.
  ///
  /// In en, this message translates to:
  /// **'Delete this expense'**
  String get accessibilityDeleteExpense;

  /// No description provided for @accessibilityEditExpense.
  ///
  /// In en, this message translates to:
  /// **'Edit this expense'**
  String get accessibilityEditExpense;

  /// No description provided for @accessibilityShareExpense.
  ///
  /// In en, this message translates to:
  /// **'Share this expense'**
  String get accessibilityShareExpense;

  /// No description provided for @accessibilityStreakInfo.
  ///
  /// In en, this message translates to:
  /// **'Current streak: {days} days, best streak: {best} days'**
  String accessibilityStreakInfo(int days, int best);

  /// No description provided for @accessibilityAiChatInput.
  ///
  /// In en, this message translates to:
  /// **'Type your financial question here'**
  String get accessibilityAiChatInput;

  /// No description provided for @accessibilityAiSendButton.
  ///
  /// In en, this message translates to:
  /// **'Send message to AI assistant'**
  String get accessibilityAiSendButton;

  /// No description provided for @accessibilitySuggestionButton.
  ///
  /// In en, this message translates to:
  /// **'Quick question: {question}'**
  String accessibilitySuggestionButton(String question);

  /// No description provided for @accessibilitySubscriptionCard.
  ///
  /// In en, this message translates to:
  /// **'{name} subscription, {amount} per {cycle}, renews on day {day}'**
  String accessibilitySubscriptionCard(
    String name,
    String amount,
    String cycle,
    int day,
  );

  /// No description provided for @accessibilitySettingsItem.
  ///
  /// In en, this message translates to:
  /// **'{title}, current value: {value}'**
  String accessibilitySettingsItem(String title, String value);

  /// No description provided for @accessibilityToggleOn.
  ///
  /// In en, this message translates to:
  /// **'Enabled'**
  String get accessibilityToggleOn;

  /// No description provided for @accessibilityToggleOff.
  ///
  /// In en, this message translates to:
  /// **'Disabled'**
  String get accessibilityToggleOff;

  /// No description provided for @accessibilityCloseSheet.
  ///
  /// In en, this message translates to:
  /// **'Close this sheet'**
  String get accessibilityCloseSheet;

  /// No description provided for @accessibilityBackButton.
  ///
  /// In en, this message translates to:
  /// **'Go back'**
  String get accessibilityBackButton;

  /// No description provided for @accessibilityProfileButton.
  ///
  /// In en, this message translates to:
  /// **'Open profile menu'**
  String get accessibilityProfileButton;

  /// No description provided for @accessibilityNotificationsButton.
  ///
  /// In en, this message translates to:
  /// **'View notifications'**
  String get accessibilityNotificationsButton;

  /// No description provided for @navHomeTooltip.
  ///
  /// In en, this message translates to:
  /// **'Home, spending overview'**
  String get navHomeTooltip;

  /// No description provided for @navPursuitsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Goals, savings targets'**
  String get navPursuitsTooltip;

  /// No description provided for @navReportsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Reports, spending analysis'**
  String get navReportsTooltip;

  /// No description provided for @navSettingsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Settings and preferences'**
  String get navSettingsTooltip;

  /// No description provided for @shareDefaultMessage.
  ///
  /// In en, this message translates to:
  /// **'I track my expenses in hours! Try it: {link}'**
  String shareDefaultMessage(String link);

  /// No description provided for @shareInviteLink.
  ///
  /// In en, this message translates to:
  /// **'Share Invite Link'**
  String get shareInviteLink;

  /// No description provided for @inviteFriends.
  ///
  /// In en, this message translates to:
  /// **'Invite Friends'**
  String get inviteFriends;

  /// No description provided for @yourReferralCode.
  ///
  /// In en, this message translates to:
  /// **'Your referral code'**
  String get yourReferralCode;

  /// No description provided for @referralStats.
  ///
  /// In en, this message translates to:
  /// **'{count} friends joined'**
  String referralStats(int count);

  /// No description provided for @referralRewardInfo.
  ///
  /// In en, this message translates to:
  /// **'Earn 7 days premium for each friend!'**
  String get referralRewardInfo;

  /// No description provided for @codeCopied.
  ///
  /// In en, this message translates to:
  /// **'Code copied!'**
  String get codeCopied;

  /// No description provided for @haveReferralCode.
  ///
  /// In en, this message translates to:
  /// **'Have a referral code?'**
  String get haveReferralCode;

  /// No description provided for @referralCodeHint.
  ///
  /// In en, this message translates to:
  /// **'Enter code (optional)'**
  String get referralCodeHint;

  /// No description provided for @referralCodePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'VANTAG-XXXXX'**
  String get referralCodePlaceholder;

  /// No description provided for @referralSuccess.
  ///
  /// In en, this message translates to:
  /// **'{name} joined Vantag! +7 days premium'**
  String referralSuccess(String name);

  /// No description provided for @welcomeReferred.
  ///
  /// In en, this message translates to:
  /// **'Welcome! You have 7 days premium trial'**
  String get welcomeReferred;

  /// No description provided for @referralInvalidCode.
  ///
  /// In en, this message translates to:
  /// **'Invalid referral code'**
  String get referralInvalidCode;

  /// No description provided for @referralCodeApplied.
  ///
  /// In en, this message translates to:
  /// **'Referral code applied!'**
  String get referralCodeApplied;

  /// No description provided for @referralSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Referrals'**
  String get referralSectionTitle;

  /// No description provided for @referralShareDescription.
  ///
  /// In en, this message translates to:
  /// **'Share your code and earn premium days'**
  String get referralShareDescription;

  /// No description provided for @trialMidpointTitle.
  ///
  /// In en, this message translates to:
  /// **'Halfway there! ⏳'**
  String get trialMidpointTitle;

  /// No description provided for @trialMidpointBody.
  ///
  /// In en, this message translates to:
  /// **'Your trial is halfway done. You\'ve saved {hours} hours so far!'**
  String trialMidpointBody(String hours);

  /// No description provided for @trialOneDayLeftTitle.
  ///
  /// In en, this message translates to:
  /// **'Trial ends tomorrow ⏰'**
  String get trialOneDayLeftTitle;

  /// No description provided for @trialOneDayLeftBody.
  ///
  /// In en, this message translates to:
  /// **'Go premium to keep tracking your savings!'**
  String get trialOneDayLeftBody;

  /// No description provided for @trialEndsTodayTitle.
  ///
  /// In en, this message translates to:
  /// **'Last day of trial! 🎁'**
  String get trialEndsTodayTitle;

  /// No description provided for @trialEndsTodayBody.
  ///
  /// In en, this message translates to:
  /// **'Get 50% off if you upgrade today!'**
  String get trialEndsTodayBody;

  /// No description provided for @trialExpiredTitle.
  ///
  /// In en, this message translates to:
  /// **'We miss you! 💜'**
  String get trialExpiredTitle;

  /// No description provided for @trialExpiredBody.
  ///
  /// In en, this message translates to:
  /// **'Come back and continue reaching your goals'**
  String get trialExpiredBody;

  /// No description provided for @dailyReminderTitle.
  ///
  /// In en, this message translates to:
  /// **'Don\'t forget to log! 📝'**
  String get dailyReminderTitle;

  /// No description provided for @dailyReminderBody.
  ///
  /// In en, this message translates to:
  /// **'Track today\'s spending in just seconds'**
  String get dailyReminderBody;

  /// No description provided for @notificationSettingsDesc.
  ///
  /// In en, this message translates to:
  /// **'Reminders and updates'**
  String get notificationSettingsDesc;

  /// No description provided for @firstExpenseTitle.
  ///
  /// In en, this message translates to:
  /// **'Great start! 🎉'**
  String get firstExpenseTitle;

  /// No description provided for @firstExpenseBody.
  ///
  /// In en, this message translates to:
  /// **'You saved {hours} hours today!'**
  String firstExpenseBody(String hours);

  /// No description provided for @trialReminderEnabled.
  ///
  /// In en, this message translates to:
  /// **'Trial reminders'**
  String get trialReminderEnabled;

  /// No description provided for @trialReminderDesc.
  ///
  /// In en, this message translates to:
  /// **'Get notified before your trial ends'**
  String get trialReminderDesc;

  /// No description provided for @dailyReminderEnabled.
  ///
  /// In en, this message translates to:
  /// **'Daily reminders'**
  String get dailyReminderEnabled;

  /// No description provided for @dailyReminderDesc.
  ///
  /// In en, this message translates to:
  /// **'Evening reminder to log expenses'**
  String get dailyReminderDesc;

  /// No description provided for @dailyReminderTime.
  ///
  /// In en, this message translates to:
  /// **'Reminder time'**
  String get dailyReminderTime;

  /// No description provided for @trialDaysRemaining.
  ///
  /// In en, this message translates to:
  /// **'{days} days left in trial'**
  String trialDaysRemaining(int days);

  /// No description provided for @subscriptionReminder.
  ///
  /// In en, this message translates to:
  /// **'Subscription reminders'**
  String get subscriptionReminder;

  /// No description provided for @subscriptionReminderDesc.
  ///
  /// In en, this message translates to:
  /// **'Get notified before subscriptions renew'**
  String get subscriptionReminderDesc;

  /// No description provided for @thinkingReminder.
  ///
  /// In en, this message translates to:
  /// **'\"Thinking\" reminders'**
  String get thinkingReminder;

  /// No description provided for @thinkingReminderDesc.
  ///
  /// In en, this message translates to:
  /// **'Get reminded after 72 hours about items you\'re still thinking about'**
  String get thinkingReminderDesc;

  /// No description provided for @thinkingReminderTitle.
  ///
  /// In en, this message translates to:
  /// **'Still thinking?'**
  String get thinkingReminderTitle;

  /// No description provided for @thinkingReminderBody.
  ///
  /// In en, this message translates to:
  /// **'Did you decide? {item}'**
  String thinkingReminderBody(String item);

  /// No description provided for @willRemindIn72h.
  ///
  /// In en, this message translates to:
  /// **'We\'ll remind you in 72 hours'**
  String get willRemindIn72h;

  /// No description provided for @thinkingAbout.
  ///
  /// In en, this message translates to:
  /// **'Thinking about'**
  String get thinkingAbout;

  /// No description provided for @addedDaysAgo.
  ///
  /// In en, this message translates to:
  /// **'Added {days} days ago'**
  String addedDaysAgo(int days);

  /// No description provided for @stillThinking.
  ///
  /// In en, this message translates to:
  /// **'Still thinking?'**
  String get stillThinking;

  /// No description provided for @stillThinkingMessage.
  ///
  /// In en, this message translates to:
  /// **'It\'s been 72 hours. Did you decide?'**
  String get stillThinkingMessage;

  /// No description provided for @decidedYes.
  ///
  /// In en, this message translates to:
  /// **'I bought it'**
  String get decidedYes;

  /// No description provided for @decidedNo.
  ///
  /// In en, this message translates to:
  /// **'I passed'**
  String get decidedNo;

  /// No description provided for @aiChatLimitReached.
  ///
  /// In en, this message translates to:
  /// **'You\'ve used your 4 daily AI chats. Go premium for unlimited!'**
  String get aiChatLimitReached;

  /// No description provided for @aiChatsRemaining.
  ///
  /// In en, this message translates to:
  /// **'{count} chats left today'**
  String aiChatsRemaining(int count);

  /// No description provided for @pursuitLimitReachedFree.
  ///
  /// In en, this message translates to:
  /// **'Free accounts can have 1 active goal. Go premium for unlimited goals!'**
  String get pursuitLimitReachedFree;

  /// No description provided for @pursuitNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter a name'**
  String get pursuitNameRequired;

  /// No description provided for @pursuitAmountRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter an amount'**
  String get pursuitAmountRequired;

  /// No description provided for @pursuitAmountInvalid.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid amount'**
  String get pursuitAmountInvalid;

  /// No description provided for @exportPremiumOnly.
  ///
  /// In en, this message translates to:
  /// **'Export is a premium feature'**
  String get exportPremiumOnly;

  /// No description provided for @multiCurrencyPremium.
  ///
  /// In en, this message translates to:
  /// **'Multiple currencies is a premium feature. Free users can only use TRY.'**
  String get multiCurrencyPremium;

  /// No description provided for @reportsPremiumOnly.
  ///
  /// In en, this message translates to:
  /// **'Monthly and yearly reports are premium features'**
  String get reportsPremiumOnly;

  /// No description provided for @upgradeToPremium.
  ///
  /// In en, this message translates to:
  /// **'Upgrade to Premium'**
  String get upgradeToPremium;

  /// No description provided for @premiumIncludes.
  ///
  /// In en, this message translates to:
  /// **'Premium includes:'**
  String get premiumIncludes;

  /// No description provided for @unlimitedAiChat.
  ///
  /// In en, this message translates to:
  /// **'Unlimited AI chat'**
  String get unlimitedAiChat;

  /// No description provided for @unlimitedPursuits.
  ///
  /// In en, this message translates to:
  /// **'Unlimited goals'**
  String get unlimitedPursuits;

  /// No description provided for @exportFeature.
  ///
  /// In en, this message translates to:
  /// **'Export your data'**
  String get exportFeature;

  /// No description provided for @allCurrencies.
  ///
  /// In en, this message translates to:
  /// **'All currencies'**
  String get allCurrencies;

  /// No description provided for @fullReports.
  ///
  /// In en, this message translates to:
  /// **'Full reports'**
  String get fullReports;

  /// No description provided for @cleanShareCards.
  ///
  /// In en, this message translates to:
  /// **'Clean share cards (no watermark)'**
  String get cleanShareCards;

  /// No description provided for @maybeLater.
  ///
  /// In en, this message translates to:
  /// **'Maybe later'**
  String get maybeLater;

  /// No description provided for @seePremium.
  ///
  /// In en, this message translates to:
  /// **'See Premium'**
  String get seePremium;

  /// No description provided for @weeklyOnly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get weeklyOnly;

  /// No description provided for @monthlyPro.
  ///
  /// In en, this message translates to:
  /// **'Monthly (Pro)'**
  String get monthlyPro;

  /// No description provided for @yearlyPro.
  ///
  /// In en, this message translates to:
  /// **'Yearly (Pro)'**
  String get yearlyPro;

  /// No description provided for @currencyLocked.
  ///
  /// In en, this message translates to:
  /// **'Premium only'**
  String get currencyLocked;

  /// No description provided for @freeUserCurrencyNote.
  ///
  /// In en, this message translates to:
  /// **'Free users can only use TRY. Upgrade to use {currency}.'**
  String freeUserCurrencyNote(String currency);

  /// No description provided for @watermarkText.
  ///
  /// In en, this message translates to:
  /// **'vantag.app'**
  String get watermarkText;

  /// No description provided for @incomeTypeSalary.
  ///
  /// In en, this message translates to:
  /// **'Salary'**
  String get incomeTypeSalary;

  /// No description provided for @incomeTypeBonus.
  ///
  /// In en, this message translates to:
  /// **'Bonus'**
  String get incomeTypeBonus;

  /// No description provided for @incomeTypeGift.
  ///
  /// In en, this message translates to:
  /// **'Gift'**
  String get incomeTypeGift;

  /// No description provided for @incomeTypeRefund.
  ///
  /// In en, this message translates to:
  /// **'Refund'**
  String get incomeTypeRefund;

  /// No description provided for @incomeTypeFreelance.
  ///
  /// In en, this message translates to:
  /// **'Freelance'**
  String get incomeTypeFreelance;

  /// No description provided for @incomeTypeRental.
  ///
  /// In en, this message translates to:
  /// **'Rental'**
  String get incomeTypeRental;

  /// No description provided for @incomeTypeInvestment.
  ///
  /// In en, this message translates to:
  /// **'Investment'**
  String get incomeTypeInvestment;

  /// No description provided for @incomeTypeOther.
  ///
  /// In en, this message translates to:
  /// **'Other Income'**
  String get incomeTypeOther;

  /// No description provided for @salaryDay.
  ///
  /// In en, this message translates to:
  /// **'Salary Day'**
  String get salaryDay;

  /// No description provided for @salaryDayTitle.
  ///
  /// In en, this message translates to:
  /// **'When do you get paid?'**
  String get salaryDayTitle;

  /// No description provided for @salaryDaySubtitle.
  ///
  /// In en, this message translates to:
  /// **'We\'ll remind you on payday'**
  String get salaryDaySubtitle;

  /// No description provided for @salaryDayHint.
  ///
  /// In en, this message translates to:
  /// **'Select day of month (1-31)'**
  String get salaryDayHint;

  /// No description provided for @salaryDaySet.
  ///
  /// In en, this message translates to:
  /// **'Salary day set to {day}'**
  String salaryDaySet(int day);

  /// No description provided for @salaryDaySkip.
  ///
  /// In en, this message translates to:
  /// **'Skip for now'**
  String get salaryDaySkip;

  /// No description provided for @salaryDayNotSet.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get salaryDayNotSet;

  /// No description provided for @currentBalance.
  ///
  /// In en, this message translates to:
  /// **'Current Balance'**
  String get currentBalance;

  /// No description provided for @balanceTitle.
  ///
  /// In en, this message translates to:
  /// **'What\'s your current balance?'**
  String get balanceTitle;

  /// No description provided for @balanceSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Track your spending more accurately'**
  String get balanceSubtitle;

  /// No description provided for @balanceHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your bank balance'**
  String get balanceHint;

  /// No description provided for @balanceUpdated.
  ///
  /// In en, this message translates to:
  /// **'Balance updated'**
  String get balanceUpdated;

  /// No description provided for @balanceOptional.
  ///
  /// In en, this message translates to:
  /// **'Optional - you can add this later'**
  String get balanceOptional;

  /// No description provided for @paydayTitle.
  ///
  /// In en, this message translates to:
  /// **'Payday!'**
  String get paydayTitle;

  /// No description provided for @paydayMessage.
  ///
  /// In en, this message translates to:
  /// **'Did you receive your salary?'**
  String get paydayMessage;

  /// No description provided for @paydayConfirm.
  ///
  /// In en, this message translates to:
  /// **'Yes, received!'**
  String get paydayConfirm;

  /// No description provided for @paydayNotYet.
  ///
  /// In en, this message translates to:
  /// **'Not yet'**
  String get paydayNotYet;

  /// No description provided for @paydaySkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get paydaySkip;

  /// No description provided for @paydayCelebration.
  ///
  /// In en, this message translates to:
  /// **'Congratulations! Salary received'**
  String get paydayCelebration;

  /// No description provided for @paydayUpdateBalance.
  ///
  /// In en, this message translates to:
  /// **'Update your balance'**
  String get paydayUpdateBalance;

  /// No description provided for @paydayNewBalance.
  ///
  /// In en, this message translates to:
  /// **'New balance after salary'**
  String get paydayNewBalance;

  /// No description provided for @daysUntilPayday.
  ///
  /// In en, this message translates to:
  /// **'{days} days until payday'**
  String daysUntilPayday(int days);

  /// No description provided for @paydayToday.
  ///
  /// In en, this message translates to:
  /// **'Payday is today!'**
  String get paydayToday;

  /// No description provided for @paydayTomorrow.
  ///
  /// In en, this message translates to:
  /// **'Payday is tomorrow'**
  String get paydayTomorrow;

  /// No description provided for @addIncomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Record Income'**
  String get addIncomeTitle;

  /// No description provided for @addIncomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Bonus, gift, refund, etc.'**
  String get addIncomeSubtitle;

  /// No description provided for @incomeAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount received'**
  String get incomeAmount;

  /// No description provided for @incomeNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes (optional)'**
  String get incomeNotes;

  /// No description provided for @incomeNotesHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Year-end bonus, birthday gift...'**
  String get incomeNotesHint;

  /// No description provided for @incomeAdded.
  ///
  /// In en, this message translates to:
  /// **'Income added!'**
  String get incomeAdded;

  /// No description provided for @incomeAddedBalance.
  ///
  /// In en, this message translates to:
  /// **'Balance updated: {amount}'**
  String incomeAddedBalance(String amount);

  /// No description provided for @thisMonthIncome.
  ///
  /// In en, this message translates to:
  /// **'This Month\'s Income'**
  String get thisMonthIncome;

  /// No description provided for @regularIncome.
  ///
  /// In en, this message translates to:
  /// **'Regular Income'**
  String get regularIncome;

  /// No description provided for @additionalIncome.
  ///
  /// In en, this message translates to:
  /// **'Additional Income'**
  String get additionalIncome;

  /// No description provided for @incomeBreakdown.
  ///
  /// In en, this message translates to:
  /// **'Income Breakdown'**
  String get incomeBreakdown;

  /// No description provided for @paydayNotificationTitle.
  ///
  /// In en, this message translates to:
  /// **'Payday!'**
  String get paydayNotificationTitle;

  /// No description provided for @paydayNotificationBody.
  ///
  /// In en, this message translates to:
  /// **'Your salary should be arriving today. Check your account!'**
  String get paydayNotificationBody;

  /// No description provided for @paydayNotificationEnabled.
  ///
  /// In en, this message translates to:
  /// **'Payday reminders'**
  String get paydayNotificationEnabled;

  /// No description provided for @paydayNotificationDesc.
  ///
  /// In en, this message translates to:
  /// **'Get notified on your salary day'**
  String get paydayNotificationDesc;

  /// No description provided for @onboardingSalaryDayTitle.
  ///
  /// In en, this message translates to:
  /// **'When\'s Payday?'**
  String get onboardingSalaryDayTitle;

  /// No description provided for @onboardingSalaryDayDesc.
  ///
  /// In en, this message translates to:
  /// **'Tell us when you receive your salary so we can help you budget better'**
  String get onboardingSalaryDayDesc;

  /// No description provided for @onboardingBalanceTitle.
  ///
  /// In en, this message translates to:
  /// **'Starting Balance'**
  String get onboardingBalanceTitle;

  /// No description provided for @onboardingBalanceDesc.
  ///
  /// In en, this message translates to:
  /// **'Enter your current balance to track your finances accurately'**
  String get onboardingBalanceDesc;

  /// No description provided for @onboardingV2Step1Title.
  ///
  /// In en, this message translates to:
  /// **'See expenses differently'**
  String get onboardingV2Step1Title;

  /// No description provided for @onboardingV2Step1Subtitle.
  ///
  /// In en, this message translates to:
  /// **'See how many hours each purchase costs you'**
  String get onboardingV2Step1Subtitle;

  /// No description provided for @onboardingV2Step1Demo.
  ///
  /// In en, this message translates to:
  /// **'\$500 phone = 20 hours of work'**
  String get onboardingV2Step1Demo;

  /// No description provided for @onboardingV2Step1Cta.
  ///
  /// In en, this message translates to:
  /// **'Calculate'**
  String get onboardingV2Step1Cta;

  /// No description provided for @onboardingV2Step2Title.
  ///
  /// In en, this message translates to:
  /// **'Let\'s get to know you'**
  String get onboardingV2Step2Title;

  /// No description provided for @onboardingV2Step2Income.
  ///
  /// In en, this message translates to:
  /// **'Monthly income'**
  String get onboardingV2Step2Income;

  /// No description provided for @onboardingV2Step2Hours.
  ///
  /// In en, this message translates to:
  /// **'Daily work hours'**
  String get onboardingV2Step2Hours;

  /// No description provided for @onboardingV2Step2Days.
  ///
  /// In en, this message translates to:
  /// **'Work days per week'**
  String get onboardingV2Step2Days;

  /// No description provided for @onboardingV2Step2Cta.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get onboardingV2Step2Cta;

  /// No description provided for @onboardingV2Step3Title.
  ///
  /// In en, this message translates to:
  /// **'Add your first expense'**
  String get onboardingV2Step3Title;

  /// No description provided for @onboardingV2Step3Subtitle.
  ///
  /// In en, this message translates to:
  /// **'See its value in hours'**
  String get onboardingV2Step3Subtitle;

  /// No description provided for @onboardingV2Step3Result.
  ///
  /// In en, this message translates to:
  /// **'= {hours}h {minutes}m'**
  String onboardingV2Step3Result(int hours, int minutes);

  /// No description provided for @onboardingV2Step3Success.
  ///
  /// In en, this message translates to:
  /// **'Great! Now you\'ll know the true cost of every purchase'**
  String get onboardingV2Step3Success;

  /// No description provided for @onboardingV2Step3Cta.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get onboardingV2Step3Cta;

  /// No description provided for @onboardingV2SkipSetup.
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get onboardingV2SkipSetup;

  /// No description provided for @onboardingV2Progress.
  ///
  /// In en, this message translates to:
  /// **'Step {current}/{total}'**
  String onboardingV2Progress(int current, int total);

  /// No description provided for @checklistTitle.
  ///
  /// In en, this message translates to:
  /// **'Getting Started'**
  String get checklistTitle;

  /// No description provided for @checklistProgress.
  ///
  /// In en, this message translates to:
  /// **'{completed}/{total} completed'**
  String checklistProgress(int completed, int total);

  /// No description provided for @checklistFirstExpenseTitle.
  ///
  /// In en, this message translates to:
  /// **'Add your first expense'**
  String get checklistFirstExpenseTitle;

  /// No description provided for @checklistFirstExpenseSubtitle.
  ///
  /// In en, this message translates to:
  /// **'See its value in hours'**
  String get checklistFirstExpenseSubtitle;

  /// No description provided for @checklistViewReportTitle.
  ///
  /// In en, this message translates to:
  /// **'View your report'**
  String get checklistViewReportTitle;

  /// No description provided for @checklistViewReportSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Discover spending patterns'**
  String get checklistViewReportSubtitle;

  /// No description provided for @checklistCreatePursuitTitle.
  ///
  /// In en, this message translates to:
  /// **'Set a savings goal'**
  String get checklistCreatePursuitTitle;

  /// No description provided for @checklistCreatePursuitSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Start saving for something'**
  String get checklistCreatePursuitSubtitle;

  /// No description provided for @checklistNotificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Enable notifications'**
  String get checklistNotificationsTitle;

  /// No description provided for @checklistNotificationsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Get daily reminders'**
  String get checklistNotificationsSubtitle;

  /// No description provided for @checklistCelebrationTitle.
  ///
  /// In en, this message translates to:
  /// **'Great start!'**
  String get checklistCelebrationTitle;

  /// No description provided for @checklistCelebrationSubtitle.
  ///
  /// In en, this message translates to:
  /// **'You\'re ready to use Vantag'**
  String get checklistCelebrationSubtitle;

  /// No description provided for @emptyStateExampleTitle.
  ///
  /// In en, this message translates to:
  /// **'Example'**
  String get emptyStateExampleTitle;

  /// No description provided for @emptyStateExpensesMessage.
  ///
  /// In en, this message translates to:
  /// **'See how many hours each purchase costs you'**
  String get emptyStateExpensesMessage;

  /// No description provided for @emptyStateExpensesCta.
  ///
  /// In en, this message translates to:
  /// **'Add Expense'**
  String get emptyStateExpensesCta;

  /// No description provided for @emptyStatePursuitsMessage.
  ///
  /// In en, this message translates to:
  /// **'Set a goal and track your progress'**
  String get emptyStatePursuitsMessage;

  /// No description provided for @emptyStatePursuitsCta.
  ///
  /// In en, this message translates to:
  /// **'Create Goal'**
  String get emptyStatePursuitsCta;

  /// No description provided for @emptyStateReportsMessage.
  ///
  /// In en, this message translates to:
  /// **'Discover your spending patterns'**
  String get emptyStateReportsMessage;

  /// No description provided for @emptyStateReportsCta.
  ///
  /// In en, this message translates to:
  /// **'Add Expense'**
  String get emptyStateReportsCta;

  /// No description provided for @emptyStateSubscriptionsMessage.
  ///
  /// In en, this message translates to:
  /// **'Track your subscriptions, never forget'**
  String get emptyStateSubscriptionsMessage;

  /// No description provided for @emptyStateSubscriptionsCta.
  ///
  /// In en, this message translates to:
  /// **'Add Subscription'**
  String get emptyStateSubscriptionsCta;

  /// No description provided for @emptyStateAchievementsMessage.
  ///
  /// In en, this message translates to:
  /// **'Add expenses to earn badges'**
  String get emptyStateAchievementsMessage;

  /// No description provided for @emptyStateSavingsPoolMessage.
  ///
  /// In en, this message translates to:
  /// **'Pool your savings together'**
  String get emptyStateSavingsPoolMessage;

  /// No description provided for @milestone3DayStreakTitle.
  ///
  /// In en, this message translates to:
  /// **'3 Day Streak!'**
  String get milestone3DayStreakTitle;

  /// No description provided for @milestone3DayStreakMessage.
  ///
  /// In en, this message translates to:
  /// **'Great start, keep going!'**
  String get milestone3DayStreakMessage;

  /// No description provided for @milestone7DayStreakTitle.
  ///
  /// In en, this message translates to:
  /// **'1 Week Streak!'**
  String get milestone7DayStreakTitle;

  /// No description provided for @milestone7DayStreakMessage.
  ///
  /// In en, this message translates to:
  /// **'A whole week of tracking'**
  String get milestone7DayStreakMessage;

  /// No description provided for @milestone14DayStreakTitle.
  ///
  /// In en, this message translates to:
  /// **'2 Week Streak!'**
  String get milestone14DayStreakTitle;

  /// No description provided for @milestone14DayStreakMessage.
  ///
  /// In en, this message translates to:
  /// **'You\'re building a habit'**
  String get milestone14DayStreakMessage;

  /// No description provided for @milestone30DayStreakTitle.
  ///
  /// In en, this message translates to:
  /// **'1 Month Streak!'**
  String get milestone30DayStreakTitle;

  /// No description provided for @milestone30DayStreakMessage.
  ///
  /// In en, this message translates to:
  /// **'A full month! Incredible'**
  String get milestone30DayStreakMessage;

  /// No description provided for @milestone60DayStreakTitle.
  ///
  /// In en, this message translates to:
  /// **'2 Month Streak!'**
  String get milestone60DayStreakTitle;

  /// No description provided for @milestone60DayStreakMessage.
  ///
  /// In en, this message translates to:
  /// **'You\'re a financial awareness pro'**
  String get milestone60DayStreakMessage;

  /// No description provided for @milestone100DayStreakTitle.
  ///
  /// In en, this message translates to:
  /// **'100 Day Streak!'**
  String get milestone100DayStreakTitle;

  /// No description provided for @milestone100DayStreakMessage.
  ///
  /// In en, this message translates to:
  /// **'Legendary achievement! You\'re a champion'**
  String get milestone100DayStreakMessage;

  /// No description provided for @milestoneFirstSavedTitle.
  ///
  /// In en, this message translates to:
  /// **'First Savings!'**
  String get milestoneFirstSavedTitle;

  /// No description provided for @milestoneFirstSavedMessage.
  ///
  /// In en, this message translates to:
  /// **'You saved your first money'**
  String get milestoneFirstSavedMessage;

  /// No description provided for @milestoneSaved100Title.
  ///
  /// In en, this message translates to:
  /// **'Saved \$100!'**
  String get milestoneSaved100Title;

  /// No description provided for @milestoneSaved100Message.
  ///
  /// In en, this message translates to:
  /// **'Your savings habit is growing'**
  String get milestoneSaved100Message;

  /// No description provided for @milestoneSaved1000Title.
  ///
  /// In en, this message translates to:
  /// **'Saved \$1,000!'**
  String get milestoneSaved1000Title;

  /// No description provided for @milestoneSaved1000Message.
  ///
  /// In en, this message translates to:
  /// **'You\'re saving seriously'**
  String get milestoneSaved1000Message;

  /// No description provided for @milestoneSaved5000Title.
  ///
  /// In en, this message translates to:
  /// **'Saved \$5,000!'**
  String get milestoneSaved5000Title;

  /// No description provided for @milestoneSaved5000Message.
  ///
  /// In en, this message translates to:
  /// **'You\'re a savings master!'**
  String get milestoneSaved5000Message;

  /// No description provided for @milestoneFirstExpenseTitle.
  ///
  /// In en, this message translates to:
  /// **'First Step!'**
  String get milestoneFirstExpenseTitle;

  /// No description provided for @milestoneFirstExpenseMessage.
  ///
  /// In en, this message translates to:
  /// **'You logged your first expense'**
  String get milestoneFirstExpenseMessage;

  /// No description provided for @milestone10ExpensesTitle.
  ///
  /// In en, this message translates to:
  /// **'10 Expenses!'**
  String get milestone10ExpensesTitle;

  /// No description provided for @milestone10ExpensesMessage.
  ///
  /// In en, this message translates to:
  /// **'You have a tracking habit now'**
  String get milestone10ExpensesMessage;

  /// No description provided for @milestone50ExpensesTitle.
  ///
  /// In en, this message translates to:
  /// **'50 Expenses!'**
  String get milestone50ExpensesTitle;

  /// No description provided for @milestone50ExpensesMessage.
  ///
  /// In en, this message translates to:
  /// **'You\'re a financial awareness pro'**
  String get milestone50ExpensesMessage;

  /// No description provided for @milestoneFirstPursuitTitle.
  ///
  /// In en, this message translates to:
  /// **'First Goal!'**
  String get milestoneFirstPursuitTitle;

  /// No description provided for @milestoneFirstPursuitMessage.
  ///
  /// In en, this message translates to:
  /// **'Your savings journey has begun'**
  String get milestoneFirstPursuitMessage;

  /// No description provided for @milestoneFirstPursuitCompletedTitle.
  ///
  /// In en, this message translates to:
  /// **'Goal Completed!'**
  String get milestoneFirstPursuitCompletedTitle;

  /// No description provided for @milestoneFirstPursuitCompletedMessage.
  ///
  /// In en, this message translates to:
  /// **'You reached your first goal!'**
  String get milestoneFirstPursuitCompletedMessage;

  /// No description provided for @milestoneUsedAiChatTitle.
  ///
  /// In en, this message translates to:
  /// **'AI Discovery!'**
  String get milestoneUsedAiChatTitle;

  /// No description provided for @milestoneUsedAiChatMessage.
  ///
  /// In en, this message translates to:
  /// **'You met your financial assistant'**
  String get milestoneUsedAiChatMessage;

  /// No description provided for @selectTimeFilter.
  ///
  /// In en, this message translates to:
  /// **'Select time filter: {filter}'**
  String selectTimeFilter(String filter);

  /// No description provided for @lockedFilterPremium.
  ///
  /// In en, this message translates to:
  /// **'{filter}, premium feature'**
  String lockedFilterPremium(String filter);

  /// No description provided for @selectedFilter.
  ///
  /// In en, this message translates to:
  /// **'{filter}, selected'**
  String selectedFilter(String filter);

  /// No description provided for @selectHeatmapDay.
  ///
  /// In en, this message translates to:
  /// **'Select day: {date}'**
  String selectHeatmapDay(String date);

  /// No description provided for @heatmapDayWithSpending.
  ///
  /// In en, this message translates to:
  /// **'{date}, {amount} spent'**
  String heatmapDayWithSpending(String date, String amount);

  /// No description provided for @heatmapDayNoSpending.
  ///
  /// In en, this message translates to:
  /// **'{date}, no spending'**
  String heatmapDayNoSpending(String date);

  /// No description provided for @loggedOutFromAnotherDevice.
  ///
  /// In en, this message translates to:
  /// **'Logged In From Another Device'**
  String get loggedOutFromAnotherDevice;

  /// No description provided for @loggedOutFromAnotherDeviceMessage.
  ///
  /// In en, this message translates to:
  /// **'Your account was accessed from another device. For security reasons, you have been signed out from this device.'**
  String get loggedOutFromAnotherDeviceMessage;

  /// No description provided for @multiCurrencyProTitle.
  ///
  /// In en, this message translates to:
  /// **'Multi-Currency'**
  String get multiCurrencyProTitle;

  /// No description provided for @multiCurrencyProDescription.
  ///
  /// In en, this message translates to:
  /// **'Upgrade to Pro to enter income and expenses in different currencies. Use USD, EUR, GBP and more.'**
  String get multiCurrencyProDescription;

  /// No description provided for @multiCurrencyBenefit.
  ///
  /// In en, this message translates to:
  /// **'All currencies available'**
  String get multiCurrencyBenefit;

  /// No description provided for @currencyLockedForFree.
  ///
  /// In en, this message translates to:
  /// **'Currency change is a Pro feature'**
  String get currencyLockedForFree;

  /// No description provided for @excelSheetExpenses.
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get excelSheetExpenses;

  /// No description provided for @excelSheetSummary.
  ///
  /// In en, this message translates to:
  /// **'Summary'**
  String get excelSheetSummary;

  /// No description provided for @excelSheetCategories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get excelSheetCategories;

  /// No description provided for @excelSheetTimeAnalysis.
  ///
  /// In en, this message translates to:
  /// **'Time Analysis'**
  String get excelSheetTimeAnalysis;

  /// No description provided for @excelSheetDecisions.
  ///
  /// In en, this message translates to:
  /// **'Decisions'**
  String get excelSheetDecisions;

  /// No description provided for @excelSheetInstallments.
  ///
  /// In en, this message translates to:
  /// **'Installments'**
  String get excelSheetInstallments;

  /// No description provided for @excelHeaderDay.
  ///
  /// In en, this message translates to:
  /// **'Day'**
  String get excelHeaderDay;

  /// No description provided for @excelHeaderStore.
  ///
  /// In en, this message translates to:
  /// **'Store/Location'**
  String get excelHeaderStore;

  /// No description provided for @excelHeaderMinutes.
  ///
  /// In en, this message translates to:
  /// **'Minutes Equiv.'**
  String get excelHeaderMinutes;

  /// No description provided for @excelHeaderMonthlyInstallment.
  ///
  /// In en, this message translates to:
  /// **'Monthly Payment'**
  String get excelHeaderMonthlyInstallment;

  /// No description provided for @excelHeaderInstallmentCount.
  ///
  /// In en, this message translates to:
  /// **'Installment'**
  String get excelHeaderInstallmentCount;

  /// No description provided for @excelHeaderSimulation.
  ///
  /// In en, this message translates to:
  /// **'Simulation'**
  String get excelHeaderSimulation;

  /// No description provided for @excelHeaderHoursEquiv.
  ///
  /// In en, this message translates to:
  /// **'Hours Equiv.'**
  String get excelHeaderHoursEquiv;

  /// No description provided for @excelReportTitle.
  ///
  /// In en, this message translates to:
  /// **'Vantag Financial Report'**
  String get excelReportTitle;

  /// No description provided for @excelReportPeriod.
  ///
  /// In en, this message translates to:
  /// **'Report Period'**
  String get excelReportPeriod;

  /// No description provided for @excelReportGeneratedAt.
  ///
  /// In en, this message translates to:
  /// **'Generated'**
  String get excelReportGeneratedAt;

  /// No description provided for @excelTotalExpenses.
  ///
  /// In en, this message translates to:
  /// **'Total Expenses'**
  String get excelTotalExpenses;

  /// No description provided for @excelTotalTransactions.
  ///
  /// In en, this message translates to:
  /// **'Total Transactions'**
  String get excelTotalTransactions;

  /// No description provided for @excelAvgPerTransaction.
  ///
  /// In en, this message translates to:
  /// **'Average per Transaction'**
  String get excelAvgPerTransaction;

  /// No description provided for @excelMonthlyAverage.
  ///
  /// In en, this message translates to:
  /// **'Monthly Average'**
  String get excelMonthlyAverage;

  /// No description provided for @excelDailyAverage.
  ///
  /// In en, this message translates to:
  /// **'Daily Average'**
  String get excelDailyAverage;

  /// No description provided for @excelWeeklyAverage.
  ///
  /// In en, this message translates to:
  /// **'Weekly Average'**
  String get excelWeeklyAverage;

  /// No description provided for @excelSavingsRate.
  ///
  /// In en, this message translates to:
  /// **'Savings Rate'**
  String get excelSavingsRate;

  /// No description provided for @excelTotalWorkHours.
  ///
  /// In en, this message translates to:
  /// **'Total Work Hours'**
  String get excelTotalWorkHours;

  /// No description provided for @excelTotalWorkDays.
  ///
  /// In en, this message translates to:
  /// **'Total Work Days'**
  String get excelTotalWorkDays;

  /// No description provided for @excelCategoryShare.
  ///
  /// In en, this message translates to:
  /// **'Share %'**
  String get excelCategoryShare;

  /// No description provided for @excelCategoryRank.
  ///
  /// In en, this message translates to:
  /// **'Rank'**
  String get excelCategoryRank;

  /// No description provided for @excelTopCategory.
  ///
  /// In en, this message translates to:
  /// **'Top Category'**
  String get excelTopCategory;

  /// No description provided for @excelCategoryCount.
  ///
  /// In en, this message translates to:
  /// **'Transaction Count'**
  String get excelCategoryCount;

  /// No description provided for @excelCategoryAvg.
  ///
  /// In en, this message translates to:
  /// **'Category Average'**
  String get excelCategoryAvg;

  /// No description provided for @excelCategoryTotal.
  ///
  /// In en, this message translates to:
  /// **'Category Total'**
  String get excelCategoryTotal;

  /// No description provided for @excelCategoryHours.
  ///
  /// In en, this message translates to:
  /// **'Work Hours'**
  String get excelCategoryHours;

  /// No description provided for @excelTimeTitle.
  ///
  /// In en, this message translates to:
  /// **'Time Analysis'**
  String get excelTimeTitle;

  /// No description provided for @excelMostActiveDay.
  ///
  /// In en, this message translates to:
  /// **'Most Active Day'**
  String get excelMostActiveDay;

  /// No description provided for @excelMostActiveHour.
  ///
  /// In en, this message translates to:
  /// **'Most Active Hour'**
  String get excelMostActiveHour;

  /// No description provided for @excelWeekdayAvg.
  ///
  /// In en, this message translates to:
  /// **'Weekday Average'**
  String get excelWeekdayAvg;

  /// No description provided for @excelWeekendAvg.
  ///
  /// In en, this message translates to:
  /// **'Weekend Average'**
  String get excelWeekendAvg;

  /// No description provided for @excelMorningSpend.
  ///
  /// In en, this message translates to:
  /// **'Morning (06-12)'**
  String get excelMorningSpend;

  /// No description provided for @excelAfternoonSpend.
  ///
  /// In en, this message translates to:
  /// **'Afternoon (12-18)'**
  String get excelAfternoonSpend;

  /// No description provided for @excelEveningSpend.
  ///
  /// In en, this message translates to:
  /// **'Evening (18-24)'**
  String get excelEveningSpend;

  /// No description provided for @excelNightSpend.
  ///
  /// In en, this message translates to:
  /// **'Night (00-06)'**
  String get excelNightSpend;

  /// No description provided for @excelByDayOfWeek.
  ///
  /// In en, this message translates to:
  /// **'By Day of Week'**
  String get excelByDayOfWeek;

  /// No description provided for @excelByHour.
  ///
  /// In en, this message translates to:
  /// **'By Hour'**
  String get excelByHour;

  /// No description provided for @excelByMonth.
  ///
  /// In en, this message translates to:
  /// **'By Month'**
  String get excelByMonth;

  /// No description provided for @excelDecisionsBought.
  ///
  /// In en, this message translates to:
  /// **'Bought'**
  String get excelDecisionsBought;

  /// No description provided for @excelDecisionsThinking.
  ///
  /// In en, this message translates to:
  /// **'Thinking'**
  String get excelDecisionsThinking;

  /// No description provided for @excelDecisionsPassed.
  ///
  /// In en, this message translates to:
  /// **'Passed'**
  String get excelDecisionsPassed;

  /// No description provided for @excelDecisionCount.
  ///
  /// In en, this message translates to:
  /// **'Count'**
  String get excelDecisionCount;

  /// No description provided for @excelDecisionAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get excelDecisionAmount;

  /// No description provided for @excelDecisionPercent.
  ///
  /// In en, this message translates to:
  /// **'Percentage'**
  String get excelDecisionPercent;

  /// No description provided for @excelDecisionAvg.
  ///
  /// In en, this message translates to:
  /// **'Average'**
  String get excelDecisionAvg;

  /// No description provided for @excelDecisionHours.
  ///
  /// In en, this message translates to:
  /// **'Work Hours'**
  String get excelDecisionHours;

  /// No description provided for @excelImpulseRate.
  ///
  /// In en, this message translates to:
  /// **'Impulse Rate'**
  String get excelImpulseRate;

  /// No description provided for @excelSavingsFromPassed.
  ///
  /// In en, this message translates to:
  /// **'Savings from Passed'**
  String get excelSavingsFromPassed;

  /// No description provided for @excelPotentialSavings.
  ///
  /// In en, this message translates to:
  /// **'Potential Savings (Thinking)'**
  String get excelPotentialSavings;

  /// No description provided for @excelInstallmentName.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get excelInstallmentName;

  /// No description provided for @excelInstallmentTotal.
  ///
  /// In en, this message translates to:
  /// **'Total Amount'**
  String get excelInstallmentTotal;

  /// No description provided for @excelInstallmentMonthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly Payment'**
  String get excelInstallmentMonthly;

  /// No description provided for @excelInstallmentProgress.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get excelInstallmentProgress;

  /// No description provided for @excelInstallmentRemaining.
  ///
  /// In en, this message translates to:
  /// **'Remaining'**
  String get excelInstallmentRemaining;

  /// No description provided for @excelInstallmentStartDate.
  ///
  /// In en, this message translates to:
  /// **'Start Date'**
  String get excelInstallmentStartDate;

  /// No description provided for @excelInstallmentEndDate.
  ///
  /// In en, this message translates to:
  /// **'End Date'**
  String get excelInstallmentEndDate;

  /// No description provided for @excelInstallmentInterest.
  ///
  /// In en, this message translates to:
  /// **'Fees / Interest'**
  String get excelInstallmentInterest;

  /// No description provided for @excelNoInstallments.
  ///
  /// In en, this message translates to:
  /// **'No payment plans'**
  String get excelNoInstallments;

  /// No description provided for @excelTotalMonthlyPayments.
  ///
  /// In en, this message translates to:
  /// **'Total Monthly Payments'**
  String get excelTotalMonthlyPayments;

  /// No description provided for @excelTotalRemainingDebt.
  ///
  /// In en, this message translates to:
  /// **'Total Remaining Debt'**
  String get excelTotalRemainingDebt;

  /// No description provided for @excelDayMonday.
  ///
  /// In en, this message translates to:
  /// **'Monday'**
  String get excelDayMonday;

  /// No description provided for @excelDayTuesday.
  ///
  /// In en, this message translates to:
  /// **'Tuesday'**
  String get excelDayTuesday;

  /// No description provided for @excelDayWednesday.
  ///
  /// In en, this message translates to:
  /// **'Wednesday'**
  String get excelDayWednesday;

  /// No description provided for @excelDayThursday.
  ///
  /// In en, this message translates to:
  /// **'Thursday'**
  String get excelDayThursday;

  /// No description provided for @excelDayFriday.
  ///
  /// In en, this message translates to:
  /// **'Friday'**
  String get excelDayFriday;

  /// No description provided for @excelDaySaturday.
  ///
  /// In en, this message translates to:
  /// **'Saturday'**
  String get excelDaySaturday;

  /// No description provided for @excelDaySunday.
  ///
  /// In en, this message translates to:
  /// **'Sunday'**
  String get excelDaySunday;

  /// No description provided for @excelYes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get excelYes;

  /// No description provided for @excelNo.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get excelNo;

  /// No description provided for @excelReal.
  ///
  /// In en, this message translates to:
  /// **'Real'**
  String get excelReal;

  /// No description provided for @excelSimulation.
  ///
  /// In en, this message translates to:
  /// **'Simulation'**
  String get excelSimulation;

  /// No description provided for @proFeaturesSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Pro Feature'**
  String get proFeaturesSheetTitle;

  /// No description provided for @proFeaturesSheetSubtitle.
  ///
  /// In en, this message translates to:
  /// **'This feature is exclusive to Pro members'**
  String get proFeaturesSheetSubtitle;

  /// No description provided for @proFeaturesIncluded.
  ///
  /// In en, this message translates to:
  /// **'Pro membership includes:'**
  String get proFeaturesIncluded;

  /// No description provided for @proFeatureHeatmap.
  ///
  /// In en, this message translates to:
  /// **'Expense Heatmap'**
  String get proFeatureHeatmap;

  /// No description provided for @proFeatureHeatmapDesc.
  ///
  /// In en, this message translates to:
  /// **'Visualize your spending patterns over the year'**
  String get proFeatureHeatmapDesc;

  /// No description provided for @proFeatureCategoryBreakdown.
  ///
  /// In en, this message translates to:
  /// **'Category Breakdown'**
  String get proFeatureCategoryBreakdown;

  /// No description provided for @proFeatureCategoryBreakdownDesc.
  ///
  /// In en, this message translates to:
  /// **'Detailed pie chart analysis by category'**
  String get proFeatureCategoryBreakdownDesc;

  /// No description provided for @proFeatureSpendingTrends.
  ///
  /// In en, this message translates to:
  /// **'Spending Trends'**
  String get proFeatureSpendingTrends;

  /// No description provided for @proFeatureSpendingTrendsDesc.
  ///
  /// In en, this message translates to:
  /// **'Track your spending changes over time'**
  String get proFeatureSpendingTrendsDesc;

  /// No description provided for @proFeatureTimeAnalysis.
  ///
  /// In en, this message translates to:
  /// **'Time Analysis'**
  String get proFeatureTimeAnalysis;

  /// No description provided for @proFeatureTimeAnalysisDesc.
  ///
  /// In en, this message translates to:
  /// **'See when you spend most by day and hour'**
  String get proFeatureTimeAnalysisDesc;

  /// No description provided for @proFeatureBudgetBreakdown.
  ///
  /// In en, this message translates to:
  /// **'Budget Breakdown'**
  String get proFeatureBudgetBreakdown;

  /// No description provided for @proFeatureBudgetBreakdownDesc.
  ///
  /// In en, this message translates to:
  /// **'Track spending against your budget goals'**
  String get proFeatureBudgetBreakdownDesc;

  /// No description provided for @proFeatureAdvancedFilters.
  ///
  /// In en, this message translates to:
  /// **'Advanced Filters'**
  String get proFeatureAdvancedFilters;

  /// No description provided for @proFeatureAdvancedFiltersDesc.
  ///
  /// In en, this message translates to:
  /// **'Filter by month, all-time, and more'**
  String get proFeatureAdvancedFiltersDesc;

  /// No description provided for @proFeatureExcelExport.
  ///
  /// In en, this message translates to:
  /// **'Excel Export'**
  String get proFeatureExcelExport;

  /// No description provided for @proFeatureExcelExportDesc.
  ///
  /// In en, this message translates to:
  /// **'Export your complete financial data'**
  String get proFeatureExcelExportDesc;

  /// No description provided for @proFeatureUnlimitedHistory.
  ///
  /// In en, this message translates to:
  /// **'Unlimited History'**
  String get proFeatureUnlimitedHistory;

  /// No description provided for @proFeatureUnlimitedHistoryDesc.
  ///
  /// In en, this message translates to:
  /// **'Access all your past expenses'**
  String get proFeatureUnlimitedHistoryDesc;

  /// No description provided for @goProButton.
  ///
  /// In en, this message translates to:
  /// **'Go Pro'**
  String get goProButton;

  /// No description provided for @lockedFeatureTapToUnlock.
  ///
  /// In en, this message translates to:
  /// **'Tap to unlock'**
  String get lockedFeatureTapToUnlock;

  /// No description provided for @voiceUsageIndicator.
  ///
  /// In en, this message translates to:
  /// **'{used}/{total} voice inputs today'**
  String voiceUsageIndicator(int used, int total);

  /// No description provided for @aiChatUsageIndicator.
  ///
  /// In en, this message translates to:
  /// **'{used}/{total} questions today'**
  String aiChatUsageIndicator(int used, int total);

  /// No description provided for @dailyLimitReached.
  ///
  /// In en, this message translates to:
  /// **'Daily limit reached'**
  String get dailyLimitReached;

  /// No description provided for @dailyLimitReachedDesc.
  ///
  /// In en, this message translates to:
  /// **'You\'ve used all your daily quota. Upgrade to Pro for unlimited access!'**
  String get dailyLimitReachedDesc;

  /// No description provided for @unlimitedWithPro.
  ///
  /// In en, this message translates to:
  /// **'Unlimited with Pro'**
  String get unlimitedWithPro;

  /// No description provided for @backupData.
  ///
  /// In en, this message translates to:
  /// **'Backup Data'**
  String get backupData;

  /// No description provided for @backupDataDesc.
  ///
  /// In en, this message translates to:
  /// **'Export your data as a JSON file'**
  String get backupDataDesc;

  /// No description provided for @restoreData.
  ///
  /// In en, this message translates to:
  /// **'Restore Data'**
  String get restoreData;

  /// No description provided for @restoreDataDesc.
  ///
  /// In en, this message translates to:
  /// **'Import data from a backup file'**
  String get restoreDataDesc;

  /// No description provided for @backupCreating.
  ///
  /// In en, this message translates to:
  /// **'Creating backup...'**
  String get backupCreating;

  /// No description provided for @backupSuccess.
  ///
  /// In en, this message translates to:
  /// **'Backup created successfully'**
  String get backupSuccess;

  /// No description provided for @backupError.
  ///
  /// In en, this message translates to:
  /// **'Failed to create backup'**
  String get backupError;

  /// No description provided for @restoreConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Restore Data?'**
  String get restoreConfirmTitle;

  /// No description provided for @restoreConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'This will add the backup data to your existing data. Continue?'**
  String get restoreConfirmMessage;

  /// No description provided for @restoreSuccess.
  ///
  /// In en, this message translates to:
  /// **'Data restored! {expenses} expenses, {pursuits} goals, {subscriptions} subscriptions imported.'**
  String restoreSuccess(int expenses, int pursuits, int subscriptions);

  /// No description provided for @restoreError.
  ///
  /// In en, this message translates to:
  /// **'Failed to restore data'**
  String get restoreError;

  /// No description provided for @noFileSelected.
  ///
  /// In en, this message translates to:
  /// **'No file selected'**
  String get noFileSelected;

  /// No description provided for @invalidBackupFormat.
  ///
  /// In en, this message translates to:
  /// **'Invalid backup file format'**
  String get invalidBackupFormat;

  /// No description provided for @shareApp.
  ///
  /// In en, this message translates to:
  /// **'Share App'**
  String get shareApp;

  /// No description provided for @shareAppDesc.
  ///
  /// In en, this message translates to:
  /// **'Recommend Vantag to friends'**
  String get shareAppDesc;

  /// No description provided for @shareAppMessage.
  ///
  /// In en, this message translates to:
  /// **'Check out Vantag - It shows you how many work hours each expense costs! Download: https://play.google.com/store/apps/details?id=com.vantag.app'**
  String get shareAppMessage;

  /// No description provided for @sendFeedback.
  ///
  /// In en, this message translates to:
  /// **'Send Feedback'**
  String get sendFeedback;

  /// No description provided for @sendFeedbackDesc.
  ///
  /// In en, this message translates to:
  /// **'Help us improve Vantag'**
  String get sendFeedbackDesc;

  /// No description provided for @feedbackEmailSubject.
  ///
  /// In en, this message translates to:
  /// **'Vantag Feedback'**
  String get feedbackEmailSubject;

  /// No description provided for @rateApp.
  ///
  /// In en, this message translates to:
  /// **'Rate App'**
  String get rateApp;

  /// No description provided for @rateAppDesc.
  ///
  /// In en, this message translates to:
  /// **'Rate us on Play Store'**
  String get rateAppDesc;

  /// No description provided for @whatsNew.
  ///
  /// In en, this message translates to:
  /// **'What\'s New'**
  String get whatsNew;

  /// No description provided for @whatsNewInVersion.
  ///
  /// In en, this message translates to:
  /// **'What\'s New in v{version}'**
  String whatsNewInVersion(String version);

  /// No description provided for @updateRequired.
  ///
  /// In en, this message translates to:
  /// **'Update Required'**
  String get updateRequired;

  /// No description provided for @updateRequiredMessage.
  ///
  /// In en, this message translates to:
  /// **'A new version of Vantag is available. Please update to continue.'**
  String get updateRequiredMessage;

  /// No description provided for @updateNow.
  ///
  /// In en, this message translates to:
  /// **'Update Now'**
  String get updateNow;

  /// No description provided for @dailyLimits.
  ///
  /// In en, this message translates to:
  /// **'Daily Limits'**
  String get dailyLimits;

  /// No description provided for @aiChat.
  ///
  /// In en, this message translates to:
  /// **'AI Chat'**
  String get aiChat;

  /// No description provided for @statementImport.
  ///
  /// In en, this message translates to:
  /// **'Statement Import'**
  String get statementImport;

  /// Apple App Store required auto-renewal disclosure
  ///
  /// In en, this message translates to:
  /// **'Subscription automatically renews unless canceled at least 24 hours before the end of the current period. Manage subscriptions in Settings.'**
  String get subscriptionAutoRenewalNotice;

  /// No description provided for @welcomeBackTitle3Days.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back!'**
  String get welcomeBackTitle3Days;

  /// No description provided for @welcomeBackSubtitle3Days.
  ///
  /// In en, this message translates to:
  /// **'We missed you. Keep tracking your expenses.'**
  String get welcomeBackSubtitle3Days;

  /// No description provided for @welcomeBackCta3Days.
  ///
  /// In en, this message translates to:
  /// **'Add Expense'**
  String get welcomeBackCta3Days;

  /// No description provided for @welcomeBackTitle7Days.
  ///
  /// In en, this message translates to:
  /// **'You\'re Back!'**
  String get welcomeBackTitle7Days;

  /// No description provided for @welcomeBackSubtitle7Days.
  ///
  /// In en, this message translates to:
  /// **'It\'s been a week. Let\'s continue towards your financial goals.'**
  String get welcomeBackSubtitle7Days;

  /// No description provided for @welcomeBackCta7Days.
  ///
  /// In en, this message translates to:
  /// **'Where Did We Leave Off?'**
  String get welcomeBackCta7Days;

  /// No description provided for @welcomeBackTitle14Days.
  ///
  /// In en, this message translates to:
  /// **'Hello Again!'**
  String get welcomeBackTitle14Days;

  /// No description provided for @welcomeBackSubtitle14Days.
  ///
  /// In en, this message translates to:
  /// **'We\'ve been waiting. Ready for a fresh start?'**
  String get welcomeBackSubtitle14Days;

  /// No description provided for @welcomeBackCta14Days.
  ///
  /// In en, this message translates to:
  /// **'Start Fresh'**
  String get welcomeBackCta14Days;

  /// No description provided for @welcomeBackTitle30Days.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back!'**
  String get welcomeBackTitle30Days;

  /// No description provided for @welcomeBackSubtitle30Days.
  ///
  /// In en, this message translates to:
  /// **'It\'s been a while, but reaching your goals is still possible!'**
  String get welcomeBackSubtitle30Days;

  /// No description provided for @welcomeBackCta30Days.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get welcomeBackCta30Days;

  /// No description provided for @welcomeBackStreakLost.
  ///
  /// In en, this message translates to:
  /// **'Your streak was reset'**
  String get welcomeBackStreakLost;

  /// No description provided for @welcomeBackStreakRecovered.
  ///
  /// In en, this message translates to:
  /// **'{percent}% of your streak recovered!'**
  String welcomeBackStreakRecovered(int percent);

  /// No description provided for @reengagementPushTitle3Days.
  ///
  /// In en, this message translates to:
  /// **'Don\'t forget to track your expenses!'**
  String get reengagementPushTitle3Days;

  /// No description provided for @reengagementPushBody3Days.
  ///
  /// In en, this message translates to:
  /// **'How much did you save today? Check now.'**
  String get reengagementPushBody3Days;

  /// No description provided for @reengagementPushTitle5Days.
  ///
  /// In en, this message translates to:
  /// **'We miss you!'**
  String get reengagementPushTitle5Days;

  /// No description provided for @reengagementPushBody5Days.
  ///
  /// In en, this message translates to:
  /// **'Keep going to reach your financial goals.'**
  String get reengagementPushBody5Days;

  /// No description provided for @reengagementPushTitle7Days.
  ///
  /// In en, this message translates to:
  /// **'Come back before you lose your streak!'**
  String get reengagementPushTitle7Days;

  /// No description provided for @reengagementPushBody7Days.
  ///
  /// In en, this message translates to:
  /// **'Don\'t lose your streak, add an expense now.'**
  String get reengagementPushBody7Days;

  /// No description provided for @reengagementUrgentTitle.
  ///
  /// In en, this message translates to:
  /// **'Don\'t lose control of your finances!'**
  String get reengagementUrgentTitle;

  /// No description provided for @reengagementUrgentBody.
  ///
  /// In en, this message translates to:
  /// **'Update your expenses and stay on track.'**
  String get reengagementUrgentBody;

  /// No description provided for @pushOnboardingDay1Title.
  ///
  /// In en, this message translates to:
  /// **'Add your first expense!'**
  String get pushOnboardingDay1Title;

  /// No description provided for @pushOnboardingDay1Body.
  ///
  /// In en, this message translates to:
  /// **'A coffee or meal - start small, see the difference.'**
  String get pushOnboardingDay1Body;

  /// No description provided for @pushOnboardingDay3Title.
  ///
  /// In en, this message translates to:
  /// **'Do you know how many hours you worked?'**
  String get pushOnboardingDay3Title;

  /// No description provided for @pushOnboardingDay3Body.
  ///
  /// In en, this message translates to:
  /// **'Keep seeing your expenses as hours worked.'**
  String get pushOnboardingDay3Body;

  /// No description provided for @pushOnboardingDay7Title.
  ///
  /// In en, this message translates to:
  /// **'It\'s been 7 days!'**
  String get pushOnboardingDay7Title;

  /// No description provided for @pushOnboardingDay7Body.
  ///
  /// In en, this message translates to:
  /// **'Add an expense daily to start a streak.'**
  String get pushOnboardingDay7Body;

  /// No description provided for @pushWeeklyInsightTitle.
  ///
  /// In en, this message translates to:
  /// **'Weekly Summary Ready'**
  String get pushWeeklyInsightTitle;

  /// No description provided for @pushWeeklyInsightBody.
  ///
  /// In en, this message translates to:
  /// **'How much did you save this week? Check now.'**
  String get pushWeeklyInsightBody;

  /// No description provided for @pushStreakReminderNewTitle.
  ///
  /// In en, this message translates to:
  /// **'Start a new streak!'**
  String get pushStreakReminderNewTitle;

  /// No description provided for @pushStreakReminderNewBody.
  ///
  /// In en, this message translates to:
  /// **'Add your first expense today and begin your journey.'**
  String get pushStreakReminderNewBody;

  /// No description provided for @pushStreakReminderShortTitle.
  ///
  /// In en, this message translates to:
  /// **'You have a {days} day streak!'**
  String pushStreakReminderShortTitle(int days);

  /// No description provided for @pushStreakReminderShortBody.
  ///
  /// In en, this message translates to:
  /// **'Add one today to keep it going.'**
  String get pushStreakReminderShortBody;

  /// No description provided for @pushStreakReminderMediumTitle.
  ///
  /// In en, this message translates to:
  /// **'{days} days! You\'re doing great!'**
  String pushStreakReminderMediumTitle(int days);

  /// No description provided for @pushStreakReminderMediumBody.
  ///
  /// In en, this message translates to:
  /// **'Add today to keep your streak alive.'**
  String get pushStreakReminderMediumBody;

  /// No description provided for @pushStreakReminderLongTitle.
  ///
  /// In en, this message translates to:
  /// **'{days} day streak!'**
  String pushStreakReminderLongTitle(int days);

  /// No description provided for @pushStreakReminderLongBody.
  ///
  /// In en, this message translates to:
  /// **'Incredible achievement! Keep it up.'**
  String get pushStreakReminderLongBody;

  /// No description provided for @pushMorningMotivationTitle.
  ///
  /// In en, this message translates to:
  /// **'Good morning!'**
  String get pushMorningMotivationTitle;

  /// No description provided for @pushMorningMotivationWithSavingsBody.
  ///
  /// In en, this message translates to:
  /// **'You saved {symbol}{amount} this month. Keep going!'**
  String pushMorningMotivationWithSavingsBody(String symbol, String amount);

  /// No description provided for @pushMorningMotivationDefaultBody.
  ///
  /// In en, this message translates to:
  /// **'Add an expense today to boost your financial awareness.'**
  String get pushMorningMotivationDefaultBody;

  /// No description provided for @notificationSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Notification Settings'**
  String get notificationSettingsTitle;

  /// No description provided for @notificationSettingsQuietHours.
  ///
  /// In en, this message translates to:
  /// **'Quiet Hours'**
  String get notificationSettingsQuietHours;

  /// No description provided for @notificationSettingsQuietHoursDesc.
  ///
  /// In en, this message translates to:
  /// **'No notifications during these hours'**
  String get notificationSettingsQuietHoursDesc;

  /// No description provided for @notificationSettingsPreferredTime.
  ///
  /// In en, this message translates to:
  /// **'Preferred Time'**
  String get notificationSettingsPreferredTime;

  /// No description provided for @notificationSettingsPreferredTimeDesc.
  ///
  /// In en, this message translates to:
  /// **'Time to receive notifications'**
  String get notificationSettingsPreferredTimeDesc;

  /// No description provided for @notificationSettingsStreakReminders.
  ///
  /// In en, this message translates to:
  /// **'Streak Reminders'**
  String get notificationSettingsStreakReminders;

  /// No description provided for @notificationSettingsStreakRemindersDesc.
  ///
  /// In en, this message translates to:
  /// **'Get evening reminders about your streak'**
  String get notificationSettingsStreakRemindersDesc;

  /// No description provided for @notificationSettingsMorningMotivation.
  ///
  /// In en, this message translates to:
  /// **'Morning Motivation'**
  String get notificationSettingsMorningMotivation;

  /// No description provided for @notificationSettingsMorningMotivationDesc.
  ///
  /// In en, this message translates to:
  /// **'Get motivation messages in the morning'**
  String get notificationSettingsMorningMotivationDesc;

  /// No description provided for @notificationSettingsWeeklyInsights.
  ///
  /// In en, this message translates to:
  /// **'Weekly Insights'**
  String get notificationSettingsWeeklyInsights;

  /// No description provided for @notificationSettingsWeeklyInsightsDesc.
  ///
  /// In en, this message translates to:
  /// **'Get weekly summary on Sunday mornings'**
  String get notificationSettingsWeeklyInsightsDesc;

  /// No description provided for @loginPromptTitle.
  ///
  /// In en, this message translates to:
  /// **'Save Your Data'**
  String get loginPromptTitle;

  /// No description provided for @loginPromptSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Link your account so you don\'t lose your data'**
  String get loginPromptSubtitle;

  /// No description provided for @loginPromptLater.
  ///
  /// In en, this message translates to:
  /// **'Maybe later'**
  String get loginPromptLater;

  /// No description provided for @additionalIncomePromptTitle.
  ///
  /// In en, this message translates to:
  /// **'Do you have additional income?'**
  String get additionalIncomePromptTitle;

  /// No description provided for @additionalIncomePromptSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Side job, rent, freelance...'**
  String get additionalIncomePromptSubtitle;

  /// No description provided for @additionalIncomeYes.
  ///
  /// In en, this message translates to:
  /// **'Yes, add'**
  String get additionalIncomeYes;

  /// No description provided for @additionalIncomeNo.
  ///
  /// In en, this message translates to:
  /// **'No, I don\'t'**
  String get additionalIncomeNo;

  /// No description provided for @expenseTypeSingle.
  ///
  /// In en, this message translates to:
  /// **'One-time'**
  String get expenseTypeSingle;

  /// No description provided for @expenseTypeRecurring.
  ///
  /// In en, this message translates to:
  /// **'Recurring'**
  String get expenseTypeRecurring;

  /// No description provided for @expenseTypeInstallment.
  ///
  /// In en, this message translates to:
  /// **'Payment Plan'**
  String get expenseTypeInstallment;

  /// No description provided for @monthlyPaymentLabel.
  ///
  /// In en, this message translates to:
  /// **'Monthly payment:'**
  String get monthlyPaymentLabel;

  /// No description provided for @installmentCountLabel.
  ///
  /// In en, this message translates to:
  /// **'{count} months'**
  String installmentCountLabel(int count);

  /// No description provided for @interestAmountLabel.
  ///
  /// In en, this message translates to:
  /// **'Fees / Interest:'**
  String get interestAmountLabel;

  /// No description provided for @interestAsHoursLabel.
  ///
  /// In en, this message translates to:
  /// **'Fees as work hours:'**
  String get interestAsHoursLabel;

  /// No description provided for @hoursUnit.
  ///
  /// In en, this message translates to:
  /// **'hours'**
  String get hoursUnit;

  /// No description provided for @installmentSavingsWarning.
  ///
  /// In en, this message translates to:
  /// **'Paying upfront would save you {hours} hours!'**
  String installmentSavingsWarning(String hours);

  /// No description provided for @errorSelectInstallmentCount.
  ///
  /// In en, this message translates to:
  /// **'Please select number of payments'**
  String get errorSelectInstallmentCount;

  /// No description provided for @errorEnterInstallmentTotal.
  ///
  /// In en, this message translates to:
  /// **'Please enter total with financing'**
  String get errorEnterInstallmentTotal;

  /// No description provided for @insightPeakDay.
  ///
  /// In en, this message translates to:
  /// **'Peak Spending Day'**
  String get insightPeakDay;

  /// No description provided for @insightTopCategory.
  ///
  /// In en, this message translates to:
  /// **'Top Category'**
  String get insightTopCategory;

  /// No description provided for @insightMonthComparison.
  ///
  /// In en, this message translates to:
  /// **'This Month vs Last Month'**
  String get insightMonthComparison;

  /// No description provided for @insightPeakDaySubtitle.
  ///
  /// In en, this message translates to:
  /// **'{day} is your highest spending day'**
  String insightPeakDaySubtitle(String day);

  /// No description provided for @insightTopCategorySubtitle.
  ///
  /// In en, this message translates to:
  /// **'{category} is your top category'**
  String insightTopCategorySubtitle(String category);

  /// No description provided for @insightMonthDown.
  ///
  /// In en, this message translates to:
  /// **'{percent}% decrease from last month'**
  String insightMonthDown(String percent);

  /// No description provided for @insightMonthUp.
  ///
  /// In en, this message translates to:
  /// **'{percent}% increase from last month'**
  String insightMonthUp(String percent);

  /// No description provided for @dayMonday.
  ///
  /// In en, this message translates to:
  /// **'Monday'**
  String get dayMonday;

  /// No description provided for @dayTuesday.
  ///
  /// In en, this message translates to:
  /// **'Tuesday'**
  String get dayTuesday;

  /// No description provided for @dayWednesday.
  ///
  /// In en, this message translates to:
  /// **'Wednesday'**
  String get dayWednesday;

  /// No description provided for @dayThursday.
  ///
  /// In en, this message translates to:
  /// **'Thursday'**
  String get dayThursday;

  /// No description provided for @dayFriday.
  ///
  /// In en, this message translates to:
  /// **'Friday'**
  String get dayFriday;

  /// No description provided for @daySaturday.
  ///
  /// In en, this message translates to:
  /// **'Saturday'**
  String get daySaturday;

  /// No description provided for @daySunday.
  ///
  /// In en, this message translates to:
  /// **'Sunday'**
  String get daySunday;

  /// No description provided for @heatmapLow.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get heatmapLow;

  /// No description provided for @heatmapHigh.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get heatmapHigh;

  /// No description provided for @dayAbbrevMon.
  ///
  /// In en, this message translates to:
  /// **'M'**
  String get dayAbbrevMon;

  /// No description provided for @dayAbbrevTue.
  ///
  /// In en, this message translates to:
  /// **'T'**
  String get dayAbbrevTue;

  /// No description provided for @dayAbbrevWed.
  ///
  /// In en, this message translates to:
  /// **'W'**
  String get dayAbbrevWed;

  /// No description provided for @dayAbbrevThu.
  ///
  /// In en, this message translates to:
  /// **'T'**
  String get dayAbbrevThu;

  /// No description provided for @dayAbbrevFri.
  ///
  /// In en, this message translates to:
  /// **'F'**
  String get dayAbbrevFri;

  /// No description provided for @dayAbbrevSat.
  ///
  /// In en, this message translates to:
  /// **'S'**
  String get dayAbbrevSat;

  /// No description provided for @dayAbbrevSun.
  ///
  /// In en, this message translates to:
  /// **'S'**
  String get dayAbbrevSun;

  /// No description provided for @monthAbbrevJan.
  ///
  /// In en, this message translates to:
  /// **'Jan'**
  String get monthAbbrevJan;

  /// No description provided for @monthAbbrevFeb.
  ///
  /// In en, this message translates to:
  /// **'Feb'**
  String get monthAbbrevFeb;

  /// No description provided for @monthAbbrevMar.
  ///
  /// In en, this message translates to:
  /// **'Mar'**
  String get monthAbbrevMar;

  /// No description provided for @monthAbbrevApr.
  ///
  /// In en, this message translates to:
  /// **'Apr'**
  String get monthAbbrevApr;

  /// No description provided for @monthAbbrevMay.
  ///
  /// In en, this message translates to:
  /// **'May'**
  String get monthAbbrevMay;

  /// No description provided for @monthAbbrevJun.
  ///
  /// In en, this message translates to:
  /// **'Jun'**
  String get monthAbbrevJun;

  /// No description provided for @monthAbbrevJul.
  ///
  /// In en, this message translates to:
  /// **'Jul'**
  String get monthAbbrevJul;

  /// No description provided for @monthAbbrevAug.
  ///
  /// In en, this message translates to:
  /// **'Aug'**
  String get monthAbbrevAug;

  /// No description provided for @monthAbbrevSep.
  ///
  /// In en, this message translates to:
  /// **'Sep'**
  String get monthAbbrevSep;

  /// No description provided for @monthAbbrevOct.
  ///
  /// In en, this message translates to:
  /// **'Oct'**
  String get monthAbbrevOct;

  /// No description provided for @monthAbbrevNov.
  ///
  /// In en, this message translates to:
  /// **'Nov'**
  String get monthAbbrevNov;

  /// No description provided for @monthAbbrevDec.
  ///
  /// In en, this message translates to:
  /// **'Dec'**
  String get monthAbbrevDec;

  /// No description provided for @savingsProjectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Savings Projection'**
  String get savingsProjectionTitle;

  /// No description provided for @threeMonths.
  ///
  /// In en, this message translates to:
  /// **'3 Mo'**
  String get threeMonths;

  /// No description provided for @sixMonths.
  ///
  /// In en, this message translates to:
  /// **'6 Mo'**
  String get sixMonths;

  /// No description provided for @oneYear.
  ///
  /// In en, this message translates to:
  /// **'1 Year'**
  String get oneYear;

  /// No description provided for @monthlyAverageLabel.
  ///
  /// In en, this message translates to:
  /// **'Monthly average: {amount}'**
  String monthlyAverageLabel(String amount);

  /// No description provided for @categoryTrendTitle.
  ///
  /// In en, this message translates to:
  /// **'Category Trend'**
  String get categoryTrendTitle;

  /// No description provided for @workHoursEquivalentTitle.
  ///
  /// In en, this message translates to:
  /// **'Work Hours Equivalent'**
  String get workHoursEquivalentTitle;

  /// No description provided for @totalHoursLabel.
  ///
  /// In en, this message translates to:
  /// **'Total: {hours} hours'**
  String totalHoursLabel(String hours);

  /// No description provided for @perHourLabel.
  ///
  /// In en, this message translates to:
  /// **'({rate}/hr)'**
  String perHourLabel(String rate);

  /// No description provided for @dayAbbrevMonFull.
  ///
  /// In en, this message translates to:
  /// **'Mon'**
  String get dayAbbrevMonFull;

  /// No description provided for @dayAbbrevTueFull.
  ///
  /// In en, this message translates to:
  /// **'Tue'**
  String get dayAbbrevTueFull;

  /// No description provided for @dayAbbrevWedFull.
  ///
  /// In en, this message translates to:
  /// **'Wed'**
  String get dayAbbrevWedFull;

  /// No description provided for @dayAbbrevThuFull.
  ///
  /// In en, this message translates to:
  /// **'Thu'**
  String get dayAbbrevThuFull;

  /// No description provided for @dayAbbrevFriFull.
  ///
  /// In en, this message translates to:
  /// **'Fri'**
  String get dayAbbrevFriFull;

  /// No description provided for @dayAbbrevSatFull.
  ///
  /// In en, this message translates to:
  /// **'Sat'**
  String get dayAbbrevSatFull;

  /// No description provided for @dayAbbrevSunFull.
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get dayAbbrevSunFull;

  /// No description provided for @sharePreText.
  ///
  /// In en, this message translates to:
  /// **'To buy this'**
  String get sharePreText;

  /// No description provided for @sharePostText.
  ///
  /// In en, this message translates to:
  /// **'of work needed'**
  String get sharePostText;

  /// No description provided for @shareCTA.
  ///
  /// In en, this message translates to:
  /// **'How many hours do you work?'**
  String get shareCTA;

  /// No description provided for @shareTextDefault.
  ///
  /// In en, this message translates to:
  /// **'How many hours do you work? 👀 vantag.app'**
  String get shareTextDefault;

  /// No description provided for @minuteUnitUpper.
  ///
  /// In en, this message translates to:
  /// **'MIN'**
  String get minuteUnitUpper;

  /// No description provided for @hourUnitUpper.
  ///
  /// In en, this message translates to:
  /// **'HOUR'**
  String get hourUnitUpper;

  /// No description provided for @decisionBought.
  ///
  /// In en, this message translates to:
  /// **'Bought'**
  String get decisionBought;

  /// No description provided for @decisionPassed.
  ///
  /// In en, this message translates to:
  /// **'Passed'**
  String get decisionPassed;

  /// No description provided for @decisionThinking.
  ///
  /// In en, this message translates to:
  /// **'Thinking'**
  String get decisionThinking;

  /// No description provided for @expenseAddedMessage.
  ///
  /// In en, this message translates to:
  /// **'{amount} {description} added'**
  String expenseAddedMessage(String amount, String description);

  /// No description provided for @undoAction.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undoAction;

  /// No description provided for @confirmExpenseTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm Expense'**
  String get confirmExpenseTitle;

  /// No description provided for @amountLabel.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amountLabel;

  /// No description provided for @categoryLabel.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get categoryLabel;

  /// No description provided for @cancelAction.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelAction;

  /// No description provided for @addAction.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get addAction;

  /// No description provided for @referralAppliedMessage.
  ///
  /// In en, this message translates to:
  /// **'Invite code applied: {code}'**
  String referralAppliedMessage(String code);

  /// No description provided for @workEquivalentBadge.
  ///
  /// In en, this message translates to:
  /// **'WORK EQUIVALENT'**
  String get workEquivalentBadge;

  /// No description provided for @hoursUnitUpper.
  ///
  /// In en, this message translates to:
  /// **'HOURS'**
  String get hoursUnitUpper;

  /// No description provided for @daysUnitUpper.
  ///
  /// In en, this message translates to:
  /// **'DAYS'**
  String get daysUnitUpper;

  /// No description provided for @budgetUsageLabel.
  ///
  /// In en, this message translates to:
  /// **'Budget Usage'**
  String get budgetUsageLabel;

  /// No description provided for @whatDecisionLabel.
  ///
  /// In en, this message translates to:
  /// **'What\'s your decision?'**
  String get whatDecisionLabel;

  /// No description provided for @daysUnit.
  ///
  /// In en, this message translates to:
  /// **'{count} days'**
  String daysUnit(int count);

  /// No description provided for @profilePhotoTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile Photo'**
  String get profilePhotoTitle;

  /// No description provided for @takePhotoOption.
  ///
  /// In en, this message translates to:
  /// **'Take photo'**
  String get takePhotoOption;

  /// No description provided for @chooseFromGalleryOption.
  ///
  /// In en, this message translates to:
  /// **'Choose from gallery'**
  String get chooseFromGalleryOption;

  /// No description provided for @removePhotoOption.
  ///
  /// In en, this message translates to:
  /// **'Remove photo'**
  String get removePhotoOption;

  /// No description provided for @examplePrefix.
  ///
  /// In en, this message translates to:
  /// **'E.g: {examples}'**
  String examplePrefix(String examples);

  /// No description provided for @exampleFood.
  ///
  /// In en, this message translates to:
  /// **'Coffee, Grocery, Restaurant'**
  String get exampleFood;

  /// No description provided for @exampleTransport.
  ///
  /// In en, this message translates to:
  /// **'Gas, Taxi, Bus'**
  String get exampleTransport;

  /// No description provided for @exampleClothing.
  ///
  /// In en, this message translates to:
  /// **'Coat, Shoes, T-shirt'**
  String get exampleClothing;

  /// No description provided for @exampleElectronics.
  ///
  /// In en, this message translates to:
  /// **'Phone, Headphones, Charger'**
  String get exampleElectronics;

  /// No description provided for @exampleEntertainment.
  ///
  /// In en, this message translates to:
  /// **'Cinema, Game, Concert'**
  String get exampleEntertainment;

  /// No description provided for @exampleHealth.
  ///
  /// In en, this message translates to:
  /// **'Medicine, Doctor, Vitamin'**
  String get exampleHealth;

  /// No description provided for @exampleEducation.
  ///
  /// In en, this message translates to:
  /// **'Book, Course, Notebook'**
  String get exampleEducation;

  /// No description provided for @exampleBills.
  ///
  /// In en, this message translates to:
  /// **'Electricity, Water, Internet'**
  String get exampleBills;

  /// No description provided for @exampleDefault.
  ///
  /// In en, this message translates to:
  /// **'Add a description...'**
  String get exampleDefault;

  /// No description provided for @newExpenseHeader.
  ///
  /// In en, this message translates to:
  /// **'New Expense'**
  String get newExpenseHeader;

  /// No description provided for @expenseGroupHeader.
  ///
  /// In en, this message translates to:
  /// **'Expense Group'**
  String get expenseGroupHeader;

  /// No description provided for @calculateAction.
  ///
  /// In en, this message translates to:
  /// **'Calculate'**
  String get calculateAction;

  /// No description provided for @detailOptionalLabel.
  ///
  /// In en, this message translates to:
  /// **'Detail (Optional)'**
  String get detailOptionalLabel;

  /// No description provided for @enterValidAmountError.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid amount'**
  String get enterValidAmountError;

  /// No description provided for @aiDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'AI-generated insights are for informational purposes only and should not be considered financial advice.'**
  String get aiDisclaimer;

  /// No description provided for @hourLabel.
  ///
  /// In en, this message translates to:
  /// **'Hour'**
  String get hourLabel;

  /// No description provided for @yearLabel.
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get yearLabel;

  /// No description provided for @goldOunces.
  ///
  /// In en, this message translates to:
  /// **'{ounces}oz gold'**
  String goldOunces(String ounces);

  /// No description provided for @goldOuncesShort.
  ///
  /// In en, this message translates to:
  /// **'{ounces}oz gold'**
  String goldOuncesShort(String ounces);

  /// No description provided for @couldBuyGoldOunces.
  ///
  /// In en, this message translates to:
  /// **'With this money you could buy {ounces} oz of gold'**
  String couldBuyGoldOunces(String ounces);

  /// No description provided for @pleaseEnterIncome.
  ///
  /// In en, this message translates to:
  /// **'Please enter your income'**
  String get pleaseEnterIncome;

  /// No description provided for @mainIncome.
  ///
  /// In en, this message translates to:
  /// **'Main Income'**
  String get mainIncome;

  /// No description provided for @ofYourWork.
  ///
  /// In en, this message translates to:
  /// **'of your work'**
  String get ofYourWork;

  /// No description provided for @expensePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Coffee, food, grocery...'**
  String get expensePlaceholder;
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
