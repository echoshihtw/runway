import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';
import '../../../shared/money_field.dart';
import 'package:intl/intl.dart';
import 'dart:math';

class LoanWizard extends StatefulWidget {
  /// Returns false when the write was refused, so the wizard can stay open
  /// with the typing intact instead of closing as though the loan existed.
  final Future<bool> Function(
    double loanAmount,
    double monthlyPayment,
    int termMonths,
    DateTime date,
    String? note,
  )
  onSubmit;

  const LoanWizard({super.key, required this.onSubmit});

  @override
  State<LoanWizard> createState() => _LoanWizardState();
}

class _LoanWizardState extends State<LoanWizard>
    with SingleTickerProviderStateMixin {
  int _step = 0;
  String? _error;
  bool _saving = false;
  late AnimationController _slideCtrl;
  late Animation<Offset> _slideAnim;

  final _amountCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _rateCtrl = TextEditingController();
  final _monthsCtrl = TextEditingController();
  final _paymentCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();

  DateTime _date = DateTime.now();
  bool _overridePayment = false;
  double? _computedPayment;
  String _source = 'BANK';

  static const _totalSteps = 3;
  static const _sources = ['BANK', 'FRIEND', 'FAMILY', 'OTHER'];

  @override
  void initState() {
    super.initState();
    _slideCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(1, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideCtrl, curve: Curves.easeOut));
    _slideCtrl.forward();
  }

  @override
  void dispose() {
    _slideCtrl.dispose();
    _amountCtrl.dispose();
    _nameCtrl.dispose();
    _rateCtrl.dispose();
    _monthsCtrl.dispose();
    _paymentCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  void _next() {
    if (_step < _totalSteps - 1) {
      _slideCtrl.reset();
      setState(() => _step++);
      _slideCtrl.forward();
    }
  }

  void _prev() {
    if (_step > 0) setState(() => _step--);
  }

  void _compute() {
    final amount = double.tryParse(_amountCtrl.text.trim());
    final months = int.tryParse(_monthsCtrl.text.trim());
    final rate = double.tryParse(_rateCtrl.text.trim());
    if (amount == null || months == null || months == 0) {
      setState(() => _computedPayment = null);
      return;
    }
    double payment;
    if (rate == null || rate == 0) {
      payment = amount / months;
    } else {
      final mr = rate / 100 / 12;
      payment = amount * (mr * pow(1 + mr, months)) / (pow(1 + mr, months) - 1);
    }
    setState(() {
      _computedPayment = payment;
      if (!_overridePayment) _paymentCtrl.text = moneyField(payment);
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (ctx, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppColors.gold,
            surface: AppColors.surface,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _date = picked);
  }

  bool get _step0Valid =>
      _nameCtrl.text.trim().isNotEmpty &&
      double.tryParse(_amountCtrl.text.trim()) != null;
  bool get _step1Valid => int.tryParse(_monthsCtrl.text.trim()) != null;
  bool get _step2Valid => double.tryParse(_paymentCtrl.text.trim()) != null;
  bool get _valid => switch (_step) {
    0 => _step0Valid,
    1 => _step1Valid,
    _ => _step2Valid,
  };

  Future<void> _submit() async {
    final amount = double.tryParse(_amountCtrl.text.trim());
    final payment = double.tryParse(_paymentCtrl.text.trim());
    final termMo = int.tryParse(_monthsCtrl.text.trim()) ?? 0;
    if (amount == null || payment == null) return;
    final note =
        '$_source — ${_nameCtrl.text.trim()}'
        '${_noteCtrl.text.trim().isNotEmpty ? " | ${_noteCtrl.text.trim()}" : ""}';
    setState(() {
      _saving = true;
      _error = null;
    });
    // The pop used to happen here, before the awaits inside onSubmit had run,
    // so the wizard closed whether the write landed or not (#133).
    final saved = await widget.onSubmit(amount, payment, termMo, _date, note);
    if (!mounted) return;
    if (saved) {
      Navigator.of(context).pop();
      return;
    }
    setState(() {
      _saving = false;
      _error = context.l10n.loanSaveFailed;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.cardRadius),
        ),
      ),
      padding: EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        top: AppSpacing.md,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.cardBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.loanWizardTitle.toUpperCase(),
                style: AppTextStyles.title.copyWith(color: AppColors.gold),
              ),
              Text('${_step + 1} / $_totalSteps', style: AppTextStyles.caption),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: List.generate(
              _totalSteps,
              (i) => Expanded(
                child: Container(
                  height: 2,
                  margin: EdgeInsets.only(
                    right: i < _totalSteps - 1 ? AppSpacing.xs : 0,
                  ),
                  decoration: BoxDecoration(
                    color: i <= _step ? AppColors.gold : AppColors.cardBorder,
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          SlideTransition(position: _slideAnim, child: _buildStep(context, l10n)),
          const SizedBox(height: AppSpacing.lg),
          if (_error != null) ...[
            Text(
              _error!,
              style: AppTextStyles.caption.copyWith(color: AppColors.red),
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
          Row(
            children: [
              if (_step > 0) ...[
                NeoButton(
                  label: l10n.back,
                  variant: NeoButtonVariant.ghost,
                  onPressed: _prev,
                ),
                const SizedBox(width: AppSpacing.sm),
              ],
              Expanded(
                child: _step < _totalSteps - 1
                    ? NeoButton(
                        label: '${l10n.next} →',
                        variant: NeoButtonVariant.primary,
                        color: AppColors.gold,
                        fullWidth: true,
                        onPressed: _valid ? _next : null,
                      )
                    : NeoButton(
                        label: l10n.confirm,
                        variant: NeoButtonVariant.primary,
                        color: AppColors.gold,
                        fullWidth: true,
                        onPressed: _step2Valid && !_saving ? _submit : null,
                      ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          NeoButton(
            label: l10n.abort,
            variant: NeoButtonVariant.danger,
            fullWidth: true,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Widget _buildStep(BuildContext context, AppLocalizations l10n) => switch (_step) {
    0 => _step0(context, l10n),
    1 => _step1(l10n),
    _ => _step2(l10n),
  };

  Widget _step0(BuildContext context, AppLocalizations l10n) {
    final locale = Localizations.localeOf(context).toString();
    final dateStr = DateFormat('dd MMM yyyy', locale).format(_date).toUpperCase();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.whoAndHowMuch.toUpperCase(),
          style: AppTextStyles.label.copyWith(color: AppColors.gold),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(l10n.source, style: AppTextStyles.label),
        const SizedBox(height: AppSpacing.xs),
        Wrap(
          spacing: AppSpacing.xs,
          children: _sources.map((s) {
            final active = s == _source;
            return GestureDetector(
              onTap: () => setState(() => _source = s),
              child: Container(
                margin: const EdgeInsets.only(bottom: AppSpacing.xs),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.xs + 2,
                ),
                decoration: BoxDecoration(
                  color: active
                      ? AppColors.gold.withAlpha(20)
                      : AppColors.surfaceHigh,
                  borderRadius: BorderRadius.circular(50),
                  border: Border.all(
                    color: active ? AppColors.gold : AppColors.cardBorder,
                    width: active ? 1.5 : 1,
                  ),
                ),
                child: Text(
                  s,
                  style: AppTextStyles.caption.copyWith(
                    color: active ? AppColors.gold : AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: AppSpacing.md),
        NeoInput(
          label: l10n.nameLender,
          controller: _nameCtrl,
          inputType: NeoInputType.name,
          hint: _source == "BANK" ? "Fubon" : "John",
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: AppSpacing.md),
        NeoInput(
          label: l10n.loanAmount,
          controller: _amountCtrl,
          inputType: NeoInputType.decimal,
          hint: "1880000",
          onChanged: (_) {
            setState(() {});
            _compute();
          },
        ),
        const SizedBox(height: AppSpacing.md),
        Text(l10n.date, style: AppTextStyles.label),
        const SizedBox(height: AppSpacing.xs),
        GestureDetector(
          onTap: _pickDate,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm + 2,
            ),
            decoration: BoxDecoration(
              color: AppColors.surfaceHigh,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(dateStr, style: AppTextStyles.body),
                const Icon(
                  Icons.calendar_today_rounded,
                  color: AppColors.textSecondary,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _step1(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.loanTerms.toUpperCase(),
          style: AppTextStyles.label.copyWith(color: AppColors.gold),
        ),
        const SizedBox(height: AppSpacing.md),
        NeoInput(
          label: l10n.annualRate,
          controller: _rateCtrl,
          inputType: NeoInputType.decimal,
          hint: "3.3",
          onChanged: (_) => _compute(),
        ),
        const SizedBox(height: AppSpacing.md),
        NeoInput(
          label: l10n.repaymentMonths,
          controller: _monthsCtrl,
          inputType: NeoInputType.numeric,
          hint: "84",
          onChanged: (_) {
            setState(() {});
            _compute();
          },
        ),
        if (_computedPayment != null) ...[
          const SizedBox(height: AppSpacing.lg),
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.gold.withAlpha(12),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.gold.withAlpha(60)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.computedInstallment, style: AppTextStyles.label),
                    Text(l10n.perMonth, style: AppTextStyles.caption),
                  ],
                ),
                Text(
                  moneyField(_computedPayment),
                  style: AppTextStyles.metric.copyWith(color: AppColors.gold),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _step2(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.confirmPayment.toUpperCase(),
          style: AppTextStyles.label.copyWith(color: AppColors.gold),
        ),
        const SizedBox(height: AppSpacing.md),
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.surfaceHigh,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Column(
            children: [
              _summaryRow(l10n.source, _source),
              _summaryRow(l10n.lender, _nameCtrl.text.toUpperCase()),
              _summaryRow(l10n.loanAmount, _amountCtrl.text),
              _summaryRow(l10n.repaymentMonths, _monthsCtrl.text),
              if (_rateCtrl.text.isNotEmpty && _rateCtrl.text != "0")
                _summaryRow(l10n.rate, "${_rateCtrl.text}%"),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        GestureDetector(
          onTap: () => setState(() {
            _overridePayment = !_overridePayment;
            if (!_overridePayment && _computedPayment != null)
              _paymentCtrl.text = moneyField(_computedPayment);
          }),
          child: Row(
            children: [
              Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  color: _overridePayment
                      ? AppColors.gold.withAlpha(40)
                      : AppColors.surfaceHigh,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: _overridePayment
                        ? AppColors.gold
                        : AppColors.cardBorder,
                  ),
                ),
                child: _overridePayment
                    ? const Icon(
                        Icons.check_rounded,
                        size: 12,
                        color: AppColors.gold,
                      )
                    : null,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(l10n.overrideInstallment, style: AppTextStyles.caption),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        NeoInput(
          label: l10n.monthlyInstallment,
          controller: _paymentCtrl,
          inputType: NeoInputType.decimal,
          hint: _computedPayment == null ? "0" : moneyField(_computedPayment),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: AppSpacing.md),
        NeoInput(
          label: l10n.noteOptional,
          controller: _noteCtrl,
          hint: "study loan",
          onChanged: (_) {},
        ),
      ],
    );
  }

  Widget _summaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.label),
          Text(
            value,
            style: AppTextStyles.caption.copyWith(color: AppColors.gold),
          ),
        ],
      ),
    );
  }
}
