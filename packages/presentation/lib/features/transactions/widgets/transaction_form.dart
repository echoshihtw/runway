import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';
import 'package:domain/domain.dart';
import 'package:intl/intl.dart';

class TransactionForm extends StatefulWidget {
  final Transaction? existing;
  final TransactionType? preselectedType;
  final List<Loan> loans;
  final void Function(
    TransactionType type,
    double amount,
    DateTime date,
    String? note,
    ExpenseCategory? category,
    String? loanId,
  ) onSubmit;

  const TransactionForm({
    super.key,
    this.existing,
    this.preselectedType,
    this.loans = const [],
    required this.onSubmit,
  });

  @override
  State<TransactionForm> createState() => _TransactionFormState();
}

class _TransactionFormState extends State<TransactionForm> {
  final _amountCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  final _amountFocus = FocusNode();

  late bool _isInflow;
  late DateTime _date;
  bool _linkToLoan = false;
  String? _selectedLoanId;
  late bool _isRent;

  bool get _isOpeningBalance =>
      widget.existing?.type == TransactionType.openingBalance ||
      widget.preselectedType == TransactionType.openingBalance;

  // Loan/openingBalance types preserve their type — only amount/date/note editable
  bool get _isLockedType =>
      widget.existing?.type == TransactionType.loan ||
      widget.existing?.type == TransactionType.openingBalance;

  @override
  void initState() {
    super.initState();
    final type =
        widget.existing?.type ??
        widget.preselectedType ??
        TransactionType.expense;
    _isInflow = type.isInflow;
    _date = widget.existing?.date ?? DateTime.now();
    _amountCtrl.text =
        widget.existing?.amount.value.toStringAsFixed(0) ?? '';
    _noteCtrl.text = widget.existing?.note ?? '';
    _selectedLoanId = widget.existing?.loanId;
    _linkToLoan = widget.existing?.type == TransactionType.repayment;
    _isRent = widget.existing?.category == ExpenseCategory.rent;
    if (_linkToLoan && _selectedLoanId == null) {
      _selectedLoanId = _defaultLoanId();
    }

    if (widget.existing == null) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _amountFocus.requestFocus(),
      );
    }
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _noteCtrl.dispose();
    _amountFocus.dispose();
    super.dispose();
  }

  TransactionType get _resolvedType {
    if (_isOpeningBalance) return TransactionType.openingBalance;
    if (_isLockedType) return widget.existing!.type;
    if (_isInflow) return TransactionType.income;
    if (_linkToLoan) return TransactionType.repayment;
    return TransactionType.expense;
  }

  /// An expense uses up the rent or the living budget. Editing a living
  /// expense keeps the category it already has.
  ExpenseCategory? get _resolvedCategory {
    if (_resolvedType != TransactionType.expense) return null;
    if (_isRent) return ExpenseCategory.rent;
    final existing = widget.existing?.category;
    return existing == ExpenseCategory.rent ? null : existing;
  }

  String? _defaultLoanId() {
    if (widget.loans.isEmpty) return null;
    final active = widget.loans.where((l) => l.isActive);
    return (active.isNotEmpty ? active : widget.loans).first.id;
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
            primary: AppColors.green,
            surface: AppColors.surface,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _date = picked);
  }

  void _submit() {
    final amount = double.tryParse(_amountCtrl.text.trim());
    if (amount == null || amount <= 0) return;
    if (_linkToLoan) {
      final validIds = widget.loans.map((l) => l.id).toSet();
      if (_selectedLoanId == null || !validIds.contains(_selectedLoanId)) {
        return;
      }
    }
    widget.onSubmit(
      _resolvedType,
      amount,
      _date,
      _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
      _resolvedCategory,
      _linkToLoan ? _selectedLoanId : null,
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toString();
    final dateStr =
        DateFormat('dd MMM yyyy', locale).format(_date).toUpperCase();
    final showLoanLink =
        !_isInflow &&
        !_isOpeningBalance &&
        !_isLockedType &&
        widget.loans.isNotEmpty;
    final showBudgetChoice =
        !_isInflow && !_isOpeningBalance && !_isLockedType && !_linkToLoan;

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
        top: AppSpacing.lg,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.lg,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
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

            // Title
            Text(
              widget.existing == null
                  ? l10n.newLogEntry.toUpperCase()
                  : l10n.modifyEntry.toUpperCase(),
              style: AppTextStyles.title,
            ),
            const SizedBox(height: AppSpacing.lg),

            // Type indicator for locked types
            if (_isLockedType) ...[
              _TypeBadge(type: widget.existing!.type),
              const SizedBox(height: AppSpacing.lg),
            ],

            // IN / OUT toggle
            if (!_isLockedType) ...[
              _InOutToggle(
                isInflow: _isInflow,
                isOpeningBalance: _isOpeningBalance,
                onChanged: (v) => setState(() {
                  _isInflow = v;
                  if (v) _linkToLoan = false;
                }),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],

            // Amount
            NeoInput(
              label: l10n.amount,
              controller: _amountCtrl,
              focusNode: _amountFocus,
              inputType: NeoInputType.numeric,
              hint: '50,000',
            ),
            const SizedBox(height: AppSpacing.md),

            // Note
            NeoInput(
              label: l10n.noteOptional,
              controller: _noteCtrl,
              inputType: NeoInputType.note,
              hint: 'rent, groceries...',
            ),
            const SizedBox(height: AppSpacing.md),

            // Which budget an expense uses up
            if (showBudgetChoice) ...[
              _BudgetToggle(
                isRent: _isRent,
                onChanged: (v) => setState(() => _isRent = v),
              ),
              const SizedBox(height: AppSpacing.md),
            ],

            // Loan repayment link (progressive disclosure)
            if (showLoanLink) ...[
              _LoanLinkRow(
                expanded: _linkToLoan,
                loans: widget.loans,
                selectedLoanId: _selectedLoanId,
                onToggle: () => setState(() {
                  _linkToLoan = !_linkToLoan;
                  if (_linkToLoan && _selectedLoanId == null) {
                    _selectedLoanId = _defaultLoanId();
                  }
                }),
                onLoanSelected: (id) => setState(() => _selectedLoanId = id),
              ),
              const SizedBox(height: AppSpacing.md),
            ],

            // Date (secondary, tappable)
            _DateChip(dateStr: dateStr, onTap: _pickDate),
            const SizedBox(height: AppSpacing.lg),

            // Submit
            NeoButton(
              label: l10n.confirm,
              variant: NeoButtonVariant.primary,
              fullWidth: true,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }
}

// ── IN / OUT toggle ──────────────────────────────────────────────────────────

class _InOutToggle extends StatelessWidget {
  final bool isInflow;
  final bool isOpeningBalance;
  final ValueChanged<bool> onChanged;

  const _InOutToggle({
    required this.isInflow,
    required this.isOpeningBalance,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (isOpeningBalance) {
      return _TypeBadge.opening();
    }
    return Row(
      children: [
        Expanded(
          child: _ToggleTile(
            label: 'IN',
            icon: Icons.arrow_downward_rounded,
            color: SC.txIncome,
            active: isInflow,
            onTap: () => onChanged(true),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _ToggleTile(
            label: 'OUT',
            icon: Icons.arrow_upward_rounded,
            color: SC.txExpense,
            active: !isInflow,
            onTap: () => onChanged(false),
          ),
        ),
      ],
    );
  }
}

// ── LIVING / RENT toggle ─────────────────────────────────────────────────────

class _BudgetToggle extends StatelessWidget {
  final bool isRent;
  final ValueChanged<bool> onChanged;

  const _BudgetToggle({required this.isRent, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ToggleTile(
            label: 'LIVING',
            icon: Icons.shopping_bag_rounded,
            color: SC.txExpense,
            active: !isRent,
            onTap: () => onChanged(false),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _ToggleTile(
            label: 'RENT',
            icon: Icons.home_rounded,
            color: SC.txExpense,
            active: isRent,
            onTap: () => onChanged(true),
          ),
        ),
      ],
    );
  }
}

class _ToggleTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool active;
  final VoidCallback onTap;

  const _ToggleTile({
    required this.label,
    required this.icon,
    required this.color,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md + 4),
        decoration: BoxDecoration(
          color: active ? color.withAlpha(25) : AppColors.surfaceHigh,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: active ? color : AppColors.cardBorder,
            width: active ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: active ? color : AppColors.textDim,
              size: 16,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppTextStyles.body.copyWith(
                color: active ? color : AppColors.textSecondary,
                fontWeight: active ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Type badge (locked / opening balance) ────────────────────────────────────

class _TypeBadge extends StatelessWidget {
  final TransactionType? type;

  const _TypeBadge({this.type});

  const _TypeBadge.opening() : type = TransactionType.openingBalance;

  Color get _color => switch (type) {
    TransactionType.loan => SC.txLoan,
    TransactionType.openingBalance => SC.txOpeningBalance,
    _ => SC.chrome,
  };

  String get _label => switch (type) {
    TransactionType.loan => 'LOAN',
    TransactionType.openingBalance => 'OPENING BALANCE',
    _ => type?.label ?? '',
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: _color.withAlpha(20),
        borderRadius: BorderRadius.circular(50),
        border: Border.all(color: _color.withAlpha(60)),
      ),
      child: Text(
        _label,
        style: AppTextStyles.caption.copyWith(color: _color),
      ),
    );
  }
}

// ── Loan repayment link ──────────────────────────────────────────────────────

class _LoanLinkRow extends StatelessWidget {
  final bool expanded;
  final List<Loan> loans;
  final String? selectedLoanId;
  final VoidCallback onToggle;
  final ValueChanged<String> onLoanSelected;

  const _LoanLinkRow({
    required this.expanded,
    required this.loans,
    required this.selectedLoanId,
    required this.onToggle,
    required this.onLoanSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: onToggle,
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
            child: Row(
              children: [
                Icon(
                  Icons.link_rounded,
                  size: 14,
                  color: expanded ? AppColors.gold : AppColors.textDim,
                ),
                const SizedBox(width: 6),
                Text(
                  'LOAN REPAYMENT',
                  style: AppTextStyles.label.copyWith(
                    color: expanded ? AppColors.gold : AppColors.textDim,
                  ),
                ),
                const Spacer(),
                Icon(
                  expanded ? Icons.expand_less : Icons.expand_more,
                  color: AppColors.textDim,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
        if (expanded) ...[
          const SizedBox(height: AppSpacing.xs),
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: loans.map((loan) {
              final active = selectedLoanId == loan.id;
              return GestureDetector(
                onTap: () => onLoanSelected(loan.id),
                child: Container(
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
                    loan.name.toUpperCase(),
                    style: AppTextStyles.caption.copyWith(
                      color: active ? AppColors.gold : AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }
}

// ── Date chip ────────────────────────────────────────────────────────────────

class _DateChip extends StatelessWidget {
  final String dateStr;
  final VoidCallback onTap;

  const _DateChip({required this.dateStr, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.calendar_today_rounded,
            size: 12,
            color: AppColors.textDim,
          ),
          const SizedBox(width: 6),
          Text(dateStr, style: AppTextStyles.caption),
          const SizedBox(width: 4),
          const Icon(
            Icons.edit_rounded,
            size: 10,
            color: AppColors.textDim,
          ),
        ],
      ),
    );
  }
}
