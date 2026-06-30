import 'package:flutter/material.dart';

import '../../../../../core/theme/app_theme.dart';
import '../../../data/models/lesson_model.dart';
import '../shared/section_label.dart';
import 'workbook_sheet.dart';

class LessonWorkbookSection extends StatelessWidget {
  final LessonWorkbook workbook;
  final Future<void> Function() onDismissed;

  const LessonWorkbookSection({
    super.key,
    required this.workbook,
    required this.onDismissed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionLabel(text: 'Workbook'),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () => showWorkbookOptions(
            context: context,
            workbook: workbook,
            onDismissed: onDismissed,
          ),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(AppRadius.modal),
              border: Border.all(color: AppColors.divider, width: 0.8),
            ),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(AppRadius.avatar),
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.22),
                      width: 0.8,
                    ),
                  ),
                  child: const Icon(
                    Icons.description_rounded,
                    color: AppColors.primary,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Lesson Workbook',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Montserrat',
                        ),
                      ),
                      SizedBox(height: 3),
                      Text(
                        'Open or download the workbook',
                        style: TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 11,
                          fontFamily: 'Montserrat',
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.textMuted,
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

void showWorkbookOptions({
  required BuildContext context,
  required LessonWorkbook workbook,
  required Future<void> Function() onDismissed,
}) {
  showModalBottomSheet(
    context: context,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (_) => LessonWorkbookSheet(workbook: workbook),
  ).whenComplete(onDismissed);
}
