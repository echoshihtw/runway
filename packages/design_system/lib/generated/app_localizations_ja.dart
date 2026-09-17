// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => 'Runway';

  @override
  String get hudTitle => 'Runway';

  @override
  String get sysOnline => 'システム：オンライン';

  @override
  String get lifeForce => 'ランウェイ準備度';

  @override
  String get statusLabel => 'ステータス';

  @override
  String get pressureLabel => 'プレッシャー';

  @override
  String get metrics => 'メトリクス';

  @override
  String get cash => '現金';

  @override
  String get loanPerMonth => '月間債務';

  @override
  String get runway => '生存期間';

  @override
  String get runOut => '枯渇日';

  @override
  String get cashTimeline => '現金タイムライン';

  @override
  String get config => '設定';

  @override
  String get monthlyLoanPayment => '月間ローン返済';

  @override
  String get tapToSet => 'タップして設定';

  @override
  String get edit => '編集';

  @override
  String get save => '保存';

  @override
  String get clear => 'クリア';

  @override
  String get loanAffectsInfo => '> 月間返済はプレッシャー比率と投資可能額に影響します';

  @override
  String get transactionLog => '取引ログ';

  @override
  String get newEntry => '+ 新規';

  @override
  String get noEntries => 'No entries yet\nTap + ADD to log your first entry';

  @override
  String get newLogEntry => '> 新規エントリー';

  @override
  String get modifyEntry => '> エントリー修正';

  @override
  String get type => 'タイプ';

  @override
  String get date => '日付';

  @override
  String get calcMonth => '計算月';

  @override
  String get amount => '金額';

  @override
  String get noteOptional => 'メモ（任意）';

  @override
  String get confirm => '確認';

  @override
  String get abort => '中止';

  @override
  String get purgeEntry => '> このエントリーを削除？';

  @override
  String get scenarioSimulator => 'シナリオシミュレーター';

  @override
  String get overrideInputs => 'オーバーライド入力';

  @override
  String get burnRateOverride => '支出オーバーライド';

  @override
  String get simulatedIncome => 'シミュレート収入/月';

  @override
  String get simResults => 'シム結果';

  @override
  String get simRunway => 'シム生存期間';

  @override
  String get simRunOut => 'シム枯渇日';

  @override
  String get deltaVsActual => '実際との差分';

  @override
  String get deltaRunway => '生存期間差分';

  @override
  String get resetSim => 'シムリセット';

  @override
  String get months => 'ヶ月';

  @override
  String get stable => '安定';

  @override
  String get caution => '注意';

  @override
  String get critical => '危機';

  @override
  String get low => '低';

  @override
  String get moderate => '中程度';

  @override
  String get highLoad => '高負荷';

  @override
  String get language => '言語';

  @override
  String get currency => '通貨';

  @override
  String get currencySymbolOnly => '表示記号のみ変更されます。金額は換算されません。';

  @override
  String get daysShort => '日';

  @override
  String get gettingStarted => 'はじめに';

  @override
  String stepsComplete(int completed, int total) {
    return '$total中$completed完了';
  }

  @override
  String get stepBalanceLabel => '残高を追加する';

  @override
  String get stepBalanceHint => '今いくら持っていますか？';

  @override
  String get stepBudgetLabel => '月額予算を設定する';

  @override
  String get stepBudgetHint => '家賃＋生活費';

  @override
  String get stepExpenseLabel => '最初の支出を記録する';

  @override
  String get stepExpenseHint => 'お金の流れを把握する';

  @override
  String get stepSimLabel => 'シミュレーターを試す';

  @override
  String get stepSimHint => '支出を減らしたらどうなる？';

  @override
  String get loading => '読み込み中...';

  @override
  String get navHud => 'HUD';

  @override
  String get navLog => 'LOG';

  @override
  String get navSim => 'SIM';

  @override
  String get typeExpense => '支出';

  @override
  String get typeIncome => '収入';

  @override
  String get typeLoan => 'ローン';

  @override
  String get typeRepay => '返済';

  @override
  String get typeOpening => '開始残高';

  @override
  String get typeSubscription => 'サブスク';

  @override
  String subscriptionPaidQuestion(String amount, String name, String date) {
    return '$dateに$nameの$amountを支払いましたか？';
  }

  @override
  String subscriptionChargesDue(int count, String amount) {
    return '未確認のサブスク請求 $count 件 — $amount';
  }

  @override
  String get subscriptionConfirmAll => 'すべて記録する';

  @override
  String get subscriptionReviewEach => '1件ずつ確認';

  @override
  String get subscriptionPaidYes => 'はい、記録する';

  @override
  String get subscriptionPaidNo => 'いいえ';

  @override
  String get subscriptionWhatHappened => '理由は？';

  @override
  String get subscriptionReasonCancelled => '解約した';

  @override
  String get subscriptionReasonPriceChanged => '料金が変わった';

  @override
  String get subscriptionReasonNotPaid => '支払っていない';

  @override
  String get deleteSubscription => 'サブスクを削除';

  @override
  String get deleteSubscriptionKeepsEntries => '今後の記録を停止します。すでに記録された支払いは残ります。';

  @override
  String get liabilities => '負債';

  @override
  String get noActiveLoans => '> アクティブなローンなし';

  @override
  String get settled => '完済';

  @override
  String get totalDebtPerMonth => '月間債務合計';

  @override
  String get remaining => '残高';

  @override
  String get installment => '月払い';

  @override
  String get paidThisMo => '今月支払い済み';

  @override
  String get monthsLeft => '残り月数';

  @override
  String get repaid => '% 返済済み';

  @override
  String get repay => '返済';

  @override
  String get repayTitle => '> 返済';

  @override
  String get extra => '追加';

  @override
  String get configButton => '設定';

  @override
  String get loanWizardTitle => 'ローンウィザード';

  @override
  String get whoAndHowMuch => '相手と金額';

  @override
  String get loanTerms => 'ローン条件';

  @override
  String get confirmPayment => '支払い確認';

  @override
  String get source => '種別';

  @override
  String get nameLender => '名前 / 貸し手';

  @override
  String get loanAmount => '借入金額';

  @override
  String get annualRate => '年利率 % (0 = 無利息)';

  @override
  String get repaymentMonths => '返済月数';

  @override
  String get computedInstallment => '計算された月払い';

  @override
  String get overrideInstallment => '月払いを上書き';

  @override
  String get monthlyInstallment => '月払い';

  @override
  String get next => '次へ';

  @override
  String get back => '戻る';

  @override
  String get lender => '貸し手';

  @override
  String get rate => '利率';

  @override
  String get change => '変更';

  @override
  String get subscriptions => 'サブスクリプション';

  @override
  String get noSubscriptions => '> アクティブなサブスクなし';

  @override
  String get subscriptionName => '名前';

  @override
  String get subscriptionAmount => '金額';

  @override
  String get subscriptionPaymentAmount => '支払金額';

  @override
  String get subscriptionCycle => '請求サイクル';

  @override
  String get subscriptionCoveragePeriod => '対象期間';

  @override
  String get subscriptionCategory => 'カテゴリ';

  @override
  String get subscriptionPaymentDate => '支払日';

  @override
  String get subscriptionNextBilling => '次回請求日';

  @override
  String get subscriptionDaysLeft => '日';

  @override
  String get totalPerMonth => '月合計';

  @override
  String get totalPerYear => '年合計';

  @override
  String get newSubscription => '+ サブスク';

  @override
  String get editSubscription => '> サブスク編集';

  @override
  String get addSubscription => '> 新規サブスク';

  @override
  String get personal => '個人';

  @override
  String get business => 'ビジネス';

  @override
  String get weekly => '毎週';

  @override
  String get monthly => '毎月';

  @override
  String get quarterly => '四半期';

  @override
  String get yearly => '毎年';

  @override
  String get subscrPerMonth => '/ 月';

  @override
  String get loans => 'ローン';

  @override
  String activeCount(int count) {
    return '$count 件有効';
  }

  @override
  String get repayLoan => 'ローン返済';

  @override
  String get repaymentAmount => '返済金額';

  @override
  String get cancel => 'キャンセル';

  @override
  String get paid => '✓ 完済';

  @override
  String get subscrPerYear => '/ 年';

  @override
  String get removeConfirm => '削除？';

  @override
  String get remove => '削除';

  @override
  String monthsProjected(int count) {
    return '$countヶ月予測';
  }

  @override
  String get budgetPerMonth => '予算/月';

  @override
  String get breakdown => '明細';

  @override
  String get safetyFund => '安全資金';

  @override
  String get safety => '安全';

  @override
  String get deployableCapital => '運用可能資金 — 生存バッファとは別';

  @override
  String get historyEntries => '履歴 & 入力';

  @override
  String get addEntry => '+ 追加';

  @override
  String get willRemoveLoan => '負債からも削除されます';

  @override
  String get delete => '削除';

  @override
  String get dataSection => 'データ';

  @override
  String get deleteAllDataBody =>
      'この端末から、すべての記録、ローン、サブスクリプション、設定を消去します。Runway Pro のロック解除はそのままです。';

  @override
  String get deleteAllDataButton => 'すべてのデータを削除';

  @override
  String get deleteAllDataConfirmTitle => 'すべて削除しますか？';

  @override
  String get deleteAllDataConfirmBody =>
      'データはこの端末から消去され、復元できません。Runway は最初から始まります。';

  @override
  String get deleteAllDataConfirmAction => 'すべて削除';

  @override
  String get planned => '予定';

  @override
  String get whatIfAnalysis => '仮定分析';

  @override
  String get current => '現在';

  @override
  String get simulate => 'シミュレート';

  @override
  String get simHint => '支出や収入を変更してランウェイへの影響を確認';

  @override
  String get simulation => 'シミュレーション';

  @override
  String get enterValuesToSim => '上の値を入力してシミュレート';

  @override
  String get perMonth => '/ 月';

  @override
  String get prefsBudget => '設定 & 予算';

  @override
  String get close => '閉じる';

  @override
  String get monthlyBudget => '月間予算';

  @override
  String get rentFixed => '家賃 / 固定費';

  @override
  String get livingExpenses => '生活費';

  @override
  String get subtotal => '小計';

  @override
  String budgetLeft(String amount) {
    return '残り $amount';
  }

  @override
  String budgetOver(String amount) {
    return '予算超過 $amount';
  }

  @override
  String dailyAllowance(String amount, int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '1日 $amount、残り $days 日',
      one: '今日は $amount',
    );
    return '$_temp0';
  }

  @override
  String get noLivingExpensesThisMonth => '今月の生活費はまだありません';

  @override
  String get totalBudgetPerMonth => '予算合計/月';

  @override
  String get setBudget => '予算設定';

  @override
  String get rentFixedCosts => '家賃 / 固定費用';

  @override
  String get subscrDebtAuto => 'サブスク + 負債は自動加算';

  @override
  String get futureAssumptions => '予測';

  @override
  String get expectedInflow => '想定流入';

  @override
  String get expectedBurn => '想定支出';

  @override
  String get notSet => '未設定';

  @override
  String get usingCurrentBurn => '現在の支出を使用';

  @override
  String get assumptionsProjectionOnly => '前提は将来予測だけに影響します。取引記録は作成されません。';

  @override
  String get setAssumptions => '予測を設定';

  @override
  String get expectedMonthlyInflow => '想定月間流入';

  @override
  String get expectedMonthlyBurn => '想定月間支出';

  @override
  String get useCurrentBurn => '現在の支出を使用';

  @override
  String get futureInflowHint => 'フリーランス、契約収入、クリエイター収入、配当など、想定される将来の流入を入力します。';

  @override
  String get runwayGoal => 'ランウェイ目標';

  @override
  String get goal => '目標';

  @override
  String get none => 'なし';

  @override
  String get target => 'ターゲット';

  @override
  String get optional => '任意';

  @override
  String monthsValue(int count) {
    return '$countか月';
  }

  @override
  String get goalsContextHint => '目標はランウェイに文脈を加えるものです。スコアではありません。';

  @override
  String get setGoal => '目標を設定';

  @override
  String get goalName => '目標名';

  @override
  String get targetMonths => '目標月数';

  @override
  String get runwayBrand => 'RUNWAY';

  @override
  String get bootRunwayCheck => '> RUNWAYチェック...';

  @override
  String get bootIncomeStopped => '> 今日、収入が止まったら...';

  @override
  String get bootCountingCashDays => '> お金で何か月まかなえるか計算中...';

  @override
  String get bootRemovingComfortFilter => '> 安心フィルターを解除中...';

  @override
  String get bootRealityCheckReady => '> 現実チェック準備完了。';

  @override
  String get ifIncomePausedToday => '今日、収入が止まったら';

  @override
  String get runwayNeedsCosts => '毎月のコストを設定すると残り月数がわかります';

  @override
  String get monthSingular => 'か月';

  @override
  String get monthPlural => 'か月';

  @override
  String get sustainableWithExpectedInflow => '想定流入で持続可能';

  @override
  String shortByPerMonth(String amount) {
    return '月あたり $amount 不足';
  }

  @override
  String goalTargetProgress(int months) {
    return '$monthsか月目標。これは目標への進捗であり、スコアではありません。';
  }

  @override
  String get availableCash => '利用可能な現金';

  @override
  String get notEnoughHistory => '履歴が不足しています';

  @override
  String get projectionSource => '予測ソース';

  @override
  String get usingAssumptions => '前提を使用';

  @override
  String get fixedPressure => '固定費';

  @override
  String get plannedEssentials => '計画上の必需支出';

  @override
  String get recurringCosts => '定期コスト';

  @override
  String get debtCommitments => 'ローン支払い';

  @override
  String get daysUpper => '日';

  @override
  String get yourRunway => 'あなたのランウェイ';

  @override
  String get higherExpenses => '支出増加';

  @override
  String deltaDays(int days) {
    return '$days日';
  }

  @override
  String get shareSafe => '安全に共有';

  @override
  String get shareSafeHint => '貯金額も支出も出しません。ランウェイだけ。';

  @override
  String get preparing => '準備中...';

  @override
  String get shareImage => '画像を共有';

  @override
  String get shareAsText => 'テキストで共有';

  @override
  String get goalReached => '目標達成！';

  @override
  String monthsToGoal(int count) {
    return 'あと$countヶ月';
  }

  @override
  String get thisMonth => '今月';

  @override
  String get cashIn => '収入';

  @override
  String get cashOut => '支出';

  @override
  String get netLabel => '純額';

  @override
  String get noActivityThisMonth => '今月はまだ活動がありません';

  @override
  String get paywallTermsOfUse => '利用規約';

  @override
  String get paywallPrivacyPolicy => 'プライバシーポリシー';
}
