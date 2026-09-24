import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';
import 'package:domain/domain.dart';
import 'package:intl/intl.dart';

import '../../shared/money_field.dart';

class SubscriptionForm extends StatefulWidget {
  final Subscription? existing;
  final Future<bool> Function(
    String name,
    SubscriptionCategory category,
    double amount,
    BillingCycle cycle,
    DateTime startDate,
    String? note,
  )
  onSubmit;

  /// Stopping the reminder. Null while creating one, since there is nothing
  /// to delete yet.
  final VoidCallback? onDelete;

  const SubscriptionForm({
    super.key,
    this.existing,
    required this.onSubmit,
    this.onDelete,
  });

  @override
  State<SubscriptionForm> createState() => _SubscriptionFormState();
}

class _SubscriptionFormState extends State<SubscriptionForm> {
  final _nameCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();

  late SubscriptionCategory _category;
  late BillingCycle _cycle;
  late DateTime _startDate;

  /// Set when a write is refused, so the reason appears inside the sheet, next
  /// to the typing it refers to. The SnackBar it replaces needed a Scaffold,
  /// and the Scaffold filled the sheet to the whole height of the screen.
  String? _error;
  bool _saving = false;

  /// CONFIRM stays disabled until there is something to save. It used to be
  /// always enabled while `_submit` returned early, so tapping it on an empty
  /// form did nothing at all and the sheet just sat there.
  bool get _valid =>
      _nameCtrl.text.trim().isNotEmpty &&
      (double.tryParse(_amountCtrl.text.trim()) ?? 0) > 0;

  @override
  void initState() {
    super.initState();
    _category = widget.existing?.category ?? SubscriptionCategory.personal;
    _cycle = widget.existing?.cycle ?? BillingCycle.monthly;
    _startDate = widget.existing?.startDate ?? DateTime.now();
    _nameCtrl.text = widget.existing?.name ?? '';
    _amountCtrl.text = moneyField(widget.existing?.amount);
    _noteCtrl.text = widget.existing?.note ?? '';
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _amountCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (ctx, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppColors.neonGreen,
            surface: AppColors.surface,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _startDate = picked);
  }

  Future<void> _submit() async {
    final name = _nameCtrl.text.trim();
    final amount = double.tryParse(_amountCtrl.text.trim());
    if (name.isEmpty || amount == null || amount <= 0) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    final saved = await widget.onSubmit(
      name,
      _category,
      amount,
      _cycle,
      _startDate,
      _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
    );
    if (!mounted) return;
    if (saved) {
      Navigator.of(context).pop();
      return;
    }
    setState(() {
      _saving = false;
      _error = context.l10n.subscriptionSaveFailed;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final dateStr = DateFormat('dd MMM yyyy').format(_startDate).toUpperCase();

    return Container(
      // The sheet is as tall as this form and no taller. Unbounded, the
      // SingleChildScrollView below grows instead of scrolling, so CONFIRM
      // ends up past the bottom of the screen with no way to reach it.
      // Capped here rather than at each of the three call sites.
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
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
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
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

            Text(
              widget.existing == null
                  ? l10n.addSubscription
                  : l10n.editSubscription,
              style: AppTextStyles.title.copyWith(color: AppColors.purple),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Category
            Text(l10n.subscriptionCategory, style: AppTextStyles.label),
            const SizedBox(height: AppSpacing.xs),
            Row(
              children: SubscriptionCategory.values.map((c) {
                final active = c == _category;
                final label = c == SubscriptionCategory.personal
                    ? l10n.personal
                    : l10n.business;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _category = c),
                    child: Container(
                      margin: EdgeInsets.only(
                        right: c != SubscriptionCategory.values.last
                            ? AppSpacing.xs
                            : 0,
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.sm,
                      ),
                      decoration: BoxDecoration(
                        color: active
                            ? AppColors.purple.withAlpha(20)
                            : AppColors.surfaceHigh,
                        borderRadius: BorderRadius.circular(50),
                        border: Border.all(
                          color: active
                              ? AppColors.purple
                              : AppColors.cardBorder,
                          width: active ? 1.5 : 1,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          label,
                          style: AppTextStyles.caption.copyWith(
                            color: active
                                ? AppColors.purple
                                : AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: AppSpacing.md),

            // Name
            NeoInput(
              label: l10n.subscriptionName,
              controller: _nameCtrl,
              inputType: NeoInputType.name,
              hint: 'Netflix',
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: AppSpacing.md),

            // Amount
            NeoInput(
              label: l10n.subscriptionPaymentAmount,
              controller: _amountCtrl,
              // Decimal, not numeric: numeric is digitsOnly, so 9.99 could
              // not be typed at all and every price with cents was
              // unenterable. The 1990 hint dated from yen.
              inputType: NeoInputType.decimal,
              hint: '9.99',
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: AppSpacing.md),

            // Billing cycle
            Text(l10n.subscriptionCoveragePeriod, style: AppTextStyles.label),
            const SizedBox(height: AppSpacing.xs),
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: BillingCycle.values.map((c) {
                final active = c == _cycle;
                final label = _cycleLabel(c, l10n);
                return GestureDetector(
                  onTap: () => setState(() => _cycle = c),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.xs + 2,
                    ),
                    decoration: BoxDecoration(
                      color: active
                          ? AppColors.purple.withAlpha(20)
                          : AppColors.surfaceHigh,
                      borderRadius: BorderRadius.circular(50),
                      border: Border.all(
                        color: active ? AppColors.purple : AppColors.cardBorder,
                        width: active ? 1.5 : 1,
                      ),
                    ),
                    child: Text(
                      label,
                      style: AppTextStyles.caption.copyWith(
                        color: active
                            ? AppColors.purple
                            : AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: AppSpacing.md),

            // Date
            Text(l10n.subscriptionPaymentDate, style: AppTextStyles.label),
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
            const SizedBox(height: AppSpacing.md),

            // Note
            NeoInput(
              label: l10n.noteOptional,
              controller: _noteCtrl,
              hint: 'streaming service',
              onChanged: (_) {},
            ),
            const SizedBox(height: AppSpacing.lg),

            if (_error != null) ...[
              Text(
                _error!,
                style: AppTextStyles.caption.copyWith(color: AppColors.red),
              ),
              const SizedBox(height: AppSpacing.sm),
            ],

            // Actions
            Row(
              children: [
                Expanded(
                  child: NeoButton(
                    label: l10n.confirm,
                    variant: NeoButtonVariant.primary,
                    fullWidth: true,
                    onPressed: _valid && !_saving ? _submit : null,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: NeoButton(
                    label: l10n.abort,
                    variant: NeoButtonVariant.ghost,
                    fullWidth: true,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
              ],
            ),

            // A reminder has to be stoppable. Only offered while editing one,
            // because there is nothing to delete while creating it.
            if (widget.onDelete != null) ...[
              const SizedBox(height: AppSpacing.sm),
              NeoButton(
                label: l10n.deleteSubscription,
                variant: NeoButtonVariant.danger,
                fullWidth: true,
                onPressed: () {
                  Navigator.of(context).pop();
                  widget.onDelete!();
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _cycleLabel(BillingCycle c, AppLocalizations l10n) => switch (c) {
    BillingCycle.weekly => l10n.weekly,
    BillingCycle.monthly => l10n.monthly,
    BillingCycle.quarterly => l10n.quarterly,
    BillingCycle.yearly => l10n.yearly,
  };
}
