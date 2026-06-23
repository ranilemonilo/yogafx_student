import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/assessment_model.dart';
import '../providers/assessment_provider.dart';

/// Netflix-inspired palette, scoped to this screen only so the rest of the
/// app's shared theme (AppColors) stays untouched.
abstract class _NetflixPalette {
  static const Color background = Color(0xFF141414);
  static const Color surface = Color(0xFF1F1F1F);
  static const Color surfaceRaised = Color(0xFF2A2A2A);
  static const Color red = Color(0xFFE50914);
  static const Color grey = Color(0xFFB3B3B3);
  static const Color greyMuted = Color(0xFF808080);
  static const Color divider = Color(0xFF3A3A3A);
}

const double _kHeroHeight = 300;

class AssessmentIntroScreen extends ConsumerWidget {
  final int lessonId;

  const AssessmentIntroScreen({super.key, required this.lessonId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final introAsync = ref.watch(assessmentIntroProvider(lessonId));

    return Scaffold(
      backgroundColor: _NetflixPalette.background,
      body: introAsync.when(
        loading: () => const _IntroSkeleton(),
        error: (e, _) => _IntroError(
          message: e.toString(),
          onBack: () => context.pop(),
          onRetry: () => ref.invalidate(assessmentIntroProvider(lessonId)),
        ),
        data: (data) {
          final assessment = data.assessment;
          final eligibility = data.eligibility;
          final isUnlocked = eligibility.isUnlocked;
          final watchProgress = eligibility.watchProgress;
          final requiresWatchProgress = eligibility.requiresWatchProgress;
          final hasActiveAttempt = _extractAttemptId(data.attempt) != null;
          final hasCompletedAttempt =
              _extractAttemptId(data.completedAttempt) != null;
          final double progressFraction =
          ((double.tryParse(watchProgress ?? '') ?? 0.0) / 100)
              .clamp(0.0, 1.0)
              .toDouble();

          return _AssessmentDetailView(
            lessonId: lessonId,
            thumbnailUrl: assessment.thumbnailUrl,
            lessonTitle: data.lesson.title,
            title: assessment.title,
            description: assessment.description,
            durationMinutes: assessment.durationMinutes,
            allowBackNavigation: assessment.allowBackNavigation,
            isUnlocked: isUnlocked,
            requiresWatchProgress: requiresWatchProgress,
            watchProgressLabel: watchProgress,
            progressFraction: progressFraction,
            onBack: () => context.pop(),
            startLabel: hasActiveAttempt
                ? 'Continue Assessment'
                : hasCompletedAttempt
                    ? 'View Result'
                    : 'Start Assessment',
            onStart: () => _startAssessment(context, ref, data),
          );
        },
      ),
    );
  }

  Future<void> _startAssessment(
    BuildContext context,
    WidgetRef ref,
    AssessmentIntroData intro,
  ) async {
    try {
      final activeAttemptId = _extractAttemptId(intro.attempt);
      if (activeAttemptId != null) {
        if (context.mounted) {
          context.pushReplacement(
            '/lessons/$lessonId/assessment/attempts/$activeAttemptId',
          );
        }
        return;
      }

      final completedAttemptId = _extractAttemptId(intro.completedAttempt);
      if (completedAttemptId != null) {
        if (context.mounted) {
          context.pushReplacement(
            '/lessons/$lessonId/assessment/attempts/$completedAttemptId/result',
          );
        }
        return;
      }

      final data = await ref.read(assessmentRepositoryProvider).start(lessonId);

      if (context.mounted) {
        context.pushReplacement(
          '/lessons/$lessonId/assessment/attempts/${data.attemptId}',
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: _NetflixPalette.red,
          ),
        );
      }
    }
  }

  int? _extractAttemptId(Map<String, dynamic>? attempt) {
    final rawId = attempt?['id'] ?? attempt?['attempt_id'];
    if (rawId is int) return rawId;
    if (rawId is num) return rawId.toInt();
    if (rawId is String) return int.tryParse(rawId);
    return null;
  }
}

class _AssessmentDetailView extends ConsumerStatefulWidget {
  final int lessonId;
  final String? thumbnailUrl;
  final String lessonTitle;
  final String title;
  final String? description;
  final int? durationMinutes;
  final bool allowBackNavigation;
  final bool isUnlocked;
  final bool requiresWatchProgress;
  final String? watchProgressLabel;
  final double progressFraction;
  final String startLabel;
  final VoidCallback onBack;
  final VoidCallback onStart;

  const _AssessmentDetailView({
    required this.lessonId,
    required this.thumbnailUrl,
    required this.lessonTitle,
    required this.title,
    required this.description,
    required this.durationMinutes,
    required this.allowBackNavigation,
    required this.isUnlocked,
    required this.requiresWatchProgress,
    required this.watchProgressLabel,
    required this.progressFraction,
    required this.startLabel,
    required this.onBack,
    required this.onStart,
  });

  @override
  ConsumerState<_AssessmentDetailView> createState() =>
      _AssessmentDetailViewState();
}

class _AssessmentDetailViewState extends ConsumerState<_AssessmentDetailView>
    with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  late final AnimationController _entranceController;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;
  double _appBarOpacity = 0;

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fade =
        CurvedAnimation(parent: _entranceController, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.04),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _entranceController, curve: Curves.easeOutCubic),
    );

    _scrollController.addListener(_handleScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _entranceController.forward();
    });
  }

  void _handleScroll() {
    final double opacity = (_scrollController.offset / (_kHeroHeight - 90))
        .clamp(0.0, 1.0)
        .toDouble();
    if ((opacity - _appBarOpacity).abs() > 0.01) {
      setState(() => _appBarOpacity = opacity);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _entranceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: _NetflixPalette.red,
      onRefresh: () async {
        ref.invalidate(assessmentIntroProvider(widget.lessonId));
        await ref.read(assessmentIntroProvider(widget.lessonId).future);
      },
      child: Stack(
        children: [
          ListView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            children: [
              _Hero(thumbnailUrl: widget.thumbnailUrl),
              FadeTransition(
                opacity: _fade,
                child: SlideTransition(
                  position: _slide,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _LessonTag(label: widget.lessonTitle),
                        const SizedBox(height: 10),
                        Text(
                          widget.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            fontFamily: 'Montserrat',
                            height: 1.15,
                          ),
                        ),
                        if (widget.description != null) ...[
                          const SizedBox(height: 10),
                          Text(
                            widget.description!,
                            style: const TextStyle(
                              color: _NetflixPalette.grey,
                              fontSize: 14,
                              fontFamily: 'Montserrat',
                              height: 1.6,
                            ),
                          ),
                        ],
                        const SizedBox(height: 18),
                        _MetaRow(
                          durationMinutes: widget.durationMinutes,
                          allowBackNavigation: widget.allowBackNavigation,
                        ),
                        const SizedBox(height: 28),
                        _EligibilitySection(
                          isUnlocked: widget.isUnlocked,
                          requiresWatchProgress: widget.requiresWatchProgress,
                          progressLabel: widget.watchProgressLabel,
                          progressFraction: widget.progressFraction,
                        ),
                        const SizedBox(height: 28),
                        _StartButton(
                          isUnlocked: widget.isUnlocked,
                          label: widget.startLabel,
                          onTap: widget.onStart,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          _TopBar(opacity: _appBarOpacity, onBack: widget.onBack),
        ],
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  final String? thumbnailUrl;

  const _Hero({required this.thumbnailUrl});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _kHeroHeight,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (thumbnailUrl != null)
            Image.network(
              thumbnailUrl!,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;
                return Container(color: _NetflixPalette.surfaceRaised);
              },
              errorBuilder: (_, __, ___) =>
                  Container(color: _NetflixPalette.surfaceRaised),
            )
          else
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    _NetflixPalette.surfaceRaised,
                    _NetflixPalette.background,
                  ],
                ),
              ),
              child: const Center(
                child: Icon(
                  Icons.quiz_outlined,
                  color: _NetflixPalette.greyMuted,
                  size: 56,
                ),
              ),
            ),
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            height: 110,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.55),
                    Colors.black.withOpacity(0),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 130,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    _NetflixPalette.background.withOpacity(0),
                    _NetflixPalette.background,
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

class _LessonTag extends StatelessWidget {
  final String label;

  const _LessonTag({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(
        color: _NetflixPalette.red,
        fontSize: 11,
        fontWeight: FontWeight.w700,
        fontFamily: 'Montserrat',
        letterSpacing: 1.4,
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  final int? durationMinutes;
  final bool allowBackNavigation;

  const _MetaRow({
    required this.durationMinutes,
    required this.allowBackNavigation,
  });

  @override
  Widget build(BuildContext context) {
    final items = <Widget>[];

    if (durationMinutes != null) {
      items.add(_item(Icons.timer_outlined, '$durationMinutes min'));
    }
    if (allowBackNavigation) {
      items.add(_item(Icons.undo_outlined, 'Back allowed'));
    }

    if (items.isEmpty) return const SizedBox.shrink();

    final children = <Widget>[];
    for (var i = 0; i < items.length; i++) {
      if (i != 0) {
        children.add(
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              '•',
              style:
              TextStyle(color: _NetflixPalette.greyMuted, fontSize: 12),
            ),
          ),
        );
      }
      children.add(items[i]);
    }

    return Row(children: children);
  }

  Widget _item(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: _NetflixPalette.grey),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            color: _NetflixPalette.grey,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            fontFamily: 'Montserrat',
          ),
        ),
      ],
    );
  }
}

class _EligibilitySection extends StatelessWidget {
  final bool isUnlocked;
  final bool requiresWatchProgress;
  final String? progressLabel;
  final double progressFraction;

  const _EligibilitySection({
    required this.isUnlocked,
    required this.requiresWatchProgress,
    required this.progressLabel,
    required this.progressFraction,
  });

  @override
  Widget build(BuildContext context) {
    final label = (progressLabel == null || progressLabel!.isEmpty)
        ? '0'
        : progressLabel!;
    if (!requiresWatchProgress) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isUnlocked ? Icons.check_circle : Icons.lock_outline,
                color:
                    isUnlocked ? _NetflixPalette.red : _NetflixPalette.greyMuted,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                isUnlocked ? 'Assessment unlocked' : 'Assessment locked',
                style: TextStyle(
                  color: isUnlocked ? Colors.white : _NetflixPalette.grey,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Montserrat',
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'This assessment is unlocked without video progress.',
            style: TextStyle(
              color: _NetflixPalette.greyMuted,
              fontSize: 11,
              fontFamily: 'Montserrat',
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              isUnlocked ? Icons.check_circle : Icons.lock_outline,
              color:
              isUnlocked ? _NetflixPalette.red : _NetflixPalette.greyMuted,
              size: 16,
            ),
            const SizedBox(width: 8),
            Text(
              isUnlocked ? 'Assessment unlocked' : 'Assessment locked',
              style: TextStyle(
                color: isUnlocked ? Colors.white : _NetflixPalette.grey,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                fontFamily: 'Montserrat',
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: SizedBox(
            width: double.infinity,
            height: 4,
            child: Stack(
              children: [
                Container(color: _NetflixPalette.surfaceRaised),
                TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0, end: progressFraction),
                  duration: const Duration(milliseconds: 900),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, child) {
                    return FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: value,
                      child: Container(color: _NetflixPalette.red),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Video progress: $progressLabel%  •  Required: 95%',
          style: const TextStyle(
            color: _NetflixPalette.greyMuted,
            fontSize: 11,
            fontFamily: 'Montserrat',
          ),
        ),
      ],
    );
  }
}

class _StartButton extends StatefulWidget {
  final bool isUnlocked;
  final String label;
  final VoidCallback onTap;

  const _StartButton({
    required this.isUnlocked,
    required this.label,
    required this.onTap,
  });

  @override
  State<_StartButton> createState() => _StartButtonState();
}

class _StartButtonState extends State<_StartButton> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (!widget.isUnlocked) return;
    if (_pressed != value) setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final unlocked = widget.isUnlocked;

    return GestureDetector(
      onTapDown: (_) => _setPressed(true),
      onTapCancel: () => _setPressed(false),
      onTapUp: (_) => _setPressed(false),
      onTap: unlocked ? widget.onTap : null,
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: Container(
          width: double.infinity,
          height: 52,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: unlocked ? Colors.white : _NetflixPalette.surfaceRaised,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                unlocked ? Icons.play_arrow : Icons.lock_outline,
                color: unlocked ? Colors.black : _NetflixPalette.greyMuted,
                size: 22,
              ),
              const SizedBox(width: 8),
              Text(
                unlocked ? widget.label : 'Watch more to unlock',
                style: TextStyle(
                  color: unlocked ? Colors.black : _NetflixPalette.greyMuted,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Montserrat',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final double opacity;
  final VoidCallback onBack;

  const _TopBar({required this.opacity, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        bottom: false,
        child: Container(
          height: 56,
          color: _NetflixPalette.background.withOpacity(opacity),
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            children: [
              IconButton(
                onPressed: onBack,
                icon: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3 * (1 - opacity)),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.arrow_back,
                      color: Colors.white, size: 20),
                ),
              ),
              Expanded(
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 150),
                  opacity: opacity,
                  child: const Text(
                    'Assessment',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Montserrat',
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 48),
            ],
          ),
        ),
      ),
    );
  }
}

class _IntroSkeleton extends StatefulWidget {
  const _IntroSkeleton();

  @override
  State<_IntroSkeleton> createState() => _IntroSkeletonState();
}

class _IntroSkeletonState extends State<_IntroSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);
    _pulse = Tween<double>(begin: 0.35, end: 0.65).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _block({
    double? width,
    required double height,
    BorderRadius? radius,
  }) {
    return AnimatedBuilder(
      animation: _pulse,
      builder: (context, _) {
        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: _NetflixPalette.surfaceRaised.withOpacity(_pulse.value),
            borderRadius: radius ?? BorderRadius.circular(4),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FadeTransition(
        opacity: _pulse,
        child: SizedBox(
          width: 220,
          child: Image.network(
            'https://yogafx.b-cdn.net/content/Logo%20YogAFX.png',
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) {
              return const Icon(
                Icons.image_outlined,
                color: _NetflixPalette.greyMuted,
                size: 56,
              );
            },
          ),
        ),
      ),
    );
  }
}

class _IntroError extends StatelessWidget {
  final String message;
  final VoidCallback onBack;
  final VoidCallback onRetry;

  const _IntroError({
    required this.message,
    required this.onBack,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: _NetflixPalette.surface,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.error_outline,
                  color: _NetflixPalette.grey,
                  size: 40,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                message,
                style: const TextStyle(
                  color: _NetflixPalette.grey,
                  fontSize: 14,
                  fontFamily: 'Montserrat',
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 12,
                runSpacing: 12,
                children: [
                  OutlinedButton(
                    onPressed: onBack,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: _NetflixPalette.divider),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 22,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    child: const Text(
                      'Back',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: onRetry,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _NetflixPalette.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 22,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    child: const Text(
                      'Retry',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
