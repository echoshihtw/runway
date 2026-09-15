import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import 'package:design_system/design_system.dart';
import 'package:application/application.dart';
import 'package:domain/domain.dart';
import '../features/boot/boot_screen.dart';
import '../features/dashboard/dashboard_screen.dart';
import '../features/transactions/transactions_screen.dart';
import '../features/transactions/widgets/transaction_form.dart';
import '../features/transactions/widgets/loan_wizard.dart';
import '../features/subscriptions/subscription_form.dart';
import '../features/paywall/paywall_screen.dart';
import '../features/scenarios/scenarios_screen.dart';

// Global keys for coach mark tour
final hudNavKey = GlobalKey();
final logNavKey = GlobalKey();
final simNavKey = GlobalKey();

final appRouter = GoRouter(
  initialLocation: '/boot',
  routes: [
    GoRoute(path: '/boot', builder: (_, __) => const BootScreen()),
    StatefulShellRoute.indexedStack(
      builder: (context, state, shell) => _ScaffoldWithNav(shell: shell),
      branches: [
        StatefulShellBranch(
          routes: [GoRoute(path: '/dashboard', builder: (_, __) => const DashboardScreen())],
        ),
        StatefulShellBranch(
          routes: [GoRoute(path: '/transactions', builder: (_, __) => const TransactionsScreen())],
        ),
        StatefulShellBranch(
          routes: [GoRoute(path: '/scenarios', builder: (_, __) => const ScenariosScreen())],
        ),
      ],
    ),
  ],
);

class _ScaffoldWithNav extends ConsumerStatefulWidget {
  final StatefulNavigationShell shell;
  const _ScaffoldWithNav({required this.shell});

  @override
  ConsumerState<_ScaffoldWithNav> createState() => _ScaffoldWithNavState();
}

class _ScaffoldWithNavState extends ConsumerState<_ScaffoldWithNav> {
  void _onHorizontalDragEnd(DragEndDetails details) {
    final v = details.primaryVelocity ?? 0;
    final i = widget.shell.currentIndex;
    // Higher threshold on Android to avoid conflict with system back gesture
    final threshold = Platform.isAndroid ? 800.0 : 500.0;
    if (v < -threshold && i < 2) widget.shell.goBranch(i + 1);
    if (v > threshold && i > 0) widget.shell.goBranch(i - 1);
  }

  void _onUpwardSwipe(DragEndDetails details) {
    if ((details.primaryVelocity ?? 0) < -400) _showActionSheet();
  }

  void _showActionSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.lg,
            0,
            AppSpacing.lg,
            MediaQuery.paddingOf(ctx).bottom + AppSpacing.md,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.surface.withAlpha(230),
                  borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _ActionRow(
                      label: 'ENTRY',
                      icon: Icons.add_rounded,
                      color: AppColors.neonGreen,
                      onTap: () {
                        Navigator.pop(ctx);
                        WidgetsBinding.instance.addPostFrameCallback(
                          (_) => _showForm(null),
                        );
                      },
                    ),
                    const Divider(color: AppColors.cardBorder, height: 1),
                    _ActionRow(
                      label: 'LOAN',
                      icon: Icons.credit_score_rounded,
                      color: AppColors.gold,
                      onTap: () {
                        Navigator.pop(ctx);
                        WidgetsBinding.instance.addPostFrameCallback(
                          (_) => _showLoanWizard(),
                        );
                      },
                    ),
                    const Divider(color: AppColors.cardBorder, height: 1),
                    _ActionRow(
                      label: 'SUBSCRIPTIONS',
                      icon: Icons.loop_rounded,
                      color: AppColors.purple,
                      onTap: () {
                        Navigator.pop(ctx);
                        WidgetsBinding.instance.addPostFrameCallback(
                          (_) => _showSubscriptionForm(),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showForm(Transaction? existing) {
    final loans = _loanChoices(existing: existing);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.cardRadius),
        ),
      ),
      builder: (_) => TransactionForm(
        existing: existing,
        loans: loans,
        onSubmit: (type, amount, date, note, category, loanId) async {
          final now = DateTime.now();
          if (existing == null) {
            await ref.read(addTransactionUseCaseProvider).execute(
              Transaction(
                id: const Uuid().v4(),
                date: date,
                type: type,
                amount: Money(amount),
                note: note,
                loanId: type == TransactionType.repayment ? loanId : null,
                category: category,
                createdAt: now,
                updatedAt: now,
              ),
            );
          } else {
            await ref.read(editTransactionUseCaseProvider).execute(
              existing.copyWith(
                date: date,
                type: type,
                amount: Money(amount),
                note: note,
                loanId: type == TransactionType.repayment ? loanId : null,
                clearLoanId: type != TransactionType.repayment,
                category: category,
                clearCategory: category == null,
                updatedAt: now,
              ),
            );
          }
        },
      ),
    );
  }

  Future<void> _showLoanWizard() async {
    final isPro =
        FeatureFlags.devProEntitlement ||
        (ref.read(entitlementProvider).value?.isPro ?? false);
    if (!isPro) {
      final loans = await ref.read(loansProvider.future);
      if (!mounted) return;
      if (loans.isNotEmpty) {
        showPaywall(context, trigger: 'loan_limit');
        return;
      }
    }
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.cardRadius),
        ),
      ),
      builder: (_) => LoanWizard(
        onSubmit: (loanAmount, monthlyPayment, termMonths, date, note) async {
          final now = DateTime.now();
          final loanId = const Uuid().v4();
          final parts = (note ?? '').split(' — ');
          final source =
              parts.isNotEmpty ? parts[0].replaceAll(' LOAN', '') : 'OTHER';
          final name = parts.length > 1 ? parts[1] : 'LOAN';
          await ref.read(addLoanUseCaseProvider).execute(
            Loan(
              id: loanId,
              name: name,
              source: source,
              originalAmount: loanAmount,
              monthlyPayment: monthlyPayment,
              originalTermMonths: termMonths,
              startDate: date,
              createdAt: now,
              updatedAt: now,
            ),
          );
          await ref.read(addTransactionUseCaseProvider).execute(
            Transaction(
              id: const Uuid().v4(),
              date: date,
              type: TransactionType.loan,
              amount: Money(loanAmount),
              note: note,
              loanId: loanId,
              createdAt: now,
              updatedAt: now,
            ),
          );
        },
      ),
    );
  }

  void _showSubscriptionForm() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.cardRadius),
        ),
      ),
      builder: (_) => SubscriptionForm(
        onSubmit: (name, category, amount, cycle, startDate, note) async {
          final now = DateTime.now();
          await ref.read(addSubscriptionUseCaseProvider).execute(
            Subscription(
              id: const Uuid().v4(),
              name: name,
              category: category,
              amount: amount,
              cycle: cycle,
              startDate: startDate,
              nextBillingDate: computeNextBillingDate(startDate, cycle),
              note: note,
              createdAt: now,
              updatedAt: now,
            ),
          );
          return true;
        },
      ),
    );
  }

  List<Loan> _loanChoices({Transaction? existing}) {
    final summaries = ref.read(loanSummariesProvider);
    final loans =
        activeLoanSummaries(summaries).map((s) => s.loan).toList();
    final existingLoanId = existing?.loanId;
    if (existingLoanId != null &&
        !loans.any((l) => l.id == existingLoanId)) {
      for (final s in summaries) {
        if (s.loan.id == existingLoanId) {
          loans.add(s.loan);
          break;
        }
      }
    }
    loans.sort((a, b) {
      if (a.isActive != b.isActive) return a.isActive ? -1 : 1;
      return a.name.compareTo(b.name);
    });
    return loans;
  }

  @override
  Widget build(BuildContext context) {
    final bottomSafe = MediaQuery.paddingOf(context).bottom;
    final currentIndex = widget.shell.currentIndex;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: GestureDetector(
        onHorizontalDragEnd: _onHorizontalDragEnd,
        behavior: HitTestBehavior.translucent,
        child: Stack(
          children: [
            widget.shell,

            // Swipe-up zone — sits above the system safe area so it
            // clears Android's home-gesture zone and iOS home indicator
            Positioned(
              left: 0,
              right: 0,
              bottom: bottomSafe,
              height: 64,
              child: GestureDetector(
                onVerticalDragEnd: _onUpwardSwipe,
                behavior: HitTestBehavior.translucent,
                child: const SizedBox.expand(),
              ),
            ),

            // Page indicator dots
            Positioned(
              left: 0,
              right: 0,
              bottom: bottomSafe + AppSpacing.sm,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (i) {
                  final active = i == currentIndex;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOut,
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: active ? 18 : 4,
                    height: 4,
                    decoration: BoxDecoration(
                      color: active
                          ? AppColors.neonGreen
                          : AppColors.textDim.withAlpha(100),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionRow({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withAlpha(22),
                shape: BoxShape.circle,
                border: Border.all(color: color.withAlpha(80), width: 1),
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: AppSpacing.md),
            Text(
              label,
              style: AppTextStyles.body.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
                letterSpacing: 1,
              ),
            ),
            const Spacer(),
            Icon(Icons.chevron_right_rounded, color: color.withAlpha(120), size: 18),
          ],
        ),
      ),
    );
  }
}
