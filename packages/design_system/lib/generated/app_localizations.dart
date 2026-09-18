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
  /// **'Rent + living / month'**
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
  /// **'LOAN PAYMENT'**
  String get typeRepay;

  /// No description provided for @typeOpening.
  ///
  /// In en, this message translates to:
  /// **'OPENING'**
  String get typeOpening;

  /// No description provided for @typeSubscription.
  ///
  /// In en, this message translates to:
  /// **'SUBSCRIPTION'**
  String get typeSubscription;

  /// Asks whether a subscription charge was actually paid
  ///
  /// In en, this message translates to:
  /// **'Did you pay {amount} for {name} on {date}?'**
  String subscriptionPaidQuestion(String amount, String name, String date);

  /// How many subscription charges are waiting to be confirmed, and their total
  ///
  /// In en, this message translates to:
  /// **'{count} subscription charges due — {amount}'**
  String subscriptionChargesDue(int count, String amount);

  /// No description provided for @subscriptionConfirmAll.
  ///
  /// In en, this message translates to:
  /// **'Confirm all'**
  String get subscriptionConfirmAll;

  /// No description provided for @subscriptionReviewEach.
  ///
  /// In en, this message translates to:
  /// **'Review each'**
  String get subscriptionReviewEach;

  /// No description provided for @subscriptionPaidYes.
  ///
  /// In en, this message translates to:
  /// **'Yes, log it'**
  String get subscriptionPaidYes;

  /// No description provided for @subscriptionChargeFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t record that. Check the amount on the subscription.'**
  String get subscriptionChargeFailed;

  /// No description provided for @subscriptionSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t save that subscription. Nothing was added.'**
  String get subscriptionSaveFailed;

  /// No description provided for @subscriptionPaidNo.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get subscriptionPaidNo;

  /// No description provided for @subscriptionWhatHappened.
  ///
  /// In en, this message translates to:
  /// **'What happened?'**
  String get subscriptionWhatHappened;

  /// No description provided for @subscriptionReasonCancelled.
  ///
  /// In en, this message translates to:
  /// **'I cancelled it'**
  String get subscriptionReasonCancelled;

  /// No description provided for @subscriptionReasonPriceChanged.
  ///
  /// In en, this message translates to:
  /// **'The price changed'**
  String get subscriptionReasonPriceChanged;

  /// No description provided for @subscriptionReasonNotPaid.
  ///
  /// In en, this message translates to:
  /// **'I didn\'t pay it'**
  String get subscriptionReasonNotPaid;

  /// No description provided for @deleteSubscription.
  ///
  /// In en, this message translates to:
  /// **'Delete subscription'**
  String get deleteSubscription;

  /// No description provided for @deleteSubscriptionKeepsEntries.
  ///
  /// In en, this message translates to:
  /// **'Stops future entries. The payments already logged are kept.'**
  String get deleteSubscriptionKeepsEntries;

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

  /// No description provided for @newLoan.
  ///
  /// In en, this message translates to:
  /// **'+ LOAN'**
  String get newLoan;

  /// No description provided for @spendOnWhat.
  ///
  /// In en, this message translates to:
  /// **'WHAT DID YOU SPEND ON?'**
  String get spendOnWhat;

  /// No description provided for @presetCoffee.
  ///
  /// In en, this message translates to:
  /// **'COFFEE'**
  String get presetCoffee;

  /// No description provided for @presetCoffeeNote.
  ///
  /// In en, this message translates to:
  /// **'Coffee'**
  String get presetCoffeeNote;

  /// No description provided for @presetLunch.
  ///
  /// In en, this message translates to:
  /// **'LUNCH'**
  String get presetLunch;

  /// No description provided for @presetLunchNote.
  ///
  /// In en, this message translates to:
  /// **'Lunch'**
  String get presetLunchNote;

  /// No description provided for @presetDinner.
  ///
  /// In en, this message translates to:
  /// **'DINNER'**
  String get presetDinner;

  /// No description provided for @presetDinnerNote.
  ///
  /// In en, this message translates to:
  /// **'Dinner'**
  String get presetDinnerNote;

  /// No description provided for @presetTransport.
  ///
  /// In en, this message translates to:
  /// **'TRANSPORT'**
  String get presetTransport;

  /// No description provided for @presetTransportNote.
  ///
  /// In en, this message translates to:
  /// **'Transport'**
  String get presetTransportNote;

  /// No description provided for @presetGroceries.
  ///
  /// In en, this message translates to:
  /// **'GROCERIES'**
  String get presetGroceries;

  /// No description provided for @presetGroceriesNote.
  ///
  /// In en, this message translates to:
  /// **'Groceries'**
  String get presetGroceriesNote;

  /// No description provided for @presetSomethingElse.
  ///
  /// In en, this message translates to:
  /// **'SOMETHING ELSE'**
  String get presetSomethingElse;

  /// No description provided for @freeEntriesUsed.
  ///
  /// In en, this message translates to:
  /// **'{used} of {free} free entries used'**
  String freeEntriesUsed(int used, int free);

  /// No description provided for @freeSimulationsUsed.
  ///
  /// In en, this message translates to:
  /// **'{used} of {free} free simulations used'**
  String freeSimulationsUsed(int used, int free);

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

  /// Settings card title for erasing all local data
  ///
  /// In en, this message translates to:
  /// **'Your data'**
  String get dataSection;

  /// Explains what Delete all data erases
  ///
  /// In en, this message translates to:
  /// **'Erase every entry, loan, subscription and setting from this device. Runway Pro stays unlocked.'**
  String get deleteAllDataBody;

  /// Button that opens the delete-all-data confirmation
  ///
  /// In en, this message translates to:
  /// **'DELETE ALL DATA'**
  String get deleteAllDataButton;

  /// Title of the delete-all-data confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Delete everything?'**
  String get deleteAllDataConfirmTitle;

  /// Warning that deletion is permanent
  ///
  /// In en, this message translates to:
  /// **'Your data is erased from this device and cannot be recovered. Runway starts again from the beginning.'**
  String get deleteAllDataConfirmBody;

  /// Confirms permanent deletion of all data
  ///
  /// In en, this message translates to:
  /// **'DELETE EVERYTHING'**
  String get deleteAllDataConfirmAction;

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
  /// **'CHANGE RENT + LIVING OR ADD INCOME TO SEE THE IMPACT ON RUNWAY'**
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
  /// **'Expected income'**
  String get expectedInflow;

  /// No description provided for @expectedBurn.
  ///
  /// In en, this message translates to:
  /// **'Expected costs'**
  String get expectedBurn;

  /// No description provided for @notSet.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get notSet;

  /// No description provided for @settingsFailedToLoad.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load these settings. Editing is off so nothing overwrites them.'**
  String get settingsFailedToLoad;

  /// No description provided for @usingCurrentBurn.
  ///
  /// In en, this message translates to:
  /// **'Using current costs'**
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
  /// **'Expected monthly income'**
  String get expectedMonthlyInflow;

  /// No description provided for @expectedMonthlyBurn.
  ///
  /// In en, this message translates to:
  /// **'Expected monthly costs'**
  String get expectedMonthlyBurn;

  /// No description provided for @useCurrentBurn.
  ///
  /// In en, this message translates to:
  /// **'Use current costs'**
  String get useCurrentBurn;

  /// No description provided for @futureInflowHint.
  ///
  /// In en, this message translates to:
  /// **'Any recurring or expected income, such as retainers, contracts, creator income or dividends.'**
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

  /// No description provided for @runwayBrand.
  ///
  /// In en, this message translates to:
  /// **'RUNWAY'**
  String get runwayBrand;

  /// No description provided for @runwayBasisBudget.
  ///
  /// In en, this message translates to:
  /// **'On your budget, if income paused today'**
  String get runwayBasisBudget;

  /// No description provided for @runwayBasisSpending.
  ///
  /// In en, this message translates to:
  /// **'On your spending, if income paused today'**
  String get runwayBasisSpending;

  /// No description provided for @runwayBasisAssumption.
  ///
  /// In en, this message translates to:
  /// **'On your cost assumption, if income paused today'**
  String get runwayBasisAssumption;

  /// No description provided for @computedCost.
  ///
  /// In en, this message translates to:
  /// **'Computed from your budget and log: {amount}'**
  String computedCost(String amount);

  /// No description provided for @runwayNeedsCosts.
  ///
  /// In en, this message translates to:
  /// **'Set your monthly costs to see your runway'**
  String get runwayNeedsCosts;

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
  /// **'Sustainable with your expected income'**
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

  /// No description provided for @availableCash.
  ///
  /// In en, this message translates to:
  /// **'Available cash'**
  String get availableCash;

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

  /// No description provided for @higherExpenses.
  ///
  /// In en, this message translates to:
  /// **'Higher expenses'**
  String get higherExpenses;

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

  /// No description provided for @onboardingSkip.
  ///
  /// In en, this message translates to:
  /// **'SKIP'**
  String get onboardingSkip;

  /// No description provided for @onboardingWelcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Know your\nrunway.'**
  String get onboardingWelcomeTitle;

  /// No description provided for @onboardingWelcomeBody.
  ///
  /// In en, this message translates to:
  /// **'One number shows where you stand.\nHow many months does your money cover?'**
  String get onboardingWelcomeBody;

  /// No description provided for @onboardingGetStarted.
  ///
  /// In en, this message translates to:
  /// **'GET STARTED'**
  String get onboardingGetStarted;

  /// No description provided for @onboardingPrivacyTitle.
  ///
  /// In en, this message translates to:
  /// **'Your data,\nyour device.'**
  String get onboardingPrivacyTitle;

  /// No description provided for @onboardingPrivacyBody.
  ///
  /// In en, this message translates to:
  /// **'Everything is encrypted on your device.\nWe cannot read your financial data.\nEven we don\'t know your numbers.'**
  String get onboardingPrivacyBody;

  /// No description provided for @onboardingPrivacyEncrypted.
  ///
  /// In en, this message translates to:
  /// **'Encrypted on device'**
  String get onboardingPrivacyEncrypted;

  /// No description provided for @onboardingPrivacyOnDevice.
  ///
  /// In en, this message translates to:
  /// **'Numbers stay on your device'**
  String get onboardingPrivacyOnDevice;

  /// No description provided for @onboardingPrivacyHidden.
  ///
  /// In en, this message translates to:
  /// **'Hidden when you switch apps'**
  String get onboardingPrivacyHidden;

  /// No description provided for @onboardingPrivacyDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete anytime, instantly'**
  String get onboardingPrivacyDelete;

  /// No description provided for @onboardingIUnderstand.
  ///
  /// In en, this message translates to:
  /// **'I UNDERSTAND'**
  String get onboardingIUnderstand;

  /// No description provided for @onboardingFirstActionTitle.
  ///
  /// In en, this message translates to:
  /// **'Ready to find\nyour runway?'**
  String get onboardingFirstActionTitle;

  /// No description provided for @onboardingFirstActionBody.
  ///
  /// In en, this message translates to:
  /// **'Start by adding your current cash balance.\nThat\'s all you need to see your number.'**
  String get onboardingFirstActionBody;

  /// No description provided for @onboardingAddMyBalance.
  ///
  /// In en, this message translates to:
  /// **'ADD MY BALANCE'**
  String get onboardingAddMyBalance;

  /// No description provided for @paywallUnlock.
  ///
  /// In en, this message translates to:
  /// **'UNLOCK RUNWAY PRO'**
  String get paywallUnlock;

  /// No description provided for @paywallLoadingPrice.
  ///
  /// In en, this message translates to:
  /// **'Loading price...'**
  String get paywallLoadingPrice;

  /// No description provided for @paywallStoreUnreachable.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t reach the store. Check your connection and try again.'**
  String get paywallStoreUnreachable;

  /// No description provided for @paywallOneTimePurchase.
  ///
  /// In en, this message translates to:
  /// **'{price} · One-time purchase'**
  String paywallOneTimePurchase(String price);

  /// No description provided for @paywallUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Pro isn\'t available right now. Please try again later.'**
  String get paywallUnavailable;

  /// No description provided for @paywallRestore.
  ///
  /// In en, this message translates to:
  /// **'Restore purchase'**
  String get paywallRestore;

  /// No description provided for @paywallMaybeLater.
  ///
  /// In en, this message translates to:
  /// **'Maybe later'**
  String get paywallMaybeLater;

  /// No description provided for @paywallPurchaseFailed.
  ///
  /// In en, this message translates to:
  /// **'Purchase failed. Please try again.'**
  String get paywallPurchaseFailed;

  /// No description provided for @paywallSomethingWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get paywallSomethingWrong;

  /// No description provided for @paywallNoPreviousPurchase.
  ///
  /// In en, this message translates to:
  /// **'No previous purchase found.'**
  String get paywallNoPreviousPurchase;

  /// No description provided for @paywallRestoreFailed.
  ///
  /// In en, this message translates to:
  /// **'Restore failed. Please try again.'**
  String get paywallRestoreFailed;

  /// No description provided for @paywallTitleEntries.
  ///
  /// In en, this message translates to:
  /// **'You\'ve logged your {count} free entries.\nUnlimited entries is Pro.'**
  String paywallTitleEntries(int count);

  /// No description provided for @paywallTitleSimulations.
  ///
  /// In en, this message translates to:
  /// **'You\'ve run your {count} free simulations.\nUnlimited simulations is Pro.'**
  String paywallTitleSimulations(int count);

  /// No description provided for @paywallTitleDefault.
  ///
  /// In en, this message translates to:
  /// **'Unlock Runway Pro.'**
  String get paywallTitleDefault;

  /// No description provided for @paywallFeatureEntries.
  ///
  /// In en, this message translates to:
  /// **'Unlimited entries'**
  String get paywallFeatureEntries;

  /// No description provided for @paywallFeatureSimulations.
  ///
  /// In en, this message translates to:
  /// **'Unlimited scenario simulations'**
  String get paywallFeatureSimulations;

  /// No description provided for @stepBalanceShort.
  ///
  /// In en, this message translates to:
  /// **'Cash balance'**
  String get stepBalanceShort;

  /// No description provided for @stepBudgetShort.
  ///
  /// In en, this message translates to:
  /// **'Budget'**
  String get stepBudgetShort;

  /// No description provided for @stepExpenseShort.
  ///
  /// In en, this message translates to:
  /// **'First expense'**
  String get stepExpenseShort;

  /// No description provided for @stepSimShort.
  ///
  /// In en, this message translates to:
  /// **'Simulator'**
  String get stepSimShort;

  /// No description provided for @stepsDone.
  ///
  /// In en, this message translates to:
  /// **'Done: {steps}'**
  String stepsDone(String steps);

  /// No description provided for @optionalBadge.
  ///
  /// In en, this message translates to:
  /// **'OPTIONAL'**
  String get optionalBadge;

  /// No description provided for @fixedCostsUnchanged.
  ///
  /// In en, this message translates to:
  /// **'Fixed costs unchanged: {amount}'**
  String fixedCostsUnchanged(String amount);

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
