import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../features/dashboard/presentation/providers/dashboard_provider.dart';
import '../../../../features/lesson/presentation/providers/lesson_provider.dart';
import '../../../../features/module/presentation/providers/module_provider.dart';
import '../providers/assessment_provider.dart';

class AssessmentResultScreen extends ConsumerWidget {
  final int lessonId;
  final int attemptId;

  const AssessmentResultScreen({
    super.key,
    required this.lessonId,
    required this.attemptId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resultAsync = ref.watch(assessmentResultProvider(
      (lessonId: lessonId, attemptId: attemptId),
    ));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: resultAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (error, _) => _ResultError(
          message: error.toString(),
          onBack: () => context.pop(),
          onRetry: () => ref.invalidate(
            assessmentResultProvider((lessonId: lessonId, attemptId: attemptId)),
          ),
        ),
        data: (payload) {
          final mode = payload['mode']?.toString();

          if (mode == 'attempt_redirect') {
            final redirectAttemptId = _extractAttemptId(payload) ?? attemptId;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!context.mounted) return;
              context.pushReplacement(
                '/lessons/$lessonId/assessment/attempts/$redirectAttemptId',
              );
            });
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          final title = _stringOrNull(payload['title']) ??
              _stringOrNull(payload['headline']) ??
              'Assessment Complete';
          final message = _stringOrNull(payload['message']) ??
              _stringOrNull(payload['description']) ??
              'Your assessment has been processed successfully.';

          return _ResultContent(
            title: title,
            message: message,
            onBackToLesson: () {
              ref.invalidate(lessonDetailProvider(lessonId));
              ref.invalidate(moduleListProvider);
              ref.invalidate(dashboardProvider);
              context.go('/lessons/$lessonId');
            },
          );
        },
      ),
    );
  }

  static int? _extractAttemptId(Map<String, dynamic> payload) {
    final rawId = payload['attempt_id'] ??
        payload['attempt']?['id'] ??
        payload['attempt']?['attempt_id'];
    if (rawId is int) return rawId;
    if (rawId is num) return rawId.toInt();
    if (rawId is String) return int.tryParse(rawId);
    return null;
  }

  static String? _stringOrNull(Object? value) {
    final text = value?.toString().trim();
    if (text == null || text.isEmpty) return null;
    return text;
  }
}

class _ResultContent extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback onBackToLesson;

  const _ResultContent({
    required this.title,
    required this.message,
    required this.onBackToLesson,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_rounded,
                color: Colors.white,
                size: 48,
              ),
            ),
            const SizedBox(height: 28),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 24,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: onBackToLesson,
              child: const Text('Back to Lesson'),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () => context.go('/modules'),
              child: const Text('Browse Modules'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultError extends StatelessWidget {
  final String message;
  final VoidCallback onBack;
  final VoidCallback onRetry;

  const _ResultError({
    required this.message,
    required this.onBack,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: AppColors.primary,
              size: 42,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton(
                  onPressed: onBack,
                  child: const Text('Go Back'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: onRetry,
                  child: const Text('Retry'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
