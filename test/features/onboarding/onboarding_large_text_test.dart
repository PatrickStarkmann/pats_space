import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pats_space/features/onboarding/onboarding_screen.dart';
import 'package:pats_space/l10n/generated/app_localizations.dart';

void main() {
  testWidgets('onboarding remains usable with large system text', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('de'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: MediaQuery(
          data: MediaQueryData.fromView(
            tester.view,
          ).copyWith(textScaler: const TextScaler.linear(1.35)),
          child: OnboardingScreen(onStartFocusChallenge: (_) {}),
        ),
      ),
    );

    // Welcome copy finishes before the primary action becomes enabled.
    await tester.pump(const Duration(seconds: 3));
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('Weiter'));
    await tester.pump(const Duration(milliseconds: 400));

    // Pat's introduction has a second progressive text animation.
    await tester.pump(const Duration(seconds: 2));
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('Hi Pat'));
    await tester.pump(const Duration(milliseconds: 400));

    // This used to overflow vertically at the largest iOS text setting.
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Fokussieren, sammeln, wachsen'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('Weiter'));
    await tester.pump(const Duration(milliseconds: 400));

    // Source labels must remain within their tiles instead of overflowing.
    expect(find.text('TikTok'), findsOneWidget);
    await tester.tap(find.text('TikTok'));
    await tester.pump(const Duration(milliseconds: 200));
    expect(tester.takeException(), isNull);
  });
}
