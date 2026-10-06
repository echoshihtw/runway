import 'package:design_system/design_system.dart';
import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:presentation/features/transactions/widgets/transaction_row.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Amounts and dates were pinned to English, so a French reader saw 1,234 and
/// SEP instead of 1 234 and sept.
void main() {
  testWidgets('a row groups digits and names the month in the reader locale', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final date = DateTime(2026, 9, 10);
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          locale: const Locale('fr'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: TransactionRow(
              transaction: Transaction(
                id: 'tx-1',
                date: date,
                type: TransactionType.expense,
                amount: Money(1234567),
                createdAt: date,
                updatedAt: date,
              ),
              onEdit: () {},
              onDelete: () {},
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // French groups with a narrow no-break space.
    expect(find.textContaining('1 234 567'), findsOneWidget);
    expect(find.textContaining('1,234,567'), findsNothing);
    expect(find.textContaining('SEPT'), findsOneWidget);
  });
}
