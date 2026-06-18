import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/models/certificate_model.dart';
import '../providers/certificate_provider.dart';

// ─── Main Screen ──────────────────────────────────────────────────────────────

class CertificateListScreen extends ConsumerWidget {
  const CertificateListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final certificatesAsync = ref.watch(certificateListProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: certificatesAsync.when(
        loading: () => const _CertificateListSkeleton(),
        error: (e, _) => _CertificateError(
          message: e.toString(),
          onRetry: () => ref.invalidate(certificateListProvider),
        ),
        data: (data) => _CertificateListContent(data: data),
      ),
    );
  }
}

// ─── Content ──────────────────────────────────────────────────────────────────

class _CertificateListContent extends ConsumerStatefulWidget {
  final CertificateListData data;

  const _CertificateListContent({required this.data});

  @override
  ConsumerState<_CertificateListContent> createState() =>
      _CertificateListContentState();
}

class _CertificateListContentState
    extends ConsumerState<_CertificateListContent>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: AppColors.primary,
      backgroundColor: const Color(0xFF1A1A1A),
      onRefresh: () async {
        ref.invalidate(certificateListProvider);
        await ref.read(certificateListProvider.future);
      },
      child: FadeTransition(
        opacity: _fade,
        child: SlideTransition(
          position: _slide,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // ── AppBar ──
              SliverAppBar(
                backgroundColor: AppColors.background,
                floating: true,
                snap: true,
                elevation: 0,
                title: const Text(
                  'CERTIFICATES',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Montserrat',
                    letterSpacing: 2.5,
                  ),
                ),
                centerTitle: true,
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(0.5),
                  child:
                  Container(height: 0.5, color: const Color(0xFF2A2A2A)),
                ),
              ),

              // ── Body ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 28, 20, 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Summary card
                      _CertificateSummary(summary: widget.data.summary),
                      const SizedBox(height: 24),

                      // List or empty
                      if (widget.data.items.isEmpty)
                        const _CertificateEmptyState()
                      else ...[
                        // Section label
                        const Padding(
                          padding: EdgeInsets.only(bottom: 14),
                          child: Text(
                            'YOUR CERTIFICATES',
                            style: TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'Montserrat',
                              letterSpacing: 2,
                            ),
                          ),
                        ),
                        ...widget.data.items.asMap().entries.map(
                              (entry) => _AnimatedCertCard(
                            index: entry.key,
                            item: entry.value,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Summary Card ─────────────────────────────────────────────────────────────

class _CertificateSummary extends StatelessWidget {
  final CertSummary summary;

  const _CertificateSummary({required this.summary});

  @override
  Widget build(BuildContext context) {
    // Completion fraction from requirements
    final totalReqs = summary.requirements.length;
    final doneReqs =
        summary.requirements.where((r) => r.isComplete).length;
    final fraction = totalReqs > 0 ? doneReqs / totalReqs : 0.0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF2A2A2A)),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF1F1010),
            const Color(0xFF1A1A1A),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: AppColors.primary.withOpacity(0.25), width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.18),
                      blurRadius: 14,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(Icons.workspace_premium_rounded,
                      color: AppColors.primary, size: 20),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      summary.tier?.name ?? 'Certificate Progress',
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Montserrat',
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${summary.generatedCount} certificate${summary.generatedCount == 1 ? '' : 's'} issued',
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 11,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Message
          if (summary.message != null)
            Text(
              summary.message!,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                fontFamily: 'Montserrat',
                height: 1.5,
              ),
            ),

          if (summary.requirements.isNotEmpty) ...[
            const SizedBox(height: 18),

            // Overall progress bar
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: LinearProgressIndicator(
                      value: fraction,
                      backgroundColor: const Color(0xFF2A2A2A),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.primary),
                      minHeight: 3,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  '$doneReqs/$totalReqs',
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 11,
                    fontFamily: 'Montserrat',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),
            Container(height: 0.5, color: const Color(0xFF2A2A2A)),
            const SizedBox(height: 14),

            // Requirements list
            ...summary.requirements.map(
                  (item) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: item.isComplete
                            ? AppColors.primary.withOpacity(0.15)
                            : Colors.transparent,
                        border: Border.all(
                          color: item.isComplete
                              ? AppColors.primary
                              : const Color(0xFF444444),
                          width: 1.5,
                        ),
                      ),
                      child: item.isComplete
                          ? const Icon(Icons.check_rounded,
                          color: AppColors.primary, size: 12)
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        item.label,
                        style: TextStyle(
                          color: item.isComplete
                              ? AppColors.textPrimary
                              : AppColors.textSecondary,
                          fontSize: 13,
                          fontFamily: 'Montserrat',
                          fontWeight: item.isComplete
                              ? FontWeight.w500
                              : FontWeight.w400,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${item.completed}/${item.total}',
                      style: TextStyle(
                        color: item.isComplete
                            ? AppColors.primary
                            : AppColors.textMuted,
                        fontSize: 11,
                        fontFamily: 'Montserrat',
                        fontWeight: item.isComplete
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Animated Certificate Card ────────────────────────────────────────────────

class _AnimatedCertCard extends StatefulWidget {
  final int index;
  final CertificateItem item;

  const _AnimatedCertCard({required this.index, required this.item});

  @override
  State<_AnimatedCertCard> createState() => _AnimatedCertCardState();
}

class _AnimatedCertCardState extends State<_AnimatedCertCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleCtrl;

  @override
  void initState() {
    super.initState();
    _scaleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 90),
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTapDown: (_) => _scaleCtrl.reverse(),
        onTapUp: (_) {
          _scaleCtrl.forward();
          context.push('/certificates/${widget.item.id}');
        },
        onTapCancel: () => _scaleCtrl.forward(),
        child: ScaleTransition(
          scale: _scaleCtrl,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF2A2A2A)),
            ),
            child: Row(
              children: [
                // Icon container with glow
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(23),
                    border: Border.all(
                        color: AppColors.primary.withOpacity(0.2), width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.15),
                        blurRadius: 12,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(Icons.workspace_premium_rounded,
                        color: AppColors.primary, size: 22),
                  ),
                ),
                const SizedBox(width: 16),

                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.item.typeLabel,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Montserrat',
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 5),
                      // Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: Text(
                          widget.item.typeLabel.toUpperCase(),
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Montserrat',
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today_rounded,
                              color: AppColors.textMuted, size: 11),
                          const SizedBox(width: 4),
                          Text(
                            widget.item.generatedAt ?? 'Date unavailable',
                            style: const TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 11,
                              fontFamily: 'Montserrat',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Chevron
                const Icon(Icons.chevron_right_rounded,
                    color: Color(0xFF444444), size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Empty State ──────────────────────────────────────────────────────────────

class _CertificateEmptyState extends StatelessWidget {
  const _CertificateEmptyState();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 56, horizontal: 32),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF2A2A2A)),
      ),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(
                  color: AppColors.primary.withOpacity(0.15), width: 1),
            ),
            child: const Center(
              child: Icon(Icons.workspace_premium_outlined,
                  color: AppColors.primary, size: 30),
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'No certificates yet',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w700,
              fontFamily: 'Montserrat',
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Complete the required learning milestones\nto unlock your certificates.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              fontFamily: 'Montserrat',
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Skeleton ─────────────────────────────────────────────────────────────────

class _CertificateListSkeleton extends StatefulWidget {
  const _CertificateListSkeleton();

  @override
  State<_CertificateListSkeleton> createState() =>
      _CertificateListSkeletonState();
}

class _CertificateListSkeletonState extends State<_CertificateListSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1100))
      ..repeat(reverse: true);
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Widget _bone(double h, {double? w, double r = 6}) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Container(
        width: w,
        height: h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(r),
          color: Color.lerp(
              const Color(0xFF1E1E1E), const Color(0xFF2A2A2A), _anim.value),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        const SliverAppBar(
          backgroundColor: AppColors.background,
          floating: true,
          snap: true,
          title: Text(
            'CERTIFICATES',
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              fontFamily: 'Montserrat',
              letterSpacing: 2.5,
            ),
          ),
          centerTitle: true,
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 28, 20, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Summary skeleton
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A1A),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFF2A2A2A)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          _bone(40, w: 40, r: 20),
                          const SizedBox(width: 14),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _bone(14, w: 140),
                              const SizedBox(height: 6),
                              _bone(10, w: 90),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _bone(12),
                      const SizedBox(height: 6),
                      _bone(12, w: 260),
                      const SizedBox(height: 18),
                      _bone(3),
                      const SizedBox(height: 16),
                      _bone(12),
                      const SizedBox(height: 10),
                      _bone(12, w: 200),
                      const SizedBox(height: 10),
                      _bone(12, w: 240),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                _bone(10, w: 140),
                const SizedBox(height: 14),
                ...List.generate(
                  3,
                      (i) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1A1A),
                        borderRadius: BorderRadius.circular(8),
                        border:
                        Border.all(color: const Color(0xFF2A2A2A)),
                      ),
                      child: Row(
                        children: [
                          _bone(46, w: 46, r: 23),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _bone(14, w: 160),
                                const SizedBox(height: 8),
                                _bone(10, w: 80),
                                const SizedBox(height: 8),
                                _bone(10, w: 120),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Error ────────────────────────────────────────────────────────────────────

class _CertificateError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _CertificateError({required this.message, required this.onRetry});

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
              child: const Icon(Icons.wifi_off_rounded,
                  color: AppColors.primary, size: 28),
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
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                fontFamily: 'Montserrat',
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            GestureDetector(
              onTap: onRetry,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 32, vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.35),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
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
            ),
          ],
        ),
      ),
    );
  }
}