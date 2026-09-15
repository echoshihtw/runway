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
  String get burnPerMonth => 'BURN/MO';

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
  String get loanAffectsInfo =>
      'Loan payments add to your fixed costs and reduce runway.';

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
  String get burnRateOverride => 'Monthly burn';

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
  String get typeRepay => 'REPAY';

  @override
  String get typeOpening => 'OPENING';

  @override
  String get liabilities => 'LIABILITIES';

  @override
  String get noActiveLoans => '> NO ACTIVE LOANS';

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
      'OVERRIDE BURN RATE OR ADD INCOME TO SEE IMPACT ON RUNWAY';

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
  String get expectedInflow => 'Expected inflow';

  @override
  String get expectedBurn => 'Expected burn';

  @override
  String get notSet => 'Not set';

  @override
  String get usingCurrentBurn => 'Using current burn';

  @override
  String get assumptionsProjectionOnly =>
      'Assumptions affect future projections only. They do not create transactions.';

  @override
  String get setAssumptions => 'SET FORECAST';

  @override
  String get expectedMonthlyInflow => 'Expected monthly inflow';

  @override
  String get expectedMonthlyBurn => 'Expected monthly burn';

  @override
  String get useCurrentBurn => 'Use current burn';

  @override
  String get futureInflowHint =>
      'Any recurring or expected inflow — retainers, contracts, creator income, dividends.';

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
  String get display => 'DISPLAY';

  @override
  String get glassEffect => 'GLASS EFFECT';

  @override
  String get glassEffectHint => 'GPU INTENSIVE — DISABLE ON OLDER DEVICES';

  @override
  String get runwayBrand => 'RUNWAY';

  @override
  String get bootRunwayCheck => 'Checking your runway...';

  @override
  String get bootIncomeStopped => 'Looking at what changes if income pauses...';

  @override
  String get bootCountingCashDays => 'Estimating your breathing room...';

  @override
  String get bootRemovingComfortFilter => 'Separating essentials from noise...';

  @override
  String get bootRealityCheckReady => 'Your financial picture is ready.';

  @override
  String get ifIncomeStoppedToday => 'If inflow stopped today';

  @override
  String get ifIncomePausedToday => 'If income paused today';

  @override
  String get monthSingular => 'month';

  @override
  String get monthPlural => 'months';

  @override
  String get sustainableWithExpectedInflow =>
      'Sustainable with your expected inflow';

  @override
  String shortByPerMonth(String amount) {
    return 'Short by $amount / month';
  }

  @override
  String goalTargetProgress(int months) {
    return '$months month target. Progress toward your goal, not a score.';
  }

  @override
  String get monthlyBurn => 'Monthly burn';

  @override
  String get availableCash => 'Available cash';

  @override
  String get historicalBurn => 'Avg burn';

  @override
  String get notEnoughHistory => 'Not enough history';

  @override
  String get projectionSource => 'Projection source';

  @override
  String get usingAssumptions => 'Using assumptions';

  @override
  String get fixedPressure => 'Fixed costs';

  @override
  String get actualBurn => 'Actual burn';

  @override
  String get actualBurnHigh => 'Actual burn ▲';

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
  String get loseIncome => 'Inflow stops';

  @override
  String get higherExpenses => 'Higher expenses';

  @override
  String get incomeSetToZero => 'Inflow set to 0';

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
}
