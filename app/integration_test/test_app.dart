import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/native.dart';
import 'package:data/data.dart';
import 'package:application/application.dart';
import 'package:presentation/router/app_router.dart';

/// Builds the full app wired to an isolated in-memory database.
/// Use this in every integration test instead of calling main().
Widget buildTestApp() {
  final db = AppDatabase.forTesting(NativeDatabase.memory());
  return ProviderScope(
    overrides: [
      analyticsProvider.overrideWithValue(const NoOpAnalytics()),
      transactionRepositoryProvider.overrideWithValue(
        DriftTransactionRepository(db),
      ),
      loanRepositoryProvider.overrideWithValue(DriftLoanRepository(db)),
      subscriptionRepositoryProvider.overrideWithValue(
        DriftSubscriptionRepository(db),
      ),
      financialSettingsRepositoryProvider.overrideWithValue(
        DriftFinancialSettingsRepository(db),
      ),
    ],
    child: MaterialApp.router(
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
    ),
  );
}
