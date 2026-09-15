// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Runway';

  @override
  String get hudTitle => 'Runway';

  @override
  String get sysOnline => 'SYS: EN LIGNE';

  @override
  String get lifeForce => 'PRÉPARATION RUNWAY';

  @override
  String get statusLabel => 'STATUT';

  @override
  String get pressureLabel => 'Coûts mensuels';

  @override
  String get metrics => 'MÉTRIQUES';

  @override
  String get cash => 'LIQUIDITÉS';

  @override
  String get burnPerMonth => 'DÉPENSE/MO';

  @override
  String get loanPerMonth => 'DETTE/MO';

  @override
  String get runway => 'AUTONOMIE';

  @override
  String get runOut => 'ÉPUISEMENT';

  @override
  String get cashTimeline => 'CHRONOLOGIE';

  @override
  String get config => 'CONFIG';

  @override
  String get monthlyLoanPayment => 'REMBOURSEMENT MENSUEL';

  @override
  String get tapToSet => 'APPUYER POUR DÉFINIR';

  @override
  String get edit => 'MODIFIER';

  @override
  String get save => 'SAUVEGARDER';

  @override
  String get clear => 'EFFACER';

  @override
  String get loanAffectsInfo =>
      '> LE PRÊT/MO AFFECTE LE RATIO DE PRESSION ET L\'INVESTISSABLE';

  @override
  String get transactionLog => 'JOURNAL DES TRANSACTIONS';

  @override
  String get newEntry => '+ NOUVEAU';

  @override
  String get noEntries => 'No entries yet\nTap + ADD to log your first entry';

  @override
  String get newLogEntry => '> NOUVELLE ENTRÉE';

  @override
  String get modifyEntry => '> MODIFIER L\'ENTRÉE';

  @override
  String get type => 'TYPE';

  @override
  String get date => 'DATE';

  @override
  String get calcMonth => 'CALC';

  @override
  String get amount => 'MONTANT';

  @override
  String get noteOptional => 'NOTE (OPTIONNEL)';

  @override
  String get confirm => 'CONFIRMER';

  @override
  String get abort => 'ANNULER';

  @override
  String get purgeEntry => '> SUPPRIMER CETTE ENTRÉE?';

  @override
  String get scenarioSimulator => 'SIMULATEUR DE SCÉNARIO';

  @override
  String get overrideInputs => 'ENTRÉES DE REMPLACEMENT';

  @override
  String get burnRateOverride => 'REMPLACEMENT DÉPENSE';

  @override
  String get simulatedIncome => 'REVENU SIMULÉ/MO';

  @override
  String get simResults => 'RÉSULTATS SIM';

  @override
  String get simRunway => 'AUTONOMIE SIM';

  @override
  String get simRunOut => 'ÉPUISEMENT SIM';

  @override
  String get deltaVsActual => 'DELTA vs RÉEL';

  @override
  String get deltaRunway => 'DELTA AUTONOMIE';

  @override
  String get resetSim => 'RÉINITIALISER SIM';

  @override
  String get months => 'MOIS';

  @override
  String get stable => 'STABLE';

  @override
  String get caution => 'PRUDENCE';

  @override
  String get critical => 'CRITIQUE';

  @override
  String get low => 'FAIBLE';

  @override
  String get moderate => 'MODÉRÉ';

  @override
  String get highLoad => 'CHARGE ÉLEVÉE';

  @override
  String get language => 'LANGUE';

  @override
  String get currency => 'DEVISE';

  @override
  String get currencySymbolOnly =>
      'Modifie uniquement le symbole — vos montants ne sont pas convertis.';

  @override
  String get daysShort => 'j';

  @override
  String get gettingStarted => 'POUR COMMENCER';

  @override
  String stepsComplete(int completed, int total) {
    return '$completed sur $total complétés';
  }

  @override
  String get stepBalanceLabel => 'Ajoutez votre solde';

  @override
  String get stepBalanceHint => 'Combien avez-vous en ce moment ?';

  @override
  String get stepBudgetLabel => 'Définissez votre budget mensuel';

  @override
  String get stepBudgetHint => 'Loyer + dépenses courantes';

  @override
  String get stepExpenseLabel => 'Enregistrez votre première dépense';

  @override
  String get stepExpenseHint => 'Suivez où va votre argent';

  @override
  String get stepSimLabel => 'Essayez le simulateur';

  @override
  String get stepSimHint => 'Et si vous réduisiez vos dépenses ?';

  @override
  String get loading => 'CHARGEMENT...';

  @override
  String get navHud => 'HUD';

  @override
  String get navLog => 'LOG';

  @override
  String get navSim => 'SIM';

  @override
  String get typeExpense => 'DÉPENSE';

  @override
  String get typeIncome => 'REVENU';

  @override
  String get typeLoan => 'PRÊT';

  @override
  String get typeRepay => 'REMBOURSER';

  @override
  String get typeOpening => 'OUVERTURE';

  @override
  String get liabilities => 'DETTES';

  @override
  String get noActiveLoans => '> AUCUN PRÊT ACTIF';

  @override
  String get settled => 'RÉGLÉ';

  @override
  String get totalDebtPerMonth => 'DETTE TOTALE/MO';

  @override
  String get remaining => 'RESTANT';

  @override
  String get installment => 'MENSUALITÉ';

  @override
  String get paidThisMo => 'PAYÉ CE MOIS';

  @override
  String get monthsLeft => 'MOIS RESTANTS';

  @override
  String get repaid => '% REMBOURSÉ';

  @override
  String get repay => 'REMBOURSER';

  @override
  String get repayTitle => '> REMBOURSER';

  @override
  String get extra => 'EXTRA';

  @override
  String get configButton => 'CFG';

  @override
  String get loanWizardTitle => 'ASSISTANT PRÊT';

  @override
  String get whoAndHowMuch => 'QUI & COMBIEN';

  @override
  String get loanTerms => 'CONDITIONS DU PRÊT';

  @override
  String get confirmPayment => 'CONFIRMER LE PAIEMENT';

  @override
  String get source => 'SOURCE';

  @override
  String get nameLender => 'NOM / PRÊTEUR';

  @override
  String get loanAmount => 'MONTANT DU PRÊT';

  @override
  String get annualRate => 'TAUX ANNUEL % (0 = SANS INTÉRÊT)';

  @override
  String get repaymentMonths => 'MOIS DE REMBOURSEMENT';

  @override
  String get computedInstallment => 'MENSUALITÉ CALCULÉE';

  @override
  String get overrideInstallment => 'REMPLACER LA MENSUALITÉ';

  @override
  String get monthlyInstallment => 'MENSUALITÉ';

  @override
  String get next => 'SUIVANT';

  @override
  String get back => 'RETOUR';

  @override
  String get lender => 'PRÊTEUR';

  @override
  String get rate => 'TAUX';

  @override
  String get change => 'MODIFIER';

  @override
  String get subscriptions => 'ABONNEMENTS';

  @override
  String get noSubscriptions => '> AUCUN ABONNEMENT ACTIF';

  @override
  String get subscriptionName => 'NOM';

  @override
  String get subscriptionAmount => 'MONTANT';

  @override
  String get subscriptionPaymentAmount => 'MONTANT PAYÉ';

  @override
  String get subscriptionCycle => 'CYCLE DE FACTURATION';

  @override
  String get subscriptionCoveragePeriod => 'PÉRIODE COUVERTE';

  @override
  String get subscriptionCategory => 'CATÉGORIE';

  @override
  String get subscriptionPaymentDate => 'DATE DE PAIEMENT';

  @override
  String get subscriptionNextBilling => 'PROCHAINE FACTURATION';

  @override
  String get subscriptionDaysLeft => 'JOURS';

  @override
  String get totalPerMonth => 'TOTAL/MOIS';

  @override
  String get totalPerYear => 'TOTAL/AN';

  @override
  String get newSubscription => '+ ABONNEMENT';

  @override
  String get editSubscription => '> MODIFIER ABONNEMENT';

  @override
  String get addSubscription => '> NOUVEL ABONNEMENT';

  @override
  String get personal => 'PERSONNEL';

  @override
  String get business => 'PROFESSIONNEL';

  @override
  String get weekly => 'HEBDOMADAIRE';

  @override
  String get monthly => 'MENSUEL';

  @override
  String get quarterly => 'TRIMESTRIEL';

  @override
  String get yearly => 'ANNUEL';

  @override
  String get subscrPerMonth => '/ month';

  @override
  String get loans => 'PRÊTS';

  @override
  String activeCount(int count) {
    return '$count ACTIF(S)';
  }

  @override
  String get repayLoan => 'REMBOURSER LE PRÊT';

  @override
  String get repaymentAmount => 'MONTANT DU REMBOURSEMENT';

  @override
  String get cancel => 'ANNULER';

  @override
  String get paid => '✓ PAYÉ';

  @override
  String get subscrPerYear => '/ year';

  @override
  String get removeConfirm => 'SUPPRIMER?';

  @override
  String get remove => 'SUPPRIMER';

  @override
  String monthsProjected(int count) {
    return '$count MOIS PROJETÉS';
  }

  @override
  String get budgetPerMonth => 'BUDGET/MOIS';

  @override
  String get breakdown => 'DÉTAIL';

  @override
  String get safetyFund => 'FONDS DE SÉCURITÉ';

  @override
  String get safety => 'SÉCURITÉ';

  @override
  String get deployableCapital =>
      'CAPITAL DÉPLOYABLE — SÉPARÉ DU TAMPON DE SURVIE';

  @override
  String get historyEntries => 'HISTORIQUE & ENTRÉES';

  @override
  String get addEntry => '+ AJOUTER';

  @override
  String get willRemoveLoan => 'SUPPRIMERA AUSSI DES DETTES';

  @override
  String get delete => 'SUPPRIMER';

  @override
  String get dataSection => 'Vos données';

  @override
  String get deleteAllDataBody =>
      'Efface toutes les entrées, prêts, abonnements et réglages de cet appareil. Runway Pro reste débloqué.';

  @override
  String get deleteAllDataButton => 'EFFACER TOUTES LES DONNÉES';

  @override
  String get deleteAllDataConfirmTitle => 'Tout effacer ?';

  @override
  String get deleteAllDataConfirmBody =>
      'Vos données sont effacées de cet appareil et ne peuvent pas être récupérées. Runway repart de zéro.';

  @override
  String get deleteAllDataConfirmAction => 'TOUT EFFACER';

  @override
  String get planned => 'PLANIFIÉ';

  @override
  String get whatIfAnalysis => 'ANALYSE WHAT-IF';

  @override
  String get current => 'ACTUEL';

  @override
  String get simulate => 'SIMULER';

  @override
  String get simHint =>
      'MODIFIER LE TAUX OU AJOUTER UN REVENU POUR VOIR L\'IMPACT';

  @override
  String get simulation => 'SIMULATION';

  @override
  String get enterValuesToSim => 'ENTREZ DES VALEURS POUR SIMULER';

  @override
  String get perMonth => '/ MOIS';

  @override
  String get prefsBudget => 'PRÉFÉRENCES & BUDGET';

  @override
  String get close => 'FERMER';

  @override
  String get monthlyBudget => 'BUDGET MENSUEL';

  @override
  String get rentFixed => 'LOYER / FIXE';

  @override
  String get livingExpenses => 'DÉPENSES DE VIE';

  @override
  String get subtotal => 'SOUS-TOTAL';

  @override
  String get totalBudgetPerMonth => 'BUDGET TOTAL/MOIS';

  @override
  String get setBudget => 'DÉFINIR LE BUDGET';

  @override
  String get rentFixedCosts => 'LOYER / COÛTS FIXES';

  @override
  String get subscrDebtAuto => 'ABONNEMENTS + DETTES AJOUTÉS AUTOMATIQUEMENT';

  @override
  String get futureAssumptions => 'Prévisions';

  @override
  String get expectedInflow => 'Entrées attendues';

  @override
  String get expectedBurn => 'Dépenses attendues';

  @override
  String get notSet => 'Non défini';

  @override
  String get usingCurrentBurn => 'Dépense actuelle utilisée';

  @override
  String get assumptionsProjectionOnly =>
      'Les hypothèses affectent seulement les projections futures. Elles ne créent pas de transactions.';

  @override
  String get setAssumptions => 'DÉFINIR LES PRÉVISIONS';

  @override
  String get expectedMonthlyInflow => 'Entrées mensuelles attendues';

  @override
  String get expectedMonthlyBurn => 'Dépenses mensuelles attendues';

  @override
  String get useCurrentBurn => 'Utiliser la dépense actuelle';

  @override
  String get futureInflowHint =>
      'Ajoutez ici des entrées futures neutres : missions freelance, contrats, revenus de création, dividendes ou toute entrée attendue.';

  @override
  String get runwayGoal => 'Objectif de runway';

  @override
  String get goal => 'Objectif';

  @override
  String get none => 'Aucun';

  @override
  String get target => 'Cible';

  @override
  String get optional => 'Optionnel';

  @override
  String monthsValue(int count) {
    return '$count mois';
  }

  @override
  String get goalsContextHint =>
      'Les objectifs donnent du contexte à votre runway. Ce ne sont pas des scores.';

  @override
  String get setGoal => 'DÉFINIR UN OBJECTIF';

  @override
  String get goalName => 'Nom de l’objectif';

  @override
  String get targetMonths => 'Mois cible';

  @override
  String get display => 'AFFICHAGE';

  @override
  String get glassEffect => 'EFFET VERRE';

  @override
  String get glassEffectHint =>
      'INTENSIF GPU — DÉSACTIVER SUR ANCIENS APPAREILS';

  @override
  String get runwayBrand => 'RUNWAY';

  @override
  String get bootRunwayCheck => '> VÉRIFICATION DU RUNWAY...';

  @override
  String get bootIncomeStopped =>
      '> SI VOS REVENUS S\'ARRÊTAIENT AUJOURD\'HUI...';

  @override
  String get bootCountingCashDays => '> COMPTE DES JOURS DE CASH...';

  @override
  String get bootRemovingComfortFilter => '> RETRAIT DU FILTRE DE CONFORT...';

  @override
  String get bootRealityCheckReady => '> RETOUR AU RÉEL PRÊT.';

  @override
  String get ifIncomeStoppedToday => 'If inflow stopped today';

  @override
  String get ifIncomePausedToday => 'Si vos revenus s\'arrêtaient aujourd\'hui';

  @override
  String get monthSingular => 'mois';

  @override
  String get monthPlural => 'mois';

  @override
  String get sustainableWithExpectedInflow =>
      'Soutenable avec vos entrées attendues';

  @override
  String shortByPerMonth(String amount) {
    return 'Manque $amount / mois';
  }

  @override
  String goalTargetProgress(int months) {
    return 'Objectif de $months mois. Progression vers votre objectif, pas un score.';
  }

  @override
  String get monthlyBurn => 'Dépense mensuelle';

  @override
  String get availableCash => 'Cash disponible';

  @override
  String get historicalBurn => 'Dépense moy.';

  @override
  String get notEnoughHistory => 'Pas assez d’historique';

  @override
  String get projectionSource => 'Source de projection';

  @override
  String get usingAssumptions => 'Hypothèses utilisées';

  @override
  String get fixedPressure => 'Coûts fixes';

  @override
  String get actualBurn => 'Dépense réelle';

  @override
  String get actualBurnHigh => 'Dépense réelle ▲';

  @override
  String get plannedEssentials => 'Essentiels prévus';

  @override
  String get recurringCosts => 'Coûts récurrents';

  @override
  String get debtCommitments => 'Remboursements';

  @override
  String get daysUpper => 'JOURS';

  @override
  String get yourRunway => 'Votre runway';

  @override
  String get loseIncome => 'Inflow stops';

  @override
  String get higherExpenses => 'Dépenses plus hautes';

  @override
  String get incomeSetToZero => 'Inflow set to 0';

  @override
  String deltaDays(int days) {
    return '$days jours';
  }

  @override
  String get shareSafe => 'PARTAGE SÛR';

  @override
  String get shareSafeHint =>
      'Pas d\'épargne. Pas de dépenses. Juste votre runway.';

  @override
  String get preparing => 'PRÉPARATION...';

  @override
  String get shareImage => 'PARTAGER L\'IMAGE';

  @override
  String get shareAsText => 'PARTAGER EN TEXTE';

  @override
  String get goalReached => 'Objectif atteint !';

  @override
  String monthsToGoal(int count) {
    return '$count mois restants';
  }

  @override
  String get thisMonth => 'CE MOIS';

  @override
  String get cashIn => 'ENTRÉE';

  @override
  String get cashOut => 'SORTIE';

  @override
  String get netLabel => 'NET';

  @override
  String get noActivityThisMonth => 'Aucune activité ce mois-ci';
}
