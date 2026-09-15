import 'package:domain/domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Overridden in main.dart with the real Drift implementation.
/// This ensures application layer never imports data layer directly.
final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  throw UnimplementedError(
    'transactionRepositoryProvider must be overridden in main.dart',
  );
});

final financialSettingsRepositoryProvider =
    Provider<FinancialSettingsRepository>((ref) {
      throw UnimplementedError(
        'financialSettingsRepositoryProvider must be overridden in main.dart',
      );
    });
