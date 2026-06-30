import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:just_audio/just_audio.dart';
import 'package:video_player/video_player.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/storage/secure_storage.dart';
import '../../../../core/widgets/auth_network_image.dart';
import '../../../dashboard/presentation/providers/dashboard_provider.dart';
import '../../../module/data/models/module_model.dart';
import '../../../module/presentation/providers/module_provider.dart';
import '../../data/models/lesson_model.dart';
import '../widgets/assessment/assessment_banner.dart';
import '../widgets/audio/audio_sheet.dart';
import '../providers/lesson_provider.dart';
import '../widgets/shared/lesson_error.dart';
import '../widgets/shared/lesson_skeleton.dart';
import '../widgets/shared/locked_snackbar.dart';
import '../widgets/shared/section_label.dart';
import '../widgets/workbook/workbook_section.dart';
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

enum _FullscreenExitAction {
  playNextLesson,
  startAssessment,
}

// ─── Root Screen ──────────────────────────────────────────────────────────────

class LessonScreen extends ConsumerStatefulWidget {
  final int lessonId;
  final bool autoPlayVideo;
  final bool autoOpenFullscreen;

  const LessonScreen({
    super.key,
    required this.lessonId,
    this.autoPlayVideo = false,
    this.autoOpenFullscreen = false,
  });

  @override
  ConsumerState<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends ConsumerState<LessonScreen> {
  late GlobalKey<_LessonContentState> _lessonContentKey;
  bool _isHandlingBackGesture = false;

  @override
  void initState() {
    super.initState();
    _lessonContentKey = GlobalKey<_LessonContentState>();
  }

  Future<void> _replaceLessonRoute(
    int lessonId, {
    bool autoPlayVideo = false,
    bool autoOpenFullscreen = false,
  }) async {
    if (!mounted) return;
    final params = <String>[];
    if (autoPlayVideo) params.add('autoplay=1');
    if (autoOpenFullscreen) params.add('fullscreen=1');
    final suffix = params.isEmpty ? '' : '?${params.join('&')}';
    context.replace('/lessons/$lessonId$suffix');
  }

  @override
  Widget build(BuildContext context) {
    final lessonAsync = ref.watch(lessonDetailProvider(widget.lessonId));

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop || _isHandlingBackGesture) return;
        _isHandlingBackGesture = true;
        final state = _lessonContentKey.currentState;
        try {
          if (state != null) {
            await state.prepareForNavigation(context);
          }
          if (context.mounted) {
            _handleLessonBack(context);
          }
        } finally {
          _isHandlingBackGesture = false;
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: lessonAsync.when(
          loading: () => const LessonSkeleton(),
          error: (e, _) => LessonError(
            message: e.toString(),
            onRetry: () => ref.invalidate(lessonDetailProvider(widget.lessonId)),
            onBack: () => _handleLessonBack(context),
          ),
          data: (lesson) => _LessonContent(
            key: _lessonContentKey,
            lesson: lesson,
            autoPlayVideo: widget.autoPlayVideo,
            autoOpenFullscreen: widget.autoOpenFullscreen,
            onReplaceLessonRoute: _replaceLessonRoute,
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
  final bool autoOpenFullscreen;
  final Future<void> Function(
    int lessonId, {
    bool autoPlayVideo,
    bool autoOpenFullscreen,
  }) onReplaceLessonRoute;

  const _LessonContent({
    super.key,
    required this.lesson,
    required this.autoPlayVideo,
    required this.autoOpenFullscreen,
    required this.onReplaceLessonRoute,
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
  bool _isFullscreenOpen = false;
  bool _preserveLandscapeOnDispose = false;
  bool _didAutoOpenFullscreen = false;
  bool _isPreparingNavigation = false;
  bool _showNextLessonPrompt = false;
  bool _isAssessmentPromptOpen = false;
  bool _autoNextCancelled = false;
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

  Future<void> _disposeVideoControllerSafely(
    VideoPlayerController? controller,
  ) async {
    if (controller == null) return;

    controller.removeListener(_onVideoProgress);
    try {
      await controller.pause();
    } catch (_) {}

    await WidgetsBinding.instance.endOfFrame;

    try {
      await controller.dispose();
    } catch (_) {}
  }

  Future<void> _initVideo() async {
    if (!_isVideoUnlocked) return;
    final video = widget.lesson.video!;
    final lessonId = widget.lesson.id;
    final previousController = _videoController;
    if (previousController != null) {
      _videoController = null;
      if (mounted) {
        setState(() => _videoInitialized = false);
      }
      unawaited(_disposeVideoControllerSafely(previousController));
    }
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

      final controller = VideoPlayerController.networkUrl(
        Uri.parse(video.hlsUrl),
      );
      _videoController = controller;
      await controller.initialize();

      if (!mounted || widget.lesson.id != lessonId || _videoController != controller) {
        if (_videoController == controller) {
          _videoController = null;
        }
        await _disposeVideoControllerSafely(controller);
        return;
      }

      if (_lastReportedProgress > 0 && _lastReportedProgress < 100) {
        final duration = controller.value.duration;
        final seekTo = duration * (_lastReportedProgress / 100);
        await controller.seekTo(seekTo);
      }

      controller.addListener(_onVideoProgress);
      if (mounted) {
        setState(() {
          _videoInitialized = true;
          _videoError = false;
          _videoErrorMessage = null;
        });
      }

      if (widget.autoPlayVideo && mounted) {
        await controller.play();
      }

      if (widget.autoOpenFullscreen &&
          !_didAutoOpenFullscreen &&
          mounted &&
          _videoController != null &&
          _videoController!.value.isInitialized) {
        _didAutoOpenFullscreen = true;

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;

          final currentController = _videoController;
          if (currentController == null || !currentController.value.isInitialized) {
            return;
          }

          unawaited(_openFullscreen());
        });
      }
    } catch (e) {
      final failedController = _videoController;
      _videoController = null;
      await _disposeVideoControllerSafely(failedController);
      if (mounted) {
        setState(() {
          _videoError = true;
          _videoErrorMessage = 'Failed to load video.';
        });
      }
    }
  }

  void _onVideoProgress() {
    if (_isAutoNavigating) return;
    final controller = _videoController;
    if (controller == null) return;

    final value = controller.value;
    if (!value.isInitialized || value.duration.inSeconds == 0) return;

    final currentProgress =
    ((value.position.inSeconds / value.duration.inSeconds) * 100).round();

    if (currentProgress >= _lastReportedProgress + 5 && currentProgress <= 100) {
      _lastReportedProgress = currentProgress;
      unawaited(
        ref
            .read(lessonRepositoryProvider)
            .updateProgress(widget.lesson.id, currentProgress),
      );
      if (currentProgress >= 100) {
        _refreshLearningState();
      }
    }

    if (_isFullscreenOpen) return;
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
      return;
    }

    if (!mounted || _isAssessmentPromptOpen) return;
    _isAssessmentPromptOpen = true;
    unawaited(_showAssessmentCompletionDialog());
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

  void _cancelAssessmentPrompt() {}

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

  Future<void> _showAssessmentCompletionDialog() async {
    await _videoController?.pause();
    if (!mounted) {
      _isAssessmentPromptOpen = false;
      return;
    }

    final shouldStartAssessment = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          title: const Text(
            'Continue to Assessment?',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
              fontFamily: 'Montserrat',
            ),
          ),
          content: const Text(
            'This lesson is complete. Do you want to continue to the assessment now?',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontFamily: 'Montserrat',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Later'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Continue'),
            ),
          ],
        );
      },
    );

    _isAssessmentPromptOpen = false;
    if (!mounted) return;
    if (shouldStartAssessment == true) {
      await _navigateToAssessmentIntro(context);
      return;
    }

    if (_videoController != null && !_isAutoNavigating) {
      await _videoController!.play();
    }
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
    if (oldWidget.lesson.id != widget.lesson.id) {
      _isAutoNavigating = true;
      _didAutoOpenFullscreen = false;
      _preserveLandscapeOnDispose = false;
      final oldVideoController = _videoController;
      final oldAudioPlayer = _audioPlayer;
      if (oldAudioPlayer != null) {
        unawaited(oldAudioPlayer.pause());
        unawaited(oldAudioPlayer.dispose());
      }
      _videoController = null;
      _audioPlayer = null;
      _lastReportedProgress = widget.lesson.progress.watchProgress;
      _autoNextRemainingSeconds = null;
      _isFullscreenOpen = false;
      _showNextLessonPrompt = false;
      _isAssessmentPromptOpen = false;
      _autoNextCancelled = false;
      _autoNextTarget = null;
      _videoInitialized = false;
      _videoError = false;
      _videoErrorMessage = null;
      _audioLoading = false;
      _audioReady = false;
      _audioError = null;
      _progressCtrl.value = 0;
      _progressAnim = Tween<double>(
        begin: 0,
        end: widget.lesson.progress.watchProgress / 100,
      ).animate(CurvedAnimation(parent: _progressCtrl, curve: Curves.easeOut));
      _progressCtrl.forward(from: 0);
      _isAutoNavigating = false;
      unawaited(_disposeVideoControllerSafely(oldVideoController));
      if (_hasPlayableVideo && _isVideoUnlocked) {
        unawaited(_initVideo());
      }
      if (widget.lesson.audio.isAvailable && widget.lesson.audio.url != null) {
        unawaited(_initAudio());
      }
      _primeAutoNextTarget();
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

  Future<void> _setLandscapeUi() async {
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    await SystemChrome.setPreferredOrientations(const [
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    await WidgetsBinding.instance.endOfFrame;
  }

  Future<void> prepareForNavigation(
    BuildContext context, {
    bool restorePortrait = true,
  }) async {
    if (_isPreparingNavigation) return;
    _isPreparingNavigation = true;
    _isAutoNavigating = true;
    try {
      final videoController = _videoController;
      final audioPlayer = _audioPlayer;
      _refreshLearningState();

      await audioPlayer?.pause();

      _videoController = null;
      if (mounted) {
        setState(() => _videoInitialized = false);
      }

      await audioPlayer?.dispose();
      _audioPlayer = null;

      await _disposeVideoControllerSafely(videoController);

      if (restorePortrait) {
        await _restorePortraitUi();
      }
    } finally {
      _isPreparingNavigation = false;
    }
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
        bool autoOpenFullscreen = false,
        bool restorePortrait = true,
      }) async {
    _preserveLandscapeOnDispose = !restorePortrait;
    await prepareForNavigation(
      context,
      restorePortrait: restorePortrait,
    );
    if (!mounted) return;
    await widget.onReplaceLessonRoute(
      lessonId,
      autoPlayVideo: autoPlayVideo,
      autoOpenFullscreen: autoOpenFullscreen,
    );
  }

  Future<void> _navigateToLessonKeepingFullscreen(
    int lessonId, {
    bool autoPlayVideo = true,
  }) async {
    _preserveLandscapeOnDispose = true;
    _isAutoNavigating = true;

    await _setLandscapeUi();

    if (!mounted) return;

    await _navigateToLesson(
      context,
      lessonId,
      autoPlayVideo: autoPlayVideo,
      autoOpenFullscreen: true,
      restorePortrait: false,
    );
  }

  Future<void> _waitForOverlayToDetach() async {
    await Future<void>.delayed(Duration.zero);
    await WidgetsBinding.instance.endOfFrame;
    await Future<void>.delayed(const Duration(milliseconds: 120));
    await WidgetsBinding.instance.endOfFrame;
  }

  Future<void> _restorePortraitUi() async {
    // Pastikan sudah balik portrait sebelum apapun
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    await SystemChrome.setPreferredOrientations(
      const [DeviceOrientation.portraitUp],
    );

    // Tunggu orientation benar-benar settle — 2 frame tidak cukup di device lambat
    await WidgetsBinding.instance.endOfFrame;
  }

  Future<void> _refreshLesson() async {
    ref.invalidate(lessonDetailProvider(widget.lesson.id));
    await ref.read(lessonDetailProvider(widget.lesson.id).future);
  }

  @override
  void dispose() {
    _isAutoNavigating = true;
    _videoController?.removeListener(_onVideoProgress);
    _videoController?.dispose();
    _videoController = null;
    _audioPlayer?.dispose();
    _audioPlayer = null;
    _fadeCtrl.dispose();
    _progressCtrl.dispose();

    if (!_preserveLandscapeOnDispose) {
      unawaited(SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge));
      unawaited(
        SystemChrome.setPreferredOrientations(
          const [DeviceOrientation.portraitUp],
        ),
      );
    }

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

    // Pause countdown sementara masuk fullscreen
    if (mounted) {
      setState(() {
        _showNextLessonPrompt = false;
        _autoNextRemainingSeconds = null;
      });
    }

    _FullscreenExitAction? result;
    _isFullscreenOpen = true;
    try {
      result = await Navigator.of(context, rootNavigator: true)
          .push<_FullscreenExitAction>(
        PageRouteBuilder<_FullscreenExitAction>(
          opaque: true,
          barrierColor: Colors.black,
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
          pageBuilder: (_, __, ___) => _FullscreenVideoScreen(
          controller: controller,
          nextLesson: _autoNextTarget,
          enableAutoNextOverlay: widget.lesson.assessment == null,
          enableAssessmentPrompt: widget.lesson.assessment != null,
          // Kirim false semua — fullscreen kelola sendiri dari controller listener
          showNextLessonPrompt: false,
          showAssessmentPrompt: false,
          autoNextRemainingSeconds: null,
          autoNextCancelled: _autoNextCancelled,
          onTogglePlayback: _toggleVideoPlayback,
          onSeek: _seekVideo,
          onToggleMute: _toggleMute,
          onSkipForward: () => _skipVideoBy(30),
          onSkipBackward: () => _skipVideoBy(-30),
          onCancelAutoNext: () => _cancelAutoNextCountdown(),
          onStartAssessment: () => _navigateToAssessmentIntro(context),
          onCancelAssessment: _cancelAssessmentPrompt,
        ),
      ),
    );
    } finally {
      _isFullscreenOpen = false;
      await _waitForOverlayToDetach();
    }

    if (!mounted) return;

    if (result == _FullscreenExitAction.playNextLesson) {
      final nextLesson = _autoNextTarget;
      if (nextLesson == null) return;

      await _navigateToLessonKeepingFullscreen(
          nextLesson.lessonId,
          autoPlayVideo: true,
      );
      return;
    }

    if (result == _FullscreenExitAction.startAssessment) {
      await _restorePortraitUi();
      if (!mounted) return;
      await _navigateToAssessmentIntro(context);
      return;
    }

    await _restorePortraitUi();

    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final lesson = widget.lesson;
    final topInset = MediaQuery.paddingOf(context).top;
    final videoTopSpacing = topInset < 12 ? 16.0 : topInset + 4;

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
            child: Padding(
              padding: EdgeInsets.only(top: videoTopSpacing),
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
                showAssessmentPrompt: false,
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
                onStartAssessment: () => _navigateToAssessmentIntro(context),
                onCancelAssessment: _cancelAssessmentPrompt,
                onOpenFullscreen: _openFullscreen,
                nextLesson: _autoNextTarget,
              ),
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
                      onOpenAssessment: () => _navigateToAssessmentIntro(context),
                    ),
                    const SizedBox(height: 28),
                    if (lesson.content != null && lesson.content!.isNotEmpty) ...[
                      _ContentSection(content: lesson.content!),
                      const SizedBox(height: 28),
                    ],
                    if (lesson.workbook.isAvailable) ...[
                      LessonWorkbookSection(
                        workbook: lesson.workbook,
                        onDismissed: _refreshLesson,
                      ),
                      const SizedBox(height: 28),
                    ],
                    if (lesson.assessment != null) ...[
                      LessonAssessmentBanner(
                        lesson: lesson,
                        isUnlocked: _isAssessmentUnlocked,
                        onOpenAssessment: () => _navigateToAssessmentIntro(context),
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
  final bool showAssessmentPrompt;
  final int? autoNextRemainingSeconds;
  final bool autoNextCancelled;
  final Future<void> Function() onPlayNextLesson;
  final VoidCallback onCancelAutoNext;
  final Future<void> Function() onStartAssessment;
  final VoidCallback onCancelAssessment;
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
    required this.showAssessmentPrompt,
    required this.autoNextRemainingSeconds,
    required this.autoNextCancelled,
    required this.onPlayNextLesson,
    required this.onCancelAutoNext,
    required this.onStartAssessment,
    required this.onCancelAssessment,
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
          top: 12,
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
            ? () => showWorkbookOptions(
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
      key: ValueKey(controller),
      controller: controller,
      onTogglePlayback: onTogglePlayback,
      onSeek: onSeek,
      onToggleMute: onToggleMute,
      onSkipForward: onSkipForward,
      onSkipBackward: onSkipBackward,
      nextLesson: nextLesson,
      showNextLessonPrompt: showNextLessonPrompt,
      showAssessmentPrompt: showAssessmentPrompt,
      autoNextRemainingSeconds: autoNextRemainingSeconds,
      autoNextCancelled: autoNextCancelled,
      onPlayNextLesson: onPlayNextLesson,
      onCancelAutoNext: onCancelAutoNext,
      onStartAssessment: onStartAssessment,
      onCancelAssessment: onCancelAssessment,
      onOpenFullscreen: onOpenFullscreen,
    );
  }
}

class _InlineVideoPlayer extends StatefulWidget {
  final VideoPlayerController controller;
  final BoxFit fit;
  final _AutoNextTarget? nextLesson;
  final Future<void> Function() onTogglePlayback;
  final Future<void> Function(Duration position) onSeek;
  final Future<void> Function() onToggleMute;
  final Future<void> Function() onSkipForward;
  final Future<void> Function() onSkipBackward;
  final bool showNextLessonPrompt;
  final bool showAssessmentPrompt;
  final int? autoNextRemainingSeconds;
  final bool autoNextCancelled;
  final Future<void> Function() onPlayNextLesson;
  final VoidCallback onCancelAutoNext;
  final Future<void> Function() onStartAssessment;
  final VoidCallback onCancelAssessment;
  final Future<void> Function() onOpenFullscreen;

  const _InlineVideoPlayer({
    super.key,
    required this.controller,
    this.fit = BoxFit.cover,
    required this.nextLesson,
    required this.onTogglePlayback,
    required this.onSeek,
    required this.onToggleMute,
    required this.onSkipForward,
    required this.onSkipBackward,
    required this.showNextLessonPrompt,
    required this.showAssessmentPrompt,
    required this.autoNextRemainingSeconds,
    required this.autoNextCancelled,
    required this.onPlayNextLesson,
    required this.onCancelAutoNext,
    required this.onStartAssessment,
    required this.onCancelAssessment,
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
    _wasPlaying = widget.controller.value.isPlaying;
    widget.controller.addListener(_handleControllerUpdate);
    _syncWakelock();
    _scheduleControlsHide();
  }

  @override
  void didUpdateWidget(covariant _InlineVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      try {
        oldWidget.controller.removeListener(_handleControllerUpdate);
      } catch (_) {}
      widget.controller.addListener(_handleControllerUpdate);
      _wasPlaying = widget.controller.value.isPlaying;
    }
    _syncWakelock();
  }

  @override
  void dispose() {
    _controlsTimer?.cancel();
    try {
      widget.controller.removeListener(_handleControllerUpdate);
    } catch (_) {}
    WakelockPlus.disable();
    super.dispose();
  }

  void _handleControllerUpdate() {
    _syncWakelock();
    if (!mounted) return;

    final isPlaying = widget.controller.value.isPlaying;
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
    if (widget.controller.value.isPlaying) {
      await WakelockPlus.enable();
    } else {
      await WakelockPlus.disable();
    }
  }

  void _scheduleControlsHide() {
    _controlsTimer?.cancel();
    if (!widget.controller.value.isPlaying) return;

    _controlsTimer = Timer(_controlsAutoHideDelay, () {
      if (!mounted || !widget.controller.value.isPlaying) return;
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
    if (mounted && widget.controller.value.isPlaying) {
      _scheduleControlsHide();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<VideoPlayerValue>(
      valueListenable: widget.controller,
      builder: (context, value, _) {
        if (!value.isInitialized ||
            value.size.width <= 0 ||
            value.size.height <= 0) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }
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
                fit: widget.fit,
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
              if (widget.showAssessmentPrompt)
                Positioned(
                  right: 16,
                  bottom: 88,
                  child: _VideoAssessmentOverlay(
                    onStartAssessment: widget.onStartAssessment,
                    onCancel: widget.onCancelAssessment,
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

class _VideoAssessmentOverlay extends StatelessWidget {
  final Future<void> Function() onStartAssessment;
  final VoidCallback onCancel;

  const _VideoAssessmentOverlay({
    required this.onStartAssessment,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 240),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.78),
          borderRadius: BorderRadius.circular(AppRadius.modal),
          border: Border.all(color: Colors.white.withOpacity(0.12), width: 0.8),
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
                    Icons.quiz_outlined,
                    color: AppColors.primary,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'ASSESSMENT READY',
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 8,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Montserrat',
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'This lesson is finished. Continue to the assessment?',
              style: TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w600,
                fontFamily: 'Montserrat',
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: onStartAssessment,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 7),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(AppRadius.button),
                      ),
                      child: const Text(
                        'Start Now',
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
                      'Later',
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
  final bool enableAssessmentPrompt;
  final bool showNextLessonPrompt;
  final bool showAssessmentPrompt;
  final int? autoNextRemainingSeconds;
  final bool autoNextCancelled;
  final Future<void> Function() onTogglePlayback;
  final Future<void> Function(Duration position) onSeek;
  final Future<void> Function() onToggleMute;
  final Future<void> Function() onSkipForward;
  final Future<void> Function() onSkipBackward;
  final VoidCallback onCancelAutoNext;
  final Future<void> Function() onStartAssessment;
  final VoidCallback onCancelAssessment;

  const _FullscreenVideoScreen({
    required this.controller,
    required this.nextLesson,
    required this.enableAutoNextOverlay,
    required this.enableAssessmentPrompt,
    required this.showNextLessonPrompt,
    required this.showAssessmentPrompt,
    required this.autoNextRemainingSeconds,
    required this.autoNextCancelled,
    required this.onTogglePlayback,
    required this.onSeek,
    required this.onToggleMute,
    required this.onSkipForward,
    required this.onSkipBackward,
    required this.onCancelAutoNext,
    required this.onStartAssessment,
    required this.onCancelAssessment,
  });

  @override
  State<_FullscreenVideoScreen> createState() => _FullscreenVideoScreenState();
}

class _FullscreenVideoScreenState extends State<_FullscreenVideoScreen> {
  bool _showNextLessonPrompt = false;
  bool _showAssessmentPrompt = false;
  bool _autoNextCancelled = false;
  bool _isAutoNavigating = false;
  bool _showTransitionLoader = false;
  bool _isClosingScreen = false;
  int? _autoNextRemainingSeconds;

  void _closeFullscreen([_FullscreenExitAction? result]) {
    if (_isClosingScreen || !mounted) return;
    _isClosingScreen = true;
    Navigator.of(context, rootNavigator: true).pop(result);
  }

  Future<void> _playNextLessonFromFullscreen() async {
    if (_isAutoNavigating) return;
    if (!mounted) return;
    setState(() {
      _isAutoNavigating = true;
      _showTransitionLoader = true;
    });
    _closeFullscreen(_FullscreenExitAction.playNextLesson);
  }

  Future<void> _startAssessmentFromFullscreen() async {
    if (_isAutoNavigating) return;
    if (!mounted) return;
    setState(() {
      _isAutoNavigating = true;
      _showTransitionLoader = true;
    });
    _closeFullscreen(_FullscreenExitAction.startAssessment);
  }

  bool _mounted = false; // track manual karena async wakelock

  @override
  void initState() {
    super.initState();
    _mounted = true;
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setPreferredOrientations(const [
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]).then((_) {
      // Tunggu orientation settle baru enable wakelock
      if (_mounted) WakelockPlus.enable();
    });
    widget.controller.addListener(_handleAutoNextOverlay);
  }


  @override
  void dispose() {
    _mounted = false;
    widget.controller.removeListener(_handleAutoNextOverlay);
    // Jangan set orientation di sini — biarkan parent yang handle
    // supaya tidak bentrok dengan _navigateToLessonAfterFullscreen
    WakelockPlus.disable();
    super.dispose();
  }

  void _handleAutoNextOverlay() {
    if (widget.enableAssessmentPrompt) {
      final value = widget.controller.value;
      final remaining = value.duration - value.position;
      final remainingMillis = remaining.inMilliseconds;
      final remainingSeconds = (remainingMillis.clamp(0, 10000) / 1000)
          .ceil()
          .clamp(0, 10);

      if (remainingSeconds <= 0 && !_showAssessmentPrompt && mounted) {
        setState(() => _showAssessmentPrompt = true);
      } else if (remainingSeconds > 0 && _showAssessmentPrompt && mounted) {
        setState(() => _showAssessmentPrompt = false);
      }
      return;
    }

    if (!widget.enableAutoNextOverlay) {
      _resetAutoNextOverlay();
      return;
    }

    final nextLesson = widget.nextLesson;
    if (nextLesson == null) {
      _resetAutoNextOverlay();
      return;
    }

    final value = widget.controller.value;
    final remaining = value.duration - value.position;
    final rawRemainingMillis = remaining.inMilliseconds;
    final isNearEnd = rawRemainingMillis <= 10000;
    final remainingMillis = rawRemainingMillis.clamp(0, 10000);
    final remainingSeconds = (remainingMillis / 1000).ceil().clamp(0, 10);

    if (remainingSeconds <= 0) {
      if (_isAutoNavigating || _autoNextCancelled) return;
      unawaited(_playNextLessonFromFullscreen());
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: AspectRatio(
                aspectRatio: widget.controller.value.aspectRatio <= 0
                    ? 16 / 9
                    : widget.controller.value.aspectRatio,
                child: _InlineVideoPlayer(
                  controller: widget.controller,
                  fit: BoxFit.contain,
                  nextLesson: widget.nextLesson,
                  showNextLessonPrompt: false,
                  showAssessmentPrompt: false,
                  autoNextRemainingSeconds: null,
                  autoNextCancelled: false,
                  onTogglePlayback: widget.onTogglePlayback,
                  onSeek: widget.onSeek,
                  onToggleMute: widget.onToggleMute,
                  onSkipForward: widget.onSkipForward,
                  onSkipBackward: widget.onSkipBackward,
                  onPlayNextLesson: _playNextLessonFromFullscreen,
                  onCancelAutoNext: widget.onCancelAutoNext,
                  onStartAssessment: _startAssessmentFromFullscreen,
                  onCancelAssessment: widget.onCancelAssessment,
                  onOpenFullscreen: () async => _closeFullscreen(),
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
                  onPlayNow: _playNextLessonFromFullscreen,
                  onCancel: () => _cancelAutoNextOverlay(),
                ),
              ),
            if (_showAssessmentPrompt)
              Positioned(
                right: 20,
                bottom: 92,
                child: _VideoAssessmentOverlay(
                  onStartAssessment: _startAssessmentFromFullscreen,
                  onCancel: () {
                    if (!mounted) return;
                    setState(() => _showAssessmentPrompt = false);
                    widget.onCancelAssessment();
                  },
                ),
              ),
            Positioned(
              top: 12,
              left: 12,
              child: GestureDetector(
                onTap: _showTransitionLoader ? null : () => _closeFullscreen(),
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
            if (_showTransitionLoader)
              Positioned.fill(
                child: AbsorbPointer(
                  child: Container(
                    color: Colors.black.withOpacity(0.78),
                    child: const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 28,
                            height: 28,
                            child: CircularProgressIndicator(
                              color: AppColors.primary,
                              strokeWidth: 2.6,
                            ),
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Loading next video...',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'Montserrat',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
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
  final Future<void> Function() onOpenAssessment;

  const _ActionRow({
    required this.lesson,
    required this.isAssessmentUnlocked,
    required this.onWorkbookDismissed,
    required this.audioLoading,
    required this.audioReady,
    required this.audioError,
    required this.audioPlayer,
    required this.onRetryAudio,
    required this.onOpenAssessment,
  });

  void _openWorkbook(BuildContext context) {
    showWorkbookOptions(
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
      builder: (_) => LessonAudioSheet(
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
                ? onOpenAssessment
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
        const SectionLabel(text: 'About This Lesson'),
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



// ─── Workbook Sheet ───────────────────────────────────────────────────────────



// ─── Audio Sheet ──────────────────────────────────────────────────────────────



// ─── Sheet Button ─────────────────────────────────────────────────────────────



// ─── Assessment Banner ────────────────────────────────────────────────────────



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
        const SectionLabel(text: 'All Lessons'),
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



// ─── Skeleton ─────────────────────────────────────────────────────────────────



// ─── Error ────────────────────────────────────────────────────────────────────

