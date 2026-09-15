import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_windowmanager_plus/flutter_windowmanager_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:design_system/design_system.dart';
import 'package:presentation/router/app_router.dart';
import 'package:application/application.dart';
import 'package:data/data.dart';
import 'firebase_options.dart';
import 'firebase_analytics_service.dart';
import 'erase_user_data.dart';
import 'revenuecat_service.dart';
import 'runway_root.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Screen security — prevent screenshots and app switcher preview
  if (Platform.isAndroid) {
    await FlutterWindowManagerPlus.addFlags(FlutterWindowManagerPlus.FLAG_SECURE);
  }

  // Firebase init — non-blocking, app works without it
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase init failed: $e');
  }

  final rcService = await RevenueCatService.init();
  final analytics = FirebaseAnalyticsService();
  late AppDatabase database;

  runApp(
    RunwayRoot(
      openSession: () {
        final db = database = AppDatabase();
        return [
          analyticsProvider.overrideWithValue(analytics),
          transactionRepositoryProvider.overrideWithValue(
            DriftTransactionRepository(db),
          ),
          loanRepositoryProvider.overrideWithValue(DriftLoanRepository(db)),
          subscriptionRepositoryProvider.overrideWithValue(
            DriftSubscriptionRepository(db),
          ),
          purchaseServiceProvider.overrideWithValue(rcService),
        ];
      },
      eraseAllData: () => eraseAllUserData(database),
      onRestarted: () => appRouter.go('/boot'),
      child: const SurvivalApp(),
    ),
  );
}

class SurvivalApp extends ConsumerWidget {
  const SurvivalApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localeAsync = ref.watch(localeProvider);

    if (!localeAsync.hasValue) {
      return MaterialApp(
        title: 'Runway',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark,
        home: const Scaffold(backgroundColor: AppColors.background),
      );
    }

    final locale = localeAsync.value;
    return MaterialApp.router(
      title: 'Runway',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      routerConfig: appRouter,
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      localeResolutionCallback: (deviceLocale, supportedLocales) {
        if (locale != null) return locale;
        if (deviceLocale != null) {
          for (final supported in supportedLocales) {
            if (supported.languageCode == deviceLocale.languageCode &&
                supported.countryCode == deviceLocale.countryCode) {
              return supported;
            }
          }
          for (final supported in supportedLocales) {
            if (supported.languageCode == deviceLocale.languageCode) {
              return supported;
            }
          }
        }
        return const Locale('en');
      },
    );
  }
}
