import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/dashboard/presentation/providers/running_login_time_provider.dart';
import '../theme/app_theme.dart';

class RunningLoginTimeCard extends ConsumerWidget {
  const RunningLoginTimeCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final durationAsync = ref.watch(runningLoginTimeProvider);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: Colors.white.withOpacity(0.08),
          width: 0.7,
        ),
      ),
      child: durationAsync.when(
        data: (duration) => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.timer_outlined,
              color: AppColors.textMuted,
              size: 14,
            ),
            const SizedBox(width: 8),
            const Text(
              'Running time',
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 11,
                fontWeight: FontWeight.w500,
                fontFamily: 'Montserrat',
              ),
            ),
            const SizedBox(width: 8),
            Text(
              _formatDuration(duration),
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w700,
                fontFamily: 'Montserrat',
              ),
            ),
          ],
        ),
        loading: () => const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.timer_outlined, color: AppColors.textMuted, size: 14),
            SizedBox(width: 8),
            Text(
              'Running time',
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 11,
                fontWeight: FontWeight.w500,
                fontFamily: 'Montserrat',
              ),
            ),
            SizedBox(width: 8),
            Text(
              '--:--:--',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w700,
                fontFamily: 'Montserrat',
              ),
            ),
          ],
        ),
        error: (_, __) => const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.timer_outlined, color: AppColors.textMuted, size: 14),
            SizedBox(width: 8),
            Text(
              'Running time',
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 11,
                fontWeight: FontWeight.w500,
                fontFamily: 'Montserrat',
              ),
            ),
            SizedBox(width: 8),
            Text(
              '--:--:--',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w700,
                fontFamily: 'Montserrat',
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final totalHours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    return '${totalHours.toString().padLeft(2, '0')}:'
        '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }
}
