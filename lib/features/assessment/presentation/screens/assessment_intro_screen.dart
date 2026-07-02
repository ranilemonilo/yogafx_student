import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/assessment_model.dart';
import '../providers/assessment_provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Design Tokens — disesuaikan dengan DESIGN_SYSTEM.md
// ─────────────────────────────────────────────────────────────────────────────
abstract class _DS {
  // Colors (sesuai §1 Warna)
  static const Color background    = Color(0xFF060908); // Neutral / Black 1 — bg utama
  static const Color surface       = Color(0xFF141110); // Neutral / Black 2 — header/footer
  static const Color surfaceRaised = Color(0xFF120F0E); // Neutral / Black 3 — card/panel
  static const Color red           = Color(0xFFDB202C); // Primary / Red
  static const Color emerald       = Color(0xFF00B14F); // Secondary / Emerald
  static const Color white         = Color(0xFFFFFFFF);
  static const Color textPrimary   = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xA6FFFFFF); // rgba(255,255,255,0.65)
  static const Color textMuted     = Color(0x73FFFFFF); // rgba(255,255,255,0.45)
  static const Color divider       = Color(0x1AFFFFFF); // rgba(255,255,255,0.1)

  // Border-radius (sesuai §"Catatan Implementasi - Border Radius")
  static const double radiusButton  = 4; // Tombol
  static const double radiusCard    = 4; // Card thumbnail
  static const double radiusInput   = 4; // Input field
  static const double radiusBadge   = 2; // Badge/label kecil
  static const double radiusAvatar  = 8; // Avatar profile
  static const double radiusModal   = 8; // Modal / panel
  static const double radiusCircle  = 100;

  // Spacing (base 8px grid)
  static const double sp4  = 4;
  static const double sp6  = 6;
  static const double sp8  = 8; // Grid dasar & Gutter antar card
  static const double sp10 = 10;
  static const double sp12 = 12;
  static const double sp16 = 16;
  static const double sp18 = 18;
  static const double sp20 = 20;
  static const double sp24 = 24;
  static const double sp28 = 28;
  static const double sp32 = 32;
  static const double sp40 = 40;
  static const double sp48 = 48;

  // Type scale (Montserrat)
  static TextStyle caption({Color? color}) => TextStyle(
    fontFamily: 'Montserrat',
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: color ?? textMuted,
    height: 1.5,
  );

  static TextStyle body({Color? color}) => TextStyle(
    fontFamily: 'Montserrat',
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: color ?? textSecondary,
    height: 1.6,
  );

  static TextStyle label({Color? color, double? letterSpacing}) => TextStyle(
    fontFamily: 'Montserrat',
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: color ?? textPrimary,
    letterSpacing: letterSpacing,
  );

  static TextStyle labelSmall({Color? color, double? letterSpacing}) => TextStyle(
    fontFamily: 'Montserrat',
    fontSize: 11,
    fontWeight: FontWeight.w700,
    color: color ?? red,
    letterSpacing: letterSpacing ?? 1.4,
    height: 1.2,
  );

  static TextStyle headline({Color? color}) => TextStyle(
    fontFamily: 'Montserrat',
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: color ?? textPrimary,
    height: 1.2,
  );

  static TextStyle title({Color? color}) => TextStyle(
    fontFamily: 'Montserrat',
    fontSize: 26,
    fontWeight: FontWeight.w800,
    color: color ?? textPrimary,
    height: 1.15,
  );

  static TextStyle buttonLabel({Color? color}) => TextStyle(
    fontFamily: 'Montserrat',
    fontSize: 15,
    fontWeight: FontWeight.w700,
    color: color ?? Colors.black,
  );

  static TextStyle navTitle({Color? color}) => TextStyle(
    fontFamily: 'Montserrat',
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: color ?? textPrimary,
  );
}

const double _kHeroHeight = 300;

// ─────────────────────────────────────────────────────────────────────────────
// Root screen — LOGIKA TIDAK DIUBAH
// ─────────────────────────────────────────────────────────────────────────────
class AssessmentIntroScreen extends ConsumerWidget {
  final int lessonId;

  const AssessmentIntroScreen({super.key, required this.lessonId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final introAsync = ref.watch(assessmentIntroProvider(lessonId));

    return Scaffold(
      backgroundColor: _DS.background,
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
            content: Text(
              e.toString(),
              style: _DS.body(color: _DS.white),
            ),
            backgroundColor: _DS.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(_DS.radiusCard),
            ),
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

// ─────────────────────────────────────────────────────────────────────────────
// Detail View — StatefulWidget TIDAK DIUBAH, hanya desain
// ─────────────────────────────────────────────────────────────────────────────
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
      color: _DS.red,
      backgroundColor: _DS.surfaceRaised,
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
                    padding: const EdgeInsets.fromLTRB(
                      _DS.sp24, _DS.sp20, _DS.sp24, _DS.sp40,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _LessonTag(label: widget.lessonTitle),
                        const SizedBox(height: _DS.sp10),
                        Text(widget.title, style: _DS.title()),
                        const SizedBox(height: _DS.sp16),
                        const _ThinDivider(),
                        const SizedBox(height: _DS.sp16),
                        if (widget.description != null) ...[
                          Text(
                            widget.description!,
                            style: _DS.body(),
                          ),
                          const SizedBox(height: _DS.sp20),
                        ],
                        _MetaRow(
                          durationMinutes: widget.durationMinutes,
                          allowBackNavigation: widget.allowBackNavigation,
                        ),
                        const SizedBox(height: _DS.sp28),
                        _EligibilitySection(
                          isUnlocked: widget.isUnlocked,
                          requiresWatchProgress: widget.requiresWatchProgress,
                          progressLabel: widget.watchProgressLabel,
                          progressFraction: widget.progressFraction,
                        ),
                        const SizedBox(height: _DS.sp32),
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

// ─────────────────────────────────────────────────────────────────────────────
// Hero
// ─────────────────────────────────────────────────────────────────────────────
class _Hero extends StatelessWidget {
  final String? thumbnailUrl;

  const _Hero({required this.thumbnailUrl});

  @override
  Widget build(BuildContext context) {
    return SizedBox(height: MediaQuery.paddingOf(context).top + 46);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Thin Divider
// ─────────────────────────────────────────────────────────────────────────────
class _ThinDivider extends StatelessWidget {
  const _ThinDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      width: double.infinity,
      color: _DS.divider,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Lesson Tag / Eyebrow
// ─────────────────────────────────────────────────────────────────────────────
class _LessonTag extends StatelessWidget {
  final String label;

  const _LessonTag({required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 3,
          height: 14,
          decoration: BoxDecoration(
            color: _DS.red,
            borderRadius: BorderRadius.circular(1),
          ),
        ),
        const SizedBox(width: _DS.sp8),
        Flexible(
          child: Text(
            label.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: _DS.labelSmall(color: _DS.red),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Meta Row
// ─────────────────────────────────────────────────────────────────────────────
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
      items.add(_MetaBadge(
        icon: Icons.timer_outlined,
        label: '$durationMinutes min',
      ));
    }
    if (allowBackNavigation) {
      items.add(_MetaBadge(
        icon: Icons.undo_outlined,
        label: 'Back allowed',
      ));
    }

    if (items.isEmpty) return const SizedBox.shrink();

    final children = <Widget>[];
    for (var i = 0; i < items.length; i++) {
      if (i != 0) {
        children.add(
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: _DS.sp8),
            child: Text(
              '•',
              style: _DS.caption(color: _DS.textMuted),
            ),
          ),
        );
      }
      children.add(items[i]);
    }

    return Row(children: children);
  }
}

class _MetaBadge extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MetaBadge({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: _DS.sp8,
        vertical: _DS.sp4,
      ),
      decoration: BoxDecoration(
        border: Border.all(color: _DS.divider),
        borderRadius: BorderRadius.circular(_DS.radiusBadge),
        color: _DS.surfaceRaised,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: _DS.textSecondary),
          const SizedBox(width: _DS.sp6),
          Text(label, style: _DS.caption(color: _DS.textSecondary)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Eligibility Section
// ─────────────────────────────────────────────────────────────────────────────
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
    return Container(
      padding: const EdgeInsets.all(_DS.sp16),
      decoration: BoxDecoration(
        color: _DS.surface,
        borderRadius: BorderRadius.circular(_DS.radiusModal), // panel → 8px
        border: Border.all(
          color: isUnlocked
              ? _DS.red.withOpacity(0.35)
              : _DS.divider,
        ),
      ),
      child: requiresWatchProgress
          ? _ProgressBody(
        isUnlocked: isUnlocked,
        progressLabel: progressLabel,
        progressFraction: progressFraction,
      )
          : _SimpleUnlockBody(isUnlocked: isUnlocked),
    );
  }
}

class _SimpleUnlockBody extends StatelessWidget {
  final bool isUnlocked;

  const _SimpleUnlockBody({required this.isUnlocked});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(_DS.sp8),
          decoration: BoxDecoration(
            color: isUnlocked
                ? _DS.red.withOpacity(0.12)
                : _DS.surfaceRaised,
            shape: BoxShape.circle,
          ),
          child: Icon(
            isUnlocked ? Icons.check_circle_outline : Icons.lock_outline,
            color: isUnlocked ? _DS.red : _DS.textMuted,
            size: 18,
          ),
        ),
        const SizedBox(width: _DS.sp12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isUnlocked ? 'Assessment Unlocked' : 'Assessment Locked',
                style: _DS.label(
                  color: isUnlocked ? _DS.textPrimary : _DS.textSecondary,
                ),
              ),
              const SizedBox(height: _DS.sp4),
              Text(
                'This assessment is unlocked without video progress.',
                style: _DS.caption(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ProgressBody extends StatelessWidget {
  final bool isUnlocked;
  final String? progressLabel;
  final double progressFraction;

  const _ProgressBody({
    required this.isUnlocked,
    required this.progressLabel,
    required this.progressFraction,
  });

  @override
  Widget build(BuildContext context) {
    final label = (progressLabel == null || progressLabel!.isEmpty)
        ? '0'
        : progressLabel!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(_DS.sp6),
              decoration: BoxDecoration(
                color: isUnlocked
                    ? _DS.red.withOpacity(0.12)
                    : _DS.surfaceRaised,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isUnlocked ? Icons.check_circle_outline : Icons.lock_outline,
                color: isUnlocked ? _DS.red : _DS.textMuted,
                size: 16,
              ),
            ),
            const SizedBox(width: _DS.sp10),
            Text(
              isUnlocked ? 'Assessment Unlocked' : 'Assessment Locked',
              style: _DS.label(
                color: isUnlocked ? _DS.textPrimary : _DS.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: _DS.sp16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Watch Progress', style: _DS.caption()),
            Text(
              '$label% / 95%',
              style: _DS.caption(
                color: isUnlocked ? _DS.red : _DS.textMuted,
              ),
            ),
          ],
        ),
        const SizedBox(height: _DS.sp8),
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: SizedBox(
            width: double.infinity,
            height: 4,
            child: Stack(
              children: [
                Container(color: _DS.surfaceRaised),
                TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0, end: progressFraction),
                  duration: const Duration(milliseconds: 900),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, child) {
                    return FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: value,
                      child: Container(color: _DS.red),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: _DS.sp10),
        if (!isUnlocked)
          Text(
            'Watch at least 95% of the video to unlock this assessment.',
            style: _DS.caption(),
          ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Start Button
// ─────────────────────────────────────────────────────────────────────────────
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

    return Column(
      children: [
        GestureDetector(
          onTapDown: (_) => _setPressed(true),
          onTapCancel: () => _setPressed(false),
          onTapUp: (_) => _setPressed(false),
          onTap: unlocked ? widget.onTap : null,
          child: AnimatedScale(
            scale: _pressed ? 0.97 : 1.0,
            duration: const Duration(milliseconds: 120),
            curve: Curves.easeOut,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 120),
              width: double.infinity,
              height: 52,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: unlocked
                    ? (_pressed ? const Color(0xFFE0E0E0) : _DS.white)
                    : _DS.surfaceRaised,
                borderRadius: BorderRadius.circular(_DS.radiusButton),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    unlocked ? Icons.play_arrow : Icons.lock_outline,
                    color: unlocked ? Colors.black : _DS.textMuted,
                    size: 22,
                  ),
                  const SizedBox(width: _DS.sp8),
                  Text(
                    unlocked ? widget.label : 'Watch more to unlock',
                    style: _DS.buttonLabel(
                      color: unlocked ? Colors.black : _DS.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (unlocked) ...[
          const SizedBox(height: _DS.sp12),
          Text(
            'You can review questions before submitting.',
            style: _DS.caption(),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Top Bar
// ─────────────────────────────────────────────────────────────────────────────
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
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          height: 56,
          decoration: BoxDecoration(
            color: _DS.background.withOpacity(opacity),
            boxShadow: opacity > 0
                ? [
              BoxShadow(
                color: Colors.black.withOpacity(0.7 * opacity),
                blurRadius: 12,
                offset: const Offset(0, 4),
              )
            ]
                : null,
          ),
          padding: const EdgeInsets.symmetric(horizontal: _DS.sp4),
          child: Row(
            children: [
              _BackButton(opacity: opacity, onBack: onBack),
              Expanded(
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 150),
                  opacity: opacity,
                  child: Text('Assessment', style: _DS.navTitle()),
                ),
              ),
              const SizedBox(width: _DS.sp48),
            ],
          ),
        ),
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  final double opacity;
  final VoidCallback onBack;

  const _BackButton({required this.opacity, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onBack,
      icon: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(_DS.sp6),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.45 * (1 - opacity)),
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white.withOpacity(0.15 * (1 - opacity)),
            width: 1,
          ),
        ),
        child: const Icon(Icons.arrow_back_rounded, color: _DS.white, size: 18),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Skeleton Loading & Error (Logika Tidak Diubah)
// ─────────────────────────────────────────────────────────────────────────────
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
                color: _DS.textMuted,
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
        padding: const EdgeInsets.all(_DS.sp32),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(_DS.sp20),
                decoration: BoxDecoration(
                  color: _DS.surface,
                  shape: BoxShape.circle,
                  border: Border.all(color: _DS.divider),
                ),
                child: const Icon(
                  Icons.error_outline,
                  color: _DS.textSecondary,
                  size: 36,
                ),
              ),
              const SizedBox(height: _DS.sp20),
              Text(
                'Something went wrong',
                style: _DS.label(color: _DS.textPrimary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: _DS.sp8),
              Text(
                message,
                style: _DS.body(),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: _DS.sp32),
              Row(
                children: [
                  Expanded(
                    child: _OutlineButton(
                      label: 'Back',
                      onPressed: onBack,
                    ),
                  ),
                  const SizedBox(width: _DS.sp12),
                  Expanded(
                    child: _PrimaryButton(
                      label: 'Retry',
                      onPressed: onRetry,
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

class _OutlineButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _OutlineButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: _DS.textPrimary,
        side: const BorderSide(color: _DS.divider),
        backgroundColor: _DS.surfaceRaised,
        padding: const EdgeInsets.symmetric(
          horizontal: _DS.sp20,
          vertical: _DS.sp16,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_DS.radiusButton),
        ),
      ),
      child: Text(
        label,
        style: _DS.buttonLabel(color: _DS.textPrimary),
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _PrimaryButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: _DS.red,
        foregroundColor: _DS.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(
          horizontal: _DS.sp20,
          vertical: _DS.sp16,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_DS.radiusButton),
        ),
      ),
      child: Text(
        label,
        style: _DS.buttonLabel(color: _DS.white),
      ),
    );
  }
}
