import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_it.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
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
    Locale('es'),
    Locale('fr'),
    Locale('it'),
    Locale('ja'),
    Locale('zh'),
    Locale('zh', 'TW'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Runway'**
  String get appTitle;

  /// No description provided for @hudTitle.
  ///
  /// In en, this message translates to:
  /// **'Runway'**
  String get hudTitle;

  /// No description provided for @sysOnline.
  ///
  /// In en, this message translates to:
  /// **'Ready'**
  String get sysOnline;

  /// No description provided for @lifeForce.
  ///
  /// In en, this message translates to:
  /// **'RUNWAY READINESS'**
  String get lifeForce;

  /// No description provided for @statusLabel.
  ///
  /// In en, this message translates to:
  /// **'Position'**
  String get statusLabel;

  /// No description provided for @pressureLabel.
  ///
  /// In en, this message translates to:
  /// **'Monthly costs'**
  String get pressureLabel;

  /// No description provided for @metrics.
  ///
  /// In en, this message translates to:
  /// **'Signals'**
  String get metrics;

  /// No description provided for @cash.
  ///
  /// In en, this message translates to:
  /// **'CASH'**
  String get cash;

  /// No description provided for @burnPerMonth.
  ///
  /// In en, this message translates to:
  /// **'BURN/MO'**
  String get burnPerMonth;

  /// No description provided for @loanPerMonth.
  ///
  /// In en, this message translates to:
  /// **'DEBT/MO'**
  String get loanPerMonth;

  /// No description provided for @runway.
  ///
  /// In en, this message translates to:
  /// **'RUNWAY'**
  String get runway;

  /// No description provided for @runOut.
  ///
  /// In en, this message translates to:
  /// **'RUN OUT'**
  String get runOut;

  /// No description provided for @cashTimeline.
  ///
  /// In en, this message translates to:
  /// **'CASH TIMELINE'**
  String get cashTimeline;

  /// No description provided for @config.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get config;

  /// No description provided for @monthlyLoanPayment.
  ///
  /// In en, this message translates to:
  /// **'MONTHLY LOAN PAYMENT'**
  String get monthlyLoanPayment;

  /// No description provided for @tapToSet.
  ///
  /// In en, this message translates to:
  /// **'TAP TO SET'**
  String get tapToSet;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'EDIT'**
  String get edit;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'SAVE'**
  String get save;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'CLEAR'**
  String get clear;

  /// No description provided for @loanAffectsInfo.
  ///
  /// In en, this message translates to:
  /// **'Loan payments add to your fixed costs and reduce runway.'**
  String get loanAffectsInfo;

  /// No description provided for @transactionLog.
  ///
  /// In en, this message translates to:
  /// **'TRANSACTION LOG'**
  String get transactionLog;

  /// No description provided for @newEntry.
  ///
  /// In en, this message translates to:
  /// **'+ NEW'**
  String get newEntry;

  /// No description provided for @noEntries.
  ///
  /// In en, this message translates to:
  /// **'No entries yet\nTap + ADD to log your first entry'**
  String get noEntries;

  /// No description provided for @newLogEntry.
  ///
  /// In en, this message translates to:
  /// **'> NEW LOG ENTRY'**
  String get newLogEntry;

  /// No description provided for @modifyEntry.
  ///
  /// In en, this message translates to:
  /// **'> MODIFY ENTRY'**
  String get modifyEntry;

  /// No description provided for @type.
  ///
  /// In en, this message translates to:
  /// **'TYPE'**
  String get type;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'DATE'**
  String get date;

  /// No description provided for @calcMonth.
  ///
  /// In en, this message translates to:
  /// **'CALC'**
  String get calcMonth;

  /// No description provided for @amount.
  ///
  /// In en, this message translates to:
  /// **'AMOUNT'**
  String get amount;

  /// No description provided for @noteOptional.
  ///
  /// In en, this message translates to:
  /// **'NOTE (OPTIONAL)'**
  String get noteOptional;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'CONFIRM'**
  String get confirm;

  /// No description provided for @abort.
  ///
  /// In en, this message translates to:
  /// **'ABORT'**
  String get abort;

  /// No description provided for @purgeEntry.
  ///
  /// In en, this message translates to:
  /// **'> PURGE ENTRY?'**
  String get purgeEntry;

  /// No description provided for @scenarioSimulator.
  ///
  /// In en, this message translates to:
  /// **'Scenario planning'**
  String get scenarioSimulator;

  /// No description provided for @overrideInputs.
  ///
  /// In en, this message translates to:
  /// **'Planning inputs'**
  String get overrideInputs;

  /// No description provided for @burnRateOverride.
  ///
  /// In en, this message translates to:
  /// **'Monthly burn'**
  String get burnRateOverride;

  /// No description provided for @simulatedIncome.
  ///
  /// In en, this message translates to:
  /// **'Income change / month'**
  String get simulatedIncome;

  /// No description provided for @simResults.
  ///
  /// In en, this message translates to:
  /// **'Projected impact'**
  String get simResults;

  /// No description provided for @simRunway.
  ///
  /// In en, this message translates to:
  /// **'Projected runway'**
  String get simRunway;

  /// No description provided for @simRunOut.
  ///
  /// In en, this message translates to:
  /// **'Projected run-out'**
  String get simRunOut;

  /// No description provided for @deltaVsActual.
  ///
  /// In en, this message translates to:
  /// **'Change from today'**
  String get deltaVsActual;

  /// No description provided for @deltaRunway.
  ///
  /// In en, this message translates to:
  /// **'Runway change'**
  String get deltaRunway;

  /// No description provided for @resetSim.
  ///
  /// In en, this message translates to:
  /// **'Reset scenario'**
  String get resetSim;

  /// No description provided for @months.
  ///
  /// In en, this message translates to:
  /// **'MONTHS'**
  String get months;

  /// No description provided for @stable.
  ///
  /// In en, this message translates to:
  /// **'STABLE'**
  String get stable;

  /// No description provided for @caution.
  ///
  /// In en, this message translates to:
  /// **'CAUTION'**
  String get caution;

  /// No description provided for @critical.
  ///
  /// In en, this message translates to:
  /// **'CRITICAL'**
  String get critical;

  /// No description provided for @low.
  ///
  /// In en, this message translates to:
  /// **'LOW'**
  String get low;

  /// No description provided for @moderate.
  ///
  /// In en, this message translates to:
  /// **'MODERATE'**
  String get moderate;

  /// No description provided for @highLoad.
  ///
  /// In en, this message translates to:
  /// **'HIGH LOAD'**
  String get highLoad;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'LANGUAGE'**
  String get language;

  /// No description provided for @currency.
  ///
  /// In en, this message translates to:
  /// **'CURRENCY'**
  String get currency;

  /// No description provided for @currencySymbolOnly.
  ///
  /// In en, this message translates to:
  /// **'Changes the display symbol only — your amounts are not converted.'**
  String get currencySymbolOnly;

  /// No description provided for @daysShort.
  ///
  /// In en, this message translates to:
  /// **'d'**
  String get daysShort;

  /// No description provided for @gettingStarted.
  ///
  /// In en, this message translates to:
  /// **'GETTING STARTED'**
  String get gettingStarted;

  /// No description provided for @stepsComplete.
  ///
  /// In en, this message translates to:
  /// **'{completed} of {total} complete'**
  String stepsComplete(int completed, int total);

  /// No description provided for @stepBalanceLabel.
  ///
  /// In en, this message translates to:
  /// **'Add your cash balance'**
  String get stepBalanceLabel;

  /// No description provided for @stepBalanceHint.
  ///
  /// In en, this message translates to:
  /// **'How much do you have right now?'**
  String get stepBalanceHint;

  /// No description provided for @stepBudgetLabel.
  ///
  /// In en, this message translates to:
  /// **'Set your monthly budget'**
  String get stepBudgetLabel;

  /// No description provided for @stepBudgetHint.
  ///
  /// In en, this message translates to:
  /// **'Rent + living expenses'**
  String get stepBudgetHint;

  /// No description provided for @stepExpenseLabel.
  ///
  /// In en, this message translates to:
  /// **'Log your first expense'**
  String get stepExpenseLabel;

  /// No description provided for @stepExpenseHint.
  ///
  /// In en, this message translates to:
  /// **'Track where your money goes'**
  String get stepExpenseHint;

  /// No description provided for @stepSimLabel.
  ///
  /// In en, this message translates to:
  /// **'Try the simulator'**
  String get stepSimLabel;

  /// No description provided for @stepSimHint.
  ///
  /// In en, this message translates to:
  /// **'What if you cut expenses?'**
  String get stepSimHint;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'LOADING...'**
  String get loading;

  /// No description provided for @navHud.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHud;

  /// No description provided for @navLog.
  ///
  /// In en, this message translates to:
  /// **'LOG'**
  String get navLog;

  /// No description provided for @navSim.
  ///
  /// In en, this message translates to:
  /// **'Plan'**
  String get navSim;

  /// No description provided for @typeExpense.
  ///
  /// In en, this message translates to:
  /// **'EXPENSE'**
  String get typeExpense;

  /// No description provided for @typeIncome.
  ///
  /// In en, this message translates to:
  /// **'INCOME'**
  String get typeIncome;

  /// No description provided for @typeLoan.
  ///
  /// In en, this message translates to:
  /// **'LOAN'**
  String get typeLoan;

  /// No description provided for @typeRepay.
  ///
  /// In en, this message translates to:
  /// **'REPAY'**
  String get typeRepay;

  /// No description provided for @typeOpening.
  ///
  /// In en, this message translates to:
  /// **'OPENING'**
  String get typeOpening;

  /// No description provided for @liabilities.
  ///
  /// In en, this message translates to:
  /// **'LIABILITIES'**
  String get liabilities;

  /// No description provided for @noActiveLoans.
  ///
  /// In en, this message translates to:
  /// **'> NO ACTIVE LOANS'**
  String get noActiveLoans;

  /// No description provided for @settled.
  ///
  /// In en, this message translates to:
  /// **'SETTLED'**
  String get settled;

  /// No description provided for @totalDebtPerMonth.
  ///
  /// In en, this message translates to:
  /// **'TOTAL DEBT/MO'**
  String get totalDebtPerMonth;

  /// No description provided for @remaining.
  ///
  /// In en, this message translates to:
  /// **'REMAINING'**
  String get remaining;

  /// No description provided for @installment.
  ///
  /// In en, this message translates to:
  /// **'INSTALLMENT'**
  String get installment;

  /// No description provided for @paidThisMo.
  ///
  /// In en, this message translates to:
  /// **'PAID THIS MO'**
  String get paidThisMo;

  /// No description provided for @monthsLeft.
  ///
  /// In en, this message translates to:
  /// **'MONTHS LEFT'**
  String get monthsLeft;

  /// No description provided for @repaid.
  ///
  /// In en, this message translates to:
  /// **'% REPAID'**
  String get repaid;

  /// No description provided for @repay.
  ///
  /// In en, this message translates to:
  /// **'REPAY'**
  String get repay;

  /// No description provided for @repayTitle.
  ///
  /// In en, this message translates to:
  /// **'> REPAY'**
  String get repayTitle;

  /// No description provided for @extra.
  ///
  /// In en, this message translates to:
  /// **'EXTRA'**
  String get extra;

  /// No description provided for @configButton.
  ///
  /// In en, this message translates to:
  /// **'CFG'**
  String get configButton;

  /// No description provided for @loanWizardTitle.
  ///
  /// In en, this message translates to:
  /// **'LOAN WIZARD'**
  String get loanWizardTitle;

  /// No description provided for @whoAndHowMuch.
  ///
  /// In en, this message translates to:
  /// **'WHO & HOW MUCH'**
  String get whoAndHowMuch;

  /// No description provided for @loanTerms.
  ///
  /// In en, this message translates to:
  /// **'LOAN TERMS'**
  String get loanTerms;

  /// No description provided for @confirmPayment.
  ///
  /// In en, this message translates to:
  /// **'CONFIRM PAYMENT'**
  String get confirmPayment;

  /// No description provided for @source.
  ///
  /// In en, this message translates to:
  /// **'SOURCE'**
  String get source;

  /// No description provided for @nameLender.
  ///
  /// In en, this message translates to:
  /// **'NAME / LENDER'**
  String get nameLender;

  /// No description provided for @loanAmount.
  ///
  /// In en, this message translates to:
  /// **'LOAN AMOUNT'**
  String get loanAmount;

  /// No description provided for @annualRate.
  ///
  /// In en, this message translates to:
  /// **'ANNUAL INTEREST RATE % (0 = NO INTEREST)'**
  String get annualRate;

  /// No description provided for @repaymentMonths.
  ///
  /// In en, this message translates to:
  /// **'REPAYMENT MONTHS'**
  String get repaymentMonths;

  /// No description provided for @computedInstallment.
  ///
  /// In en, this message translates to:
  /// **'COMPUTED INSTALLMENT'**
  String get computedInstallment;

  /// No description provided for @overrideInstallment.
  ///
  /// In en, this message translates to:
  /// **'OVERRIDE MONTHLY INSTALLMENT'**
  String get overrideInstallment;

  /// No description provided for @monthlyInstallment.
  ///
  /// In en, this message translates to:
  /// **'MONTHLY INSTALLMENT'**
  String get monthlyInstallment;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'NEXT'**
  String get next;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'BACK'**
  String get back;

  /// No description provided for @lender.
  ///
  /// In en, this message translates to:
  /// **'LENDER'**
  String get lender;

  /// No description provided for @rate.
  ///
  /// In en, this message translates to:
  /// **'RATE'**
  String get rate;

  /// No description provided for @change.
  ///
  /// In en, this message translates to:
  /// **'CHANGE'**
  String get change;

  /// No description provided for @subscriptions.
  ///
  /// In en, this message translates to:
  /// **'SUBSCRIPTIONS'**
  String get subscriptions;

  /// No description provided for @noSubscriptions.
  ///
  /// In en, this message translates to:
  /// **'> NO ACTIVE SUBSCRIPTIONS'**
  String get noSubscriptions;

  /// No description provided for @subscriptionName.
  ///
  /// In en, this message translates to:
  /// **'NAME'**
  String get subscriptionName;

  /// No description provided for @subscriptionAmount.
  ///
  /// In en, this message translates to:
  /// **'AMOUNT'**
  String get subscriptionAmount;

  /// No description provided for @subscriptionPaymentAmount.
  ///
  /// In en, this message translates to:
  /// **'PAYMENT AMOUNT'**
  String get subscriptionPaymentAmount;

  /// No description provided for @subscriptionCycle.
  ///
  /// In en, this message translates to:
  /// **'BILLING CYCLE'**
  String get subscriptionCycle;

  /// No description provided for @subscriptionCoveragePeriod.
  ///
  /// In en, this message translates to:
  /// **'COVERAGE PERIOD'**
  String get subscriptionCoveragePeriod;

  /// No description provided for @subscriptionCategory.
  ///
  /// In en, this message translates to:
  /// **'CATEGORY'**
  String get subscriptionCategory;

  /// No description provided for @subscriptionPaymentDate.
  ///
  /// In en, this message translates to:
  /// **'PAYMENT DATE'**
  String get subscriptionPaymentDate;

  /// No description provided for @subscriptionNextBilling.
  ///
  /// In en, this message translates to:
  /// **'NEXT BILLING'**
  String get subscriptionNextBilling;

  /// No description provided for @subscriptionDaysLeft.
  ///
  /// In en, this message translates to:
  /// **'DAYS'**
  String get subscriptionDaysLeft;

  /// No description provided for @totalPerMonth.
  ///
  /// In en, this message translates to:
  /// **'TOTAL/MO'**
  String get totalPerMonth;

  /// No description provided for @totalPerYear.
  ///
  /// In en, this message translates to:
  /// **'TOTAL/YR'**
  String get totalPerYear;

  /// No description provided for @newSubscription.
  ///
  /// In en, this message translates to:
  /// **'+ SUBSCRIPTION'**
  String get newSubscription;

  /// No description provided for @editSubscription.
  ///
  /// In en, this message translates to:
  /// **'> EDIT SUBSCRIPTION'**
  String get editSubscription;

  /// No description provided for @addSubscription.
  ///
  /// In en, this message translates to:
  /// **'> NEW SUBSCRIPTION'**
  String get addSubscription;

  /// No description provided for @personal.
  ///
  /// In en, this message translates to:
  /// **'PERSONAL'**
  String get personal;

  /// No description provided for @business.
  ///
  /// In en, this message translates to:
  /// **'BUSINESS'**
  String get business;

  /// No description provided for @weekly.
  ///
  /// In en, this message translates to:
  /// **'WEEKLY'**
  String get weekly;

  /// No description provided for @monthly.
  ///
  /// In en, this message translates to:
  /// **'MONTHLY'**
  String get monthly;

  /// No description provided for @quarterly.
  ///
  /// In en, this message translates to:
  /// **'QUARTERLY'**
  String get quarterly;

  /// No description provided for @yearly.
  ///
  /// In en, this message translates to:
  /// **'YEARLY'**
  String get yearly;

  /// No description provided for @subscrPerMonth.
  ///
  /// In en, this message translates to:
  /// **'/ month'**
  String get subscrPerMonth;

  /// No description provided for @loans.
  ///
  /// In en, this message translates to:
  /// **'LOANS'**
  String get loans;

  /// No description provided for @activeCount.
  ///
  /// In en, this message translates to:
  /// **'{count} ACTIVE'**
  String activeCount(int count);

  /// No description provided for @repayLoan.
  ///
  /// In en, this message translates to:
  /// **'REPAY LOAN'**
  String get repayLoan;

  /// No description provided for @repaymentAmount.
  ///
  /// In en, this message translates to:
  /// **'REPAYMENT AMOUNT'**
  String get repaymentAmount;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'CANCEL'**
  String get cancel;

  /// No description provided for @paid.
  ///
  /// In en, this message translates to:
  /// **'✓ PAID'**
  String get paid;

  /// No description provided for @subscrPerYear.
  ///
  /// In en, this message translates to:
  /// **'/ year'**
  String get subscrPerYear;

  /// No description provided for @removeConfirm.
  ///
  /// In en, this message translates to:
  /// **'REMOVE?'**
  String get removeConfirm;

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'REMOVE'**
  String get remove;

  /// No description provided for @monthsProjected.
  ///
  /// In en, this message translates to:
  /// **'{count} months ahead'**
  String monthsProjected(int count);

  /// No description provided for @budgetPerMonth.
  ///
  /// In en, this message translates to:
  /// **'BUDGET/MO'**
  String get budgetPerMonth;

  /// No description provided for @breakdown.
  ///
  /// In en, this message translates to:
  /// **'BREAKDOWN'**
  String get breakdown;

  /// No description provided for @safetyFund.
  ///
  /// In en, this message translates to:
  /// **'SAFETY FUND'**
  String get safetyFund;

  /// No description provided for @safety.
  ///
  /// In en, this message translates to:
  /// **'SAFETY'**
  String get safety;

  /// No description provided for @deployableCapital.
  ///
  /// In en, this message translates to:
  /// **'Optional capital after protecting your runway'**
  String get deployableCapital;

  /// No description provided for @historyEntries.
  ///
  /// In en, this message translates to:
  /// **'HISTORY & ENTRIES'**
  String get historyEntries;

  /// No description provided for @addEntry.
  ///
  /// In en, this message translates to:
  /// **'+ ADD'**
  String get addEntry;

  /// No description provided for @willRemoveLoan.
  ///
  /// In en, this message translates to:
  /// **'WILL ALSO REMOVE FROM LIABILITIES'**
  String get willRemoveLoan;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'DELETE'**
  String get delete;

  /// No description provided for @planned.
  ///
  /// In en, this message translates to:
  /// **'PLANNED'**
  String get planned;

  /// No description provided for @whatIfAnalysis.
  ///
  /// In en, this message translates to:
  /// **'WHAT-IF ANALYSIS'**
  String get whatIfAnalysis;

  /// No description provided for @current.
  ///
  /// In en, this message translates to:
  /// **'CURRENT'**
  String get current;

  /// No description provided for @simulate.
  ///
  /// In en, this message translates to:
  /// **'Plan'**
  String get simulate;

  /// No description provided for @simHint.
  ///
  /// In en, this message translates to:
  /// **'OVERRIDE BURN RATE OR ADD INCOME TO SEE IMPACT ON RUNWAY'**
  String get simHint;

  /// No description provided for @simulation.
  ///
  /// In en, this message translates to:
  /// **'Scenario'**
  String get simulation;

  /// No description provided for @enterValuesToSim.
  ///
  /// In en, this message translates to:
  /// **'Enter values above to see the impact'**
  String get enterValuesToSim;

  /// No description provided for @perMonth.
  ///
  /// In en, this message translates to:
  /// **'/ MONTH'**
  String get perMonth;

  /// No description provided for @prefsBudget.
  ///
  /// In en, this message translates to:
  /// **'PREFERENCES & BUDGET'**
  String get prefsBudget;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'CLOSE'**
  String get close;

  /// No description provided for @monthlyBudget.
  ///
  /// In en, this message translates to:
  /// **'MONTHLY BUDGET'**
  String get monthlyBudget;

  /// No description provided for @rentFixed.
  ///
  /// In en, this message translates to:
  /// **'RENT / FIXED'**
  String get rentFixed;

  /// No description provided for @livingExpenses.
  ///
  /// In en, this message translates to:
  /// **'LIVING EXPENSES'**
  String get livingExpenses;

  /// No description provided for @subtotal.
  ///
  /// In en, this message translates to:
  /// **'SUBTOTAL'**
  String get subtotal;

  /// Unused part of a monthly budget, e.g. $ 29,790 left
  ///
  /// In en, this message translates to:
  /// **'{amount} left'**
  String budgetLeft(String amount);

  /// Spending above a monthly budget, e.g. $ 1,500 over budget
  ///
  /// In en, this message translates to:
  /// **'{amount} over budget'**
  String budgetOver(String amount);

  /// What is left of the living budget per remaining day of the month
  ///
  /// In en, this message translates to:
  /// **'{days, plural, =1{{amount} left for today} other{{amount} a day for {days} days}}'**
  String dailyAllowance(String amount, int days);

  /// No description provided for @noLivingExpensesThisMonth.
  ///
  /// In en, this message translates to:
  /// **'No living expenses logged this month'**
  String get noLivingExpensesThisMonth;

  /// No description provided for @totalBudgetPerMonth.
  ///
  /// In en, this message translates to:
  /// **'TOTAL BUDGET/MO'**
  String get totalBudgetPerMonth;

  /// No description provided for @setBudget.
  ///
  /// In en, this message translates to:
  /// **'SET BUDGET'**
  String get setBudget;

  /// No description provided for @rentFixedCosts.
  ///
  /// In en, this message translates to:
  /// **'RENT / FIXED COSTS'**
  String get rentFixedCosts;

  /// No description provided for @subscrDebtAuto.
  ///
  /// In en, this message translates to:
  /// **'SUBSCRIPTIONS + DEBT ADDED AUTOMATICALLY'**
  String get subscrDebtAuto;

  /// No description provided for @futureAssumptions.
  ///
  /// In en, this message translates to:
  /// **'Forecast'**
  String get futureAssumptions;

  /// No description provided for @expectedInflow.
  ///
  /// In en, this message translates to:
  /// **'Expected inflow'**
  String get expectedInflow;

  /// No description provided for @expectedBurn.
  ///
  /// In en, this message translates to:
  /// **'Expected burn'**
  String get expectedBurn;

  /// No description provided for @notSet.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get notSet;

  /// No description provided for @usingCurrentBurn.
  ///
  /// In en, this message translates to:
  /// **'Using current burn'**
  String get usingCurrentBurn;

  /// No description provided for @assumptionsProjectionOnly.
  ///
  /// In en, this message translates to:
  /// **'Assumptions affect future projections only. They do not create transactions.'**
  String get assumptionsProjectionOnly;

  /// No description provided for @setAssumptions.
  ///
  /// In en, this message translates to:
  /// **'SET FORECAST'**
  String get setAssumptions;

  /// No description provided for @expectedMonthlyInflow.
  ///
  /// In en, this message translates to:
  /// **'Expected monthly inflow'**
  String get expectedMonthlyInflow;

  /// No description provided for @expectedMonthlyBurn.
  ///
  /// In en, this message translates to:
  /// **'Expected monthly burn'**
  String get expectedMonthlyBurn;

  /// No description provided for @useCurrentBurn.
  ///
  /// In en, this message translates to:
  /// **'Use current burn'**
  String get useCurrentBurn;

  /// No description provided for @futureInflowHint.
  ///
  /// In en, this message translates to:
  /// **'Any recurring or expected inflow — retainers, contracts, creator income, dividends.'**
  String get futureInflowHint;

  /// No description provided for @runwayGoal.
  ///
  /// In en, this message translates to:
  /// **'Runway goal'**
  String get runwayGoal;

  /// No description provided for @goal.
  ///
  /// In en, this message translates to:
  /// **'Goal'**
  String get goal;

  /// No description provided for @none.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get none;

  /// No description provided for @target.
  ///
  /// In en, this message translates to:
  /// **'Target'**
  String get target;

  /// No description provided for @optional.
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get optional;

  /// No description provided for @monthsValue.
  ///
  /// In en, this message translates to:
  /// **'{count} months'**
  String monthsValue(int count);

  /// No description provided for @goalsContextHint.
  ///
  /// In en, this message translates to:
  /// **'Goals add context to your runway. They are not a score.'**
  String get goalsContextHint;

  /// No description provided for @setGoal.
  ///
  /// In en, this message translates to:
  /// **'SET GOAL'**
  String get setGoal;

  /// No description provided for @goalName.
  ///
  /// In en, this message translates to:
  /// **'Goal name'**
  String get goalName;

  /// No description provided for @targetMonths.
  ///
  /// In en, this message translates to:
  /// **'Target months'**
  String get targetMonths;

  /// No description provided for @display.
  ///
  /// In en, this message translates to:
  /// **'DISPLAY'**
  String get display;

  /// No description provided for @glassEffect.
  ///
  /// In en, this message translates to:
  /// **'GLASS EFFECT'**
  String get glassEffect;

  /// No description provided for @glassEffectHint.
  ///
  /// In en, this message translates to:
  /// **'GPU INTENSIVE — DISABLE ON OLDER DEVICES'**
  String get glassEffectHint;

  /// No description provided for @runwayBrand.
  ///
  /// In en, this message translates to:
  /// **'RUNWAY'**
  String get runwayBrand;

  /// No description provided for @bootRunwayCheck.
  ///
  /// In en, this message translates to:
  /// **'Checking your runway...'**
  String get bootRunwayCheck;

  /// No description provided for @bootIncomeStopped.
  ///
  /// In en, this message translates to:
  /// **'Looking at what changes if income pauses...'**
  String get bootIncomeStopped;

  /// No description provided for @bootCountingCashDays.
  ///
  /// In en, this message translates to:
  /// **'Estimating your breathing room...'**
  String get bootCountingCashDays;

  /// No description provided for @bootRemovingComfortFilter.
  ///
  /// In en, this message translates to:
  /// **'Separating essentials from noise...'**
  String get bootRemovingComfortFilter;

  /// No description provided for @bootRealityCheckReady.
  ///
  /// In en, this message translates to:
  /// **'Your financial picture is ready.'**
  String get bootRealityCheckReady;

  /// No description provided for @ifIncomeStoppedToday.
  ///
  /// In en, this message translates to:
  /// **'If inflow stopped today'**
  String get ifIncomeStoppedToday;

  /// No description provided for @ifIncomePausedToday.
  ///
  /// In en, this message translates to:
  /// **'If income paused today'**
  String get ifIncomePausedToday;

  /// No description provided for @monthSingular.
  ///
  /// In en, this message translates to:
  /// **'month'**
  String get monthSingular;

  /// No description provided for @monthPlural.
  ///
  /// In en, this message translates to:
  /// **'months'**
  String get monthPlural;

  /// No description provided for @sustainableWithExpectedInflow.
  ///
  /// In en, this message translates to:
  /// **'Sustainable with your expected inflow'**
  String get sustainableWithExpectedInflow;

  /// No description provided for @shortByPerMonth.
  ///
  /// In en, this message translates to:
  /// **'Short by {amount} / month'**
  String shortByPerMonth(String amount);

  /// No description provided for @goalTargetProgress.
  ///
  /// In en, this message translates to:
  /// **'{months} month target. Progress toward your goal, not a score.'**
  String goalTargetProgress(int months);

  /// No description provided for @monthlyBurn.
  ///
  /// In en, this message translates to:
  /// **'Monthly burn'**
  String get monthlyBurn;

  /// No description provided for @availableCash.
  ///
  /// In en, this message translates to:
  /// **'Available cash'**
  String get availableCash;

  /// No description provided for @historicalBurn.
  ///
  /// In en, this message translates to:
  /// **'Avg burn'**
  String get historicalBurn;

  /// No description provided for @notEnoughHistory.
  ///
  /// In en, this message translates to:
  /// **'Not enough history'**
  String get notEnoughHistory;

  /// No description provided for @projectionSource.
  ///
  /// In en, this message translates to:
  /// **'Projection source'**
  String get projectionSource;

  /// No description provided for @usingAssumptions.
  ///
  /// In en, this message translates to:
  /// **'Using assumptions'**
  String get usingAssumptions;

  /// No description provided for @fixedPressure.
  ///
  /// In en, this message translates to:
  /// **'Fixed costs'**
  String get fixedPressure;

  /// No description provided for @actualBurn.
  ///
  /// In en, this message translates to:
  /// **'Actual burn'**
  String get actualBurn;

  /// No description provided for @actualBurnHigh.
  ///
  /// In en, this message translates to:
  /// **'Actual burn ▲'**
  String get actualBurnHigh;

  /// No description provided for @plannedEssentials.
  ///
  /// In en, this message translates to:
  /// **'Planned essentials'**
  String get plannedEssentials;

  /// No description provided for @recurringCosts.
  ///
  /// In en, this message translates to:
  /// **'Recurring costs'**
  String get recurringCosts;

  /// No description provided for @debtCommitments.
  ///
  /// In en, this message translates to:
  /// **'Loan payments'**
  String get debtCommitments;

  /// No description provided for @daysUpper.
  ///
  /// In en, this message translates to:
  /// **'DAYS'**
  String get daysUpper;

  /// No description provided for @yourRunway.
  ///
  /// In en, this message translates to:
  /// **'Your runway'**
  String get yourRunway;

  /// No description provided for @loseIncome.
  ///
  /// In en, this message translates to:
  /// **'Inflow stops'**
  String get loseIncome;

  /// No description provided for @higherExpenses.
  ///
  /// In en, this message translates to:
  /// **'Higher expenses'**
  String get higherExpenses;

  /// No description provided for @incomeSetToZero.
  ///
  /// In en, this message translates to:
  /// **'Inflow set to 0'**
  String get incomeSetToZero;

  /// No description provided for @deltaDays.
  ///
  /// In en, this message translates to:
  /// **'{days} days'**
  String deltaDays(int days);

  /// No description provided for @shareSafe.
  ///
  /// In en, this message translates to:
  /// **'SHARE SAFE'**
  String get shareSafe;

  /// No description provided for @shareSafeHint.
  ///
  /// In en, this message translates to:
  /// **'No savings. No expenses. Just your runway.'**
  String get shareSafeHint;

  /// No description provided for @preparing.
  ///
  /// In en, this message translates to:
  /// **'PREPARING...'**
  String get preparing;

  /// No description provided for @shareImage.
  ///
  /// In en, this message translates to:
  /// **'SHARE IMAGE'**
  String get shareImage;

  /// No description provided for @shareAsText.
  ///
  /// In en, this message translates to:
  /// **'SHARE AS TEXT'**
  String get shareAsText;

  /// No description provided for @goalReached.
  ///
  /// In en, this message translates to:
  /// **'Goal reached!'**
  String get goalReached;

  /// No description provided for @monthsToGoal.
  ///
  /// In en, this message translates to:
  /// **'{count} months to go'**
  String monthsToGoal(int count);

  /// No description provided for @thisMonth.
  ///
  /// In en, this message translates to:
  /// **'THIS MONTH'**
  String get thisMonth;

  /// No description provided for @cashIn.
  ///
  /// In en, this message translates to:
  /// **'IN'**
  String get cashIn;

  /// No description provided for @cashOut.
  ///
  /// In en, this message translates to:
  /// **'OUT'**
  String get cashOut;

  /// No description provided for @netLabel.
  ///
  /// In en, this message translates to:
  /// **'NET'**
  String get netLabel;

  /// No description provided for @noActivityThisMonth.
  ///
  /// In en, this message translates to:
  /// **'No activity yet this month'**
  String get noActivityThisMonth;

  /// Link on the paywall to Apple's standard end user license agreement
  ///
  /// In en, this message translates to:
  /// **'Terms of Use'**
  String get paywallTermsOfUse;

  /// Link on the paywall to the Runway privacy policy
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get paywallPrivacyPolicy;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'en',
    'es',
    'fr',
    'it',
    'ja',
    'zh',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when language+country codes are specified.
  switch (locale.languageCode) {
    case 'zh':
      {
        switch (locale.countryCode) {
          case 'TW':
            return AppLocalizationsZhTw();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'it':
      return AppLocalizationsIt();
    case 'ja':
      return AppLocalizationsJa();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
