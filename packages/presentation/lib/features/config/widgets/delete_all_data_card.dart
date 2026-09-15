import 'package:application/application.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Settings card that erases all local data after a confirmation step.
class DeleteAllDataCard extends ConsumerWidget {
  const DeleteAllDataCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    return NeoCard(
      title: l10n.dataSection,
      accentColor: AppColors.red,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.deleteAllDataBody,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          NeoButton(
            label: l10n.deleteAllDataButton,
            variant: NeoButtonVariant.danger,
            fullWidth: true,
            onPressed: () => _confirmAndDelete(context, ref),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmAndDelete(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        ),
        title: Text(l10n.deleteAllDataConfirmTitle, style: AppTextStyles.title),
        content: Text(l10n.deleteAllDataConfirmBody, style: AppTextStyles.body),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.cancel, style: AppTextStyles.body),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              l10n.deleteAllDataConfirmAction,
              style: AppTextStyles.body.copyWith(color: AppColors.red),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    // The app restarts at onboarding, which disposes this widget and its ref.
    await ref.read(dataResetServiceProvider).deleteAllData();
  }
}
