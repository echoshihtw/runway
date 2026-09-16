import 'package:application/application.dart';
import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:presentation/features/dashboard/widgets/review_prompt_trigger.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakePrompter implements ReviewPrompter {
  int calls = 0;

  @override
  Future<void> requestReview() async => calls++;
}

Transaction _tx(TransactionType type) {
  final date = DateTime(2026, 9, 1);
  return Transaction(
    id: type.name,
    date: date,
    type: type,
    amount: Money(100),
    createdAt: date,
    updatedAt: date,
  );
}

const _model = ModelState(
  currentCash: 1000,
  burnRate: 100,
  effectiveBurnRate: 100,
  monthlyPayment: 0,
  subscriptionMonthlyCost: 0,
  runwayMonths: 10,
  runwayDays: 300,
  pressureRatio: 0,
);

Future<_FakePrompter> _pump(
  WidgetTester tester, {
  required Map<String, Object> prefs,
  required List<Transaction> transactions,
}) async {
  SharedPreferences.setMockInitialValues(prefs);
  resetReviewPromptForTest();
  final prompter = _FakePrompter();
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        transactionsProvider.overrideWith((ref) => Stream.value(transactions)),
        modelProvider.overrideWithValue(_model),
        reviewPrompterProvider.overrideWithValue(prompter),
      ],
      child: const MaterialApp(home: Scaffold(body: ReviewPromptTrigger())),
    ),
  );
  for (var i = 0; i < 5; i++) {
    await tester.pump();
  }
  return prompter;
}

final _eligible = [
  _tx(TransactionType.openingBalance),
  _tx(TransactionType.expense),
];

void main() {
  testWidgets('asks once on a launch after becoming eligible', (tester) async {
    final prompter = await _pump(
      tester,
      prefs: {'app_launch_count': 2, 'review_eligible_at_launch': 1},
      transactions: _eligible,
    );

    expect(prompter.calls, 1);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool('review_requested'), isTrue);

    // A rebuild later in the same launch doesn't ask again.
    await tester.pumpWidget(const SizedBox.shrink());
    expect(prompter.calls, 1);
  });

  testWidgets('on the first eligible launch it only remembers the launch', (tester) async {
    final prompter = await _pump(
      tester,
      prefs: {'app_launch_count': 1},
      transactions: _eligible,
    );

    expect(prompter.calls, 0);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getInt('review_eligible_at_launch'), 1);
  });

  testWidgets('never asks without an expense', (tester) async {
    final prompter = await _pump(
      tester,
      prefs: {'app_launch_count': 3, 'review_eligible_at_launch': 1},
      transactions: [_tx(TransactionType.openingBalance)],
    );

    expect(prompter.calls, 0);
  });

  testWidgets('never asks twice per install', (tester) async {
    final prompter = await _pump(
      tester,
      prefs: {
        'app_launch_count': 9,
        'review_eligible_at_launch': 1,
        'review_requested': true,
      },
      transactions: _eligible,
    );

    expect(prompter.calls, 0);
  });
}
