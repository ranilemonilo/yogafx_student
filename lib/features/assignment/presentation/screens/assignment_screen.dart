import 'dart:ui';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/models/assignment_model.dart';
import '../providers/assignment_provider.dart';

// ─── Design tokens (sesuai DESIGN_SYSTEM.md) ─────────────────────────────────
// bg utama   : #060908
// bg card    : #120F0E
// bg layer   : #141110  (header, divider area)
// overlay    : #161210  (hover card)
// primary    : #DB202C
// success    : #00B14F
// white      : #FFFFFF
// text sec   : rgba(255,255,255,0.65)
// text muted : rgba(255,255,255,0.45)
// border     : rgba(255,255,255,0.10)

class _DS {
  static const bgPage    = Color(0xFF060908);
  static const bgCard    = Color(0xFF120F0E);
  static const bgHeader  = Color(0xFF141110);
  static const bgOverlay = Color(0xFF161210);
  static const primary   = Color(0xFFDB202C);
  static const success   = Color(0xFF00B14F);
  static const white     = Color(0xFFFFFFFF);
  static const textSec   = Color(0xFFA6A6A6);   // ~rgba(255,255,255,0.65)
  static const textMuted = Color(0xFF737373);   // ~rgba(255,255,255,0.45)
  static const border    = Color(0xFF1A1A1A);   // ~rgba(255,255,255,0.10)

  static const fontFamily = 'Montserrat';
}

// ─── Main Screen ──────────────────────────────────────────────────────────────

class AssignmentScreen extends ConsumerStatefulWidget {
  final int assignmentId;

  const AssignmentScreen({super.key, required this.assignmentId});

  @override
  ConsumerState<AssignmentScreen> createState() => _AssignmentScreenState();
}

class _AssignmentScreenState extends ConsumerState<AssignmentScreen> {
  bool _submitting = false;
  String? _submitError;

  @override
  Widget build(BuildContext context) {
    final assignmentAsync =
    ref.watch(assignmentDetailProvider(widget.assignmentId));

    return Scaffold(
      backgroundColor: _DS.bgPage,
      body: assignmentAsync.when(
        loading: () => const _AssignmentSkeleton(),
        error: (e, _) => _AssignmentError(
          message: e.toString(),
          onRetry: () =>
              ref.invalidate(assignmentDetailProvider(widget.assignmentId)),
          onBack: () => context.pop(),
        ),
        data: (assignment) => _AssignmentContent(
          assignment: assignment,
          submitting: _submitting,
          submitError: _submitError,
          onPickVideo: () => _pickVideo(assignment),
        ),
      ),
    );
  }

  Future<void> _pickVideo(AssignmentDetail assignment) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: assignment.uploadConstraints?.acceptedExtensions ??
          const ['mp4', 'mov', 'webm', 'avi', 'm4v'],
    );

    if (result == null || result.files.single.path == null) return;

    setState(() {
      _submitting = true;
      _submitError = null;
    });

    try {
      await ref.read(assignmentRepositoryProvider).submitAssignment(
        assignmentId: widget.assignmentId,
        filePath: result.files.single.path!,
        fileName: result.files.single.name,
      );
      ref.invalidate(assignmentDetailProvider(widget.assignmentId));
    } catch (e) {
      setState(() => _submitError = e.toString());
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }
}

// ─── Content ──────────────────────────────────────────────────────────────────

class _AssignmentContent extends StatefulWidget {
  final AssignmentDetail assignment;
  final bool submitting;
  final String? submitError;
  final VoidCallback onPickVideo;

  const _AssignmentContent({
    required this.assignment,
    required this.submitting,
    required this.submitError,
    required this.onPickVideo,
  });

  @override
  State<_AssignmentContent> createState() => _AssignmentContentState();
}

class _AssignmentContentState extends State<_AssignmentContent>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeCtrl;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _fade = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut));
    _fadeCtrl.forward();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final a = widget.assignment;

    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: CustomScrollView(
          slivers: [
            // ── SliverAppBar ──────────────────────────────────────────
            SliverAppBar(
              backgroundColor: _DS.bgHeader,
              floating: true,
              snap: true,
              elevation: 0,
              leading: _HeaderIconBtn(
                icon: Icons.arrow_back_ios_new_rounded,
                onTap: () => Navigator.of(context).pop(),
              ),
              title: const Text(
                'ASSIGNMENT',
                style: TextStyle(
                  color: _DS.primary,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  fontFamily: _DS.fontFamily,
                  letterSpacing: 3,
                ),
              ),
              centerTitle: true,
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(0.5),
                child: Container(
                  height: 0.5,
                  color: _DS.border,
                ),
              ),
            ),

            // ── Body ──────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 32, 20, 60),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Title card ──
                    _SectionCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _EyebrowLabel(
                              label: a.module.title?.toUpperCase() ?? 'MODULE'),
                          const SizedBox(height: 12),

                          Text(
                            a.title,
                            style: const TextStyle(
                              color: _DS.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              fontFamily: _DS.fontFamily,
                              height: 1.25,
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(height: 12),

                          Text(
                            a.description ?? 'No description available.',
                            style: const TextStyle(
                              color: _DS.textSec,
                              fontSize: 14,
                              fontFamily: _DS.fontFamily,
                              height: 1.65,
                            ),
                          ),

                          const SizedBox(height: 20),
                          const _Divider(),
                          const SizedBox(height: 16),

                          _MetaRow(label: 'Status', value: a.status ?? '-'),
                          if (a.uploadConstraints != null)
                            _MetaRow(
                              label: 'Max file size',
                              value: a.uploadConstraints!.videoMaxSizeLabel,
                            ),
                          if (a.uploadConstraints != null)
                            _MetaRow(
                              label: 'Accepted formats',
                              value: (a.uploadConstraints!.acceptedExtensions ??
                                  ['mp4', 'mov', 'webm'])
                                  .join(', ')
                                  .toUpperCase(),
                            ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // ── Submission card ──
                    if (a.submission != null)
                      _SubmissionCard(submission: a.submission!),

                    // ── Error message ──
                    if (widget.submitError != null) ...[
                      const SizedBox(height: 12),
                      _ErrorBanner(message: widget.submitError!),
                    ],

                    const SizedBox(height: 24),

                    // ── Upload CTA ──
                    _UploadButton(
                      submitting: widget.submitting,
                      onTap: widget.onPickVideo,
                      hasSubmission: a.submission != null,
                    ),

                    const SizedBox(height: 10),

                    Center(
                      child: Text(
                        'Your video will be reviewed by the instructor',
                        style: TextStyle(
                          color: _DS.textMuted.withOpacity(0.7),
                          fontSize: 11,
                          fontFamily: _DS.fontFamily,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Submission Card ──────────────────────────────────────────────────────────

class _SubmissionCard extends StatelessWidget {
  final AssignmentSubmissionInfo submission;

  const _SubmissionCard({required this.submission});

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
      case 'passed':
        return _DS.success;
      case 'rejected':
      case 'failed':
        return _DS.primary;
      case 'pending':
      case 'in_review':
        return const Color(0xFFDF6739); // warm orange dari design system
      default:
        return _DS.textMuted;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(submission.status);

    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'LATEST SUBMISSION',
                      style: TextStyle(
                        color: _DS.textMuted,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        fontFamily: _DS.fontFamily,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Review Status',
                      style: TextStyle(
                        color: _DS.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        fontFamily: _DS.fontFamily,
                      ),
                    ),
                  ],
                ),
              ),
              // Status pill
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(2),
                  border:
                  Border.all(color: color.withOpacity(0.35), width: 1),
                ),
                child: Text(
                  submission.status.replaceAll('_', ' ').toUpperCase(),
                  style: TextStyle(
                    color: color,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    fontFamily: _DS.fontFamily,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
          const _Divider(),
          const SizedBox(height: 14),

          _MetaRow(
              label: 'Submitted at', value: submission.submittedAt ?? '-'),

          if (submission.feedback != null && submission.feedback!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'INSTRUCTOR FEEDBACK',
                    style: TextStyle(
                      color: _DS.textMuted,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      fontFamily: _DS.fontFamily,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: _DS.bgOverlay,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: _DS.border, width: 1),
                    ),
                    child: Text(
                      submission.feedback!,
                      style: const TextStyle(
                        color: _DS.textSec,
                        fontSize: 13,
                        fontFamily: _DS.fontFamily,
                        height: 1.6,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          if (submission.videoUrl != null) ...[
            const SizedBox(height: 14),
            _VideoButton(url: submission.videoUrl!),
          ],
        ],
      ),
    );
  }
}

// ─── Video Button ─────────────────────────────────────────────────────────────

class _VideoButton extends StatefulWidget {
  final String url;

  const _VideoButton({required this.url});

  @override
  State<_VideoButton> createState() => _VideoButtonState();
}

class _VideoButtonState extends State<_VideoButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleCtrl;

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
  }

  @override
  void dispose() {
    _scaleCtrl.dispose();
    super.dispose();
  }

  Future<void> _open() async {
    final uri = Uri.parse(widget.url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _scaleCtrl.reverse(),
      onTapUp: (_) {
        _scaleCtrl.forward();
        _open();
      },
      onTapCancel: () => _scaleCtrl.forward(),
      child: ScaleTransition(
        scale: _scaleCtrl,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 13),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1410), // warm dark sesuai DS
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: _DS.border),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.play_circle_outline_rounded,
                  color: _DS.textSec, size: 18),
              const SizedBox(width: 8),
              const Text(
                'Watch Uploaded Video',
                style: TextStyle(
                  color: _DS.textSec,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  fontFamily: _DS.fontFamily,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Upload Button ────────────────────────────────────────────────────────────

class _UploadButton extends StatefulWidget {
  final bool submitting;
  final VoidCallback onTap;
  final bool hasSubmission;

  const _UploadButton({
    required this.submitting,
    required this.onTap,
    required this.hasSubmission,
  });

  @override
  State<_UploadButton> createState() => _UploadButtonState();
}

class _UploadButtonState extends State<_UploadButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleCtrl;

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
  }

  @override
  void dispose() {
    _scaleCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final enabled = !widget.submitting;

    return GestureDetector(
      onTapDown: enabled ? (_) => _scaleCtrl.reverse() : null,
      onTapUp: enabled
          ? (_) {
        _scaleCtrl.forward();
        widget.onTap();
      }
          : null,
      onTapCancel: () => _scaleCtrl.forward(),
      child: ScaleTransition(
        scale: _scaleCtrl,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: double.infinity,
          height: 48, // sesuai DS: Large button ~42px, sedikit lebih tinggi
          decoration: BoxDecoration(
            // DS: primary #DB202C, disabled pakai rgba(255,255,255,0.2)
            color: enabled
                ? _DS.primary
                : const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(4),
            boxShadow: enabled
                ? [
              BoxShadow(
                color: _DS.primary.withOpacity(0.30),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ]
                : [],
          ),
          child: Center(
            child: widget.submitting
                ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                  color: _DS.white, strokeWidth: 2.5),
            )
                : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.upload_rounded,
                    color: _DS.white, size: 20),
                const SizedBox(width: 10),
                Text(
                  widget.hasSubmission
                      ? 'Re-upload Assignment'
                      : 'Upload Assignment Video',
                  style: const TextStyle(
                    color: _DS.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    fontFamily: _DS.fontFamily,
                    letterSpacing: 0.3,
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

// ─── Error Banner ─────────────────────────────────────────────────────────────

class _ErrorBanner extends StatelessWidget {
  final String message;

  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: _DS.primary.withOpacity(0.07),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: _DS.primary.withOpacity(0.30), width: 1),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded,
              color: _DS.primary, size: 16),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: _DS.primary,
                fontSize: 12,
                fontFamily: _DS.fontFamily,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Shared Widgets ───────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final Widget child;

  const _SectionCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _DS.bgCard,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _DS.border, width: 1),
        // DS: modal/panel shadow
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _EyebrowLabel extends StatelessWidget {
  final String label;

  const _EyebrowLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _DS.primary.withOpacity(0.10),
        borderRadius: BorderRadius.circular(2),
        border:
        Border.all(color: _DS.primary.withOpacity(0.25), width: 0.5),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: _DS.primary,
          fontSize: 10,
          fontWeight: FontWeight.w700,
          fontFamily: _DS.fontFamily,
          letterSpacing: 1.5,
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Container(height: 0.5, color: _DS.border);
  }
}

class _MetaRow extends StatelessWidget {
  final String label;
  final String value;

  const _MetaRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Text(
              label,
              style: const TextStyle(
                color: _DS.textMuted,
                fontSize: 12,
                fontFamily: _DS.fontFamily,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 6,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: _DS.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
                fontFamily: _DS.fontFamily,
              ),
            ),
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
          child: Icon(icon, color: _DS.white, size: 18),
        ),
      ),
    );
  }
}

// ─── Skeleton ─────────────────────────────────────────────────────────────────

class _AssignmentSkeleton extends StatefulWidget {
  const _AssignmentSkeleton();

  @override
  State<_AssignmentSkeleton> createState() => _AssignmentSkeletonState();
}

class _AssignmentSkeletonState extends State<_AssignmentSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimCtrl;
  late Animation<double> _shimAnim;

  @override
  void initState() {
    super.initState();
    _shimCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _shimAnim = CurvedAnimation(parent: _shimCtrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _shimCtrl.dispose();
    super.dispose();
  }

  Widget _bone(double height, {double? width, double radius = 4}) {
    return AnimatedBuilder(
      animation: _shimAnim,
      builder: (_, __) => Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius),
          color: Color.lerp(
            _DS.bgCard,
            const Color(0xFF1E1A18),
            _shimAnim.value,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        const SliverAppBar(
          backgroundColor: _DS.bgHeader,
          floating: true,
          snap: true,
          title: Text(
            'ASSIGNMENT',
            style: TextStyle(
              color: _DS.primary,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              fontFamily: _DS.fontFamily,
              letterSpacing: 3,
            ),
          ),
          centerTitle: true,
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 32, 20, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: _DS.bgCard,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: _DS.border, width: 1),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _bone(14, width: 80),
                      const SizedBox(height: 12),
                      _bone(26),
                      const SizedBox(height: 8),
                      _bone(22, width: 200),
                      const SizedBox(height: 20),
                      _bone(0.5),
                      const SizedBox(height: 16),
                      _bone(12),
                      const SizedBox(height: 10),
                      _bone(12, width: 180),
                      const SizedBox(height: 10),
                      _bone(12, width: 140),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: _DS.bgCard,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: _DS.border, width: 1),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _bone(12, width: 120),
                      const SizedBox(height: 12),
                      _bone(20, width: 160),
                      const SizedBox(height: 16),
                      _bone(0.5),
                      const SizedBox(height: 14),
                      _bone(12),
                      const SizedBox(height: 10),
                      _bone(12, width: 200),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                _bone(48, radius: 4),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Error State ──────────────────────────────────────────────────────────────

class _AssignmentError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  final VoidCallback onBack;

  const _AssignmentError({
    required this.message,
    required this.onRetry,
    required this.onBack,
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
                color: _DS.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.wifi_off_rounded,
                  color: _DS.primary, size: 28),
            ),
            const SizedBox(height: 20),
            const Text(
              'Something went wrong',
              style: TextStyle(
                color: _DS.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
                fontFamily: _DS.fontFamily,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: _DS.textSec,
                fontSize: 13,
                fontFamily: _DS.fontFamily,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton(
                  onPressed: onBack,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _DS.textSec,
                    side: const BorderSide(color: _DS.border),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4)),
                  ),
                  child: const Text('Go Back',
                      style: TextStyle(fontFamily: _DS.fontFamily)),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: onRetry,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _DS.primary,
                    // DS hover: #F6121D — Flutter pakai overlayColor
                    overlayColor: const Color(0xFFF6121D),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 28, vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4)),
                  ),
                  child: const Text(
                    'Try Again',
                    style: TextStyle(
                      color: _DS.white,
                      fontFamily: _DS.fontFamily,
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