import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/dialog_provider.dart';

// ─── Design Tokens (Berdasarkan DESIGN_SYSTEM.md) ─────────────────────────────

const _kRed = Color(0xFFDB202C); // Primary / Red
const _kRedHover = Color(0xFFF6121D);
const _kBg = Color(0xFF060908); // Neutral / Black (Background Utama)
const _kHeaderBg = Color(0xFF141110); // Neutral / Black (Header)
const _kSurface = Color(0xFF120F0E); // Neutral / Black (Card/Panel)
const _kSurfaceElevated = Color(0xFF281D16); // Neutral / Brown (Elevated/Hover)
const _kDivider = Color(0x4DFFFFFF); // rgba(255,255,255,0.3)
const _kTextPrimary = Color(0xFFFFFFFF); // Neutral / White
const _kTextSecondary = Color(0xA6FFFFFF); // Transparent White 65% (Metadata)
const _kTextMuted = Color(0x73FFFFFF); // Transparent White 45% (Placeholder/Disabled)

// ─── Main Screen ──────────────────────────────────────────────────────────────

class DialogDetailScreen extends ConsumerWidget {
  final String dialogKey;
  const DialogDetailScreen({super.key, required this.dialogKey});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dialogAsync = ref.watch(dialogDetailProvider(dialogKey));

    return Scaffold(
      backgroundColor: _kBg,
      body: dialogAsync.when(
        loading: () => const _DialogDetailSkeleton(),
        error: (e, _) => _DialogDetailError(
          message: e.toString(),
          onRetry: () => ref.invalidate(dialogDetailProvider(dialogKey)),
        ),
        data: (dialog) => _DialogDetailContent(dialog: dialog),
      ),
    );
  }
}

// ─── Content ──────────────────────────────────────────────────────────────────

class _DialogDetailContent extends StatefulWidget {
  final dynamic dialog;
  const _DialogDetailContent({required this.dialog});

  @override
  State<_DialogDetailContent> createState() => _DialogDetailContentState();
}

class _DialogDetailContentState extends State<_DialogDetailContent>
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

  @override
  Widget build(BuildContext context) {
    final dialog = widget.dialog;
    final content = (dialog.content as String?)?.trim() ?? '';

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // ── App Bar ──
        SliverAppBar(
          backgroundColor: _kHeaderBg.withOpacity(0.9),
          expandedHeight: 0,
          floating: true,
          snap: true,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back, // Menggunakan outline tipis monokrom putih
              color: _kTextPrimary,
              size: 24,
            ),
            onPressed: () => context.pop(),
          ),
          title: Text(
            dialog.title,
            style: const TextStyle(
              color: _kTextPrimary,
              fontSize: 24, // Semi Bold / Title 2
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
                padding: const EdgeInsets.fromLTRB(4.0, 24, 4.0, 48), // Padding horizontal direkomendasikan 4% (bisa disesuaikan dengan media query, di sini disederhanakan)
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Section label
                      Row(
                        children: [
                          Container(
                            width: 4,
                            height: 14,
                            decoration: BoxDecoration(
                              color: _kRed,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'MESSAGE CONTENT',
                            style: TextStyle(
                              color: _kTextSecondary,
                              fontSize: 14, // Semi Bold / Headline 2
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Montserrat',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      content.isEmpty
                          ? Row(
                        children: const [
                          Icon(Icons.info_outline_rounded,
                              color: _kTextMuted, size: 16),
                          SizedBox(width: 10),
                          Text(
                            'No content available yet.',
                            style: TextStyle(
                              color: _kTextMuted,
                              fontSize: 14, // Regular / Body
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      )
                          : Html(
                        data: content,
                        style: {
                          'html': Style(
                            margin: Margins.zero,
                            padding: HtmlPaddings.zero,
                            color: _kTextSecondary,
                            fontFamily: 'Montserrat',
                            fontSize: FontSize(14), // Regular / Body
                            fontWeight: FontWeight.w400,
                            lineHeight: const LineHeight(1.5),
                          ),
                          'body': Style(
                            margin: Margins.zero,
                            padding: HtmlPaddings.zero,
                            color: _kTextSecondary,
                            backgroundColor: Colors.transparent,
                          ),
                          'p': Style(
                            margin: Margins.only(bottom: 14),
                          ),
                          'div': Style(
                            margin: Margins.only(bottom: 14),
                          ),
                          'strong': Style(
                            fontWeight: FontWeight.w700,
                            color: _kTextPrimary,
                          ),
                          'b': Style(
                            fontWeight: FontWeight.w700,
                            color: _kTextPrimary,
                          ),
                          'h1': Style(
                            margin: Margins.only(bottom: 16),
                            fontFamily: 'Montserrat',
                            fontSize: FontSize(36), // Semi Bold / Header
                            fontWeight: FontWeight.w600,
                            color: _kTextPrimary,
                            letterSpacing: -0.5,
                          ),
                          'h2': Style(
                            margin: Margins.only(bottom: 14),
                            fontFamily: 'Montserrat',
                            fontSize: FontSize(28), // Semi Bold / Title 1
                            fontWeight: FontWeight.w600,
                            color: _kTextPrimary,
                          ),
                          'h3': Style(
                            margin: Margins.only(bottom: 12),
                            fontFamily: 'Montserrat',
                            fontSize: FontSize(24), // Semi Bold / Title 2
                            fontWeight: FontWeight.w600,
                            color: _kTextPrimary,
                          ),
                          'ul': Style(
                            margin: Margins.only(bottom: 14, left: 14),
                            padding: HtmlPaddings.zero,
                          ),
                          'ol': Style(
                            margin: Margins.only(bottom: 14, left: 14),
                            padding: HtmlPaddings.zero,
                          ),
                          'li': Style(
                            margin: Margins.only(bottom: 8),
                          ),
                          'blockquote': Style(
                            color: _kTextSecondary,
                            backgroundColor: _kSurface,
                            border: Border(
                              left: BorderSide(
                                color: _kRed,
                                width: 3,
                              ),
                            ),
                            padding: HtmlPaddings.only(left: 14, top: 8, bottom: 8),
                            margin: Margins.only(bottom: 14),
                          ),
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Skeleton ─────────────────────────────────────────────────────────────────

class _DialogDetailSkeleton extends StatefulWidget {
  const _DialogDetailSkeleton();

  @override
  State<_DialogDetailSkeleton> createState() => _DialogDetailSkeletonState();
}

class _DialogDetailSkeletonState extends State<_DialogDetailSkeleton>
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
          slivers: [
            SliverAppBar(
              backgroundColor: _kHeaderBg,
              floating: true,
              snap: true,
              leading: Container(
                margin: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: shimmer,
                  borderRadius: BorderRadius.circular(4), // Border radius sesuai guideline (4px)
                ),
              ),
              title: _Bone(width: 140, height: 24, color: shimmer),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Bone(width: 120, height: 14, color: shimmer),
                    const SizedBox(height: 16),
                    _Bone(width: double.infinity, height: 240, color: shimmer),
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
        borderRadius: BorderRadius.circular(4), // Border radius card standar (4px)
      ),
    );
  }
}

// ─── Error ────────────────────────────────────────────────────────────────────

class _DialogDetailError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _DialogDetailError(
      {required this.message, required this.onRetry});

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
                color: const Color(0x1ADB202C), // Transparan merah tipis
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
                fontSize: 14, // Regular / Body
                fontFamily: 'Montserrat',
                height: 1.5,
              ),
            ),
            const SizedBox(height: 28),
            // Tombol Action - Small / Default
            InkWell(
              onTap: onRetry,
              borderRadius: BorderRadius.circular(4),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: _kRed,
                  borderRadius: BorderRadius.circular(4), // Border radius (4px)
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
                        fontSize: 14, // Small Button (14px Bold)
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