import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/models/dialog_model.dart';
import '../providers/dialog_provider.dart';

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

// ─── Root Screen ──────────────────────────────────────────────────────────────

class DialogListScreen extends ConsumerWidget {
  const DialogListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dialogsAsync = ref.watch(dialogListProvider);

    return Scaffold(
      backgroundColor: _kBg,
      body: dialogsAsync.when(
        loading: () => const _DialogListSkeleton(),
        error: (e, _) => _DialogError(
          message: e.toString(),
          onRetry: () => ref.invalidate(dialogListProvider),
        ),
        data: (data) => _DialogListContent(data: data),
      ),
    );
  }
}

// ─── Content ──────────────────────────────────────────────────────────────────

class _DialogListContent extends ConsumerStatefulWidget {
  final DialogListData data;
  const _DialogListContent({required this.data});

  @override
  ConsumerState<_DialogListContent> createState() => _DialogListContentState();
}

class _DialogListContentState extends ConsumerState<_DialogListContent>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late List<Animation<double>> _fades;
  late List<Animation<Offset>> _slides;

  @override
  void initState() {
    super.initState();
    final count = widget.data.items.length + 1; // +1 for header
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fades = List.generate(
      count,
          (i) => Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
          parent: _ctrl,
          curve: Interval(i * 0.1, (i * 0.1 + 0.5).clamp(0, 1),
              curve: Curves.easeOut),
        ),
      ),
    );
    _slides = List.generate(
      count,
          (i) => Tween<Offset>(
        begin: const Offset(0, 0.07),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: _ctrl,
          curve: Interval(i * 0.1, (i * 0.1 + 0.5).clamp(0, 1),
              curve: Curves.easeOut),
        ),
      ),
    );
    Future.delayed(const Duration(milliseconds: 60), () {
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
    return RefreshIndicator(
      color: _kTextPrimary,
      backgroundColor: _kRed,
      onRefresh: () async {
        ref.invalidate(dialogListProvider);
        await ref.read(dialogListProvider.future);
      },
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: [
          // ── App Bar ──
          SliverAppBar(
            backgroundColor: _kHeaderBg.withOpacity(0.95),
            expandedHeight: 0,
            floating: true,
            snap: true,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back,
                color: _kTextPrimary,
                size: 24,
              ),
              onPressed: () => context.pop(),
            ),
            title: const Text(
              'Dialogs',
              style: TextStyle(
                color: _kTextPrimary,
                fontSize: 24, // Title 2 / Semi Bold
                fontWeight: FontWeight.w600,
                fontFamily: 'Montserrat',
              ),
            ),
          ),

          // ── Body ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 48), // Padding horizontal 4% (~16px)
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Section label
                  FadeTransition(
                    opacity: _fades[0],
                    child: SlideTransition(
                      position: _slides[0],
                      child: const _SectionLabel(text: 'Available Content'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Cards
                  ...widget.data.items.asMap().entries.map((entry) {
                    final i = entry.key + 1;
                    final item = entry.value;
                    return FadeTransition(
                      opacity: _fades[i],
                      child: SlideTransition(
                        position: _slides[i],
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 8), // Grid dasar 8px
                          child: _DialogCard(item: item),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Dialog Card ──────────────────────────────────────────────────────────────

class _DialogCard extends StatefulWidget {
  final DialogItem item;
  const _DialogCard({required this.item});

  @override
  State<_DialogCard> createState() => _DialogCardState();
}

class _DialogCardState extends State<_DialogCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _pressCtrl;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _pressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 160),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.975).animate(
      CurvedAnimation(parent: _pressCtrl, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _pressCtrl.dispose();
    super.dispose();
  }

  static String _plainText(String html) {
    return html
        .replaceAll(RegExp(r'<[^>]*>'), ' ')
        .replaceAll('&nbsp;', ' ')
        .trim();
  }

  static String _routeKey(String key) {
    return key == 'full_standing' ? 'full-standing' : 'full-floor';
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final preview = item.hasContent ? _plainText(item.content) : null;

    return GestureDetector(
      onTap: () => context.push('/dialogs/${_routeKey(item.key)}'),
      onTapDown: (_) => _pressCtrl.forward(),
      onTapUp: (_) => _pressCtrl.reverse(),
      onTapCancel: () => _pressCtrl.reverse(),
      child: ScaleTransition(
        scale: _scaleAnim,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _kSurface, // Sesuai dengan default card state
            borderRadius: BorderRadius.circular(4), // Radius 4px sesuai desain sistem
            border: Border.all(color: _kDivider, width: 0.8),
            boxShadow: const [
              BoxShadow(
                color: Color(0x66000000), // Shadow subtle untuk non-hover
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0x1ADB202C), // Red transparan tipis
                  borderRadius: BorderRadius.circular(4), // Radius 4px
                  border: Border.all(
                    color: const Color(0x4DDB202C),
                    width: 0.8,
                  ),
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  color: _kRed,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              // Text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: const TextStyle(
                        color: _kTextPrimary,
                        fontSize: 16, // Body/Sub-header (Regular/Medium)
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      preview ?? 'No content available yet.',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: preview != null ? _kTextSecondary : _kTextMuted,
                        fontSize: 14, // Body
                        fontFamily: 'Montserrat',
                        height: 1.5,
                        fontStyle: preview != null
                            ? FontStyle.normal
                            : FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Chevron
              const Icon(
                Icons.chevron_right_rounded,
                color: _kTextMuted,
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Shared Widgets ───────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 14,
          decoration: BoxDecoration(
            color: _kRed,
            borderRadius: BorderRadius.circular(2), // Badge/label kecil = 2px
          ),
        ),
        const SizedBox(width: 8),
        Text(
          text.toUpperCase(),
          style: const TextStyle(
            color: _kTextSecondary,
            fontSize: 14, // Headline 2
            fontWeight: FontWeight.w600,
            fontFamily: 'Montserrat',
            letterSpacing: 1.5,
          ),
        ),
      ],
    );
  }
}

// ─── Skeleton ─────────────────────────────────────────────────────────────────

class _DialogListSkeleton extends StatefulWidget {
  const _DialogListSkeleton();

  @override
  State<_DialogListSkeleton> createState() => _DialogListSkeletonState();
}

class _DialogListSkeletonState extends State<_DialogListSkeleton>
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
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              title: _Bone(width: 120, height: 24, color: shimmer),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Bone(width: 140, height: 14, color: shimmer),
                    const SizedBox(height: 16),
                    ...List.generate(
                      3,
                          (_) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _Bone(
                          width: double.infinity,
                          height: 96,
                          color: shimmer,
                        ),
                      ),
                    ),
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
        borderRadius: BorderRadius.circular(4), // Radius 4px untuk elemen placeholder
      ),
    );
  }
}

// ─── Error ────────────────────────────────────────────────────────────────────

class _DialogError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _DialogError({required this.message, required this.onRetry});

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
                fontSize: 14, // Body 14px
                fontFamily: 'Montserrat',
                height: 1.5,
              ),
            ),
            const SizedBox(height: 28),
            InkWell(
              onTap: onRetry,
              borderRadius: BorderRadius.circular(4),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: _kRed,
                  borderRadius: BorderRadius.circular(4), // Tombol CTA 4px
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
                    Icon(Icons.refresh_rounded, color: Colors.white, size: 16),
                    SizedBox(width: 8),
                    Text(
                      'Try again',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14, // Small Button (Bold 14)
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