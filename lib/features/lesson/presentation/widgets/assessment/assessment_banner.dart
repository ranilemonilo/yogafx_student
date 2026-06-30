import 'package:flutter/material.dart';

import '../../../../../core/theme/app_theme.dart';
import '../../../data/models/lesson_model.dart';
import '../shared/locked_snackbar.dart';

class LessonAssessmentBanner extends StatefulWidget {
  final LessonDetail lesson;
  final bool isUnlocked;
  final Future<void> Function() onOpenAssessment;

  const LessonAssessmentBanner({
    super.key,
    required this.lesson,
    required this.isUnlocked,
    required this.onOpenAssessment,
  });

  @override
  State<LessonAssessmentBanner> createState() => _LessonAssessmentBannerState();
}

class _LessonAssessmentBannerState extends State<LessonAssessmentBanner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseCtrl;
  late final Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
    _pulseAnim = CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasWorkbookGate =
        widget.lesson.workbook.isAvailable &&
        !widget.lesson.progress.isWorkbookDownloaded;
    final hasPlayableVideo =
        widget.lesson.video != null && widget.lesson.video!.isReady;
    final isUnlocked = widget.isUnlocked;
    final lockMessage = hasWorkbookGate
        ? 'Open or download the workbook first to unlock the video and assessment.'
        : hasPlayableVideo
            ? 'Watch at least 95% of the video to unlock it.'
            : 'Complete the lesson materials to unlock it.';

    return AnimatedBuilder(
      animation: _pulseAnim,
      builder: (_, __) => GestureDetector(
        onTap: () {
          if (isUnlocked) {
            widget.onOpenAssessment();
            return;
          }

          showLockedSnackBar(
            context,
            fallbackMessage:
                'You need to complete this lesson before accessing the assessment.',
          );
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isUnlocked ? const Color(0xFF130A08) : AppColors.surfaceElevated,
            borderRadius: BorderRadius.circular(AppRadius.modal),
            border: Border.all(
              color: isUnlocked
                  ? AppColors.primary.withOpacity(0.25 + _pulseAnim.value * 0.2)
                  : AppColors.divider,
              width: 0.8,
            ),
            boxShadow: isUnlocked
                ? [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(
                        0.05 + _pulseAnim.value * 0.07,
                      ),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [],
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isUnlocked
                      ? AppColors.primary.withOpacity(0.12)
                      : AppColors.overlayDark,
                  borderRadius: BorderRadius.circular(AppRadius.avatar),
                ),
                child: Icon(
                  isUnlocked ? Icons.quiz_rounded : Icons.lock_rounded,
                  color: isUnlocked ? AppColors.primary : AppColors.textMuted,
                  size: 18,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isUnlocked ? 'Assessment Available' : 'Assessment Locked',
                      style: TextStyle(
                        color:
                            isUnlocked ? AppColors.textPrimary : AppColors.textMuted,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      isUnlocked ? 'Start the assessment now' : lockMessage,
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 11,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                  ],
                ),
              ),
              if (isUnlocked)
                Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.primary.withOpacity(0.7),
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
