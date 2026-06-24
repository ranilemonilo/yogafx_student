import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../lesson/presentation/providers/lesson_provider.dart';
import '../../../lesson/data/models/lesson_model.dart';
import '../../data/models/assessment_model.dart';
import '../providers/assessment_provider.dart';

/// Netflix-inspired palette, scoped to this screen only so the rest of the
/// app's shared theme (AppColors) stays untouched. Kept in sync with the
/// palette used in assessment_intro_screen.dart.
abstract class _NetflixPalette {
  static const Color background = Color(0xFF141414);
  static const Color surface = Color(0xFF1F1F1F);
  static const Color surfaceRaised = Color(0xFF2A2A2A);
  static const Color red = Color(0xFFE50914);
  static const Color green = Color(0xFF46D369); // BARU
  static const Color grey = Color(0xFFB3B3B3);
  static const Color greyMuted = Color(0xFF808080);
  static const Color divider = Color(0xFF3A3A3A);
}

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
      backgroundColor: _NetflixPalette.background,
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
    final isCompleted = widget.status == 'completed' || widget.status == 'result';
    final score = widget.scorePercentage;
    
    // Format skor untuk UI baru (hanya angka tanpa tanda %)
    final scoreValue = score == null ? '--' : score.toStringAsFixed(0);
    
    final correctnessLabel = score == null
        ? null
        : '${score.toStringAsFixed(0)}% correct';
    final summary = widget.correctAnswers != null && widget.totalQuestions != null
        ? '${widget.correctAnswers} of ${widget.totalQuestions} answers correct'
        : 'Your answers have been processed successfully.';

    return Padding(
      padding: const EdgeInsets.all(32),
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
          const SizedBox(height: 28),
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
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      fontFamily: 'Montserrat',
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (isCompleted && correctnessLabel != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      correctnessLabel,
                      style: const TextStyle(
                        color: _NetflixPalette.red,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Montserrat',
                        letterSpacing: 0.3,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  
                  // PERUBAHAN: Desain UI Kotak Skor Baru
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: _NetflixPalette.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: _NetflixPalette.red.withOpacity(0.3),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: _NetflixPalette.red.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'TOTAL SCORE',
                          style: TextStyle(
                            color: _NetflixPalette.grey,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Montserrat',
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              scoreValue,
                              style: const TextStyle(
                                color: _NetflixPalette.red,
                                fontSize: 48,
                                fontWeight: FontWeight.w800,
                                fontFamily: 'Montserrat',
                              ),
                            ),
                            const Text(
                              ' / 100',
                              style: TextStyle(
                                color: _NetflixPalette.greyMuted,
                                fontSize: 24,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Montserrat',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  Text(
                    summary,
                    style: const TextStyle(
                      color: _NetflixPalette.grey,
                      fontSize: 14,
                      fontFamily: 'Montserrat',
                      height: 1.6,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 48),
          FadeTransition(
            opacity: _buttonsFade,
            child: SlideTransition(
              position: _buttonsSlide,
              child: Column(
                children: [
                  _ResultButton(
                    label: 'Back to Lesson',
                    icon: Icons.arrow_back_rounded,
                    filled: true,
                    onTap: () => context.go('/lessons/${widget.lessonId}'),
                  ),
                  if (widget.nextLesson != null && widget.nextLesson!.isUnlocked) ...[
                    const SizedBox(height: 12),
                    _ResultButton(
                      label: 'Next Lesson',
                      icon: Icons.play_arrow_rounded,
                      filled: true,
                      onTap: () => context.go('/lessons/${widget.nextLesson!.id}'),
                    ),
                  ],
                  const SizedBox(height: 12),
                  _ResultButton(
                    label: 'Browse Modules',
                    icon: Icons.apps_rounded,
                    filled: false,
                    onTap: () => context.go('/modules'),
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

class _ResultLoadingState extends StatelessWidget {
  const _ResultLoadingState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(color: _NetflixPalette.red),
    );
  }
}

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
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded,
                color: _NetflixPalette.red, size: 42),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontFamily: 'Montserrat',
              ),
            ),
            const SizedBox(height: 20),
            _ResultButton(
              label: 'Back to Lesson',
              icon: Icons.arrow_back_rounded,
              filled: true,
              onTap: () => context.go('/lessons/$lessonId'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultBadge extends StatelessWidget {
  final bool isCompleted;

  const _ResultBadge({required this.isCompleted});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 104,
      height: 104,
      decoration: BoxDecoration(
        color: isCompleted ? _NetflixPalette.green : _NetflixPalette.surfaceRaised, // diubah dari .red
        shape: BoxShape.circle,
        border: isCompleted
            ? null
            : Border.all(color: _NetflixPalette.divider, width: 1.5),
      ),
      child: Icon(
        isCompleted ? Icons.check_rounded : Icons.hourglass_top_rounded,
        color: isCompleted ? Colors.white : _NetflixPalette.grey,
        size: 50,
      ),
    );
  }
}

class _ResultButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final bool filled;
  final VoidCallback onTap;

  const _ResultButton({
    required this.label,
    required this.icon,
    required this.filled,
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
    final filled = widget.filled;

    return GestureDetector(
      onTapDown: (_) => _setPressed(true),
      onTapCancel: () => _setPressed(false),
      onTapUp: (_) => _setPressed(false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: Container(
          width: double.infinity,
          height: 52,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: filled ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(4),
            border: filled
                ? null
                : Border.all(color: _NetflixPalette.divider, width: 1),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                widget.icon,
                size: 20,
                color: filled ? Colors.black : Colors.white,
              ),
              const SizedBox(width: 8),
              Text(
                widget.label,
                style: TextStyle(
                  color: filled ? Colors.black : Colors.white,
                  fontSize: 15,
                  fontWeight: filled ? FontWeight.w700 : FontWeight.w600,
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