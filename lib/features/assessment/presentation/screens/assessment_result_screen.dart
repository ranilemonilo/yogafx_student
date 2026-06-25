import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../lesson/presentation/providers/lesson_provider.dart';
import '../../../lesson/data/models/lesson_model.dart';
import '../../data/models/assessment_model.dart';
import '../providers/assessment_provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Design Tokens — Disinkronkan penuh dengan DESIGN_SYSTEM.md
// ─────────────────────────────────────────────────────────────────────────────
abstract class _DS {
  // Colors (sesuai §1 Warna)
  static const Color background    = Color(0xFF060908); // Neutral / Black 1
  static const Color surface       = Color(0xFF141110); // Neutral / Black 2 — header/footer
  static const Color surfaceRaised = Color(0xFF120F0E); // Neutral / Black 3 — card/panel
  static const Color red           = Color(0xFFDB202C); // Primary / Red
  static const Color emerald       = Color(0xFF00B14F); // Secondary / Emerald
  static const Color white         = Color(0xFFFFFFFF);
  static const Color textPrimary   = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xA6FFFFFF); // rgba(255,255,255,0.65)
  static const Color textMuted     = Color(0x73FFFFFF); // rgba(255,255,255,0.45)
  static const Color divider       = Color(0x1AFFFFFF); // rgba(255,255,255,0.1)

  // Border-radius
  static const double radiusButton = 4;
  static const double radiusBadge  = 2;
  static const double radiusCard   = 4;
  static const double radiusInput  = 4;
  static const double radiusAvatar = 8;
  static const double radiusModal  = 8;

  // Spacing (8px grid)
  static const double sp4  = 4;
  static const double sp6  = 6;
  static const double sp8  = 8;
  static const double sp10 = 10;
  static const double sp12 = 12;
  static const double sp16 = 16;
  static const double sp20 = 20;
  static const double sp24 = 24;
  static const double sp28 = 28;
  static const double sp32 = 32;
  static const double sp40 = 40;
  static const double sp48 = 48;

  // Type scale — Montserrat
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
    color: color ?? textMuted,
    letterSpacing: letterSpacing ?? 1.4,
  );

  static TextStyle title({Color? color}) => TextStyle(
    fontFamily: 'Montserrat',
    fontSize: 24,
    fontWeight: FontWeight.w800,
    color: color ?? textPrimary,
    height: 1.2,
  );

  static TextStyle display({Color? color}) => TextStyle(
    fontFamily: 'Montserrat',
    fontSize: 48,
    fontWeight: FontWeight.w800,
    color: color ?? red,
    height: 1.0,
  );

  static TextStyle displaySub({Color? color}) => TextStyle(
    fontFamily: 'Montserrat',
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: color ?? textMuted,
    height: 1.0,
  );

  static TextStyle buttonLabel({Color? color}) => TextStyle(
    fontFamily: 'Montserrat',
    fontSize: 15,
    fontWeight: FontWeight.w700,
    color: color ?? Colors.black,
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Root Screen — LOGIKA TIDAK DIUBAH
// ─────────────────────────────────────────────────────────────────────────────
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
    final resultAsync = ref.watch(
      assessmentResultProvider((lessonId: lessonId, attemptId: attemptId)),
    );
    final lessonAsync = ref.watch(lessonDetailProvider(lessonId));
    final nextLesson = lessonAsync.valueOrNull?.nextLesson;

    return Scaffold(
      backgroundColor: _DS.background,
      body: SafeArea(
        child: resultAsync.when(
          loading: () => const _ResultLoadingState(),
          error: (error, _) => _ResultErrorState(
            lessonId: lessonId,
            message: error.toString(),
          ),
          data: (result) => _ResultContent(
            lessonId: lessonId,
            attemptId: attemptId,
            status: result.status ?? result.mode,
            scorePercentage: result.scorePercentage,
            correctAnswers: result.correctAnswers,
            totalQuestions: result.totalQuestions,
            nextLesson: nextLesson,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Result Content
// ─────────────────────────────────────────────────────────────────────────────
class _ResultContent extends StatefulWidget {
  final int lessonId;
  final int attemptId;
  final String status;
  final double? scorePercentage;
  final int? correctAnswers;
  final int? totalQuestions;
  final NextLesson? nextLesson;

  const _ResultContent({
    required this.lessonId,
    required this.attemptId,
    required this.status,
    required this.scorePercentage,
    required this.correctAnswers,
    required this.totalQuestions,
    required this.nextLesson,
  });

  @override
  State<_ResultContent> createState() => _ResultContentState();
}

class _ResultContentState extends State<_ResultContent>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _iconFade;
  late final Animation<double> _iconScale;
  late final Animation<double> _textFade;
  late final Animation<Offset> _textSlide;
  late final Animation<double> _buttonsFade;
  late final Animation<Offset> _buttonsSlide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _iconFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.3, curve: Curves.easeOut),
    );
    _iconScale = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.55, curve: Curves.elasticOut),
    );
    _textFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.35, 0.7, curve: Curves.easeOut),
    );
    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.35, 0.7, curve: Curves.easeOutCubic),
      ),
    );
    _buttonsFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.55, 1.0, curve: Curves.easeOut),
    );
    _buttonsSlide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.55, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isCompleted =
        widget.status == 'completed' || widget.status == 'result';
    final score = widget.scorePercentage;
    final scoreValue = score == null ? '--' : score.toStringAsFixed(0);
    final correctnessLabel = score == null
        ? null
        : '${score.toStringAsFixed(0)}% correct';
    final summary =
    widget.correctAnswers != null && widget.totalQuestions != null
        ? '${widget.correctAnswers} of ${widget.totalQuestions} answers correct'
        : 'Your answers have been processed successfully.';

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal: _DS.sp24,
        vertical: _DS.sp40,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FadeTransition(
            opacity: _iconFade,
            child: ScaleTransition(
              scale: _iconScale,
              child: _ResultBadge(isCompleted: isCompleted),
            ),
          ),
          const SizedBox(height: _DS.sp28),

          FadeTransition(
            opacity: _textFade,
            child: SlideTransition(
              position: _textSlide,
              child: Column(
                children: [
                  Text(
                    isCompleted
                        ? 'Assessment Complete'
                        : 'Assessment In Progress',
                    style: _DS.title(),
                    textAlign: TextAlign.center,
                  ),

                  if (isCompleted && correctnessLabel != null) ...[
                    const SizedBox(height: _DS.sp8),
                    Text(
                      correctnessLabel,
                      style: _DS.labelSmall(
                        color: _DS.red,
                        letterSpacing: 0.8,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],

                  const SizedBox(height: _DS.sp24),

                  _ScoreCard(
                    scoreValue: scoreValue,
                    isCompleted: isCompleted,
                  ),

                  const SizedBox(height: _DS.sp20),

                  Text(
                    summary,
                    style: _DS.body(),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: _DS.sp40),

          FadeTransition(
            opacity: _buttonsFade,
            child: SlideTransition(
              position: _buttonsSlide,
              child: _ActionButtons(
                lessonId: widget.lessonId,
                nextLesson: widget.nextLesson,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Score Card
// ─────────────────────────────────────────────────────────────────────────────
class _ScoreCard extends StatelessWidget {
  final String scoreValue;
  final bool isCompleted;

  const _ScoreCard({
    required this.scoreValue,
    required this.isCompleted,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        vertical: _DS.sp24,
        horizontal: _DS.sp24,
      ),
      decoration: BoxDecoration(
        color: _DS.surface,
        borderRadius: BorderRadius.circular(_DS.radiusModal), // panel → 8px
        border: Border.all(
          color: isCompleted
              ? _DS.red.withOpacity(0.35)
              : _DS.divider,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'TOTAL SCORE',
            style: _DS.labelSmall(
              color: _DS.textMuted,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: _DS.sp12),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(scoreValue, style: _DS.display()),
              Text(' / 100', style: _DS.displaySub()),
            ],
          ),

          const SizedBox(height: _DS.sp16),
          Container(height: 1, color: _DS.divider),
          const SizedBox(height: _DS.sp16),

          _StatusBadge(isCompleted: isCompleted),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final bool isCompleted;

  const _StatusBadge({required this.isCompleted});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: _DS.sp10,
        vertical: _DS.sp4,
      ),
      decoration: BoxDecoration(
        color: isCompleted
            ? _DS.emerald.withOpacity(0.12)
            : _DS.surfaceRaised,
        borderRadius: BorderRadius.circular(_DS.radiusBadge),
        border: Border.all(
          color: isCompleted
              ? _DS.emerald.withOpacity(0.4)
              : _DS.divider,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isCompleted
                ? Icons.check_circle_outline
                : Icons.hourglass_top_rounded,
            size: 12,
            color: isCompleted ? _DS.emerald : _DS.textMuted,
          ),
          const SizedBox(width: _DS.sp6),
          Text(
            isCompleted ? 'Completed' : 'In Progress',
            style: _DS.caption(
              color: isCompleted ? _DS.emerald : _DS.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Result Badge
// ─────────────────────────────────────────────────────────────────────────────
class _ResultBadge extends StatelessWidget {
  final bool isCompleted;

  const _ResultBadge({required this.isCompleted});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 96,
      height: 96,
      decoration: BoxDecoration(
        color: isCompleted
            ? _DS.emerald.withOpacity(0.15)
            : _DS.surfaceRaised,
        shape: BoxShape.circle,
        border: Border.all(
          color: isCompleted ? _DS.emerald : _DS.divider,
          width: 1.5,
        ),
      ),
      child: Icon(
        isCompleted ? Icons.check_rounded : Icons.hourglass_top_rounded,
        color: isCompleted ? _DS.emerald : _DS.textMuted,
        size: 44,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Action Buttons
// ─────────────────────────────────────────────────────────────────────────────
class _ActionButtons extends StatelessWidget {
  final int lessonId;
  final NextLesson? nextLesson;

  const _ActionButtons({
    required this.lessonId,
    required this.nextLesson,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _ResultButton(
          label: 'Back to Lesson',
          icon: Icons.arrow_back_rounded,
          style: _ButtonStyle.primary,
          onTap: () => context.go('/lessons/$lessonId'),
        ),

        if (nextLesson != null && nextLesson!.isUnlocked) ...[
          const SizedBox(height: _DS.sp12),
          _ResultButton(
            label: 'Next Lesson',
            icon: Icons.play_arrow_rounded,
            style: _ButtonStyle.primary,
            onTap: () => context.go('/lessons/${nextLesson!.id}'),
          ),
        ],

        const SizedBox(height: _DS.sp12),

        _ResultButton(
          label: 'Browse Modules',
          icon: Icons.apps_rounded,
          style: _ButtonStyle.secondary,
          onTap: () => context.go('/modules'),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Result Button
// ─────────────────────────────────────────────────────────────────────────────
enum _ButtonStyle { primary, secondary }

class _ResultButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final _ButtonStyle style;
  final VoidCallback onTap;

  const _ResultButton({
    required this.label,
    required this.icon,
    required this.style,
    required this.onTap,
  });

  @override
  State<_ResultButton> createState() => _ResultButtonState();
}

class _ResultButtonState extends State<_ResultButton> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed != value) setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final isPrimary = widget.style == _ButtonStyle.primary;

    return GestureDetector(
      onTapDown: (_) => _setPressed(true),
      onTapCancel: () => _setPressed(false),
      onTapUp: (_) => _setPressed(false),
      onTap: widget.onTap,
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
            color: isPrimary
                ? (_pressed ? const Color(0xFFE0E0E0) : _DS.white)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(_DS.radiusButton),
            border: isPrimary
                ? null
                : Border.all(color: _DS.divider),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                widget.icon,
                size: 20,
                color: isPrimary ? Colors.black : _DS.textPrimary,
              ),
              const SizedBox(width: _DS.sp8),
              Text(
                widget.label,
                style: isPrimary
                    ? _DS.buttonLabel(color: Colors.black)
                    : _DS.buttonLabel(color: _DS.textPrimary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Loading State
// ─────────────────────────────────────────────────────────────────────────────
class _ResultLoadingState extends StatelessWidget {
  const _ResultLoadingState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(
        color: _DS.red,
        strokeWidth: 2,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Error State
// ─────────────────────────────────────────────────────────────────────────────
class _ResultErrorState extends StatelessWidget {
  final int lessonId;
  final String message;

  const _ResultErrorState({
    required this.lessonId,
    required this.message,
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
            children: [
              Container(
                padding: const EdgeInsets.all(_DS.sp20),
                decoration: BoxDecoration(
                  color: _DS.surface,
                  shape: BoxShape.circle,
                  border: Border.all(color: _DS.divider),
                ),
                child: const Icon(
                  Icons.error_outline_rounded,
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

              _ResultButton(
                label: 'Back to Lesson',
                icon: Icons.arrow_back_rounded,
                style: _ButtonStyle.primary,
                onTap: () => context.go('/lessons/$lessonId'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}