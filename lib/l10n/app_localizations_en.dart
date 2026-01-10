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
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

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
  String get profile => 'Profile';

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get settings => 'Settings';

  @override
  String get language => 'Language';

  @override
  String get selectLanguage => 'Select Language';

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
  String get signOut => 'Sign Out';

  @override
  String get deleteAccount => 'Delete Account';

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
  String get expenseHistory => 'History';

  @override
  String recordCount(int count) {
    return '$count records';
  }

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
  String get selectCategory => 'Select category';

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
  String get exampleAmount => 'e.g: 50000';

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
}
