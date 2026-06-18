import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:video_player/video_player.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/models/course_model.dart';
import '../providers/course_provider.dart';

class CourseDetailScreen extends ConsumerWidget {
  final int courseId;

  const CourseDetailScreen({super.key, required this.courseId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final courseAsync = ref.watch(courseDetailProvider(courseId));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: courseAsync.when(
        loading: () => const _CourseDetailSkeleton(),
        error: (e, _) => _CourseDetailError(
          message: e.toString(),
          onRetry: () => ref.invalidate(courseDetailProvider(courseId)),
        ),
        data: (course) => _CourseDetailContent(course: course),
      ),
    );
  }
}

class _CourseDetailContent extends ConsumerStatefulWidget {
  final CourseItem course;

  const _CourseDetailContent({required this.course});

  @override
  ConsumerState<_CourseDetailContent> createState() =>
      _CourseDetailContentState();
}

class _CourseDetailContentState extends ConsumerState<_CourseDetailContent> {
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;
  bool _initialized = false;
  bool _videoError = false;

  @override
  void initState() {
    super.initState();
    if (widget.course.video.hlsUrl != null && widget.course.video.isReady) {
      _initVideo();
    }
  }

  Future<void> _initVideo() async {
    try {
      _videoController = VideoPlayerController.networkUrl(
        Uri.parse(widget.course.video.hlsUrl!),
      );
      await _videoController!.initialize();
      _chewieController = ChewieController(
        videoPlayerController: _videoController!,
        autoPlay: false,
        looping: false,
        allowFullScreen: true,
        allowMuting: true,
        materialProgressColors: ChewieProgressColors(
          playedColor: AppColors.primary,
          handleColor: AppColors.primary,
          bufferedColor: AppColors.textMuted,
          backgroundColor: AppColors.divider,
        ),
        placeholder: Container(color: Colors.black),
      );
      if (mounted) {
        setState(() => _initialized = true);
      }
    } catch (_) {
      if (mounted) {
        setState(() => _videoError = true);
      }
    }
  }

  @override
  void dispose() {
    _chewieController?.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final course = widget.course;

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          backgroundColor: AppColors.background,
          floating: true,
          snap: true,
          leading: IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          ),
          title: const Text('Course Detail'),
        ),
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AspectRatio(
                aspectRatio: 16 / 9,
                child: _buildVideoArea(course),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      course.title,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      course.description ?? 'No description available.',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                        fontFamily: 'Montserrat',
                        height: 1.5,
                      ),
                    ),
                    if (course.video.warningMessage != null) ...[
                      const SizedBox(height: 14),
                      Text(
                        course.video.warningMessage!,
                        style: const TextStyle(
                          color: AppColors.error,
                          fontSize: 12,
                          fontFamily: 'Montserrat',
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVideoArea(CourseItem course) {
    if (course.video.hlsUrl == null || !course.video.isReady) {
      return _VideoPlaceholder(
        thumbnailUrl: course.thumbnailUrl,
        message: course.video.warningMessage ?? 'Video not available',
      );
    }

    if (_videoError) {
      return _VideoPlaceholder(
        thumbnailUrl: course.thumbnailUrl,
        message: 'Failed to load video',
      );
    }

    if (!_initialized || _chewieController == null) {
      return Stack(
        fit: StackFit.expand,
        children: [
          if (course.thumbnailUrl != null)
            Image.network(course.thumbnailUrl!, fit: BoxFit.cover),
          Container(color: Colors.black.withOpacity(0.4)),
          const Center(
            child: CircularProgressIndicator(
              color: AppColors.primary,
              strokeWidth: 2,
            ),
          ),
        ],
      );
    }

    return Chewie(controller: _chewieController!);
  }
}

class _VideoPlaceholder extends StatelessWidget {
  final String? thumbnailUrl;
  final String message;

  const _VideoPlaceholder({
    this.thumbnailUrl,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        if (thumbnailUrl != null) Image.network(thumbnailUrl!, fit: BoxFit.cover),
        Container(color: Colors.black.withOpacity(0.65)),
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.play_circle_outline,
                  color: AppColors.textMuted, size: 48),
              const SizedBox(height: 8),
              Text(
                message,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  fontFamily: 'Montserrat',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CourseDetailSkeleton extends StatelessWidget {
  const _CourseDetailSkeleton();

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        const SliverAppBar(
          backgroundColor: AppColors.background,
          floating: true,
          snap: true,
          title: Text('Course Detail'),
        ),
        SliverToBoxAdapter(
          child: Column(
            children: [
              Container(height: 220, color: AppColors.shimmer),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Container(
                  height: 120,
                  decoration: BoxDecoration(
                    color: AppColors.shimmer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CourseDetailError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _CourseDetailError({required this.message, required this.onRetry});

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
