// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'Runway';

  @override
  String get hudTitle => 'Runway';

  @override
  String get sysOnline => '已就緒';

  @override
  String get lifeForce => '跑道狀態';

  @override
  String get statusLabel => '目前狀況';

  @override
  String get pressureLabel => '每月支出';

  @override
  String get costsIncludeCommitments => '包含訂閱和貸款還款';

  @override
  String get metrics => '重點';

  @override
  String get cash => '現金';

  @override
  String get owed => '欠款';

  @override
  String runsOut(String date) {
    return '$date 會用完';
  }

  @override
  String get loanPerMonth => '月債務';

  @override
  String get runway => '可撐多久';

  @override
  String get runOut => '用完時間';

  @override
  String get cashTimeline => '現金時間軸';

  @override
  String get config => '設定';

  @override
  String get monthlyLoanPayment => '每月貸款';

  @override
  String get tapToSet => '點擊設定';

  @override
  String get edit => '編輯';

  @override
  String get save => '儲存';

  @override
  String get clear => '清除';

  @override
  String get transactionLog => '交易記錄';

  @override
  String get newEntry => '+ 新增';

  @override
  String get noEntries => '還沒有任何紀錄\n點 + 新增你的第一筆資料';

  @override
  String get newLogEntry => '新增一筆';

  @override
  String get modifyEntry => '編輯紀錄';

  @override
  String get type => '類型';

  @override
  String get date => '日期';

  @override
  String get calcMonth => '計算月份';

  @override
  String get amount => '金額';

  @override
  String get noteOptional => '備註（選填）';

  @override
  String get confirm => '確認';

  @override
  String get abort => '取消';

  @override
  String get purgeEntry => '刪除這筆記錄？';

  @override
  String get scenarioSimulator => '情境規劃';

  @override
  String get overrideInputs => '規劃用數字';

  @override
  String get burnRateOverride => '房租 + 生活費 / 月';

  @override
  String get simulatedIncome => '每月收入變化';

  @override
  String get simResults => '預估結果';

  @override
  String get simRunway => '預估跑道';

  @override
  String get simRunOut => '預估用完時間';

  @override
  String get deltaVsActual => '和現在相比';

  @override
  String get deltaRunway => '跑道變化';

  @override
  String get resetSim => '重置模擬';

  @override
  String get months => '個月';

  @override
  String get stable => '穩定';

  @override
  String get caution => '警告';

  @override
  String get critical => '危急';

  @override
  String get low => '低';

  @override
  String get moderate => '中等';

  @override
  String get highLoad => '壓力偏高';

  @override
  String get language => '語言';

  @override
  String get currency => '貨幣';

  @override
  String get currencySymbolOnly => '僅變更顯示符號，金額不會轉換。';

  @override
  String get daysShort => '天';

  @override
  String get gettingStarted => '入門指南';

  @override
  String stepsComplete(int completed, int total) {
    return '已完成 $completed/$total';
  }

  @override
  String get stepBalanceLabel => '新增現金餘額';

  @override
  String get stepBalanceHint => '你現在有多少錢？';

  @override
  String get stepBudgetLabel => '設定每月預算';

  @override
  String get stepBudgetHint => '房租 + 生活費';

  @override
  String get stepExpenseLabel => '記錄第一筆支出';

  @override
  String get stepExpenseHint => '追蹤你的花費';

  @override
  String get stepSimLabel => '試試模擬器';

  @override
  String get stepSimHint => '減少支出會怎樣？';

  @override
  String get loading => '載入中...';

  @override
  String get navHud => '總覽';

  @override
  String get navLog => 'LOG';

  @override
  String get navSim => '規劃';

  @override
  String get typeExpense => '支出';

  @override
  String get typeIncome => '收入';

  @override
  String get typeLoan => '貸款';

  @override
  String get typeRepay => '貸款還款';

  @override
  String get typeOpening => '初始';

  @override
  String get typeSubscription => '訂閱';

  @override
  String subscriptionPaidQuestion(String amount, String name, String date) {
    return '你在$date支付了$name的$amount嗎？';
  }

  @override
  String subscriptionChargesDue(int count, String amount) {
    return '$count 筆訂閱費用待確認 — $amount';
  }

  @override
  String get subscriptionConfirmAll => '全部確認';

  @override
  String get subscriptionReviewEach => '逐筆確認';

  @override
  String get subscriptionPaidYes => '是，記錄下來';

  @override
  String get subscriptionChargeFailed => '無法記錄。請檢查訂閱金額。';

  @override
  String get subscriptionSaveFailed => '無法儲存訂閱。尚未新增。';

  @override
  String get loanSaveFailed => '貸款沒存成功，還沒加進去。';

  @override
  String get subscriptionPaidNo => '否';

  @override
  String get subscriptionWhatHappened => '發生了什麼？';

  @override
  String get subscriptionReasonCancelled => '我已取消';

  @override
  String get subscriptionReasonPriceChanged => '價格變了';

  @override
  String get subscriptionReasonNotPaid => '我沒有支付';

  @override
  String get deleteSubscription => '刪除訂閱';

  @override
  String get deleteSubscriptionKeepsEntries => '停止未來的記錄。已記錄的付款會保留。';

  @override
  String get liabilities => '負債';

  @override
  String get noActiveLoans => '目前沒有貸款';

  @override
  String get newLoan => '+ 貸款';

  @override
  String get spendOnWhat => '剛剛買了什麼？';

  @override
  String get moneyCameInInstead => '剛剛收到錢？';

  @override
  String get logIncome => '新增收入';

  @override
  String get presetCoffee => '咖啡';

  @override
  String get presetCoffeeNote => '咖啡';

  @override
  String get presetLunch => '午餐';

  @override
  String get presetLunchNote => '午餐';

  @override
  String get presetDinner => '晚餐';

  @override
  String get presetDinnerNote => '晚餐';

  @override
  String get presetTransport => '交通';

  @override
  String get presetTransportNote => '交通';

  @override
  String get presetGroceries => '採買';

  @override
  String get presetGroceriesNote => '採買';

  @override
  String get presetSomethingElse => '其他';

  @override
  String freeEntriesUsed(int used, int free) {
    return '免費記錄 $free 筆已用 $used 筆';
  }

  @override
  String freeSimulationsUsed(int used, int free) {
    return '免費模擬 $free 次已用 $used 次';
  }

  @override
  String get settled => '已結清';

  @override
  String get totalDebtPerMonth => '每月債務';

  @override
  String get remaining => '剩餘';

  @override
  String get installment => '每月還款';

  @override
  String get paidThisMo => '本月已還';

  @override
  String get monthsLeft => '剩餘月數';

  @override
  String get repaid => '% 已還';

  @override
  String get stillPaying => '借的錢已經還完了，但還要付到期滿。';

  @override
  String get markSettled => '標記為已結清';

  @override
  String get markSettledExplain => '每月還款不再計入，這筆貸款也會永久從清單上移除。紀錄會留著。';

  @override
  String get repay => '還款';

  @override
  String get repayTitle => '還款';

  @override
  String get extra => '額外';

  @override
  String get configButton => '設定';

  @override
  String get loanWizardTitle => '新增貸款';

  @override
  String get whoAndHowMuch => '借款對象與金額';

  @override
  String get loanTerms => '貸款條件';

  @override
  String get confirmPayment => '確認還款';

  @override
  String get source => '類型';

  @override
  String get nameLender => '名稱 / 貸款方';

  @override
  String get loanAmount => '貸款金額';

  @override
  String get annualRate => '年利率 % (0 = 無利息)';

  @override
  String get repaymentMonths => '還款月數';

  @override
  String get computedInstallment => '試算每月還款';

  @override
  String get overrideInstallment => '自訂每月還款';

  @override
  String get monthlyInstallment => '每月要還';

  @override
  String get next => '下一步';

  @override
  String get back => '返回';

  @override
  String get lender => '貸款方';

  @override
  String get rate => '利率';

  @override
  String get change => '更改';

  @override
  String get subscriptions => '訂閱';

  @override
  String get noSubscriptions => '目前沒有訂閱';

  @override
  String get subscriptionName => '名稱';

  @override
  String get subscriptionAmount => '金額';

  @override
  String get subscriptionPaymentAmount => '付款金額';

  @override
  String get subscriptionCycle => '扣款週期';

  @override
  String get subscriptionCoveragePeriod => '這筆費用涵蓋多久';

  @override
  String get subscriptionCategory => '類別';

  @override
  String get subscriptionPaymentDate => '付款日期';

  @override
  String get subscriptionNextBilling => '下次付款';

  @override
  String get subscriptionDaysLeft => '天';

  @override
  String get totalPerMonth => '月合計';

  @override
  String get totalPerYear => '年合計';

  @override
  String get newSubscription => '+ 訂閱';

  @override
  String get editSubscription => '編輯訂閱';

  @override
  String get addSubscription => '新增訂閱';

  @override
  String get personal => '個人';

  @override
  String get business => '商業';

  @override
  String get weekly => '每週';

  @override
  String get monthly => '每月';

  @override
  String get quarterly => '每季';

  @override
  String get yearly => '每年';

  @override
  String get subscrPerMonth => '/ 月';

  @override
  String get loans => '貸款';

  @override
  String activeCount(int count) {
    return '$count 筆有效';
  }

  @override
  String get repayLoan => '還款';

  @override
  String get repaymentAmount => '還款金額';

  @override
  String get cancel => '取消';

  @override
  String get paid => '✓ 已還清';

  @override
  String get subscrPerYear => '/ 年';

  @override
  String get removeConfirm => '刪除？';

  @override
  String get remove => '刪除';

  @override
  String monthsProjected(int count) {
    return '往後 $count 個月';
  }

  @override
  String get budgetPerMonth => '預算/月';

  @override
  String get breakdown => '明細';

  @override
  String get safetyFund => '安全基金';

  @override
  String get safety => '安全';

  @override
  String get deployableCapital => '保留安全緩衝後，還能運用的資金';

  @override
  String get historyEntries => '歷史記錄';

  @override
  String get addEntry => '+ 新增';

  @override
  String get willRemoveLoan => '也會一起從貸款清單移除';

  @override
  String get delete => '刪除';

  @override
  String get dataSection => '你的資料';

  @override
  String get deleteAllDataBody => '從這台裝置清除所有紀錄、貸款、訂閱與設定。Runway Pro 仍保持解鎖。';

  @override
  String get deleteAllDataButton => '刪除所有資料';

  @override
  String get deleteAllDataConfirmTitle => '要刪除全部嗎？';

  @override
  String get deleteAllDataConfirmBody => '資料會從這台裝置清除，且無法復原。Runway 將從頭開始。';

  @override
  String get deleteAllDataConfirmAction => '全部刪除';

  @override
  String get planned => '規劃中';

  @override
  String get whatIfAnalysis => '如果情況改變';

  @override
  String get current => '現在';

  @override
  String get simulate => '規劃';

  @override
  String get simHint => '調整每月支出或收入，看看跑道會怎麼變';

  @override
  String get simulation => '情境結果';

  @override
  String get enterValuesToSim => '輸入數字後，就能看到影響';

  @override
  String get perMonth => '/ 月';

  @override
  String get prefsBudget => '偏好與預算';

  @override
  String get close => '關閉';

  @override
  String get monthlyBudget => '每月預算';

  @override
  String get rentFixed => '房租 / 固定支出';

  @override
  String get livingExpenses => '生活費';

  @override
  String get budgetRuleHint => '支出只是把預算用掉 — 超支才會多花錢';

  @override
  String get subtotal => '小計';

  @override
  String budgetLeft(String amount) {
    return '剩餘 $amount';
  }

  @override
  String spentOfBudget(String spent, String budget) {
    return '$budget 用了 $spent';
  }

  @override
  String budgetOver(String amount) {
    return '超出預算 $amount';
  }

  @override
  String dailyAllowance(String amount, int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '每天 $amount，還有 $days 天',
      one: '今天可用 $amount',
    );
    return '$_temp0';
  }

  @override
  String get noLivingExpensesThisMonth => '本月還沒有生活費紀錄';

  @override
  String get totalBudgetPerMonth => '每月總預算';

  @override
  String get setBudget => '設定預算';

  @override
  String get rentFixedCosts => '房租 / 固定支出';

  @override
  String get subscrDebtAuto => '訂閱和債務會自動加進來';

  @override
  String get futureAssumptions => '預測';

  @override
  String get expectedInflow => '預計每月收入';

  @override
  String get everyMonth => '每個月';

  @override
  String get monthlySurplus => '結餘';

  @override
  String get monthlyDeficit => '不足';

  @override
  String get setExpectedIncome => '設定預期收入';

  @override
  String get expectedBurn => '預計每月支出';

  @override
  String get notSet => '未設定';

  @override
  String get settingsFailedToLoad => '無法載入這些設定。為避免覆寫，暫時無法編輯。';

  @override
  String get usingCurrentBurn => '先用目前支出估算';

  @override
  String get assumptionsProjectionOnly => '這些數字只用來預估未來，不會變成交易紀錄。';

  @override
  String get setAssumptions => '設定預測';

  @override
  String get expectedMonthlyInflow => '預計每月收入';

  @override
  String get expectedMonthlyBurn => '預計每月支出';

  @override
  String get useCurrentBurn => '使用目前支出';

  @override
  String get futureInflowHint => '可以填接案、合約收入、創作者收入、股息，或任何你預期會進來的錢。';

  @override
  String get forecastDoesNotMoveRunway =>
      '收入不會改變可用月數。可用月數是沒收入時現金能撐多久，這裡只顯示這個月是增加還是減少。';

  @override
  String get runwayGoal => '跑道目標';

  @override
  String get goal => '目標';

  @override
  String get none => '無';

  @override
  String get target => '目標';

  @override
  String get optional => '選填';

  @override
  String monthsValue(int count) {
    return '$count 個月';
  }

  @override
  String get goalsContextHint => '目標只是拿來對照你的跑道，不是在替你打分數。';

  @override
  String get setGoal => '設定目標';

  @override
  String get goalName => '目標名稱';

  @override
  String get targetMonths => '目標月數';

  @override
  String get runwayBrand => 'RUNWAY';

  @override
  String get runwayBasisBudget => '照你的預算算，假設今天起沒收入';

  @override
  String get runwayBasisSpending => '照你實際花的算，假設今天起沒收入';

  @override
  String get runwayBasisAssumption => '照你設定的成本算，假設今天起沒收入';

  @override
  String computedCost(String amount) {
    return '照預算和記錄算出來是：$amount';
  }

  @override
  String get runwayNeedsCosts => '設定每月支出後即可看到可用月數';

  @override
  String get monthSingular => '個月';

  @override
  String get monthPlural => '個月';

  @override
  String get sustainableWithExpectedInflow => '照你的預期收入來看，可以持續下去';

  @override
  String shortByPerMonth(String amount) {
    return '每月還差 $amount';
  }

  @override
  String goalTargetProgress(int months) {
    return '$months 個月目標。這是離目標的距離，不是分數。';
  }

  @override
  String get availableCash => '目前現金';

  @override
  String get notEnoughHistory => '資料還不夠';

  @override
  String get projectionSource => '估算方式';

  @override
  String get usingAssumptions => '使用你的規劃數字';

  @override
  String get fixedPressure => '固定支出';

  @override
  String get plannedEssentials => '預計必要支出';

  @override
  String get recurringCosts => '固定扣款';

  @override
  String get debtCommitments => '貸款還款';

  @override
  String get daysUpper => '天';

  @override
  String get yourRunway => '你的跑道';

  @override
  String get higherExpenses => '支出增加';

  @override
  String deltaDays(int days) {
    return '$days 天';
  }

  @override
  String get shareSafe => '安全分享';

  @override
  String get shareSafeHint => '不顯示存款和支出，只分享你的跑道。';

  @override
  String get preparing => '準備中...';

  @override
  String get shareImage => '分享圖片';

  @override
  String get shareAsText => '以文字分享';

  @override
  String get goalReached => '目標達成！';

  @override
  String monthsToGoal(int count) {
    return '還要再存 $count 個月';
  }

  @override
  String get goalCashTarget => '目標金額';

  @override
  String goalCashTargetFrom(int count, String cost) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 個月 × 每月 $cost',
    );
    return '$_temp0';
  }

  @override
  String get goalCashToGo => '還差';

  @override
  String get thisMonth => '本月';

  @override
  String get cashIn => '收入';

  @override
  String get cashOut => '支出';

  @override
  String get netLabel => '淨額';

  @override
  String get noActivityThisMonth => '本月暫無活動';

  @override
  String get onboardingSkip => '跳過';

  @override
  String get onboardingWelcomeTitle => '別再猜\n你的錢能撐多久。';

  @override
  String get onboardingWelcomeBody => '不用註冊，也不連銀行。';

  @override
  String get onboardingGetStarted => '開始吧';

  @override
  String get onboardingPrivacyTitle => '你的資料，\n只在你手機裡。';

  @override
  String get onboardingPrivacyBody => '沒有伺服器，就沒有外洩的問題。';

  @override
  String get onboardingPrivacyEncrypted => '在手機上加密';

  @override
  String get onboardingPrivacyOnDevice => '數字不會離開你的手機';

  @override
  String get onboardingPrivacyHidden => '切到別的 App 就自動遮起來';

  @override
  String get onboardingPrivacyDelete => '想刪就刪，馬上清光';

  @override
  String get onboardingIUnderstand => '了解';

  @override
  String get onboardingFirstActionTitle => '一個數字\n就設定完成。';

  @override
  String get onboardingFirstActionBody => '只要現金餘額，其他都不用。';

  @override
  String get onboardingAddMyBalance => '輸入我的餘額';

  @override
  String get paywallUnlock => '解鎖 RUNWAY PRO';

  @override
  String get paywallLoadingPrice => '價格載入中...';

  @override
  String get paywallStoreUnreachable => '連不上商店，看看網路再試一次。';

  @override
  String paywallOneTimePurchase(String price) {
    return '$price 買斷。這個 App 幫你算訂閱，自己當然不會變成訂閱。';
  }

  @override
  String get paywallUnavailable => 'Pro 現在暫時買不到，晚點再試試。';

  @override
  String get paywallRestore => '恢復購買';

  @override
  String get paywallMaybeLater => '下次再說';

  @override
  String get paywallPurchaseFailed => '購買沒成功，再試一次吧。';

  @override
  String get paywallSomethingWrong => '出了點問題，再試一次吧。';

  @override
  String get paywallNoPreviousPurchase => '找不到之前的購買紀錄。';

  @override
  String get paywallRestoreFailed => '恢復沒成功，再試一次吧。';

  @override
  String paywallTitleEntries(int count) {
    return '$count 筆免費紀錄用完了。\nPro 就是讓這個數字一直準。';
  }

  @override
  String paywallTitleSimulations(int count) {
    return '$count 次免費模擬用完了。\nPro 讓你想試幾次就試幾次。';
  }

  @override
  String get paywallTitleDefault => '解鎖 Runway Pro。';

  @override
  String get paywallFeatureEntries => '全部都記，數字才不會跑掉';

  @override
  String get paywallFeatureSimulations => '想模擬幾次就幾次';

  @override
  String get stepBalanceShort => '現金餘額';

  @override
  String get stepBudgetShort => '預算';

  @override
  String get stepExpenseShort => '第一筆支出';

  @override
  String get stepSimShort => '模擬器';

  @override
  String stepsDone(String steps) {
    return '搞定：$steps';
  }

  @override
  String get optionalBadge => '可選';

  @override
  String fixedCostsUnchanged(String amount) {
    return '固定支出照舊：$amount';
  }

  @override
  String get simNeedsBalance => '先新增你的期初餘額';

  @override
  String get simNeedsBalanceWhy => '可用月數要從一個起始餘額開始算。';

  @override
  String get addOpeningBalance => '新增我的餘額';

  @override
  String get runSimulation => '開始模擬';

  @override
  String get runwayUnlimitedHere => '在這個計畫裡，收入蓋得過支出';

  @override
  String get runwayNoChange => '沒有變化';

  @override
  String deltaDaysLonger(int days) {
    return '多 $days 天';
  }

  @override
  String deltaDaysShorter(int days) {
    return '少 $days 天';
  }

  @override
  String deltaMonthsLonger(int months) {
    return '多 $months 個月';
  }

  @override
  String deltaMonthsShorter(int months) {
    return '少 $months 個月';
  }

  @override
  String get paywallTermsOfUse => '使用條款';

  @override
  String get paywallPrivacyPolicy => '隱私權政策';
}
