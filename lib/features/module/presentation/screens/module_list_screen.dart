import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/widgets/auth_network_image.dart';
import '../../../../core/widgets/running_login_time_card.dart';
import '../../data/models/module_model.dart';
import '../providers/module_provider.dart';

// ─── Design Tokens (Berdasarkan DESIGN_SYSTEM.md) ─────────────────────────────

const _kRed = Color(0xFFDB202C); // Primary / Red
const _kGreen = Color(0xFF00B14F); // Secondary / Emerald (Sukses/Completed)
const _kBg = Color(0xFF060908); // Neutral / Black (Background Utama)
const _kHeaderBg = Color(0xFF141110); // Neutral / Black (Header)
const _kSurface = Color(0xFF120F0E); // Neutral / Black (Card/Panel)
const _kSurfaceElevated = Color(0xFF281D16); // Neutral / Brown (Elevated/Hover)
const _kDivider = Color(0x4DFFFFFF); // rgba(255,255,255,0.3)
const _kTextPrimary = Color(0xFFFFFFFF); // Neutral / White
const _kTextSecondary = Color(0xA6FFFFFF); // Transparent White 65% (Metadata)
const _kTextMuted = Color(0x73FFFFFF); // Transparent White 45% (Placeholder/Disabled)

const _kLockedModuleMessage =
    'This page is not available yet. Please complete the previous module first.';

void _showLockedModuleSnackBar(BuildContext context) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: const Text(
          _kLockedModuleMessage,
          style: TextStyle(fontFamily: 'Montserrat'),
        ),
        backgroundColor: _kSurfaceElevated,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
}

bool _canOpenModule(String status) {
  final normalizedStatus = status.toLowerCase();
  return normalizedStatus != 'locked' &&
      normalizedStatus != 'unavailable' &&
      normalizedStatus != 'hidden';
}

// (Logika _isLessonModule dan _moduleTypeLabel sudah dihapus karena kita pakai viewTypes dari Backend)

// ─── Root Screen ──────────────────────────────────────────────────────────────

class ModuleListScreen extends ConsumerWidget {
  const ModuleListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final modulesAsync = ref.watch(moduleListProvider);

    return Scaffold(
      backgroundColor: _kBg,
      body: RefreshIndicator(
        color: _kRed,
        backgroundColor: _kSurface,
        onRefresh: () async {
          ref.invalidate(moduleListProvider);
          await ref.read(moduleListProvider.future);
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            _NetflixAppBar(),
            modulesAsync.when(
              loading: () => const SliverFillRemaining(
                child: _ModuleListSkeleton(),
              ),
              error: (e, _) => SliverFillRemaining(
                child: _ModuleListError(
                  message: e.toString(),
                  onRetry: () => ref.invalidate(moduleListProvider),
                ),
              ),
              data: (data) => _ModuleListContent(data: data),
            ),
          ],
        ),
      ),
    );
  }
}

void _handleModuleBack(BuildContext context) {
  if (Navigator.of(context).canPop()) {
    context.pop();
    return;
  }
  context.go(AppRoutes.dashboard);
}

// ─── App Bar ──────────────────────────────────────────────────────────────────

class _NetflixAppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      backgroundColor: _kHeaderBg.withOpacity(0.95),
      floating: true,
      snap: true,
      elevation: 0,
      titleSpacing: 8,
      leading: IconButton(
        onPressed: () => _handleModuleBack(context),
        icon: const Icon(Icons.arrow_back, color: _kTextPrimary, size: 24),
      ),
      title: const Text(
        'Modules',
        style: TextStyle(
          color: _kTextPrimary,
          fontSize: 24, // Title 2
          fontWeight: FontWeight.w600,
          fontFamily: 'Montserrat',
        ),
      ),
    );
  }
}

// ─── Content ──────────────────────────────────────────────────────────────────

class _ModuleListContent extends StatefulWidget {
  final ModuleListData data;

  const _ModuleListContent({required this.data});

  @override
  State<_ModuleListContent> createState() => _ModuleListContentState();
}

class _ModuleListContentState extends State<_ModuleListContent>
    with TickerProviderStateMixin {
  late final List<AnimationController> _controllers;
  late final List<Animation<double>> _fades;
  late final List<Animation<Offset>> _slides;

  @override
  void initState() {
    super.initState();
    final count = widget.data.items.length + 1; // +1 for summary bar
    _controllers = List.generate(
      count,
          (i) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 420),
      ),
    );
    _fades = _controllers
        .map((c) => CurvedAnimation(parent: c, curve: Curves.easeOut))
        .toList();
    _slides = _controllers
        .map((c) => Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: c, curve: Curves.easeOut)))
        .toList();

    for (int i = 0; i < count; i++) {
      Future.delayed(Duration(milliseconds: 60 * i), () {
        if (mounted) _controllers[i].forward();
      });
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  Widget _animated(int index, Widget child) {
    if (index >= _fades.length) return child;
    return FadeTransition(
      opacity: _fades[index],
      child: SlideTransition(position: _slides[index], child: child),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 48), // Horizontal margin 4% (~16px)
      sliver: SliverList(
        delegate: SliverChildListDelegate([
          const Align(
            alignment: Alignment.centerRight,
            child: RunningLoginTimeCard(),
          ),
          const SizedBox(height: 16),
          _animated(0, _SummaryBar(summary: widget.data.summary)),
          const SizedBox(height: 24),
          ...widget.data.items.asMap().entries.map(
                (entry) => _animated(
              entry.key + 1,
              Padding(
                padding: const EdgeInsets.only(bottom: 16), // Gutter kelipatan 8
                child: _ModuleCard(module: entry.value),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}

// ─── Summary Bar ─────────────────────────────────────────────────────────────

class _SummaryBar extends StatelessWidget {
  final ModuleListSummary summary;

  const _SummaryBar({required this.summary});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          _SummaryChip(
            label: '${summary.total} modules',
            icon: Icons.layers_rounded,
          ),
          const SizedBox(width: 8), // Gutter
          _SummaryChip(
            label: '${summary.completed} completed',
            icon: Icons.check_circle_rounded,
            highlight: true,
          ),
          const SizedBox(width: 8),
          _SummaryChip(
            label: '${summary.active} active',
            icon: Icons.play_circle_outline_rounded,
          ),
        ],
      ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool highlight;

  const _SummaryChip({
    required this.label,
    required this.icon,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: highlight
            ? const Color(0x1ADB202C) // Transparan Red
            : _kSurfaceElevated,
        borderRadius: BorderRadius.circular(4), // Radius tombol/chip 4px
        border: Border.all(
          color: highlight ? const Color(0x4DDB202C) : _kDivider,
          width: 0.8,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: highlight ? _kRed : _kTextMuted,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: highlight ? _kRed : _kTextSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              fontFamily: 'Montserrat',
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Module Card ──────────────────────────────────────────────────────────────

class _ModuleCard extends StatefulWidget {
  final ModuleItem module;

  const _ModuleCard({required this.module});

  @override
  State<_ModuleCard> createState() => _ModuleCardState();
}

class _ModuleCardState extends State<_ModuleCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _pressCtrl;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _pressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _pressCtrl, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _pressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final module = widget.module;
    final canOpen = _canOpenModule(module.status);

    return GestureDetector(
      onTap: () {
        if (!canOpen) {
          _showLockedModuleSnackBar(context);
          return;
        }
        context.push('/modules/${module.id}');
      },
      onTapDown: canOpen ? (_) => _pressCtrl.forward() : null,
      onTapUp: canOpen ? (_) => _pressCtrl.reverse() : null,
      onTapCancel: canOpen ? () => _pressCtrl.reverse() : null,
      child: ScaleTransition(
        scale: _scaleAnim,
        child: Container(
          decoration: BoxDecoration(
            color: _kSurface,
            borderRadius: BorderRadius.circular(4), // Radius Card 4px
            border: Border.all(color: _kDivider, width: 0.8),
            boxShadow: const [
              BoxShadow(
                color: Color(0x66000000), // Shadow Depth
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          clipBehavior: Clip.hardEdge,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Thumbnail ──
              AspectRatio(
                aspectRatio: 16 / 9, // Sesuai design system (16:9)
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Image
                    module.thumbnailUrl != null
                        ? AuthNetworkImage(
                      imageUrl: module.thumbnailUrl!,
                      fit: BoxFit.cover,
                      placeholderBuilder: (_) =>
                          _ThumbnailPlaceholder(title: module.title),
                      errorBuilderWidget: (_, __) =>
                          _ThumbnailPlaceholder(title: module.title),
                    )
                        : _ThumbnailPlaceholder(title: module.title),

                    // Bottom gradient
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.8),
                          ],
                          stops: const [0.5, 1.0],
                        ),
                      ),
                    ),

                    // Status badge — top right
                    Positioned(
                      top: 12,
                      right: 12,
                      child: _StatusBadge(status: module.status),
                    ),

                    // Completed badge — top left
                    if (module.isComplete)
                      Positioned(
                        top: 12,
                        left: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _kGreen.withOpacity(0.95),
                            borderRadius: BorderRadius.circular(2), // Badge Radius 2px
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.check_rounded,
                                  color: Colors.white, size: 14),
                              SizedBox(width: 4),
                              Text(
                                'Completed',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  fontFamily: 'Montserrat',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    // Play button center
                    if (canOpen)
                      Center(
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.45),
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: Colors.white.withOpacity(0.8),
                                width: 1.5),
                          ),
                          child: const Icon(
                            Icons.play_arrow_rounded,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // ── Info ──
              Padding(
                padding: const EdgeInsets.all(16), // Padding 16px
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      module.title,
                      style: const TextStyle(
                        color: _kTextPrimary,
                        fontSize: 18, // Title 3 Equivalent
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Montserrat',
                      ),
                    ),

                    // Description
                    if (module.description != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        module.description!,
                        style: const TextStyle(
                          color: _kTextSecondary,
                          fontSize: 14,
                          fontFamily: 'Montserrat',
                          height: 1.5,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],

                    const SizedBox(height: 16),

                    // Meta row (menggunakan viewTypes dari Backend)
                    Wrap(
                      spacing: 16,
                      runSpacing: 8,
                      children: [
                        if (module.viewTypes.contains('certificate'))
                          const _MetaChip(
                            icon: Icons.workspace_premium_outlined,
                            label: 'Certificate',
                            accent: true,
                          ),
                        if (module.viewTypes.contains('ebook'))
                          const _MetaChip(
                            icon: Icons.menu_book_rounded,
                            label: 'Ebook',
                          ),
                        if (module.viewTypes.contains('video_lecturer'))
                          const _MetaChip(
                            icon: Icons.play_circle_fill_rounded,
                            label: 'Video Lecturer',
                          ),
                        if (module.viewTypes.contains('lesson'))
                          _MetaChip(
                            icon: Icons.play_circle_outline_rounded,
                            label: '${module.lessonCount} lessons',
                          ),
                        if (module.viewTypes.contains('assignment') &&
                            module.assignmentsCount > 0)
                          _MetaChip(
                            icon: Icons.assignment_outlined,
                            label: '${module.assignmentsCount} assignments',
                          ),
                      ],
                    ),

                    // Progress bar
                    if (module.showProgress) ...[
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(2), // Bar radius 2px
                              child: LinearProgressIndicator(
                                value: module.progressPercentage / 100,
                                backgroundColor: _kDivider,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  module.isComplete ? _kGreen : _kRed,
                                ),
                                minHeight: 4, // Sedikit ditebalkan
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            '${module.completedLessons}/${module.lessonCount}',
                            style: const TextStyle(
                              color: _kTextMuted,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Montserrat',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Meta Chip ────────────────────────────────────────────────────────────────

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool accent;

  const _MetaChip({
    required this.icon,
    required this.label,
    this.accent = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: accent ? _kRed : _kTextMuted,
          size: 16,
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            color: accent ? _kRed : _kTextSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w500,
            fontFamily: 'Montserrat',
          ),
        ),
      ],
    );
  }
}

// ─── Thumbnail Placeholder ────────────────────────────────────────────────────

class _ThumbnailPlaceholder extends StatelessWidget {
  final String title;

  const _ThumbnailPlaceholder({required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _kSurfaceElevated,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.movie_creation_outlined,
                color: _kTextMuted, size: 40),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                title,
                style: const TextStyle(
                  color: _kTextMuted,
                  fontSize: 12,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Status Badge ─────────────────────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status.toLowerCase()) {
      case 'active':
        color = _kRed;
        break;
      case 'completed':
        color = _kGreen;
        break;
      default:
        color = _kTextMuted;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.65),
        borderRadius: BorderRadius.circular(2), // Badge radius 2px
        border: Border.all(color: color.withOpacity(0.5), width: 0.8),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w700,
          fontFamily: 'Montserrat',
          letterSpacing: 1,
        ),
      ),
    );
  }
}

// ─── Skeleton ─────────────────────────────────────────────────────────────────

class _ModuleListSkeleton extends StatefulWidget {
  const _ModuleListSkeleton();

  @override
  State<_ModuleListSkeleton> createState() => _ModuleListSkeletonState();
}

class _ModuleListSkeletonState extends State<_ModuleListSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.3, end: 0.7).animate(
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
      builder: (context, _) {
        final c = Color.lerp(_kSurface, _kSurfaceElevated, _anim.value)!;
        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Summary chips skeleton
              Row(
                children: [
                  _Bone(width: 100, height: 32, color: c),
                  const SizedBox(width: 8),
                  _Bone(width: 120, height: 32, color: c),
                  const SizedBox(width: 8),
                  _Bone(width: 90, height: 32, color: c),
                ],
              ),
              const SizedBox(height: 24),
              ...List.generate(
                3,
                    (_) => Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _Bone(
                        width: double.infinity,
                        height: 200,
                        color: c,
                        radius: 4, // Radius card 4px
                      ),
                      const SizedBox(height: 16),
                      _Bone(width: 220, height: 16, color: c),
                      const SizedBox(height: 12),
                      _Bone(width: double.infinity, height: 12, color: c),
                      const SizedBox(height: 8),
                      _Bone(width: 280, height: 12, color: c),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Bone extends StatelessWidget {
  final double width;
  final double height;
  final Color color;
  final double radius;

  const _Bone({
    required this.width,
    required this.height,
    required this.color,
    this.radius = 4,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

// ─── Error ────────────────────────────────────────────────────────────────────

class _ModuleListError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ModuleListError({required this.message, required this.onRetry});

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
              style: const TextStyle(
                color: _kTextSecondary,
                fontSize: 14,
                fontFamily: 'Montserrat',
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            InkWell(
              onTap: onRetry,
              borderRadius: BorderRadius.circular(4), // Button radius 4px
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
                child: const Text(
                  'Try again',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Montserrat',
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