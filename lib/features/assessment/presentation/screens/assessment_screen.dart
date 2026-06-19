import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../data/models/assessment_model.dart';
import '../providers/assessment_provider.dart';

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
  int? _activeQuestionId;

  late final AnimationController _fadeController;
  late final AnimationController _slideController;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _fadeAnim =
        CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.04),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
    );

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _replayEntrance() {
    _fadeController
      ..reset()
      ..forward();
    _slideController
      ..reset()
      ..forward();
  }

  @override
  Widget build(BuildContext context) {
    final attemptState = ref.watch(assessmentAttemptProvider(
      (lessonId: widget.lessonId, attemptId: widget.attemptId),
    ));
    final data = attemptState.data;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: _buildBody(context, attemptState, data),
    );
  }

  Widget _buildBody(
    BuildContext context,
    AssessmentAttemptState attemptState,
    AssessmentAttemptData? data,
  ) {
    if (attemptState.isInitialLoading && data == null) {
      return const _AssessmentLoader();
    }

    if (attemptState.fatalError != null && data == null) {
      return _AttemptError(
        message: attemptState.fatalError!,
        onBack: () => context.pop(),
        onRetry: () => ref
            .read(assessmentAttemptProvider(
              (lessonId: widget.lessonId, attemptId: widget.attemptId),
            ).notifier)
            .load(),
      );
    }

    if (data == null) return const SizedBox.shrink();

    if (data.mode != 'question') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        context.pushReplacement(
          '/lessons/${widget.lessonId}/assessment/attempts/${widget.attemptId}/result',
        );
      });
      return const _AssessmentLoader();
    }

    _syncQuestionState(data.question);

    return SafeArea(
      child: Column(
        children: [
          _AssessmentHeader(
            title: data.assessment.title,
            expiresAt: data.attempt.expiresAt,
            canGoBack: data.canGoBack,
            onBack: _handleBack,
            onClose: _handleClose,
          ),
          if (data.assessment.showProgressBar)
            _ProgressHeader(progress: data.assessment.progress),
          if (attemptState.actionError != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: _InlineActionError(
                message: attemptState.actionError!,
                onDismiss: () => ref
                    .read(assessmentAttemptProvider(
                      (lessonId: widget.lessonId, attemptId: widget.attemptId),
                    ).notifier)
                    .clearActionError(),
              ),
            ),
          Expanded(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                  child: _QuestionCard(
                    key: ValueKey(data.question.id),
                    question: data.question,
                    selectedOptionIds: _selectedOptionIds,
                    answerText: _answerText,
                    onOptionSelected: (optionId) {
                      ref
                          .read(assessmentAttemptProvider(
                            (lessonId: widget.lessonId, attemptId: widget.attemptId),
                          ).notifier)
                          .clearActionError();
                      setState(() {
                        if (data.question.allowMultiSelect) {
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
                      ref
                          .read(assessmentAttemptProvider(
                            (lessonId: widget.lessonId, attemptId: widget.attemptId),
                          ).notifier)
                          .clearActionError();
                      setState(() => _answerText = text);
                    },
                  ),
                ),
              ),
            ),
          ),
          _BottomBar(
            isLastQuestion: data.isLastQuestion,
            hasAnswer: _hasAnswer(data.question),
            isRequired: data.question.required,
            isBusy:
                attemptState.isSubmittingAnswer || attemptState.isSubmittingBack,
            onSubmit: () => _handleSubmit(data),
          ),
        ],
      ),
    );
  }

  void _syncQuestionState(AssessmentQuestion question) {
    if (_activeQuestionId == question.id) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() {
        _activeQuestionId = question.id;
        _selectedOptionIds = List<int>.from(question.saved.optionIds);
        _answerText = question.saved.answerText ?? '';
      });
    });
  }

  bool _hasAnswer(AssessmentQuestion question) {
    if (question.questionType == 'radio_buttons' ||
        question.questionType == 'checkboxes') {
      return _selectedOptionIds.isNotEmpty;
    }

    if (question.questionType == 'text') {
      return _answerText != null && _answerText!.trim().isNotEmpty;
    }

    return true;
  }

  Future<void> _handleSubmit(AssessmentAttemptData data) async {
    if (data.question.required && !_hasAnswer(data.question)) {
      _showSnack('Please answer this question before continuing.');
      return;
    }

    final success = await ref
        .read(assessmentAttemptProvider(
          (lessonId: widget.lessonId, attemptId: widget.attemptId),
        ).notifier)
        .submitAnswer(
          questionId: data.question.id,
          optionIds: _selectedOptionIds.isNotEmpty ? _selectedOptionIds : null,
          answerText:
              (_answerText?.trim().isEmpty ?? true) ? null : _answerText!.trim(),
        );

    if (!mounted || !success) return;

    setState(() {
      _activeQuestionId = null;
      _selectedOptionIds = [];
      _answerText = null;
    });
    _replayEntrance();
  }

  Future<void> _handleBack() async {
    final success = await ref
        .read(assessmentAttemptProvider(
          (lessonId: widget.lessonId, attemptId: widget.attemptId),
        ).notifier)
        .goBack();

    if (!mounted || !success) return;

    setState(() {
      _activeQuestionId = null;
      _selectedOptionIds = [];
      _answerText = null;
    });
    _replayEntrance();
  }

  void _handleClose() {
    showDialog<void>(
      context: context,
      barrierColor: Colors.black.withOpacity(0.72),
      builder: (ctx) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
        child: AlertDialog(
          backgroundColor: AppColors.surfaceElevated,
          title: const Text('Leave assessment?'),
          content: const Text(
            'Your progress is saved. You can continue again from the lesson.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Stay'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                context.pop();
              },
              child: const Text('Leave'),
            ),
          ],
        ),
      ),
    );
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class _AssessmentHeader extends StatelessWidget {
  final String title;
  final String? expiresAt;
  final bool canGoBack;
  final Future<void> Function() onBack;
  final VoidCallback onClose;

  const _AssessmentHeader({
    required this.title,
    required this.expiresAt,
    required this.canGoBack,
    required this.onBack,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 8, 4, 8),
      child: Row(
        children: [
          if (canGoBack)
            IconButton(
              onPressed: onBack,
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
            )
          else
            const SizedBox(width: 48),
          Expanded(
            child: Column(
              children: [
                const Text(
                  'ASSESSMENT',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (expiresAt != null) ...[
                  const SizedBox(height: 4),
                  _AttemptCountdown(expiresAt: expiresAt!),
                ],
              ],
            ),
          ),
          IconButton(
            onPressed: onClose,
            icon: const Icon(Icons.close_rounded, size: 20),
          ),
        ],
      ),
    );
  }
}

class _ProgressHeader extends StatelessWidget {
  final AssessmentProgress progress;

  const _ProgressHeader({required this.progress});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: List.generate(progress.total, (index) {
              final done = index < progress.current;
              final active = index == progress.current - 1;
              return Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  height: 3,
                  decoration: BoxDecoration(
                    color: done
                        ? AppColors.primary
                        : active
                            ? AppColors.primary.withOpacity(0.45)
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
            ),
          ),
        ],
      ),
    );
  }
}

class _InlineActionError extends StatelessWidget {
  final String message;
  final VoidCallback onDismiss;

  const _InlineActionError({
    required this.message,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.3),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 2),
            child: Icon(
              Icons.error_outline_rounded,
              color: AppColors.primary,
              size: 18,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 13,
                height: 1.5,
              ),
            ),
          ),
          IconButton(
            onPressed: onDismiss,
            icon: const Icon(
              Icons.close_rounded,
              color: AppColors.textSecondary,
              size: 18,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuestionCard extends StatelessWidget {
  final AssessmentQuestion question;
  final List<int> selectedOptionIds;
  final String? answerText;
  final ValueChanged<int> onOptionSelected;
  final ValueChanged<String> onTextChanged;

  const _QuestionCard({
    super.key,
    required this.question,
    required this.selectedOptionIds,
    required this.answerText,
    required this.onOptionSelected,
    required this.onTextChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (question.title.isNotEmpty &&
              question.title != 'Question ${question.id}') ...[
            Text(
              question.title.toUpperCase(),
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 12),
          ],
          Text(
            question.questionText,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.w800,
              height: 1.35,
            ),
          ),
          if (question.showInstruction &&
              question.instructionText != null &&
              question.instructionText!.trim().isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              question.instructionText!,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                height: 1.6,
              ),
            ),
          ],
          const SizedBox(height: 24),
          if (question.questionType == 'radio_buttons' ||
              question.questionType == 'checkboxes')
            ...question.options.map(
              (option) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _OptionTile(
                  option: option,
                  isMulti: question.allowMultiSelect,
                  isSelected: selectedOptionIds.contains(option.id),
                  onTap: () => onOptionSelected(option.id),
                ),
              ),
            )
          else if (question.questionType == 'text')
            _AnswerTextField(
              key: ValueKey(question.id),
              initialValue: answerText,
              characterLimit: question.characterLimit,
              onChanged: onTextChanged,
            ),
        ],
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  final AssessmentOption option;
  final bool isMulti;
  final bool isSelected;
  final VoidCallback onTap;

  const _OptionTile({
    required this.option,
    required this.isMulti,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1A0A0A) : AppColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.divider,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: isMulti ? BoxShape.rectangle : BoxShape.circle,
                borderRadius: isMulti ? BorderRadius.circular(6) : null,
                color: isSelected ? AppColors.primary : Colors.transparent,
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.textMuted,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check_rounded, color: Colors.white, size: 14)
                  : null,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                option.label,
                style: TextStyle(
                  color: isSelected
                      ? AppColors.textPrimary
                      : AppColors.textSecondary,
                  fontSize: 15,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnswerTextField extends StatefulWidget {
  final String? initialValue;
  final int? characterLimit;
  final ValueChanged<String> onChanged;

  const _AnswerTextField({
    super.key,
    this.initialValue,
    this.characterLimit,
    required this.onChanged,
  });

  @override
  State<_AnswerTextField> createState() => _AnswerTextFieldState();
}

class _AnswerTextFieldState extends State<_AnswerTextField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      minLines: 5,
      maxLines: 7,
      maxLength: widget.characterLimit,
      onChanged: widget.onChanged,
      style: const TextStyle(color: AppColors.textPrimary),
      decoration: const InputDecoration(
        hintText: 'Write your answer here...',
        alignLabelWithHint: true,
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  final bool isLastQuestion;
  final bool hasAnswer;
  final bool isRequired;
  final bool isBusy;
  final VoidCallback onSubmit;

  const _BottomBar({
    required this.isLastQuestion,
    required this.hasAnswer,
    required this.isRequired,
    required this.isBusy,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final canProceed = !isRequired || hasAnswer;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.divider)),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          onPressed: isBusy || !canProceed ? null : onSubmit,
          child: isBusy
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white,
                  ),
                )
              : Text(isLastQuestion ? 'Submit Assessment' : 'Next Question'),
        ),
      ),
    );
  }
}

class _AssessmentLoader extends StatelessWidget {
  const _AssessmentLoader();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: SizedBox(
        width: 32,
        height: 32,
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
    );
  }
}

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
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: AppColors.primary,
              size: 42,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton(
                  onPressed: onBack,
                  child: const Text('Go Back'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: onRetry,
                  child: const Text('Try Again'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AttemptCountdown extends StatefulWidget {
  final String expiresAt;

  const _AttemptCountdown({required this.expiresAt});

  @override
  State<_AttemptCountdown> createState() => _AttemptCountdownState();
}

class _AttemptCountdownState extends State<_AttemptCountdown> {
  Timer? _timer;
  Duration _remaining = Duration.zero;

  @override
  void initState() {
    super.initState();
    _tick();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void _tick() {
    final expiresAt = DateTime.tryParse(widget.expiresAt)?.toLocal();
    if (expiresAt == null || !mounted) return;

    final remaining = expiresAt.difference(DateTime.now());
    setState(() {
      _remaining = remaining.isNegative ? Duration.zero : remaining;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final totalSeconds = _remaining.inSeconds;
    final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');

    return Text(
      '$minutes:$seconds remaining',
      style: TextStyle(
        color: totalSeconds <= 60 ? AppColors.primary : AppColors.textMuted,
        fontSize: 11,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
