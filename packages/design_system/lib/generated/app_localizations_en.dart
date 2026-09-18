// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Runway';

  @override
  String get hudTitle => 'Runway';

  @override
  String get sysOnline => 'Ready';

  @override
  String get lifeForce => 'RUNWAY READINESS';

  @override
  String get statusLabel => 'Position';

  @override
  String get pressureLabel => 'Monthly costs';

  @override
  String get metrics => 'Signals';

  @override
  String get cash => 'CASH';

  @override
  String get loanPerMonth => 'DEBT/MO';

  @override
  String get runway => 'RUNWAY';

  @override
  String get runOut => 'RUN OUT';

  @override
  String get cashTimeline => 'CASH TIMELINE';

  @override
  String get config => 'Settings';

  @override
  String get monthlyLoanPayment => 'MONTHLY LOAN PAYMENT';

  @override
  String get tapToSet => 'TAP TO SET';

  @override
  String get edit => 'EDIT';

  @override
  String get save => 'SAVE';

  @override
  String get clear => 'CLEAR';

  @override
  String get transactionLog => 'TRANSACTION LOG';

  @override
  String get newEntry => '+ NEW';

  @override
  String get noEntries => 'No entries yet\nTap + ADD to log your first entry';

  @override
  String get newLogEntry => '> NEW LOG ENTRY';

  @override
  String get modifyEntry => '> MODIFY ENTRY';

  @override
  String get type => 'TYPE';

  @override
  String get date => 'DATE';

  @override
  String get calcMonth => 'CALC';

  @override
  String get amount => 'AMOUNT';

  @override
  String get noteOptional => 'NOTE (OPTIONAL)';

  @override
  String get confirm => 'CONFIRM';

  @override
  String get abort => 'ABORT';

  @override
  String get purgeEntry => '> PURGE ENTRY?';

  @override
  String get scenarioSimulator => 'Scenario planning';

  @override
  String get overrideInputs => 'Planning inputs';

  @override
  String get burnRateOverride => 'Monthly costs';

  @override
  String get simulatedIncome => 'Income change / month';

  @override
  String get simResults => 'Projected impact';

  @override
  String get simRunway => 'Projected runway';

  @override
  String get simRunOut => 'Projected run-out';

  @override
  String get deltaVsActual => 'Change from today';

  @override
  String get deltaRunway => 'Runway change';

  @override
  String get resetSim => 'Reset scenario';

  @override
  String get months => 'MONTHS';

  @override
  String get stable => 'STABLE';

  @override
  String get caution => 'CAUTION';

  @override
  String get critical => 'CRITICAL';

  @override
  String get low => 'LOW';

  @override
  String get moderate => 'MODERATE';

  @override
  String get highLoad => 'HIGH LOAD';

  @override
  String get language => 'LANGUAGE';

  @override
  String get currency => 'CURRENCY';

  @override
  String get currencySymbolOnly =>
      'Changes the display symbol only — your amounts are not converted.';

  @override
  String get daysShort => 'd';

  @override
  String get gettingStarted => 'GETTING STARTED';

  @override
  String stepsComplete(int completed, int total) {
    return '$completed of $total complete';
  }

  @override
  String get stepBalanceLabel => 'Add your cash balance';

  @override
  String get stepBalanceHint => 'How much do you have right now?';

  @override
  String get stepBudgetLabel => 'Set your monthly budget';

  @override
  String get stepBudgetHint => 'Rent + living expenses';

  @override
  String get stepExpenseLabel => 'Log your first expense';

  @override
  String get stepExpenseHint => 'Track where your money goes';

  @override
  String get stepSimLabel => 'Try the simulator';

  @override
  String get stepSimHint => 'What if you cut expenses?';

  @override
  String get loading => 'LOADING...';

  @override
  String get navHud => 'Home';

  @override
  String get navLog => 'LOG';

  @override
  String get navSim => 'Plan';

  @override
  String get typeExpense => 'EXPENSE';

  @override
  String get typeIncome => 'INCOME';

  @override
  String get typeLoan => 'LOAN';

  @override
  String get typeRepay => 'LOAN PAYMENT';

  @override
  String get typeOpening => 'OPENING';

  @override
  String get typeSubscription => 'SUBSCRIPTION';

  @override
  String subscriptionPaidQuestion(String amount, String name, String date) {
    return 'Did you pay $amount for $name on $date?';
  }

  @override
  String subscriptionChargesDue(int count, String amount) {
    return '$count subscription charges due — $amount';
  }

  @override
  String get subscriptionConfirmAll => 'Confirm all';

  @override
  String get subscriptionReviewEach => 'Review each';

  @override
  String get subscriptionPaidYes => 'Yes, log it';

  @override
  String get subscriptionChargeFailed =>
      'Couldn\'t record that. Check the amount on the subscription.';

  @override
  String get subscriptionSaveFailed =>
      'Couldn\'t save that subscription. Nothing was added.';

  @override
  String get subscriptionPaidNo => 'No';

  @override
  String get subscriptionWhatHappened => 'What happened?';

  @override
  String get subscriptionReasonCancelled => 'I cancelled it';

  @override
  String get subscriptionReasonPriceChanged => 'The price changed';

  @override
  String get subscriptionReasonNotPaid => 'I didn\'t pay it';

  @override
  String get deleteSubscription => 'Delete subscription';

  @override
  String get deleteSubscriptionKeepsEntries =>
      'Stops future entries. The payments already logged are kept.';

  @override
  String get liabilities => 'LIABILITIES';

  @override
  String get noActiveLoans => '> NO ACTIVE LOANS';

  @override
  String get newLoan => '+ LOAN';

  @override
  String get spendOnWhat => 'WHAT DID YOU SPEND ON?';

  @override
  String get presetCoffee => 'COFFEE';

  @override
  String get presetCoffeeNote => 'Coffee';

  @override
  String get presetLunch => 'LUNCH';

  @override
  String get presetLunchNote => 'Lunch';

  @override
  String get presetDinner => 'DINNER';

  @override
  String get presetDinnerNote => 'Dinner';

  @override
  String get presetTransport => 'TRANSPORT';

  @override
  String get presetTransportNote => 'Transport';

  @override
  String get presetGroceries => 'GROCERIES';

  @override
  String get presetGroceriesNote => 'Groceries';

  @override
  String get presetSomethingElse => 'SOMETHING ELSE';

  @override
  String freeEntriesUsed(int used, int free) {
    return '$used of $free free entries used';
  }

  @override
  String freeSimulationsUsed(int used, int free) {
    return '$used of $free free simulations used';
  }

  @override
  String get settled => 'SETTLED';

  @override
  String get totalDebtPerMonth => 'TOTAL DEBT/MO';

  @override
  String get remaining => 'REMAINING';

  @override
  String get installment => 'INSTALLMENT';

  @override
  String get paidThisMo => 'PAID THIS MO';

  @override
  String get monthsLeft => 'MONTHS LEFT';

  @override
  String get repaid => '% REPAID';

  @override
  String get repay => 'REPAY';

  @override
  String get repayTitle => '> REPAY';

  @override
  String get extra => 'EXTRA';

  @override
  String get configButton => 'CFG';

  @override
  String get loanWizardTitle => 'LOAN WIZARD';

  @override
  String get whoAndHowMuch => 'WHO & HOW MUCH';

  @override
  String get loanTerms => 'LOAN TERMS';

  @override
  String get confirmPayment => 'CONFIRM PAYMENT';

  @override
  String get source => 'SOURCE';

  @override
  String get nameLender => 'NAME / LENDER';

  @override
  String get loanAmount => 'LOAN AMOUNT';

  @override
  String get annualRate => 'ANNUAL INTEREST RATE % (0 = NO INTEREST)';

  @override
  String get repaymentMonths => 'REPAYMENT MONTHS';

  @override
  String get computedInstallment => 'COMPUTED INSTALLMENT';

  @override
  String get overrideInstallment => 'OVERRIDE MONTHLY INSTALLMENT';

  @override
  String get monthlyInstallment => 'MONTHLY INSTALLMENT';

  @override
  String get next => 'NEXT';

  @override
  String get back => 'BACK';

  @override
  String get lender => 'LENDER';

  @override
  String get rate => 'RATE';

  @override
  String get change => 'CHANGE';

  @override
  String get subscriptions => 'SUBSCRIPTIONS';

  @override
  String get noSubscriptions => '> NO ACTIVE SUBSCRIPTIONS';

  @override
  String get subscriptionName => 'NAME';

  @override
  String get subscriptionAmount => 'AMOUNT';

  @override
  String get subscriptionPaymentAmount => 'PAYMENT AMOUNT';

  @override
  String get subscriptionCycle => 'BILLING CYCLE';

  @override
  String get subscriptionCoveragePeriod => 'COVERAGE PERIOD';

  @override
  String get subscriptionCategory => 'CATEGORY';

  @override
  String get subscriptionPaymentDate => 'PAYMENT DATE';

  @override
  String get subscriptionNextBilling => 'NEXT BILLING';

  @override
  String get subscriptionDaysLeft => 'DAYS';

  @override
  String get totalPerMonth => 'TOTAL/MO';

  @override
  String get totalPerYear => 'TOTAL/YR';

  @override
  String get newSubscription => '+ SUBSCRIPTION';

  @override
  String get editSubscription => '> EDIT SUBSCRIPTION';

  @override
  String get addSubscription => '> NEW SUBSCRIPTION';

  @override
  String get personal => 'PERSONAL';

  @override
  String get business => 'BUSINESS';

  @override
  String get weekly => 'WEEKLY';

  @override
  String get monthly => 'MONTHLY';

  @override
  String get quarterly => 'QUARTERLY';

  @override
  String get yearly => 'YEARLY';

  @override
  String get subscrPerMonth => '/ month';

  @override
  String get loans => 'LOANS';

  @override
  String activeCount(int count) {
    return '$count ACTIVE';
  }

  @override
  String get repayLoan => 'REPAY LOAN';

  @override
  String get repaymentAmount => 'REPAYMENT AMOUNT';

  @override
  String get cancel => 'CANCEL';

  @override
  String get paid => '✓ PAID';

  @override
  String get subscrPerYear => '/ year';

  @override
  String get removeConfirm => 'REMOVE?';

  @override
  String get remove => 'REMOVE';

  @override
  String monthsProjected(int count) {
    return '$count months ahead';
  }

  @override
  String get budgetPerMonth => 'BUDGET/MO';

  @override
  String get breakdown => 'BREAKDOWN';

  @override
  String get safetyFund => 'SAFETY FUND';

  @override
  String get safety => 'SAFETY';

  @override
  String get deployableCapital =>
      'Optional capital after protecting your runway';

  @override
  String get historyEntries => 'HISTORY & ENTRIES';

  @override
  String get addEntry => '+ ADD';

  @override
  String get willRemoveLoan => 'WILL ALSO REMOVE FROM LIABILITIES';

  @override
  String get delete => 'DELETE';

  @override
  String get dataSection => 'Your data';

  @override
  String get deleteAllDataBody =>
      'Erase every entry, loan, subscription and setting from this device. Runway Pro stays unlocked.';

  @override
  String get deleteAllDataButton => 'DELETE ALL DATA';

  @override
  String get deleteAllDataConfirmTitle => 'Delete everything?';

  @override
  String get deleteAllDataConfirmBody =>
      'Your data is erased from this device and cannot be recovered. Runway starts again from the beginning.';

  @override
  String get deleteAllDataConfirmAction => 'DELETE EVERYTHING';

  @override
  String get planned => 'PLANNED';

  @override
  String get whatIfAnalysis => 'WHAT-IF ANALYSIS';

  @override
  String get current => 'CURRENT';

  @override
  String get simulate => 'Plan';

  @override
  String get simHint =>
      'CHANGE MONTHLY COSTS OR ADD INCOME TO SEE THE IMPACT ON RUNWAY';

  @override
  String get simulation => 'Scenario';

  @override
  String get enterValuesToSim => 'Enter values above to see the impact';

  @override
  String get perMonth => '/ MONTH';

  @override
  String get prefsBudget => 'PREFERENCES & BUDGET';

  @override
  String get close => 'CLOSE';

  @override
  String get monthlyBudget => 'MONTHLY BUDGET';

  @override
  String get rentFixed => 'RENT / FIXED';

  @override
  String get livingExpenses => 'LIVING EXPENSES';

  @override
  String get subtotal => 'SUBTOTAL';

  @override
  String budgetLeft(String amount) {
    return '$amount left';
  }

  @override
  String budgetOver(String amount) {
    return '$amount over budget';
  }

  @override
  String dailyAllowance(String amount, int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$amount a day for $days days',
      one: '$amount left for today',
    );
    return '$_temp0';
  }

  @override
  String get noLivingExpensesThisMonth =>
      'No living expenses logged this month';

  @override
  String get totalBudgetPerMonth => 'TOTAL BUDGET/MO';

  @override
  String get setBudget => 'SET BUDGET';

  @override
  String get rentFixedCosts => 'RENT / FIXED COSTS';

  @override
  String get subscrDebtAuto => 'SUBSCRIPTIONS + DEBT ADDED AUTOMATICALLY';

  @override
  String get futureAssumptions => 'Forecast';

  @override
  String get expectedInflow => 'Expected income';

  @override
  String get expectedBurn => 'Expected costs';

  @override
  String get notSet => 'Not set';

  @override
  String get settingsFailedToLoad =>
      'Couldn\'t load these settings. Editing is off so nothing overwrites them.';

  @override
  String get usingCurrentBurn => 'Using current costs';

  @override
  String get assumptionsProjectionOnly =>
      'Assumptions affect future projections only. They do not create transactions.';

  @override
  String get setAssumptions => 'SET FORECAST';

  @override
  String get expectedMonthlyInflow => 'Expected monthly income';

  @override
  String get expectedMonthlyBurn => 'Expected monthly costs';

  @override
  String get useCurrentBurn => 'Use current costs';

  @override
  String get futureInflowHint =>
      'Any recurring or expected income, such as retainers, contracts, creator income or dividends.';

  @override
  String get runwayGoal => 'Runway goal';

  @override
  String get goal => 'Goal';

  @override
  String get none => 'None';

  @override
  String get target => 'Target';

  @override
  String get optional => 'Optional';

  @override
  String monthsValue(int count) {
    return '$count months';
  }

  @override
  String get goalsContextHint =>
      'Goals add context to your runway. They are not a score.';

  @override
  String get setGoal => 'SET GOAL';

  @override
  String get goalName => 'Goal name';

  @override
  String get targetMonths => 'Target months';

  @override
  String get runwayBrand => 'RUNWAY';

  @override
  String get runwayBasisBudget => 'On your budget, if income paused today';

  @override
  String get runwayBasisSpending => 'On your spending, if income paused today';

  @override
  String get runwayBasisAssumption =>
      'On your cost assumption, if income paused today';

  @override
  String computedCost(String amount) {
    return 'Computed from your budget and log: $amount';
  }

  @override
  String get runwayNeedsCosts => 'Set your monthly costs to see your runway';

  @override
  String get monthSingular => 'month';

  @override
  String get monthPlural => 'months';

  @override
  String get sustainableWithExpectedInflow =>
      'Sustainable with your expected income';

  @override
  String shortByPerMonth(String amount) {
    return 'Short by $amount / month';
  }

  @override
  String goalTargetProgress(int months) {
    return '$months month target. Progress toward your goal, not a score.';
  }

  @override
  String get availableCash => 'Available cash';

  @override
  String get notEnoughHistory => 'Not enough history';

  @override
  String get projectionSource => 'Projection source';

  @override
  String get usingAssumptions => 'Using assumptions';

  @override
  String get fixedPressure => 'Fixed costs';

  @override
  String get plannedEssentials => 'Planned essentials';

  @override
  String get recurringCosts => 'Recurring costs';

  @override
  String get debtCommitments => 'Loan payments';

  @override
  String get daysUpper => 'DAYS';

  @override
  String get yourRunway => 'Your runway';

  @override
  String get higherExpenses => 'Higher expenses';

  @override
  String deltaDays(int days) {
    return '$days days';
  }

  @override
  String get shareSafe => 'SHARE SAFE';

  @override
  String get shareSafeHint => 'No savings. No expenses. Just your runway.';

  @override
  String get preparing => 'PREPARING...';

  @override
  String get shareImage => 'SHARE IMAGE';

  @override
  String get shareAsText => 'SHARE AS TEXT';

  @override
  String get goalReached => 'Goal reached!';

  @override
  String monthsToGoal(int count) {
    return '$count months to go';
  }

  @override
  String get thisMonth => 'THIS MONTH';

  @override
  String get cashIn => 'IN';

  @override
  String get cashOut => 'OUT';

  @override
  String get netLabel => 'NET';

  @override
  String get noActivityThisMonth => 'No activity yet this month';

  @override
  String get onboardingSkip => 'SKIP';

  @override
  String get onboardingWelcomeTitle => 'Know your\nrunway.';

  @override
  String get onboardingWelcomeBody =>
      'One number shows where you stand.\nHow many months does your money cover?';

  @override
  String get onboardingGetStarted => 'GET STARTED';

  @override
  String get onboardingPrivacyTitle => 'Your data,\nyour device.';

  @override
  String get onboardingPrivacyBody =>
      'Everything is encrypted on your device.\nWe cannot read your financial data.\nEven we don\'t know your numbers.';

  @override
  String get onboardingPrivacyEncrypted => 'Encrypted on device';

  @override
  String get onboardingPrivacyOnDevice => 'Numbers stay on your device';

  @override
  String get onboardingPrivacyHidden => 'Hidden when you switch apps';

  @override
  String get onboardingPrivacyDelete => 'Delete anytime, instantly';

  @override
  String get onboardingIUnderstand => 'I UNDERSTAND';

  @override
  String get onboardingFirstActionTitle => 'Ready to find\nyour runway?';

  @override
  String get onboardingFirstActionBody =>
      'Start by adding your current cash balance.\nThat\'s all you need to see your number.';

  @override
  String get onboardingAddMyBalance => 'ADD MY BALANCE';

  @override
  String get paywallUnlock => 'UNLOCK RUNWAY PRO';

  @override
  String get paywallLoadingPrice => 'Loading price...';

  @override
  String get paywallStoreUnreachable =>
      'Couldn\'t reach the store. Check your connection and try again.';

  @override
  String paywallOneTimePurchase(String price) {
    return '$price · One-time purchase';
  }

  @override
  String get paywallUnavailable =>
      'Pro isn\'t available right now. Please try again later.';

  @override
  String get paywallRestore => 'Restore purchase';

  @override
  String get paywallMaybeLater => 'Maybe later';

  @override
  String get paywallPurchaseFailed => 'Purchase failed. Please try again.';

  @override
  String get paywallSomethingWrong => 'Something went wrong. Please try again.';

  @override
  String get paywallNoPreviousPurchase => 'No previous purchase found.';

  @override
  String get paywallRestoreFailed => 'Restore failed. Please try again.';

  @override
  String paywallTitleEntries(int count) {
    return 'You\'ve logged your $count free entries.\nUnlimited entries is Pro.';
  }

  @override
  String paywallTitleSimulations(int count) {
    return 'You\'ve run your $count free simulations.\nUnlimited simulations is Pro.';
  }

  @override
  String get paywallTitleDefault => 'Unlock Runway Pro.';

  @override
  String get paywallFeatureEntries => 'Unlimited entries';

  @override
  String get paywallFeatureSimulations => 'Unlimited scenario simulations';

  @override
  String get stepBalanceShort => 'Cash balance';

  @override
  String get stepBudgetShort => 'Budget';

  @override
  String get stepExpenseShort => 'First expense';

  @override
  String get stepSimShort => 'Simulator';

  @override
  String stepsDone(String steps) {
    return 'Done: $steps';
  }

  @override
  String get optionalBadge => 'OPTIONAL';

  @override
  String get paywallTermsOfUse => 'Terms of Use';

  @override
  String get paywallPrivacyPolicy => 'Privacy Policy';
}
