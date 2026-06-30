import 'package:flutter/material.dart';

import '../../../../../core/theme/app_theme.dart';

class SheetButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isPrimary;
  final VoidCallback? onTap;

  const SheetButton({
    super.key,
    required this.label,
    required this.icon,
    required this.isPrimary,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isPrimary ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.avatar),
          border: Border.all(
            color: isPrimary ? AppColors.primary : AppColors.divider,
            width: 0.8,
          ),
          boxShadow: isPrimary
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isPrimary ? Colors.white : AppColors.textSecondary,
              size: 16,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isPrimary ? Colors.white : AppColors.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w700,
                fontFamily: 'Montserrat',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
