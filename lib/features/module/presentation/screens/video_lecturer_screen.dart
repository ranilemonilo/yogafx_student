import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:go_router/go_router.dart';

// ─── Constants ───
const _kBg = Color(0xFF141414);
const _kSurface = Color(0xFF1F1F1F);
const _kNetflixRed = Color(0xFFE50914);
const _kTextPrimary = Colors.white;
const _kTextSecondary = Color(0xFFB3B3B3);
const _kDivider = Color(0xFF2E2E2E);

class VideoLecturerScreen extends StatefulWidget {
  final String videoId;
  final String title;
  final String videoUrl;

  final String? nextVideoId;
  final String? nextVideoTitle;
  final String? nextVideoUrl;

  const VideoLecturerScreen({
    super.key,
    required this.videoId,
    required this.title,
    required this.videoUrl,
    this.nextVideoId,
    this.nextVideoTitle,
    this.nextVideoUrl,
  });

  @override
  State<VideoLecturerScreen> createState() => _VideoLecturerScreenState();
}

class _VideoLecturerScreenState extends State<VideoLecturerScreen> {
  VideoPlayerController? _controller;

  bool _isInitialized = false;
  bool _hasError = false;
  bool _isFullScreen = false;
  bool _showControls = true;

  double _playbackSpeed = 1.0;
  Duration? _dragPosition;
  Timer? _hideControlsTimer;

  int _initToken = 0;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  @override
  void didUpdateWidget(covariant VideoLecturerScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.videoUrl != widget.videoUrl) {
      _disposeCurrentController();
      _initializeVideo();
    }
  }

  Future<void> _initializeVideo() async {
    final token = ++_initToken;

    setState(() {
      _isInitialized = false;
      _hasError = false;
      _showControls = true;
      _dragPosition = null;
      _playbackSpeed = 1.0;
    });

    final controller = VideoPlayerController.networkUrl(
      Uri.parse(widget.videoUrl),
    );

    _controller = controller;
    controller.addListener(_handleVideoStateChanged);

    try {
      await controller.initialize();

      if (!mounted || token != _initToken) {
        await controller.dispose();
        return;
      }

      await controller.setPlaybackSpeed(_playbackSpeed);

      setState(() {
        _isInitialized = true;
      });

      await controller.play();
      _showControlsThenAutoHide();
    } catch (_) {
      if (!mounted || token != _initToken) return;

      setState(() {
        _hasError = true;
        _isInitialized = false;
      });
    }
  }

  void _handleVideoStateChanged() {
    final controller = _controller;
    if (!mounted || controller == null) return;

    final value = controller.value;

    if (value.hasError && !_hasError) {
      setState(() {
        _hasError = true;
      });
      return;
    }

    final isEnded = value.isInitialized &&
        value.duration != Duration.zero &&
        value.position >= value.duration;

    if (isEnded && !_showControls) {
      setState(() {
        _showControls = true;
      });
    }
  }

  void _disposeCurrentController() {
    _hideControlsTimer?.cancel();

    final controller = _controller;
    if (controller != null) {
      controller.removeListener(_handleVideoStateChanged);
      controller.dispose();
    }

    _controller = null;
  }

  @override
  void dispose() {
    _hideControlsTimer?.cancel();
    _restoreSystemUi();
    _disposeCurrentController();
    super.dispose();
  }

  Future<void> _restoreSystemUi() async {
    await SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );

    await SystemChrome.setPreferredOrientations([]);
  }

  Future<void> _enterFullScreen() async {
    setState(() {
      _isFullScreen = true;
      _showControls = true;
    });

    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    _showControlsThenAutoHide();
  }

  Future<void> _exitFullScreen() async {
    setState(() {
      _isFullScreen = false;
      _showControls = true;
    });

    await _restoreSystemUi();
    _showControlsThenAutoHide();
  }

  Future<void> _toggleFullScreen() async {
    if (_isFullScreen) {
      await _exitFullScreen();
    } else {
      await _enterFullScreen();
    }
  }

  Future<void> _togglePlayPause() async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;

    final value = controller.value;
    final isEnded = value.duration != Duration.zero &&
        value.position >= value.duration;

    if (value.isPlaying) {
      await controller.pause();
      _hideControlsTimer?.cancel();

      setState(() {
        _showControls = true;
      });
    } else {
      if (isEnded) {
        await controller.seekTo(Duration.zero);
      }

      await controller.play();
      _showControlsThenAutoHide();
    }
  }

  Future<void> _seekRelative(Duration offset) async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;

    final current = controller.value.position;
    final duration = controller.value.duration;

    Duration target = current + offset;

    if (target < Duration.zero) {
      target = Duration.zero;
    }

    if (duration != Duration.zero && target > duration) {
      target = duration;
    }

    await controller.seekTo(target);
    _showControlsThenAutoHide();
  }

  Future<void> _changePlaybackSpeed(double speed) async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;

    setState(() {
      _playbackSpeed = speed;
      _showControls = true;
    });

    await controller.setPlaybackSpeed(speed);
    _showControlsThenAutoHide();
  }

  void _toggleControls() {
    if (_showControls) {
      _hideControlsTimer?.cancel();

      setState(() {
        _showControls = false;
      });
    } else {
      _showControlsThenAutoHide();
    }
  }

  void _showControlsThenAutoHide() {
    if (!mounted) return;

    setState(() {
      _showControls = true;
    });

    _startHideControlsTimer();
  }

  void _startHideControlsTimer() {
    _hideControlsTimer?.cancel();

    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;
    if (!controller.value.isPlaying) return;

    _hideControlsTimer = Timer(const Duration(seconds: 3), () {
      final latestController = _controller;

      if (!mounted ||
          latestController == null ||
          !latestController.value.isInitialized ||
          !latestController.value.isPlaying) {
        return;
      }

      setState(() {
        _showControls = false;
      });
    });
  }

  Future<void> _goToNextVideo() async {
    if (widget.nextVideoId == null || widget.nextVideoUrl == null) return;

    if (_isFullScreen) {
      await _exitFullScreen();
    }

    if (!mounted) return;

    context.pushReplacementNamed(
      'videoLecturer',
      pathParameters: {
        'videoId': widget.nextVideoId!,
      },
      queryParameters: {
        'title': widget.nextVideoTitle ?? 'Next Video',
        'url': widget.nextVideoUrl!,
      },
    );
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }

    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  String _formatPlaybackSpeed(double speed) {
    if (speed == speed.roundToDouble()) {
      return '${speed.toInt()}x';
    }

    return '${speed.toStringAsFixed(2).replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '')}x';
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_isFullScreen) {
          await _exitFullScreen();
          return false;
        }

        return true;
      },
      child: Scaffold(
        backgroundColor: _isFullScreen ? Colors.black : _kBg,
        appBar: _isFullScreen
            ? null
            : AppBar(
                title: const Text(
                  'Video Lecture',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                backgroundColor: Colors.black,
                iconTheme: const IconThemeData(color: Colors.white),
                elevation: 0,
              ),
        body: _isFullScreen ? _buildFullScreenBody() : _buildNormalBody(),
      ),
    );
  }

  Widget _buildNormalBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          color: Colors.black,
          width: double.infinity,
          child: _buildVideoPlayer(isFullScreen: false),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(20.0),
            children: [
              Text(
                widget.title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: _kTextPrimary,
                  fontFamily: 'Montserrat',
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Watch this lesson carefully. You can continue to the next video after completing this lecture.',
                style: TextStyle(
                  fontSize: 14,
                  color: _kTextSecondary,
                  height: 1.5,
                  fontFamily: 'Montserrat',
                ),
              ),
              const SizedBox(height: 32),
              if (widget.nextVideoId != null) ...[
                const Divider(color: _kDivider),
                const SizedBox(height: 16),
                const Text(
                  'UP NEXT',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    letterSpacing: 1.2,
                    color: _kTextSecondary,
                    fontFamily: 'Montserrat',
                  ),
                ),
                const SizedBox(height: 12),
                InkWell(
                  onTap: _goToNextVideo,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _kSurface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _kDivider,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: _kNetflixRed.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.play_circle_fill,
                            color: _kNetflixRed,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            widget.nextVideoTitle ?? 'Next Video',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: _kTextPrimary,
                              fontFamily: 'Montserrat',
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Icon(
                          Icons.chevron_right,
                          color: _kTextSecondary,
                        ),
                      ],
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

  Widget _buildFullScreenBody() {
    return Container(
      color: Colors.black,
      child: _buildVideoPlayer(isFullScreen: true),
    );
  }

  Widget _buildVideoPlayer({
    required bool isFullScreen,
  }) {
    final controller = _controller;

    if (_hasError) {
      return _buildVideoPlaceholder(
        isFullScreen: isFullScreen,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: _kNetflixRed,
              size: 42,
            ),
            const SizedBox(height: 12),
            const Text(
              'Video failed to load',
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () {
                _disposeCurrentController();
                _initializeVideo();
              },
              child: const Text(
                'Try Again',
                style: TextStyle(
                  color: _kNetflixRed,
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (!_isInitialized || controller == null) {
      return _buildVideoPlaceholder(
        isFullScreen: isFullScreen,
        child: const CircularProgressIndicator(
          color: _kNetflixRed,
        ),
      );
    }

    return isFullScreen
        ? SizedBox.expand(
            child: _buildInteractiveVideo(
              controller: controller,
              isFullScreen: true,
            ),
          )
        : AspectRatio(
            aspectRatio: controller.value.aspectRatio,
            child: _buildInteractiveVideo(
              controller: controller,
              isFullScreen: false,
            ),
          );
  }

  Widget _buildVideoPlaceholder({
    required bool isFullScreen,
    required Widget child,
  }) {
    if (isFullScreen) {
      return SizedBox.expand(
        child: Center(
          child: child,
        ),
      );
    }

    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Center(
        child: child,
      ),
    );
  }

  Widget _buildInteractiveVideo({
    required VideoPlayerController controller,
    required bool isFullScreen,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _toggleControls,
          onDoubleTapDown: (details) {
            final tapX = details.localPosition.dx;
            final width = constraints.maxWidth;

            if (tapX < width / 2) {
              _seekRelative(const Duration(seconds: -10));
            } else {
              _seekRelative(const Duration(seconds: 10));
            }
          },
          child: Stack(
            fit: StackFit.expand,
            children: [
              Center(
                child: AspectRatio(
                  aspectRatio: controller.value.aspectRatio,
                  child: VideoPlayer(controller),
                ),
              ),
              ValueListenableBuilder<VideoPlayerValue>(
                valueListenable: controller,
                builder: (context, value, _) {
                  if (!value.isBuffering) {
                    return const SizedBox.shrink();
                  }

                  return const Center(
                    child: CircularProgressIndicator(
                      color: _kNetflixRed,
                    ),
                  );
                },
              ),
              AnimatedOpacity(
                opacity: _showControls ? 1 : 0,
                duration: const Duration(milliseconds: 180),
                child: IgnorePointer(
                  ignoring: !_showControls,
                  child: _buildControls(
                    controller: controller,
                    isFullScreen: isFullScreen,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildControls({
    required VideoPlayerController controller,
    required bool isFullScreen,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withOpacity(0.75),
            Colors.black.withOpacity(0.15),
            Colors.black.withOpacity(0.85),
          ],
          stops: const [
            0.0,
            0.45,
            1.0,
          ],
        ),
      ),
      child: ValueListenableBuilder<VideoPlayerValue>(
        valueListenable: controller,
        builder: (context, value, _) {
          final duration = value.duration;
          final currentPosition = _dragPosition ?? value.position;

          final durationMs = duration.inMilliseconds <= 0
              ? 1.0
              : duration.inMilliseconds.toDouble();

          final maxPositionMs = duration.inMilliseconds <= 0
              ? 1
              : duration.inMilliseconds;

          final positionMs = currentPosition.inMilliseconds
              .clamp(0, maxPositionMs)
              .toDouble();

          final isEnded = duration != Duration.zero &&
              value.position >= duration;

          return Column(
            children: [
              if (isFullScreen)
                SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          tooltip: 'Exit Fullscreen',
                          onPressed: _exitFullScreen,
                          icon: const Icon(
                            Icons.keyboard_arrow_down,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            widget.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                const SizedBox(height: 8),
              Expanded(
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _controlIconButton(
                        icon: Icons.replay_10,
                        size: isFullScreen ? 42 : 34,
                        onPressed: () {
                          _seekRelative(const Duration(seconds: -10));
                        },
                      ),
                      SizedBox(
                        width: isFullScreen ? 44 : 30,
                      ),
                      _mainPlayButton(
                        icon: value.isPlaying
                            ? Icons.pause
                            : isEnded
                                ? Icons.replay
                                : Icons.play_arrow,
                        isFullScreen: isFullScreen,
                        onPressed: _togglePlayPause,
                      ),
                      SizedBox(
                        width: isFullScreen ? 44 : 30,
                      ),
                      _controlIconButton(
                        icon: Icons.forward_10,
                        size: isFullScreen ? 42 : 34,
                        onPressed: () {
                          _seekRelative(const Duration(seconds: 10));
                        },
                      ),
                    ],
                  ),
                ),
              ),
              SafeArea(
                top: false,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    isFullScreen ? 28 : 12,
                    0,
                    isFullScreen ? 28 : 12,
                    isFullScreen ? 14 : 8,
                  ),
                  child: Column(
                    children: [
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          trackHeight: isFullScreen ? 4 : 3,
                          activeTrackColor: _kNetflixRed,
                          inactiveTrackColor: Colors.white24,
                          thumbColor: _kNetflixRed,
                          overlayColor: _kNetflixRed.withOpacity(0.20),
                          thumbShape: RoundSliderThumbShape(
                            enabledThumbRadius: isFullScreen ? 6 : 5,
                          ),
                          overlayShape: RoundSliderOverlayShape(
                            overlayRadius: isFullScreen ? 14 : 12,
                          ),
                        ),
                        child: Slider(
                          min: 0,
                          max: durationMs,
                          value: positionMs,
                          onChangeStart: (_) {
                            _hideControlsTimer?.cancel();
                          },
                          onChanged: (newValue) {
                            setState(() {
                              _dragPosition = Duration(
                                milliseconds: newValue.round(),
                              );
                            });
                          },
                          onChangeEnd: (newValue) async {
                            await controller.seekTo(
                              Duration(
                                milliseconds: newValue.round(),
                              ),
                            );

                            if (!mounted) return;

                            setState(() {
                              _dragPosition = null;
                            });

                            _showControlsThenAutoHide();
                          },
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            '${_formatDuration(currentPosition)} / ${_formatDuration(duration)}',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: isFullScreen ? 13 : 11,
                              fontFamily: 'Montserrat',
                            ),
                          ),
                          const Spacer(),
                          PopupMenuButton<double>(
                            tooltip: 'Playback Speed',
                            color: _kSurface,
                            initialValue: _playbackSpeed,
                            onOpened: () {
                              _hideControlsTimer?.cancel();
                            },
                            onSelected: _changePlaybackSpeed,
                            itemBuilder: (context) {
                              return const [
                                PopupMenuItem(
                                  value: 0.5,
                                  child: Text('0.5x'),
                                ),
                                PopupMenuItem(
                                  value: 0.75,
                                  child: Text('0.75x'),
                                ),
                                PopupMenuItem(
                                  value: 1.0,
                                  child: Text('1x'),
                                ),
                                PopupMenuItem(
                                  value: 1.25,
                                  child: Text('1.25x'),
                                ),
                                PopupMenuItem(
                                  value: 1.5,
                                  child: Text('1.5x'),
                                ),
                                PopupMenuItem(
                                  value: 2.0,
                                  child: Text('2x'),
                                ),
                              ];
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 8,
                              ),
                              child: Text(
                                _formatPlaybackSpeed(_playbackSpeed),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: isFullScreen ? 13 : 11,
                                  fontFamily: 'Montserrat',
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          IconButton(
                            tooltip: isFullScreen
                                ? 'Exit Fullscreen'
                                : 'Fullscreen',
                            onPressed: _toggleFullScreen,
                            icon: Icon(
                              isFullScreen
                                  ? Icons.fullscreen_exit
                                  : Icons.fullscreen,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _mainPlayButton({
    required IconData icon,
    required bool isFullScreen,
    required VoidCallback onPressed,
  }) {
    return InkResponse(
      onTap: onPressed,
      radius: isFullScreen ? 44 : 38,
      child: Container(
        width: isFullScreen ? 76 : 64,
        height: isFullScreen ? 76 : 64,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.48),
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white24,
          ),
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: isFullScreen ? 46 : 40,
        ),
      ),
    );
  }

  Widget _controlIconButton({
    required IconData icon,
    required double size,
    required VoidCallback onPressed,
  }) {
    return InkResponse(
      onTap: onPressed,
      radius: size,
      child: Container(
        width: size + 22,
        height: size + 22,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.35),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: size,
        ),
      ),
    );
  }
}