import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/models/assessment_model.dart';
import '../providers/assessment_provider.dart';

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
  bool _submitting = false;

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
      backgroundColor: AppColors.background,
      body: attemptAsync.when(
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
            WidgetsBinding.instance.addPostFrameCallback((_) {
              context.pushReplacement(
                '/lessons/${widget.lessonId}/assessment/attempts/${widget.attemptId}/result',
              );
            });
            return const _NetflixLoader();
          }

          final assessment = data.assessment;
          final question = data.question;
          if (assessment == null || question == null) {
            return _AttemptError(
              message: 'Assessment data is incomplete.',
              onBack: () => context.pop(),
              onRetry: () => ref
                  .read(assessmentAttemptProvider(
                (lessonId: widget.lessonId, attemptId: widget.attemptId),
              ).notifier)
                  .load(),
            );
          }

          if (_selectedOptionIds.isEmpty &&
              question.saved.optionIds.isNotEmpty) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              setState(() {
                _selectedOptionIds = List.from(question.saved.optionIds);
              });
            });
          }

          if ((_answerText == null || _answerText!.isEmpty) &&
              question.saved.answerText != null &&
              question.saved.answerText!.isNotEmpty) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              setState(() {
                _answerText = question.saved.answerText;
              });
            });
          }

          return SafeArea(
            child: Column(
              children: [
                // Header
                _AssessmentHeader(
                  assessment: assessment,
                  canGoBack: data.canGoBack,
                  onBack: () => _handleBack(context),
                  onClose: () => _handleClose(context),
                ),

                // Slim progress bar
                if (assessment.showProgressBar)
                  _NetflixProgressBar(progress: assessment.progress),

                // Question content — animated
                Expanded(
                  child: FadeTransition(
                    opacity: _fadeAnim,
                    child: SlideTransition(
                      position: _slideAnim,
                      child: SingleChildScrollView(
                        padding:
                        const EdgeInsets.fromLTRB(24, 32, 24, 24),
                        child: _QuestionBody(
                          question: question,
                          selectedOptionIds: _selectedOptionIds,
                          answerText: _answerText,
                          onOptionSelected: (optionId) {
                            setState(() {
                              if (question.allowMultiSelect) {
                                if (_selectedOptionIds.contains(optionId)) {
                                  _selectedOptionIds.remove(optionId);
                                } else {
                                  _selectedOptionIds.add(optionId);
                                }
                              } else {
                                _selectedOptionIds = [optionId];
                              }
                            });
                          },
                          onTextChanged: (text) {
                            setState(() => _answerText = text);
                          },
                        ),
                      ),
                    ),
                  ),
                ),

                // Bottom CTA
                _BottomAction(
                  isLastQuestion: data.isLastQuestion,
                  submitting: _submitting,
                  hasAnswer: _hasAnswer(question),
                  isRequired: question.required,
                  isCorrectnessGateBlocked: _isCorrectnessGateBlocked(question),
                  onSubmit: () => _handleSubmit(context, data),
                ),
              ],
            ),
          );
        },
      ),
    );
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

  bool _isCorrectnessGateBlocked(AssessmentQuestion question) {
    if (!question.hasCorrectnessGate) return false;
    if (question.questionType != 'radio_buttons' &&
        question.questionType != 'checkboxes') {
      return false;
    }

    final correctOptionIds = question.options
        .where((option) => option.isCorrect)
        .map((option) => option.id)
        .toSet();

    if (correctOptionIds.isEmpty || _selectedOptionIds.isEmpty) {
      return false;
    }

    return !setEquals(_selectedOptionIds.toSet(), correctOptionIds);
  }

  Future<void> _handleSubmit(
      BuildContext context, AssessmentAttemptData data) async {
    final question = data.question;
    if (question == null) {
      _showNetflixSnack(context, 'Assessment question is unavailable.');
      return;
    }
    final isRequired = question.required;

    if (isRequired && !_hasAnswer(question)) {
      _showNetflixSnack(context, 'Please answer this question before continuing.');
      return;
    }

    if (_isCorrectnessGateBlocked(question)) {
      _showNetflixSnack(
        context,
        'Choose the correct answer before continuing.',
      );
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
        });
        _replayEntrance();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _submitting = false);
        _showNetflixSnack(context, e.toString());
      }
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
        });
        _replayEntrance();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _submitting = false);
        _showNetflixSnack(context, e.toString());
      }
    }
  }

  void _handleClose(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.75),
      builder: (ctx) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
        child: AlertDialog(
          backgroundColor: const Color(0xFF1F1F1F),
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: const Text(
            'Leave assessment?',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w700,
              fontFamily: 'Montserrat',
              letterSpacing: -0.3,
            ),
          ),
          content: const Text(
            'Your progress will be saved. You can continue later.',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
              fontFamily: 'Montserrat',
              height: 1.6,
            ),
          ),
          actionsPadding:
          const EdgeInsets.fromLTRB(16, 0, 16, 16),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              style: TextButton.styleFrom(
                padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              child: const Text(
                'Stay',
                style: TextStyle(
                  color: AppColors.textSecondary,
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
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4)),
                padding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text(
                'Leave',
                style: TextStyle(
                  color: Colors.white,
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
            const Icon(Icons.info_outline, color: AppColors.primary, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                msg,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontFamily: 'Montserrat',
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF1F1F1F),
        behavior: SnackBarBehavior.floating,
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
    _pulse =
        Tween<double>(begin: 0.4, end: 1.0).animate(CurvedAnimation(
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
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(4),
          ),
          child: const Center(
            child: Text(
              'N',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w900,
                fontFamily: 'Montserrat',
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Header ───────────────────────────────────────────────────────────────────

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
          // Back button or spacer
          if (canGoBack)
            _HeaderIconBtn(
              icon: Icons.arrow_back_ios_new_rounded,
              onTap: onBack,
            )
          else
            const SizedBox(width: 48),

          // Title
          Expanded(
            child: Column(
              children: [
                // Red "ASSESSMENT" eyebrow label
                const Text(
                  'ASSESSMENT',
                  style: TextStyle(
                    color: AppColors.primary,
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
                    color: AppColors.textPrimary,
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

          // Close button
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
          child: Icon(icon, color: AppColors.textPrimary, size: 18),
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
          // Step dots
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
                        ? AppColors.primary
                        : active
                        ? AppColors.primary.withOpacity(0.5)
                        : AppColors.divider,
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
              color: AppColors.textMuted,
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
  final void Function(int) onOptionSelected;
  final void Function(String) onTextChanged;

  const _QuestionBody({
    required this.question,
    required this.selectedOptionIds,
    required this.answerText,
    required this.onOptionSelected,
    required this.onTextChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Question type badge
        if (question.title.isNotEmpty &&
            question.title != 'Question ${question.id}')
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                  color: AppColors.primary.withOpacity(0.3), width: 0.5),
            ),
            child: Text(
              question.title.toUpperCase(),
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                fontFamily: 'Montserrat',
                letterSpacing: 1.5,
              ),
            ),
          ),

        // Question text — big, bold, Netflix-feel
        if (question.questionText.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              question.questionText,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.w800,
                fontFamily: 'Montserrat',
                height: 1.35,
                letterSpacing: -0.5,
              ),
            ),
          ),

        // Instruction
        if (question.showInstruction && question.instructionText != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: Text(
              question.instructionText!,
              style: TextStyle(
                color: AppColors.textSecondary.withOpacity(0.8),
                fontSize: 13,
                fontFamily: 'Montserrat',
                height: 1.6,
              ),
            ),
          )
        else
          const SizedBox(height: 28),

        // Options
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
          )
        else if (question.questionType == 'text')
          _NetflixTextField(
            initialValue: answerText,
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
            padding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            decoration: BoxDecoration(
              color: widget.isSelected
                  ? const Color(0xFF1A0A0A) // dark red tint
                  : const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: widget.isSelected
                    ? AppColors.primary
                    : const Color(0xFF2A2A2A),
                width: widget.isSelected ? 1.5 : 1.0,
              ),
              boxShadow: widget.isSelected
                  ? [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.18),
                  blurRadius: 12,
                  offset: const Offset(0, 2),
                ),
              ]
                  : [],
            ),
            child: Row(
              children: [
                // Selector indicator
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    shape: widget.isMulti
                        ? BoxShape.rectangle
                        : BoxShape.circle,
                    borderRadius:
                    widget.isMulti ? BorderRadius.circular(5) : null,
                    color: widget.isSelected
                        ? AppColors.primary
                        : Colors.transparent,
                    border: Border.all(
                      color: widget.isSelected
                          ? AppColors.primary
                          : const Color(0xFF555555),
                      width: 1.5,
                    ),
                  ),
                  child: widget.isSelected
                      ? const Icon(Icons.check_rounded,
                      color: Colors.white, size: 14)
                      : null,
                ),
                const SizedBox(width: 16),

                // Option image
                if (widget.option.imageUrl != null) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Image.network(
                      widget.option.imageUrl!,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 14),
                ],

                // Label
                Expanded(
                  child: Text(
                    widget.option.label,
                    style: TextStyle(
                      color: widget.isSelected
                          ? AppColors.textPrimary
                          : const Color(0xFFAAAAAA),
                      fontSize: 15,
                      fontWeight: widget.isSelected
                          ? FontWeight.w600
                          : FontWeight.w400,
                      fontFamily: 'Montserrat',
                      height: 1.4,
                    ),
                  ),
                ),

                // Selected checkmark accent on the right
                if (widget.isSelected)
                  Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Icon(
                      Icons.circle,
                      color: AppColors.primary.withOpacity(0.7),
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
  final String? initialValue;
  final void Function(String) onChanged;
  final int? characterLimit;

  const _NetflixTextField({
    this.initialValue,
    required this.onChanged,
    this.characterLimit,
  });

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
  void initState() {
    super.initState();
    _ctrl.text = widget.initialValue ?? '';
  }

  @override
  void didUpdateWidget(covariant _NetflixTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    final nextValue = widget.initialValue ?? '';
    if (nextValue != _ctrl.text) {
      _ctrl.text = nextValue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      onFocusChange: (v) => setState(() => _focused = v),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: _focused ? AppColors.primary : const Color(0xFF2A2A2A),
            width: _focused ? 1.5 : 1.0,
          ),
          color: const Color(0xFF1A1A1A),
          boxShadow: _focused
              ? [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.12),
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
            color: AppColors.textPrimary,
            fontFamily: 'Montserrat',
            fontSize: 14,
            height: 1.6,
          ),
          decoration: InputDecoration(
            hintText: 'Write your answer here...',
            hintStyle: TextStyle(
              color: AppColors.textMuted.withOpacity(0.6),
              fontFamily: 'Montserrat',
              fontSize: 14,
            ),
            counterStyle: const TextStyle(
              color: AppColors.textMuted,
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
  final bool isLastQuestion;
  final bool submitting;
  final bool hasAnswer;
  final bool isRequired;
  final bool isCorrectnessGateBlocked;
  final VoidCallback onSubmit;

  const _BottomAction({
    required this.isLastQuestion,
    required this.submitting,
    required this.hasAnswer,
    required this.isRequired,
    required this.isCorrectnessGateBlocked,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final canProceed = !isRequired || hasAnswer;

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 14, 24, 34),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border(
          top: BorderSide(
            color: const Color(0xFF2A2A2A),
            width: 0.5,
          ),
        ),
      ),
      child: SizedBox(
        width: double.infinity,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isCorrectnessGateBlocked)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Text(
                  'Choose the correct answer to unlock the next question.',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontFamily: 'Montserrat',
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                child: ElevatedButton(
                  onPressed: submitting || !canProceed ? null : onSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                    canProceed ? AppColors.primary : const Color(0xFF2A2A2A),
                    disabledBackgroundColor: const Color(0xFF2A2A2A),
                    elevation: canProceed ? 4 : 0,
                    shadowColor: AppColors.primary.withOpacity(0.4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
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
                        isLastQuestion ? 'Submit Assessment' : 'Next Question',
                        style: TextStyle(
                          color: canProceed
                              ? Colors.white
                              : AppColors.textMuted,
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
          ],
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(32),
              ),
              child: const Icon(
                Icons.wifi_off_rounded,
                color: AppColors.primary,
                size: 28,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Something went wrong',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w700,
                fontFamily: 'Montserrat',
              ),
            ),
            const SizedBox(height: 8),
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
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton(
                  onPressed: onBack,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textSecondary,
                    side: const BorderSide(color: Color(0xFF2A2A2A)),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4)),
                  ),
                  child: const Text(
                    'Go Back',
                    style: TextStyle(fontFamily: 'Montserrat'),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: onRetry,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 28, vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4)),
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
    );
  }
}
