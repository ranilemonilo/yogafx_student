import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/storage/secure_storage.dart';
import '../../../../core/widgets/auth_network_image.dart';
import '../../../dashboard/presentation/providers/dashboard_provider.dart';
import '../../../module/presentation/providers/module_provider.dart';
import '../../data/models/lesson_model.dart';
import '../providers/lesson_provider.dart';
import '../../../../features/lesson/data/repositories/lesson_repository.dart';

// ─── Design Tokens ────────────────────────────────────────────────────────────

const _kRed = Color(0xFFE50914);
const _kBg = Color(0xFF0D0D0D);
const _kSurface = Color(0xFF161616);
const _kSurfaceElevated = Color(0xFF1E1E1E);
const _kSurfaceHigh = Color(0xFF262626);
const _kDivider = Color(0xFF252525);
const _kTextPrimary = Colors.white;
const _kTextSecondary = Color(0xFFB3B3B3);
const _kTextMuted = Color(0xFF6B6B6B);
const _kGreen = Color(0xFF46D369);
final _lessonContentKey = GlobalKey<_LessonContentState>();

// ─── Root Screen ──────────────────────────────────────────────────────────────

class LessonScreen extends ConsumerWidget {
  final int lessonId;
  const LessonScreen({super.key, required this.lessonId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lessonAsync = ref.watch(lessonDetailProvider(lessonId));

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final state = _lessonContentKey.currentState;
        if (state != null) {
          await state.prepareForNavigation(context);
        }
        if (context.mounted) {
          _handleLessonBack(context);
        }
      },
      child: Scaffold(
        backgroundColor: _kBg,
        body: lessonAsync.when(
          loading: () => const _LessonSkeleton(),
          error: (e, _) => _LessonError(
            message: e.toString(),
            onRetry: () => ref.invalidate(lessonDetailProvider(lessonId)),
            onBack: () => _handleLessonBack(context),
          ),
          data: (lesson) => _LessonContent(
            key: _lessonContentKey,
            lesson: lesson,
          ),
        ),
      ),
    );
  }
}

void _handleLessonBack(BuildContext context) {
  if (Navigator.of(context).canPop()) {
    context.pop();
    return;
  }
  context.go(AppRoutes.modules);
}

void _showLockedSnackBar(
  BuildContext context, {
  required String fallbackMessage,
  String? reason,
}) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(reason ?? fallbackMessage),
      ),
    );
}

// ─── Content ──────────────────────────────────────────────────────────────────

class _LessonContent extends ConsumerStatefulWidget {
  final LessonDetail lesson;
  const _LessonContent({super.key, required this.lesson});

  @override
  ConsumerState<_LessonContent> createState() => _LessonContentState();
}

class _LessonContentState extends ConsumerState<_LessonContent>
    with TickerProviderStateMixin {
  VideoPlayerController? _videoController;
  AudioPlayer? _audioPlayer;
  bool _videoInitialized = false;
  bool _videoError = false;
  bool _audioLoading = false;
  bool _audioReady = false;
  String? _audioError;
  int _lastReportedProgress = 0;
  int? _autoNextRemainingSeconds;
  bool _isAutoNavigating = false;

  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;
  late AnimationController _progressCtrl;
  late Animation<double> _progressAnim;

  @override
  void initState() {
    super.initState();
    _lastReportedProgress = widget.lesson.progress.watchProgress;

    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);

    _progressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _progressAnim = Tween<double>(
      begin: 0,
      end: widget.lesson.progress.watchProgress / 100,
    ).animate(CurvedAnimation(parent: _progressCtrl, curve: Curves.easeOut));

    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        _fadeCtrl.forward();
        _progressCtrl.forward();
      }
    });

    if (widget.lesson.video != null && widget.lesson.video!.isReady) {
      _initVideo();
    }
    if (widget.lesson.audio.isAvailable && widget.lesson.audio.url != null) {
      _initAudio();
    }
  }

  Future<void> _initVideo() async {
    final video = widget.lesson.video!;
    try {
      _videoController = VideoPlayerController.networkUrl(
        Uri.parse(video.hlsUrl),
      );
      await _videoController!.initialize();

      if (_lastReportedProgress > 0 && _lastReportedProgress < 100) {
        final duration = _videoController!.value.duration;
        final seekTo = duration * (_lastReportedProgress / 100);
        await _videoController!.seekTo(seekTo);
      }

      _videoController!.addListener(_onVideoProgress);
      if (mounted) setState(() => _videoInitialized = true);
    } catch (e) {
      if (mounted) setState(() => _videoError = true);
    }
  }

  void _onVideoProgress() {
    if (_videoController == null) return;
    final value = _videoController!.value;
    if (!value.isInitialized || value.duration.inSeconds == 0) return;

    final currentProgress =
    ((value.position.inSeconds / value.duration.inSeconds) * 100).round();

    if (currentProgress >= _lastReportedProgress + 5 && currentProgress <= 100) {
      _lastReportedProgress = currentProgress;
      ref
          .read(lessonRepositoryProvider)
          .updateProgress(widget.lesson.id, currentProgress);
      if (currentProgress >= 100) {
        _refreshLearningState();
      }
    }

    _handleAutoNext(value);
  }

  void _handleAutoNext(VideoPlayerValue value) {
    final nextLesson = widget.lesson.nextLesson;
    final shouldAutoNavigate =
        nextLesson != null &&
        nextLesson.isUnlocked &&
        widget.lesson.assessment == null;

    if (!shouldAutoNavigate) {
      if (_autoNextRemainingSeconds != null && mounted) {
        setState(() => _autoNextRemainingSeconds = null);
      }
      return;
    }

    final remaining = value.duration - value.position;
    final remainingSeconds = remaining.inSeconds;

    if (remainingSeconds > 10 || remainingSeconds <= 0) {
      if (_autoNextRemainingSeconds != null && mounted) {
        setState(() => _autoNextRemainingSeconds = null);
      }
      return;
    }

    if (_autoNextRemainingSeconds != remainingSeconds && mounted) {
      setState(() => _autoNextRemainingSeconds = remainingSeconds);
    }

    if (remainingSeconds == 1 && !_isAutoNavigating) {
      _isAutoNavigating = true;
      Future.microtask(() async {
        if (!mounted) return;
        await _navigateToLesson(context, nextLesson.id);
      });
    }
  }

  void _refreshLearningState() {
    ref.invalidate(lessonDetailProvider(widget.lesson.id));
    ref.invalidate(moduleDetailProvider(widget.lesson.module.id));
    ref.invalidate(moduleListProvider);
    ref.invalidate(dashboardProvider);
  }

  Future<void> _initAudio() async {
    final url = widget.lesson.audio.url;
    if (url == null || url.isEmpty) return;

    setState(() {
      _audioLoading = true;
      _audioError = null;
    });

    try {
      _audioPlayer?.dispose();
      final player = AudioPlayer();
      final token = await SecureStorageService.getToken();
      await player.setUrl(
        url,
        headers: token == null || token.isEmpty
            ? null
            : {'Authorization': 'Bearer $token'},
      );
      if (!mounted) {
        await player.dispose();
        return;
      }
      setState(() {
        _audioPlayer = player;
        _audioReady = true;
      });
    } catch (e) {
      if (mounted) setState(() => _audioError = 'Audio failed to load');
    } finally {
      if (mounted) setState(() => _audioLoading = false);
    }
  }

  Future<void> prepareForNavigation(BuildContext context) async {
    _isAutoNavigating = true;
    _refreshLearningState();

    if (context.mounted) {
      Navigator.of(
        context,
        rootNavigator: false,
      ).popUntil((route) => route.settings.name != null || route.isFirst);
    }

    await _videoController?.pause();
    await _audioPlayer?.pause();

    if (mounted) {
      setState(() => _videoInitialized = false);
    }

    await Future.delayed(Duration.zero);

    await _audioPlayer?.dispose();
    _audioPlayer = null;

    _videoController?.removeListener(_onVideoProgress);
    await _videoController?.dispose();
    _videoController = null;
  }

  Future<void> _handleBack(BuildContext context) async {
    await prepareForNavigation(context);
    if (!mounted) return;
    _handleLessonBack(context);
  }

  Future<void> _navigateToLesson(BuildContext context, int lessonId) async {
    await prepareForNavigation(context);
    if (!mounted) return;
    context.go('/lessons/$lessonId');
  }

  @override
  void dispose() {
    _videoController?.removeListener(_onVideoProgress);

    _videoController?.dispose();
    _videoController = null;

    _audioPlayer?.dispose();
    _audioPlayer = null;
    _fadeCtrl.dispose();
    _progressCtrl.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    super.dispose();
  }

  Future<void> _toggleVideoPlayback() async {
    final controller = _videoController;
    if (controller == null || !controller.value.isInitialized) return;

    if (controller.value.isPlaying) {
      await controller.pause();
    } else {
      await controller.play();
    }
  }

  Future<void> _seekVideo(Duration position) async {
    final controller = _videoController;
    if (controller == null || !controller.value.isInitialized) return;

    final duration = controller.value.duration;
    final safePosition = position > duration ? duration : position;
    await controller.seekTo(safePosition < Duration.zero ? Duration.zero : safePosition);
  }

  Future<void> _toggleMute() async {
    final controller = _videoController;
    if (controller == null || !controller.value.isInitialized) return;

    final nextMuted = controller.value.volume > 0;
    await controller.setVolume(nextMuted ? 0 : 1);
    if (mounted) setState(() {});
  }

  Future<void> _openFullscreen() async {
    final controller = _videoController;
    if (controller == null || !controller.value.isInitialized) return;
    if (!mounted) return;

    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => _FullscreenVideoScreen(
          controller: controller,
          onTogglePlayback: _toggleVideoPlayback,
          onSeek: _seekVideo,
          onToggleMute: _toggleMute,
        ),
      ),
    );

    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final lesson = widget.lesson;

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // Video
        SliverToBoxAdapter(
          child: _VideoSection(
            lesson: lesson,
            videoInitialized: _videoInitialized,
            videoError: _videoError,
            videoController: _videoController,
            onRetry: _initVideo,
            onBack: () => _handleBack(context),
            onTogglePlayback: _toggleVideoPlayback,
            onSeek: _seekVideo,
            onToggleMute: _toggleMute,
            onOpenFullscreen: _openFullscreen,
          ),
        ),

        // Body
        SliverToBoxAdapter(
          child: FadeTransition(
            opacity: _fadeAnim,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 48),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Breadcrumb
                  _ModuleBreadcrumb(module: lesson.module),
                  const SizedBox(height: 10),

                  // Title
                  Text(
                    lesson.title,
                    style: const TextStyle(
                      color: _kTextPrimary,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      fontFamily: 'Montserrat',
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Progress
                  _LessonProgressBar(
                    progress: lesson.progress,
                    animation: _progressAnim,
                  ),
                  const SizedBox(height: 20),

                  // Action chips
                  _ActionRow(
                    lesson: lesson,
                    audioLoading: _audioLoading,
                    audioReady: _audioReady,
                    audioError: _audioError,
                    audioPlayer: _audioPlayer,
                    onRetryAudio: _initAudio,
                  ),
                  const SizedBox(height: 28),

                  // Content
                  if (lesson.content != null && lesson.content!.isNotEmpty) ...[
                    _ContentSection(content: lesson.content!),
                    const SizedBox(height: 28),
                  ],

                  // Workbook
                  if (lesson.workbook.isAvailable) ...[
                    _WorkbookSection(workbook: lesson.workbook),
                    const SizedBox(height: 28),
                  ],

                  // Assessment
                  if (lesson.assessment != null) ...[
                    _AssessmentBanner(
                      lessonId: lesson.id,
                      progress: lesson.progress,
                    ),
                    const SizedBox(height: 28),
                  ],

                  // Navigation
                  if (lesson.navigation.isNotEmpty) ...[
                    _NavigationSection(
                      navigation: lesson.navigation,
                      currentLessonId: lesson.id,
                      onNavigate: (lessonId) =>
                          _navigateToLesson(context, lessonId),
                    ),
                    const SizedBox(height: 28),
                  ],

                  // Next lesson
                  if (lesson.nextLesson != null)
                    _NextLessonBanner(
                      nextLesson: lesson.nextLesson!,
                      countdownSeconds: lesson.assessment == null
                          ? _autoNextRemainingSeconds
                          : null,
                      onNavigate: (lessonId) =>
                          _navigateToLesson(context, lessonId),
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Video Section ────────────────────────────────────────────────────────────

class _VideoSection extends StatelessWidget {
  final LessonDetail lesson;
  final bool videoInitialized;
  final bool videoError;
  final VideoPlayerController? videoController;
  final VoidCallback onRetry;
  final VoidCallback onBack;
  final Future<void> Function() onTogglePlayback;
  final Future<void> Function(Duration position) onSeek;
  final Future<void> Function() onToggleMute;
  final Future<void> Function() onOpenFullscreen;

  const _VideoSection({
    required this.lesson,
    required this.videoInitialized,
    required this.videoError,
    required this.videoController,
    required this.onRetry,
    required this.onBack,
    required this.onTogglePlayback,
    required this.onSeek,
    required this.onToggleMute,
    required this.onOpenFullscreen,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AspectRatio(
          aspectRatio: 16 / 9,
          child: Container(
            color: Colors.black,
            child: _buildVideoBody(),
          ),
        ),
        // Back button overlay
        Positioned(
          top: MediaQuery.paddingOf(context).top + 8,
          left: 12,
          child: GestureDetector(
            onTap: onBack,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.55),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: Colors.white.withOpacity(0.12),
                  width: 0.8,
                ),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
                size: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVideoBody() {
    if (lesson.video == null || !lesson.video!.isReady) {
      return _VideoPlaceholder(
        thumbnailUrl: lesson.thumbnailUrl,
        message: 'Video is not available.',
      );
    }
    if (videoError) {
      return _VideoPlaceholder(
        thumbnailUrl: lesson.thumbnailUrl,
        message: 'Failed to load video.',
        showRetry: true,
        onRetry: onRetry,
      );
    }
    if (!videoInitialized) {
      return Stack(
        fit: StackFit.expand,
        children: [
          if (lesson.thumbnailUrl != null)
            AuthNetworkImage(
              imageUrl: lesson.thumbnailUrl!,
              fit: BoxFit.cover,
              placeholderBuilder: (_) =>
                  Container(color: _kSurfaceElevated),
              errorBuilderWidget: (_, __) =>
                  Container(color: _kSurfaceElevated),
            ),
          Container(color: Colors.black.withOpacity(0.5)),
          const Center(
            child: CircularProgressIndicator(
              color: _kRed,
              strokeWidth: 2,
            ),
          ),
        ],
      );
    }
    final controller = videoController;
    if (controller == null) {
      return _VideoPlaceholder(
        thumbnailUrl: lesson.thumbnailUrl,
        message: 'Video is not available.',
      );
    }

    return _InlineVideoPlayer(
      controller: controller,
      onTogglePlayback: onTogglePlayback,
      onSeek: onSeek,
      onToggleMute: onToggleMute,
      onOpenFullscreen: onOpenFullscreen,
    );
  }
}

class _InlineVideoPlayer extends StatelessWidget {
  final VideoPlayerController controller;
  final Future<void> Function() onTogglePlayback;
  final Future<void> Function(Duration position) onSeek;
  final Future<void> Function() onToggleMute;
  final Future<void> Function() onOpenFullscreen;

  const _InlineVideoPlayer({
    required this.controller,
    required this.onTogglePlayback,
    required this.onSeek,
    required this.onToggleMute,
    required this.onOpenFullscreen,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<VideoPlayerValue>(
      valueListenable: controller,
      builder: (context, value, _) {
        final duration = value.duration;
        final position = value.position > duration ? duration : value.position;
        final isMuted = value.volume == 0;

        return Stack(
          fit: StackFit.expand,
          children: [
            FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: value.size.width,
                height: value.size.height,
                child: VideoPlayer(controller),
              ),
            ),
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0x66000000),
                    Color(0x11000000),
                    Color(0x77000000),
                  ],
                ),
              ),
            ),
            Center(
              child: GestureDetector(
                onTap: onTogglePlayback,
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.45),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withOpacity(0.16),
                    ),
                  ),
                  child: Icon(
                    value.isPlaying
                        ? Icons.pause_rounded
                        : Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: 34,
                  ),
                ),
              ),
            ),
            Positioned(
              left: 12,
              right: 12,
              bottom: 10,
              child: _VideoControlsBar(
                duration: duration,
                position: position,
                isPlaying: value.isPlaying,
                isMuted: isMuted,
                onTogglePlayback: onTogglePlayback,
                onSeek: onSeek,
                onToggleMute: onToggleMute,
                onOpenFullscreen: onOpenFullscreen,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _VideoControlsBar extends StatelessWidget {
  final Duration duration;
  final Duration position;
  final bool isPlaying;
  final bool isMuted;
  final Future<void> Function() onTogglePlayback;
  final Future<void> Function(Duration position) onSeek;
  final Future<void> Function() onToggleMute;
  final Future<void> Function() onOpenFullscreen;

  const _VideoControlsBar({
    required this.duration,
    required this.position,
    required this.isPlaying,
    required this.isMuted,
    required this.onTogglePlayback,
    required this.onSeek,
    required this.onToggleMute,
    required this.onOpenFullscreen,
  });

  @override
  Widget build(BuildContext context) {
    final maxMillis = duration.inMilliseconds <= 0 ? 1 : duration.inMilliseconds;
    final currentMillis = position.inMilliseconds.clamp(0, maxMillis);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.58),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 2.5,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 5),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 10),
              activeTrackColor: _kRed,
              inactiveTrackColor: Colors.white24,
              thumbColor: _kRed,
              overlayColor: _kRed.withOpacity(0.18),
            ),
            child: Slider(
              value: currentMillis.toDouble(),
              max: maxMillis.toDouble(),
              onChanged: (value) => onSeek(Duration(milliseconds: value.round())),
            ),
          ),
          Row(
            children: [
              _VideoControlButton(
                icon: isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                onTap: onTogglePlayback,
              ),
              _VideoControlButton(
                icon: isMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
                onTap: onToggleMute,
              ),
              Expanded(
                child: Text(
                  '${_formatVideoDuration(position)} / ${_formatVideoDuration(duration)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Montserrat',
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              _VideoControlButton(
                icon: Icons.fullscreen_rounded,
                onTap: onOpenFullscreen,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _VideoControlButton extends StatelessWidget {
  final IconData icon;
  final Future<void> Function() onTap;

  const _VideoControlButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 32,
        height: 32,
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}

class _FullscreenVideoScreen extends StatefulWidget {
  final VideoPlayerController controller;
  final Future<void> Function() onTogglePlayback;
  final Future<void> Function(Duration position) onSeek;
  final Future<void> Function() onToggleMute;

  const _FullscreenVideoScreen({
    required this.controller,
    required this.onTogglePlayback,
    required this.onSeek,
    required this.onToggleMute,
  });

  @override
  State<_FullscreenVideoScreen> createState() => _FullscreenVideoScreenState();
}

class _FullscreenVideoScreenState extends State<_FullscreenVideoScreen> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setPreferredOrientations(const [
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations(const [DeviceOrientation.portraitUp]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        Navigator.of(context).pop();
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Stack(
            children: [
              Center(
                child: AspectRatio(
                  aspectRatio: widget.controller.value.aspectRatio == 0
                      ? 16 / 9
                      : widget.controller.value.aspectRatio,
                  child: _InlineVideoPlayer(
                    controller: widget.controller,
                    onTogglePlayback: widget.onTogglePlayback,
                    onSeek: widget.onSeek,
                    onToggleMute: widget.onToggleMute,
                    onOpenFullscreen: () async => Navigator.of(context).pop(),
                  ),
                ),
              ),
              Positioned(
                top: 12,
                left: 12,
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.55),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _formatVideoDuration(Duration duration) {
  final totalSeconds = duration.inSeconds;
  final hours = totalSeconds ~/ 3600;
  final minutes = (totalSeconds % 3600) ~/ 60;
  final seconds = totalSeconds % 60;

  if (hours > 0) {
    return '${hours.toString().padLeft(2, '0')}:'
        '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  return '${minutes.toString().padLeft(2, '0')}:'
      '${seconds.toString().padLeft(2, '0')}';
}

class _VideoPlaceholder extends StatelessWidget {
  final String? thumbnailUrl;
  final String message;
  final bool showRetry;
  final VoidCallback? onRetry;

  const _VideoPlaceholder({
    this.thumbnailUrl,
    required this.message,
    this.showRetry = false,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        if (thumbnailUrl != null)
          AuthNetworkImage(
            imageUrl: thumbnailUrl!,
            fit: BoxFit.cover,
            placeholderBuilder: (_) => Container(color: _kSurfaceElevated),
            errorBuilderWidget: (_, __) => Container(color: _kSurfaceElevated),
          ),
        Container(color: Colors.black.withOpacity(0.65)),
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.play_circle_outline_rounded,
                  color: _kTextMuted, size: 48),
              const SizedBox(height: 10),
              Text(
                message,
                style: const TextStyle(
                  color: _kTextSecondary,
                  fontSize: 13,
                  fontFamily: 'Montserrat',
                ),
              ),
              if (showRetry && onRetry != null) ...[
                const SizedBox(height: 14),
                GestureDetector(
                  onTap: onRetry,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(
                      color: _kRed,
                      borderRadius: BorderRadius.circular(4),
                      boxShadow: [
                        BoxShadow(
                          color: _kRed.withOpacity(0.35),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Text(
                      'Try again',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Module Breadcrumb ────────────────────────────────────────────────────────

class _ModuleBreadcrumb extends StatelessWidget {
  final LessonModule module;
  const _ModuleBreadcrumb({required this.module});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _handleLessonBack(context),
      child: Row(
        children: [
          const Icon(Icons.layers_rounded, color: _kTextMuted, size: 12),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              module.title,
              style: const TextStyle(
                color: _kTextMuted,
                fontSize: 11,
                fontFamily: 'Montserrat',
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
            decoration: BoxDecoration(
              color: _kSurfaceHigh,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '${module.completedLessons}/${module.lessonCount}',
              style: const TextStyle(
                color: _kTextMuted,
                fontSize: 10,
                fontFamily: 'Montserrat',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Progress Bar ─────────────────────────────────────────────────────────────

class _LessonProgressBar extends StatelessWidget {
  final LessonProgress progress;
  final Animation<double> animation;
  const _LessonProgressBar({required this.progress, required this.animation});

  @override
  Widget build(BuildContext context) {
    final isDone = progress.isDone;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedBuilder(
          animation: animation,
          builder: (_, __) => ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: animation.value,
              backgroundColor: _kDivider,
              valueColor: AlwaysStoppedAnimation<Color>(
                isDone ? _kGreen : _kRed,
              ),
              minHeight: 2.5,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            if (isDone) ...[
              const Icon(Icons.check_circle_rounded,
                  color: _kGreen, size: 13),
              const SizedBox(width: 5),
              const Text(
                'Completed',
                style: TextStyle(
                  color: _kGreen,
                  fontSize: 11,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ] else ...[
              Text(
                '${progress.watchProgress}% watched',
                style: const TextStyle(
                  color: _kTextMuted,
                  fontSize: 11,
                  fontFamily: 'Montserrat',
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

// ─── Action Row ───────────────────────────────────────────────────────────────

class _ActionRow extends StatelessWidget {
  final LessonDetail lesson;
  final bool audioLoading;
  final bool audioReady;
  final String? audioError;
  final AudioPlayer? audioPlayer;
  final Future<void> Function() onRetryAudio;

  const _ActionRow({
    required this.lesson,
    required this.audioLoading,
    required this.audioReady,
    required this.audioError,
    required this.audioPlayer,
    required this.onRetryAudio,
  });

  void _openWorkbook(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: _kSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => _WorkbookSheet(workbook: lesson.workbook),
    );
  }

  void _openAudio(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: _kSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => _AudioSheet(
        audio: lesson.audio,
        audioLoading: audioLoading,
        audioReady: audioReady,
        audioError: audioError,
        audioPlayer: audioPlayer,
        onRetryAudio: onRetryAudio,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        if (lesson.workbook.isAvailable)
          _ActionChip(
            icon: Icons.description_rounded,
            label: 'Workbook',
            onTap: () => _openWorkbook(context),
          ),
        if (lesson.audio.isAvailable)
          _ActionChip(
            icon: Icons.headphones_rounded,
            label: audioLoading
                ? 'Loading audio...'
                : audioReady
                ? 'Audio'
                : 'Audio Unavailable',
            onTap: lesson.audio.url == null
                ? null
                : () => _openAudio(context),
          ),
        if (lesson.assessment != null)
          _ActionChip(
            icon: Icons.quiz_rounded,
            label: 'Assessment',
            onTap: () => context.push('/lessons/${lesson.id}/assessment'),
          ),
      ],
    );
  }
}

class _ActionChip extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  const _ActionChip({required this.icon, required this.label, this.onTap});

  @override
  State<_ActionChip> createState() => _ActionChipState();
}

class _ActionChipState extends State<_ActionChip>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 140),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.94).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onTap != null;
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: enabled ? (_) => _ctrl.forward() : null,
      onTapUp: enabled ? (_) => _ctrl.reverse() : null,
      onTapCancel: enabled ? () => _ctrl.reverse() : null,
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            color: _kSurfaceElevated,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: _kDivider, width: 0.8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.icon,
                color: enabled ? _kTextSecondary : _kTextMuted,
                size: 14,
              ),
              const SizedBox(width: 7),
              Text(
                widget.label,
                style: TextStyle(
                  color: enabled ? _kTextSecondary : _kTextMuted,
                  fontSize: 12,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Content Section ──────────────────────────────────────────────────────────

class _ContentSection extends StatelessWidget {
  final String content;
  const _ContentSection({required this.content});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionLabel(text: 'About This Lesson'),
        const SizedBox(height: 12),
        Text(
          content,
          style: const TextStyle(
            color: _kTextSecondary,
            fontSize: 13,
            fontFamily: 'Montserrat',
            height: 1.75,
          ),
        ),
      ],
    );
  }
}

// ─── Workbook Section ─────────────────────────────────────────────────────────

class _WorkbookSection extends StatelessWidget {
  final LessonWorkbook workbook;
  const _WorkbookSection({required this.workbook});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionLabel(text: 'Workbook'),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () => showModalBottomSheet(
            context: context,
            backgroundColor: _kSurface,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            builder: (_) => _WorkbookSheet(workbook: workbook),
          ),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _kSurfaceElevated,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _kDivider, width: 0.8),
            ),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: _kRed.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: _kRed.withOpacity(0.22), width: 0.8),
                  ),
                  child: const Icon(Icons.description_rounded,
                      color: _kRed, size: 18),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Lesson Workbook',
                        style: TextStyle(
                          color: _kTextPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Montserrat',
                        ),
                      ),
                      SizedBox(height: 3),
                      Text(
                        'Open or download the workbook',
                        style: TextStyle(
                          color: _kTextMuted,
                          fontSize: 11,
                          fontFamily: 'Montserrat',
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded,
                    color: _kTextMuted, size: 18),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Workbook Sheet ───────────────────────────────────────────────────────────

class _WorkbookSheet extends StatelessWidget {
  final LessonWorkbook workbook;
  const _WorkbookSheet({required this.workbook});

  Future<void> _downloadWorkbook(BuildContext context, String url) async {
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    messenger.showSnackBar(
      const SnackBar(content: Text('Downloading workbook...')),
    );
    navigator.pop();
    try {
      final fileName = _buildFileName(workbook.fileName);
      final directory = await _resolveDownloadDirectory();
      final targetPath = '${directory.path}${Platform.pathSeparator}$fileName';
      final dio = ApiClient.create();
      await dio.download(url, targetPath);
      messenger.showSnackBar(
        SnackBar(content: Text('Saved to $targetPath')),
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('Download failed: $e')),
      );
    }
  }

  Future<Directory> _resolveDownloadDirectory() async {
    if (Platform.isAndroid) {
      final publicDownloads = Directory('/storage/emulated/0/Download');
      if (await publicDownloads.exists()) return publicDownloads;
      throw const FileSystemException('Download folder not found');
    }
    final downloadsDir = await getDownloadsDirectory();
    if (downloadsDir != null) return downloadsDir;
    throw const FileSystemException('Download folder not found');
  }

  String _buildFileName(String? rawName) {
    final baseName = (rawName == null || rawName.trim().isEmpty)
        ? 'workbook_${DateTime.now().millisecondsSinceEpoch}.pdf'
        : rawName.trim();
    return baseName.toLowerCase().endsWith('.pdf')
        ? baseName
        : '$baseName.pdf';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 36,
              height: 3,
              decoration: BoxDecoration(
                color: _kDivider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 22),
          const Text(
            'Workbook',
            style: TextStyle(
              color: _kTextPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w800,
              fontFamily: 'Montserrat',
            ),
          ),
          const SizedBox(height: 4),
          Text(
            workbook.fileName ?? 'Lesson file',
            style: const TextStyle(
              color: _kTextMuted,
              fontSize: 12,
              fontFamily: 'Montserrat',
            ),
          ),
          const SizedBox(height: 24),

          if (workbook.url != null)
            _SheetButton(
              label: 'Open Workbook',
              icon: Icons.open_in_new_rounded,
              isPrimary: true,
              onTap: () {
                Navigator.pop(context);
                context.push(
                  AppRoutes.workbookViewer,
                  extra: {
                    'url': workbook.url!,
                    'title': workbook.fileName ?? 'Workbook',
                  },
                );
              },
            ),
          if (workbook.downloadUrl != null) ...[
            const SizedBox(height: 10),
            _SheetButton(
              label: 'Download',
              icon: Icons.download_rounded,
              isPrimary: false,
              onTap: () => _downloadWorkbook(context, workbook.downloadUrl!),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Audio Sheet ──────────────────────────────────────────────────────────────

class _AudioSheet extends StatelessWidget {
  final LessonAudio audio;
  final bool audioLoading;
  final bool audioReady;
  final String? audioError;
  final AudioPlayer? audioPlayer;
  final Future<void> Function() onRetryAudio;

  const _AudioSheet({
    required this.audio,
    required this.audioLoading,
    required this.audioReady,
    required this.audioError,
    required this.audioPlayer,
    required this.onRetryAudio,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 3,
              decoration: BoxDecoration(
                color: _kDivider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 22),
          const Text(
            'Audio',
            style: TextStyle(
              color: _kTextPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w800,
              fontFamily: 'Montserrat',
            ),
          ),
          const SizedBox(height: 6),
          if (audioLoading)
            const Text(
              'Loading audio...',
              style: TextStyle(
                  color: _kTextMuted, fontSize: 12, fontFamily: 'Montserrat'),
            )
          else if (audioError != null)
            Text(
              audioError!,
              style: const TextStyle(
                  color: Color(0xFFE57373),
                  fontSize: 12,
                  fontFamily: 'Montserrat'),
            )
          else
            const Text(
              'Play the audio for this lesson',
              style: TextStyle(
                  color: _kTextMuted, fontSize: 12, fontFamily: 'Montserrat'),
            ),
          const SizedBox(height: 24),
          if (audioReady && audioPlayer != null)
            StreamBuilder<PlayerState>(
              stream: audioPlayer?.playerStateStream ?? const Stream.empty(),
              builder: (context, snapshot) {
                final playing = snapshot.data?.playing ?? false;
                return _SheetButton(
                  label: playing ? 'Pause Audio' : 'Play Audio',
                  icon: playing
                      ? Icons.pause_rounded
                      : Icons.play_arrow_rounded,
                  isPrimary: true,
                  onTap: () async {
                    if (audioPlayer == null) return;
                    if (playing) {
                      await audioPlayer!.pause();
                    } else {
                      await audioPlayer!.play();
                    }
                  },
                );
              },
            )
          else
            _SheetButton(
              label: 'Try Again',
              icon: Icons.refresh_rounded,
              isPrimary: false,
              onTap: onRetryAudio,
            ),
        ],
      ),
    );
  }
}

// ─── Sheet Button ─────────────────────────────────────────────────────────────

class _SheetButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isPrimary;
  final VoidCallback? onTap;
  const _SheetButton({
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
          color: isPrimary ? _kRed : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isPrimary ? _kRed : _kDivider,
            width: 0.8,
          ),
          boxShadow: isPrimary
              ? [
            BoxShadow(
              color: _kRed.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            )
          ]
              : [],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                color: isPrimary ? Colors.white : _kTextSecondary, size: 16),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isPrimary ? Colors.white : _kTextSecondary,
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

// ─── Assessment Banner ────────────────────────────────────────────────────────

class _AssessmentBanner extends StatefulWidget {
  final int lessonId;
  final LessonProgress progress;
  const _AssessmentBanner({required this.lessonId, required this.progress});

  @override
  State<_AssessmentBanner> createState() => _AssessmentBannerState();
}

class _AssessmentBannerState extends State<_AssessmentBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
    _pulseAnim =
        CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isUnlocked = widget.progress.watchProgress >= 95;

    return AnimatedBuilder(
      animation: _pulseAnim,
      builder: (_, __) => GestureDetector(
        onTap: () {
          if (isUnlocked) {
            context.push('/lessons/${widget.lessonId}/assessment');
            return;
          }
          _showLockedSnackBar(
            context,
            fallbackMessage:
                'You need to complete this lesson before accessing the assessment.',
          );
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isUnlocked ? const Color(0xFF1A0A0A) : _kSurfaceElevated,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isUnlocked
                  ? _kRed.withOpacity(0.25 + _pulseAnim.value * 0.2)
                  : _kDivider,
              width: 0.8,
            ),
            boxShadow: isUnlocked
                ? [
              BoxShadow(
                color: _kRed
                    .withOpacity(0.05 + _pulseAnim.value * 0.07),
                blurRadius: 16,
                offset: const Offset(0, 4),
              )
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
                      ? _kRed.withOpacity(0.12)
                      : _kSurfaceHigh,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  isUnlocked ? Icons.quiz_rounded : Icons.lock_rounded,
                  color: isUnlocked ? _kRed : _kTextMuted,
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
                        color: isUnlocked ? _kTextPrimary : _kTextMuted,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      isUnlocked
                          ? 'Start the assessment now'
                          : 'Watch at least 95% of the video to unlock it.',
                      style: const TextStyle(
                        color: _kTextMuted,
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
                  color: _kRed.withOpacity(0.7),
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Navigation Section ───────────────────────────────────────────────────────

class _NavigationSection extends StatelessWidget {
  final List<LessonNavItem> navigation;
  final int currentLessonId;
  final void Function(int lessonId) onNavigate;

  const _NavigationSection({
    required this.navigation,
    required this.currentLessonId,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionLabel(text: 'All Lessons'),
        const SizedBox(height: 12),
        ...navigation.map(
              (item) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _NavLessonRow(
              item: item,
              isCurrent: item.id == currentLessonId,
              onNavigate: onNavigate,
            ),
          ),
        ),
      ],
    );
  }
}

class _NavLessonRow extends StatelessWidget {
  final LessonNavItem item;
  final bool isCurrent;
  final void Function(int lessonId) onNavigate;

  const _NavLessonRow({
    required this.item,
    required this.isCurrent,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (isCurrent) {
          return;
        }
        if (item.isLocked) {
          _showLockedSnackBar(
            context,
            fallbackMessage: 'You need to complete the previous lesson first.',
            reason: item.lockReason,
          );
          return;
        }
        onNavigate(item.id);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isCurrent ? const Color(0xFF1A0A0A) : _kSurfaceElevated,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isCurrent ? _kRed.withOpacity(0.3) : _kDivider,
            width: 0.8,
          ),
        ),
        child: Row(
          children: [
            // Status icon / number
            SizedBox(
              width: 24,
              child: item.isLocked
                  ? const Icon(Icons.lock_rounded,
                  color: _kTextMuted, size: 13)
                  : item.status == 'completed'
                  ? const Icon(Icons.check_circle_rounded,
                  color: _kGreen, size: 15)
                  : Text(
                '${item.sortOrder}',
                style: TextStyle(
                  color: isCurrent ? _kRed : _kTextMuted,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Montserrat',
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                item.title,
                style: TextStyle(
                  color: item.isLocked
                      ? _kTextMuted
                      : isCurrent
                      ? _kTextPrimary
                      : _kTextSecondary,
                  fontSize: 13,
                  fontWeight:
                  isCurrent ? FontWeight.w700 : FontWeight.w400,
                  fontFamily: 'Montserrat',
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // Progress %
            if (!item.isLocked && item.progressPercentage > 0 && !isCurrent)
              Text(
                '${item.progressPercentage}%',
                style: const TextStyle(
                  color: _kTextMuted,
                  fontSize: 10,
                  fontFamily: 'Montserrat',
                ),
              ),
            // NOW badge
            if (isCurrent) ...[
              const SizedBox(width: 8),
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: _kRed,
                  borderRadius: BorderRadius.circular(3),
                ),
                child: const Text(
                  'NOW',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 8,
                    fontWeight: FontWeight.w800,
                    fontFamily: 'Montserrat',
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Next Lesson Banner ───────────────────────────────────────────────────────

class _NextLessonBanner extends StatefulWidget {
  final NextLesson nextLesson;
  final int? countdownSeconds;
  final void Function(int lessonId) onNavigate;

  const _NextLessonBanner({
    required this.nextLesson,
    required this.countdownSeconds,
    required this.onNavigate,
  });

  @override
  State<_NextLessonBanner> createState() => _NextLessonBannerState();
}

class _NextLessonBannerState extends State<_NextLessonBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 160),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isUnlocked = widget.nextLesson.isUnlocked;
    final countdownSeconds = widget.countdownSeconds;

    return GestureDetector(
      onTap: () {
        if (isUnlocked) {
          widget.onNavigate(widget.nextLesson.id);
          return;
        }
        _showLockedSnackBar(
          context,
          fallbackMessage: 'You need to complete the previous lesson first.',
          reason: widget.nextLesson.lockReason,
        );
      },
      onTapDown: isUnlocked ? (_) => _ctrl.forward() : null,
      onTapUp: isUnlocked ? (_) => _ctrl.reverse() : null,
      onTapCancel: isUnlocked ? () => _ctrl.reverse() : null,
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          decoration: BoxDecoration(
            color: _kSurfaceElevated,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: _kDivider, width: 0.8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          clipBehavior: Clip.hardEdge,
          child: Row(
            children: [
              // Thumbnail
              SizedBox(
                width: 100,
                height: 70,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (widget.nextLesson.thumbnailUrl != null)
                      AuthNetworkImage(
                        imageUrl: widget.nextLesson.thumbnailUrl!,
                        fit: BoxFit.cover,
                        placeholderBuilder: (_) =>
                            Container(color: _kSurfaceHigh),
                        errorBuilderWidget: (_, __) =>
                            Container(color: _kSurfaceHigh),
                      )
                    else
                      Container(color: _kSurfaceHigh),
                    if (!isUnlocked)
                      Container(
                        color: Colors.black.withOpacity(0.55),
                        child: const Icon(Icons.lock_rounded,
                            color: _kTextMuted, size: 18),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'NEXT LESSON',
                      style: TextStyle(
                        color: _kTextMuted,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Montserrat',
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      widget.nextLesson.title,
                      style: TextStyle(
                        color: isUnlocked ? _kTextPrimary : _kTextMuted,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Montserrat',
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (isUnlocked && countdownSeconds != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        'Auto next in ${countdownSeconds}s',
                        style: const TextStyle(
                          color: _kRed,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Montserrat',
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 14),
                child: Icon(
                  isUnlocked
                      ? Icons.play_arrow_rounded
                      : Icons.lock_rounded,
                  color: isUnlocked ? _kRed : _kTextMuted,
                  size: 22,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Shared Widgets ───────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 12,
          decoration: BoxDecoration(
            color: _kRed,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          text.toUpperCase(),
          style: const TextStyle(
            color: _kTextMuted,
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

// ─── Skeleton ─────────────────────────────────────────────────────────────────

class _LessonSkeleton extends StatefulWidget {
  const _LessonSkeleton();

  @override
  State<_LessonSkeleton> createState() => _LessonSkeletonState();
}

class _LessonSkeletonState extends State<_LessonSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) {
        final shimmer = Color.lerp(_kSurface, _kSurfaceHigh, _anim.value)!;
        return Column(
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Container(color: Colors.black),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Bone(width: 100, height: 10, color: shimmer),
                  const SizedBox(height: 12),
                  _Bone(width: 260, height: 26, color: shimmer),
                  const SizedBox(height: 18),
                  _Bone(
                      width: double.infinity, height: 2.5, color: shimmer),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      _Bone(width: 90, height: 36, color: shimmer),
                      const SizedBox(width: 8),
                      _Bone(width: 70, height: 36, color: shimmer),
                    ],
                  ),
                  const SizedBox(height: 28),
                  _Bone(
                      width: double.infinity, height: 80, color: shimmer),
                  const SizedBox(height: 14),
                  _Bone(
                      width: double.infinity, height: 80, color: shimmer),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _Bone extends StatelessWidget {
  final double width;
  final double height;
  final Color color;
  const _Bone(
      {required this.width, required this.height, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
      ),
    );
  }
}

// ─── Error ────────────────────────────────────────────────────────────────────

class _LessonError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  final VoidCallback onBack;
  const _LessonError(
      {required this.message, required this.onRetry, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: _kRed.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(color: _kRed.withOpacity(0.25)),
              ),
              child: const Icon(Icons.wifi_off_rounded,
                  color: _kRed, size: 28),
            ),
            const SizedBox(height: 20),
            Text(
              message,
              style: const TextStyle(
                color: _kTextSecondary,
                fontSize: 13,
                fontFamily: 'Montserrat',
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: onBack,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: _kDivider, width: 0.8),
                    ),
                    child: const Text(
                      'Back',
                      style: TextStyle(
                        color: _kTextSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: onRetry,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: _kRed,
                      borderRadius: BorderRadius.circular(4),
                      boxShadow: [
                        BoxShadow(
                          color: _kRed.withOpacity(0.35),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Text(
                      'Try again',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
