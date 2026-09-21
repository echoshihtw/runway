// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Runway';

  @override
  String get hudTitle => 'Runway';

  @override
  String get sysOnline => 'SIS: EN LÍNEA';

  @override
  String get lifeForce => 'PREPARACIÓN DE AUTONOMÍA';

  @override
  String get statusLabel => 'ESTADO';

  @override
  String get pressureLabel => 'Costos mensuales';

  @override
  String get costsIncludeCommitments =>
      'Incluye suscripciones y pagos de préstamos';

  @override
  String get metrics => 'MÉTRICAS';

  @override
  String get cash => 'EFECTIVO';

  @override
  String get owed => 'Pendiente';

  @override
  String runsOut(String date) {
    return 'Se agota $date';
  }

  @override
  String get loanPerMonth => 'DEUDA/MES';

  @override
  String get runway => 'AUTONOMÍA';

  @override
  String get runOut => 'AGOTAMIENTO';

  @override
  String get cashTimeline => 'CRONOLOGÍA';

  @override
  String get config => 'CONFIG';

  @override
  String get monthlyLoanPayment => 'PAGO MENSUAL DE PRÉSTAMO';

  @override
  String get tapToSet => 'TOCA PARA ESTABLECER';

  @override
  String get edit => 'EDITAR';

  @override
  String get save => 'GUARDAR';

  @override
  String get clear => 'LIMPIAR';

  @override
  String get transactionLog => 'REGISTRO DE TRANSACCIONES';

  @override
  String get newEntry => '+ NUEVO';

  @override
  String get noEntries => 'No entries yet\nTap + ADD to log your first entry';

  @override
  String get newLogEntry => 'Nueva entrada';

  @override
  String get modifyEntry => 'MODIFICAR ENTRADA';

  @override
  String get type => 'TIPO';

  @override
  String get date => 'FECHA';

  @override
  String get calcMonth => 'CALC';

  @override
  String get amount => 'MONTO';

  @override
  String get noteOptional => 'NOTA (OPCIONAL)';

  @override
  String get confirm => 'CONFIRMAR';

  @override
  String get abort => 'CANCELAR';

  @override
  String get purgeEntry => '¿Eliminar entrada?';

  @override
  String get scenarioSimulator => 'SIMULADOR DE ESCENARIOS';

  @override
  String get overrideInputs => 'ENTRADAS DE REEMPLAZO';

  @override
  String get burnRateOverride => 'Alquiler + vida / mes';

  @override
  String get simulatedIncome => 'INGRESO SIMULADO/MES';

  @override
  String get simResults => 'RESULTADOS SIM';

  @override
  String get simRunway => 'AUTONOMÍA SIM';

  @override
  String get simRunOut => 'AGOTAMIENTO SIM';

  @override
  String get deltaVsActual => 'DELTA vs REAL';

  @override
  String get deltaRunway => 'DELTA AUTONOMÍA';

  @override
  String get resetSim => 'REINICIAR SIM';

  @override
  String get months => 'MESES';

  @override
  String get stable => 'ESTABLE';

  @override
  String get caution => 'PRECAUCIÓN';

  @override
  String get critical => 'CRÍTICO';

  @override
  String get low => 'BAJO';

  @override
  String get moderate => 'MODERADO';

  @override
  String get highLoad => 'CARGA ALTA';

  @override
  String get language => 'Idioma';

  @override
  String get currency => 'Moneda';

  @override
  String get currencySymbolOnly =>
      'Cambia solo el símbolo de visualización. Tus importes no se convierten.';

  @override
  String get daysShort => 'd';

  @override
  String get gettingStarted => 'PRIMEROS PASOS';

  @override
  String stepsComplete(int completed, int total) {
    return '$completed de $total completados';
  }

  @override
  String get stepBalanceLabel => 'Agrega tu saldo en efectivo';

  @override
  String get stepBalanceHint => '¿Cuánto tienes ahora mismo?';

  @override
  String get stepBudgetLabel => 'Define tu presupuesto mensual';

  @override
  String get stepBudgetHint => 'Alquiler + gastos de vida';

  @override
  String get stepExpenseLabel => 'Registra tu primer gasto';

  @override
  String get stepExpenseHint => 'Lleva el control de tu dinero';

  @override
  String get stepSimLabel => 'Prueba el simulador';

  @override
  String get stepSimHint => '¿Y si recortas gastos?';

  @override
  String get loading => 'CARGANDO...';

  @override
  String get navHud => 'Resumen';

  @override
  String get navLog => 'Registro';

  @override
  String get navSim => 'Plan';

  @override
  String get typeExpense => 'GASTO';

  @override
  String get typeIncome => 'INGRESO';

  @override
  String get typeLoan => 'PRÉSTAMO';

  @override
  String get typeRepay => 'PAGO DEL PRÉSTAMO';

  @override
  String get typeOpening => 'SALDO INICIAL';

  @override
  String get typeSubscription => 'SUSCRIPCIÓN';

  @override
  String subscriptionPaidQuestion(String amount, String name, String date) {
    return '¿Pagaste $amount de $name el $date?';
  }

  @override
  String subscriptionChargesDue(int count, String amount) {
    return '$count cargos de suscripción pendientes: $amount';
  }

  @override
  String get subscriptionConfirmAll => 'Confirmar todo';

  @override
  String get subscriptionReviewEach => 'Revisar uno a uno';

  @override
  String get subscriptionPaidYes => 'Sí, regístralo';

  @override
  String get subscriptionChargeFailed =>
      'No se pudo registrar. Comprueba el importe de la suscripción.';

  @override
  String get subscriptionSaveFailed =>
      'No se pudo guardar la suscripción. No se añadió nada.';

  @override
  String get loanSaveFailed =>
      'No se pudo guardar el préstamo. No se añadió nada.';

  @override
  String get subscriptionPaidNo => 'No';

  @override
  String get subscriptionWhatHappened => '¿Qué pasó?';

  @override
  String get subscriptionReasonCancelled => 'La cancelé';

  @override
  String get subscriptionReasonPriceChanged => 'Cambió el precio';

  @override
  String get subscriptionReasonNotPaid => 'No la pagué';

  @override
  String get deleteSubscription => 'Eliminar suscripción';

  @override
  String get deleteSubscriptionKeepsEntries =>
      'Detiene las entradas futuras. Los pagos ya registrados se conservan.';

  @override
  String get liabilities => 'Deudas';

  @override
  String get noActiveLoans => 'SIN PRÉSTAMOS ACTIVOS';

  @override
  String get newLoan => '+ PRÉSTAMO';

  @override
  String get spendOnWhat => '¿Para qué fue?';

  @override
  String get moneyCameInInstead => '¿Entró dinero en su lugar?';

  @override
  String get logIncome => 'Registrar ingreso';

  @override
  String get presetCoffee => 'CAFÉ';

  @override
  String get presetCoffeeNote => 'Café';

  @override
  String get presetLunch => 'ALMUERZO';

  @override
  String get presetLunchNote => 'Almuerzo';

  @override
  String get presetDinner => 'CENA';

  @override
  String get presetDinnerNote => 'Cena';

  @override
  String get presetTransport => 'TRANSPORTE';

  @override
  String get presetTransportNote => 'Transporte';

  @override
  String get presetGroceries => 'COMPRA';

  @override
  String get presetGroceriesNote => 'Compra';

  @override
  String get presetSomethingElse => 'OTRA COSA';

  @override
  String freeEntriesUsed(int used, int free) {
    return '$used de $free entradas gratis usadas';
  }

  @override
  String freeSimulationsUsed(int used, int free) {
    return '$used de $free simulaciones gratis usadas';
  }

  @override
  String get settled => 'LIQUIDADO';

  @override
  String get totalDebtPerMonth => 'DEUDA TOTAL/MES';

  @override
  String get remaining => 'RESTANTE';

  @override
  String get installment => 'CUOTA';

  @override
  String get paidThisMo => 'PAGADO ESTE MES';

  @override
  String get monthsLeft => 'MESES RESTANTES';

  @override
  String get repaid => '% REEMBOLSADO';

  @override
  String get stillPaying =>
      'Ya has devuelto lo que pediste. Los pagos siguen hasta el final del plazo.';

  @override
  String get markSettled => 'Marcar como liquidado';

  @override
  String get markSettledExplain =>
      'La cuota mensual deja de contar y el préstamo sale de esta lista para siempre. Los registros se conservan.';

  @override
  String get repay => 'PAGAR';

  @override
  String get repayTitle => 'PAGAR';

  @override
  String get extra => 'EXTRA';

  @override
  String get configButton => 'CFG';

  @override
  String get loanWizardTitle => 'Asistente de préstamo';

  @override
  String get whoAndHowMuch => 'QUIÉN Y CUÁNTO';

  @override
  String get loanTerms => 'CONDICIONES DEL PRÉSTAMO';

  @override
  String get confirmPayment => 'CONFIRMAR PAGO';

  @override
  String get source => 'FUENTE';

  @override
  String get nameLender => 'NOMBRE / PRESTAMISTA';

  @override
  String get loanAmount => 'MONTO DEL PRÉSTAMO';

  @override
  String get annualRate => 'TASA ANUAL % (0 = SIN INTERÉS)';

  @override
  String get repaymentMonths => 'MESES DE PAGO';

  @override
  String get computedInstallment => 'CUOTA CALCULADA';

  @override
  String get overrideInstallment => 'REEMPLAZAR CUOTA MENSUAL';

  @override
  String get monthlyInstallment => 'CUOTA MENSUAL';

  @override
  String get next => 'SIGUIENTE';

  @override
  String get back => 'ATRÁS';

  @override
  String get lender => 'PRESTAMISTA';

  @override
  String get rate => 'TASA';

  @override
  String get change => 'CAMBIAR';

  @override
  String get subscriptions => 'Suscripciones';

  @override
  String get noSubscriptions => 'SIN SUSCRIPCIONES ACTIVAS';

  @override
  String get subscriptionName => 'NOMBRE';

  @override
  String get subscriptionAmount => 'MONTO';

  @override
  String get subscriptionPaymentAmount => 'MONTO PAGADO';

  @override
  String get subscriptionCycle => 'CICLO DE FACTURACIÓN';

  @override
  String get subscriptionCoveragePeriod => 'PERIODO CUBIERTO';

  @override
  String get subscriptionCategory => 'CATEGORÍA';

  @override
  String get subscriptionPaymentDate => 'FECHA DE PAGO';

  @override
  String get subscriptionNextBilling => 'PRÓXIMA FACTURACIÓN';

  @override
  String get subscriptionDaysLeft => 'DÍAS';

  @override
  String get totalPerMonth => 'TOTAL/MES';

  @override
  String get totalPerYear => 'TOTAL/AÑO';

  @override
  String get newSubscription => '+ SUSCRIPCIÓN';

  @override
  String get editSubscription => 'Editar suscripción';

  @override
  String get addSubscription => 'Nueva suscripción';

  @override
  String get personal => 'PERSONAL';

  @override
  String get business => 'NEGOCIO';

  @override
  String get weekly => 'SEMANAL';

  @override
  String get monthly => 'MENSUAL';

  @override
  String get quarterly => 'TRIMESTRAL';

  @override
  String get yearly => 'ANUAL';

  @override
  String get subscrPerMonth => '/ month';

  @override
  String get loans => 'PRÉSTAMOS';

  @override
  String get repayLoan => 'Pagar préstamo';

  @override
  String get repaymentAmount => 'MONTO DE PAGO';

  @override
  String get cancel => 'CANCELAR';

  @override
  String get paid => '✓ PAGADO';

  @override
  String get subscrPerYear => '/ year';

  @override
  String get remove => 'ELIMINAR';

  @override
  String monthsProjected(int count) {
    return '$count MESES PROYECTADOS';
  }

  @override
  String get budgetPerMonth => 'PRESUPUESTO/MES';

  @override
  String get breakdown => 'DESGLOSE';

  @override
  String get safetyFund => 'FONDO DE SEGURIDAD';

  @override
  String get safety => 'SEGURIDAD';

  @override
  String get historyEntries => 'HISTORIAL & ENTRADAS';

  @override
  String get addEntry => '+ AGREGAR';

  @override
  String get willRemoveLoan => 'TAMBIÉN SE ELIMINARÁ DE DEUDAS';

  @override
  String get delete => 'ELIMINAR';

  @override
  String get dataSection => 'Tus datos';

  @override
  String get deleteAllDataBody =>
      'Borra todos los movimientos, préstamos, suscripciones y ajustes de este dispositivo. Runway Pro sigue desbloqueado.';

  @override
  String get deleteAllDataButton => 'BORRAR TODOS LOS DATOS';

  @override
  String get deleteAllDataConfirmTitle => '¿Borrar todo?';

  @override
  String get deleteAllDataConfirmBody =>
      'Tus datos se borran de este dispositivo y no se pueden recuperar. Runway empezará desde el principio.';

  @override
  String get deleteAllDataConfirmAction => 'BORRAR TODO';

  @override
  String get planned => 'PLANIFICADO';

  @override
  String get whatIfAnalysis => 'ANÁLISIS WHAT-IF';

  @override
  String get current => 'Actual';

  @override
  String get simulate => 'Simular';

  @override
  String get simHint =>
      'Cambia el gasto o ingreso para ver el impacto en autonomía';

  @override
  String get simulation => 'SIMULACIÓN';

  @override
  String get enterValuesToSim => 'INGRESA VALORES PARA SIMULAR';

  @override
  String get perMonth => '/ MES';

  @override
  String get prefsBudget => 'PREFERENCIAS & PRESUPUESTO';

  @override
  String get close => 'CERRAR';

  @override
  String get monthlyBudget => 'Presupuesto mensual';

  @override
  String get rentFixed => 'ALQUILER / FIJO';

  @override
  String get livingExpenses => 'Gastos de vida';

  @override
  String get budgetRuleHint =>
      'El gasto consume su presupuesto. Solo pasarse añade coste.';

  @override
  String get subtotal => 'SUBTOTAL';

  @override
  String budgetLeft(String amount) {
    return 'quedan $amount';
  }

  @override
  String budgetPaid(String amount) {
    return '$amount pagado';
  }

  @override
  String spentOfBudget(String spent, String budget) {
    return '$spent de $budget';
  }

  @override
  String budgetOver(String amount) {
    return '$amount por encima del presupuesto';
  }

  @override
  String dailyAllowance(String amount, int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$amount al día durante $days días',
      one: '$amount para hoy',
    );
    return '$_temp0';
  }

  @override
  String get noLivingExpensesThisMonth => 'Aún no hay gastos de vida este mes';

  @override
  String get totalBudgetPerMonth => 'PRESUPUESTO TOTAL/MES';

  @override
  String get setBudget => 'ESTABLECER PRESUPUESTO';

  @override
  String get rentFixedCosts => 'ALQUILER / COSTOS FIJOS';

  @override
  String get subscrDebtAuto =>
      'SUSCRIPCIONES + DEUDAS AÑADIDAS AUTOMÁTICAMENTE';

  @override
  String get futureAssumptions => 'Previsión';

  @override
  String get expectedInflow => 'Entrada esperada';

  @override
  String get everyMonth => 'Cada mes';

  @override
  String get monthlySurplus => 'Superávit';

  @override
  String get monthlyDeficit => 'Déficit';

  @override
  String get setExpectedIncome => 'Indicar ingresos previstos';

  @override
  String get expectedBurn => 'Gasto esperado';

  @override
  String get notSet => 'Sin definir';

  @override
  String get settingsFailedToLoad =>
      'No se pudieron cargar estos ajustes. La edición está desactivada para no sobrescribirlos.';

  @override
  String get usingCurrentBurn => 'Usando gasto actual';

  @override
  String get assumptionsProjectionOnly =>
      'Los supuestos solo afectan las proyecciones futuras. No crean transacciones.';

  @override
  String get setAssumptions => 'DEFINIR PREVISIÓN';

  @override
  String get expectedMonthlyInflow => 'Entrada mensual esperada';

  @override
  String get expectedMonthlyBurn => 'Gasto mensual esperado';

  @override
  String get useCurrentBurn => 'Usar gasto actual';

  @override
  String get futureInflowHint =>
      'Usa aquí entradas futuras neutrales: freelance, contratos, ingresos de creador, dividendos o cualquier entrada esperada.';

  @override
  String get forecastDoesNotMoveRunway =>
      'Los ingresos no cambian el margen. El margen es lo que cubre tu efectivo si los ingresos se detuvieran; esto indica si el mes lo aumenta.';

  @override
  String get runwayGoal => 'Objetivo de runway';

  @override
  String get goal => 'Objetivo';

  @override
  String get none => 'Ninguno';

  @override
  String get target => 'Meta';

  @override
  String get optional => 'Opcional';

  @override
  String monthsValue(int count) {
    return '$count meses';
  }

  @override
  String get goalsContextHint =>
      'Los objetivos agregan contexto a tu runway. No son una puntuación.';

  @override
  String get setGoal => 'DEFINIR OBJETIVO';

  @override
  String get goalName => 'Nombre del objetivo';

  @override
  String get targetMonths => 'Meses objetivo';

  @override
  String get runwayBrand => 'RUNWAY';

  @override
  String get runwayBasisBudget =>
      'Según tu presupuesto, si los ingresos se detuvieran hoy';

  @override
  String get runwayBasisSpending =>
      'Según tu gasto, si los ingresos se detuvieran hoy';

  @override
  String get runwayBasisAssumption =>
      'Según tu supuesto de costes, si los ingresos se detuvieran hoy';

  @override
  String computedCost(String amount) {
    return 'Calculado con tu presupuesto y registro: $amount';
  }

  @override
  String get runwayNeedsCosts =>
      'Indica tus gastos mensuales para ver tu margen';

  @override
  String get monthSingular => 'mes';

  @override
  String get monthPlural => 'meses';

  @override
  String get sustainableWithExpectedInflow =>
      'Sostenible con tu entrada esperada';

  @override
  String shortByPerMonth(String amount) {
    return 'Faltan $amount / mes';
  }

  @override
  String goalTargetProgress(int months) {
    return 'Objetivo de $months meses. Progreso hacia tu objetivo, no una puntuación.';
  }

  @override
  String get availableCash => 'Efectivo disponible';

  @override
  String get notEnoughHistory => 'Historial insuficiente';

  @override
  String get projectionSource => 'Fuente de proyección';

  @override
  String get usingAssumptions => 'Usando supuestos';

  @override
  String get fixedPressure => 'Costos fijos';

  @override
  String get plannedEssentials => 'Esenciales previstos';

  @override
  String get recurringCosts => 'Costos recurrentes';

  @override
  String get debtCommitments => 'Pagos de préstamos';

  @override
  String get daysUpper => 'DÍAS';

  @override
  String get yourRunway => 'Tu autonomía';

  @override
  String get higherExpenses => 'Más gastos';

  @override
  String deltaDays(int days) {
    return '$days días';
  }

  @override
  String get shareSafe => 'COMPARTIR SEGURO';

  @override
  String get shareSafeHint => 'Sin ahorros. Sin gastos. Solo tu autonomía.';

  @override
  String get preparing => 'PREPARANDO...';

  @override
  String get shareImage => 'COMPARTIR IMAGEN';

  @override
  String get shareAsText => 'COMPARTIR TEXTO';

  @override
  String get goalReached => 'Objetivo alcanzado';

  @override
  String monthsToGoal(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count meses de cobertura por construir',
      one: '1 mes de cobertura por construir',
    );
    return '$_temp0';
  }

  @override
  String get goalCashTarget => 'Objetivo';

  @override
  String goalCashTargetFrom(int count, String cost) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count meses × $cost al mes',
      one: '1 mes × $cost al mes',
    );
    return '$_temp0';
  }

  @override
  String get goalCashToGo => 'Falta';

  @override
  String get thisMonth => 'Este mes';

  @override
  String get cashIn => 'ENTRADA';

  @override
  String get cashOut => 'SALIDA';

  @override
  String get netLabel => 'NETO';

  @override
  String get noActivityThisMonth => 'Sin actividad este mes';

  @override
  String get onboardingSkip => 'OMITIR';

  @override
  String get onboardingWelcomeTitle =>
      'Deja de adivinar\ncuánto te dura el dinero.';

  @override
  String get onboardingWelcomeBody => 'Sin cuenta. Sin conexión bancaria.';

  @override
  String get onboardingGetStarted => 'EMPEZAR';

  @override
  String get onboardingPrivacyTitle => 'Tus datos,\ntu dispositivo.';

  @override
  String get onboardingPrivacyBody =>
      'No hay servidor, así que no hay nada que filtrar.';

  @override
  String get onboardingPrivacyEncrypted => 'Cifrado en el dispositivo';

  @override
  String get onboardingPrivacyOnDevice => 'Tus cifras no salen del dispositivo';

  @override
  String get onboardingPrivacyHidden => 'Oculto al cambiar de app';

  @override
  String get onboardingPrivacyDelete => 'Bórralo cuando quieras';

  @override
  String get onboardingIUnderstand => 'ENTENDIDO';

  @override
  String get onboardingFirstActionTitle => 'Un número y\nya está listo.';

  @override
  String get onboardingFirstActionBody =>
      'Solo tu saldo en efectivo. Nada más.';

  @override
  String get onboardingAddMyBalance => 'AÑADIR MI SALDO';

  @override
  String get paywallUnlock => 'DESBLOQUEAR RUNWAY PRO';

  @override
  String get paywallLoadingPrice => 'Cargando precio...';

  @override
  String get paywallStoreUnreachable =>
      'No se pudo conectar con la tienda. Revisa tu conexión e inténtalo de nuevo.';

  @override
  String paywallOneTimePurchase(String price) {
    return '$price una vez. Esta app cuenta tus suscripciones; no va a ser una.';
  }

  @override
  String get paywallUnavailable =>
      'Pro no está disponible ahora mismo. Inténtalo más tarde.';

  @override
  String get paywallRestore => 'Restaurar compra';

  @override
  String get paywallMaybeLater => 'Quizá más tarde';

  @override
  String get paywallPurchaseFailed => 'La compra falló. Inténtalo de nuevo.';

  @override
  String get paywallSomethingWrong => 'Algo salió mal. Inténtalo de nuevo.';

  @override
  String get paywallNoPreviousPurchase =>
      'No se encontró ninguna compra anterior.';

  @override
  String get paywallRestoreFailed =>
      'La restauración falló. Inténtalo de nuevo.';

  @override
  String paywallTitleEntries(int count) {
    return 'Has usado tus $count registros gratis.\nPro es lo que mantiene el número verdadero.';
  }

  @override
  String paywallTitleSimulations(int count) {
    return 'Has hecho tus $count simulaciones gratis.\nPro es como sigues preguntando qué pasaría si.';
  }

  @override
  String get paywallTitleDefault => 'Desbloquea Runway Pro.';

  @override
  String get paywallFeatureEntries => 'Registra todo, y el número no se desvía';

  @override
  String get paywallFeatureSimulations => 'Pregunta qué pasaría si, sin contar';

  @override
  String get stepBalanceShort => 'Saldo';

  @override
  String get stepBudgetShort => 'Presupuesto';

  @override
  String get stepExpenseShort => 'Primer gasto';

  @override
  String get stepSimShort => 'Simulador';

  @override
  String stepsDone(String steps) {
    return 'Hecho: $steps';
  }

  @override
  String get optionalBadge => 'OPCIONAL';

  @override
  String fixedCostsUnchanged(String amount) {
    return 'Costes fijos sin cambios: $amount';
  }

  @override
  String get simNeedsBalance => 'Añade primero tu saldo inicial';

  @override
  String get simNeedsBalanceWhy =>
      'Tu margen necesita un saldo de partida desde el que contar.';

  @override
  String get addOpeningBalance => 'AÑADIR MI SALDO';

  @override
  String get runSimulation => 'SIMULAR';

  @override
  String get runwayUnlimitedHere =>
      'Los ingresos cubren los costes en este plan';

  @override
  String get runwayNoChange => 'Sin cambios';

  @override
  String deltaDaysLonger(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days días más',
      one: '1 día más',
    );
    return '$_temp0';
  }

  @override
  String deltaDaysShorter(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days días menos',
      one: '1 día menos',
    );
    return '$_temp0';
  }

  @override
  String deltaMonthsLonger(int months) {
    String _temp0 = intl.Intl.pluralLogic(
      months,
      locale: localeName,
      other: '$months meses más',
      one: '1 mes más',
    );
    return '$_temp0';
  }

  @override
  String deltaMonthsShorter(int months) {
    String _temp0 = intl.Intl.pluralLogic(
      months,
      locale: localeName,
      other: '$months meses menos',
      one: '1 mes menos',
    );
    return '$_temp0';
  }

  @override
  String get paywallTermsOfUse => 'Términos de uso';

  @override
  String get paywallPrivacyPolicy => 'Política de privacidad';
}
