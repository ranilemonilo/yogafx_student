import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/error/app_exception.dart';
// import '../../../../core/theme/app_theme.dart'; // Digantikan oleh design system _DS di bawah
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
  static const double radiusModal  = 8; // Digunakan untuk dialog & overlay
}

// ─── Main Screen ──────────────────────────────────────────────────────────────

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
    _fadeAnim = CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));

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
                (lessonId: widget.lessonId, attemptId: widget.attemptId),
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
                    _selectedOptionIds = List.from(data.question.saved.optionIds);
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
                            padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
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
                      canManuallyProceed: data.question.questionType == 'text'
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
        setState(() {
          _processingCountdown -= 1;
        });
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
        .firstWhere((option) => option?.id == optionId, orElse: () => null);

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
      _showNetflixSnack(context, 'Please answer this question before continuing.');
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
        optionIds: _selectedOptionIds.isNotEmpty ? _selectedOptionIds : null,
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
      _showNetflixSnack(
        context,
        'Something went wrong. Please try again later.',
      );
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
      _showNetflixSnack(
        context,
        'Something went wrong. Please try again later.',
      );
    }
  }

  String _resolveAssessmentErrorMessage(AppException exception) {
    final errors = exception.errors;
    if (errors != null) {
      for (final value in errors.values) {
        if (value is List && value.isNotEmpty) {
          return value.first.toString();
        }
        if (value is String && value.isNotEmpty) {
          return value;
        }
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
              borderRadius: BorderRadius.circular(_DS.radiusModal)),
          title: const Text(
            'Leave assessment?',
            style: TextStyle(
              color: _DS.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w700,
              fontFamily: 'Montserrat',
              letterSpacing: -0.3,
            ),
          ),
          content: const Text(
            'Your progress will be saved. You can continue later.',
            style: TextStyle(
              color: _DS.textSecondary,
              fontSize: 14,
              fontFamily: 'Montserrat',
              height: 1.6,
            ),
          ),
          actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              child: const Text(
                'Stay',
                style: TextStyle(
                  color: _DS.textSecondary,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                context.pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _DS.red,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(_DS.radiusButton)),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text(
                'Leave',
                style: TextStyle(
                  color: _DS.white,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Montserrat',
                ),
              ),
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
            const Icon(Icons.info_outline, color: _DS.red, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                msg,
                style: const TextStyle(
                  color: _DS.textPrimary,
                  fontFamily: 'Montserrat',
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: _DS.surfaceRaised,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_DS.radiusModal)),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      ),
    );
  }
}

// ─── Netflix Loader ───────────────────────────────────────────────────────────

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
    _pulse = Tween<double>(begin: 0.4, end: 1.0).animate(CurvedAnimation(
      parent: _ctrl,
      curve: Curves.easeInOut,
    ));
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

// ─── Header & Overlay ─────────────────────────────────────────────────────────

class _AssessmentProcessingOverlay extends StatelessWidget {
  final int countdown;

  const _AssessmentProcessingOverlay({
    required this.countdown,
  });

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.black.withOpacity(0.82),
      child: Center(
        child: Container(
          width: 280,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
          decoration: BoxDecoration(
            color: _DS.surface,
            borderRadius: BorderRadius.circular(_DS.radiusModal),
            border: Border.all(
              color: _DS.red.withOpacity(0.28),
            ),
            // Penambahan Shadow Modal/Panel sesuai design system
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.9),
                blurRadius: 40,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  const SizedBox(
                    width: 76,
                    height: 76,
                    child: CircularProgressIndicator(
                      color: _DS.red,
                      strokeWidth: 4.5,
                    ),
                  ),
                  Text(
                    '$countdown',
                    style: const TextStyle(
                      color: _DS.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      fontFamily: 'Montserrat',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                'Processing Your Answers',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _DS.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  fontFamily: 'Montserrat',
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Please wait a moment...',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _DS.textSecondary,
                  fontSize: 13,
                  fontFamily: 'Montserrat',
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

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
      padding: const EdgeInsets.fromLTRB(4, 8, 4, 8),
      child: Row(
        children: [
          if (canGoBack)
            _HeaderIconBtn(
              icon: Icons.arrow_back_ios_new_rounded,
              onTap: onBack,
            )
          else
            const SizedBox(width: 48),

          Expanded(
            child: Column(
              children: [
                const Text(
                  'ASSESSMENT',
                  style: TextStyle(
                    color: _DS.red,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Montserrat',
                    letterSpacing: 2.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  assessment.title,
                  style: const TextStyle(
                    color: _DS.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Montserrat',
                    letterSpacing: -0.2,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          _HeaderIconBtn(
            icon: Icons.close_rounded,
            onTap: onClose,
          ),
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
          padding: const EdgeInsets.all(12),
          child: Icon(icon, color: _DS.textPrimary, size: 18),
        ),
      ),
    );
  }
}

// ─── Netflix Progress Bar ─────────────────────────────────────────────────────

class _NetflixProgressBar extends StatelessWidget {
  final AssessmentProgress progress;

  const _NetflixProgressBar({required this.progress});

  @override
  Widget build(BuildContext context) {
    final frac = progress.current / progress.total;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                        ? _DS.red.withOpacity(0.5)
                        : _DS.divider,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 8),
          Text(
            '${progress.current} / ${progress.total}',
            style: const TextStyle(
              color: _DS.textMuted,
              fontSize: 11,
              fontFamily: 'Montserrat',
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Question Body ────────────────────────────────────────────────────────────

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
        if (question.title.isNotEmpty &&
            question.title != 'Question ${question.id}')
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: _DS.red.withOpacity(0.15),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                  color: _DS.red.withOpacity(0.3), width: 0.5),
            ),
            child: Text(
              question.title.toUpperCase(),
              style: const TextStyle(
                color: _DS.red,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                fontFamily: 'Montserrat',
                letterSpacing: 1.5,
              ),
            ),
          ),

        if (question.questionText.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              question.questionText,
              style: const TextStyle(
                color: _DS.textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.w800,
                fontFamily: 'Montserrat',
                height: 1.35,
                letterSpacing: -0.5,
              ),
            ),
          ),

        if (question.showInstruction && question.instructionText != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: Text(
              question.instructionText!,
              style: TextStyle(
                color: _DS.textSecondary.withOpacity(0.8),
                fontSize: 13,
                fontFamily: 'Montserrat',
                height: 1.6,
              ),
            ),
          )
        else
          const SizedBox(height: 28),

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
        if (optionFeedbackMessage != null &&
            optionFeedbackMessage!.trim().isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 2, right: 2),
            child: Text(
              optionFeedbackMessage!,
              style: TextStyle(
                color: isCorrectFeedback ? _DS.emerald : _DS.red,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                fontFamily: 'Montserrat',
                height: 1.5,
              ),
            ),
          )
        else if (question.questionType == 'text')
          _NetflixTextField(
            onChanged: onTextChanged,
            characterLimit: question.characterLimit,
          ),
      ],
    );
  }
}

// ─── Animated Option Card ─────────────────────────────────────────────────────

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
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: widget.onTap,
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        child: ScaleTransition(
          scale: _scaleAnim,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            decoration: BoxDecoration(
              color: widget.isSelected
                  ? _DS.red.withOpacity(0.12)
                  : _DS.surface,
              borderRadius: BorderRadius.circular(_DS.radiusCard),
              border: Border.all(
                color: widget.isSelected
                    ? _DS.red
                    : _DS.divider,
                width: widget.isSelected ? 1.5 : 1.0,
              ),
              boxShadow: widget.isSelected
                  ? [
                BoxShadow(
                  color: _DS.red.withOpacity(0.18),
                  blurRadius: 12,
                  offset: const Offset(0, 2),
                ),
              ]
                  : [],
            ),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    shape: widget.isMulti ? BoxShape.rectangle : BoxShape.circle,
                    borderRadius: widget.isMulti ? BorderRadius.circular(4) : null,
                    color: widget.isSelected
                        ? _DS.red
                        : Colors.transparent,
                    border: Border.all(
                      color: widget.isSelected ? _DS.red : _DS.textMuted,
                      width: 1.5,
                    ),
                  ),
                  child: widget.isSelected
                      ? const Icon(Icons.check_rounded,
                      color: Colors.white, size: 14)
                      : null,
                ),
                const SizedBox(width: 16),

                if (widget.option.imageUrl != null) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Image.network(
                      widget.option.imageUrl!,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 50,
                        height: 50,
                        color: _DS.surfaceRaised,
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.image_outlined,
                          color: Colors.white70,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                ],

                Expanded(
                  child: Text(
                    widget.option.label,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: widget.isSelected
                          ? FontWeight.w600
                          : FontWeight.w500,
                      fontFamily: 'Montserrat',
                      height: 1.4,
                    ),
                  ),
                ),

                if (widget.isSelected)
                  Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Icon(
                      Icons.circle,
                      color: _DS.red.withOpacity(0.7),
                      size: 7,
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

// ─── Netflix Text Field ───────────────────────────────────────────────────────

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
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(_DS.radiusInput),
          border: Border.all(
            color: _focused ? _DS.red : _DS.divider,
            width: _focused ? 1.5 : 1.0,
          ),
          color: _DS.surfaceRaised,
          boxShadow: _focused
              ? [
            BoxShadow(
              color: _DS.red.withOpacity(0.12),
              blurRadius: 12,
              offset: const Offset(0, 2),
            ),
          ]
              : [],
        ),
        child: TextField(
          controller: _ctrl,
          maxLines: 6,
          maxLength: widget.characterLimit,
          onChanged: widget.onChanged,
          style: const TextStyle(
            color: _DS.textPrimary,
            fontFamily: 'Montserrat',
            fontSize: 14,
            height: 1.6,
          ),
          decoration: InputDecoration(
            hintText: 'Write your answer here...',
            hintStyle: TextStyle(
              color: _DS.textMuted.withOpacity(0.6),
              fontFamily: 'Montserrat',
              fontSize: 14,
            ),
            counterStyle: const TextStyle(
              color: _DS.textMuted,
              fontFamily: 'Montserrat',
              fontSize: 11,
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
      ),
    );
  }
}

// ─── Bottom Action ────────────────────────────────────────────────────────────

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
    final showManualSubmit = questionType == 'text' || canManuallyProceed;
    final isEnabled = !submitting && canProceed && showManualSubmit;

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 14, 24, 34),
      decoration: const BoxDecoration(
        color: _DS.background,
        border: Border(
          top: BorderSide(
            color: _DS.divider,
            width: 0.5,
          ),
        ),
      ),
      child: Center(
        child: SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton(
            onPressed: isEnabled ? onSubmit : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: canProceed && showManualSubmit
                  ? _DS.red
                  : _DS.surfaceRaised,
              disabledBackgroundColor: _DS.surfaceRaised,
              elevation: canProceed ? 4 : 0,
              shadowColor: _DS.red.withOpacity(0.4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(_DS.radiusButton),
              ),
            ),
            child: submitting
                ? const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2.5,
              ),
            )
                : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  isLastQuestion
                      ? 'Submit Assessment'
                      : 'Next Question',
                  style: TextStyle(
                    color: canProceed
                        ? Colors.white
                        : _DS.textMuted,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Montserrat',
                    letterSpacing: 0.2,
                  ),
                ),
                if (canProceed && !isLastQuestion) ...[
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.arrow_forward_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ],
                if (canProceed && isLastQuestion) ...[
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.check_circle_outline_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Error State ──────────────────────────────────────────────────────────────

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
        padding: const EdgeInsets.all(40),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: _DS.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(32),
                ),
                child: const Icon(
                  Icons.wifi_off_rounded,
                  color: _DS.red,
                  size: 28,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Something went wrong',
                style: TextStyle(
                  color: _DS.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Montserrat',
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                style: const TextStyle(
                  color: _DS.textSecondary,
                  fontSize: 13,
                  fontFamily: 'Montserrat',
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 12,
                runSpacing: 12,
                children: [
                  OutlinedButton(
                    onPressed: onBack,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _DS.textSecondary,
                      side: const BorderSide(color: _DS.divider),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(_DS.radiusButton),
                      ),
                    ),
                    child: const Text(
                      'Go Back',
                      style: TextStyle(fontFamily: 'Montserrat'),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: onRetry,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _DS.red,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 28,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(_DS.radiusButton),
                      ),
                    ),
                    child: const Text(
                      'Try Again',
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w700,
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