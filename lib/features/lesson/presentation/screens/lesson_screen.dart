import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/storage/secure_storage.dart';
import '../../../../core/widgets/auth_network_image.dart';
import '../../../dashboard/presentation/providers/dashboard_provider.dart';
import '../../../module/data/models/module_model.dart';
import '../../../module/presentation/providers/module_provider.dart';
import '../../data/models/lesson_model.dart';
import '../providers/lesson_provider.dart';
import '../../../../features/lesson/data/repositories/lesson_repository.dart';

class _AutoNextTarget {
  final int lessonId;
  final String title;
  final int sortOrder;
  final String? thumbnailUrl;
  final bool isFromNextModule;

  const _AutoNextTarget({
    required this.lessonId,
    required this.title,
    required this.sortOrder,
    required this.thumbnailUrl,
    required this.isFromNextModule,
  });

  factory _AutoNextTarget.fromNextLesson(NextLesson lesson) {
    return _AutoNextTarget(
      lessonId: lesson.id,
      title: lesson.title,
      sortOrder: lesson.sortOrder,
      thumbnailUrl: lesson.thumbnailUrl,
      isFromNextModule: false,
    );
  }
}

// ─── Root Screen ──────────────────────────────────────────────────────────────

class LessonScreen extends ConsumerStatefulWidget {
  final int lessonId;
  final bool autoPlayVideo;
  final bool startInFullscreen;

  const LessonScreen({
    super.key,
    required this.lessonId,
    this.autoPlayVideo = false,
    this.startInFullscreen = false,
  });

  @override
  ConsumerState<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends ConsumerState<LessonScreen> {
  final GlobalKey<_LessonContentState> _lessonContentKey =
      GlobalKey<_LessonContentState>();

  @override
  Widget build(BuildContext context) {
    final lessonAsync = ref.watch(lessonDetailProvider(widget.lessonId));

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
        backgroundColor: AppColors.background,
        body: lessonAsync.when(
          loading: () => const _LessonSkeleton(),
          error: (e, _) => _LessonError(
            message: e.toString(),
            onRetry: () => ref.invalidate(lessonDetailProvider(widget.lessonId)),
            onBack: () => _handleLessonBack(context),
          ),
          data: (lesson) => _LessonContent(
            key: _lessonContentKey,
            lesson: lesson,
            autoPlayVideo: widget.autoPlayVideo,
            startInFullscreen: widget.startInFullscreen,
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
  const lockedMessage =
      'This page is not available yet. Please complete the previous module first.';

  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(lockedMessage),
      ),
    );
}

// ─── Content ──────────────────────────────────────────────────────────────────

class _LessonContent extends ConsumerStatefulWidget {
  final LessonDetail lesson;
  final bool autoPlayVideo;
  final bool startInFullscreen;

  const _LessonContent({
    super.key,
    required this.lesson,
    required this.autoPlayVideo,
    required this.startInFullscreen,
  });

  @override
  ConsumerState<_LessonContent> createState() => _LessonContentState();
}

class _LessonContentState extends ConsumerState<_LessonContent>
    with TickerProviderStateMixin {
  VideoPlayerController? _videoController;
  AudioPlayer? _audioPlayer;
  bool _videoInitialized = false;
  bool _videoError = false;
  String? _videoErrorMessage;
  bool _audioLoading = false;
  bool _audioReady = false;
  String? _audioError;
  int _lastReportedProgress = 0;
  int? _autoNextRemainingSeconds;
  bool _isAutoNavigating = false;
  bool _showNextLessonPrompt = false;
  bool _autoNextCancelled = false;
  bool _hasOpenedInitialFullscreen = false;
  bool _isDisposingVideoController = false;
  _AutoNextTarget? _autoNextTarget;

  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;
  late AnimationController _progressCtrl;
  late Animation<double> _progressAnim;

  bool get _hasPlayableVideo {
    final video = widget.lesson.video;
    return video != null && video.isReady;
  }

  bool get _requiresWorkbookFirst =>
      widget.lesson.workbook.isAvailable &&
          !widget.lesson.progress.isWorkbookDownloaded;

  bool get _isVideoUnlocked => !_requiresWorkbookFirst;

  bool get _isAssessmentUnlocked {
    if (_requiresWorkbookFirst) return false;
    final hasPlayableVideo = widget.lesson.video != null && widget.lesson.video!.isReady;
    if (!hasPlayableVideo) return true;
    return widget.lesson.progress.watchProgress >= 95;
  }

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

    if (_hasPlayableVideo && _isVideoUnlocked) {
      _initVideo();
    }
    if (widget.lesson.audio.isAvailable && widget.lesson.audio.url != null) {
      _initAudio();
    }
    _primeAutoNextTarget();
  }

  Future<void> _primeAutoNextTarget() async {
    if (widget.lesson.nextLesson != null) {
      if (!mounted) return;
      setState(() {
        _autoNextTarget = _AutoNextTarget.fromNextLesson(widget.lesson.nextLesson!);
      });
      return;
    }

    final fallbackTarget = await _resolveNextModuleLessonTarget();
    if (!mounted || fallbackTarget == null) return;
    setState(() => _autoNextTarget = fallbackTarget);
  }

  Future<_AutoNextTarget?> _resolveNextModuleLessonTarget() async {
    try {
      final moduleList = await ref.read(moduleListProvider.future);
      final sortedModules = [...moduleList.items]
        ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
      final currentIndex = sortedModules.indexWhere(
        (module) => module.id == widget.lesson.module.id,
      );
      if (currentIndex == -1) return null;

      for (var i = currentIndex + 1; i < sortedModules.length; i++) {
        final module = sortedModules[i];
        if (!_canAutoOpenModule(module)) continue;

        final detail = await ref.read(moduleDetailProvider(module.id).future);
        final unlockedLessons = detail.lessons.where((lesson) => !lesson.isLocked);
        final firstLesson =
            unlockedLessons.isEmpty ? null : unlockedLessons.first;
        if (firstLesson == null) continue;

        return _AutoNextTarget(
          lessonId: firstLesson.id,
          title: firstLesson.title,
          sortOrder: firstLesson.sortOrder,
          thumbnailUrl: firstLesson.thumbnailUrl,
          isFromNextModule: true,
        );
      }
    } catch (_) {
      return null;
    }

    return null;
  }

  bool _canAutoOpenModule(ModuleItem module) {
    final status = module.status.toLowerCase();
    if (!module.isVisible) return false;
    if (status == 'locked' || status == 'hidden' || status == 'unavailable') {
      return false;
    }
    return module.viewTypes.contains('lesson');
  }

  Future<void> _initVideo() async {
    if (!_isVideoUnlocked) return;
    final video = widget.lesson.video!;
    try {
      final canReachVideoHost = await _canResolveMediaHost(video.hlsUrl);
      if (!canReachVideoHost) {
        if (mounted) {
          setState(() {
            _videoError = true;
            _videoErrorMessage = 'No internet connection. Video could not be loaded.';
          });
        }
        return;
      }

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
      if (mounted) {
        setState(() {
          _videoInitialized = true;
          _videoError = false;
          _videoErrorMessage = null;
        });
      }

      if (widget.autoPlayVideo && mounted) {
        await _videoController!.play();
      }

      if (widget.startInFullscreen &&
          !_hasOpenedInitialFullscreen &&
          mounted) {
        _hasOpenedInitialFullscreen = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          unawaited(_openFullscreen());
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _videoError = true;
          _videoErrorMessage = 'Failed to load video.';
        });
      }
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
    if (widget.lesson.assessment != null) {
      _handleAssessmentAutoStart(value);
      return;
    }

    final nextLesson = _autoNextTarget;
    final shouldAutoNavigate =
        nextLesson != null &&
            widget.lesson.assessment == null;

    if (!shouldAutoNavigate) {
      _resetAutoNextState();
      return;
    }

    final remaining = value.duration - value.position;
    final rawRemainingMillis = remaining.inMilliseconds;
    final isNearEnd = rawRemainingMillis <= 10000;
    final remainingMillis = rawRemainingMillis.clamp(0, 10000);
    final remainingSeconds = (remainingMillis / 1000).ceil().clamp(0, 10);

    if (remainingSeconds <= 0) {
      if (_isAutoNavigating || _autoNextCancelled) return;
      _isAutoNavigating = true;
      unawaited(
        _navigateToLesson(context, nextLesson.lessonId, autoPlayVideo: true),
      );
      return;
    }

    if (!isNearEnd) {
      _resetAutoNextState();
      return;
    }

    if (_autoNextCancelled || !value.isPlaying) return;

    if (!mounted) return;
    if (_showNextLessonPrompt &&
        _autoNextRemainingSeconds == remainingSeconds) {
      return;
    }

    setState(() {
      _showNextLessonPrompt = true;
      _autoNextRemainingSeconds = remainingSeconds;
    });
  }

  void _handleAssessmentAutoStart(VideoPlayerValue value) {
    final remaining = value.duration - value.position;
    final remainingMillis = remaining.inMilliseconds;
    final remainingSeconds = (remainingMillis.clamp(0, 10000) / 1000)
        .ceil()
        .clamp(0, 10);

    if (remainingSeconds > 0 || !_isAssessmentUnlocked || _autoNextCancelled) {
      _resetAutoNextState();
      return;
    }

    if (_isAutoNavigating) return;
    _isAutoNavigating = true;
    unawaited(_navigateToAssessmentIntro(context));
  }

  Future<void> _navigateToAssessmentIntro(BuildContext context) async {
    await prepareForNavigation(context);
    if (!mounted) return;
    context.go('/lessons/${widget.lesson.id}/assessment');
  }

  void _cancelAutoNextCountdown({bool keepPromptVisible = true}) {
    if (!mounted) return;
    setState(() {
      _autoNextCancelled = true;
      _autoNextRemainingSeconds = null;
      _showNextLessonPrompt = keepPromptVisible;
    });
  }

  void _resetAutoNextState() {
    if (!mounted) return;
    if (!_showNextLessonPrompt &&
        _autoNextRemainingSeconds == null &&
        !_autoNextCancelled) {
      return;
    }
    setState(() {
      _showNextLessonPrompt = false;
      _autoNextRemainingSeconds = null;
      _autoNextCancelled = false;
    });
  }

  void _refreshLearningState() {
    ref.invalidate(lessonDetailProvider(widget.lesson.id));
    ref.invalidate(moduleDetailProvider(widget.lesson.module.id));
    ref.invalidate(moduleListProvider);
    ref.invalidate(dashboardProvider);
  }

  @override
  void didUpdateWidget(covariant _LessonContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_hasPlayableVideo &&
        _isVideoUnlocked &&
        _videoController == null &&
        !_videoInitialized) {
      _initVideo();
    }
  }

  Future<void> _initAudio() async {
    final url = widget.lesson.audio.url;
    if (url == null || url.isEmpty) return;

    setState(() {
      _audioLoading = true;
      _audioError = null;
    });

    try {
      final canReachAudioHost = await _canResolveMediaHost(url);
      if (!canReachAudioHost) {
        if (mounted) {
          setState(() => _audioError =
          'No internet connection. Audio could not be loaded.');
        }
        return;
      }

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
        _audioError = null;
      });
    } catch (e) {
      if (mounted) setState(() => _audioError = 'Audio failed to load');
    } finally {
      if (mounted) setState(() => _audioLoading = false);
    }
  }

  Future<bool> _canResolveMediaHost(String url) async {
    final uri = Uri.tryParse(url);
    final host = uri?.host;
    if (host == null || host.isEmpty) return false;

    try {
      final result = await InternetAddress.lookup(host);
      return result.isNotEmpty && result.first.rawAddress.isNotEmpty;
    } on SocketException {
      return false;
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

    await _audioPlayer?.dispose();
    _audioPlayer = null;

    await _detachAndDisposeVideoController();
  }

  Future<void> _handleBack(BuildContext context) async {
    await prepareForNavigation(context);
    if (!mounted) return;
    _handleLessonBack(context);
  }

  Future<void> _navigateToLesson(
      BuildContext context,
      int lessonId, {
        bool autoPlayVideo = false,
        bool startInFullscreen = false,
      }) async {
    await prepareForNavigation(context);
    if (!mounted) return;
    final queryParameters = <String, String>{
      if (autoPlayVideo) 'autoplay': '1',
      if (startInFullscreen) 'fullscreen': '1',
    };
    final uri = Uri(
      path: '/lessons/$lessonId',
      queryParameters: queryParameters.isEmpty ? null : queryParameters,
    );
    context.go(uri.toString());
  }

  Future<void> _refreshLesson() async {
    ref.invalidate(lessonDetailProvider(widget.lesson.id));
    await ref.read(lessonDetailProvider(widget.lesson.id).future);
  }

  @override
  void dispose() {
    final controller = _videoController;
    if (controller != null) {
      controller.removeListener(_onVideoProgress);
    }
    _videoController = null;
    _audioPlayer?.dispose();
    _audioPlayer = null;
    _fadeCtrl.dispose();
    _progressCtrl.dispose();
    controller?.dispose();
    super.dispose();
  }

  Future<void> _detachAndDisposeVideoController() async {
    if (_isDisposingVideoController) return;

    final controller = _videoController;
    if (controller == null) {
      if (mounted && _videoInitialized) {
        setState(() => _videoInitialized = false);
      } else {
        _videoInitialized = false;
      }
      return;
    }

    _isDisposingVideoController = true;
    controller.removeListener(_onVideoProgress);

    if (mounted) {
      setState(() {
        _videoController = null;
        _videoInitialized = false;
        _showNextLessonPrompt = false;
        _autoNextRemainingSeconds = null;
      });
      await Future<void>.delayed(Duration.zero);
    } else {
      _videoController = null;
      _videoInitialized = false;
      _showNextLessonPrompt = false;
      _autoNextRemainingSeconds = null;
    }

    await controller.dispose();
    _isDisposingVideoController = false;
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

  Future<void> _skipVideoBy(int seconds) async {
    final controller = _videoController;
    if (controller == null || !controller.value.isInitialized) return;
    await _seekVideo(controller.value.position + Duration(seconds: seconds));
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

    final shouldPlayNextLesson = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => _FullscreenVideoScreen(
          controller: controller,
          nextLesson: _autoNextTarget,
          enableAutoNextOverlay: widget.lesson.assessment == null,
          showNextLessonPrompt: _showNextLessonPrompt,
          autoNextRemainingSeconds: _autoNextRemainingSeconds,
          autoNextCancelled: _autoNextCancelled,
          onTogglePlayback: _toggleVideoPlayback,
          onSeek: _seekVideo,
          onToggleMute: _toggleMute,
          onSkipForward: () => _skipVideoBy(30),
          onSkipBackward: () => _skipVideoBy(-30),
          onCancelAutoNext: () => _cancelAutoNextCountdown(),
        ),
      ),
    );

    if (shouldPlayNextLesson == true && mounted) {
      final nextLesson = _autoNextTarget;
      if (nextLesson != null) {
        _isAutoNavigating = true;
        await _navigateToLesson(
          context,
          nextLesson.lessonId,
          autoPlayVideo: true,
          startInFullscreen: true,
        );
      }
    }

    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final lesson = widget.lesson;

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: _refreshLesson,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        slivers: [
          // Video
          SliverToBoxAdapter(
            child: _VideoSection(
              lesson: lesson,
              videoInitialized: _videoInitialized,
              videoError: _videoError,
              videoErrorMessage: _videoErrorMessage,
              videoController: _videoController,
              videoUnlocked: _isVideoUnlocked,
              onWorkbookDismissed: _refreshLesson,
              onRetry: _initVideo,
              onBack: () => _handleBack(context),
              onTogglePlayback: _toggleVideoPlayback,
              onSeek: _seekVideo,
              onToggleMute: _toggleMute,
              onSkipForward: () => _skipVideoBy(30),
              onSkipBackward: () => _skipVideoBy(-30),
              showNextLessonPrompt: _showNextLessonPrompt,
              autoNextRemainingSeconds: _autoNextRemainingSeconds,
              autoNextCancelled: _autoNextCancelled,
              onPlayNextLesson: () async {
                final nextLesson = _autoNextTarget;
                if (nextLesson == null) return;
                _isAutoNavigating = true;
                await _navigateToLesson(
                  context,
                  nextLesson.lessonId,
                  autoPlayVideo: true,
                );
              },
              onCancelAutoNext: () => _cancelAutoNextCountdown(),
              onOpenFullscreen: _openFullscreen,
              nextLesson: _autoNextTarget,
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
                    _ModuleBreadcrumb(module: lesson.module),
                    const SizedBox(height: 10),
                    Text(
                      lesson.title,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        fontFamily: 'Montserrat',
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _LessonProgressBar(
                      progress: lesson.progress,
                      animation: _progressAnim,
                    ),
                    const SizedBox(height: 20),
                    _ActionRow(
                      lesson: lesson,
                      isAssessmentUnlocked: _isAssessmentUnlocked,
                      onWorkbookDismissed: _refreshLesson,
                      audioLoading: _audioLoading,
                      audioReady: _audioReady,
                      audioError: _audioError,
                      audioPlayer: _audioPlayer,
                      onRetryAudio: _initAudio,
                    ),
                    const SizedBox(height: 28),
                    if (lesson.content != null && lesson.content!.isNotEmpty) ...[
                      _ContentSection(content: lesson.content!),
                      const SizedBox(height: 28),
                    ],
                    if (lesson.workbook.isAvailable) ...[
                      _WorkbookSection(
                        workbook: lesson.workbook,
                        onDismissed: _refreshLesson,
                      ),
                      const SizedBox(height: 28),
                    ],
                    if (lesson.assessment != null) ...[
                      _AssessmentBanner(
                        lesson: lesson,
                        isUnlocked: _isAssessmentUnlocked,
                      ),
                      const SizedBox(height: 28),
                    ],
                    if (lesson.navigation.isNotEmpty) ...[
                      _NavigationSection(
                        navigation: lesson.navigation,
                        currentLessonId: lesson.id,
                        onNavigate: (lessonId) =>
                            _navigateToLesson(context, lessonId),
                      ),
                      const SizedBox(height: 28),
                    ],
                    if (_autoNextTarget != null)
                      _NextLessonBanner(
                        nextLesson: _autoNextTarget!,
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
      ),
    );
  }
}

// ─── Video Section ────────────────────────────────────────────────────────────

class _VideoSection extends StatelessWidget {
  final LessonDetail lesson;
  final _AutoNextTarget? nextLesson;
  final bool videoInitialized;
  final bool videoError;
  final String? videoErrorMessage;
  final VideoPlayerController? videoController;
  final bool videoUnlocked;
  final Future<void> Function() onWorkbookDismissed;
  final VoidCallback onRetry;
  final VoidCallback onBack;
  final Future<void> Function() onTogglePlayback;
  final Future<void> Function(Duration position) onSeek;
  final Future<void> Function() onToggleMute;
  final Future<void> Function() onSkipForward;
  final Future<void> Function() onSkipBackward;
  final bool showNextLessonPrompt;
  final int? autoNextRemainingSeconds;
  final bool autoNextCancelled;
  final Future<void> Function() onPlayNextLesson;
  final VoidCallback onCancelAutoNext;
  final Future<void> Function() onOpenFullscreen;

  const _VideoSection({
    required this.lesson,
    required this.nextLesson,
    required this.videoInitialized,
    required this.videoError,
    required this.videoErrorMessage,
    required this.videoController,
    required this.videoUnlocked,
    required this.onWorkbookDismissed,
    required this.onRetry,
    required this.onBack,
    required this.onTogglePlayback,
    required this.onSeek,
    required this.onToggleMute,
    required this.onSkipForward,
    required this.onSkipBackward,
    required this.showNextLessonPrompt,
    required this.autoNextRemainingSeconds,
    required this.autoNextCancelled,
    required this.onPlayNextLesson,
    required this.onCancelAutoNext,
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
            child: _buildVideoBody(context),
          ),
        ),
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
                borderRadius: BorderRadius.circular(AppRadius.modal),
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

  Widget _buildVideoBody(BuildContext context) {
    if (!videoUnlocked) {
      return _VideoPlaceholder(
        thumbnailUrl: lesson.thumbnailUrl,
        message: 'Open or download the workbook first to unlock the video.',
        onTap: lesson.workbook.isAvailable
            ? () => _showWorkbookOptions(
                  context: context,
                  workbook: lesson.workbook,
                  onDismissed: onWorkbookDismissed,
                )
            : null,
      );
    }
    if (lesson.video == null || !lesson.video!.isReady) {
      return _VideoPlaceholder(
        thumbnailUrl: lesson.thumbnailUrl,
        message: 'Video is not available.',
      );
    }
    if (videoError) {
      return _VideoPlaceholder(
        thumbnailUrl: lesson.thumbnailUrl,
        message: videoErrorMessage ?? 'Failed to load video.',
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
              placeholderBuilder: (_) => Container(color: AppColors.surfaceElevated),
              errorBuilderWidget: (_, __) => Container(color: AppColors.surfaceElevated),
            ),
          Container(color: Colors.black.withOpacity(0.5)),
          const Center(
            child: CircularProgressIndicator(
              color: AppColors.primary,
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
      onSkipForward: onSkipForward,
      onSkipBackward: onSkipBackward,
      nextLesson: nextLesson,
      showNextLessonPrompt: showNextLessonPrompt,
      autoNextRemainingSeconds: autoNextRemainingSeconds,
      autoNextCancelled: autoNextCancelled,
      onPlayNextLesson: onPlayNextLesson,
      onCancelAutoNext: onCancelAutoNext,
      onOpenFullscreen: onOpenFullscreen,
    );
  }
}

class _InlineVideoPlayer extends StatefulWidget {
  final VideoPlayerController controller;
  final _AutoNextTarget? nextLesson;
  final Future<void> Function() onTogglePlayback;
  final Future<void> Function(Duration position) onSeek;
  final Future<void> Function() onToggleMute;
  final Future<void> Function() onSkipForward;
  final Future<void> Function() onSkipBackward;
  final bool showNextLessonPrompt;
  final int? autoNextRemainingSeconds;
  final bool autoNextCancelled;
  final Future<void> Function() onPlayNextLesson;
  final VoidCallback onCancelAutoNext;
  final Future<void> Function() onOpenFullscreen;

  const _InlineVideoPlayer({
    required this.controller,
    required this.nextLesson,
    required this.onTogglePlayback,
    required this.onSeek,
    required this.onToggleMute,
    required this.onSkipForward,
    required this.onSkipBackward,
    required this.showNextLessonPrompt,
    required this.autoNextRemainingSeconds,
    required this.autoNextCancelled,
    required this.onPlayNextLesson,
    required this.onCancelAutoNext,
    required this.onOpenFullscreen,
  });

  @override
  State<_InlineVideoPlayer> createState() => _InlineVideoPlayerState();
}

class _InlineVideoPlayerState extends State<_InlineVideoPlayer> {
  static const _controlsAutoHideDelay = Duration(seconds: 3);

  Timer? _controlsTimer;
  bool _controlsVisible = true;
  late bool _wasPlaying;

  @override
  void initState() {
    super.initState();
    _wasPlaying = _controllerValueOrNull()?.isPlaying ?? false;
    widget.controller.addListener(_handleControllerUpdate);
    _syncWakelock();
    _scheduleControlsHide();
  }

  @override
  void didUpdateWidget(covariant _InlineVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_handleControllerUpdate);
      widget.controller.addListener(_handleControllerUpdate);
      _wasPlaying = _controllerValueOrNull()?.isPlaying ?? false;
    }
    _syncWakelock();
  }

  @override
  void dispose() {
    _controlsTimer?.cancel();
    widget.controller.removeListener(_handleControllerUpdate);
    WakelockPlus.disable();
    super.dispose();
  }

  void _handleControllerUpdate() {
    _syncWakelock();
    if (!mounted) return;

    final value = _controllerValueOrNull();
    if (value == null) return;

    final isPlaying = value.isPlaying;
    if (_wasPlaying == isPlaying) {
      return;
    }
    _wasPlaying = isPlaying;

    if (!isPlaying && !_controlsVisible) {
      _controlsTimer?.cancel();
      setState(() => _controlsVisible = true);
      return;
    }

    if (isPlaying && _controlsVisible) {
      _scheduleControlsHide();
    }
  }

  Future<void> _syncWakelock() async {
    final value = _controllerValueOrNull();
    if (value == null) return;

    if (value.isPlaying) {
      await WakelockPlus.enable();
    } else {
      await WakelockPlus.disable();
    }
  }

  void _scheduleControlsHide() {
    _controlsTimer?.cancel();
    final value = _controllerValueOrNull();
    if (value == null || !value.isPlaying) return;

    _controlsTimer = Timer(_controlsAutoHideDelay, () {
      final latestValue = _controllerValueOrNull();
      if (!mounted || latestValue == null || !latestValue.isPlaying) return;
      setState(() => _controlsVisible = false);
    });
  }

  void _showControls() {
    if (!_controlsVisible) {
      setState(() => _controlsVisible = true);
    }
    _scheduleControlsHide();
  }

  void _handleSurfaceTap() {
    _showControls();
  }

  Future<void> _runControlAction(Future<void> Function() action) async {
    _showControls();
    await action();
    final value = _controllerValueOrNull();
    if (mounted && value != null && value.isPlaying) {
      _scheduleControlsHide();
    }
  }

  VideoPlayerValue? _controllerValueOrNull() {
    try {
      return widget.controller.value;
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_controllerValueOrNull() == null) {
      return const SizedBox.expand();
    }

    return ValueListenableBuilder<VideoPlayerValue>(
      valueListenable: widget.controller,
      builder: (context, value, _) {
        final duration = value.duration;
        final position = value.position > duration ? duration : value.position;
        final isMuted = value.volume == 0;

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _handleSurfaceTap,
          child: Stack(
            fit: StackFit.expand,
            children: [
              FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: value.size.width,
                  height: value.size.height,
                  child: VideoPlayer(widget.controller),
                ),
              ),
              IgnorePointer(
                ignoring: !_controlsVisible,
                child: AnimatedOpacity(
                  opacity: _controlsVisible ? 1 : 0,
                  duration: const Duration(milliseconds: 220),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
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
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _BigVideoActionButton(
                              icon: Icons.replay_30_rounded,
                              onTap: () => _runControlAction(
                                widget.onSkipBackward,
                              ),
                            ),
                            const SizedBox(width: 18),
                            _BigVideoActionButton(
                              icon: value.isPlaying
                                  ? Icons.pause_rounded
                                  : Icons.play_arrow_rounded,
                              size: 64,
                              iconSize: 34,
                              onTap: () => _runControlAction(
                                widget.onTogglePlayback,
                              ),
                            ),
                            const SizedBox(width: 18),
                            _BigVideoActionButton(
                              icon: Icons.forward_30_rounded,
                              onTap: () => _runControlAction(
                                widget.onSkipForward,
                              ),
                            ),
                          ],
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
                          onTogglePlayback: () =>
                              _runControlAction(widget.onTogglePlayback),
                          onSeek: (position) => _runControlAction(
                            () => widget.onSeek(position),
                          ),
                          onToggleMute: () =>
                              _runControlAction(widget.onToggleMute),
                          onOpenFullscreen: () =>
                              _runControlAction(widget.onOpenFullscreen),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (widget.nextLesson != null &&
                  widget.showNextLessonPrompt &&
                  widget.autoNextRemainingSeconds != null)
                Positioned(
                  right: 16,
                  bottom: 88,
                  child: _VideoNextLessonOverlay(
                    nextLesson: widget.nextLesson!,
                    countdownSeconds: widget.autoNextRemainingSeconds,
                    onPlayNow: widget.onPlayNextLesson,
                    onCancel: widget.onCancelAutoNext,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _BigVideoActionButton extends StatelessWidget {
  final IconData icon;
  final Future<void> Function() onTap;
  final double size;
  final double iconSize;

  const _BigVideoActionButton({
    required this.icon,
    required this.onTap,
    this.size = 52,
    this.iconSize = 28,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.45),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withOpacity(0.16)),
        ),
        child: Icon(icon, color: Colors.white, size: iconSize),
      ),
    );
  }
}

class _VideoNextLessonOverlay extends StatelessWidget {
  final _AutoNextTarget nextLesson;
  final int? countdownSeconds;
  final Future<void> Function() onPlayNow;
  final VoidCallback onCancel;

  const _VideoNextLessonOverlay({
    required this.nextLesson,
    required this.countdownSeconds,
    required this.onPlayNow,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final countdownText = 'Next lesson starts in ${countdownSeconds ?? 0}s...';
    final eyebrowText =
        nextLesson.isFromNextModule ? 'NEXT MODULE' : 'NEXT LESSON';

    return ConstrainedBox(
      constraints: const BoxConstraints(
        maxWidth: 220,
      ),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.78),
          borderRadius: BorderRadius.circular(AppRadius.modal),
          border: Border.all(color: Colors.white.withOpacity(0.12), width: 0.8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.28),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(AppRadius.card),
                  ),
                  child: const Icon(
                    Icons.skip_next_rounded,
                    color: AppColors.primary,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        eyebrowText,
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 7,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Montserrat',
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        nextLesson.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Montserrat',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              countdownText,
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 10,
                fontWeight: FontWeight.w600,
                fontFamily: 'Montserrat',
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: onPlayNow,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 7),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(AppRadius.button),
                      ),
                      child: const Text(
                        'Play Now',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Montserrat',
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                GestureDetector(
                  onTap: onCancel,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(AppRadius.button),
                      border: Border.all(color: Colors.white.withOpacity(0.12)),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
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
        borderRadius: BorderRadius.circular(AppRadius.modal),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 2.5,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 5),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 10),
              activeTrackColor: AppColors.primary,
              inactiveTrackColor: Colors.white24,
              thumbColor: AppColors.primary,
              overlayColor: AppColors.primary.withOpacity(0.18),
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
  final _AutoNextTarget? nextLesson;
  final bool enableAutoNextOverlay;
  final bool showNextLessonPrompt;
  final int? autoNextRemainingSeconds;
  final bool autoNextCancelled;
  final Future<void> Function() onTogglePlayback;
  final Future<void> Function(Duration position) onSeek;
  final Future<void> Function() onToggleMute;
  final Future<void> Function() onSkipForward;
  final Future<void> Function() onSkipBackward;
  final VoidCallback onCancelAutoNext;

  const _FullscreenVideoScreen({
    required this.controller,
    required this.nextLesson,
    required this.enableAutoNextOverlay,
    required this.showNextLessonPrompt,
    required this.autoNextRemainingSeconds,
    required this.autoNextCancelled,
    required this.onTogglePlayback,
    required this.onSeek,
    required this.onToggleMute,
    required this.onSkipForward,
    required this.onSkipBackward,
    required this.onCancelAutoNext,
  });

  @override
  State<_FullscreenVideoScreen> createState() => _FullscreenVideoScreenState();
}

class _FullscreenVideoScreenState extends State<_FullscreenVideoScreen> {
  bool _showNextLessonPrompt = false;
  bool _autoNextCancelled = false;
  bool _isAutoNavigating = false;
  bool _isClosing = false;
  int? _autoNextRemainingSeconds;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setPreferredOrientations(const [
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    WakelockPlus.enable();
    widget.controller.addListener(_handleAutoNextOverlay);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_handleAutoNextOverlay);
    WakelockPlus.disable();
    super.dispose();
  }

  Future<void> _restorePortraitMode() async {
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    await SystemChrome.setPreferredOrientations(const [
      DeviceOrientation.portraitUp,
    ]);
  }

  Future<void> _closeFullscreen() async {
    if (_isClosing) return;
    _isClosing = true;

    try {
      await _restorePortraitMode();
      await Future<void>.delayed(const Duration(milliseconds: 100));

      if (mounted) {
        Navigator.of(context).pop();
      }
    } finally {
      _isClosing = false;
    }
  }

  Future<void> _playNextLessonInFullscreen() async {
    if (_isAutoNavigating) return;
    _isAutoNavigating = true;

    if (mounted) {
      Navigator.of(context).pop(true);
    }
  }

  void _handleAutoNextOverlay() {
    if (!widget.enableAutoNextOverlay) {
      _resetAutoNextOverlay();
      return;
    }

    final nextLesson = widget.nextLesson;
    if (nextLesson == null) {
      _resetAutoNextOverlay();
      return;
    }

    final value = _controllerValueOrNull();
    if (value == null) return;
    final remaining = value.duration - value.position;
    final rawRemainingMillis = remaining.inMilliseconds;
    final isNearEnd = rawRemainingMillis <= 10000;
    final remainingMillis = rawRemainingMillis.clamp(0, 10000);
    final remainingSeconds = (remainingMillis / 1000).ceil().clamp(0, 10);

    if (remainingSeconds <= 0) {
      if (_isAutoNavigating || _autoNextCancelled) return;
      unawaited(_playNextLessonInFullscreen());
      return;
    }

    if (!isNearEnd) {
      _resetAutoNextOverlay();
      return;
    }

    if (_autoNextCancelled || !value.isPlaying) return;

    if (!mounted) return;
    if (_showNextLessonPrompt &&
        _autoNextRemainingSeconds == remainingSeconds) {
      return;
    }

    setState(() {
      _showNextLessonPrompt = true;
      _autoNextRemainingSeconds = remainingSeconds;
    });
  }

  void _cancelAutoNextOverlay({bool keepPromptVisible = true}) {
    if (!mounted) return;
    setState(() {
      _autoNextCancelled = true;
      _autoNextRemainingSeconds = null;
      _showNextLessonPrompt = keepPromptVisible;
    });
  }

  void _resetAutoNextOverlay() {
    if (!mounted) return;
    if (!_showNextLessonPrompt &&
        _autoNextRemainingSeconds == null &&
        !_autoNextCancelled) {
      return;
    }
    setState(() {
      _showNextLessonPrompt = false;
      _autoNextRemainingSeconds = null;
      _autoNextCancelled = false;
    });
  }

  VideoPlayerValue? _controllerValueOrNull() {
    try {
      return widget.controller.value;
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final controllerValue = _controllerValueOrNull();
    final aspectRatio = controllerValue == null || controllerValue.aspectRatio == 0
        ? 16 / 9
        : controllerValue.aspectRatio;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        await _closeFullscreen();
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Stack(
            children: [
              Center(
                child: AspectRatio(
                  aspectRatio: aspectRatio,
                  child: _InlineVideoPlayer(
                    controller: widget.controller,
                    nextLesson: widget.nextLesson,
                    showNextLessonPrompt: false,
                    autoNextRemainingSeconds: null,
                    autoNextCancelled: false,
                    onTogglePlayback: widget.onTogglePlayback,
                    onSeek: widget.onSeek,
                    onToggleMute: widget.onToggleMute,
                    onSkipForward: widget.onSkipForward,
                    onSkipBackward: widget.onSkipBackward,
                    onPlayNextLesson: _playNextLessonInFullscreen,
                    onCancelAutoNext: widget.onCancelAutoNext,
                    onOpenFullscreen: _closeFullscreen,
                  ),
                ),
              ),
              if (widget.nextLesson != null &&
                  _showNextLessonPrompt &&
                  _autoNextRemainingSeconds != null)
                Positioned(
                  right: 20,
                  bottom: 92,
                  child: _VideoNextLessonOverlay(
                    nextLesson: widget.nextLesson!,
                    countdownSeconds: _autoNextRemainingSeconds,
                    onPlayNow: _playNextLessonInFullscreen,
                    onCancel: () => _cancelAutoNextOverlay(),
                  ),
                ),
              Positioned(
                top: 12,
                left: 12,
                child: GestureDetector(
                  onTap: _closeFullscreen,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.55),
                      borderRadius: BorderRadius.circular(AppRadius.modal),
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
  final VoidCallback? onTap;
  final VoidCallback? onRetry;

  const _VideoPlaceholder({
    this.thumbnailUrl,
    required this.message,
    this.showRetry = false,
    this.onTap,
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
            placeholderBuilder: (_) => Container(color: AppColors.surfaceElevated),
            errorBuilderWidget: (_, __) => Container(color: AppColors.surfaceElevated),
          ),
        Container(color: Colors.black.withOpacity(0.65)),
        Center(
          child: GestureDetector(
            onTap: onTap,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.play_circle_outline_rounded,
                    color: AppColors.textMuted, size: 48),
                const SizedBox(height: 10),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    fontFamily: 'Montserrat',
                  ),
                ),
                if (onTap != null) ...[
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(AppRadius.button),
                      border: Border.all(
                        color: AppColors.divider,
                        width: 0.8,
                      ),
                    ),
                    child: const Text(
                      'Workbook Options',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                  ),
                ],
                if (showRetry && onRetry != null) ...[
                  const SizedBox(height: 14),
                  GestureDetector(
                    onTap: onRetry,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(AppRadius.button),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.35),
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
          const Icon(Icons.layers_rounded, color: AppColors.textMuted, size: 12),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              module.title,
              style: const TextStyle(
                color: AppColors.textMuted,
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
              color: AppColors.overlayDark,
              borderRadius: BorderRadius.circular(AppRadius.card),
            ),
            child: Text(
              '${module.completedLessons}/${module.lessonCount}',
              style: const TextStyle(
                color: AppColors.textMuted,
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
            borderRadius: BorderRadius.circular(AppRadius.badge),
            child: LinearProgressIndicator(
              value: animation.value,
              backgroundColor: AppColors.divider,
              valueColor: AlwaysStoppedAnimation<Color>(
                isDone ? AppColors.secondary : AppColors.primary,
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
                  color: AppColors.secondary, size: 13),
              const SizedBox(width: 5),
              const Text(
                'Completed',
                style: TextStyle(
                  color: AppColors.secondary,
                  fontSize: 11,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ] else ...[
              Text(
                '${progress.watchProgress}% watched',
                style: const TextStyle(
                  color: AppColors.textMuted,
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
  final bool isAssessmentUnlocked;
  final Future<void> Function() onWorkbookDismissed;
  final bool audioLoading;
  final bool audioReady;
  final String? audioError;
  final AudioPlayer? audioPlayer;
  final Future<void> Function() onRetryAudio;

  const _ActionRow({
    required this.lesson,
    required this.isAssessmentUnlocked,
    required this.onWorkbookDismissed,
    required this.audioLoading,
    required this.audioReady,
    required this.audioError,
    required this.audioPlayer,
    required this.onRetryAudio,
  });

  void _openWorkbook(BuildContext context) {
    _showWorkbookOptions(
      context: context,
      workbook: lesson.workbook,
      onDismissed: onWorkbookDismissed,
    );
  }

  void _openAudio(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
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
            label: isAssessmentUnlocked ? 'Assessment' : 'Assessment Locked',
            onTap: isAssessmentUnlocked
                ? () => context.push('/lessons/${lesson.id}/assessment')
                : null,
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
            color: AppColors.surfaceElevated,
            borderRadius: BorderRadius.circular(AppRadius.avatar),
            border: Border.all(color: AppColors.divider, width: 0.8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.icon,
                color: enabled ? AppColors.textSecondary : AppColors.textMuted,
                size: 14,
              ),
              const SizedBox(width: 7),
              Text(
                widget.label,
                style: TextStyle(
                  color: enabled ? AppColors.textSecondary : AppColors.textMuted,
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
            color: AppColors.textSecondary,
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
  final Future<void> Function() onDismissed;

  const _WorkbookSection({
    required this.workbook,
    required this.onDismissed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionLabel(text: 'Workbook'),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () => _showWorkbookOptions(
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
                        color: AppColors.primary.withOpacity(0.22), width: 0.8),
                  ),
                  child: const Icon(Icons.description_rounded,
                      color: AppColors.primary, size: 18),
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
                const Icon(Icons.chevron_right_rounded,
                    color: AppColors.textMuted, size: 18),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Workbook Sheet ───────────────────────────────────────────────────────────

void _showWorkbookOptions({
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
    builder: (_) => _WorkbookSheet(workbook: workbook),
  ).whenComplete(onDismissed);
}

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
          Center(
            child: Container(
              width: 36,
              height: 3,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(AppRadius.badge),
              ),
            ),
          ),
          const SizedBox(height: 22),
          const Text(
            'Workbook',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w800,
              fontFamily: 'Montserrat',
            ),
          ),
          const SizedBox(height: 4),
          Text(
            workbook.fileName ?? 'Lesson file',
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 12,
              fontFamily: 'Montserrat',
            ),
          ),
          const SizedBox(height: 24),
          if (workbook.downloadUrl != null)
            _SheetButton(
              label: 'Download',
              icon: Icons.download_rounded,
              isPrimary: true,
              onTap: () => _downloadWorkbook(context, workbook.downloadUrl!),
            ),
          if (workbook.url != null) ...[
            if (workbook.downloadUrl != null) const SizedBox(height: 10),
            _SheetButton(
              label: 'Open Workbook',
              icon: Icons.open_in_new_rounded,
              isPrimary: workbook.downloadUrl == null,
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
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(AppRadius.badge),
              ),
            ),
          ),
          const SizedBox(height: 22),
          const Text(
            'Audio',
            style: TextStyle(
              color: AppColors.textPrimary,
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
                  color: AppColors.textMuted, fontSize: 12, fontFamily: 'Montserrat'),
            )
          else if (audioError != null)
            Text(
              audioError!,
              style: const TextStyle(
                  color: AppColors.error,
                  fontSize: 12,
                  fontFamily: 'Montserrat'),
            )
          else
            const Text(
              'Play the audio for this lesson',
              style: TextStyle(
                  color: AppColors.textMuted, fontSize: 12, fontFamily: 'Montserrat'),
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
            )
          ]
              : [],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                color: isPrimary ? Colors.white : AppColors.textSecondary,
                size: 16),
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

// ─── Assessment Banner ────────────────────────────────────────────────────────

class _AssessmentBanner extends StatefulWidget {
  final LessonDetail lesson;
  final bool isUnlocked;
  const _AssessmentBanner({
    required this.lesson,
    required this.isUnlocked,
  });

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
            context.push('/lessons/${widget.lesson.id}/assessment');
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
                color: AppColors.primary.withOpacity(0.05 + _pulseAnim.value * 0.07),
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
                        color: isUnlocked ? AppColors.textPrimary : AppColors.textMuted,
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
        if (isCurrent) return;
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
          color: isCurrent ? const Color(0xFF130A08) : AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(AppRadius.avatar),
          border: Border.all(
            color: isCurrent ? AppColors.primary.withOpacity(0.3) : AppColors.divider,
            width: 0.8,
          ),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 24,
              child: item.isLocked
                  ? const Icon(Icons.lock_rounded, color: AppColors.textMuted, size: 13)
                  : item.status == 'completed'
                  ? const Icon(Icons.check_circle_rounded,
                  color: AppColors.secondary, size: 15)
                  : Text(
                '${item.sortOrder}',
                style: TextStyle(
                  color: isCurrent ? AppColors.primary : AppColors.textMuted,
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
                      ? AppColors.textMuted
                      : isCurrent
                      ? AppColors.textPrimary
                      : AppColors.textSecondary,
                  fontSize: 13,
                  fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w400,
                  fontFamily: 'Montserrat',
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (!item.isLocked && item.progressPercentage > 0 && !isCurrent)
              Text(
                '${item.progressPercentage}%',
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 10,
                  fontFamily: 'Montserrat',
                ),
              ),
            if (isCurrent) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(AppRadius.badge),
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
  final _AutoNextTarget nextLesson;
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
    final countdownSeconds = widget.countdownSeconds;

    return GestureDetector(
      onTap: () {
        widget.onNavigate(widget.nextLesson.lessonId);
      },
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) => _ctrl.reverse(),
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceElevated,
            borderRadius: BorderRadius.circular(AppRadius.modal),
            border: Border.all(color: AppColors.divider, width: 0.8),
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
                            Container(color: AppColors.overlayDark),
                        errorBuilderWidget: (_, __) =>
                            Container(color: AppColors.overlayDark),
                      )
                    else
                      Container(color: AppColors.overlayDark),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'UP NEXT',
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Montserrat',
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      widget.nextLesson.title,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Montserrat',
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (widget.nextLesson.isFromNextModule) ...[
                      const SizedBox(height: 4),
                      const Text(
                        'From the next module',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Montserrat',
                        ),
                      ),
                    ],
                    if (countdownSeconds != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        'Auto next in ${countdownSeconds}s',
                        style: const TextStyle(
                          color: AppColors.primary,
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
                child: const Icon(
                  Icons.play_arrow_rounded,
                  color: AppColors.primary,
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
        final shimmer =
        Color.lerp(AppColors.shimmer, AppColors.shimmerHighlight, _anim.value)!;
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
                  _Bone(width: double.infinity, height: 2.5, color: shimmer),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      _Bone(width: 90, height: 36, color: shimmer),
                      const SizedBox(width: 8),
                      _Bone(width: 70, height: 36, color: shimmer),
                    ],
                  ),
                  const SizedBox(height: 28),
                  _Bone(width: double.infinity, height: 80, color: shimmer),
                  const SizedBox(height: 14),
                  _Bone(width: double.infinity, height: 80, color: shimmer),
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
  const _Bone({required this.width, required this.height, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppRadius.avatar),
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
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primary.withOpacity(0.25)),
              ),
              child: const Icon(Icons.wifi_off_rounded,
                  color: AppColors.primary, size: 28),
            ),
            const SizedBox(height: 20),
            Text(
              message,
              style: const TextStyle(
                color: AppColors.textSecondary,
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
                      borderRadius: BorderRadius.circular(AppRadius.button),
                      border: Border.all(color: AppColors.divider, width: 0.8),
                    ),
                    child: const Text(
                      'Back',
                      style: TextStyle(
                        color: AppColors.textSecondary,
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
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(AppRadius.button),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.35),
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
