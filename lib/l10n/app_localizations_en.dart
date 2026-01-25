// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Vantag';

  @override
  String get appSlogan => 'Your Financial Edge';

  @override
  String get navExpenses => 'Expenses';

  @override
  String get navReports => 'Reports';

  @override
  String get navAchievements => 'Achievements';

  @override
  String get navProfile => 'Profile';

  @override
  String get navSettings => 'Settings';

  @override
  String get profile => 'Profile';

  @override
  String get profileSavedTime => 'Time Saved with Vantag';

  @override
  String profileHours(String hours) {
    return '$hours Hours';
  }

  @override
  String get profileMemberSince => 'Member Since';

  @override
  String profileDays(int days) {
    return '$days Days';
  }

  @override
  String get profileBadgesEarned => 'Badges Earned';

  @override
  String get profileGoogleConnected => 'Google Account Connected';

  @override
  String get profileGoogleNotConnected => 'Google Account Not Connected';

  @override
  String get profileSignOut => 'Sign Out';

  @override
  String get profileSignOutConfirm => 'Are you sure you want to sign out?';

  @override
  String get proMember => 'Pro Member';

  @override
  String get proMemberToast => 'You are a Pro Member ✓';

  @override
  String get settingsGeneral => 'General';

  @override
  String get settingsCurrency => 'Currency';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsTheme => 'Theme';

  @override
  String get settingsThemeDark => 'Dark';

  @override
  String get settingsThemeLight => 'Light';

  @override
  String get settingsThemeAutomatic => 'Automatic';

  @override
  String get simpleMode => 'Simple Mode';

  @override
  String get simpleModeDescription =>
      'Streamlined experience with essential features only';

  @override
  String get simpleModeEnabled => 'Simple mode is enabled';

  @override
  String get simpleModeDisabled => 'Simple mode is disabled';

  @override
  String get simpleModeHint =>
      'Turn off Simple Mode to access all features like AI chat, achievements, and pursuits';

  @override
  String get simpleTransactions => 'Transactions';

  @override
  String get simpleStatistics => 'Statistics';

  @override
  String get simpleSettings => 'Settings';

  @override
  String get simpleIncome => 'Income';

  @override
  String get simpleExpense => 'Expense';

  @override
  String get simpleExpenses => 'Expenses';

  @override
  String get simpleBalance => 'Balance';

  @override
  String get simpleTotal => 'Total';

  @override
  String get simpleTotalIncome => 'Total Income';

  @override
  String get simpleIncomeTab => 'Income';

  @override
  String get simpleIncomeSources => 'Income Sources';

  @override
  String get simpleNoTransactions => 'No transactions this month';

  @override
  String get simpleNoData => 'No data for this month';

  @override
  String get settingsNotifications => 'Notifications';

  @override
  String get settingsReminders => 'Reminders';

  @override
  String get settingsSoundEffects => 'Sound Effects';

  @override
  String get settingsSoundVolume => 'Volume';

  @override
  String get settingsProPurchases => 'Pro & Purchases';

  @override
  String get settingsVantagPro => 'Vantag Pro';

  @override
  String get settingsRestorePurchases => 'Restore Purchases';

  @override
  String get settingsRestoreSuccess => 'Purchases restored';

  @override
  String get settingsRestoreNone => 'No purchases to restore';

  @override
  String get settingsDataPrivacy => 'Data & Privacy';

  @override
  String get settingsExportData => 'Export Data';

  @override
  String get settingsImportStatement => 'Import Statement';

  @override
  String get settingsImportStatementDesc =>
      'Upload your bank statement (PDF/CSV)';

  @override
  String get importStatementTitle => 'Import Statement';

  @override
  String get importStatementSelectFile => 'Select File';

  @override
  String get importStatementSupportedFormats => 'Supported formats: PDF, CSV';

  @override
  String get importStatementDragDrop => 'Tap to select your bank statement';

  @override
  String get importStatementProcessing => 'Processing statement...';

  @override
  String importStatementSuccess(int count) {
    return 'Successfully imported $count transactions';
  }

  @override
  String get importStatementError => 'Error importing statement';

  @override
  String get importStatementNoTransactions =>
      'No transactions found in statement';

  @override
  String get importStatementUnsupportedFormat => 'Unsupported file format';

  @override
  String importStatementMonthlyLimit(int remaining) {
    return '$remaining imports remaining this month';
  }

  @override
  String get importStatementLimitReached => 'Monthly import limit reached';

  @override
  String get importStatementLimitReachedDesc =>
      'You\'ve used all your imports for this month. Upgrade to Pro for more imports.';

  @override
  String get importStatementProLimit => '10 imports/month';

  @override
  String get importStatementFreeLimit => '1 import/month';

  @override
  String get importStatementReviewTitle => 'Review Transactions';

  @override
  String get importStatementReviewDesc => 'Select transactions to import';

  @override
  String importStatementImportSelected(int count) {
    return 'Import Selected ($count)';
  }

  @override
  String get importStatementSelectAll => 'Select All';

  @override
  String get importStatementDeselectAll => 'Deselect All';

  @override
  String get settingsPrivacyPolicy => 'Privacy Policy';

  @override
  String get settingsAbout => 'About';

  @override
  String get settingsVersion => 'Version';

  @override
  String get settingsContactUs => 'Contact Us';

  @override
  String get settingsGrowth => 'Invite & get 3 days Premium free!';

  @override
  String get settingsInviteFriends => 'Invite Friends';

  @override
  String get settingsInviteMessage =>
      'I\'m tracking my expenses with Vantag! You should try it too:';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get totalBalance => 'Total Balance';

  @override
  String get monthlyIncome => 'Monthly Income';

  @override
  String get totalIncome => 'Total Income';

  @override
  String get totalSpent => 'Total Spent';

  @override
  String get totalSaved => 'Total Saved';

  @override
  String get workHours => 'Work Hours';

  @override
  String get workDays => 'Work Days';

  @override
  String get expenses => 'Expenses';

  @override
  String get addExpense => 'Add Expense';

  @override
  String get amount => 'Amount';

  @override
  String get amountTL => 'Amount (₺)';

  @override
  String get category => 'Category';

  @override
  String get description => 'Description';

  @override
  String get descriptionHint => 'e.g: Migros, Spotify, Shell...';

  @override
  String get descriptionLabel => 'Description (Store/Product)';

  @override
  String get date => 'Date';

  @override
  String get today => 'Today';

  @override
  String get weekdayMon => 'Mon';

  @override
  String get weekdayTue => 'Tue';

  @override
  String get weekdayWed => 'Wed';

  @override
  String get weekdayThu => 'Thu';

  @override
  String get weekdayFri => 'Fri';

  @override
  String get weekdaySat => 'Sat';

  @override
  String get weekdaySun => 'Sun';

  @override
  String get monthJan => 'Jan';

  @override
  String get monthFeb => 'Feb';

  @override
  String get monthMar => 'Mar';

  @override
  String get monthApr => 'Apr';

  @override
  String get monthMay => 'May';

  @override
  String get monthJun => 'Jun';

  @override
  String get monthJul => 'Jul';

  @override
  String get monthAug => 'Aug';

  @override
  String get monthSep => 'Sep';

  @override
  String get monthOct => 'Oct';

  @override
  String get monthNov => 'Nov';

  @override
  String get monthDec => 'Dec';

  @override
  String get yesterday => 'Yesterday';

  @override
  String get twoDaysAgo => '2 Days Ago';

  @override
  String daysAgo(int count) {
    return '$count Days Ago';
  }

  @override
  String get bought => 'Bought';

  @override
  String get thinking => 'Thinking';

  @override
  String get passed => 'Passed';

  @override
  String get cancel => 'Cancel';

  @override
  String get ok => 'OK';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get change => 'Change';

  @override
  String get close => 'Close';

  @override
  String get update => 'Update';

  @override
  String get calculate => 'Calculate';

  @override
  String get giveUp => 'Give Up';

  @override
  String get select => 'Select';

  @override
  String get decision => 'Decision';

  @override
  String hoursRequired(String hours) {
    return '$hours hours';
  }

  @override
  String daysRequired(String days) {
    return '$days days';
  }

  @override
  String minutesRequired(int minutes) {
    return '$minutes minutes';
  }

  @override
  String hoursEquivalent(String hours) {
    return '$hours hours equivalent';
  }

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get settings => 'Settings';

  @override
  String get language => 'Language';

  @override
  String get selectLanguage => 'Select Language';

  @override
  String get selectCurrency => 'Select Currency';

  @override
  String get currency => 'Currency';

  @override
  String get turkish => 'Turkish';

  @override
  String get english => 'English';

  @override
  String get incomeInfo => 'Income Information';

  @override
  String get dailyWorkHours => 'Daily Work Hours';

  @override
  String get weeklyWorkDays => 'Weekly Work Days';

  @override
  String workingDaysPerWeek(int count) {
    return 'Working $count days per week';
  }

  @override
  String get hours => 'hours';

  @override
  String incomeSources(int count) {
    return '$count sources';
  }

  @override
  String get detailedEntry => 'Detailed Entry';

  @override
  String get googleAccount => 'Google Account';

  @override
  String get googleLinked => 'Google Linked';

  @override
  String get googleNotLinked => 'Google Not Linked';

  @override
  String get linkWithGoogle => 'Link with Google';

  @override
  String get linking => 'Linking...';

  @override
  String get backupAndSecure => 'Backup and secure your data';

  @override
  String get dataNotBackedUp => 'Your data is not backed up';

  @override
  String get googleLinkedSuccess => 'Google account linked successfully!';

  @override
  String get googleLinkFailed => 'Failed to link Google account';

  @override
  String get freeCurrencyNote =>
      'Free users can only use TRY. Upgrade to Pro for all currencies.';

  @override
  String get welcome => 'Welcome';

  @override
  String get welcomeSubtitle =>
      'Enter your information to measure expenses in time';

  @override
  String get getStarted => 'Get Started';

  @override
  String get offlineMode => 'Offline mode - Data will be synced';

  @override
  String get noInternet => 'No Internet Connection';

  @override
  String get offline => 'Offline';

  @override
  String get offlineMessage => 'Data will sync when connection is restored';

  @override
  String get backOnline => 'Back Online';

  @override
  String get dataSynced => 'Data synced successfully';

  @override
  String get reports => 'Reports';

  @override
  String get monthlyReport => 'Monthly Report';

  @override
  String get categoryReport => 'Category Report';

  @override
  String get thisMonth => 'This Month';

  @override
  String get lastMonth => 'Last Month';

  @override
  String get thisWeek => 'This Week';

  @override
  String get allTime => 'All Time';

  @override
  String get achievements => 'Achievements';

  @override
  String get badges => 'Badges';

  @override
  String get progress => 'Progress';

  @override
  String get unlocked => 'Unlocked';

  @override
  String get locked => 'Locked';

  @override
  String get streak => 'Streak';

  @override
  String get currentStreak => 'Current Streak';

  @override
  String get bestStreak => 'Best Streak';

  @override
  String streakDays(int count) {
    return '$count days';
  }

  @override
  String get subscriptions => 'Subscriptions';

  @override
  String get subscriptionsDescription =>
      'Track your recurring subscriptions like Netflix, Spotify here.';

  @override
  String get addSubscription => 'Add Subscription';

  @override
  String get monthlyTotal => 'Monthly Total';

  @override
  String get yearlyTotal => 'Yearly Total';

  @override
  String get nextPayment => 'Next Payment';

  @override
  String renewalWarning(int days) {
    return 'Renewal in $days days';
  }

  @override
  String activeSubscriptions(int count) {
    return '$count active subscriptions';
  }

  @override
  String get monthlySubscriptions => 'Monthly Subscriptions';

  @override
  String get habitCalculator => 'Habit Calculator';

  @override
  String get selectHabit => 'Select a Habit';

  @override
  String get enterAmount => 'Enter Amount';

  @override
  String get dailyAmount => 'Daily Amount';

  @override
  String get yearlyCost => 'Yearly Cost';

  @override
  String get workDaysEquivalent => 'Work Days Equivalent';

  @override
  String get shareResult => 'Share Result';

  @override
  String get habitQuestion => 'How many days does your habit cost?';

  @override
  String get calculateAndShock => 'Calculate and be shocked →';

  @override
  String get appTour => 'App Tour';

  @override
  String get repeatTour => 'Repeat App Tour';

  @override
  String get tourCompleted => 'Tour Completed';

  @override
  String get notifications => 'Notifications';

  @override
  String get notificationSettings => 'Notifications';

  @override
  String get streakReminder => 'Streak Reminder';

  @override
  String get weeklyInsights => 'Weekly Insights';

  @override
  String get error => 'Error';

  @override
  String get success => 'Success';

  @override
  String get warning => 'Warning';

  @override
  String get info => 'Info';

  @override
  String get retry => 'Retry';

  @override
  String get loading => 'Loading...';

  @override
  String get noData => 'No data available';

  @override
  String get noExpenses => 'No expenses yet';

  @override
  String get noExpensesHint => 'Enter an amount above to start';

  @override
  String get noAchievements => 'No achievements yet';

  @override
  String get recordToEarnBadge => 'Record expenses to earn badges';

  @override
  String get notEnoughDataForReports => 'Not enough data for reports';

  @override
  String get confirmDelete => 'Are you sure you want to delete?';

  @override
  String get deleteConfirmation => 'This action cannot be undone.';

  @override
  String get categoryFood => 'Food';

  @override
  String get categoryTransport => 'Transport';

  @override
  String get categoryEntertainment => 'Entertainment';

  @override
  String get categoryShopping => 'Shopping';

  @override
  String get categoryBills => 'Bills';

  @override
  String get categoryHealth => 'Health';

  @override
  String get categoryEducation => 'Education';

  @override
  String get categoryDigital => 'Digital';

  @override
  String get categoryOther => 'Other';

  @override
  String get categoryClothing => 'Clothing';

  @override
  String get categoryElectronics => 'Electronics';

  @override
  String get categorySubscription => 'Subscription';

  @override
  String get weekdayMonday => 'Monday';

  @override
  String get weekdayTuesday => 'Tuesday';

  @override
  String get weekdayWednesday => 'Wednesday';

  @override
  String get weekdayThursday => 'Thursday';

  @override
  String get weekdayFriday => 'Friday';

  @override
  String get weekdaySaturday => 'Saturday';

  @override
  String get weekdaySunday => 'Sunday';

  @override
  String get shareTitle => 'Check out my savings with Vantag!';

  @override
  String shareMessage(String amount) {
    return 'I saved $amount TL this month with Vantag!';
  }

  @override
  String get currencyRates => 'Currency Rates';

  @override
  String get currencyRatesDescription =>
      'Current USD, EUR and gold prices. Tap for details.';

  @override
  String get gold => 'Gold';

  @override
  String get dollar => 'Dollar';

  @override
  String get euro => 'Euro';

  @override
  String get moneySavedInPocket => 'Money stayed in your pocket!';

  @override
  String get greatDecision => 'Great decision!';

  @override
  String freedomCloser(String hours) {
    return 'Money stayed in pocket, you\'re $hours closer to freedom!';
  }

  @override
  String get version => 'Version';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get termsOfService => 'Terms of Service';

  @override
  String get about => 'About';

  @override
  String get dangerZone => 'Danger Zone';

  @override
  String get appVersion => 'App Version';

  @override
  String get signOut => 'Sign Out';

  @override
  String get deleteAccount => 'Delete My Account';

  @override
  String get greetingMorning => 'Good morning';

  @override
  String get greetingAfternoon => 'Good afternoon';

  @override
  String get greetingEvening => 'Good evening';

  @override
  String get financialStatus => 'Financial Status';

  @override
  String get financialSummary => 'Financial Summary';

  @override
  String get financialSummaryDescription =>
      'Your monthly income, expenses and saved money here. All data updates in real-time.';

  @override
  String get newExpense => 'New Expense';

  @override
  String get editExpense => 'Edit Expense';

  @override
  String get deleteExpense => 'Delete Expense';

  @override
  String get deleteExpenseConfirm =>
      'Are you sure you want to delete this expense?';

  @override
  String get updateExpense => 'Update';

  @override
  String get expenseHistory => 'History';

  @override
  String recordCount(int count) {
    return '$count records';
  }

  @override
  String recordCountLimited(int shown, int total) {
    return '$shown of $total records';
  }

  @override
  String get unlockFullHistory => 'Unlock Full History';

  @override
  String proHistoryDescription(int count) {
    return 'Free users can view last 30 days. Upgrade to Pro for unlimited history.';
  }

  @override
  String get upgradeToPro => 'Upgrade to Pro';

  @override
  String get streakTracking => 'Streak Tracking';

  @override
  String get streakTrackingDescription =>
      'Your streak increases with daily entries. Regular tracking is key to mindful spending!';

  @override
  String get pastDateSelection => 'Past Date Selection';

  @override
  String get pastDateSelectionDescription =>
      'You can also enter expenses from yesterday or previous days. Tap the calendar icon to select any date.';

  @override
  String get amountEntry => 'Amount Entry';

  @override
  String get amountEntryDescription =>
      'Enter the expense amount here. Use the receipt scan button to read from receipt automatically.';

  @override
  String get smartMatching => 'Smart Matching';

  @override
  String get smartMatchingDescription =>
      'Type the store or product name. Migros, A101, Starbucks... The app will automatically suggest a category!';

  @override
  String get categorySelection => 'Category Selection';

  @override
  String get categorySelectionDescription =>
      'If smart matching doesn\'t find it or you want to change, you can manually select here.';

  @override
  String get selectCategory => 'Select Category';

  @override
  String autoSelected(String category) {
    return 'Auto-selected: $category';
  }

  @override
  String get pleaseSelectCategory => 'Please select a category';

  @override
  String get subCategoryOptional => 'Sub-category (optional)';

  @override
  String get recentlyUsed => 'Recently used';

  @override
  String get suggestions => 'Suggestions';

  @override
  String get scanReceipt => 'Scan receipt';

  @override
  String get cameraCapture => 'Capture with camera';

  @override
  String get selectFromGallery => 'Select from gallery';

  @override
  String amountFound(String amount) {
    return 'Amount found: $amount ₺';
  }

  @override
  String get amountNotFound => 'Amount not found. Enter manually.';

  @override
  String get scanError => 'Scan error. Try again.';

  @override
  String get selectExpenseDate => 'Select Expense Date';

  @override
  String get decisionUpdatedBought => 'Decision updated: Bought';

  @override
  String decisionSaved(String amount) {
    return 'You passed, saved $amount TL!';
  }

  @override
  String get keepThinking => 'Keep thinking';

  @override
  String get expenseUpdated => 'Expense updated';

  @override
  String get validationEnterAmount => 'Please enter a valid amount';

  @override
  String get validationAmountPositive => 'Amount must be greater than 0';

  @override
  String get validationAmountTooHigh => 'Amount seems too high';

  @override
  String get simulationSaved => 'Saved as Simulation';

  @override
  String get simulationDescription =>
      'This amount was saved as simulation because it\'s large.';

  @override
  String get simulationInfo =>
      'Does not affect your statistics, just for reference.';

  @override
  String get understood => 'Understood';

  @override
  String get largeAmountTitle => 'Large Amount';

  @override
  String get largeAmountMessage => 'Is this a real expense or a simulation?';

  @override
  String get realExpenseButton => 'Real Expense';

  @override
  String get simulationButton => 'Simulation';

  @override
  String get monthJanuary => 'January';

  @override
  String get monthFebruary => 'February';

  @override
  String get monthMarch => 'March';

  @override
  String get monthApril => 'April';

  @override
  String get monthJune => 'June';

  @override
  String get monthJuly => 'July';

  @override
  String get monthAugust => 'August';

  @override
  String get monthSeptember => 'September';

  @override
  String get monthOctober => 'October';

  @override
  String get monthNovember => 'November';

  @override
  String get monthDecember => 'December';

  @override
  String get categoryDistribution => 'Category Distribution';

  @override
  String moreCategories(int count) {
    return '+$count more categories';
  }

  @override
  String get expenseCount => 'Expense Count';

  @override
  String boughtPassed(int bought, int passed) {
    return '$bought bought, $passed passed';
  }

  @override
  String get passRate => 'Pass Rate';

  @override
  String get doingGreat => 'You\'re doing great!';

  @override
  String get canDoBetter => 'You can do better';

  @override
  String get statistics => 'Statistics';

  @override
  String get avgDailyExpense => 'Average Daily Expense';

  @override
  String get highestSingleExpense => 'Highest Single Expense';

  @override
  String get mostDeclinedCategory => 'Most Declined Category';

  @override
  String times(int count) {
    return '$count times';
  }

  @override
  String get trend => 'Trend';

  @override
  String trendSpentThisPeriod(String amount, String period) {
    return 'You spent $amount TL this $period';
  }

  @override
  String trendSameAsPrevious(String period) {
    return 'Same spending as last $period';
  }

  @override
  String trendSpentLess(String percent, String period) {
    return 'You spent $percent% less than last $period';
  }

  @override
  String trendSpentMore(String percent, String period) {
    return 'You spent $percent% more than last $period';
  }

  @override
  String get periodWeek => 'week';

  @override
  String get periodMonth => 'month';

  @override
  String get subCategoryDetail => 'Sub-Category Detail';

  @override
  String get comparedToPrevious => 'Compared to previous period';

  @override
  String get increased => 'increased';

  @override
  String get decreased => 'decreased';

  @override
  String subCategoryChange(
    String period,
    String subCategory,
    String changeText,
    String percent,
    String previousPeriod,
  ) {
    return 'This $period your $subCategory spending $changeText by $percent% compared to last $previousPeriod.';
  }

  @override
  String get listView => 'List View';

  @override
  String get calendarView => 'Calendar View';

  @override
  String get subscription => 'subscription';

  @override
  String get workDaysPerMonth => 'work days/month';

  @override
  String everyMonthDay(int day) {
    return 'Every ${day}th of month';
  }

  @override
  String get noSubscriptionsYet => 'No subscriptions yet';

  @override
  String get addSubscriptionsLikeNetflix =>
      'Add your subscriptions like Netflix, Spotify';

  @override
  String monthlyTotalAmount(String amount) {
    return 'Monthly total: $amount TL';
  }

  @override
  String dayOfMonth(int day) {
    return 'Day $day';
  }

  @override
  String get addSubscriptionHint => 'Press + button to add a new subscription';

  @override
  String get tomorrow => 'Tomorrow';

  @override
  String daysLater(int days) {
    return 'in $days days';
  }

  @override
  String get perMonth => '/month';

  @override
  String get enterSubscriptionName => 'Enter subscription name';

  @override
  String get enterValidAmount => 'Enter a valid amount';

  @override
  String get editSubscription => 'Edit Subscription';

  @override
  String get newSubscription => 'New Subscription';

  @override
  String get subscriptionName => 'Subscription Name';

  @override
  String get subscriptionNameHint => 'Netflix, Spotify...';

  @override
  String get monthlyAmount => 'Monthly Amount';

  @override
  String get renewalDay => 'Renewal Day';

  @override
  String get active => 'Active';

  @override
  String get passivesNotIncluded =>
      'Passive subscriptions not included in notifications';

  @override
  String get autoRecord => 'Auto Record';

  @override
  String get autoRecordDescription =>
      'Expense will be automatically added on billing date';

  @override
  String get add => 'Add';

  @override
  String subscriptionCount(int count, String amount) {
    return '$count subscriptions, $amount ₺/month';
  }

  @override
  String get viewSubscriptionsInCalendar =>
      'View your subscriptions in calendar';

  @override
  String get urgentRenewalWarning => 'Urgent Renewal Warning!';

  @override
  String get upcomingRenewals => 'Upcoming Renewals';

  @override
  String renewsWithinOneHour(String name) {
    return '$name - renews within 1 hour';
  }

  @override
  String renewsWithinHours(String name, int hours) {
    return '$name - in $hours hours';
  }

  @override
  String renewsToday(String name) {
    return '$name - renews today';
  }

  @override
  String renewsTomorrow(String name) {
    return '$name - renews tomorrow';
  }

  @override
  String subscriptionsRenewingSoon(int count) {
    return '$count subscriptions renewing soon';
  }

  @override
  String amountPerMonth(String amount) {
    return '$amount ₺/month';
  }

  @override
  String get hiddenBadges => 'Hidden Badges';

  @override
  String badgesEarned(int unlocked, int total) {
    return '$unlocked / $total badges earned';
  }

  @override
  String percentComplete(String percent) {
    return '$percent% complete';
  }

  @override
  String get completed => 'Completed!';

  @override
  String get startRecordingForFirstBadge =>
      'Record an expense to earn your first badge!';

  @override
  String get greatStartKeepGoing => 'Great start, keep going!';

  @override
  String get halfwayThere => 'Halfway there, keep it up!';

  @override
  String get doingVeryWell => 'You\'re doing very well!';

  @override
  String get almostDone => 'Almost there!';

  @override
  String get allBadgesEarned => 'All badges earned, congratulations!';

  @override
  String get hiddenBadge => 'Hidden Badge';

  @override
  String get discoverHowToUnlock => 'Discover how to unlock!';

  @override
  String get difficultyEasy => 'Easy';

  @override
  String get difficultyMedium => 'Medium';

  @override
  String get difficultyHard => 'Hard';

  @override
  String get difficultyLegendary => 'Legendary';

  @override
  String get earnedToday => 'Earned today!';

  @override
  String get earnedYesterday => 'Earned yesterday';

  @override
  String daysAgoEarned(int count) {
    return '$count days ago';
  }

  @override
  String weeksAgoEarned(int count) {
    return '$count weeks ago';
  }

  @override
  String get tapToAddPhoto => 'Tap to add photo';

  @override
  String get dailyWork => 'Daily Work';

  @override
  String get weeklyWorkingDays => 'Weekly Working Days';

  @override
  String get hourlyEarnings => 'Hourly Earnings';

  @override
  String get hourAbbreviation => 'h';

  @override
  String get days => 'days';

  @override
  String get resetData => 'Reset Data';

  @override
  String get resetDataDebug => 'Reset Data (DEBUG)';

  @override
  String get resetDataTitle => 'Reset Data';

  @override
  String get resetDataMessage =>
      'All app data will be deleted. This action cannot be undone.';

  @override
  String get deleteAccountWarningTitle =>
      'You Are About to Delete Your Account';

  @override
  String get deleteAccountWarningMessage =>
      'This action cannot be undone! All your data will be permanently deleted:\n\n• Expenses\n• Income\n• Installments\n• Achievements\n• Settings';

  @override
  String get deleteAccountConfirmPlaceholder => 'Type \'I confirm\' to confirm';

  @override
  String get deleteAccountConfirmWord => 'I confirm';

  @override
  String get deleteAccountButton => 'Delete Account';

  @override
  String get deleteAccountSuccess =>
      'Your account has been successfully deleted';

  @override
  String get deleteAccountError =>
      'An error occurred while deleting your account';

  @override
  String get notificationTypes => 'Notification Types';

  @override
  String get awarenessReminder => 'Awareness Reminder';

  @override
  String get awarenessReminderDesc => '6-12 hours after high-value purchases';

  @override
  String get giveUpCongrats => 'Pass Congratulation';

  @override
  String get giveUpCongratsDesc => 'Same day motivation when you pass';

  @override
  String get streakReminderDesc => 'Evening, before streak breaks';

  @override
  String get weeklySummary => 'Weekly Summary';

  @override
  String get weeklySummaryDesc => 'Sunday weekly insight';

  @override
  String get nightModeNotice =>
      'No notifications during night hours (22:00-08:00). We won\'t disturb your sleep.';

  @override
  String get on => 'On';

  @override
  String get off => 'Off';

  @override
  String get lastUpdate => 'Last Update';

  @override
  String get rates => 'Rates';

  @override
  String get usDollar => 'US Dollar';

  @override
  String get gramGold => 'Gram Gold';

  @override
  String get tcmbNotice =>
      'Rates are from TCMB (Central Bank of the Republic of Turkey). Gold prices reflect real-time market data.';

  @override
  String get buy => 'Buy';

  @override
  String get sell => 'Sell';

  @override
  String get createOwnCategory => 'Create Your Own Category';

  @override
  String get selectEmoji => 'Select Emoji';

  @override
  String get categoryName => 'Category Name';

  @override
  String get categoryNameHint => 'e.g: Starbucks';

  @override
  String get continueButton => 'Continue';

  @override
  String get howManyDaysForHabit => 'How many days do you work for what?';

  @override
  String get selectHabitShock => 'Select a habit, be shocked';

  @override
  String get addMyOwnCategory => 'Add my own category';

  @override
  String get whatIsYourSalary => 'What\'s Your Monthly Salary?';

  @override
  String get enterNetAmount => 'Enter net take-home amount';

  @override
  String get howMuchPerTime => 'How much TL do you spend per time?';

  @override
  String get tl => 'TL';

  @override
  String get howOften => 'How often?';

  @override
  String get whatIsYourIncome => 'What\'s your monthly income?';

  @override
  String get exampleAmount => 'e.g: 20,000';

  @override
  String get dontWantToSay => 'I don\'t want to say';

  @override
  String resultDays(String value) {
    return '$value DAYS';
  }

  @override
  String yearlyHabitCost(String habit) {
    return 'You work this many days\njust for $habit yearly';
  }

  @override
  String monthlyYearlyCost(String monthly, String yearly) {
    return 'Monthly: $monthly • Yearly: $yearly';
  }

  @override
  String get shareOnStory => 'Share on Story';

  @override
  String get tryAnotherHabit => 'Try another habit';

  @override
  String get trackAllExpenses => 'Track all my expenses';

  @override
  String get habitCatCoffee => 'Coffee';

  @override
  String get habitCatSmoking => 'Smoking';

  @override
  String get habitCatEatingOut => 'Eating Out';

  @override
  String get habitCatGaming => 'Gaming';

  @override
  String get habitCatClothing => 'Clothing';

  @override
  String get habitCatTaxi => 'Taxi/Uber';

  @override
  String get freqOnceDaily => 'Once daily';

  @override
  String get freqTwiceDaily => 'Twice daily';

  @override
  String get freqEveryTwoDays => 'Every 2 days';

  @override
  String get freqOnceWeekly => 'Once weekly';

  @override
  String get freqTwoThreeWeekly => '2-3x weekly';

  @override
  String get freqFewMonthly => 'Few per month';

  @override
  String get habitSharePreText => 'This habit takes';

  @override
  String get habitShareWorkDays => 'WORK DAYS';

  @override
  String get habitSharePostText => 'of work per year';

  @override
  String get habitSharePerYear => '/year';

  @override
  String get habitShareCTA => 'How many days are your habits?';

  @override
  String get habitShareText => 'How many days are your habits? 👀 vantag.app';

  @override
  String habitShareTextWithLink(String link) {
    return 'How many days are your habits? 👀 $link';
  }

  @override
  String habitMonthlyDetail(int days, int hours) {
    return '$days days $hours hours';
  }

  @override
  String get editIncomes => 'Edit Incomes';

  @override
  String get editIncome => 'Edit Income';

  @override
  String get addIncome => 'Add Income';

  @override
  String get changePhoto => 'Photo';

  @override
  String get takePhoto => 'Take Photo';

  @override
  String get chooseFromGallery => 'Choose from Gallery';

  @override
  String get removePhoto => 'Remove Photo';

  @override
  String get photoSelectError => 'Could not select photo';

  @override
  String get editSalary => 'Salary';

  @override
  String get editSalarySubtitle => 'Update your monthly salary';

  @override
  String get daysPerWeek => 'days/week';

  @override
  String get doYouHaveOtherIncome => 'Do You Have\nOther Income?';

  @override
  String get otherIncomeDescription =>
      'You can add additional incomes like\nfreelance, rental, investment income';

  @override
  String get yesAddIncome => 'Yes, I Want to Add';

  @override
  String get noOnlySalary => 'No, Only My Salary';

  @override
  String get addAdditionalIncome => '+ Add Additional Income';

  @override
  String get additionalIncomeQuestion => 'Do you have additional income?';

  @override
  String get budgetSettings => 'Budget Settings';

  @override
  String get budgetSettingsHint =>
      'Optional. If not set, it will be calculated based on your income.';

  @override
  String get monthlySpendingLimit => 'Monthly Spending Limit';

  @override
  String get monthlySpendingLimitHint =>
      'How much do you want to spend this month?';

  @override
  String get monthlySavingsGoal => 'Monthly Savings Goal';

  @override
  String get monthlySavingsGoalHint =>
      'How much do you want to save each month?';

  @override
  String get budgetInfoMessage =>
      'The progress bar is calculated based on your remaining budget after mandatory expenses.';

  @override
  String get linkWithGoogleTitle => 'Link with Google';

  @override
  String get linkWithGoogleDescription =>
      'Securely access your data from all devices';

  @override
  String get skipForNow => 'Skip for now';

  @override
  String get incomeType => 'Income type';

  @override
  String get incomeCategorySalary => 'Salary';

  @override
  String get incomeCategoryFreelance => 'Freelance';

  @override
  String get incomeCategoryRental => 'Rental Income';

  @override
  String get incomeCategoryPassive => 'Passive Income';

  @override
  String get incomeCategoryOther => 'Other';

  @override
  String get incomeCategorySalaryDesc => 'Monthly regular salary';

  @override
  String get incomeCategoryFreelanceDesc => 'Self-employment income';

  @override
  String get incomeCategoryRentalDesc => 'Property, vehicle rental income';

  @override
  String get incomeCategoryPassiveDesc =>
      'Investment, dividends, interest etc.';

  @override
  String get incomeCategoryOtherDesc => 'Other income sources';

  @override
  String get mainSalary => 'Main Salary';

  @override
  String get descriptionOptional => 'Description (Optional)';

  @override
  String get descriptionOptionalHint => 'e.g: Upwork Project';

  @override
  String get addedIncomes => 'Added Incomes';

  @override
  String get incomeSummary => 'Income Summary';

  @override
  String get totalMonthlyIncome => 'Total Monthly Income';

  @override
  String get incomeSource => 'income source';

  @override
  String get complete => 'Complete';

  @override
  String get editMyIncomes => 'Edit My Incomes';

  @override
  String get goBack => 'Go Back';

  @override
  String get notBudgetApp => 'This is not a budget app';

  @override
  String get showRealCost => 'Show the real cost of expenses: your time.';

  @override
  String get everyExpenseDecision => 'Every expense is a decision';

  @override
  String get youDecide => 'Bought, thinking, or passed. You decide.';

  @override
  String get oneExpenseEnough => 'One expense today is enough';

  @override
  String get startSmall => 'Start small, awareness grows.';

  @override
  String get skip => 'Skip';

  @override
  String get start => 'Start';

  @override
  String get whatIsYourDecision => 'What\'s your decision?';

  @override
  String get netBalance => 'NET BALANCE';

  @override
  String sources(int count) {
    return '$count sources';
  }

  @override
  String get income => 'INCOME';

  @override
  String get expense => 'SPENT';

  @override
  String get saved => 'SAVED';

  @override
  String get budgetUsage => 'BUDGET USAGE';

  @override
  String get startToday => 'Start today!';

  @override
  String dayStreak(int count) {
    return '$count Day Streak!';
  }

  @override
  String get startStreak => 'Start Your Streak!';

  @override
  String get keepStreakMessage =>
      'Keep your streak by recording expenses daily!';

  @override
  String get startStreakMessage =>
      'Record at least 1 expense daily and build a streak!';

  @override
  String longestStreak(int count) {
    return 'Longest streak: $count days';
  }

  @override
  String get newRecord => 'New Record!';

  @override
  String withThisAmount(String amount) {
    return 'With this $amount TL you could have bought:';
  }

  @override
  String goldGrams(String grams) {
    return '${grams}g gold';
  }

  @override
  String get ratesLoading => 'Loading rates...';

  @override
  String get ratesLoadFailed => 'Failed to load rates';

  @override
  String get goldPriceNotUpdated => 'Gold price could not be updated';

  @override
  String get monthAbbreviations =>
      'Jan,Feb,Mar,Apr,May,Jun,Jul,Aug,Sep,Oct,Nov,Dec';

  @override
  String get updateYourDecision => 'Update your decision';

  @override
  String get simulation => 'Simulation';

  @override
  String get tapToUpdate => 'Tap to update';

  @override
  String get swipeToEditOrDelete => 'Swipe to edit or delete';

  @override
  String get pleaseEnterValidAmount => 'Please enter a valid amount';

  @override
  String get amountTooHigh => 'Amount seems too high';

  @override
  String get pleaseSelectExpenseGroup => 'Please select expense group first';

  @override
  String get categorySelectionRequired => 'Category selection is required';

  @override
  String get expenseGroup => 'Expense Group';

  @override
  String get required => 'Required';

  @override
  String get detail => 'Detail';

  @override
  String get optional => 'Optional';

  @override
  String get editYourCard => 'Edit Your Card';

  @override
  String get share => 'Share';

  @override
  String get sharing => 'Sharing...';

  @override
  String get frequency => 'Frequency';

  @override
  String get daysAbbrev => 'days';

  @override
  String get youSaved => 'saved!';

  @override
  String get noSavingsYet => 'No savings yet';

  @override
  String get categorySports => 'Sports';

  @override
  String get categoryCommunication => 'Communication';

  @override
  String get subscriptionNameExample => 'e.g: Netflix, Spotify';

  @override
  String get monthlyAmountExample => 'e.g: 99.99';

  @override
  String get color => 'Color';

  @override
  String get autoRecordOnRenewal => 'Record as expense on renewal day';

  @override
  String get deleteSubscription => 'Delete Subscription';

  @override
  String deleteSubscriptionConfirm(String name) {
    return 'Are you sure you want to delete $name subscription?';
  }

  @override
  String get subscriptionDuration => 'Subscription Duration';

  @override
  String subscriptionDurationDays(int days) {
    return '$days days';
  }

  @override
  String get totalPaid => 'Total Paid';

  @override
  String workHoursAmount(String hours) {
    return '$hours hours';
  }

  @override
  String workDaysAmount(String days) {
    return '$days days';
  }

  @override
  String get autoRecordEnabled => 'Auto-record enabled';

  @override
  String get autoRecordDisabled => 'Auto expense recording disabled';

  @override
  String get saveChanges => 'Save Changes';

  @override
  String get weekdayAbbreviations => 'Mon,Tue,Wed,Thu,Fri,Sat,Sun';

  @override
  String get homePage => 'Home';

  @override
  String get analysis => 'Analysis';

  @override
  String get reportsDescription =>
      'View monthly and category-based expense analysis here.';

  @override
  String get quickAdd => 'Quick Add';

  @override
  String get quickAddDescription =>
      'Use this button to quickly add expenses from anywhere. Practical and fast!';

  @override
  String get badgesDescription =>
      'Earn badges as you reach your savings goals. Keep your motivation high!';

  @override
  String get profileAndSettings => 'Profile & Settings';

  @override
  String get profileAndSettingsDescription =>
      'Edit income info, manage notification preferences and access app settings.';

  @override
  String get addSubscriptionButton => 'Add subscriptions like Netflix, Spotify';

  @override
  String get shareError => 'An error occurred while sharing';

  @override
  String get shareVia => 'Share via';

  @override
  String get saveToGallery => 'Save to Gallery';

  @override
  String get savedToGallery => 'Saved to gallery';

  @override
  String get otherApps => 'Other Apps';

  @override
  String get expenseDeleted => 'Expense deleted';

  @override
  String get undo => 'Undo';

  @override
  String get choosePlatform => 'Choose Platform';

  @override
  String get savingToGallery => 'Saving...';

  @override
  String get pleaseEnterValidSalary => 'Please enter a valid salary';

  @override
  String get pleaseEnterValidIncomeAmount => 'Please enter a valid amount';

  @override
  String get atLeastOneIncomeRequired =>
      'You must add at least one income source';

  @override
  String get incomesUpdated => 'Incomes updated';

  @override
  String get incomesSaved => 'Incomes saved';

  @override
  String get saveError => 'An error occurred while saving';

  @override
  String incomeSourceCount(int count) {
    return '$count income sources';
  }

  @override
  String get freedTime => 'Freed';

  @override
  String get savedAmountLabel => 'Saved';

  @override
  String get dayLabel => 'Day';

  @override
  String get zeroMinutes => '0 Minutes';

  @override
  String get zeroAmount => '0 ₺';

  @override
  String shareCardDays(int days) {
    return '$days DAYS';
  }

  @override
  String shareCardDescription(String category) {
    return 'I work this many days yearly\njust for $category';
  }

  @override
  String get shareCardQuestion => 'How many days for you?';

  @override
  String shareCardDuration(int days) {
    return 'Duration ($days days)';
  }

  @override
  String shareCardAmountLabel(String amount) {
    return 'Amount (₺$amount)';
  }

  @override
  String shareCardFrequency(String frequency) {
    return 'Frequency ($frequency)';
  }

  @override
  String get unsavedChanges => 'Unsaved Changes';

  @override
  String get unsavedChangesConfirm =>
      'Are you sure you want to exit without saving?';

  @override
  String get discardChanges => 'Discard';

  @override
  String get thinkingTime => 'Thinking time...';

  @override
  String get confirm => 'Confirm';

  @override
  String get riskLevelNone => 'Safe';

  @override
  String get riskLevelLow => 'Low Risk';

  @override
  String get riskLevelMedium => 'Medium Risk';

  @override
  String get riskLevelHigh => 'High Risk';

  @override
  String get riskLevelExtreme => 'Critical Risk';

  @override
  String savedTimeHoursDays(String hours, String days) {
    return '$hours hours = $days days saved';
  }

  @override
  String savedTimeHours(String hours) {
    return '$hours hours saved';
  }

  @override
  String savedTimeMinutes(int minutes) {
    return '$minutes minutes saved';
  }

  @override
  String couldBuyGoldGrams(String grams) {
    return 'With this money you could buy $grams grams of gold';
  }

  @override
  String equivalentWorkDays(String days) {
    return 'This equals $days days of work';
  }

  @override
  String equivalentWorkHours(String hours) {
    return 'This equals $hours hours of work';
  }

  @override
  String savedDollars(String amount) {
    return 'You saved exactly $amount dollars';
  }

  @override
  String get or => 'OR';

  @override
  String goldGramsShort(String grams) {
    return '${grams}g gold';
  }

  @override
  String get amountRequired => 'Amount is required';

  @override
  String get everyMonth => 'Every month';

  @override
  String daysCount(int count) {
    return '$count days';
  }

  @override
  String hoursCount(String count) {
    return '$count hours';
  }

  @override
  String daysCountDecimal(String count) {
    return '$count days';
  }

  @override
  String get autoRecordOn => 'Auto record enabled';

  @override
  String get autoRecordOff => 'Auto record disabled';

  @override
  String monthlyAmountTl(String amount) {
    return '$amount TL/month';
  }

  @override
  String get nameRequired => 'Name is required';

  @override
  String get amountHint => 'e.g: 99.99';

  @override
  String get updateDecision => 'Update your decision';

  @override
  String get categoryRequired => 'Category is required';

  @override
  String get monthlyAmountLabel => 'Monthly Amount (TL)';

  @override
  String withThisAmountYouCouldBuy(String amount) {
    return 'With $amount TL you could buy:';
  }

  @override
  String get workHoursDistribution => 'Work Hours Distribution';

  @override
  String get workHoursDistributionDesc =>
      'See how many hours you work for each category';

  @override
  String hoursShort(String hours) {
    return '${hours}h';
  }

  @override
  String categoryHoursBar(String hours, String percent) {
    return '$hours hours ($percent%)';
  }

  @override
  String get monthComparison => 'Month Comparison';

  @override
  String get vsLastMonth => 'vs Last Month';

  @override
  String get noLastMonthData => 'No last month data';

  @override
  String decreasedBy(String percent) {
    return '↓ $percent% decreased';
  }

  @override
  String increasedBy(String percent) {
    return '↑ $percent% increased';
  }

  @override
  String get noChange => 'No change';

  @override
  String get greatProgress => 'Great progress!';

  @override
  String get watchOut => 'Watch out!';

  @override
  String get smartInsights => 'Smart Insights';

  @override
  String get mostExpensiveDay => 'Most Expensive Day';

  @override
  String mostExpensiveDayValue(String day, String amount) {
    return '$day (avg. $amount TL)';
  }

  @override
  String get mostPassedCategory => 'Most Passed Category';

  @override
  String mostPassedCategoryValue(String category, int count) {
    return '$category ($count times)';
  }

  @override
  String get savingsOpportunity => 'Savings Opportunity';

  @override
  String savingsOpportunityValue(String category, String hours) {
    return 'Cut $category by 20% = ${hours}h saved/month';
  }

  @override
  String get weeklyTrend => 'Weekly Trend';

  @override
  String weeklyTrendValue(String trend) {
    return 'Last 4 weeks: $trend';
  }

  @override
  String get overallDecreasing => 'Overall decreasing';

  @override
  String get overallIncreasing => 'Overall increasing';

  @override
  String get stableTrend => 'Stable';

  @override
  String get noTrendData => 'Not enough data';

  @override
  String get yearlyView => 'Yearly View';

  @override
  String get yearlyHeatmap => 'Spending Trend';

  @override
  String get yearlyHeatmapDesc =>
      'Your monthly spending over the last 12 months';

  @override
  String get lowSpending => 'Low';

  @override
  String get highSpending => 'High';

  @override
  String get noSpending => 'No spending';

  @override
  String get tapDayForDetails => 'Tap a day for details';

  @override
  String get tapMonthForDetails => 'Tap a month for details';

  @override
  String selectedDayExpenses(String date, String amount, int count) {
    return '$date: $amount TL ($count expenses)';
  }

  @override
  String selectedMonthExpenses(String month, String amount, int count) {
    return '$month: $amount ($count expenses)';
  }

  @override
  String get proBadge => 'PRO';

  @override
  String get proFeature => 'Pro Feature';

  @override
  String get comingSoon => 'Coming Soon';

  @override
  String get mindfulChoice => 'Mindful Choice';

  @override
  String get mindfulChoiceExpandedDesc =>
      'What were you originally planning to buy?';

  @override
  String get mindfulChoiceCollapsedDesc =>
      'Were you going to buy something more expensive?';

  @override
  String get mindfulChoiceAmountLabel => 'Amount in Mind (₺)';

  @override
  String mindfulChoiceAmountHint(String amount) {
    return 'e.g: $amount';
  }

  @override
  String mindfulChoiceSavings(String amount) {
    return '$amount TL savings';
  }

  @override
  String get mindfulChoiceSavingsDesc =>
      'Stays in your pocket with mindful choice';

  @override
  String get tierBronze => 'Bronze';

  @override
  String get tierSilver => 'Silver';

  @override
  String get tierGold => 'Gold';

  @override
  String get tierPlatinum => 'Platinum';

  @override
  String get achievementCategoryStreak => 'Streak';

  @override
  String get achievementCategorySavings => 'Savings';

  @override
  String get achievementCategoryDecision => 'Decision';

  @override
  String get achievementCategoryRecord => 'Record';

  @override
  String get achievementCategoryHidden => 'Hidden';

  @override
  String get achievementStreakB1Title => 'Getting Started';

  @override
  String get achievementStreakB1Desc => 'Record for 3 days in a row';

  @override
  String get achievementStreakB2Title => 'Keeping Going';

  @override
  String get achievementStreakB2Desc => 'Record for 7 days in a row';

  @override
  String get achievementStreakB3Title => 'Building Routine';

  @override
  String get achievementStreakB3Desc => 'Record for 14 days in a row';

  @override
  String get achievementStreakS1Title => 'Determination';

  @override
  String get achievementStreakS1Desc => 'Record for 30 days in a row';

  @override
  String get achievementStreakS2Title => 'Habit';

  @override
  String get achievementStreakS2Desc => 'Record for 60 days in a row';

  @override
  String get achievementStreakS3Title => 'Discipline';

  @override
  String get achievementStreakS3Desc => 'Record for 90 days in a row';

  @override
  String get achievementStreakG1Title => 'Strong Will';

  @override
  String get achievementStreakG1Desc => 'Record for 150 days in a row';

  @override
  String get achievementStreakG2Title => 'Unshakeable';

  @override
  String get achievementStreakG2Desc => 'Record for 250 days in a row';

  @override
  String get achievementStreakG3Title => 'Consistency';

  @override
  String get achievementStreakG3Desc => 'Record for 365 days in a row';

  @override
  String get achievementStreakPTitle => 'Persistence';

  @override
  String get achievementStreakPDesc => 'Record for 730 days in a row';

  @override
  String get achievementSavingsB1Title => 'First Savings';

  @override
  String get achievementSavingsB1Desc => 'Saved 250 TL';

  @override
  String get achievementSavingsB2Title => 'Starting to Save';

  @override
  String get achievementSavingsB2Desc => 'Saved 500 TL';

  @override
  String get achievementSavingsB3Title => 'On the Right Path';

  @override
  String get achievementSavingsB3Desc => 'Saved 1,000 TL';

  @override
  String get achievementSavingsS1Title => 'Mindful Spending';

  @override
  String get achievementSavingsS1Desc => 'Saved 2,500 TL';

  @override
  String get achievementSavingsS2Title => 'In Control';

  @override
  String get achievementSavingsS2Desc => 'Saved 5,000 TL';

  @override
  String get achievementSavingsS3Title => 'Consistent';

  @override
  String get achievementSavingsS3Desc => 'Saved 10,000 TL';

  @override
  String get achievementSavingsG1Title => 'Strong Savings';

  @override
  String get achievementSavingsG1Desc => 'Saved 25,000 TL';

  @override
  String get achievementSavingsG2Title => 'Financial Awareness';

  @override
  String get achievementSavingsG2Desc => 'Saved 50,000 TL';

  @override
  String get achievementSavingsG3Title => 'Solid Foundation';

  @override
  String get achievementSavingsG3Desc => 'Saved 100,000 TL';

  @override
  String get achievementSavingsP1Title => 'Long-term Thinking';

  @override
  String get achievementSavingsP1Desc => 'Saved 250,000 TL';

  @override
  String get achievementSavingsP2Title => 'Financial Clarity';

  @override
  String get achievementSavingsP2Desc => 'Saved 500,000 TL';

  @override
  String get achievementSavingsP3Title => 'Big Picture';

  @override
  String get achievementSavingsP3Desc => 'Saved 1,000,000 TL';

  @override
  String get achievementDecisionB1Title => 'First Decision';

  @override
  String get achievementDecisionB1Desc => 'Passed 3 times';

  @override
  String get achievementDecisionB2Title => 'Resistance';

  @override
  String get achievementDecisionB2Desc => 'Passed 7 times';

  @override
  String get achievementDecisionB3Title => 'Control';

  @override
  String get achievementDecisionB3Desc => 'Passed 15 times';

  @override
  String get achievementDecisionS1Title => 'Determination';

  @override
  String get achievementDecisionS1Desc => 'Passed 30 times';

  @override
  String get achievementDecisionS2Title => 'Clarity';

  @override
  String get achievementDecisionS2Desc => 'Passed 60 times';

  @override
  String get achievementDecisionS3Title => 'Strong Choices';

  @override
  String get achievementDecisionS3Desc => 'Passed 100 times';

  @override
  String get achievementDecisionG1Title => 'Willpower';

  @override
  String get achievementDecisionG1Desc => 'Passed 200 times';

  @override
  String get achievementDecisionG2Title => 'Composure';

  @override
  String get achievementDecisionG2Desc => 'Passed 400 times';

  @override
  String get achievementDecisionG3Title => 'Top Level Control';

  @override
  String get achievementDecisionG3Desc => 'Passed 700 times';

  @override
  String get achievementDecisionPTitle => 'Total Mastery';

  @override
  String get achievementDecisionPDesc => 'Passed 1,000 times';

  @override
  String get achievementRecordB1Title => 'Started';

  @override
  String get achievementRecordB1Desc => '5 expense records';

  @override
  String get achievementRecordB2Title => 'Tracking';

  @override
  String get achievementRecordB2Desc => '15 expense records';

  @override
  String get achievementRecordB3Title => 'Organized';

  @override
  String get achievementRecordB3Desc => '30 expense records';

  @override
  String get achievementRecordS1Title => 'Detailed Tracking';

  @override
  String get achievementRecordS1Desc => '60 expense records';

  @override
  String get achievementRecordS2Title => 'Analytical';

  @override
  String get achievementRecordS2Desc => '120 expense records';

  @override
  String get achievementRecordS3Title => 'Systematic';

  @override
  String get achievementRecordS3Desc => '200 expense records';

  @override
  String get achievementRecordG1Title => 'Depth';

  @override
  String get achievementRecordG1Desc => '350 expense records';

  @override
  String get achievementRecordG2Title => 'Mastery';

  @override
  String get achievementRecordG2Desc => '600 expense records';

  @override
  String get achievementRecordG3Title => 'Archive';

  @override
  String get achievementRecordG3Desc => '1,000 expense records';

  @override
  String get achievementRecordPTitle => 'Long-term Record';

  @override
  String get achievementRecordPDesc => '2,000 expense records';

  @override
  String get achievementHiddenNightTitle => 'Night Record';

  @override
  String get achievementHiddenNightDesc => 'Record between 00:00-05:00';

  @override
  String get achievementHiddenEarlyTitle => 'Early Bird';

  @override
  String get achievementHiddenEarlyDesc => 'Record between 05:00-07:00';

  @override
  String get achievementHiddenWeekendTitle => 'Weekend Routine';

  @override
  String get achievementHiddenWeekendDesc => '5 records on Saturday-Sunday';

  @override
  String get achievementHiddenOcrTitle => 'First Scan';

  @override
  String get achievementHiddenOcrDesc => 'First receipt OCR usage';

  @override
  String get achievementHiddenBalancedTitle => 'Balanced Week';

  @override
  String get achievementHiddenBalancedDesc =>
      '7 days in a row with 0 \"Bought\"';

  @override
  String get achievementHiddenCategoriesTitle => 'Category Completion';

  @override
  String get achievementHiddenCategoriesDesc => 'Record in all 6 categories';

  @override
  String get achievementHiddenGoldTitle => 'Gold Equivalent';

  @override
  String get achievementHiddenGoldDesc => 'Saved money equals 1 gram of gold';

  @override
  String get achievementHiddenUsdTitle => 'Currency Equivalent';

  @override
  String get achievementHiddenUsdDesc => 'Saved money equals \$100';

  @override
  String get achievementHiddenSubsTitle => 'Subscription Control';

  @override
  String get achievementHiddenSubsDesc => 'Track 5 subscriptions';

  @override
  String get achievementHiddenNoSpendTitle => 'No-Spend Month';

  @override
  String get achievementHiddenNoSpendDesc => '0 \"Bought\" for 1 month';

  @override
  String get achievementHiddenGoldKgTitle => 'High Value Savings';

  @override
  String get achievementHiddenGoldKgDesc => 'Saved money equals 1 kg of gold';

  @override
  String get achievementHiddenUsd10kTitle => 'Major Currency Equivalent';

  @override
  String get achievementHiddenUsd10kDesc => 'Saved money equals \$10,000';

  @override
  String get achievementHiddenAnniversaryTitle => 'Usage Anniversary';

  @override
  String get achievementHiddenAnniversaryDesc => '365 days of usage';

  @override
  String get achievementHiddenEarlyAdopterTitle => 'Early Adopter';

  @override
  String get achievementHiddenEarlyAdopterDesc =>
      'Installed the app 2 years ago';

  @override
  String get achievementHiddenUltimateTitle => 'Long-term Discipline';

  @override
  String get achievementHiddenUltimateDesc =>
      '1,000,000 TL + 365 day streak at once';

  @override
  String get achievementHiddenCollectorTitle => 'Collector';

  @override
  String get achievementHiddenCollectorDesc =>
      'Collected all badges except Platinum';

  @override
  String get easterEgg5Left => '5 more...';

  @override
  String get easterEggAlmost => 'Almost...';

  @override
  String get achievementUnlocked => 'Achievement Unlocked!';

  @override
  String get curiousCatTitle => 'Too Curious';

  @override
  String get curiousCatDescription => 'You found the hidden Easter Egg!';

  @override
  String get great => 'Great!';

  @override
  String get achievementHiddenCuriousCatTitle => 'Too Curious';

  @override
  String get achievementHiddenCuriousCatDesc =>
      'You found the hidden Easter Egg!';

  @override
  String get recentExpenses => 'Recent Expenses';

  @override
  String get seeMore => 'See More';

  @override
  String get tapPlusToAdd => 'Tap + to add your first expense';

  @override
  String get expenseAdded => 'Expense added successfully';

  @override
  String get duplicateExpenseWarning => 'This expense already seems to exist';

  @override
  String duplicateExpenseDetails(String amount, String category) {
    return '$amount $category';
  }

  @override
  String get addAnyway => 'Do you still want to add it?';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get timeAgoNow => 'just now';

  @override
  String timeAgoMinutes(int count) {
    return '$count minutes ago';
  }

  @override
  String timeAgoHours(int count) {
    return '$count hours ago';
  }

  @override
  String timeAgoDays(int count) {
    return '$count days ago';
  }

  @override
  String get exportToExcel => 'Export to Excel';

  @override
  String get exportReport => 'Export Report';

  @override
  String get exporting => 'Exporting...';

  @override
  String get exportSuccess => 'Report exported successfully';

  @override
  String get exportError => 'Export failed';

  @override
  String get exportComplete => 'Export Complete';

  @override
  String get exportShareOption => 'Share';

  @override
  String get exportSaveOption => 'Save to Files';

  @override
  String get exportSavedToDownloads => 'Saved to Downloads/Vantag';

  @override
  String get exportChooseAction => 'What would you like to do with the file?';

  @override
  String get csvHeaderDate => 'Date';

  @override
  String get csvHeaderTime => 'Time';

  @override
  String get csvHeaderAmount => 'Amount';

  @override
  String get csvHeaderCurrency => 'Currency';

  @override
  String get csvHeaderCategory => 'Category';

  @override
  String get csvHeaderSubcategory => 'Subcategory';

  @override
  String get csvHeaderDescription => 'Description';

  @override
  String get csvHeaderProduct => 'Product';

  @override
  String get csvHeaderDecision => 'Decision';

  @override
  String get csvHeaderWorkHours => 'Work Hours';

  @override
  String get csvHeaderInstallment => 'Installment';

  @override
  String get csvHeaderMandatory => 'Mandatory';

  @override
  String get csvSummarySection => 'SUMMARY';

  @override
  String get csvTotalExpense => 'Total Expense';

  @override
  String get csvCategoryTotals => 'Category Totals';

  @override
  String get csvDailyAverage => 'Daily Average';

  @override
  String get csvWeeklyAverage => 'Weekly Average';

  @override
  String get csvTopCategory => 'Top Category';

  @override
  String get csvLargestExpense => 'Largest Expense';

  @override
  String get csvTotalWorkHours => 'Total Work Hours';

  @override
  String get csvPeriod => 'Period';

  @override
  String get csvYes => 'Yes';

  @override
  String get csvNo => 'No';

  @override
  String get financialReport => 'Financial Summary Report';

  @override
  String get createdAt => 'Created';

  @override
  String get savingsRate => 'Savings Rate';

  @override
  String get hourlyRate => 'Hourly Rate';

  @override
  String get workHoursEquivalent => 'Work Hours Equivalent';

  @override
  String get transactionCount => 'Transaction Count';

  @override
  String get average => 'Average';

  @override
  String get percentage => 'Percentage';

  @override
  String get total => 'Total';

  @override
  String get monthly => 'Monthly';

  @override
  String get yearly => 'Yearly';

  @override
  String get changePercent => 'Change %';

  @override
  String get month => 'Month';

  @override
  String get originalAmount => 'Original Amount';

  @override
  String get nextRenewal => 'Next Renewal';

  @override
  String get yearlyAmount => 'Yearly Amount';

  @override
  String get badge => 'Badge';

  @override
  String get status => 'Status';

  @override
  String get earnedDate => 'Earned Date';

  @override
  String get totalBadges => 'Total Badges';

  @override
  String get proFeatureExport => 'Excel Export is a Pro feature';

  @override
  String get upgradeForExport => 'Upgrade to Pro to export your financial data';

  @override
  String get importPremiumOnly => 'Import is a Pro feature';

  @override
  String get upgradeForImport =>
      'Upgrade to Pro to import your bank statements';

  @override
  String get receiptScanned => 'Receipt scanned successfully';

  @override
  String get noAmountFound => 'No amount found in the image';

  @override
  String saveAllRecognized(int count) {
    return 'Save All ($count)';
  }

  @override
  String saveAllRecognizedSuccess(int count) {
    return '$count expenses saved successfully';
  }

  @override
  String get budgets => 'Budgets';

  @override
  String get budget => 'Budget';

  @override
  String get addBudget => 'Add Budget';

  @override
  String get editBudget => 'Edit Budget';

  @override
  String get deleteBudget => 'Delete Budget';

  @override
  String get deleteBudgetConfirm =>
      'Are you sure you want to delete this budget?';

  @override
  String get monthlyLimit => 'Monthly Limit';

  @override
  String get budgetProgress => 'Budget Progress';

  @override
  String get totalBudget => 'Total Budget';

  @override
  String remainingAmount(String amount) {
    return '$amount remaining';
  }

  @override
  String overBudgetAmount(String amount) {
    return '$amount over!';
  }

  @override
  String ofBudget(String spent, String total) {
    return '$spent of $total';
  }

  @override
  String get onTrack => 'On track';

  @override
  String get nearLimit => 'Near limit';

  @override
  String get overLimit => 'Over limit';

  @override
  String get noBudgetsYet => 'No budgets yet';

  @override
  String get noBudgetsDescription =>
      'Set budgets to track your spending by category';

  @override
  String get budgetHelperText =>
      'Set a monthly spending limit for this category';

  @override
  String get budgetExceededTitle => 'Budget Exceeded!';

  @override
  String budgetExceededMessage(String category, String amount) {
    return 'You\'ve exceeded your $category budget by $amount';
  }

  @override
  String get budgetNearLimit => 'Approaching budget limit';

  @override
  String budgetNearLimitMessage(String percent, String category) {
    return 'You\'ve used $percent% of your $category budget';
  }

  @override
  String categoriesOnTrack(int count) {
    return '$count on track';
  }

  @override
  String categoriesOverBudget(int count) {
    return '$count over budget';
  }

  @override
  String categoriesNearLimit(int count) {
    return '$count near limit';
  }

  @override
  String get categories => 'categories';

  @override
  String get viewAll => 'View All';

  @override
  String get viewBudgetsInReports => 'View budget details in Reports tab';

  @override
  String pendingCategorization(int count) {
    return '$count expenses pending categorization';
  }

  @override
  String suggestionsAvailable(int count) {
    return '$count suggestions available';
  }

  @override
  String get reviewExpenses => 'Review Expenses';

  @override
  String get swipeToCategorizeTip => 'Tap a category to categorize';

  @override
  String get rememberMerchant => 'Remember this merchant';

  @override
  String suggestionLabel(String name) {
    return 'Suggestion: $name';
  }

  @override
  String get suggested => 'Suggested';

  @override
  String get allCategorized => 'All Done!';

  @override
  String categorizedCount(int processed, int skipped) {
    return '$processed categorized, $skipped skipped';
  }

  @override
  String get importStatement => 'Import Statement';

  @override
  String get importCSV => 'Import CSV';

  @override
  String get importFromBank => 'Import from Bank';

  @override
  String get selectCSVFile => 'Select CSV file';

  @override
  String get importingExpenses => 'Importing expenses...';

  @override
  String importSuccess(int count) {
    return '$count expenses imported successfully';
  }

  @override
  String get importError => 'Import failed';

  @override
  String recognizedExpenses(int count) {
    return '$count recognized';
  }

  @override
  String pendingExpenses(int count) {
    return '$count pending review';
  }

  @override
  String get importSummary => 'Import Summary';

  @override
  String get autoMatched => 'Auto-matched';

  @override
  String get needsReview => 'Needs Review';

  @override
  String get startReview => 'Start Review';

  @override
  String get importAIParsed => 'AI Parsed Transactions';

  @override
  String get importNoTransactions => 'No transactions found in this file';

  @override
  String importSelected(int count) {
    return 'Save $count Selected';
  }

  @override
  String get transactions => 'transactions';

  @override
  String get selectAll => 'Select All';

  @override
  String get selectNone => 'Select None';

  @override
  String get selected => 'selected';

  @override
  String get saving => 'Saving...';

  @override
  String get learnedMerchants => 'Learned Merchants';

  @override
  String get noLearnedMerchants => 'No learned merchants yet';

  @override
  String get learnedMerchantsDescription =>
      'Merchants you categorize will appear here';

  @override
  String merchantCount(int count) {
    return '$count merchants learned';
  }

  @override
  String get deleteMerchant => 'Delete Merchant';

  @override
  String get deleteMerchantConfirm =>
      'Are you sure you want to delete this merchant?';

  @override
  String get voiceInput => 'Voice Input';

  @override
  String get listening => 'Listening...';

  @override
  String get voiceNotAvailable => 'Voice input is not available on this device';

  @override
  String get microphonePermissionDenied => 'Microphone permission denied';

  @override
  String get microphonePermissionRequired => 'Microphone permission required';

  @override
  String get networkRequired => 'Internet connection required';

  @override
  String get understanding => 'Understanding...';

  @override
  String get couldNotUnderstandTryAgain => 'Could not understand, try again';

  @override
  String get couldNotUnderstandSayAgain => 'Could not understand, say again';

  @override
  String get sayAgain => 'Say again';

  @override
  String get yesSave => 'Yes, save';

  @override
  String voiceExpenseAdded(String amount, String description) {
    return '$amount₺ $description added';
  }

  @override
  String get voiceConfirmExpense => 'Confirm Expense';

  @override
  String voiceDetectedAmount(String amount) {
    return 'Detected: $amount₺';
  }

  @override
  String get tapToSpeak => 'Tap to speak';

  @override
  String get speakExpense => 'Say your expense (e.g. \"50 lira coffee\")';

  @override
  String get voiceParsingFailed => 'Could not understand. Please try again.';

  @override
  String get voiceHighConfidence => 'Auto-saved';

  @override
  String get voiceMediumConfidence => 'Tap to edit';

  @override
  String get voiceLowConfidence => 'Please confirm';

  @override
  String get speakYourExpense => 'Speak your expense';

  @override
  String get longPressForVoice => 'Long-press for voice input';

  @override
  String get didYouKnow => 'Did you know?';

  @override
  String get voiceTipMessage =>
      'Add expenses faster! Long-press + button and say: \"50 lira coffee\"';

  @override
  String get gotIt => 'Got it';

  @override
  String get tryNow => 'Try Now';

  @override
  String get voiceAndShortcuts => 'Voice & Shortcuts';

  @override
  String get newBadge => 'NEW';

  @override
  String get voiceInputHint => 'Long-press + button for voice';

  @override
  String get howToUseVoice => 'How to Use Voice';

  @override
  String get voiceLimitReachedTitle => 'Daily Limit Reached';

  @override
  String get voiceLimitReachedFree =>
      'You\'ve used your daily voice input. Upgrade to Pro for unlimited access or try again tomorrow.';

  @override
  String get voiceServerBusyTitle => 'Servers Busy';

  @override
  String get voiceServerBusyMessage =>
      'Voice servers are busy right now. Please try again shortly.';

  @override
  String get longPressFab => 'Long-Press + Button';

  @override
  String get longPressFabHint => 'Hold for 1 second';

  @override
  String get micButton => 'Microphone Button';

  @override
  String get micButtonHint => 'Tap mic when adding expense';

  @override
  String get exampleCommands => 'Example Commands';

  @override
  String get voiceExample1 => '\"50 dollars for coffee\"';

  @override
  String get voiceExample2 => '\"Spent 200 on groceries\"';

  @override
  String get voiceExample3 => '\"Taxi was 150\"';

  @override
  String get voiceExamplesMultiline =>
      '\"50 dollars coffee\"\n\"spent 200 on groceries\"\n\"taxi was 150\"';

  @override
  String get somethingWentWrong => 'Something went wrong. Please try again.';

  @override
  String get errorLoadingData => 'Error loading data';

  @override
  String get errorSaving => 'Error saving. Please try again.';

  @override
  String get networkError => 'Network error. Check your connection.';

  @override
  String get errorLoadingRates => 'Could not load exchange rates';

  @override
  String get errorLoadingSubscriptions => 'Could not load subscriptions';

  @override
  String get autoRecorded => 'Auto';

  @override
  String autoRecordedExpenses(int count) {
    return '$count subscription(s) auto-recorded';
  }

  @override
  String get security => 'Security';

  @override
  String get pinLock => 'PIN Lock';

  @override
  String get pinLockDescription => 'Require PIN to open app';

  @override
  String get biometricUnlock => 'Biometric Unlock';

  @override
  String get biometricDescription => 'Use fingerprint or Face ID';

  @override
  String get enterPin => 'Enter PIN';

  @override
  String get createPin => 'Create PIN';

  @override
  String get createPinDescription => 'Choose a 4-digit PIN';

  @override
  String get confirmPin => 'Confirm PIN';

  @override
  String get confirmPinDescription => 'Enter your PIN again';

  @override
  String get wrongPin => 'Wrong PIN. Try again.';

  @override
  String get pinMismatch => 'PINs don\'t match. Try again.';

  @override
  String get pinSet => 'PIN set successfully';

  @override
  String get useBiometric => 'Use Biometric';

  @override
  String get unlockWithBiometric => 'Unlock Vantag';

  @override
  String get reset => 'Reset';

  @override
  String get assistantSetupTitle => 'Google Assistant Setup';

  @override
  String get assistantSetupHeadline => 'Add expenses without saying \"Vantag\"';

  @override
  String get assistantSetupSubheadline =>
      'After this setup, just say\n\"Hey Google, add expense\"';

  @override
  String get assistantSetupComplete =>
      'Great! Now you can say \"Hey Google, add expense\"';

  @override
  String get assistantSetupStep1Title => 'Open Google Assistant';

  @override
  String get assistantSetupStep1Desc =>
      'Say \"Hey Google, settings\" or open the Google Assistant app.';

  @override
  String get assistantSetupStep1Tip =>
      'Tap the profile icon in the bottom right corner.';

  @override
  String get assistantSetupStep2Title => 'Go to Routines';

  @override
  String get assistantSetupStep2Desc =>
      'Find and tap \"Routines\" in the settings.';

  @override
  String get assistantSetupStep2Tip =>
      'May also appear as \"Shortcuts\" on some devices.';

  @override
  String get assistantSetupStep3Title => 'Create New Routine';

  @override
  String get assistantSetupStep3Desc =>
      'Tap the \"+\" or \"New routine\" button.';

  @override
  String get assistantSetupStep3Tip => 'Usually in the bottom right corner.';

  @override
  String get assistantSetupStep4Title => 'Add Voice Command';

  @override
  String get assistantSetupStep4Desc =>
      'Tap \"When I say\" and add a voice command.\n\nType \"add expense\".';

  @override
  String get assistantSetupStep4Tip =>
      'You can also use \"log expense\" or \"record spending\".';

  @override
  String get assistantSetupStep5Title => 'Add Action';

  @override
  String get assistantSetupStep5Desc =>
      '\"Add action\" → \"Open app\" → Select \"Vantag\".';

  @override
  String get assistantSetupStep5Tip =>
      'Search for Vantag if not visible in the list.';

  @override
  String get assistantSetupStep6Title => 'Save';

  @override
  String get assistantSetupStep6Desc => 'Tap \"Save\" in the top right corner.';

  @override
  String get assistantSetupStep6Tip => 'You may be asked to name the routine.';

  @override
  String get step => 'Step';

  @override
  String get next => 'Next';

  @override
  String get back => 'Back';

  @override
  String get laterButton => 'I\'ll do it later';

  @override
  String get monthlySpendingBreakdown => 'Monthly Spending Breakdown';

  @override
  String get mandatoryExpenses => 'Mandatory';

  @override
  String get discretionaryExpenses => 'Discretionary';

  @override
  String remainingHoursToSpend(String hours) {
    return '$hours hours left to spend';
  }

  @override
  String budgetExceeded(String amount) {
    return 'You exceeded your budget by $amount!';
  }

  @override
  String get activeInstallments => 'Active Installments';

  @override
  String installmentCount(int count) {
    return '$count installments';
  }

  @override
  String moreInstallments(int count) {
    return '+$count more installments';
  }

  @override
  String get monthlyBurden => 'Monthly Burden';

  @override
  String get remainingDebt => 'Remaining Debt';

  @override
  String totalInterestCost(String amount, String hours) {
    return 'Total interest: $amount ($hours hours)';
  }

  @override
  String get monthAbbreviation => 'mo';

  @override
  String get installmentsLabel => 'installments';

  @override
  String get remaining => 'Remaining';

  @override
  String get paywallTitle => 'Upgrade to Premium';

  @override
  String get paywallSubtitle =>
      'Unlock all features and achieve your financial freedom';

  @override
  String get subscribeToPro => 'Subscribe to Pro';

  @override
  String get startFreeTrial => 'Start 7-Day Free Trial';

  @override
  String get freeTrialBanner => '7 DAYS FREE';

  @override
  String get freeTrialDescription =>
      'First 7 days completely free, cancel anytime';

  @override
  String trialThenPrice(String price) {
    return 'Then $price/month after trial';
  }

  @override
  String get noPaymentNow => 'No payment required now';

  @override
  String get restorePurchases => 'Restore purchases';

  @override
  String get feature => 'Feature';

  @override
  String get featureAiChat => 'AI Chat';

  @override
  String get featureAiChatFree => '4/day';

  @override
  String get featureHistory => 'History';

  @override
  String get featureHistory30Days => '30 days';

  @override
  String get featureExport => 'Excel Export';

  @override
  String get featureWidgets => 'Widgets';

  @override
  String get featureAds => 'Ads';

  @override
  String get featureUnlimited => 'Unlimited';

  @override
  String get featureYes => 'Yes';

  @override
  String get featureNo => 'No';

  @override
  String get weekly => 'Weekly';

  @override
  String get week => 'week';

  @override
  String get year => 'year';

  @override
  String get bestValue => 'Best Value';

  @override
  String get yearlySavings => 'Save up to 50%';

  @override
  String get cancelAnytime => 'Cancel anytime';

  @override
  String get aiLimitReached => 'Daily AI limit reached';

  @override
  String aiLimitMessage(int used, int limit) {
    return 'You\'ve used $used/$limit AI chats today. Upgrade to Pro for unlimited access.';
  }

  @override
  String get historyLimitReached => 'History limit reached';

  @override
  String get historyLimitMessage =>
      'Free plan only shows last 30 days. Upgrade to Pro for full history access.';

  @override
  String get exportProOnly => 'Excel export is a Pro feature';

  @override
  String remainingAiUses(int count) {
    return '$count AI uses left';
  }

  @override
  String get lifetime => 'Lifetime';

  @override
  String get lifetimeDescription =>
      'Pay once, use forever • 100 AI credits/month';

  @override
  String get oneTime => 'one-time';

  @override
  String get forever => 'FOREVER';

  @override
  String get mostPopular => 'MOST POPULAR';

  @override
  String monthlyCredits(int count) {
    return '$count AI credits/month';
  }

  @override
  String proMonthlyCredits(int remaining, int limit) {
    return '$remaining/$limit monthly credits';
  }

  @override
  String get aiLimitFreeTitleEmoji => '🔒 Daily AI Limit Reached!';

  @override
  String get aiLimitProTitleEmoji => '⏳ Monthly AI Limit Reached!';

  @override
  String get aiLimitFreeMessage => 'You\'ve used all 4 AI questions for today.';

  @override
  String get aiLimitProMessage =>
      'You\'ve used all 500 AI questions this month.';

  @override
  String get aiLimitLifetimeMessage =>
      'You\'ve used all 200 AI credits this month.';

  @override
  String aiLimitResetDate(String day, String month, int days) {
    return 'Limit resets on $month $day ($days days left)';
  }

  @override
  String get aiLimitUpgradeToPro => '🚀 Upgrade to Pro - Unlimited AI';

  @override
  String get aiLimitBuyCredits => '🔋 Buy Extra Credit Pack';

  @override
  String get aiLimitTryTomorrow => 'or try again tomorrow';

  @override
  String aiLimitOrWaitDays(int days) {
    return 'or wait $days days for reset';
  }

  @override
  String get creditPurchaseTitle => 'Buy Credits';

  @override
  String get creditPurchaseHeader => 'Top Up AI Credits';

  @override
  String get creditPurchaseSubtitle =>
      'Purchase extra credits for AI queries beyond your monthly limit.';

  @override
  String get creditCurrentBalance => 'Current Balance';

  @override
  String creditAmount(int credits) {
    return '$credits Credits';
  }

  @override
  String creditPackTitle(int credits) {
    return '$credits Credits';
  }

  @override
  String creditPackPricePerCredit(String price) {
    return '₺$price per credit';
  }

  @override
  String get creditPackPopular => 'MOST POPULAR';

  @override
  String get creditPackBestValue => 'BEST VALUE';

  @override
  String get creditNeverExpire => 'Credits never expire, use them anytime';

  @override
  String creditPurchaseSuccess(int credits) {
    return '$credits credits added to your account!';
  }

  @override
  String get pursuits => 'My Dreams';

  @override
  String get myPursuits => 'My Dreams';

  @override
  String get navPursuits => 'Dreams';

  @override
  String get createPursuit => 'New Dream';

  @override
  String get pursuitName => 'What are you saving for?';

  @override
  String get pursuitNameHint => 'e.g: iPhone 16, Maldives Vacation...';

  @override
  String get targetAmount => 'Target Amount';

  @override
  String get savedAmount => 'Saved';

  @override
  String get addSavings => 'Add Money';

  @override
  String pursuitProgress(int percent) {
    return '$percent% complete';
  }

  @override
  String daysToGoal(int days) {
    return '≈ $days work days';
  }

  @override
  String get pursuitCompleted => 'Your Dream Came True!';

  @override
  String get congratulations => 'Congratulations!';

  @override
  String pursuitCompletedMessage(int days, String amount) {
    return 'You saved $amount in $days days!';
  }

  @override
  String get shareProgress => 'Share Progress';

  @override
  String get activePursuits => 'Active';

  @override
  String get completedPursuits => 'Completed';

  @override
  String get archivePursuit => 'Archive';

  @override
  String get deletePursuit => 'Delete';

  @override
  String get editPursuit => 'Edit';

  @override
  String get deletePursuitConfirm =>
      'Are you sure you want to delete this dream?';

  @override
  String get pursuitCategoryTech => 'Tech';

  @override
  String get pursuitCategoryTravel => 'Travel';

  @override
  String get pursuitCategoryHome => 'Home';

  @override
  String get pursuitCategoryFashion => 'Fashion';

  @override
  String get pursuitCategoryVehicle => 'Vehicle';

  @override
  String get pursuitCategoryEducation => 'Education';

  @override
  String get pursuitCategoryHealth => 'Health';

  @override
  String get pursuitCategoryOther => 'Other';

  @override
  String get emptyPursuitsTitle => 'Take a Step Toward Your Dream';

  @override
  String get emptyPursuitsMessage => 'Add your first dream and start saving!';

  @override
  String get addFirstPursuit => 'Add Your First Dream';

  @override
  String get pursuitLimitReached => 'Upgrade to Pro for unlimited dreams';

  @override
  String get quickAmounts => 'Quick Amounts';

  @override
  String get addNote => 'Add note (optional)';

  @override
  String get pursuitCreated => 'Dream created!';

  @override
  String get savingsAdded => 'Added!';

  @override
  String workHoursRemaining(String hours) {
    return '$hours work hours remaining';
  }

  @override
  String get pursuitInitialSavings => 'Initial Savings';

  @override
  String get pursuitInitialSavingsHint => 'Amount you\'ve already saved';

  @override
  String get pursuitSelectCategory => 'Select Category';

  @override
  String get redirectSavings => 'Redirect Savings to Dream';

  @override
  String redirectSavingsMessage(String amount) {
    return 'Which dream would you like to add the $amount you saved?';
  }

  @override
  String get skipRedirect => 'Skip for Now';

  @override
  String get pursuitTransactionHistory => 'Transaction History';

  @override
  String get noTransactions => 'No transactions yet';

  @override
  String get transactionSourceManual => 'Manual Entry';

  @override
  String get transactionSourcePool => 'Pool Transfer';

  @override
  String get transactionSourceExpense => 'Cancelled Expense';

  @override
  String get savingsPool => 'Savings Pool';

  @override
  String get savingsPoolAvailable => 'available';

  @override
  String get savingsPoolDebt => 'You owe';

  @override
  String shadowDebtMessage(String amount) {
    return 'You borrowed $amount from your future self';
  }

  @override
  String budgetShiftQuestion(String amount) {
    return 'Where did this $amount come from?';
  }

  @override
  String get jokerUsed => 'You used this month\'s joker';

  @override
  String get jokerAvailable => 'You have a joker available!';

  @override
  String allocatedToDreams(String amount) {
    return '$amount allocated to dreams';
  }

  @override
  String get extraIncome => 'I earned extra income';

  @override
  String get useJoker => 'Use Joker (1/month)';

  @override
  String get budgetShiftFromFood => 'From my food budget';

  @override
  String get budgetShiftFromEntertainment => 'From my entertainment budget';

  @override
  String get budgetShiftFromClothing => 'From my clothing budget';

  @override
  String get budgetShiftFromTransport => 'From my transport budget';

  @override
  String get budgetShiftFromShopping => 'From my shopping budget';

  @override
  String get budgetShiftFromHealth => 'From my health budget';

  @override
  String get budgetShiftFromEducation => 'From my education budget';

  @override
  String get insufficientFunds => 'Insufficient funds';

  @override
  String insufficientFundsMessage(String available, String requested) {
    return 'Pool has $available, you want $requested';
  }

  @override
  String get createShadowDebt => 'Add anyway (create debt)';

  @override
  String debtRepaidMessage(String amount) {
    return '$amount paid towards your debt!';
  }

  @override
  String get poolSummaryTotal => 'Total Savings';

  @override
  String get poolSummaryAllocated => 'Allocated to Dreams';

  @override
  String get poolSummaryAvailable => 'Available';

  @override
  String get overAllocationTitle => 'Insufficient Pool Balance';

  @override
  String overAllocationMessage(String available, String requested) {
    return 'Pool has $available. You want to add $requested.';
  }

  @override
  String get fromMyPocket => 'Add from my pocket';

  @override
  String fromMyPocketDesc(String difference) {
    return 'Zero out pool + add $difference from pocket';
  }

  @override
  String get deductFromFuture => 'Deduct from future savings';

  @override
  String deductFromFutureDesc(String amount) {
    return 'Pool will go negative by $amount';
  }

  @override
  String transferAvailableOnly(String amount) {
    return 'Transfer only $amount';
  }

  @override
  String get transferAvailableOnlyDesc =>
      'Add only what\'s available in the pool';

  @override
  String get oneTimeIncomeTitle => 'Where is this money from?';

  @override
  String get oneTimeIncomeDesc => 'Your pool is in debt. Choose the source:';

  @override
  String get oneTimeIncomeOption => 'One-time income';

  @override
  String get oneTimeIncomeOptionDesc =>
      'Doesn\'t affect the pool, goes directly to goal';

  @override
  String get fromSavingsOption => 'From my savings';

  @override
  String get fromSavingsOptionDesc => 'Pool will go further negative';

  @override
  String debtWarningOnPurchase(String amount) {
    return 'You owe $amount to your dreams!';
  }

  @override
  String get debtReminderNotification =>
      'Don\'t forget to pay off your debt to your dreams!';

  @override
  String get aiThinking => 'Thinking...';

  @override
  String get aiSuggestion1 => 'Where did I spend this month?';

  @override
  String get aiSuggestion2 => 'Where can I save money?';

  @override
  String get aiSuggestion3 => 'What\'s my most expensive habit?';

  @override
  String get aiSuggestion4 => 'How far am I from my goal?';

  @override
  String get aiPremiumUpsell =>
      'Get detailed analysis and personal savings plan with Premium';

  @override
  String get aiPremiumButton => 'Go Premium';

  @override
  String get aiInputPlaceholderFree => 'Ask your own question 🔒';

  @override
  String get aiInputPlaceholder => 'Ask something...';

  @override
  String get onboardingTryTitle => 'Let\'s Try!';

  @override
  String get onboardingTrySubtitle =>
      'Curious how long you\'d work for something?';

  @override
  String get onboardingTryButton => 'Calculate';

  @override
  String get onboardingTryDisclaimer =>
      'This was just to show how abstract money is and how concrete time is.';

  @override
  String get onboardingTryNotSaved =>
      'Don\'t worry, this wasn\'t saved to your expenses.';

  @override
  String get onboardingContinue => 'Continue to App';

  @override
  String onboardingTryResult(String hours) {
    return 'This expense takes $hours hours from your life';
  }

  @override
  String get subscriptionPriceHint => '\$9.99';

  @override
  String currencyUpdatePopup(
    String oldAmount,
    String oldCurrency,
    String newAmount,
    String newCurrency,
  ) {
    return 'Currency updating: $oldAmount $oldCurrency ≈ $newAmount $newCurrency';
  }

  @override
  String get currencyConverting => 'Converting currency...';

  @override
  String get currencyConversionFailed =>
      'Could not fetch exchange rate, values unchanged';

  @override
  String get requiredExpense => 'Required Expense';

  @override
  String get installmentPurchase => 'Installment Purchase';

  @override
  String get installmentInfo => 'Installment Information';

  @override
  String get cashPrice => 'Cash Price';

  @override
  String get cashPriceHint => 'Original cash price';

  @override
  String get numberOfInstallments => 'Number of Installments';

  @override
  String get totalInstallmentPrice => 'Total Installment Price';

  @override
  String get totalWithInterestHint => 'Total with interest';

  @override
  String get installmentSummary => 'INSTALLMENT SUMMARY';

  @override
  String get willBeSavedAsRequired => 'Will be saved as required expense';

  @override
  String get creditCardOrStoreInstallment => 'Credit card or store installment';

  @override
  String get vantagAI => 'Vantag AI';

  @override
  String get professionalMode => 'Professional mode';

  @override
  String get friendlyMode => 'Friendly mode';

  @override
  String get errorTryAgain => 'An error occurred, try again?';

  @override
  String get aiInsights => 'AI Insights';

  @override
  String get mostSpendingDay => 'Busiest Spending Day';

  @override
  String get biggestCategory => 'Biggest Category';

  @override
  String get thisMonthVsLast => 'This Month vs Last Month';

  @override
  String get monday => 'Monday';

  @override
  String get tuesday => 'Tuesday';

  @override
  String get wednesday => 'Wednesday';

  @override
  String get thursday => 'Thursday';

  @override
  String get friday => 'Friday';

  @override
  String get saturday => 'Saturday';

  @override
  String get sunday => 'Sunday';

  @override
  String get securePayment => 'Secure Payment';

  @override
  String get encrypted => 'Encrypted';

  @override
  String get syncing => 'Syncing data...';

  @override
  String pendingSync(int count) {
    return '$count changes pending sync';
  }

  @override
  String get pendingLabel => 'Pending';

  @override
  String insightMinutes(int minutes) {
    return 'This expense took $minutes minutes of your life.';
  }

  @override
  String insightHours(String hours) {
    return 'This expense took $hours hours of your life.';
  }

  @override
  String get insightAlmostDay =>
      'You worked almost a full day for this expense.';

  @override
  String insightDays(String days) {
    return 'This expense took $days days of your life.';
  }

  @override
  String insightDaysWorked(String days) {
    return 'You had to work $days days for this expense.';
  }

  @override
  String get insightAlmostMonth =>
      'This expense cost you almost a month of work.';

  @override
  String insightCategoryDays(String category, String days) {
    return 'This month you worked $days days for $category.';
  }

  @override
  String insightCategoryHours(String category, String hours) {
    return 'This month you worked $hours hours for $category.';
  }

  @override
  String get insightMonthlyAlmost =>
      'You worked almost the entire month for this month\'s expenses.';

  @override
  String insightMonthlyDays(String days) {
    return 'You worked $days days for this month\'s expenses.';
  }

  @override
  String get msgShort1 => 'A few hours of work, for a fleeting desire?';

  @override
  String get msgShort2 =>
      'Easy to spend what you earned in such short time, hard to earn it back.';

  @override
  String get msgShort3 =>
      'You went to work this morning, this money will be gone before lunch.';

  @override
  String get msgShort4 =>
      'You earned it in a coffee break, it\'ll be gone with one click.';

  @override
  String get msgShort5 =>
      'Half a day\'s work, don\'t let it become a full day of regret.';

  @override
  String get msgShort6 => 'Think about the hours you worked for this item.';

  @override
  String get msgShort7 => 'Looks small but makes a big difference in total.';

  @override
  String get msgShort8 => 'If not now, tomorrow works too.';

  @override
  String get msgMedium1 => 'Is your week\'s work worth this item?';

  @override
  String get msgMedium2 =>
      'It took days to save this money, seconds to spend it.';

  @override
  String get msgMedium3 =>
      'Would you accept if you were investing a week into this?';

  @override
  String get msgMedium4 => 'Days of effort, a split-second decision.';

  @override
  String get msgMedium5 => 'A weekend getaway or this item?';

  @override
  String get msgMedium6 => 'Remember what you worked for all those days.';

  @override
  String get msgMedium7 => 'Did you work Monday to Friday for this?';

  @override
  String get msgMedium8 =>
      'Does it make sense to spend your weekly budget in one go?';

  @override
  String get msgLong1 =>
      'You need to work for weeks for this. Is it really worth it?';

  @override
  String get msgLong2 => 'Saving this money could take months.';

  @override
  String get msgLong3 => 'You might be delaying one of your long-term goals.';

  @override
  String get msgLong4 =>
      'Does the time you\'ll spend on this affect your vacation plans?';

  @override
  String get msgLong5 => 'Is this an investment or an expense?';

  @override
  String get msgLong6 => 'How would future you evaluate this decision?';

  @override
  String get msgLong7 => 'Working this long should be for something lasting.';

  @override
  String get msgLong8 => 'How will you view this decision at month\'s end?';

  @override
  String get msgSim1 =>
      'This amount isn\'t just spending anymore, it\'s a serious investment decision.';

  @override
  String get msgSim2 =>
      'For such a large sum, decide with your vision, not your emotions.';

  @override
  String get msgSim3 =>
      'It\'s hard to even calculate the time equivalent of this amount.';

  @override
  String get msgSim4 => 'Could this be that big step you\'ve been dreaming of?';

  @override
  String get msgSim5 =>
      'Managing such a large amount requires patience and strategy.';

  @override
  String get msgSim6 =>
      'You\'re at a point that will affect your future, not just your wallet.';

  @override
  String get msgSim7 =>
      'Big numbers bring big responsibilities. Are you ready?';

  @override
  String get msgSim8 =>
      'Is this amount just a number to you, or a turning point?';

  @override
  String get msgYes1 => 'Recorded. Hope it\'s worth it.';

  @override
  String get msgYes2 => 'Let\'s see if you\'ll regret it.';

  @override
  String get msgYes3 => 'Okay, it\'s your money.';

  @override
  String get msgYes4 => 'You bought it, congratulations.';

  @override
  String get msgYes5 => 'As you wish.';

  @override
  String get msgYes6 => 'Alright, it\'s on the record.';

  @override
  String get msgYes7 => 'If it\'s a need, no problem.';

  @override
  String get msgYes8 => 'Sometimes spending is necessary too.';

  @override
  String get msgNo1 => 'Great decision. You saved this money.';

  @override
  String get msgNo2 =>
      'You chose the hard path, your future self will thank you.';

  @override
  String get msgNo3 => 'Willpower won.';

  @override
  String get msgNo4 => 'Smart move. You\'ll need this money.';

  @override
  String get msgNo5 => 'Passing is also a win.';

  @override
  String get msgNo6 => 'The urge passed, the money stayed.';

  @override
  String get msgNo7 => 'You actually invested in yourself.';

  @override
  String get msgNo8 => 'Hard decision, right decision.';

  @override
  String get msgThink1 => 'Thinking is free, spending isn\'t.';

  @override
  String get msgThink2 => 'Not rushing is smart.';

  @override
  String get msgThink3 => 'Sleep on it, look again tomorrow.';

  @override
  String get msgThink4 => 'Wait 24 hours, come back if you still want it.';

  @override
  String get msgThink5 =>
      'If you\'re hesitating, it\'s probably not necessary.';

  @override
  String get msgThink6 => 'Time is the best advisor.';

  @override
  String get msgThink7 => 'If it\'s not urgent, don\'t rush.';

  @override
  String get msgThink8 => 'If you\'re not sure, the answer is probably no.';

  @override
  String get savingMsg1 => 'Great decision! 💪';

  @override
  String get savingMsg2 => 'You protected your money! 🛡️';

  @override
  String get savingMsg3 => 'Future you will thank you!';

  @override
  String get savingMsg4 => 'Smart choice! 🧠';

  @override
  String get savingMsg5 => 'Saving is power!';

  @override
  String get savingMsg6 => 'One step closer to your goal!';

  @override
  String get savingMsg7 => 'Willpower! 💎';

  @override
  String get savingMsg8 => 'This money is now yours!';

  @override
  String get savingMsg9 => 'Financial discipline! 🎯';

  @override
  String get savingMsg10 => 'You\'re building wealth!';

  @override
  String get savingMsg11 => 'Strong decision! 💪';

  @override
  String get savingMsg12 => 'Your wallet thanks you!';

  @override
  String get savingMsg13 => 'That\'s how champions save! 🏆';

  @override
  String get savingMsg14 => 'Money saved = Freedom earned!';

  @override
  String get savingMsg15 => 'Impressive self-control! ⭐';

  @override
  String get spendingMsg1 => 'Recorded! ✓';

  @override
  String get spendingMsg2 => 'You\'re tracking, that\'s important.';

  @override
  String get spendingMsg3 => 'Every record is awareness.';

  @override
  String get spendingMsg4 => 'Knowing your spending is power.';

  @override
  String get spendingMsg5 => 'Logged! Keep going.';

  @override
  String get spendingMsg6 => 'Tracking builds control.';

  @override
  String get spendingMsg7 => 'Noted! Awareness is key.';

  @override
  String get spendingMsg8 => 'Good job tracking!';

  @override
  String get spendingMsg9 => 'Data is power! 📊';

  @override
  String get spendingMsg10 => 'Stay aware, stay in control.';

  @override
  String get tourAmountTitle => 'Amount Entry';

  @override
  String get tourAmountDesc =>
      'Enter the expense amount here. You can automatically scan it from a receipt using the scan button.';

  @override
  String get tourDescriptionTitle => 'Smart Matching';

  @override
  String get tourDescriptionDesc =>
      'Enter the store or product name. Like Migros, A101, Starbucks... The app will automatically suggest a category!';

  @override
  String get tourCategoryTitle => 'Category Selection';

  @override
  String get tourCategoryDesc =>
      'If smart matching doesn\'t find it or you want to change it, you can manually select from here.';

  @override
  String get tourDateTitle => 'Past Date Selection';

  @override
  String get tourDateDesc =>
      'You can also enter expenses from yesterday or previous days. Click the calendar icon to select any date.';

  @override
  String get tourSnapshotTitle => 'Financial Summary';

  @override
  String get tourSnapshotDesc =>
      'Your monthly income, expenses, and saved money are here. All data updates in real-time.';

  @override
  String get tourCurrencyTitle => 'Exchange Rates';

  @override
  String get tourCurrencyDesc =>
      'Current USD, EUR, and gold prices. Tap for detailed information.';

  @override
  String get tourStreakTitle => 'Streak Tracking';

  @override
  String get tourStreakDesc =>
      'Your streak increases every day you record an expense. Regular tracking is the key to mindful spending!';

  @override
  String get tourSubscriptionTitle => 'Subscriptions';

  @override
  String get tourSubscriptionDesc =>
      'Track your regular subscriptions like Netflix, Spotify here. You\'ll get notifications for upcoming payments.';

  @override
  String get tourReportTitle => 'Reports';

  @override
  String get tourReportDesc =>
      'View monthly and category-based spending analysis here.';

  @override
  String get tourAchievementsTitle => 'Badges';

  @override
  String get tourAchievementsDesc =>
      'Earn badges as you reach savings goals. Keep your motivation high!';

  @override
  String get tourProfileTitle => 'Profile & Settings';

  @override
  String get tourProfileDesc =>
      'Edit income info, manage notification preferences, and access app settings.';

  @override
  String get tourQuickAddTitle => 'Quick Add';

  @override
  String get tourQuickAddDesc =>
      'Use this button to quickly add expenses from anywhere. Practical and fast!';

  @override
  String get notifChannelName => 'Vantag Notifications';

  @override
  String get notifChannelDescription => 'Financial tracking notifications';

  @override
  String get notifTitleThinkAboutIt => 'Think about it';

  @override
  String get notifTitleCongratulations => 'Congratulations';

  @override
  String get notifTitleStreakWaiting => 'Your streak is waiting';

  @override
  String get notifTitleWeeklySummary => 'Weekly summary';

  @override
  String get notifTitleSubscriptionReminder => 'Subscription reminder';

  @override
  String get aiGreeting =>
      'Hello! I\'m Vantag.\nReady to answer your financial questions.';

  @override
  String get onboardingHookTitle => 'This coffee is 47 minutes';

  @override
  String get onboardingHookSubtitle => 'See the real cost of every purchase';

  @override
  String get pursuitOnboardingTitle => 'What\'s your goal?';

  @override
  String get pursuitOnboardingSubtitle => 'Pick something to save for';

  @override
  String get pursuitOnboardingAirpods => 'AirPods';

  @override
  String get pursuitOnboardingIphone => 'iPhone';

  @override
  String get pursuitOnboardingVacation => 'Vacation';

  @override
  String get pursuitOnboardingCustom => 'My own goal';

  @override
  String get pursuitOnboardingCta => 'I want this';

  @override
  String get pursuitOnboardingSkip => 'Skip for now';

  @override
  String pursuitOnboardingHours(int hours) {
    return '$hours hours';
  }

  @override
  String get celebrationTitle => 'Congratulations!';

  @override
  String celebrationSubtitle(String goalName) {
    return 'You reached your $goalName goal!';
  }

  @override
  String celebrationTotalSaved(String hours) {
    return 'Total saved: $hours hours';
  }

  @override
  String celebrationDuration(int days) {
    return 'Duration: $days days';
  }

  @override
  String get celebrationShare => 'Share';

  @override
  String get celebrationNewGoal => 'New Goal';

  @override
  String get celebrationDismiss => 'Close';

  @override
  String get widgetTodayLabel => 'Today';

  @override
  String get widgetHoursAbbrev => 'h';

  @override
  String get widgetMinutesAbbrev => 'm';

  @override
  String get widgetSetGoal => 'Set a goal';

  @override
  String get widgetNoData => 'Open app to start';

  @override
  String get widgetSmallTitle => 'Daily Spending';

  @override
  String get widgetSmallDesc => 'See today\'s spending in hours';

  @override
  String get widgetMediumTitle => 'Spending + Goal';

  @override
  String get widgetMediumDesc => 'Track spending and goal progress';

  @override
  String accessibilityTodaySpending(String amount, int hours, int minutes) {
    return 'Today you spent $amount, equal to $hours hours $minutes minutes of work';
  }

  @override
  String accessibilitySpendingProgress(int percentage) {
    return 'Spending progress: $percentage percent of budget used';
  }

  @override
  String accessibilityExpenseItem(
    String category,
    String amount,
    String hours,
    String decision,
  ) {
    return '$category expense of $amount, took $hours hours, status: $decision';
  }

  @override
  String accessibilityPursuitCard(
    String name,
    String saved,
    String target,
    int percentage,
  ) {
    return '$name goal, $saved of $target saved, $percentage percent complete';
  }

  @override
  String get accessibilityAddExpense => 'Add new expense';

  @override
  String get accessibilityDecisionYes => 'Purchased';

  @override
  String get accessibilityDecisionNo => 'Passed';

  @override
  String get accessibilityDecisionThinking => 'Thinking';

  @override
  String get accessibilityDashboard =>
      'Financial dashboard showing income, expenses and balance';

  @override
  String accessibilityNetBalance(String amount, String status) {
    return 'Net balance: $amount, $status';
  }

  @override
  String get accessibilityBalanceHealthy => 'in the green';

  @override
  String get accessibilityBalanceNegative => 'in the red';

  @override
  String accessibilityIncomeTotal(String amount) {
    return 'Total income: $amount';
  }

  @override
  String accessibilityExpenseTotal(String amount) {
    return 'Total expenses: $amount';
  }

  @override
  String get accessibilityAddSavings => 'Add savings to this goal';

  @override
  String get accessibilityDeleteExpense => 'Delete this expense';

  @override
  String get accessibilityEditExpense => 'Edit this expense';

  @override
  String get accessibilityShareExpense => 'Share this expense';

  @override
  String accessibilityStreakInfo(int days, int best) {
    return 'Current streak: $days days, best streak: $best days';
  }

  @override
  String get accessibilityAiChatInput => 'Type your financial question here';

  @override
  String get accessibilityAiSendButton => 'Send message to AI assistant';

  @override
  String accessibilitySuggestionButton(String question) {
    return 'Quick question: $question';
  }

  @override
  String accessibilitySubscriptionCard(
    String name,
    String amount,
    String cycle,
    int day,
  ) {
    return '$name subscription, $amount per $cycle, renews on day $day';
  }

  @override
  String accessibilitySettingsItem(String title, String value) {
    return '$title, current value: $value';
  }

  @override
  String get accessibilityToggleOn => 'Enabled';

  @override
  String get accessibilityToggleOff => 'Disabled';

  @override
  String get accessibilityCloseSheet => 'Close this sheet';

  @override
  String get accessibilityBackButton => 'Go back';

  @override
  String get accessibilityProfileButton => 'Open profile menu';

  @override
  String get accessibilityNotificationsButton => 'View notifications';

  @override
  String get navHomeTooltip => 'Home, spending overview';

  @override
  String get navPursuitsTooltip => 'Goals, savings targets';

  @override
  String get navReportsTooltip => 'Reports, spending analysis';

  @override
  String get navSettingsTooltip => 'Settings and preferences';

  @override
  String shareDefaultMessage(String link) {
    return 'I track my expenses in hours! Try it: $link';
  }

  @override
  String get shareInviteLink => 'Share Invite Link';

  @override
  String get inviteFriends => 'Invite Friends';

  @override
  String get yourReferralCode => 'Your referral code';

  @override
  String referralStats(int count) {
    return '$count friends joined';
  }

  @override
  String get referralRewardInfo => 'Earn 7 days premium for each friend!';

  @override
  String get codeCopied => 'Code copied!';

  @override
  String get haveReferralCode => 'Have a referral code?';

  @override
  String get referralCodeHint => 'Enter code (optional)';

  @override
  String get referralCodePlaceholder => 'VANTAG-XXXXX';

  @override
  String referralSuccess(String name) {
    return '$name joined Vantag! +7 days premium';
  }

  @override
  String get welcomeReferred => 'Welcome! You have 7 days premium trial';

  @override
  String get referralInvalidCode => 'Invalid referral code';

  @override
  String get referralCodeApplied => 'Referral code applied!';

  @override
  String get referralSectionTitle => 'Referrals';

  @override
  String get referralShareDescription =>
      'Share your code and earn premium days';

  @override
  String get trialMidpointTitle => 'Halfway there! ⏳';

  @override
  String trialMidpointBody(String hours) {
    return 'Your trial is halfway done. You\'ve saved $hours hours so far!';
  }

  @override
  String get trialOneDayLeftTitle => 'Trial ends tomorrow ⏰';

  @override
  String get trialOneDayLeftBody => 'Go premium to keep tracking your savings!';

  @override
  String get trialEndsTodayTitle => 'Last day of trial! 🎁';

  @override
  String get trialEndsTodayBody => 'Get 50% off if you upgrade today!';

  @override
  String get trialExpiredTitle => 'We miss you! 💜';

  @override
  String get trialExpiredBody => 'Come back and continue reaching your goals';

  @override
  String get dailyReminderTitle => 'Don\'t forget to log! 📝';

  @override
  String get dailyReminderBody => 'Track today\'s spending in just seconds';

  @override
  String get notificationSettingsDesc => 'Reminders and updates';

  @override
  String get firstExpenseTitle => 'Great start! 🎉';

  @override
  String firstExpenseBody(String hours) {
    return 'You saved $hours hours today!';
  }

  @override
  String get trialReminderEnabled => 'Trial reminders';

  @override
  String get trialReminderDesc => 'Get notified before your trial ends';

  @override
  String get dailyReminderEnabled => 'Daily reminders';

  @override
  String get dailyReminderDesc => 'Evening reminder to log expenses';

  @override
  String get dailyReminderTime => 'Reminder time';

  @override
  String trialDaysRemaining(int days) {
    return '$days days left in trial';
  }

  @override
  String get subscriptionReminder => 'Subscription reminders';

  @override
  String get subscriptionReminderDesc =>
      'Get notified before subscriptions renew';

  @override
  String get thinkingReminder => '\"Thinking\" reminders';

  @override
  String get thinkingReminderDesc =>
      'Get reminded after 72 hours about items you\'re still thinking about';

  @override
  String get thinkingReminderTitle => 'Still thinking?';

  @override
  String thinkingReminderBody(String item) {
    return 'Did you decide? $item';
  }

  @override
  String get willRemindIn72h => 'We\'ll remind you in 72 hours';

  @override
  String get thinkingAbout => 'Thinking about';

  @override
  String addedDaysAgo(int days) {
    return 'Added $days days ago';
  }

  @override
  String get stillThinking => 'Still thinking?';

  @override
  String get stillThinkingMessage => 'It\'s been 72 hours. Did you decide?';

  @override
  String get decidedYes => 'I bought it';

  @override
  String get decidedNo => 'I passed';

  @override
  String get aiChatLimitReached =>
      'You\'ve used your 4 daily AI chats. Go premium for unlimited!';

  @override
  String aiChatsRemaining(int count) {
    return '$count chats left today';
  }

  @override
  String get pursuitLimitReachedFree =>
      'Free accounts can have 1 active goal. Go premium for unlimited goals!';

  @override
  String get pursuitNameRequired => 'Please enter a name';

  @override
  String get pursuitAmountRequired => 'Please enter an amount';

  @override
  String get pursuitAmountInvalid => 'Please enter a valid amount';

  @override
  String get exportPremiumOnly => 'Export is a premium feature';

  @override
  String get multiCurrencyPremium =>
      'Multiple currencies is a premium feature. Free users can only use TRY.';

  @override
  String get reportsPremiumOnly =>
      'Monthly and yearly reports are premium features';

  @override
  String get upgradeToPremium => 'Upgrade to Premium';

  @override
  String get premiumIncludes => 'Premium includes:';

  @override
  String get unlimitedAiChat => 'Unlimited AI chat';

  @override
  String get unlimitedPursuits => 'Unlimited goals';

  @override
  String get exportFeature => 'Export your data';

  @override
  String get allCurrencies => 'All currencies';

  @override
  String get fullReports => 'Full reports';

  @override
  String get cleanShareCards => 'Clean share cards (no watermark)';

  @override
  String get maybeLater => 'Maybe later';

  @override
  String get seePremium => 'See Premium';

  @override
  String get weeklyOnly => 'Weekly';

  @override
  String get monthlyPro => 'Monthly (Pro)';

  @override
  String get yearlyPro => 'Yearly (Pro)';

  @override
  String get currencyLocked => 'Premium only';

  @override
  String freeUserCurrencyNote(String currency) {
    return 'Free users can only use TRY. Upgrade to use $currency.';
  }

  @override
  String get watermarkText => 'vantag.app';

  @override
  String get incomeTypeSalary => 'Salary';

  @override
  String get incomeTypeBonus => 'Bonus';

  @override
  String get incomeTypeGift => 'Gift';

  @override
  String get incomeTypeRefund => 'Refund';

  @override
  String get incomeTypeFreelance => 'Freelance';

  @override
  String get incomeTypeRental => 'Rental';

  @override
  String get incomeTypeInvestment => 'Investment';

  @override
  String get incomeTypeOther => 'Other Income';

  @override
  String get salaryDay => 'Salary Day';

  @override
  String get salaryDayTitle => 'When do you get paid?';

  @override
  String get salaryDaySubtitle => 'We\'ll remind you on payday';

  @override
  String get salaryDayHint => 'Select day of month (1-31)';

  @override
  String salaryDaySet(int day) {
    return 'Salary day set to $day';
  }

  @override
  String get salaryDaySkip => 'Skip for now';

  @override
  String get salaryDayNotSet => 'Not set';

  @override
  String get currentBalance => 'Current Balance';

  @override
  String get balanceTitle => 'What\'s your current balance?';

  @override
  String get balanceSubtitle => 'Track your spending more accurately';

  @override
  String get balanceHint => 'Enter your bank balance';

  @override
  String get balanceUpdated => 'Balance updated';

  @override
  String get balanceOptional => 'Optional - you can add this later';

  @override
  String get paydayTitle => 'Payday!';

  @override
  String get paydayMessage => 'Did you receive your salary?';

  @override
  String get paydayConfirm => 'Yes, received!';

  @override
  String get paydayNotYet => 'Not yet';

  @override
  String get paydaySkip => 'Skip';

  @override
  String get paydayCelebration => 'Congratulations! Salary received';

  @override
  String get paydayUpdateBalance => 'Update your balance';

  @override
  String get paydayNewBalance => 'New balance after salary';

  @override
  String daysUntilPayday(int days) {
    return '$days days until payday';
  }

  @override
  String get paydayToday => 'Payday is today!';

  @override
  String get paydayTomorrow => 'Payday is tomorrow';

  @override
  String get addIncomeTitle => 'Record Income';

  @override
  String get addIncomeSubtitle => 'Bonus, gift, refund, etc.';

  @override
  String get incomeAmount => 'Amount received';

  @override
  String get incomeNotes => 'Notes (optional)';

  @override
  String get incomeNotesHint => 'e.g. Year-end bonus, birthday gift...';

  @override
  String get incomeAdded => 'Income added!';

  @override
  String incomeAddedBalance(String amount) {
    return 'Balance updated: $amount';
  }

  @override
  String get thisMonthIncome => 'This Month\'s Income';

  @override
  String get regularIncome => 'Regular Income';

  @override
  String get additionalIncome => 'Additional Income';

  @override
  String get incomeBreakdown => 'Income Breakdown';

  @override
  String get paydayNotificationTitle => 'Payday!';

  @override
  String get paydayNotificationBody =>
      'Your salary should be arriving today. Check your account!';

  @override
  String get paydayNotificationEnabled => 'Payday reminders';

  @override
  String get paydayNotificationDesc => 'Get notified on your salary day';

  @override
  String get onboardingSalaryDayTitle => 'When\'s Payday?';

  @override
  String get onboardingSalaryDayDesc =>
      'Tell us when you receive your salary so we can help you budget better';

  @override
  String get onboardingBalanceTitle => 'Starting Balance';

  @override
  String get onboardingBalanceDesc =>
      'Enter your current balance to track your finances accurately';

  @override
  String selectTimeFilter(String filter) {
    return 'Select time filter: $filter';
  }

  @override
  String lockedFilterPremium(String filter) {
    return '$filter, premium feature';
  }

  @override
  String selectedFilter(String filter) {
    return '$filter, selected';
  }

  @override
  String selectHeatmapDay(String date) {
    return 'Select day: $date';
  }

  @override
  String heatmapDayWithSpending(String date, String amount) {
    return '$date, $amount spent';
  }

  @override
  String heatmapDayNoSpending(String date) {
    return '$date, no spending';
  }

  @override
  String get loggedOutFromAnotherDevice => 'Logged In From Another Device';

  @override
  String get loggedOutFromAnotherDeviceMessage =>
      'Your account was accessed from another device. For security reasons, you have been signed out from this device.';

  @override
  String get multiCurrencyProTitle => 'Multi-Currency';

  @override
  String get multiCurrencyProDescription =>
      'Upgrade to Pro to enter income and expenses in different currencies. Use USD, EUR, GBP and more.';

  @override
  String get multiCurrencyBenefit => 'All currencies available';

  @override
  String get currencyLockedForFree => 'Currency change is a Pro feature';

  @override
  String get excelSheetExpenses => 'Expenses';

  @override
  String get excelSheetSummary => 'Summary';

  @override
  String get excelSheetCategories => 'Categories';

  @override
  String get excelSheetTimeAnalysis => 'Time Analysis';

  @override
  String get excelSheetDecisions => 'Decisions';

  @override
  String get excelSheetInstallments => 'Installments';

  @override
  String get excelHeaderDay => 'Day';

  @override
  String get excelHeaderStore => 'Store/Location';

  @override
  String get excelHeaderMinutes => 'Minutes Equiv.';

  @override
  String get excelHeaderMonthlyInstallment => 'Monthly Payment';

  @override
  String get excelHeaderInstallmentCount => 'Installment';

  @override
  String get excelHeaderSimulation => 'Simulation';

  @override
  String get excelHeaderHoursEquiv => 'Hours Equiv.';

  @override
  String get excelReportTitle => 'Vantag Financial Report';

  @override
  String get excelReportPeriod => 'Report Period';

  @override
  String get excelReportGeneratedAt => 'Generated';

  @override
  String get excelTotalExpenses => 'Total Expenses';

  @override
  String get excelTotalTransactions => 'Total Transactions';

  @override
  String get excelAvgPerTransaction => 'Average per Transaction';

  @override
  String get excelMonthlyAverage => 'Monthly Average';

  @override
  String get excelDailyAverage => 'Daily Average';

  @override
  String get excelWeeklyAverage => 'Weekly Average';

  @override
  String get excelSavingsRate => 'Savings Rate';

  @override
  String get excelTotalWorkHours => 'Total Work Hours';

  @override
  String get excelTotalWorkDays => 'Total Work Days';

  @override
  String get excelCategoryShare => 'Share %';

  @override
  String get excelCategoryRank => 'Rank';

  @override
  String get excelTopCategory => 'Top Category';

  @override
  String get excelCategoryCount => 'Transaction Count';

  @override
  String get excelCategoryAvg => 'Category Average';

  @override
  String get excelCategoryTotal => 'Category Total';

  @override
  String get excelCategoryHours => 'Work Hours';

  @override
  String get excelTimeTitle => 'Time Analysis';

  @override
  String get excelMostActiveDay => 'Most Active Day';

  @override
  String get excelMostActiveHour => 'Most Active Hour';

  @override
  String get excelWeekdayAvg => 'Weekday Average';

  @override
  String get excelWeekendAvg => 'Weekend Average';

  @override
  String get excelMorningSpend => 'Morning (06-12)';

  @override
  String get excelAfternoonSpend => 'Afternoon (12-18)';

  @override
  String get excelEveningSpend => 'Evening (18-24)';

  @override
  String get excelNightSpend => 'Night (00-06)';

  @override
  String get excelByDayOfWeek => 'By Day of Week';

  @override
  String get excelByHour => 'By Hour';

  @override
  String get excelByMonth => 'By Month';

  @override
  String get excelDecisionsBought => 'Bought';

  @override
  String get excelDecisionsThinking => 'Thinking';

  @override
  String get excelDecisionsPassed => 'Passed';

  @override
  String get excelDecisionCount => 'Count';

  @override
  String get excelDecisionAmount => 'Amount';

  @override
  String get excelDecisionPercent => 'Percentage';

  @override
  String get excelDecisionAvg => 'Average';

  @override
  String get excelDecisionHours => 'Work Hours';

  @override
  String get excelImpulseRate => 'Impulse Rate';

  @override
  String get excelSavingsFromPassed => 'Savings from Passed';

  @override
  String get excelPotentialSavings => 'Potential Savings (Thinking)';

  @override
  String get excelInstallmentName => 'Description';

  @override
  String get excelInstallmentTotal => 'Total Amount';

  @override
  String get excelInstallmentMonthly => 'Monthly Payment';

  @override
  String get excelInstallmentProgress => 'Progress';

  @override
  String get excelInstallmentRemaining => 'Remaining';

  @override
  String get excelInstallmentStartDate => 'Start Date';

  @override
  String get excelInstallmentEndDate => 'End Date';

  @override
  String get excelInstallmentInterest => 'Interest';

  @override
  String get excelNoInstallments => 'No installment payments';

  @override
  String get excelTotalMonthlyPayments => 'Total Monthly Payments';

  @override
  String get excelTotalRemainingDebt => 'Total Remaining Debt';

  @override
  String get excelDayMonday => 'Monday';

  @override
  String get excelDayTuesday => 'Tuesday';

  @override
  String get excelDayWednesday => 'Wednesday';

  @override
  String get excelDayThursday => 'Thursday';

  @override
  String get excelDayFriday => 'Friday';

  @override
  String get excelDaySaturday => 'Saturday';

  @override
  String get excelDaySunday => 'Sunday';

  @override
  String get excelYes => 'Yes';

  @override
  String get excelNo => 'No';

  @override
  String get excelReal => 'Real';

  @override
  String get excelSimulation => 'Simulation';

  @override
  String get proFeaturesSheetTitle => 'Pro Feature';

  @override
  String get proFeaturesSheetSubtitle =>
      'This feature is exclusive to Pro members';

  @override
  String get proFeaturesIncluded => 'Pro membership includes:';

  @override
  String get proFeatureHeatmap => 'Expense Heatmap';

  @override
  String get proFeatureHeatmapDesc =>
      'Visualize your spending patterns over the year';

  @override
  String get proFeatureCategoryBreakdown => 'Category Breakdown';

  @override
  String get proFeatureCategoryBreakdownDesc =>
      'Detailed pie chart analysis by category';

  @override
  String get proFeatureSpendingTrends => 'Spending Trends';

  @override
  String get proFeatureSpendingTrendsDesc =>
      'Track your spending changes over time';

  @override
  String get proFeatureTimeAnalysis => 'Time Analysis';

  @override
  String get proFeatureTimeAnalysisDesc =>
      'See when you spend most by day and hour';

  @override
  String get proFeatureBudgetBreakdown => 'Budget Breakdown';

  @override
  String get proFeatureBudgetBreakdownDesc =>
      'Track spending against your budget goals';

  @override
  String get proFeatureAdvancedFilters => 'Advanced Filters';

  @override
  String get proFeatureAdvancedFiltersDesc =>
      'Filter by month, all-time, and more';

  @override
  String get proFeatureExcelExport => 'Excel Export';

  @override
  String get proFeatureExcelExportDesc => 'Export your complete financial data';

  @override
  String get proFeatureUnlimitedHistory => 'Unlimited History';

  @override
  String get proFeatureUnlimitedHistoryDesc => 'Access all your past expenses';

  @override
  String get goProButton => 'Go Pro';

  @override
  String get lockedFeatureTapToUnlock => 'Tap to unlock';

  @override
  String voiceUsageIndicator(int used, int total) {
    return '$used/$total voice inputs today';
  }

  @override
  String aiChatUsageIndicator(int used, int total) {
    return '$used/$total questions today';
  }

  @override
  String get dailyLimitReached => 'Daily limit reached';

  @override
  String get dailyLimitReachedDesc =>
      'You\'ve used all your daily quota. Upgrade to Pro for unlimited access!';

  @override
  String get unlimitedWithPro => 'Unlimited with Pro';
}
