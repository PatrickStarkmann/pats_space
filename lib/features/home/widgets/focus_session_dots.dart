import 'package:flutter/material.dart';
import 'package:pats_space/core/theme/app_colors.dart';
import 'package:pats_space/core/theme/app_spacing.dart';
import 'package:pats_space/features/focus/models/focus_session_status.dart';

class FocusSessionDots extends StatelessWidget {
  const FocusSessionDots({super.key, required this.states});

  final List<FocusSessionStatus> states;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(states.length, (index) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxs),
          child: _SessionDot(state: states[index]),
        );
      }),
    );
  }
}

class _SessionDot extends StatelessWidget {
  const _SessionDot({required this.state});

  final FocusSessionStatus state;

  @override
  Widget build(BuildContext context) {
    final active = state == FocusSessionStatus.active;
    final complete = state == FocusSessionStatus.complete;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: active || complete ? AppColors.charcoal : AppColors.graySoft,
          width: active || complete ? 2.6 : 1.8,
        ),
      ),
      child: Center(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 160),
          child: switch (state) {
            FocusSessionStatus.empty => const SizedBox.shrink(),
            FocusSessionStatus.active => const DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.charcoal,
                shape: BoxShape.circle,
              ),
              child: SizedBox(width: 7, height: 7),
            ),
            FocusSessionStatus.complete => const Icon(
              Icons.check,
              size: 13,
              color: AppColors.charcoal,
            ),
          },
        ),
      ),
    );
  }
}
