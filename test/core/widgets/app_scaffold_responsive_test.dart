import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pats_space/app/navigation/app_tab.dart';
import 'package:pats_space/core/theme/app_spacing.dart';
import 'package:pats_space/core/widgets/app_scaffold.dart';
import 'package:pats_space/core/widgets/patsspace_bottom_nav_bar.dart';

void main() {
  for (final size in <Size>[
    const Size(320, 568),
    const Size(375, 667),
    const Size(430, 932),
    const Size(834, 1194),
  ]) {
    testWidgets('lays out the shared app shell at $size', (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          home: AppScaffold(
            bottomNavigation: PatsspaceBottomNavBar(
              selectedTab: AppTab.home,
              onTabSelected: (_) {},
            ),
            child: const Center(child: Text('Responsive content')),
          ),
        ),
      );

      expect(find.text('Responsive content'), findsOneWidget);
      expect(tester.takeException(), isNull);

      final shell = tester.renderObject<RenderBox>(
        find.byWidgetPredicate(
          (widget) =>
              widget is ConstrainedBox &&
              widget.constraints.maxWidth == AppSpacing.maxContentWidth,
        ),
      );
      expect(shell.size.width, lessThanOrEqualTo(AppSpacing.maxContentWidth));
      expect(shell.size.width, lessThanOrEqualTo(size.width));
    });
  }
}
