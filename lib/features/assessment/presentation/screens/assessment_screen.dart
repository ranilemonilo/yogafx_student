import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/error/app_exception.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/models/assessment_model.dart';
import '../providers/assessment_provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Design Tokens — identik dengan intro & result screen
// ─────────────────────────────────────────────────────────────────────────────
abstract class _DS {
  // Colors
  static const Color background    = Color(0xFF141110);
  static const Color surface       = Color(0xFF1F1D1C);
  static const Color surfaceRaised = Color(0xFF2A2826);
  static const Color red           = Color(0xFFDB202C);
  static const Color white         = Color(0xFFFFFFFF);
  static const Color textPrimary   = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFA8A8A8);
  static const Color textMuted     = Color(0xFF737373);
  static const Color divider       = Color(0xFF3A3836);

  // Option card states
  static const Color optionDefault  = Color(0xFF1F1D1C); // surface
  static const Color optionSelected = Color(0xFF2A0A0C); // red tint gelap

  // Border-radius
  static const double radiusButton = 4;
  static const double radiusBadge  = 2;
  static const double radiusCard   = 4;
  static const double radiusInput  = 4;

  // Spacing (8px grid)
  static const double sp2  = 2;
  static const double sp4  = 4;
  static const double sp6  = 6;
  static const double sp8  = 8;
  static const double sp10 = 10;
  static const double sp12 = 12;
  static const double sp14 = 14;
  static const double sp16 = 16;
  static const double sp18 = 18;
  static const double sp20 = 20;
  static const double sp22 = 22;
  static const double sp24 = 24;
  static const double sp28 = 28;
  static const double sp32 = 32;
  static const double sp34 = 34;
  static const double sp40 = 40;
  static const double sp48 = 48;

  // Type scale — Montserrat
  static TextStyle caption({Color? color, double? letterSpacing}) => TextStyle(
    fontFamily: 'Montserrat',
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: color ?? textMuted,
    height: 1.5,
    letterSpacing: letterSpacing,
  );

  static TextStyle body({Color? color}) => TextStyle(
    fontFamily: 'Montserrat',
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: color ?? textSecondary,
    height: 1.6,
  );

  static TextStyle label({
    Color? color,
    double? fontSize,
    FontWeight? weight,
    double? letterSpacing,
  }) =>
      TextStyle(
        fontFamily: 'Montserrat',
        fontSize: fontSize ?? 14,
        fontWeight: weight ?? FontWeight.w500,
        color: color ?? textPrimary,
        letterSpacing: letterSpacing,
      );

  static TextStyle labelSmall({Color? color, double? letterSpacing}) => TextStyle(
    fontFamily: 'Montserrat',
    fontSize: 10,
    fontWeight: FontWeight.w700,
    color: color ?? red,
    letterSpacing: letterSpacing ?? 2.0,
    height: 1.2,
  );

  static TextStyle questionText() => const TextStyle(
    fontFamily: 'Montserrat',
    fontSize: 22,
    fontWeight: FontWeight.w800,
    color: textPrimary,
    height: 1.35,
    letterSpacing: -0.4,
  );

  static TextStyle buttonLabel({Color? color}) => TextStyle(
    fontFamily: 'Montserrat',
    fontSize: 15,
    fontWeight: FontWeight.w700,
    color: color ?? Colors.black,
    letterSpacing: 0.2,
  );

  static TextStyle navTitle() => const TextStyle(
    fontFamily: 'Montserrat',
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: textPrimary,
    letterSpacing: -0.2,
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Main Screen — LOGIKA TIDAK DIUBAH
// ─────────────────────────────────────────────────────────────────────────────
class AssessmentScreen extends ConsumerStatefulWidget {
  final int lessonId;
  final int attemptId;

  const AssessmentScreen({
    super.key,
    required this.lessonId,
    required this.attemptId,
  });

  @override
  ConsumerState<AssessmentScreen> createState() => _AssessmentScreenState();
}

class _AssessmentScreenState extends ConsumerState<AssessmentScreen>
    with TickerProviderStateMixin {
  List<int> _selectedOptionIds = [];
  String? _answerText;
  String? _optionFeedbackMessage;
  bool _isOptionAnswerCorrect = false;
  bool _submitting = false;
  bool _processingResult = false;
  int _processingCountdown = 5;
  int? _lastQuestionId;
  Timer? _processingTimer;

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _fadeAnim =
        CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(
        CurvedAnimation(parent: _slideController, curve: Curves.easeOut));

    _fadeController.forward();
    _slideController.forward();
  }

  void _replayEntrance() {
    _fadeController.reset();
    _slideController.reset();
    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _processingTimer?.cancel();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final attemptAsync = ref.watch(assessmentAttemptProvider(
      (lessonId: widget.lessonId, attemptId: widget.attemptId),
    ));

    return Scaffold(
      backgroundColor: _DS.background,
      body: Stack(
        children: [
          attemptAsync.when(
            loading: () => const _NetflixLoader(),
            error: (e, _) => _AttemptError(
              message: e.toString(),
              onBack: () => context.pop(),
              onRetry: () => ref
                  .read(assessmentAttemptProvider(
                (
                lessonId: widget.lessonId,
                attemptId: widget.attemptId
                ),
              ).notifier)
                  .load(),
            ),
            data: (data) {
              if (data == null) return const SizedBox.shrink();

              if (data.mode != 'question') {
                _startResultProcessing(context);
                return const _NetflixLoader();
              }

              if (_lastQuestionId != data.question.id) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (!mounted) return;
                  setState(() {
                    _lastQuestionId = data.question.id;
                    _selectedOptionIds =
                        List.from(data.question.saved.optionIds);
                    _answerText = data.question.saved.answerText;
                    _optionFeedbackMessage = null;
                    _isOptionAnswerCorrect = false;
                    _submitting = false;
                  });
                });
              }

              if (_selectedOptionIds.isEmpty &&
                  data.question.saved.optionIds.isNotEmpty) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  setState(() {
                    _selectedOptionIds =
                        List.from(data.question.saved.optionIds);
                  });
                });
              }

              return SafeArea(
                child: Column(
                  children: [
                    _AssessmentHeader(
                      assessment: data.assessment,
                      canGoBack: false,
                      onBack: () => _handleBack(context),
                      onClose: () => _handleClose(context),
                    ),

                    if (data.assessment.showProgressBar)
                      _NetflixProgressBar(progress: data.assessment.progress),

                    Expanded(
                      child: FadeTransition(
                        opacity: _fadeAnim,
                        child: SlideTransition(
                          position: _slideAnim,
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.fromLTRB(
                              _DS.sp24, _DS.sp32, _DS.sp24, _DS.sp24,
                            ),
                            child: _QuestionBody(
                              question: data.question,
                              selectedOptionIds: _selectedOptionIds,
                              answerText: _answerText,
                              optionFeedbackMessage: _optionFeedbackMessage,
                              onOptionSelected: (optionId) =>
                                  _handleOptionSelected(context, data, optionId),
                              onTextChanged: (text) {
                                setState(() {
                                  _answerText = text;
                                  _optionFeedbackMessage = null;
                                  _isOptionAnswerCorrect = false;
                                });
                              },
                            ),
                          ),
                        ),
                      ),
                    ),

                    _BottomAction(
                      questionType: data.question.questionType,
                      isLastQuestion: data.isLastQuestion,
                      canGoBack: false,
                      submitting: _submitting,
                      hasAnswer: _hasAnswer(data.question),
                      canManuallyProceed:
                      data.question.questionType == 'text'
                          ? _hasAnswer(data.question)
                          : (!data.question.hasCorrectnessGate ||
                          _isOptionAnswerCorrect),
                      isRequired: data.question.required,
                      onPrevious: () {},
                      onSubmit: () => _handleSubmit(context, data),
                    ),
                  ],
                ),
              );
            },
          ),

          if (_processingResult)
            Positioned.fill(
              child: _AssessmentProcessingOverlay(
                countdown: _processingCountdown,
              ),
            ),
        ],
      ),
    );
  }

  // ── SEMUA LOGIKA DI BAWAH INI TIDAK DIUBAH ────────────────────────────────

  void _startResultProcessing(BuildContext context) {
    if (_processingResult) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _processingResult) return;
      setState(() {
        _processingResult = true;
        _processingCountdown = 5;
      });
      _processingTimer?.cancel();
      _processingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (!mounted) {
          timer.cancel();
          return;
        }
        if (_processingCountdown <= 1) {
          timer.cancel();
          context.pushReplacement(
            '/lessons/${widget.lessonId}/assessment/attempts/${widget.attemptId}/result',
          );
          return;
        }
        setState(() => _processingCountdown -= 1);
      });
    });
  }

  bool _hasAnswer(AssessmentQuestion question) {
    if (question.questionType == 'radio_buttons' ||
        question.questionType == 'checkboxes') {
      return _selectedOptionIds.isNotEmpty;
    }
    if (question.questionType == 'text') {
      return _answerText != null && _answerText!.isNotEmpty;
    }
    return true;
  }

  Future<void> _handleOptionSelected(
      BuildContext context,
      AssessmentAttemptData data,
      int optionId,
      ) async {
    if (_submitting) return;

    List<int> nextSelection;
    if (data.question.allowMultiSelect) {
      nextSelection = List<int>.from(_selectedOptionIds);
      if (nextSelection.contains(optionId)) {
        nextSelection.remove(optionId);
      } else {
        nextSelection.add(optionId);
      }
      setState(() {
        _selectedOptionIds = nextSelection;
        _optionFeedbackMessage = null;
        _isOptionAnswerCorrect = false;
      });
      return;
    } else {
      nextSelection = [optionId];
    }

    final selectedOption = data.question.options
        .cast<AssessmentOption?>()
        .firstWhere((o) => o?.id == optionId, orElse: () => null);

    setState(() {
      _selectedOptionIds = nextSelection;
      _isOptionAnswerCorrect = selectedOption?.isCorrect == true;
      _optionFeedbackMessage = selectedOption?.isCorrect == true
          ? 'Answer correct.'
          : 'Oops!!! Wrong Answer! Please refer to your workbook and try again.';
    });
  }

  Future<void> _handleSubmit(
      BuildContext context, AssessmentAttemptData data) async {
    final question = data.question;
    final isRequired = question.required;
    final isOptionQuestion = question.questionType == 'radio_buttons' ||
        question.questionType == 'checkboxes';

    if (isRequired && !_hasAnswer(question)) {
      _showNetflixSnack(
          context, 'Please answer this question before continuing.');
      return;
    }

    if (isOptionQuestion &&
        question.hasCorrectnessGate &&
        !_isOptionAnswerCorrect) {
      return;
    }

    setState(() => _submitting = true);

    try {
      await ref
          .read(assessmentAttemptProvider(
        (lessonId: widget.lessonId, attemptId: widget.attemptId),
      ).notifier)
          .submitAnswer(
        questionId: question.id,
        optionIds:
        _selectedOptionIds.isNotEmpty ? _selectedOptionIds : null,
        answerText: _answerText,
      );

      if (mounted) {
        setState(() {
          _submitting = false;
          _selectedOptionIds = [];
          _answerText = null;
          _optionFeedbackMessage = null;
          _isOptionAnswerCorrect = false;
        });
        _replayEntrance();
      }
    } on AppException catch (e) {
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _isOptionAnswerCorrect = false;
      });
      _showNetflixSnack(context, _resolveAssessmentErrorMessage(e));
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _isOptionAnswerCorrect = false;
      });
      _showNetflixSnack(context, 'Something went wrong. Please try again later.');
    }
  }

  Future<void> _handleBack(BuildContext context) async {
    setState(() => _submitting = true);
    try {
      await ref
          .read(assessmentAttemptProvider(
        (lessonId: widget.lessonId, attemptId: widget.attemptId),
      ).notifier)
          .goBack();
      if (mounted) {
        setState(() {
          _submitting = false;
          _selectedOptionIds = [];
          _answerText = null;
          _optionFeedbackMessage = null;
          _isOptionAnswerCorrect = false;
        });
        _replayEntrance();
      }
    } on AppException catch (e) {
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _optionFeedbackMessage = null;
        _isOptionAnswerCorrect = false;
      });
      _showNetflixSnack(context, _resolveAssessmentErrorMessage(e));
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _optionFeedbackMessage = null;
        _isOptionAnswerCorrect = false;
      });
      _showNetflixSnack(context, 'Something went wrong. Please try again later.');
    }
  }

  String _resolveAssessmentErrorMessage(AppException exception) {
    final errors = exception.errors;
    if (errors != null) {
      for (final value in errors.values) {
        if (value is List && value.isNotEmpty) return value.first.toString();
        if (value is String && value.isNotEmpty) return value;
      }
    }
    return exception.message;
  }

  void _handleClose(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.75),
      builder: (ctx) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
        child: AlertDialog(
          backgroundColor: _DS.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_DS.radiusCard),
            side: BorderSide(color: _DS.divider),
          ),
          titlePadding: const EdgeInsets.fromLTRB(
            _DS.sp24, _DS.sp24, _DS.sp24, _DS.sp8,
          ),
          contentPadding: const EdgeInsets.fromLTRB(
            _DS.sp24, _DS.sp8, _DS.sp24, _DS.sp8,
          ),
          actionsPadding: const EdgeInsets.fromLTRB(
            _DS.sp16, _DS.sp8, _DS.sp16, _DS.sp16,
          ),
          title: Text('Leave assessment?', style: _DS.label(fontSize: 18, weight: FontWeight.w700)),
          content: Text(
            'Your progress will be saved. You can continue later.',
            style: _DS.body(),
          ),
          actions: [
            // Stay — tombol sekunder (outline style)
            OutlinedButton(
              onPressed: () => Navigator.pop(ctx),
              style: OutlinedButton.styleFrom(
                foregroundColor: _DS.textSecondary,
                side: BorderSide(color: _DS.divider),
                padding: const EdgeInsets.symmetric(
                  horizontal: _DS.sp20,
                  vertical: _DS.sp12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(_DS.radiusButton),
                ),
              ),
              child: Text('Stay', style: _DS.label(color: _DS.textSecondary, weight: FontWeight.w600)),
            ),
            // Leave — tombol primer merah
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                context.pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _DS.red,
                foregroundColor: _DS.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: _DS.sp24,
                  vertical: _DS.sp12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(_DS.radiusButton),
                ),
              ),
              child: Text('Leave', style: _DS.buttonLabel(color: _DS.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _showNetflixSnack(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.info_outline, color: _DS.red, size: 16),
            const SizedBox(width: _DS.sp10),
            Expanded(
              child: Text(msg, style: _DS.caption(color: _DS.textPrimary)),
            ),
          ],
        ),
        backgroundColor: _DS.surface,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_DS.radiusCard),
          side: BorderSide(color: _DS.divider),
        ),
        margin: const EdgeInsets.fromLTRB(
          _DS.sp16, 0, _DS.sp16, _DS.sp16,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Netflix Loader — pulsing logo (TIDAK DIUBAH)
// ─────────────────────────────────────────────────────────────────────────────
class _NetflixLoader extends StatefulWidget {
  const _NetflixLoader();

  @override
  State<_NetflixLoader> createState() => _NetflixLoaderState();
}

class _NetflixLoaderState extends State<_NetflixLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _pulse = Tween<double>(begin: 0.4, end: 1.0).animate(
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
    return Center(
      child: FadeTransition(
        opacity: _pulse,
        child: SizedBox(
          width: 220,
          child: Image.network(
            'https://yogafx.b-cdn.net/content/Logo%20YogAFX.png',
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => Icon(
              Icons.image_outlined,
              color: _DS.textMuted,
              size: 56,
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Processing Overlay — countdown di tengah spinner (TIDAK DIUBAH)
// ─────────────────────────────────────────────────────────────────────────────
class _AssessmentProcessingOverlay extends StatelessWidget {
  final int countdown;

  const _AssessmentProcessingOverlay({required this.countdown});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.black.withOpacity(0.82),
      child: Center(
        child: Container(
          width: 280,
          padding: const EdgeInsets.symmetric(
            horizontal: _DS.sp24,
            vertical: _DS.sp28,
          ),
          decoration: BoxDecoration(
            color: _DS.surface,
            borderRadius: BorderRadius.circular(_DS.radiusCard),
            border: Border.all(color: _DS.red.withOpacity(0.28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Spinner + countdown number
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 72,
                    height: 72,
                    child: CircularProgressIndicator(
                      color: _DS.red,
                      strokeWidth: 3,
                    ),
                  ),
                  Text(
                    '$countdown',
                    style: _DS.label(
                      fontSize: 24,
                      weight: FontWeight.w800,
                      color: _DS.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: _DS.sp24),

              // Title
              Text(
                'Processing Your Answers',
                textAlign: TextAlign.center,
                style: _DS.label(
                  fontSize: 16,
                  weight: FontWeight.w800,
                  color: _DS.white,
                ),
              ),
              const SizedBox(height: _DS.sp8),

              // Subtitle
              Text(
                'Please wait a moment...',
                textAlign: TextAlign.center,
                style: _DS.body(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Assessment Header — top bar dengan back/close
// ─────────────────────────────────────────────────────────────────────────────
class _AssessmentHeader extends StatelessWidget {
  final AssessmentPlayInfo assessment;
  final bool canGoBack;
  final VoidCallback onBack;
  final VoidCallback onClose;

  const _AssessmentHeader({
    required this.assessment,
    required this.canGoBack,
    required this.onBack,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: _DS.sp4),
      // Divider bawah tipis — konsisten dengan header DS
      decoration: BoxDecoration(
        color: _DS.background,
        border: Border(bottom: BorderSide(color: _DS.divider, width: 0.5)),
      ),
      child: Row(
        children: [
          // Back button atau placeholder lebar sama
          if (canGoBack)
            _HeaderIconBtn(icon: Icons.arrow_back_ios_new_rounded, onTap: onBack)
          else
            const SizedBox(width: 48),

          // Center: eyebrow label + judul
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'ASSESSMENT',
                  style: _DS.labelSmall(color: _DS.red, letterSpacing: 2.5),
                ),
                const SizedBox(height: _DS.sp2),
                Text(
                  assessment.title,
                  style: _DS.navTitle(),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // Close button
          _HeaderIconBtn(icon: Icons.close_rounded, onTap: onClose),
        ],
      ),
    );
  }
}

class _HeaderIconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _HeaderIconBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(_DS.sp12),
          child: Icon(icon, color: _DS.textPrimary, size: 18),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Progress Bar — segmented, identik dengan video progress indicator DS
// ─────────────────────────────────────────────────────────────────────────────
class _NetflixProgressBar extends StatelessWidget {
  final AssessmentProgress progress;

  const _NetflixProgressBar({required this.progress});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        _DS.sp24, _DS.sp12, _DS.sp24, _DS.sp4,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Segmented progress bar — satu slot per soal
          Row(
            children: List.generate(progress.total, (i) {
              final done = i < progress.current;
              final active = i == progress.current - 1;
              return Expanded(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  height: 3,
                  decoration: BoxDecoration(
                    color: done
                        ? _DS.red
                        : active
                        ? _DS.red.withOpacity(0.4)
                        : _DS.divider,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: _DS.sp8),

          // Counter — caption muted
          Text(
            '${progress.current} / ${progress.total}',
            style: _DS.caption(letterSpacing: 0.5),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Question Body — judul, instruksi, opsi / text field
// ─────────────────────────────────────────────────────────────────────────────
class _QuestionBody extends StatelessWidget {
  final AssessmentQuestion question;
  final List<int> selectedOptionIds;
  final String? answerText;
  final String? optionFeedbackMessage;
  final void Function(int) onOptionSelected;
  final void Function(String) onTextChanged;

  const _QuestionBody({
    required this.question,
    required this.selectedOptionIds,
    required this.answerText,
    required this.optionFeedbackMessage,
    required this.onOptionSelected,
    required this.onTextChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isCorrectFeedback = optionFeedbackMessage == 'Answer correct.';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Eyebrow / question title badge — mengikuti label style DS
        if (question.title.isNotEmpty &&
            question.title != 'Question ${question.id}') ...[
          _QuestionEyebrow(label: question.title),
          const SizedBox(height: _DS.sp12),
        ],

        // ── Question text — Bold Display style
        if (question.questionText.isNotEmpty) ...[
          Text(question.questionText, style: _DS.questionText()),
          const SizedBox(height: _DS.sp8),
        ],

        // ── Instruction — body muted
        if (question.showInstruction && question.instructionText != null) ...[
          Text(question.instructionText!, style: _DS.body()),
          const SizedBox(height: _DS.sp28),
        ] else
          const SizedBox(height: _DS.sp28),

        // ── Options (radio / checkbox)
        if (question.questionType == 'radio_buttons' ||
            question.questionType == 'checkboxes')
          ...question.options.asMap().entries.map(
                (entry) => _AnimatedOptionCard(
              index: entry.key,
              option: entry.value,
              isSelected: selectedOptionIds.contains(entry.value.id),
              isMulti: question.allowMultiSelect,
              onTap: () => onOptionSelected(entry.value.id),
            ),
          ),

        // ── Feedback message (correct / wrong)
        if (optionFeedbackMessage != null &&
            optionFeedbackMessage!.trim().isNotEmpty)
          _FeedbackBanner(
            message: optionFeedbackMessage!,
            isCorrect: isCorrectFeedback,
          )
        // ── Text field
        else if (question.questionType == 'text')
          _NetflixTextField(
            onChanged: onTextChanged,
            characterLimit: question.characterLimit,
          ),
      ],
    );
  }
}

/// Eyebrow badge di atas pertanyaan — pola dari DS label/badge
class _QuestionEyebrow extends StatelessWidget {
  final String label;

  const _QuestionEyebrow({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: _DS.sp10,
        vertical: _DS.sp4,
      ),
      decoration: BoxDecoration(
        color: _DS.red.withOpacity(0.12),
        borderRadius: BorderRadius.circular(_DS.radiusBadge),
        border: Border.all(color: _DS.red.withOpacity(0.3), width: 0.5),
      ),
      child: Text(
        label.toUpperCase(),
        style: _DS.labelSmall(color: _DS.red, letterSpacing: 1.5),
      ),
    );
  }
}

/// Banner feedback — benar (emerald) / salah (merah)
class _FeedbackBanner extends StatelessWidget {
  final String message;
  final bool isCorrect;

  const _FeedbackBanner({required this.message, required this.isCorrect});

  static const Color _emerald = Color(0xFF00B14F);

  @override
  Widget build(BuildContext context) {
    final color = isCorrect ? _emerald : _DS.red;

    return Padding(
      padding: const EdgeInsets.only(top: _DS.sp12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: _DS.sp14,
          vertical: _DS.sp12,
        ),
        decoration: BoxDecoration(
          color: color.withOpacity(0.10),
          borderRadius: BorderRadius.circular(_DS.radiusCard),
          border: Border.all(color: color.withOpacity(0.35)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              isCorrect ? Icons.check_circle_outline : Icons.cancel_outlined,
              color: color,
              size: 16,
            ),
            const SizedBox(width: _DS.sp8),
            Expanded(
              child: Text(
                message,
                style: _DS.caption(color: color.withOpacity(0.9)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Animated Option Card — logika scale & setState TIDAK DIUBAH
// ─────────────────────────────────────────────────────────────────────────────
class _AnimatedOptionCard extends StatefulWidget {
  final int index;
  final AssessmentOption option;
  final bool isSelected;
  final bool isMulti;
  final VoidCallback onTap;

  const _AnimatedOptionCard({
    required this.index,
    required this.option,
    required this.isSelected,
    required this.isMulti,
    required this.onTap,
  });

  @override
  State<_AnimatedOptionCard> createState() => _AnimatedOptionCardState();
}

class _AnimatedOptionCardState extends State<_AnimatedOptionCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleCtrl;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _scaleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.97,
      upperBound: 1.0,
      value: 1.0,
    );
    _scaleAnim = _scaleCtrl;
  }

  @override
  void dispose() {
    _scaleCtrl.dispose();
    super.dispose();
  }

  void _onTapDown(_) => _scaleCtrl.reverse();
  void _onTapUp(_) => _scaleCtrl.forward();
  void _onTapCancel() => _scaleCtrl.forward();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: _DS.sp10),
      child: GestureDetector(
        onTap: widget.onTap,
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        child: ScaleTransition(
          scale: _scaleAnim,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(
              horizontal: _DS.sp16,
              vertical: _DS.sp16,
            ),
            decoration: BoxDecoration(
              // Selected: tint merah gelap | Default: surface
              color: widget.isSelected
                  ? _DS.optionSelected
                  : _DS.optionDefault,
              borderRadius: BorderRadius.circular(_DS.radiusCard),
              border: Border.all(
                color: widget.isSelected ? _DS.red : _DS.divider,
                width: widget.isSelected ? 1.5 : 1.0,
              ),
            ),
            child: Row(
              children: [
                // Checkbox / radio indicator — mengikuti DS checkbox style
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: widget.isMulti
                        ? BoxShape.rectangle
                        : BoxShape.circle,
                    borderRadius:
                    widget.isMulti ? BorderRadius.circular(3) : null,
                    color: widget.isSelected ? _DS.red : Colors.transparent,
                    border: Border.all(
                      color: widget.isSelected ? _DS.red : _DS.textMuted,
                      width: 1.5,
                    ),
                  ),
                  child: widget.isSelected
                      ? const Icon(Icons.check_rounded,
                      color: Colors.white, size: 13)
                      : null,
                ),
                const SizedBox(width: _DS.sp14),

                // Image opsional
                if (widget.option.imageUrl != null) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(_DS.radiusBadge),
                    child: Image.network(
                      widget.option.imageUrl!,
                      width: 48,
                      height: 48,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 48,
                        height: 48,
                        color: _DS.surfaceRaised,
                        alignment: Alignment.center,
                        child: Icon(Icons.image_outlined,
                            color: _DS.textMuted, size: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: _DS.sp12),
                ],

                // Label teks
                Expanded(
                  child: Text(
                    widget.option.label,
                    style: _DS.label(
                      fontSize: 14,
                      weight: widget.isSelected
                          ? FontWeight.w600
                          : FontWeight.w500,
                      color: widget.isSelected
                          ? _DS.textPrimary
                          : _DS.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Text Field — mengikuti input field DS
// Focus: border putih | Default: border divider
// ─────────────────────────────────────────────────────────────────────────────
class _NetflixTextField extends StatefulWidget {
  final void Function(String) onChanged;
  final int? characterLimit;

  const _NetflixTextField({required this.onChanged, this.characterLimit});

  @override
  State<_NetflixTextField> createState() => _NetflixTextFieldState();
}

class _NetflixTextFieldState extends State<_NetflixTextField> {
  final _ctrl = TextEditingController();
  bool _focused = false;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      onFocusChange: (v) => setState(() => _focused = v),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(_DS.radiusInput),
          border: Border.all(
            // Focus: border putih (persis input field DS)
            // Default: border divider gelap
            color: _focused ? _DS.white : _DS.divider,
            width: _focused ? 1.5 : 1.0,
          ),
          color: _DS.surface,
        ),
        child: TextField(
          controller: _ctrl,
          maxLines: 6,
          maxLength: widget.characterLimit,
          onChanged: widget.onChanged,
          style: _DS.body(color: _DS.textPrimary),
          cursorColor: _DS.red,
          decoration: InputDecoration(
            hintText: 'Write your answer here...',
            hintStyle: _DS.body(color: _DS.textMuted),
            counterStyle: _DS.caption(),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.all(_DS.sp16),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Bottom Action — CTA button "Next Question" / "Submit Assessment"
// Logika enabled/disabled TIDAK DIUBAH
// ─────────────────────────────────────────────────────────────────────────────
class _BottomAction extends StatelessWidget {
  final String questionType;
  final bool isLastQuestion;
  final bool canGoBack;
  final bool submitting;
  final bool hasAnswer;
  final bool canManuallyProceed;
  final bool isRequired;
  final VoidCallback onPrevious;
  final VoidCallback onSubmit;

  const _BottomAction({
    required this.questionType,
    required this.isLastQuestion,
    required this.canGoBack,
    required this.submitting,
    required this.hasAnswer,
    required this.canManuallyProceed,
    required this.isRequired,
    required this.onPrevious,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final canProceed = !isRequired || hasAnswer;
    final showManualSubmit =
        questionType == 'text' || canManuallyProceed;
    final isEnabled = !submitting && canProceed && showManualSubmit;

    return Container(
      padding: const EdgeInsets.fromLTRB(
        _DS.sp24, _DS.sp14, _DS.sp24, _DS.sp34,
      ),
      decoration: BoxDecoration(
        color: _DS.background,
        border: Border(top: BorderSide(color: _DS.divider, width: 0.5)),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          onPressed: isEnabled ? onSubmit : null,
          style: ElevatedButton.styleFrom(
            // Enabled aktif: putih (Play button style dari DS)
            // Enabled tapi belum siap / disabled: surfaceRaised
            backgroundColor: isEnabled ? _DS.white : _DS.surfaceRaised,
            disabledBackgroundColor: _DS.surfaceRaised,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(_DS.radiusButton),
            ),
          ),
          child: submitting
              ? SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              color: _DS.background,
              strokeWidth: 2,
            ),
          )
              : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                isLastQuestion ? 'Submit Assessment' : 'Next Question',
                style: _DS.buttonLabel(
                  color: isEnabled ? Colors.black : _DS.textMuted,
                ),
              ),
              if (isEnabled && !isLastQuestion) ...[
                const SizedBox(width: _DS.sp8),
                Icon(Icons.arrow_forward_rounded,
                    color: Colors.black, size: 18),
              ],
              if (isEnabled && isLastQuestion) ...[
                const SizedBox(width: _DS.sp8),
                Icon(Icons.check_circle_outline_rounded,
                    color: Colors.black, size: 18),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Error State — konsisten dengan intro & result screen
// ─────────────────────────────────────────────────────────────────────────────
class _AttemptError extends StatelessWidget {
  final String message;
  final VoidCallback onBack;
  final VoidCallback onRetry;

  const _AttemptError({
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
              // Error icon — konsisten dengan kedua file sebelumnya
              Container(
                padding: const EdgeInsets.all(_DS.sp20),
                decoration: BoxDecoration(
                  color: _DS.surface,
                  shape: BoxShape.circle,
                  border: Border.all(color: _DS.divider),
                ),
                child: Icon(Icons.wifi_off_rounded,
                    color: _DS.textSecondary, size: 32),
              ),
              const SizedBox(height: _DS.sp20),

              Text(
                'Something went wrong',
                style: _DS.label(weight: FontWeight.w700),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: _DS.sp8),

              Text(message, style: _DS.body(), textAlign: TextAlign.center),
              const SizedBox(height: _DS.sp32),

              // Dua tombol sejajar — pola dari intro & result screen
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onBack,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _DS.textSecondary,
                        side: BorderSide(color: _DS.divider),
                        padding: const EdgeInsets.symmetric(
                          horizontal: _DS.sp20,
                          vertical: _DS.sp16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(_DS.radiusButton),
                        ),
                      ),
                      child: Text(
                        'Go Back',
                        style: _DS.label(
                          color: _DS.textSecondary,
                          weight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: _DS.sp12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onRetry,
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
                        'Try Again',
                        style: _DS.buttonLabel(color: _DS.white),
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