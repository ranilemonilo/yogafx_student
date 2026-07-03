import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/dashboard/presentation/providers/running_login_time_provider.dart';
import '../../features/dashboard/presentation/utils/access_time_helper.dart';
import '../theme/app_theme.dart';

enum RunningLoginTimeCardSize {
  compact,
  regular,
  large,
}

class RunningLoginTimeCard extends ConsumerWidget {
  final RunningLoginTimeCardSize size;

  const RunningLoginTimeCard({
    super.key,
    this.size = RunningLoginTimeCardSize.regular,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final durationAsync = ref.watch(runningLoginTimeProvider);
    final isCompact = size == RunningLoginTimeCardSize.compact;
    final isLarge = size == RunningLoginTimeCardSize.large;
    final verticalPadding = isCompact ? 6.0 : isLarge ? 10.0 : 8.0;
    final horizontalPadding = isCompact ? 10.0 : isLarge ? 14.0 : 12.0;
    final iconSize = isCompact ? 12.0 : isLarge ? 16.0 : 14.0;
    final labelFontSize = isCompact ? 10.0 : isLarge ? 12.0 : 11.0;
    final valueFontSize = isCompact ? 12.0 : isLarge ? 15.0 : 14.0;
    final gap = isCompact ? 6.0 : isLarge ? 9.0 : 8.0;

    Widget buildContent(String value) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.timer_outlined,
            color: AppColors.textMuted,
            size: iconSize,
          ),
          SizedBox(width: gap),
          Text(
            'Running time',
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: labelFontSize,
              fontWeight: FontWeight.w500,
              fontFamily: 'Montserrat',
            ),
          ),
          SizedBox(width: gap),
          Text(
            value,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: valueFontSize,
              fontWeight: FontWeight.w700,
              fontFamily: 'Montserrat',
            ),
          ),
        ],
      );
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: verticalPadding,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: Colors.white.withOpacity(0.08),
          width: 0.7,
        ),
      ),
      child: durationAsync.when(
        data: (duration) => buildContent(formatAccessDuration(duration)),
        loading: () => buildContent('--:--:--'),
        error: (_, __) => buildContent('--:--:--'),
      ),
    );
  }
}
