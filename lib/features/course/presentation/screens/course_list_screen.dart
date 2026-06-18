import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/running_login_time_card.dart';
import '../../data/models/course_model.dart';
import '../providers/course_provider.dart';

class CourseListScreen extends ConsumerWidget {
  const CourseListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coursesAsync = ref.watch(courseListProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: coursesAsync.when(
        loading: () => const _CourseListSkeleton(),
        error: (e, _) => _CourseError(
          message: e.toString(),
          onRetry: () => ref.invalidate(courseListProvider),
        ),
        data: (data) => _CourseListContent(data: data),
      ),
    );
  }
}

class _CourseListContent extends ConsumerWidget {
  final CourseListData data;

  const _CourseListContent({required this.data});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () async {
        ref.invalidate(courseListProvider);
        await ref.read(courseListProvider.future);
      },
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          const SliverAppBar(
            backgroundColor: AppColors.background,
            floating: true,
            snap: true,
            title: Text('Courses'),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              child: data.items.isEmpty
                  ? const Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        RunningLoginTimeCard(),
                        SizedBox(height: 12),
                        _CourseEmptyState(),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(bottom: 12),
                          child: RunningLoginTimeCard(),
                        ),
                        ...data.items.map(
                          (item) => Padding(
                            padding: const EdgeInsets.only(bottom: 14),
                            child: _CourseCard(item: item),
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CourseCard extends StatelessWidget {
  final CourseItem item;

  const _CourseCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/courses/${item.id}'),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.divider, width: 0.5),
        ),
        clipBehavior: Clip.hardEdge,
        child: Row(
          children: [
            SizedBox(
              width: 120,
              height: 86,
              child: item.thumbnailUrl != null
                  ? Image.network(
                      item.thumbnailUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: AppColors.surface,
                        child: const Icon(
                          Icons.play_circle_outline,
                          color: AppColors.textMuted,
                        ),
                      ),
                    )
                  : Container(
                      color: AppColors.surface,
                      child: const Icon(
                        Icons.play_circle_outline,
                        color: AppColors.textMuted,
                      ),
                    ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item.status.toUpperCase(),
                      style: TextStyle(
                        color: item.video.isReady
                            ? AppColors.primary
                            : AppColors.textMuted,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Montserrat',
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(right: 12),
              child: Icon(Icons.chevron_right, color: AppColors.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}

class _CourseEmptyState extends StatelessWidget {
  const _CourseEmptyState();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.divider, width: 0.5),
      ),
      child: const Column(
        children: [
          Icon(Icons.ondemand_video_outlined,
              color: AppColors.textMuted, size: 40),
          SizedBox(height: 12),
          Text(
            'No courses available',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w600,
              fontFamily: 'Montserrat',
            ),
          ),
        ],
      ),
    );
  }
}

class _CourseListSkeleton extends StatelessWidget {
  const _CourseListSkeleton();

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        const SliverAppBar(
          backgroundColor: AppColors.background,
          floating: true,
          snap: true,
          title: Text('Courses'),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: List.generate(
                3,
                (_) => Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Container(
                    height: 86,
                    decoration: BoxDecoration(
                      color: AppColors.shimmer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _CourseError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _CourseError({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wifi_off_outlined,
                color: AppColors.textMuted, size: 48),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                fontFamily: 'Montserrat',
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: 140,
              child: ElevatedButton(
                onPressed: onRetry,
                child: const Text('Try again'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
