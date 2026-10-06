import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// The Plan screen's delta read "1 months longer", and it reached a store
/// screenshot. The strings took a bare placeholder where they needed a plural.
Future<AppLocalizations> _l10n(WidgetTester tester, Locale locale) async {
  late AppLocalizations l10n;
  await tester.pumpWidget(
    MaterialApp(
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Builder(
        builder: (context) {
          l10n = AppLocalizations.of(context);
          return const SizedBox();
        },
      ),
    ),
  );
  await tester.pumpAndSettle();
  return l10n;
}

void main() {
  testWidgets('one of something is singular in English', (tester) async {
    final l10n = await _l10n(tester, const Locale('en'));
    expect(l10n.deltaMonthsLonger(1), '1 month longer');
    expect(l10n.deltaMonthsLonger(3), '3 months longer');
    expect(l10n.deltaMonthsShorter(1), '1 month shorter');
    expect(l10n.deltaDaysLonger(1), '1 day longer');
    expect(l10n.deltaDaysShorter(2), '2 days shorter');
  });

  testWidgets('and in the other languages that inflect', (tester) async {
    expect(
      (await _l10n(tester, const Locale('es'))).deltaMonthsLonger(1),
      '1 mes más',
    );
    expect(
      (await _l10n(tester, const Locale('it'))).deltaMonthsLonger(1),
      '1 mese in più',
    );
    // French "mois" does not inflect, but "jour" does.
    expect(
      (await _l10n(tester, const Locale('fr'))).deltaDaysLonger(1),
      '1 jour de plus',
    );
  });
}
