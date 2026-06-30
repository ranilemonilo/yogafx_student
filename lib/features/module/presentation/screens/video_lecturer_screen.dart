import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:go_router/go_router.dart';

// ─── Design Tokens (Sesuai DESIGN_SYSTEM.md & AppColors) ──────────────────────

const _kRed        = Color(0xFFDB202C); // Primary / Red
const _kBg         = Color(0xFF060908); // Neutral Black 1 — bg utama
const _kHeaderBg   = Color(0xFF141110); // Neutral Black 2 — header
const _kSurface    = Color(0xFF120F0E); // Neutral Black 3 — card/panel
const _kElevated   = Color(0xFF281D16); // Neutral Brown — elevated/hover

const _kTextPrimary   = Color(0xFFFFFFFF);  // White
const _kTextSecondary = Color(0xA6FFFFFF);  // White 65%
const _kTextMuted     = Color(0x73FFFFFF);  // White 45%

const _kBorderSoft = Color(0x4DFFFFFF);     // White 30% — border card
const _kDivider    = Color(0x1AFFFFFF);     // White 10% — divider tipis

const _kRedSoft    = Color(0x1ADB202C);     // Red 10%
const _kRedBorder  = Color(0x4DDB202C);     // Red 30%

// Shadow DS §Catatan Implementasi
const _kShadowCard = [BoxShadow(color: Color(0xCC000000), blurRadius: 24, offset: Offset(0, 8))];

// ─── Screen ───────────────────────────────────────────────────────────────────

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

  // ─── Lifecycle ───

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

  @override
  void dispose() {
    _hideControlsTimer?.cancel();
    _restoreSystemUi();
    _disposeCurrentController();
    super.dispose();
  }

  // ─── Init ───

  Future<void> _initializeVideo() async {
    final token = ++_initToken;

    setState(() {
      _isInitialized = false;
      _hasError = false;
      _showControls = true;
      _dragPosition = null;
      _playbackSpeed = 1.0;
    });

    final controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));
    _controller = controller;
    controller.addListener(_handleVideoStateChanged);

    try {
      await controller.initialize();
      if (!mounted || token != _initToken) {
        await controller.dispose();
        return;
      }
      await controller.setPlaybackSpeed(_playbackSpeed);
      setState(() => _isInitialized = true);
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
      setState(() => _hasError = true);
      return;
    }

    final isEnded = value.isInitialized &&
        value.duration != Duration.zero &&
        value.position >= value.duration;

    if (isEnded && !_showControls) {
      setState(() => _showControls = true);
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

  // ─── System UI ───

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
    _isFullScreen ? await _exitFullScreen() : await _enterFullScreen();
  }

  // ─── Playback Controls ───

  Future<void> _togglePlayPause() async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;

    final value = controller.value;
    final isEnded = value.duration != Duration.zero && value.position >= value.duration;

    if (value.isPlaying) {
      await controller.pause();
      _hideControlsTimer?.cancel();
      setState(() => _showControls = true);
    } else {
      if (isEnded) await controller.seekTo(Duration.zero);
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
    if (target < Duration.zero) target = Duration.zero;
    if (duration != Duration.zero && target > duration) target = duration;

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
      setState(() => _showControls = false);
    } else {
      _showControlsThenAutoHide();
    }
  }

  void _showControlsThenAutoHide() {
    if (!mounted) return;
    setState(() => _showControls = true);
    _startHideControlsTimer();
  }

  void _startHideControlsTimer() {
    _hideControlsTimer?.cancel();
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;
    if (!controller.value.isPlaying) return;

    _hideControlsTimer = Timer(const Duration(seconds: 3), () {
      final latest = _controller;
      if (!mounted || latest == null || !latest.value.isInitialized || !latest.value.isPlaying) return;
      setState(() => _showControls = false);
    });
  }

  // ─── Navigation ───

  Future<void> _goToNextVideo() async {
    if (widget.nextVideoId == null || widget.nextVideoUrl == null) return;
    if (_isFullScreen) await _exitFullScreen();
    if (!mounted) return;

    context.pushReplacementNamed(
      'videoLecturer',
      pathParameters: {'videoId': widget.nextVideoId!},
      queryParameters: {
        'title': widget.nextVideoTitle ?? 'Next Video',
        'url': widget.nextVideoUrl!,
      },
    );
  }

  // ─── Formatters ───

  String _formatDuration(Duration duration) {
    final h = duration.inHours;
    final m = duration.inMinutes.remainder(60);
    final s = duration.inSeconds.remainder(60);
    if (h > 0) {
      return '$h:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    }
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  String _formatPlaybackSpeed(double speed) {
    if (speed == speed.roundToDouble()) return '${speed.toInt()}x';
    return '${speed.toStringAsFixed(2).replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '')}x';
  }

  // ─── Build ───

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
        // DS: Header bg #141110, elevation 0
        appBar: _isFullScreen
            ? null
            : AppBar(
          title: const Text(
            'Video Lecture',
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: _kTextPrimary,
            ),
          ),
          backgroundColor: _kHeaderBg,
          iconTheme: const IconThemeData(color: _kTextPrimary),
          elevation: 0,
          scrolledUnderElevation: 0,
        ),
        body: _isFullScreen ? _buildFullScreenBody() : _buildNormalBody(),
      ),
    );
  }

  Widget _buildNormalBody() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxVideoHeight = constraints.maxHeight * 0.52;
        final widthBasedHeight = constraints.maxWidth * 9 / 16;
        final videoHeight =
            widthBasedHeight < maxVideoHeight ? widthBasedHeight : maxVideoHeight;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
        // Video player di atas — background hitam penuh
        SizedBox(
          height: videoHeight,
          width: double.infinity,
          child: Container(
            color: Colors.black,
            child: _buildVideoPlayer(isFullScreen: false),
          ),
        ),
        // Info panel
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Judul — DS: Semi Bold / Headline 1 (22px) untuk judul seksi
              Text(
                widget.title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: _kTextPrimary,
                  fontFamily: 'Montserrat',
                ),
              ),
              const SizedBox(height: 12),
              // Deskripsi — DS: Regular / Body 14px, White 65%
              const Text(
                'Watch this lesson carefully. You can continue to the next video after completing this lecture.',
                style: TextStyle(
                  fontSize: 14,
                  color: _kTextSecondary,
                  height: 1.6,
                  fontFamily: 'Montserrat',
                ),
              ),
              // "Up Next" section
              if (widget.nextVideoId != null) ...[
                const SizedBox(height: 28),
                // Divider — DS: White 10%
                Container(height: 1, color: _kDivider),
                const SizedBox(height: 20),
                // Section label — DS: uppercase, letter-spacing, White 65%
                const Text(
                  'UP NEXT',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                    letterSpacing: 1.5,
                    color: _kTextSecondary,
                    fontFamily: 'Montserrat',
                  ),
                ),
                const SizedBox(height: 12),
                // Next video card — DS: Card radius 4px, border White 30%, shadow
                GestureDetector(
                  onTap: _goToNextVideo,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _kSurface,
                      borderRadius: BorderRadius.circular(4), // DS: card 4px
                      border: Border.all(color: _kBorderSoft, width: 0.8),
                      boxShadow: _kShadowCard,
                    ),
                    child: Row(
                      children: [
                        // Icon container — DS: Red soft bg, radius 4px
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: _kRedSoft,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: _kRedBorder, width: 0.8),
                          ),
                          child: const Icon(
                            Icons.play_circle_fill_rounded,
                            color: _kRed,
                            size: 26,
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
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.chevron_right_rounded,
                          color: _kTextMuted,
                          size: 24,
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
      },
    );
  }

  Widget _buildFullScreenBody() {
    return Container(
      color: Colors.black,
      child: _buildVideoPlayer(isFullScreen: true),
    );
  }

  // ─── Video Player ───

  Widget _buildVideoPlayer({required bool isFullScreen}) {
    final controller = _controller;

    if (_hasError) {
      return _buildVideoPlaceholder(
        isFullScreen: isFullScreen,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: _kRedSoft,
                shape: BoxShape.circle,
                border: Border.all(color: _kRedBorder),
              ),
              child: const Icon(Icons.error_outline_rounded, color: _kRed, size: 28),
            ),
            const SizedBox(height: 16),
            const Text(
              'Video failed to load',
              style: TextStyle(
                color: _kTextPrimary,
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () {
                _disposeCurrentController();
                _initializeVideo();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: _kRed,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'Try Again',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
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
          color: _kRed,
          strokeWidth: 2,
        ),
      );
    }

    return isFullScreen
        ? SizedBox.expand(
      child: _buildInteractiveVideo(controller: controller, isFullScreen: true),
    )
        : AspectRatio(
      aspectRatio: controller.value.aspectRatio,
      child: _buildInteractiveVideo(controller: controller, isFullScreen: false),
    );
  }

  Widget _buildVideoPlaceholder({required bool isFullScreen, required Widget child}) {
    if (isFullScreen) {
      return SizedBox.expand(child: Center(child: child));
    }
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Center(child: child),
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
              // Buffering indicator
              ValueListenableBuilder<VideoPlayerValue>(
                valueListenable: controller,
                builder: (context, value, _) {
                  if (!value.isBuffering) return const SizedBox.shrink();
                  return const Center(
                    child: CircularProgressIndicator(color: _kRed, strokeWidth: 2),
                  );
                },
              ),
              // Controls overlay
              AnimatedOpacity(
                opacity: _showControls ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 180),
                child: IgnorePointer(
                  ignoring: !_showControls,
                  child: _buildControls(controller: controller, isFullScreen: isFullScreen),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ─── Controls Overlay ───

  Widget _buildControls({
    required VideoPlayerController controller,
    required bool isFullScreen,
  }) {
    // DS §7 Video Player: gradient overlay hitam atas & bawah, tengah transparan
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withOpacity(0.75), // DS: Transparent Black 65–80%
            Colors.black.withOpacity(0.10),
            Colors.black.withOpacity(0.80),
          ],
          stops: const [0.0, 0.45, 1.0],
        ),
      ),
      child: ValueListenableBuilder<VideoPlayerValue>(
        valueListenable: controller,
        builder: (context, value, _) {
          final duration = value.duration;
          final currentPosition = _dragPosition ?? value.position;

          final durationMs = duration.inMilliseconds <= 0 ? 1.0 : duration.inMilliseconds.toDouble();
          final maxPositionMs = duration.inMilliseconds <= 0 ? 1 : duration.inMilliseconds;
          final positionMs = currentPosition.inMilliseconds.clamp(0, maxPositionMs).toDouble();
          final isEnded = duration != Duration.zero && value.position >= duration;

          return Column(
            children: [
              // Top bar — judul saat fullscreen
              if (isFullScreen)
                SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Row(
                      children: [
                        IconButton(
                          tooltip: 'Exit Fullscreen',
                          onPressed: _exitFullScreen,
                          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white),
                        ),
                        const SizedBox(width: 4),
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

              // Center: play/pause + seek
              Expanded(
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _controlIconButton(
                        icon: Icons.replay_10_rounded,
                        size: isFullScreen ? 38 : 32,
                        onPressed: () => _seekRelative(const Duration(seconds: -10)),
                      ),
                      SizedBox(width: isFullScreen ? 40 : 28),
                      _mainPlayButton(
                        icon: value.isPlaying
                            ? Icons.pause_rounded
                            : isEnded
                            ? Icons.replay_rounded
                            : Icons.play_arrow_rounded,
                        isFullScreen: isFullScreen,
                        onPressed: _togglePlayPause,
                      ),
                      SizedBox(width: isFullScreen ? 40 : 28),
                      _controlIconButton(
                        icon: Icons.forward_10_rounded,
                        size: isFullScreen ? 38 : 32,
                        onPressed: () => _seekRelative(const Duration(seconds: 10)),
                      ),
                    ],
                  ),
                ),
              ),

              // Bottom: progress bar + time + speed + fullscreen
              SafeArea(
                top: false,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    isFullScreen ? 20 : 8,
                    0,
                    isFullScreen ? 20 : 8,
                    isFullScreen ? 8 : 4,
                  ),
                  child: Column(
                    children: [
                      // Progress slider — for portrait keep it attached to the video frame
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          trackHeight: isFullScreen ? 4 : 3,
                          activeTrackColor: _kRed,
                          inactiveTrackColor: Colors.white24,
                          thumbColor: _kRed,
                          overlayColor: _kRed.withOpacity(0.20),
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
                          onChangeStart: (_) => _hideControlsTimer?.cancel(),
                          onChanged: (v) => setState(() {
                            _dragPosition = Duration(milliseconds: v.round());
                          }),
                          onChangeEnd: (v) async {
                            await controller.seekTo(Duration(milliseconds: v.round()));
                            if (!mounted) return;
                            setState(() => _dragPosition = null);
                            _showControlsThenAutoHide();
                          },
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.zero,
                        padding: EdgeInsets.symmetric(
                          horizontal: isFullScreen ? 10 : 6,
                          vertical: isFullScreen ? 4 : 2,
                        ),
                        decoration: BoxDecoration(
                          color: isFullScreen
                              ? Colors.black.withOpacity(0.35)
                              : Colors.black.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Row(
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
                              onOpened: () => _hideControlsTimer?.cancel(),
                              onSelected: _changePlaybackSpeed,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                                side: BorderSide(color: _kBorderSoft, width: 0.8),
                              ),
                              itemBuilder: (context) => [
                                _speedItem(0.5),
                                _speedItem(0.75),
                                _speedItem(1.0),
                                _speedItem(1.25),
                                _speedItem(1.5),
                                _speedItem(2.0),
                              ],
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
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
                              tooltip: isFullScreen ? 'Exit Fullscreen' : 'Fullscreen',
                              onPressed: _toggleFullScreen,
                              icon: Icon(
                                isFullScreen ? Icons.fullscreen_exit_rounded : Icons.fullscreen_rounded,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
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

  PopupMenuItem<double> _speedItem(double speed) {
    final isSelected = _playbackSpeed == speed;
    return PopupMenuItem<double>(
      value: speed,
      child: Text(
        _formatPlaybackSpeed(speed),
        style: TextStyle(
          color: isSelected ? _kRed : _kTextPrimary,
          fontFamily: 'Montserrat',
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          fontSize: 14,
        ),
      ),
    );
  }

  // ─── Control Buttons ───

  Widget _mainPlayButton({
    required IconData icon,
    required bool isFullScreen,
    required VoidCallback onPressed,
  }) {
    final size = isFullScreen ? 72.0 : 60.0;
    final iconSize = isFullScreen ? 42.0 : 36.0;

    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          // DS §Media Control: rgba(0,0,0,0.6), border putih tipis
          color: Colors.black.withOpacity(0.60),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withOpacity(0.8), width: 1.5),
        ),
        child: Icon(icon, color: Colors.white, size: iconSize),
      ),
    );
  }

  Widget _controlIconButton({
    required IconData icon,
    required double size,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: size + 20,
        height: size + 20,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.40),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: size),
      ),
    );
  }
}
