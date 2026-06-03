import 'package:flutter/material.dart';
import 'package:pats_space/core/theme/app_colors.dart';
import 'package:pats_space/core/theme/app_spacing.dart';

class FocusSessionDots extends StatelessWidget {
  const FocusSessionDots({super.key, required this.states});

  final List<FocusSessionDotState> states;

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

enum FocusSessionDotState { empty, active, complete }

class _SessionDot extends StatelessWidget {
  const _SessionDot({required this.state});

  final FocusSessionDotState state;

  @override
  Widget build(BuildContext context) {
    final active = state == FocusSessionDotState.active;
    final complete = state == FocusSessionDotState.complete;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: 26,
      height: 26,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: active || complete ? AppColors.charcoal : AppColors.graySoft,
          width: active || complete ? 3 : 2,
        ),
      ),
      child: Center(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 160),
          child: switch (state) {
            FocusSessionDotState.empty => const SizedBox.shrink(),
            FocusSessionDotState.active => const DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.charcoal,
                shape: BoxShape.circle,
              ),
              child: SizedBox(width: 8, height: 8),
            ),
            FocusSessionDotState.complete => const Icon(
              Icons.check,
              size: 15,
              color: AppColors.charcoal,
            ),
          },
        ),
      ),
    );
  }
}
