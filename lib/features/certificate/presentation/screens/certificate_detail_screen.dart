import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/models/certificate_model.dart';
import '../providers/certificate_provider.dart';

// ─── Main Screen ──────────────────────────────────────────────────────────────

class CertificateDetailScreen extends ConsumerWidget {
  final int certificateId;

  const CertificateDetailScreen({super.key, required this.certificateId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final certificateAsync =
    ref.watch(certificateDetailProvider(certificateId));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: certificateAsync.when(
        loading: () => const _CertificateDetailSkeleton(),
        error: (e, _) => _CertificateDetailError(
          message: e.toString(),
          onRetry: () =>
              ref.invalidate(certificateDetailProvider(certificateId)),
        ),
        data: (certificate) =>
            _CertificateDetailContent(certificate: certificate),
      ),
    );
  }
}

// ─── Content ──────────────────────────────────────────────────────────────────

class _CertificateDetailContent extends StatefulWidget {
  final CertificateItem certificate;

  const _CertificateDetailContent({required this.certificate});

  @override
  State<_CertificateDetailContent> createState() =>
      _CertificateDetailContentState();
}

class _CertificateDetailContentState extends State<_CertificateDetailContent>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 550));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _openUrl(String value) async {
    final uri = Uri.parse(value);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.certificate;

    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: CustomScrollView(
          slivers: [
            // ── AppBar ──
            SliverAppBar(
              backgroundColor: AppColors.background,
              floating: true,
              snap: true,
              elevation: 0,
              leading: _HeaderIconBtn(
                icon: Icons.arrow_back_ios_new_rounded,
                onTap: () => Navigator.of(context).pop(),
              ),
              title: const Text(
                'CERTIFICATE',
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
                // §1: divider = rgba(255,255,255,0.1)
                child: Container(height: 0.5, color: AppColors.divider),
              ),
            ),

            // ── Body ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 32, 20, 60),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Hero certificate card ──
                    _CertificateHeroCard(certificate: c),

                    const SizedBox(height: 16),

                    // ── Details card ──
                    _SectionCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'DETAILS',
                            style: TextStyle(
                              // §2: textMuted = rgba(255,255,255,0.45)
                              color: AppColors.textMuted,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'Montserrat',
                              letterSpacing: 2,
                            ),
                          ),
                          const SizedBox(height: 14),
                          _DetailRow(
                            label: 'Issued at',
                            value: c.generatedAt ?? '-',
                          ),
                          _DetailRow(
                            label: 'Generated by',
                            value: c.generatedBy ?? '-',
                          ),
                          _DetailRow(
                            label: 'Download',
                            value: c.downloadUrl != null
                                ? 'Available'
                                : 'Not available',
                            // §1: secondary = Emerald #00B14F untuk indikator sukses
                            valueColor: c.downloadUrl != null
                                ? AppColors.secondary
                                : null,
                          ),
                          _DetailRow(
                            label: 'View online',
                            value: c.openUrl != null
                                ? 'Available'
                                : 'Not available',
                            valueColor: c.openUrl != null
                                ? AppColors.secondary
                                : null,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ── CTAs ──
                    if (c.openUrl != null)
                      _ActionButton(
                        label: 'Open Certificate',
                        icon: Icons.open_in_new_rounded,
                        primary: true,
                        onTap: () => _openUrl(c.openUrl!),
                      ),

                    if (c.downloadUrl != null) ...[
                      const SizedBox(height: 12),
                      _ActionButton(
                        label: 'Download Certificate',
                        icon: Icons.download_rounded,
                        primary: false,
                        onTap: () => _openUrl(c.downloadUrl!),
                      ),
                    ],
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

// ─── Hero Certificate Card ────────────────────────────────────────────────────

class _CertificateHeroCard extends StatelessWidget {
  final CertificateItem certificate;

  const _CertificateHeroCard({required this.certificate});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        // §1: surfaceElevated = Neutral Black 3 (#120F0E) untuk card/panel
        borderRadius: BorderRadius.circular(AppRadius.modal),
        border: Border.all(color: AppColors.divider),
        // Subtle warm-tinted gradient sesuai palet coklat design system
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            // §1: overlayDark (#161210) → surfaceElevated (#120F0E)
            AppColors.overlayDark,
            AppColors.surfaceElevated,
            AppColors.surfaceElevated,
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon with glow
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.10),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                  color: AppColors.primary.withOpacity(0.25), width: 1),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.20),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Center(
              child: Icon(
                Icons.workspace_premium_rounded,
                color: AppColors.primary,
                size: 28,
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Type badge — §3: badge styling radius 2px
          Container(
            padding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(AppRadius.badge),
              border: Border.all(
                  color: AppColors.primary.withOpacity(0.30), width: 0.5),
            ),
            child: Text(
              certificate.typeLabel.toUpperCase(),
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                fontFamily: 'Montserrat',
                letterSpacing: 1.5,
              ),
            ),
          ),

          const SizedBox(height: 10),

          // Title — §2: Title 2 = 24px SemiBold
          Text(
            certificate.typeLabel,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.w800,
              fontFamily: 'Montserrat',
              letterSpacing: -0.5,
              height: 1.2,
            ),
          ),

          const SizedBox(height: 16),

          // Decorative divider line
          Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withOpacity(0.5),
                  AppColors.primary.withOpacity(0.0),
                ],
              ),
            ),
          ),

          const SizedBox(height: 14),

          // Issued at hint
          if (certificate.generatedAt != null)
            Row(
              children: [
                const Icon(Icons.calendar_today_rounded,
                    color: AppColors.textMuted, size: 13),
                const SizedBox(width: 6),
                Text(
                  'Issued ${certificate.generatedAt}',
                  style: const TextStyle(
                    // §2: caption 12px, textMuted = rgba(255,255,255,0.45)
                    color: AppColors.textMuted,
                    fontSize: 12,
                    fontFamily: 'Montserrat',
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

// ─── Detail Row ───────────────────────────────────────────────────────────────

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _DetailRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 12,
                fontFamily: 'Montserrat',
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 6,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: valueColor ?? AppColors.textPrimary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
                fontFamily: 'Montserrat',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Action Buttons ───────────────────────────────────────────────────────────
// §4: Primary = bg #DB202C, radius 4px | Secondary = bg rgba(255,255,255,0.2)

class _ActionButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final bool primary;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.primary,
    required this.onTap,
  });

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton>
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
    return GestureDetector(
      onTapDown: (_) => _scaleCtrl.reverse(),
      onTapUp: (_) {
        _scaleCtrl.forward();
        widget.onTap();
      },
      onTapCancel: () => _scaleCtrl.forward(),
      child: ScaleTransition(
        scale: _scaleCtrl,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: double.infinity,
          // §4: Large button height ~42px, pakai 48 agar konsisten dengan login
          height: 48,
          decoration: BoxDecoration(
            // Primary = #DB202C | Secondary = rgba(255,255,255,0.2) §4
            color: widget.primary
                ? AppColors.primary
                : AppColors.inputFill, // rgba(255,255,255,0.10)
            borderRadius: BorderRadius.circular(AppRadius.button),
            border: widget.primary
                ? null
                : Border.all(color: AppColors.divider),
            boxShadow: widget.primary
                ? [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.35),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ]
                : [],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                widget.icon,
                // §3: ikon putih untuk primary, textSecondary untuk secondary
                color: widget.primary
                    ? AppColors.textPrimary
                    : AppColors.textSecondary,
                size: 18,
              ),
              const SizedBox(width: 10),
              Text(
                widget.label,
                style: TextStyle(
                  color: widget.primary
                      ? AppColors.textPrimary
                      : AppColors.textSecondary,
                  // §4: Large button = 16px Bold
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Montserrat',
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Shared ───────────────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final Widget child;

  const _SectionCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        // §1: surfaceElevated (#120F0E) untuk card/panel
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(AppRadius.modal),
        border: Border.all(color: AppColors.divider),
      ),
      child: child,
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

// ─── Skeleton ─────────────────────────────────────────────────────────────────

class _CertificateDetailSkeleton extends StatefulWidget {
  const _CertificateDetailSkeleton();

  @override
  State<_CertificateDetailSkeleton> createState() =>
      _CertificateDetailSkeletonState();
}

class _CertificateDetailSkeletonState
    extends State<_CertificateDetailSkeleton>
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
          // §1: shimmer (#281D16) → shimmerHighlight (#3A2A1E)
          color: Color.lerp(
              AppColors.shimmer, AppColors.shimmerHighlight, _anim.value),
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
            'CERTIFICATE',
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
            padding: const EdgeInsets.fromLTRB(20, 32, 20, 40),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(AppRadius.modal),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _bone(56, w: 56, r: 28),
                      const SizedBox(height: 20),
                      _bone(16, w: 90),
                      const SizedBox(height: 10),
                      _bone(28),
                      const SizedBox(height: 8),
                      _bone(20, w: 200),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(AppRadius.modal),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _bone(12, w: 60),
                      const SizedBox(height: 14),
                      _bone(12),
                      const SizedBox(height: 10),
                      _bone(12, w: 220),
                      const SizedBox(height: 10),
                      _bone(12, w: 180),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                _bone(48, r: AppRadius.button),
                const SizedBox(height: 12),
                _bone(48, r: AppRadius.button),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Error ────────────────────────────────────────────────────────────────────

class _CertificateDetailError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _CertificateDetailError({
    required this.message,
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
                color: AppColors.primary.withOpacity(0.10),
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
                // §2: Headline 1 ~22px, pakai 18 untuk konteks error
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
                // §2: textSecondary = rgba(255,255,255,0.65)
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
                  borderRadius: BorderRadius.circular(AppRadius.button),
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
                    color: AppColors.textPrimary,
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