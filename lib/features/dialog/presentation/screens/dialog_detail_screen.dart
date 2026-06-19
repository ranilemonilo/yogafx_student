import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/dialog_provider.dart';

// ─── Design Tokens ────────────────────────────────────────────────────────────

const _kRed = Color(0xFFE50914);
const _kBg = Color(0xFF0D0D0D);
const _kSurface = Color(0xFF161616);
const _kSurfaceElevated = Color(0xFF1E1E1E);
const _kDivider = Color(0xFF252525);
const _kTextPrimary = Colors.white;
const _kTextSecondary = Color(0xFFB3B3B3);
const _kTextMuted = Color(0xFF6B6B6B);

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
    final content = dialog.content.trim();

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // ── App Bar ──
        SliverAppBar(
          backgroundColor: Colors.transparent,
          expandedHeight: 0,
          floating: true,
          snap: true,
          elevation: 0,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xD0000000), Colors.transparent],
              ),
            ),
          ),
          leading: GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              margin: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
              decoration: BoxDecoration(
                color: _kSurfaceElevated,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: _kDivider, width: 0.8),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: _kTextPrimary,
                size: 15,
              ),
            ),
          ),
          title: Text(
            dialog.title,
            style: const TextStyle(
              color: _kTextPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w700,
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
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 48),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Section label
                    Row(
                      children: [
                        Container(
                          width: 3,
                          height: 12,
                          decoration: BoxDecoration(
                            color: _kRed,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'MESSAGE CONTENT',
                          style: TextStyle(
                            color: _kTextMuted,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Montserrat',
                            letterSpacing: 2,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Content card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: _kSurfaceElevated,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: _kDivider, width: 0.8),
                      ),
                      child: content.isEmpty
                          ? Row(
                        children: const [
                          Icon(Icons.info_outline_rounded,
                              color: _kTextMuted, size: 16),
                          SizedBox(width: 10),
                          Text(
                            'No content available yet.',
                            style: TextStyle(
                              color: _kTextMuted,
                              fontSize: 13,
                              fontFamily: 'Montserrat',
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      )
                          : Html(
                        data: content,
                        style: {
                          'body': Style(
                            margin: Margins.zero,
                            padding: HtmlPaddings.zero,
                            color: _kTextSecondary,
                            fontSize: FontSize(13),
                            fontFamily: 'Montserrat',
                            lineHeight: const LineHeight(1.75),
                          ),
                          'p': Style(margin: Margins.only(bottom: 14)),
                        },
                      ),
                    ),
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
        final shimmer =
        Color.lerp(_kSurface, _kSurfaceElevated, _anim.value)!;
        return CustomScrollView(
          slivers: [
            SliverAppBar(
              backgroundColor: _kBg,
              floating: true,
              snap: true,
              leading: Container(
                margin: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
                decoration: BoxDecoration(
                  color: shimmer,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              title: _Bone(width: 140, height: 14, color: shimmer),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Bone(width: 80, height: 9, color: shimmer),
                    const SizedBox(height: 16),
                    _Bone(
                        width: double.infinity,
                        height: 240,
                        color: shimmer),
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
        borderRadius: BorderRadius.circular(6),
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
                color: _kRed.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(color: _kRed.withOpacity(0.25)),
              ),
              child: const Icon(Icons.wifi_off_rounded, color: _kRed, size: 28),
            ),
            const SizedBox(height: 20),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: _kTextSecondary,
                fontSize: 13,
                fontFamily: 'Montserrat',
                height: 1.5,
              ),
            ),
            const SizedBox(height: 28),
            GestureDetector(
              onTap: onRetry,
              child: Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                decoration: BoxDecoration(
                  color: _kRed,
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: [
                    BoxShadow(
                      color: _kRed.withOpacity(0.35),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.refresh_rounded, color: Colors.white, size: 15),
                    SizedBox(width: 6),
                    Text(
                      'Try again',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
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
