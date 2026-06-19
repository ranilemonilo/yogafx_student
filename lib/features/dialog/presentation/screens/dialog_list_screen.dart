import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/models/dialog_model.dart';
import '../providers/dialog_provider.dart';

// ─── Design Tokens ────────────────────────────────────────────────────────────

const _kRed = Color(0xFFE50914);
const _kBg = Color(0xFF0D0D0D);
const _kSurface = Color(0xFF161616);
const _kSurfaceElevated = Color(0xFF1E1E1E);
const _kSurfaceHigh = Color(0xFF262626);
const _kDivider = Color(0xFF252525);
const _kTextPrimary = Colors.white;
const _kTextSecondary = Color(0xFFB3B3B3);
const _kTextMuted = Color(0xFF6B6B6B);

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
      color: _kRed,
      backgroundColor: _kSurfaceElevated,
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
            title: const Text(
              'Dialogs',
              style: TextStyle(
                color: _kTextPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w700,
                fontFamily: 'Montserrat',
              ),
            ),
          ),

          // ── Body ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 48),
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
                          padding: const EdgeInsets.only(bottom: 12),
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
            color: _kSurfaceElevated,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: _kDivider, width: 0.8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // Icon
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: _kRed.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _kRed.withOpacity(0.22),
                    width: 0.8,
                  ),
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  color: _kRed,
                  size: 20,
                ),
              ),
              const SizedBox(width: 14),
              // Text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: const TextStyle(
                        color: _kTextPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      preview ?? 'No content available yet.',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: preview != null ? _kTextSecondary : _kTextMuted,
                        fontSize: 12,
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
              const SizedBox(width: 10),
              // Chevron
              const Icon(
                Icons.chevron_right_rounded,
                color: _kTextMuted,
                size: 20,
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
          width: 3,
          height: 12,
          decoration: BoxDecoration(
            color: _kRed,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          text.toUpperCase(),
          style: const TextStyle(
            color: _kTextMuted,
            fontSize: 9,
            fontWeight: FontWeight.w700,
            fontFamily: 'Montserrat',
            letterSpacing: 2,
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
        final shimmer =
        Color.lerp(_kSurface, _kSurfaceHigh, _anim.value)!;
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
              title: _Bone(width: 80, height: 14, color: shimmer),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Bone(width: 100, height: 9, color: shimmer),
                    const SizedBox(height: 16),
                    ...List.generate(
                      3,
                          (_) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _Bone(
                          width: double.infinity,
                          height: 80,
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
        borderRadius: BorderRadius.circular(6),
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
