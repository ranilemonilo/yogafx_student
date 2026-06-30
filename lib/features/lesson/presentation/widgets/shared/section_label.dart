import 'package:flutter/material.dart';

import '../../../../../core/theme/app_theme.dart';

class SectionLabel extends StatelessWidget {
  final String text;

  const SectionLabel({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 12,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(AppRadius.badge),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          text.toUpperCase(),
          style: const TextStyle(
            color: AppColors.textMuted,
            fontSize: 9,
            fontWeight: FontWeight.w700,
            fontFamily: 'Montserrat',
            letterSpacing: 2,
          ),
        ),
      ],
    );
  }
}
