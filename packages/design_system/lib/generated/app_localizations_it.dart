// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get appTitle => 'Runway';

  @override
  String get hudTitle => 'Runway';

  @override
  String get sysOnline => 'SIS: ONLINE';

  @override
  String get lifeForce => 'PREPARAZIONE RUNWAY';

  @override
  String get statusLabel => 'STATO';

  @override
  String get pressureLabel => 'Costi mensili';

  @override
  String get metrics => 'METRICHE';

  @override
  String get cash => 'CONTANTI';

  @override
  String get loanPerMonth => 'DEBITO/MESE';

  @override
  String get runway => 'AUTONOMIA';

  @override
  String get runOut => 'ESAURIMENTO';

  @override
  String get cashTimeline => 'CRONOLOGIA';

  @override
  String get config => 'CONFIG';

  @override
  String get monthlyLoanPayment => 'PAGAMENTO MENSILE PRESTITO';

  @override
  String get tapToSet => 'TOCCA PER IMPOSTARE';

  @override
  String get edit => 'MODIFICA';

  @override
  String get save => 'SALVA';

  @override
  String get clear => 'CANCELLA';

  @override
  String get loanAffectsInfo =>
      '> PRESTITO/MESE INFLUISCE SUL RATIO DI PRESSIONE E INVESTIBILE';

  @override
  String get transactionLog => 'REGISTRO TRANSAZIONI';

  @override
  String get newEntry => '+ NUOVO';

  @override
  String get noEntries => 'No entries yet\nTap + ADD to log your first entry';

  @override
  String get newLogEntry => '> NUOVA VOCE';

  @override
  String get modifyEntry => '> MODIFICA VOCE';

  @override
  String get type => 'TIPO';

  @override
  String get date => 'DATA';

  @override
  String get calcMonth => 'CALC';

  @override
  String get amount => 'IMPORTO';

  @override
  String get noteOptional => 'NOTA (OPZIONALE)';

  @override
  String get confirm => 'CONFERMA';

  @override
  String get abort => 'ANNULLA';

  @override
  String get purgeEntry => '> ELIMINARE QUESTA VOCE?';

  @override
  String get scenarioSimulator => 'SIMULATORE DI SCENARI';

  @override
  String get overrideInputs => 'INPUT DI SOSTITUZIONE';

  @override
  String get burnRateOverride => 'SOSTITUZIONE SPESA';

  @override
  String get simulatedIncome => 'REDDITO SIMULATO/MESE';

  @override
  String get simResults => 'RISULTATI SIM';

  @override
  String get simRunway => 'AUTONOMIA SIM';

  @override
  String get simRunOut => 'ESAURIMENTO SIM';

  @override
  String get deltaVsActual => 'DELTA vs REALE';

  @override
  String get deltaRunway => 'DELTA AUTONOMIA';

  @override
  String get resetSim => 'REIMPOSTA SIM';

  @override
  String get months => 'MESI';

  @override
  String get stable => 'STABILE';

  @override
  String get caution => 'ATTENZIONE';

  @override
  String get critical => 'CRITICO';

  @override
  String get low => 'BASSO';

  @override
  String get moderate => 'MODERATO';

  @override
  String get highLoad => 'CARICO ELEVATO';

  @override
  String get language => 'LINGUA';

  @override
  String get currency => 'VALUTA';

  @override
  String get currencySymbolOnly =>
      'Modifica solo il simbolo — i tuoi importi non vengono convertiti.';

  @override
  String get daysShort => 'g';

  @override
  String get gettingStarted => 'INIZIA ORA';

  @override
  String stepsComplete(int completed, int total) {
    return '$completed di $total completati';
  }

  @override
  String get stepBalanceLabel => 'Aggiungi il tuo saldo';

  @override
  String get stepBalanceHint => 'Quanto hai adesso?';

  @override
  String get stepBudgetLabel => 'Imposta il tuo budget mensile';

  @override
  String get stepBudgetHint => 'Affitto + spese di vita';

  @override
  String get stepExpenseLabel => 'Registra la prima spesa';

  @override
  String get stepExpenseHint => 'Tieni traccia dove vanno i soldi';

  @override
  String get stepSimLabel => 'Prova il simulatore';

  @override
  String get stepSimHint => 'Cosa succede se tagli le spese?';

  @override
  String get loading => 'CARICAMENTO...';

  @override
  String get navHud => 'HUD';

  @override
  String get navLog => 'LOG';

  @override
  String get navSim => 'SIM';

  @override
  String get typeExpense => 'SPESA';

  @override
  String get typeIncome => 'REDDITO';

  @override
  String get typeLoan => 'PRESTITO';

  @override
  String get typeRepay => 'RIMBORSO';

  @override
  String get typeOpening => 'SALDO INIZIALE';

  @override
  String get typeSubscription => 'ABBONAMENTO';

  @override
  String subscriptionPaidQuestion(String amount, String name, String date) {
    return 'Hai pagato $amount per $name il $date?';
  }

  @override
  String subscriptionChargesDue(int count, String amount) {
    return '$count addebiti di abbonamento da confermare — $amount';
  }

  @override
  String get subscriptionConfirmAll => 'Conferma tutto';

  @override
  String get subscriptionReviewEach => 'Rivedi uno a uno';

  @override
  String get subscriptionPaidYes => 'Sì, registralo';

  @override
  String get subscriptionPaidNo => 'No';

  @override
  String get subscriptionWhatHappened => 'Cosa è successo?';

  @override
  String get subscriptionReasonCancelled => 'L\'ho disdetto';

  @override
  String get subscriptionReasonPriceChanged => 'Il prezzo è cambiato';

  @override
  String get subscriptionReasonNotPaid => 'Non l\'ho pagato';

  @override
  String get deleteSubscription => 'Elimina abbonamento';

  @override
  String get deleteSubscriptionKeepsEntries =>
      'Interrompe le voci future. I pagamenti già registrati vengono mantenuti.';

  @override
  String get liabilities => 'DEBITI';

  @override
  String get noActiveLoans => '> NESSUN PRESTITO ATTIVO';

  @override
  String get settled => 'SALDATO';

  @override
  String get totalDebtPerMonth => 'DEBITO TOTALE/MESE';

  @override
  String get remaining => 'RIMANENTE';

  @override
  String get installment => 'RATA';

  @override
  String get paidThisMo => 'PAGATO QUESTO MESE';

  @override
  String get monthsLeft => 'MESI RIMANENTI';

  @override
  String get repaid => '% RIMBORSATO';

  @override
  String get repay => 'RIMBORSA';

  @override
  String get repayTitle => '> RIMBORSA';

  @override
  String get extra => 'EXTRA';

  @override
  String get configButton => 'CFG';

  @override
  String get loanWizardTitle => 'ASSISTENTE PRESTITO';

  @override
  String get whoAndHowMuch => 'CHI E QUANTO';

  @override
  String get loanTerms => 'CONDIZIONI DEL PRESTITO';

  @override
  String get confirmPayment => 'CONFERMA PAGAMENTO';

  @override
  String get source => 'FONTE';

  @override
  String get nameLender => 'NOME / PRESTATORE';

  @override
  String get loanAmount => 'IMPORTO DEL PRESTITO';

  @override
  String get annualRate => 'TASSO ANNUO % (0 = SENZA INTERESSI)';

  @override
  String get repaymentMonths => 'MESI DI RIMBORSO';

  @override
  String get computedInstallment => 'RATA CALCOLATA';

  @override
  String get overrideInstallment => 'SOSTITUISCI RATA MENSILE';

  @override
  String get monthlyInstallment => 'RATA MENSILE';

  @override
  String get next => 'AVANTI';

  @override
  String get back => 'INDIETRO';

  @override
  String get lender => 'PRESTATORE';

  @override
  String get rate => 'TASSO';

  @override
  String get change => 'CAMBIA';

  @override
  String get subscriptions => 'ABBONAMENTI';

  @override
  String get noSubscriptions => '> NESSUN ABBONAMENTO ATTIVO';

  @override
  String get subscriptionName => 'NOME';

  @override
  String get subscriptionAmount => 'IMPORTO';

  @override
  String get subscriptionPaymentAmount => 'IMPORTO PAGATO';

  @override
  String get subscriptionCycle => 'CICLO DI FATTURAZIONE';

  @override
  String get subscriptionCoveragePeriod => 'PERIODO COPERTO';

  @override
  String get subscriptionCategory => 'CATEGORIA';

  @override
  String get subscriptionPaymentDate => 'DATA DI PAGAMENTO';

  @override
  String get subscriptionNextBilling => 'PROSSIMA FATTURAZIONE';

  @override
  String get subscriptionDaysLeft => 'GIORNI';

  @override
  String get totalPerMonth => 'TOTALE/MESE';

  @override
  String get totalPerYear => 'TOTALE/ANNO';

  @override
  String get newSubscription => '+ ABBONAMENTO';

  @override
  String get editSubscription => '> MODIFICA ABBONAMENTO';

  @override
  String get addSubscription => '> NUOVO ABBONAMENTO';

  @override
  String get personal => 'PERSONALE';

  @override
  String get business => 'AZIENDALE';

  @override
  String get weekly => 'SETTIMANALE';

  @override
  String get monthly => 'MENSILE';

  @override
  String get quarterly => 'TRIMESTRALE';

  @override
  String get yearly => 'ANNUALE';

  @override
  String get subscrPerMonth => '/ month';

  @override
  String get loans => 'PRESTITI';

  @override
  String activeCount(int count) {
    return '$count ATTIVO/I';
  }

  @override
  String get repayLoan => 'RIMBORSA PRESTITO';

  @override
  String get repaymentAmount => 'IMPORTO DEL RIMBORSO';

  @override
  String get cancel => 'ANNULLA';

  @override
  String get paid => '✓ PAGATO';

  @override
  String get subscrPerYear => '/ year';

  @override
  String get removeConfirm => 'RIMUOVERE?';

  @override
  String get remove => 'RIMUOVI';

  @override
  String monthsProjected(int count) {
    return '$count MESI PROIETTATI';
  }

  @override
  String get budgetPerMonth => 'BUDGET/MESE';

  @override
  String get breakdown => 'RIEPILOGO';

  @override
  String get safetyFund => 'FONDO DI SICUREZZA';

  @override
  String get safety => 'SICUREZZA';

  @override
  String get deployableCapital =>
      'CAPITALE DISPONIBILE — SEPARATO DAL BUFFER DI SOPRAVVIVENZA';

  @override
  String get historyEntries => 'STORICO & VOCI';

  @override
  String get addEntry => '+ AGGIUNGI';

  @override
  String get willRemoveLoan => 'VERRÀ RIMOSSO ANCHE DAI DEBITI';

  @override
  String get delete => 'ELIMINA';

  @override
  String get dataSection => 'I tuoi dati';

  @override
  String get deleteAllDataBody =>
      'Cancella tutte le voci, i prestiti, gli abbonamenti e le impostazioni da questo dispositivo. Runway Pro resta sbloccato.';

  @override
  String get deleteAllDataButton => 'CANCELLA TUTTI I DATI';

  @override
  String get deleteAllDataConfirmTitle => 'Cancellare tutto?';

  @override
  String get deleteAllDataConfirmBody =>
      'I tuoi dati vengono cancellati da questo dispositivo e non possono essere recuperati. Runway ricomincia dall\'inizio.';

  @override
  String get deleteAllDataConfirmAction => 'CANCELLA TUTTO';

  @override
  String get planned => 'PIANIFICATO';

  @override
  String get whatIfAnalysis => 'ANALISI WHAT-IF';

  @override
  String get current => 'ATTUALE';

  @override
  String get simulate => 'SIMULA';

  @override
  String get simHint =>
      'MODIFICA SPESA O REDDITO PER VEDERE L\'IMPATTO SULL\'AUTONOMIA';

  @override
  String get simulation => 'SIMULAZIONE';

  @override
  String get enterValuesToSim => 'INSERISCI VALORI PER SIMULARE';

  @override
  String get perMonth => '/ MESE';

  @override
  String get prefsBudget => 'PREFERENZE & BUDGET';

  @override
  String get close => 'CHIUDI';

  @override
  String get monthlyBudget => 'BUDGET MENSILE';

  @override
  String get rentFixed => 'AFFITTO / FISSO';

  @override
  String get livingExpenses => 'SPESE DI VITA';

  @override
  String get subtotal => 'SUBTOTALE';

  @override
  String budgetLeft(String amount) {
    return 'restano $amount';
  }

  @override
  String budgetOver(String amount) {
    return '$amount oltre il budget';
  }

  @override
  String dailyAllowance(String amount, int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$amount al giorno per $days giorni',
      one: '$amount per oggi',
    );
    return '$_temp0';
  }

  @override
  String get noLivingExpensesThisMonth => 'Nessuna spesa di vita questo mese';

  @override
  String get totalBudgetPerMonth => 'BUDGET TOTALE/MESE';

  @override
  String get setBudget => 'IMPOSTA BUDGET';

  @override
  String get rentFixedCosts => 'AFFITTO / COSTI FISSI';

  @override
  String get subscrDebtAuto => 'ABBONAMENTI + DEBITI AGGIUNTI AUTOMATICAMENTE';

  @override
  String get futureAssumptions => 'Previsione';

  @override
  String get expectedInflow => 'Entrate previste';

  @override
  String get expectedBurn => 'Spesa prevista';

  @override
  String get notSet => 'Non impostato';

  @override
  String get usingCurrentBurn => 'Uso della spesa attuale';

  @override
  String get assumptionsProjectionOnly =>
      'Le ipotesi influenzano solo le proiezioni future. Non creano transazioni.';

  @override
  String get setAssumptions => 'IMPOSTA PREVISIONE';

  @override
  String get expectedMonthlyInflow => 'Entrate mensili previste';

  @override
  String get expectedMonthlyBurn => 'Spesa mensile prevista';

  @override
  String get useCurrentBurn => 'Usa spesa attuale';

  @override
  String get futureInflowHint =>
      'Usa qui entrate future neutrali: freelance, contratti, redditi creator, dividendi o qualsiasi entrata prevista.';

  @override
  String get runwayGoal => 'Obiettivo runway';

  @override
  String get goal => 'Obiettivo';

  @override
  String get none => 'Nessuno';

  @override
  String get target => 'Target';

  @override
  String get optional => 'Opzionale';

  @override
  String monthsValue(int count) {
    return '$count mesi';
  }

  @override
  String get goalsContextHint =>
      'Gli obiettivi aggiungono contesto al tuo runway. Non sono un punteggio.';

  @override
  String get setGoal => 'IMPOSTA OBIETTIVO';

  @override
  String get goalName => 'Nome obiettivo';

  @override
  String get targetMonths => 'Mesi target';

  @override
  String get runwayBrand => 'RUNWAY';

  @override
  String get bootRunwayCheck => '> CONTROLLO RUNWAY...';

  @override
  String get bootIncomeStopped => '> SE IL TUO REDDITO SI FERMASSE OGGI...';

  @override
  String get bootCountingCashDays => '> CONTEGGIO DEI GIORNI DI CASSA...';

  @override
  String get bootRemovingComfortFilter =>
      '> RIMOZIONE DEL FILTRO DI COMFORT...';

  @override
  String get bootRealityCheckReady => '> CONTROLLO REALTÀ PRONTO.';

  @override
  String get ifIncomePausedToday => 'Se il reddito si fermasse oggi';

  @override
  String get runwayNeedsCosts =>
      'Imposta i costi mensili per vedere la tua autonomia';

  @override
  String get monthSingular => 'mese';

  @override
  String get monthPlural => 'mesi';

  @override
  String get sustainableWithExpectedInflow =>
      'Sostenibile con le entrate previste';

  @override
  String shortByPerMonth(String amount) {
    return 'Mancano $amount / mese';
  }

  @override
  String goalTargetProgress(int months) {
    return 'Obiettivo di $months mesi. Progresso verso il tuo obiettivo, non un punteggio.';
  }

  @override
  String get availableCash => 'Liquidità disponibile';

  @override
  String get notEnoughHistory => 'Storico insufficiente';

  @override
  String get projectionSource => 'Fonte proiezione';

  @override
  String get usingAssumptions => 'Uso delle ipotesi';

  @override
  String get fixedPressure => 'Costi fissi';

  @override
  String get plannedEssentials => 'Essenziali pianificati';

  @override
  String get recurringCosts => 'Costi ricorrenti';

  @override
  String get debtCommitments => 'Rate del prestito';

  @override
  String get daysUpper => 'GIORNI';

  @override
  String get yourRunway => 'Il tuo runway';

  @override
  String get higherExpenses => 'Spese più alte';

  @override
  String deltaDays(int days) {
    return '$days giorni';
  }

  @override
  String get shareSafe => 'CONDIVISIONE SICURA';

  @override
  String get shareSafeHint =>
      'Niente risparmi. Niente spese. Solo il tuo runway.';

  @override
  String get preparing => 'PREPARAZIONE...';

  @override
  String get shareImage => 'CONDIVIDI IMMAGINE';

  @override
  String get shareAsText => 'CONDIVIDI TESTO';

  @override
  String get goalReached => 'Obiettivo raggiunto!';

  @override
  String monthsToGoal(int count) {
    return '$count mesi al traguardo';
  }

  @override
  String get thisMonth => 'QUESTO MESE';

  @override
  String get cashIn => 'ENTRATA';

  @override
  String get cashOut => 'USCITA';

  @override
  String get netLabel => 'NETTO';

  @override
  String get noActivityThisMonth => 'Nessuna attività questo mese';

  @override
  String get paywallTermsOfUse => 'Termini di utilizzo';

  @override
  String get paywallPrivacyPolicy => 'Informativa sulla privacy';
}
