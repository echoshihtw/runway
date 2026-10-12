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
  ];

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

  /// Under Monthly costs: the budget is only part of it
  ///
  /// In en, this message translates to:
  /// **'Includes subscriptions and loan payments'**
  String get costsIncludeCommitments;

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

  /// Total outstanding loan principal, beside CASH on the runway card
  ///
  /// In en, this message translates to:
  /// **'Owed'**
  String get owed;

  /// The run-out date, under the runway number it restates
  ///
  /// In en, this message translates to:
  /// **'Runs out {date}'**
  String runsOut(String date);

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

  /// No description provided for @config.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get config;

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

  /// No description provided for @noEntries.
  ///
  /// In en, this message translates to:
  /// **'Start with your cash balance'**
  String get noEntries;

  /// No description provided for @newLogEntry.
  ///
  /// In en, this message translates to:
  /// **'New log entry'**
  String get newLogEntry;

  /// No description provided for @modifyEntry.
  ///
  /// In en, this message translates to:
  /// **'MODIFY ENTRY'**
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
  /// **'Delete entry?'**
  String get purgeEntry;

  /// No description provided for @scenarioSimulator.
  ///
  /// In en, this message translates to:
  /// **'Scenario planning'**
  String get scenarioSimulator;

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

  /// No description provided for @simRunway.
  ///
  /// In en, this message translates to:
  /// **'Projected runway'**
  String get simRunway;

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

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @currency.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get currency;

  /// No description provided for @currencySymbolOnly.
  ///
  /// In en, this message translates to:
  /// **'Changes the display symbol only. Your amounts are not converted.'**
  String get currencySymbolOnly;

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
  /// **'Overview'**
  String get navHud;

  /// No description provided for @navLog.
  ///
  /// In en, this message translates to:
  /// **'Log'**
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
  /// **'{count} subscription charges due: {amount}'**
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

  /// No description provided for @loanSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t save that loan. Nothing was added.'**
  String get loanSaveFailed;

  /// No description provided for @repaymentSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t record that repayment. Nothing was added.'**
  String get repaymentSaveFailed;

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
  /// **'Liabilities'**
  String get liabilities;

  /// No description provided for @noActiveLoans.
  ///
  /// In en, this message translates to:
  /// **'NO ACTIVE LOANS'**
  String get noActiveLoans;

  /// No description provided for @newLoan.
  ///
  /// In en, this message translates to:
  /// **'+ LOAN'**
  String get newLoan;

  /// No description provided for @spendOnWhat.
  ///
  /// In en, this message translates to:
  /// **'What was it for?'**
  String get spendOnWhat;

  /// Under the spend tiles: the other direction has a door too
  ///
  /// In en, this message translates to:
  /// **'Money came in instead?'**
  String get moneyCameInInstead;

  /// The action beside it; opens the form on income
  ///
  /// In en, this message translates to:
  /// **'Log income'**
  String get logIncome;

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

  /// No description provided for @stillPaying.
  ///
  /// In en, this message translates to:
  /// **'You have repaid what you borrowed. Payments run to the end of the term.'**
  String get stillPaying;

  /// No description provided for @markSettled.
  ///
  /// In en, this message translates to:
  /// **'Mark as settled'**
  String get markSettled;

  /// No description provided for @markSettledExplain.
  ///
  /// In en, this message translates to:
  /// **'The monthly payment stops counting and the loan leaves this list for good. Entries are kept.'**
  String get markSettledExplain;

  /// No description provided for @repay.
  ///
  /// In en, this message translates to:
  /// **'REPAY'**
  String get repay;

  /// No description provided for @extra.
  ///
  /// In en, this message translates to:
  /// **'EXTRA'**
  String get extra;

  /// No description provided for @loanWizardTitle.
  ///
  /// In en, this message translates to:
  /// **'Loan wizard'**
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
  /// **'Subscriptions'**
  String get subscriptions;

  /// No description provided for @noSubscriptions.
  ///
  /// In en, this message translates to:
  /// **'NO ACTIVE SUBSCRIPTIONS'**
  String get noSubscriptions;

  /// No description provided for @subscriptionName.
  ///
  /// In en, this message translates to:
  /// **'NAME'**
  String get subscriptionName;

  /// No description provided for @subscriptionPaymentAmount.
  ///
  /// In en, this message translates to:
  /// **'PAYMENT AMOUNT'**
  String get subscriptionPaymentAmount;

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

  /// No description provided for @totalPerMonth.
  ///
  /// In en, this message translates to:
  /// **'TOTAL/MO'**
  String get totalPerMonth;

  /// No description provided for @newSubscription.
  ///
  /// In en, this message translates to:
  /// **'+ SUBSCRIPTION'**
  String get newSubscription;

  /// No description provided for @editSubscription.
  ///
  /// In en, this message translates to:
  /// **'Edit subscription'**
  String get editSubscription;

  /// No description provided for @addSubscription.
  ///
  /// In en, this message translates to:
  /// **'New subscription'**
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

  /// No description provided for @repayLoan.
  ///
  /// In en, this message translates to:
  /// **'Repay loan'**
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

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'REMOVE'**
  String get remove;

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
  /// **'Current'**
  String get current;

  /// No description provided for @simulate.
  ///
  /// In en, this message translates to:
  /// **'Plan'**
  String get simulate;

  /// No description provided for @simHint.
  ///
  /// In en, this message translates to:
  /// **'Change rent + living or add income to see the impact on runway'**
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

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'CLOSE'**
  String get close;

  /// No description provided for @monthlyBudget.
  ///
  /// In en, this message translates to:
  /// **'Monthly budget'**
  String get monthlyBudget;

  /// No description provided for @rentFixed.
  ///
  /// In en, this message translates to:
  /// **'RENT / FIXED'**
  String get rentFixed;

  /// No description provided for @livingExpenses.
  ///
  /// In en, this message translates to:
  /// **'Living expenses'**
  String get livingExpenses;

  /// No description provided for @budgetRuleHint.
  ///
  /// In en, this message translates to:
  /// **'Spending uses up its budget. Only going over adds cost.'**
  String get budgetRuleHint;

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

  /// A fixed cost logged in full this month
  ///
  /// In en, this message translates to:
  /// **'{amount} paid'**
  String budgetPaid(String amount);

  /// Under the remainder: the working behind it
  ///
  /// In en, this message translates to:
  /// **'{spent} of {budget}'**
  String spentOfBudget(String spent, String budget);

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

  /// No description provided for @everyMonth.
  ///
  /// In en, this message translates to:
  /// **'Every month'**
  String get everyMonth;

  /// No description provided for @monthlySurplus.
  ///
  /// In en, this message translates to:
  /// **'Surplus'**
  String get monthlySurplus;

  /// No description provided for @monthlyDeficit.
  ///
  /// In en, this message translates to:
  /// **'Deficit'**
  String get monthlyDeficit;

  /// No description provided for @setExpectedIncome.
  ///
  /// In en, this message translates to:
  /// **'Set expected income'**
  String get setExpectedIncome;

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

  /// In the Forecast card: income is deliberately outside the runway
  ///
  /// In en, this message translates to:
  /// **'Income does not move the runway. The runway is what your cash covers if income stopped; this says whether the month adds to it.'**
  String get forecastDoesNotMoveRunway;

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
  /// **'Used instead of {amount}, computed from your budget and log'**
  String computedCost(String amount);

  /// No description provided for @runwayNeedsCosts.
  ///
  /// In en, this message translates to:
  /// **'Set your monthly costs to see your runway'**
  String get runwayNeedsCosts;

  /// No description provided for @runwayNeedsBalance.
  ///
  /// In en, this message translates to:
  /// **'Add your balance to see your runway'**
  String get runwayNeedsBalance;

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

  /// No description provided for @deltaDays.
  ///
  /// In en, this message translates to:
  /// **'{days} days'**
  String deltaDays(int days);

  /// No description provided for @goalReached.
  ///
  /// In en, this message translates to:
  /// **'Goal reached'**
  String get goalReached;

  /// No description provided for @monthsToGoal.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 month of cover to build} other{{count} months of cover to build}}'**
  String monthsToGoal(int count);

  /// No description provided for @goalCashTarget.
  ///
  /// In en, this message translates to:
  /// **'Target cash'**
  String get goalCashTarget;

  /// Under Target cash: the arithmetic behind a figure nobody typed
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 month × {cost} a month} other{{count} months × {cost} a month}}'**
  String goalCashTargetFrom(int count, String cost);

  /// No description provided for @goalCashToGo.
  ///
  /// In en, this message translates to:
  /// **'Still to go'**
  String get goalCashToGo;

  /// No description provided for @thisMonth.
  ///
  /// In en, this message translates to:
  /// **'This month'**
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
  /// **'Stop guessing how long your money lasts.'**
  String get onboardingWelcomeTitle;

  /// No description provided for @onboardingWelcomeBody.
  ///
  /// In en, this message translates to:
  /// **'No account. No bank connection.'**
  String get onboardingWelcomeBody;

  /// No description provided for @onboardingPreviewCaption.
  ///
  /// In en, this message translates to:
  /// **'Enter your cash. That is the whole setup.'**
  String get onboardingPreviewCaption;

  /// No description provided for @onboardingPrivacyEncrypted.
  ///
  /// In en, this message translates to:
  /// **'Encrypted on device'**
  String get onboardingPrivacyEncrypted;

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
  /// **'{price} once. This app counts your subscriptions; it will not be one.'**
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

  /// Shown in settings when the owner has Runway Pro
  ///
  /// In en, this message translates to:
  /// **'Unlocked. Entries and simulations are unlimited.'**
  String get proUnlocked;

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
  /// **'You\'ve used your {count} free entries.\nPro is what keeps the number true.'**
  String paywallTitleEntries(int count);

  /// No description provided for @paywallTitleSimulations.
  ///
  /// In en, this message translates to:
  /// **'You\'ve run your {count} free simulations.\nPro is how you keep asking what if.'**
  String paywallTitleSimulations(int count);

  /// No description provided for @paywallTitleDefault.
  ///
  /// In en, this message translates to:
  /// **'Unlock Runway Pro.'**
  String get paywallTitleDefault;

  /// No description provided for @paywallFeatureEntries.
  ///
  /// In en, this message translates to:
  /// **'Log everything, so the number never drifts'**
  String get paywallFeatureEntries;

  /// No description provided for @paywallFeatureSimulations.
  ///
  /// In en, this message translates to:
  /// **'Ask what if as often as you like'**
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

  /// No description provided for @simNeedsBalance.
  ///
  /// In en, this message translates to:
  /// **'Add your opening balance first'**
  String get simNeedsBalance;

  /// No description provided for @simNeedsBalanceWhy.
  ///
  /// In en, this message translates to:
  /// **'A runway needs a starting balance to count down from.'**
  String get simNeedsBalanceWhy;

  /// No description provided for @addOpeningBalance.
  ///
  /// In en, this message translates to:
  /// **'ADD MY BALANCE'**
  String get addOpeningBalance;

  /// No description provided for @runSimulation.
  ///
  /// In en, this message translates to:
  /// **'RUN SIMULATION'**
  String get runSimulation;

  /// No description provided for @runwayUnlimitedHere.
  ///
  /// In en, this message translates to:
  /// **'Income covers costs in this plan'**
  String get runwayUnlimitedHere;

  /// No description provided for @runwayNoChange.
  ///
  /// In en, this message translates to:
  /// **'No change'**
  String get runwayNoChange;

  /// No description provided for @deltaDaysLonger.
  ///
  /// In en, this message translates to:
  /// **'{days, plural, =1{1 day longer} other{{days} days longer}}'**
  String deltaDaysLonger(int days);

  /// No description provided for @deltaDaysShorter.
  ///
  /// In en, this message translates to:
  /// **'{days, plural, =1{1 day shorter} other{{days} days shorter}}'**
  String deltaDaysShorter(int days);

  /// No description provided for @deltaMonthsLonger.
  ///
  /// In en, this message translates to:
  /// **'{months, plural, =1{1 month longer} other{{months} months longer}}'**
  String deltaMonthsLonger(int months);

  /// No description provided for @deltaMonthsShorter.
  ///
  /// In en, this message translates to:
  /// **'{months, plural, =1{1 month shorter} other{{months} months shorter}}'**
  String deltaMonthsShorter(int months);

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
