import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/models/ebook_model.dart';
import '../providers/ebook_provider.dart';

// ─── Design Tokens (Berdasarkan DESIGN_SYSTEM.md) ─────────────────────────────

const _kRed = Color(0xFFDB202C); // Primary / Red
const _kBg = Color(0xFF060908); // Neutral / Black (Background Utama)
const _kHeaderBg = Color(0xFF141110); // Neutral / Black (Header)
const _kSurface = Color(0xFF120F0E); // Neutral / Black (Card/Panel)
const _kSurfaceElevated = Color(0xFF281D16); // Neutral / Brown (Elevated/Hover)
const _kDivider = Color(0x4DFFFFFF); // rgba(255,255,255,0.3)
const _kTextPrimary = Color(0xFFFFFFFF); // Neutral / White
const _kTextSecondary = Color(0xA6FFFFFF); // Transparent White 65% (Metadata)
const _kTextMuted = Color(0x73FFFFFF); // Transparent White 45% (Placeholder/Disabled)

// ─── Main Screen ──────────────────────────────────────────────────────────────

class EbookDetailScreen extends ConsumerWidget {
  final int ebookId;

  const EbookDetailScreen({super.key, required this.ebookId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ebookAsync = ref.watch(ebookDetailProvider(ebookId));

    return Scaffold(
      backgroundColor: _kBg,
      body: ebookAsync.when(
        loading: () => const _EbookDetailSkeleton(),
        error: (e, _) => _EbookDetailError(
          message: e.toString(),
          onRetry: () => ref.invalidate(ebookDetailProvider(ebookId)),
        ),
        data: (ebook) => _EbookDetailContent(ebook: ebook),
      ),
    );
  }
}

// ─── Content ──────────────────────────────────────────────────────────────────

class _EbookDetailContent extends StatefulWidget {
  final EbookItem ebook;

  const _EbookDetailContent({required this.ebook});

  @override
  State<_EbookDetailContent> createState() => _EbookDetailContentState();
}

class _EbookDetailContentState extends State<_EbookDetailContent>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));

    Future.delayed(const Duration(milliseconds: 80), () {
      if (mounted) _ctrl.forward();
    });
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
    final ebook = widget.ebook;

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // ── App Bar ──
        SliverAppBar(
          backgroundColor: _kHeaderBg.withOpacity(0.95),
          expandedHeight: 0,
          floating: true,
          snap: true,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: _kTextPrimary, size: 24),
            onPressed: () => context.pop(),
          ),
          title: const Text(
            'Ebook Detail',
            style: TextStyle(
              color: _kTextPrimary,
              fontSize: 24, // Title 2
              fontWeight: FontWeight.w600,
              fontFamily: 'Montserrat',
            ),
          ),
        ),

        // ── Body ──
        SliverToBoxAdapter(
          child: FadeTransition(
            opacity: _fadeAnim,
            child: SlideTransition(
              position: _slideAnim,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 48), // Padding horiz. standar (16px)
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Card Detail Buku
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: _kSurface,
                        borderRadius: BorderRadius.circular(4), // Border radius desain: 4px
                        border: Border.all(color: _kDivider, width: 0.8),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x66000000),
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0x1ADB202C),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: const Color(0x4DDB202C)),
                            ),
                            child: const Icon(Icons.menu_book_rounded,
                                color: _kRed, size: 28),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            ebook.title,
                            style: const TextStyle(
                              color: _kTextPrimary,
                              fontSize: 24, // Title 2
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Montserrat',
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            ebook.fileName ?? 'Ebook file',
                            style: const TextStyle(
                              color: _kTextSecondary,
                              fontSize: 14, // Body
                              fontFamily: 'Montserrat',
                            ),
                          ),
                          const SizedBox(height: 24),
                          const Divider(color: _kDivider, height: 1),
                          const SizedBox(height: 16),
                          _DetailRow(
                              label: 'Preview',
                              value: ebook.previewSupported ? 'Available' : 'Unavailable'),
                          _DetailRow(
                              label: 'Format',
                              value: (ebook.mimeType ?? '-').split('/').last.toUpperCase()),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Actions
                    if (ebook.previewUrl != null)
                      SizedBox(
                        width: double.infinity,
                        height: 48, // Tinggi tombol minimum 48px
                        child: ElevatedButton.icon(
                          onPressed: () => _openUrl(ebook.previewUrl!),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _kRed,
                            foregroundColor: _kTextPrimary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4), // Radius 4px
                            ),
                            elevation: 0,
                          ),
                          icon: const Icon(Icons.open_in_new_rounded, size: 18),
                          label: const Text(
                            'Preview Ebook',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'Montserrat',
                            ),
                          ),
                        ),
                      ),
                    if (ebook.downloadUrl != null) ...[
                      const SizedBox(height: 12), // Gutter antar elemen 8px/12px
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: OutlinedButton.icon(
                          onPressed: () => _openUrl(ebook.downloadUrl!),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: _kTextPrimary,
                            side: const BorderSide(color: _kDivider, width: 1.2),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4), // Radius 4px
                            ),
                          ),
                          icon: const Icon(Icons.download_rounded, size: 18),
                          label: const Text(
                            'Download Ebook',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Montserrat',
                            ),
                          ),
                        ),
                      ),
                    ],
                    if (!ebook.previewSupported && ebook.previewMessage != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _kSurface,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: _kDivider),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.info_outline_rounded,
                                color: _kTextMuted, size: 18),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                ebook.previewMessage!,
                                style: const TextStyle(
                                  color: _kTextMuted,
                                  fontSize: 12,
                                  fontFamily: 'Montserrat',
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                color: _kTextMuted,
                fontSize: 14,
                fontFamily: 'Montserrat',
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: _kTextPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                fontFamily: 'Montserrat',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Skeleton ─────────────────────────────────────────────────────────────────

class _EbookDetailSkeleton extends StatefulWidget {
  const _EbookDetailSkeleton();

  @override
  State<_EbookDetailSkeleton> createState() => _EbookDetailSkeletonState();
}

class _EbookDetailSkeletonState extends State<_EbookDetailSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.0, end: 1.0).animate(
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
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) {
        final shimmer = Color.lerp(_kSurface, _kSurfaceElevated, _anim.value)!;
        return CustomScrollView(
          physics: const NeverScrollableScrollPhysics(),
          slivers: [
            SliverAppBar(
              backgroundColor: _kHeaderBg,
              floating: true,
              snap: true,
              leading: Container(
                margin: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: shimmer,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              title: _Bone(width: 140, height: 24, color: shimmer),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 20),
                child: Column(
                  children: [
                    _Bone(width: double.infinity, height: 260, color: shimmer),
                    const SizedBox(height: 24),
                    _Bone(width: double.infinity, height: 48, color: shimmer),
                    const SizedBox(height: 12),
                    _Bone(width: double.infinity, height: 48, color: shimmer),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _Bone extends StatelessWidget {
  final double width;
  final double height;
  final Color color;
  const _Bone({required this.width, required this.height, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

// ─── Error ────────────────────────────────────────────────────────────────────

class _EbookDetailError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _EbookDetailError({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: const Color(0x1ADB202C),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0x4DDB202C)),
              ),
              child: const Icon(Icons.wifi_off_rounded, color: _kRed, size: 28),
            ),
            const SizedBox(height: 20),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: _kTextMuted,
                fontSize: 14,
                fontFamily: 'Montserrat',
                height: 1.5,
              ),
            ),
            const SizedBox(height: 28),
            InkWell(
              onTap: onRetry,
              borderRadius: BorderRadius.circular(4),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: _kRed,
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x4DDB202C),
                      blurRadius: 12,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.refresh_rounded, color: _kTextPrimary, size: 16),
                    SizedBox(width: 8),
                    Text(
                      'Try again',
                      style: TextStyle(
                        color: _kTextPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Montserrat',
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