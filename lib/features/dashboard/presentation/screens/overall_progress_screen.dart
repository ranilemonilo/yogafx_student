import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

class OverallProgressScreen extends StatelessWidget {
  final int modulesCompleted;
  final int modulesTotal;
  final int lessonsCompleted;
  final int lessonsTotal;
  final int overallProgressPercentage;

  const OverallProgressScreen({
    super.key,
    required this.modulesCompleted,
    required this.modulesTotal,
    required this.lessonsCompleted,
    required this.lessonsTotal,
    required this.overallProgressPercentage,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Overall Progress'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.divider, width: 0.6),
              ),
              child: Column(
                children: [
                  SizedBox(
                    width: 220,
                    height: 220,
                    child: CustomPaint(
                      painter: _DonutPainter(
                        progress: overallProgressPercentage / 100,
                        progressColor: AppColors.primary,
                        trackColor: AppColors.divider,
                      ),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '$overallProgressPercentage%',
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 34,
                                fontWeight: FontWeight.w700,
                                fontFamily: 'Montserrat',
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Completed',
                              style: TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 12,
                                fontFamily: 'Montserrat',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Learning Progress Overview',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Montserrat',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Statistics',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                fontFamily: 'Montserrat',
              ),
            ),
            const SizedBox(height: 12),
            _StatTile(
              label: 'Total modules',
              value: '$modulesTotal',
            ),
            _StatTile(
              label: 'Modules completed',
              value: '$modulesCompleted',
            ),
            _StatTile(
              label: 'Total lessons',
              value: '$lessonsTotal',
            ),
            _StatTile(
              label: 'Lessons completed',
              value: '$lessonsCompleted',
            ),
            _StatTile(
              label: 'Overall percentage',
              value: '$overallProgressPercentage%',
              highlighted: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  final bool highlighted;

  const _StatTile({
    required this.label,
    required this.value,
    this.highlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: highlighted ? AppColors.primary.withOpacity(0.08) : AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: highlighted ? AppColors.primary.withOpacity(0.25) : AppColors.divider,
          width: 0.6,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                fontFamily: 'Montserrat',
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: highlighted ? AppColors.primary : AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w700,
              fontFamily: 'Montserrat',
            ),
          ),
        ],
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  final double progress;
  final Color progressColor;
  final Color trackColor;

  const _DonutPainter({
    required this.progress,
    required this.progressColor,
    required this.trackColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final strokeWidth = 18.0;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - strokeWidth;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect, -math.pi / 2, math.pi * 2, false, trackPaint);
    canvas.drawArc(
      rect,
      -math.pi / 2,
      math.pi * 2 * progress.clamp(0.0, 1.0),
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _DonutPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.progressColor != progressColor ||
        oldDelegate.trackColor != trackColor;
  }
}
