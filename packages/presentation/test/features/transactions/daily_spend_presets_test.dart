import 'package:application/application.dart';
import 'package:design_system/design_system.dart';
import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:presentation/features/paywall/paywall_screen.dart';
import 'package:presentation/features/transactions/transactions_screen.dart';
import 'package:presentation/product_config.dart';
import 'package:presentation/router/nav_metrics.dart';
import 'package:presentation/features/transactions/widgets/transaction_form.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The add button offered ENTRY, NEW LOAN and SUBSCRIPTIONS at equal weight,
/// though their frequencies differ by two orders of magnitude. The daily
/// action paid a tap plus a decision so that two rare ones stayed reachable.
///
/// The runway only tells the truth if spending gets logged, so this is a
/// correctness change: fewer taps is `typicalSpending` understating less.
class _Transactions implements TransactionRepository {
  _Transactions(this.items);
  final List<Transaction> items;

  @override
  Stream<List<Transaction>> watchAll() => Stream.value(items);

  @override
  Future<List<Transaction>> getAll() async => items;

  @override
  Future<void> add(Transaction transaction) async => items.add(transaction);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Loans implements LoanRepository {
  @override
  Stream<List<Loan>> watchAll() => Stream.value(const []);

  @override
  Future<List<Loan>> getAll() async => const [];

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// The Keychain counter, in memory. Fresh per pump, so every test starts free.
class _EntryCount implements UsageCountStore {
  final counts = <String, int>{};

  @override
  Future<int> read(String key) async => counts[key] ?? 0;

  @override
  Future<void> write(String key, int count) async => counts[key] = count;
}

class _FreeTier implements PurchaseService {
  @override
  Stream<bool> get proEntitlementUpdates => const Stream<bool>.empty();

  @override
  Future<bool> checkProEntitlement() async => false;

  @override
  Future<ProOffering?> fetchOffering() async => null;

  @override
  Future<bool> purchasePackage(ProPackage package) async => false;

  @override
  Future<bool> restorePurchases() async => false;
}

/// The add button. Found by key because the dial it replaces rendered
/// `Icons.add_rounded` twice — on the button and on its own ENTRY option.
final _addButton = find.byKey(const Key('add-fab'));

String _fieldText(WidgetTester tester, int index) =>
    tester.widget<TextField>(find.byType(TextField).at(index)).controller!.text;

Future<_Transactions> _pump(
  WidgetTester tester, {
  double textScale = 1.0,
  int entriesAlreadyLogged = 0,
}) async {
  SharedPreferences.setMockInitialValues({});
  final written = _Transactions([]);
  final entryCount = _EntryCount()
    ..counts[UsageKind.entries.key] = entriesAlreadyLogged;
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        transactionRepositoryProvider.overrideWithValue(written),
        loanRepositoryProvider.overrideWithValue(_Loans()),
        purchaseServiceProvider.overrideWithValue(_FreeTier()),
        usageCountStoreProvider.overrideWithValue(entryCount),
      ],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(textScale)),
          child: child!,
        ),
        home: const TransactionsScreen(),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return written;
}

void main() {
  testWidgets('the add button clears the band the page indicator occupies', (
    tester,
  ) async {
    // The router draws a scrim kNavBandHeight tall so scrolled content fades
    // out behind the labels. At the default floating position the button sat
    // inside it: the lower half was painted over and it could not be tapped on
    // a device (#201). This screen does not host the indicator, so the check is
    // on the gap the button leaves at the foot of the screen.
    await _pump(tester);

    final button = tester.getRect(_addButton);
    final screenHeight =
        tester.view.physicalSize.height / tester.view.devicePixelRatio;

    expect(
      screenHeight - button.bottom,
      greaterThanOrEqualTo(kNavBandHeight),
      reason: 'the scrim behind the nav labels would cover the add button',
    );
  });

  testWidgets('the add button asks what you bought, not which record type', (
    tester,
  ) async {
    await _pump(tester);
    await tester.tap(_addButton);
    await tester.pumpAndSettle();

    expect(find.text('What did you spend on?'), findsOneWidget);
    for (final label in const [
      'COFFEE',
      'LUNCH',
      'DINNER',
      'TRANSPORT',
      'GROCERIES',
      'SOMETHING ELSE',
    ]) {
      expect(find.text(label), findsOneWidget, reason: '$label is missing');
    }

    // The commitments are creatable from their own cards now, so a global
    // menu of record types has nothing left to offer.
    expect(find.text('NEW LOAN'), findsNothing);
    expect(find.text('SUBSCRIPTIONS'), findsNothing);
  });

  testWidgets('a preset fills the note and leaves the amount to type', (
    tester,
  ) async {
    await _pump(tester);
    await tester.tap(_addButton);
    await tester.pumpAndSettle();
    await tester.tap(find.text('LUNCH'));
    await tester.pumpAndSettle();

    expect(find.byType(TransactionForm), findsOneWidget);
    expect(
      _fieldText(tester, 1),
      'Lunch',
      reason: 'the note arrives written, in the case a note is read back in',
    );
    expect(
      _fieldText(tester, 0),
      isEmpty,
      reason: 'the amount is the one thing only the owner knows',
    );
  });

  testWidgets("a preset's note reaches the saved entry", (tester) async {
    final written = await _pump(tester);
    await tester.tap(_addButton);
    await tester.pumpAndSettle();
    await tester.tap(find.text('LUNCH'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).at(0), '980');
    await tester.pump();
    await tester.tap(find.text('CONFIRM'));
    await tester.pumpAndSettle();

    expect(written.items, hasLength(1));
    final entry = written.items.single;
    expect(entry.note, 'Lunch');
    expect(entry.amount.value, 980);
    expect(
      entry.type,
      TransactionType.expense,
      reason: 'a preset logs spending; anything else would skip the budget',
    );
  });

  testWidgets('"something else" is the free-form sheet, unchanged', (
    tester,
  ) async {
    await _pump(tester);
    await tester.tap(_addButton);
    await tester.pumpAndSettle();
    await tester.tap(find.text('SOMETHING ELSE'));
    await tester.pumpAndSettle();

    expect(find.byType(TransactionForm), findsOneWidget);
    expect(_fieldText(tester, 1), isEmpty, reason: 'nothing was chosen');
    expect(_fieldText(tester, 0), isEmpty);
  });

  testWidgets('the grid fits a narrow screen at double text size', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await _pump(tester, textScale: 2.0);
    await tester.tap(_addButton);
    await tester.pumpAndSettle();

    expect(
      tester.takeException(),
      isNull,
      reason:
          'six tiles must lay out on the smallest screen we support at '
          'the largest text size',
    );
    expect(find.text('LUNCH'), findsOneWidget);
  });

  testWidgets('the first five entries are free; the sixth meets the paywall', (
    tester,
  ) async {
    // The app is free and the planning tool is the paid part (#80). Five
    // entries let someone see the number move; the sixth asks for Pro at the
    // button itself, before any preset is offered.
    await _pump(tester);

    Future<void> logLunch() async {
      await tester.tap(_addButton);
      await tester.pumpAndSettle();
      await tester.tap(find.text('LUNCH'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).at(0), '980');
      await tester.pump();
      await tester.tap(find.text('CONFIRM'));
      await tester.pumpAndSettle();
    }

    for (var i = 0; i < 5; i++) {
      await logLunch();
    }
    expect(find.byType(TransactionForm), findsNothing);

    await tester.tap(_addButton);
    await tester.pumpAndSettle();

    expect(
      find.byType(PaywallScreen),
      findsOneWidget,
      reason: 'the sixth entry is where the free plan ends',
    );
    expect(find.text('LUNCH'), findsNothing, reason: 'no preset is offered');
  });

  testWidgets('the sheet says how many free entries are used', (tester) async {
    // The paywall arriving with no warning read as arbitrary, even to someone
    // who knew the rule. Count down in the open, once the first is spent.
    await _pump(tester, entriesAlreadyLogged: 2);
    await tester.tap(_addButton);
    await tester.pumpAndSettle();

    expect(find.text('2 of 5 free entries used'), findsOneWidget);
  });

  testWidgets('the sheet is quiet before anything is spent', (tester) async {
    await _pump(tester);
    await tester.tap(_addButton);
    await tester.pumpAndSettle();

    expect(find.textContaining('free entries used'), findsNothing);
  });

  testWidgets('each tile wears an icon, not the system\'s emoji artwork', (
    tester,
  ) async {
    // Emoji are drawn by the OS in its own colours, which put a dozen hues
    // the palette never chose into a sheet where every hue means one thing,
    // and they cannot dim with the tile that holds them.
    await _pump(tester);
    await tester.tap(_addButton);
    await tester.pumpAndSettle();

    for (final preset in ProductConfig.presets) {
      expect(
        find.byIcon(preset.glyph),
        findsOneWidget,
        reason: 'a preset is missing its icon',
      );
    }

    final dim = ProductConfig.presets.last;
    expect(
      tester.widget<Icon>(find.byIcon(dim.glyph)).color,
      AppColors.textSecondary,
      reason: 'the dim tile\'s icon dims with it; an emoji could not',
    );
  });

  testWidgets('a tile is announced by its category, once, as a button', (
    tester,
  ) async {
    // The tile was a Text beside an Icon with no button role: VoiceOver read
    // it as static content and gave no sign it could be activated.
    final semantics = tester.ensureSemantics();

    await _pump(tester);
    await tester.tap(_addButton);
    await tester.pumpAndSettle();

    // getSemantics throws on more than one match, so this also proves the
    // icon does not contribute a second node carrying the same label.
    final data = tester
        .getSemantics(find.bySemanticsLabel('COFFEE'))
        .getSemanticsData();
    expect(
      data.flagsCollection.isButton,
      isTrue,
      reason: 'the category is a control, and has to say so',
    );
    expect(
      data.hasAction(SemanticsAction.tap),
      isTrue,
      reason: 'a screen reader must be able to activate it',
    );
    semantics.dispose();
  });

  testWidgets('every tile is big enough to hit', (tester) async {
    await _pump(tester);
    await tester.tap(_addButton);
    await tester.pumpAndSettle();

    for (final label in const [
      'COFFEE',
      'LUNCH',
      'DINNER',
      'TRANSPORT',
      'GROCERIES',
      'SOMETHING ELSE',
    ]) {
      final tile = find
          .ancestor(
            of: find.text(label),
            matching: find.byType(GestureDetector),
          )
          .first;
      expect(
        tester.getSize(tile).height,
        greaterThanOrEqualTo(44),
        reason: '$label is smaller than the 44pt minimum',
      );
    }
  });
}
