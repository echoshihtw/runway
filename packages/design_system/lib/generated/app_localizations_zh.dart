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
  String get sysOnline => '系統：上線';

  @override
  String get lifeForce => '跑道准备度';

  @override
  String get statusLabel => '狀態';

  @override
  String get pressureLabel => '壓力';

  @override
  String get metrics => '數據';

  @override
  String get cash => '現金';

  @override
  String get loanPerMonth => '月債務';

  @override
  String get runway => '存活期';

  @override
  String get runOut => '耗盡日';

  @override
  String get cashTimeline => '現金時間軸';

  @override
  String get config => '設定';

  @override
  String get monthlyLoanPayment => '每月貸款還款';

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
  String get noEntries => 'No entries yet\nTap + ADD to log your first entry';

  @override
  String get newLogEntry => '> 新增記錄';

  @override
  String get modifyEntry => '> 修改記錄';

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
  String get purgeEntry => '> 刪除此記錄？';

  @override
  String get scenarioSimulator => '情境模擬器';

  @override
  String get overrideInputs => '覆蓋輸入';

  @override
  String get burnRateOverride => '支出覆蓋';

  @override
  String get simulatedIncome => '模擬月收入';

  @override
  String get simResults => '模擬結果';

  @override
  String get simRunway => '模擬存活期';

  @override
  String get simRunOut => '模擬耗盡日';

  @override
  String get deltaVsActual => '與實際差異';

  @override
  String get deltaRunway => '存活期差異';

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
  String get highLoad => '高負荷';

  @override
  String get language => '語言';

  @override
  String get currency => '貨幣';

  @override
  String get currencySymbolOnly => '仅更改显示符号，金额不会转换。';

  @override
  String get daysShort => '天';

  @override
  String get gettingStarted => '入门指南';

  @override
  String stepsComplete(int completed, int total) {
    return '已完成 $completed/$total';
  }

  @override
  String get stepBalanceLabel => '添加现金余额';

  @override
  String get stepBalanceHint => '你现在有多少钱？';

  @override
  String get stepBudgetLabel => '设置月度预算';

  @override
  String get stepBudgetHint => '房租 + 生活费';

  @override
  String get stepExpenseLabel => '记录第一笔支出';

  @override
  String get stepExpenseHint => '追踪你的花销';

  @override
  String get stepSimLabel => '试试模拟器';

  @override
  String get stepSimHint => '削减支出会怎样？';

  @override
  String get loading => '載入中...';

  @override
  String get navHud => 'HUD';

  @override
  String get navLog => 'LOG';

  @override
  String get navSim => 'SIM';

  @override
  String get typeExpense => '支出';

  @override
  String get typeIncome => '收入';

  @override
  String get typeLoan => '貸款';

  @override
  String get typeRepay => '還款';

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
  String get noActiveLoans => '> 無有效貸款';

  @override
  String get settled => '已結清';

  @override
  String get totalDebtPerMonth => '月債務合計';

  @override
  String get remaining => '剩餘';

  @override
  String get installment => '每期還款';

  @override
  String get paidThisMo => '本月已還';

  @override
  String get monthsLeft => '剩餘月數';

  @override
  String get repaid => '% 已還';

  @override
  String get repay => '還款';

  @override
  String get repayTitle => '> 還款';

  @override
  String get extra => '額外';

  @override
  String get configButton => '設定';

  @override
  String get loanWizardTitle => '貸款精靈';

  @override
  String get whoAndHowMuch => '對象與金額';

  @override
  String get loanTerms => '貸款條件';

  @override
  String get confirmPayment => '確認還款';

  @override
  String get source => '來源';

  @override
  String get nameLender => '名稱 / 借款方';

  @override
  String get loanAmount => '貸款金額';

  @override
  String get annualRate => '年利率 % (0 = 無利息)';

  @override
  String get repaymentMonths => '還款月數';

  @override
  String get computedInstallment => '計算每期還款';

  @override
  String get overrideInstallment => '自訂每月還款';

  @override
  String get monthlyInstallment => '每月還款';

  @override
  String get next => '下一步';

  @override
  String get back => '返回';

  @override
  String get lender => '借款方';

  @override
  String get rate => '利率';

  @override
  String get change => '更改';

  @override
  String get subscriptions => '訂閱';

  @override
  String get noSubscriptions => '> 無有效訂閱';

  @override
  String get subscriptionName => '名稱';

  @override
  String get subscriptionAmount => '金額';

  @override
  String get subscriptionPaymentAmount => '付款金額';

  @override
  String get subscriptionCycle => '計費週期';

  @override
  String get subscriptionCoveragePeriod => '涵蓋期間';

  @override
  String get subscriptionCategory => '類別';

  @override
  String get subscriptionPaymentDate => '付款日期';

  @override
  String get subscriptionNextBilling => '下次扣款';

  @override
  String get subscriptionDaysLeft => '天';

  @override
  String get totalPerMonth => '月合計';

  @override
  String get totalPerYear => '年合計';

  @override
  String get newSubscription => '+ 訂閱';

  @override
  String get editSubscription => '> 編輯訂閱';

  @override
  String get addSubscription => '> 新增訂閱';

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
    return '$count 個月預測';
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
  String get deployableCapital => '可部署資金 — 獨立於生存緩衝金';

  @override
  String get historyEntries => '歷史記錄';

  @override
  String get addEntry => '+ 新增';

  @override
  String get willRemoveLoan => '同時將從負債中移除';

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
  String get planned => '計劃中';

  @override
  String get whatIfAnalysis => '情境分析';

  @override
  String get current => '當前';

  @override
  String get simulate => '模擬';

  @override
  String get simHint => '覆蓋支出或新增收入，查看對存活期的影響';

  @override
  String get simulation => '模擬結果';

  @override
  String get enterValuesToSim => '輸入數值以開始模擬';

  @override
  String get perMonth => '/ 月';

  @override
  String get prefsBudget => '偏好設定 & 預算';

  @override
  String get close => '關閉';

  @override
  String get monthlyBudget => '每月預算';

  @override
  String get rentFixed => '租金 / 固定';

  @override
  String get livingExpenses => '生活費';

  @override
  String get subtotal => '小計';

  @override
  String budgetLeft(String amount) {
    return '剩餘 $amount';
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
  String get totalBudgetPerMonth => '總預算/月';

  @override
  String get setBudget => '設定預算';

  @override
  String get rentFixedCosts => '租金 / 固定費用';

  @override
  String get subscrDebtAuto => '訂閱 + 債務已自動加入';

  @override
  String get futureAssumptions => '预测';

  @override
  String get expectedInflow => '预期流入';

  @override
  String get expectedBurn => '预期支出';

  @override
  String get notSet => '未设置';

  @override
  String get usingCurrentBurn => '使用当前支出';

  @override
  String get assumptionsProjectionOnly => '假设只影响未来预测，不会新增交易记录。';

  @override
  String get setAssumptions => '设置预测';

  @override
  String get expectedMonthlyInflow => '预期每月流入';

  @override
  String get expectedMonthlyBurn => '预期每月支出';

  @override
  String get useCurrentBurn => '使用当前支出';

  @override
  String get futureInflowHint => '在这里输入中性的未来流入：自由接案、合约收入、创作者收入、股息，或任何预期流入。';

  @override
  String get runwayGoal => '跑道目标';

  @override
  String get goal => '目标';

  @override
  String get none => '无';

  @override
  String get target => '目标';

  @override
  String get optional => '选填';

  @override
  String monthsValue(int count) {
    return '$count 个月';
  }

  @override
  String get goalsContextHint => '目标只是为你的跑道加入情境，不是分数。';

  @override
  String get setGoal => '设置目标';

  @override
  String get goalName => '目标名称';

  @override
  String get targetMonths => '目标月数';

  @override
  String get runwayBrand => 'RUNWAY';

  @override
  String get bootRunwayCheck => '> RUNWAY 检查...';

  @override
  String get bootIncomeStopped => '> 如果你的收入今天停止...';

  @override
  String get bootCountingCashDays => '> 正在计算现金天数...';

  @override
  String get bootRemovingComfortFilter => '> 正在移除舒适滤镜...';

  @override
  String get bootRealityCheckReady => '> 现实检查就绪。';

  @override
  String get ifIncomePausedToday => '如果收入今天暂停';

  @override
  String get runwayNeedsCosts => '設定每月支出後即可看到可用月數';

  @override
  String get monthSingular => '个月';

  @override
  String get monthPlural => '个月';

  @override
  String get sustainableWithExpectedInflow => '在预期流入下可持续';

  @override
  String shortByPerMonth(String amount) {
    return '每月短缺 $amount';
  }

  @override
  String goalTargetProgress(int months) {
    return '$months 个月目标。这是目标进度，不是分数。';
  }

  @override
  String get availableCash => '可用现金';

  @override
  String get notEnoughHistory => '历史资料不足';

  @override
  String get projectionSource => '预测来源';

  @override
  String get usingAssumptions => '使用假设';

  @override
  String get fixedPressure => '固定支出';

  @override
  String get plannedEssentials => '计划必要支出';

  @override
  String get recurringCosts => '周期成本';

  @override
  String get debtCommitments => '贷款还款';

  @override
  String get daysUpper => '天';

  @override
  String get yourRunway => '你的生存跑道';

  @override
  String get higherExpenses => '支出增加';

  @override
  String deltaDays(int days) {
    return '$days 天';
  }

  @override
  String get shareSafe => '安全分享';

  @override
  String get shareSafeHint => '不显示存款。不显示支出。只显示你的生存跑道。';

  @override
  String get preparing => '准备中...';

  @override
  String get shareImage => '分享图片';

  @override
  String get shareAsText => '以文字分享';

  @override
  String get goalReached => '目标达成！';

  @override
  String monthsToGoal(int count) {
    return '还差$count个月';
  }

  @override
  String get thisMonth => '本月';

  @override
  String get cashIn => '收入';

  @override
  String get cashOut => '支出';

  @override
  String get netLabel => '净额';

  @override
  String get noActivityThisMonth => '本月暂无活动';

  @override
  String get paywallTermsOfUse => '使用条款';

  @override
  String get paywallPrivacyPolicy => '隐私政策';
}

/// The translations for Chinese, as used in Taiwan (`zh_TW`).
class AppLocalizationsZhTw extends AppLocalizationsZh {
  AppLocalizationsZhTw() : super('zh_TW');

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
  String get metrics => '重點';

  @override
  String get cash => '現金';

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
  String get newLogEntry => '> 新增一筆';

  @override
  String get modifyEntry => '> 編輯紀錄';

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
  String get purgeEntry => '> 要刪除這筆嗎？';

  @override
  String get scenarioSimulator => '情境規劃';

  @override
  String get overrideInputs => '規劃用數字';

  @override
  String get burnRateOverride => '每月支出';

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
  String get navHud => '首頁';

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
  String get typeRepay => '還款';

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
  String get noActiveLoans => '> 目前沒有貸款';

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
  String get repay => '還款';

  @override
  String get repayTitle => '> 還款';

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
  String get noSubscriptions => '> 目前沒有訂閱';

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
  String get editSubscription => '> 編輯訂閱';

  @override
  String get addSubscription => '> 新增訂閱';

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
  String get subtotal => '小計';

  @override
  String budgetLeft(String amount) {
    return '剩餘 $amount';
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
  String get expectedBurn => '預計每月支出';

  @override
  String get notSet => '未設定';

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
  String get bootRunwayCheck => '正在檢查你的跑道...';

  @override
  String get bootIncomeStopped => '看看如果收入暫停會怎樣...';

  @override
  String get bootCountingCashDays => '正在計算你的錢可以支應幾個月...';

  @override
  String get bootRemovingComfortFilter => '把必要支出和雜訊分開...';

  @override
  String get bootRealityCheckReady => '你的財務狀況整理好了。';

  @override
  String get ifIncomePausedToday => '如果今天收入暫停';

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
    return '還差$count個月';
  }

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
  String get paywallTermsOfUse => '使用條款';

  @override
  String get paywallPrivacyPolicy => '隱私權政策';
}
