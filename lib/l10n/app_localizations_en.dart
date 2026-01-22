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
  String get settingsThemeSystem => 'System';

  @override
  String get settingsNotifications => 'Notifications';

  @override
  String get settingsReminders => 'Reminders';

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
  String get settingsPrivacyPolicy => 'Privacy Policy';

  @override
  String get settingsAbout => 'About';

  @override
  String get settingsVersion => 'Version';

  @override
  String get settingsContactUs => 'Contact Us';

  @override
  String get settingsGrowth => 'Growth';

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
  String get monthJan => 'January';

  @override
  String get monthFeb => 'February';

  @override
  String get monthMar => 'March';

  @override
  String get monthApr => 'April';

  @override
  String get monthMay => 'May';

  @override
  String get monthJun => 'June';

  @override
  String get monthJul => 'July';

  @override
  String get monthAug => 'August';

  @override
  String get monthSep => 'September';

  @override
  String get monthOct => 'October';

  @override
  String get monthNov => 'November';

  @override
  String get monthDec => 'December';

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
  String get linkWithGoogle => 'Link with Google';

  @override
  String get linking => 'Linking...';

  @override
  String get backupAndSecure => 'Backup and secure your data';

  @override
  String get googleLinkedSuccess => 'Google account linked successfully!';

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
  String get notificationSettings => 'Notification Settings';

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
  String get understood => 'Got it';

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
    return 'Every ${day}th';
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
  String get autoRecordDescription => 'Create expense record on renewal';

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
  String get editIncomes => 'Edit Incomes';

  @override
  String get addIncome => 'Add Income';

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
  String get incomeType => 'Income Type';

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
  String get expense => 'EXPENSE';

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
  String get autoRecordEnabled => 'Auto expense recording enabled';

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
  String get yearlyHeatmap => 'Expense Heatmap';

  @override
  String get yearlyHeatmapDesc => 'Your spending intensity throughout the year';

  @override
  String get lowSpending => 'Low';

  @override
  String get highSpending => 'High';

  @override
  String get noSpending => 'No spending';

  @override
  String get tapDayForDetails => 'Tap a day for details';

  @override
  String selectedDayExpenses(String date, String amount, int count) {
    return '$date: $amount TL ($count expenses)';
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
  String get importSuccess => 'Import completed successfully';

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
  String get undo => 'Undo';

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
  String get featureAiChatFree => '5/day';

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
  String get aiLimitFreeMessage => 'You\'ve used all 5 AI questions for today.';

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
  String remainingAmount(String amount) {
    return '$amount remaining';
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
}
