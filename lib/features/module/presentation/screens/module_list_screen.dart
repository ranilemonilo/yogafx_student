import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/auth_network_image.dart';
import '../../../../core/widgets/running_login_time_card.dart';
import '../../data/models/module_model.dart';
import '../providers/module_provider.dart';

// ─── Constants ────────────────────────────────────────────────────────────────

const _kNetflixRed = Color(0xFFE50914);
const _kBg = Color(0xFF141414);
const _kSurface = Color(0xFF1F1F1F);
const _kSurfaceElevated = Color(0xFF2A2A2A);
const _kDivider = Color(0xFF2E2E2E);
const _kTextPrimary = Colors.white;
const _kTextSecondary = Color(0xFFB3B3B3);
const _kTextMuted = Color(0xFF737373);
const _kGreenCheck = Color(0xFF46D369);
const _kLockedModuleMessage =
    'This page is not available yet. Please complete the previous module first.';

void _showLockedModuleSnackBar(BuildContext context) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      const SnackBar(
        content: Text(_kLockedModuleMessage),
      ),
    );
}

bool _canOpenModule(String status) {
  final normalizedStatus = status.toLowerCase();
  return normalizedStatus != 'locked' &&
      normalizedStatus != 'unavailable' &&
      normalizedStatus != 'hidden';
}

// ─── Root Screen ──────────────────────────────────────────────────────────────

class ModuleListScreen extends ConsumerWidget {
  const ModuleListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final modulesAsync = ref.watch(moduleListProvider);

    return Scaffold(
      backgroundColor: _kBg,
      body: RefreshIndicator(
        color: _kNetflixRed,
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
      backgroundColor: _kBg,
      floating: true,
      snap: true,
      elevation: 0,
      titleSpacing: 20,
      leading: IconButton(
        onPressed: () => _handleModuleBack(context),
        icon: const Icon(Icons.arrow_back_ios_new,
            color: _kTextPrimary, size: 18),
      ),
      title: const Text(
        'Modules',
        style: TextStyle(
          color: _kTextPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w700,
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
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 48),
      sliver: SliverList(
        delegate: SliverChildListDelegate([
          const Align(
            alignment: Alignment.centerRight,
            child: RunningLoginTimeCard(),
          ),
          const SizedBox(height: 12),
          _animated(0, _SummaryBar(summary: widget.data.summary)),
          const SizedBox(height: 20),
          ...widget.data.items.asMap().entries.map(
                (entry) => _animated(
              entry.key + 1,
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
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
      child: Row(
        children: [
          _SummaryChip(
            label: '${summary.total} modules',
            icon: Icons.layers_outlined,
          ),
          const SizedBox(width: 8),
          _SummaryChip(
            label: '${summary.completed} completed',
            icon: Icons.check_circle_outline,
            highlight: true,
          ),
          const SizedBox(width: 8),
          _SummaryChip(
            label: '${summary.active} active',
            icon: Icons.play_circle_outline,
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: highlight
            ? _kNetflixRed.withOpacity(0.12)
            : _kSurfaceElevated,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: highlight ? _kNetflixRed.withOpacity(0.35) : _kDivider,
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 13,
            color: highlight ? _kNetflixRed : _kTextMuted,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: highlight ? _kNetflixRed : _kTextSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w500,
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
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.985).animate(
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
            borderRadius: BorderRadius.circular(6),
          ),
          clipBehavior: Clip.hardEdge,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Thumbnail ──
              AspectRatio(
                aspectRatio: 16 / 7,
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
                            Colors.black.withOpacity(0.7),
                          ],
                          stops: const [0.4, 1.0],
                        ),
                      ),
                    ),

                    // Status badge — top right
                    Positioned(
                      top: 10,
                      right: 10,
                      child: _StatusBadge(status: module.status),
                    ),

                    // Completed badge — top left
                    if (module.isComplete)
                      Positioned(
                        top: 10,
                        left: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _kGreenCheck.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.check,
                                  color: Colors.white, size: 11),
                              SizedBox(width: 4),
                              Text(
                                'Completed',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Montserrat',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    // Play button center
                    Center(
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: Colors.white.withOpacity(0.6),
                              width: 1.5),
                        ),
                        child: const Icon(
                          Icons.play_arrow,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Info ──
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      module.title,
                      style: const TextStyle(
                        color: _kTextPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Montserrat',
                      ),
                    ),

                    // Description
                    if (module.description != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        module.description!,
                        style: const TextStyle(
                          color: _kTextSecondary,
                          fontSize: 13,
                          fontFamily: 'Montserrat',
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],

                    const SizedBox(height: 12),

                    // Meta row
                    Row(
                      children: [
                        _MetaChip(
                          icon: Icons.play_circle_outline,
                          label: '${module.lessonCount} lessons',
                        ),
                        if (module.assignmentsCount > 0) ...[
                          const SizedBox(width: 12),
                          _MetaChip(
                            icon: Icons.assignment_outlined,
                            label: '${module.assignmentsCount} assignments',
                          ),
                        ],
                        if (module.certificateEnabled) ...[
                          const SizedBox(width: 12),
                          const _MetaChip(
                            icon: Icons.workspace_premium_outlined,
                            label: 'Certificate',
                            accent: true,
                          ),
                        ],
                      ],
                    ),

                    // Progress bar
                    if (module.showProgress) ...[
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(2),
                              child: LinearProgressIndicator(
                                value: module.progressPercentage / 100,
                                backgroundColor: _kDivider,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  module.isComplete
                                      ? _kGreenCheck
                                      : _kNetflixRed,
                                ),
                                minHeight: 3,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            '${module.completedLessons}/${module.lessonCount}',
                            style: const TextStyle(
                              color: _kTextMuted,
                              fontSize: 11,
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
          color: accent ? _kNetflixRed : _kTextMuted,
          size: 14,
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            color: accent ? _kNetflixRed : _kTextMuted,
            fontSize: 12,
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
            const Icon(Icons.play_circle_outline,
                color: _kTextMuted, size: 36),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                title,
                style: const TextStyle(
                  color: _kTextMuted,
                  fontSize: 11,
                  fontFamily: 'Montserrat',
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
        color = _kNetflixRed;
      case 'completed':
        color = _kGreenCheck;
      default:
        color = _kTextMuted;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.65),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.5), width: 0.5),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 9,
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
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Summary chips skeleton
              Row(
                children: [
                  _Bone(width: 90, height: 28, color: c),
                  const SizedBox(width: 8),
                  _Bone(width: 110, height: 28, color: c),
                  const SizedBox(width: 8),
                  _Bone(width: 80, height: 28, color: c),
                ],
              ),
              const SizedBox(height: 20),
              ...List.generate(
                3,
                (_) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _Bone(
                        width: double.infinity,
                        height: 180,
                        color: c,
                        radius: 6,
                      ),
                      const SizedBox(height: 12),
                      _Bone(width: 200, height: 14, color: c),
                      const SizedBox(height: 8),
                      _Bone(width: double.infinity, height: 10, color: c),
                      const SizedBox(height: 6),
                      _Bone(width: 260, height: 10, color: c),
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
            const Icon(Icons.wifi_off_outlined,
                color: _kTextMuted, size: 48),
            const SizedBox(height: 16),
            Text(
              message,
              style: const TextStyle(
                color: _kTextSecondary,
                fontSize: 14,
                fontFamily: 'Montserrat',
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: 140,
              child: ElevatedButton(
                onPressed: onRetry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _kNetflixRed,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Try again',
                  style: TextStyle(fontFamily: 'Montserrat'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
