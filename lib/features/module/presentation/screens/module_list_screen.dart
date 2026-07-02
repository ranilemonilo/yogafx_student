import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/widgets/auth_network_image.dart';
import '../../../../core/widgets/running_login_time_card.dart';
import '../../../certificate/presentation/providers/certificate_provider.dart';
import '../../data/models/module_model.dart';
import '../providers/module_provider.dart';
import '../../utils/module_access_helper.dart';

// ─── Design Tokens (Sesuai DESIGN_SYSTEM.md & AppColors) ──────────────────────

const _kRed        = Color(0xFFDB202C); // Primary / Red
const _kGreen      = Color(0xFF00B14F); // Secondary / Emerald
const _kBg         = Color(0xFF060908); // Neutral Black 1 — bg utama
const _kHeaderBg   = Color(0xFF141110); // Neutral Black 2 — header
const _kSurface    = Color(0xFF120F0E); // Neutral Black 3 — card/panel
const _kElevated   = Color(0xFF281D16); // Neutral Brown — elevated/hover

const _kTextPrimary   = Color(0xFFFFFFFF);  // White
const _kTextSecondary = Color(0xA6FFFFFF);  // White 65%
const _kTextMuted     = Color(0x73FFFFFF);  // White 45%

const _kDivider    = Color(0x1AFFFFFF);     // White 10% — divider tipis
const _kBorderSoft = Color(0x4DFFFFFF);     // White 30% — border card/input

const _kRedSoft    = Color(0x1ADB202C);     // Red 10%
const _kRedBorder  = Color(0x4DDB202C);     // Red 30%

// Shadow sesuai DS §Catatan Implementasi
const _kShadowCard  = [BoxShadow(color: Color(0xCC000000), blurRadius: 24, offset: Offset(0, 8))];
const _kShadowBtn   = [BoxShadow(color: Color(0xB3000000), blurRadius: 12, offset: Offset(0, 4))];

// ─── Helpers (logika tidak diubah) ────────────────────────────────────────────

const _kLockedModuleMessage =
    'This page is not available yet. Please complete the previous module first.';

void _showLockedModuleSnackBar(BuildContext context) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: const Text(
          _kLockedModuleMessage,
          style: TextStyle(
            fontFamily: 'Montserrat',
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
    );
}

bool _canOpenModule(ModuleItem module, bool hasGeneratedCertificate) {
  if (!module.isVisible) return false;
  return canOpenModuleByStatus(
    module.status,
    hasGeneratedCertificate: hasGeneratedCertificate,
  );
}

bool _isAssignmentModule(ModuleItem module) {
  return module.viewTypes.contains('assignment') &&
      !module.viewTypes.contains('lesson') &&
      !module.viewTypes.contains('ebook') &&
      !module.viewTypes.contains('certificate') &&
      !module.viewTypes.contains('video_lecturer');
}

bool _isEbookModule(ModuleItem module) {
  return module.viewTypes.contains('ebook') &&
      !module.viewTypes.contains('lesson') &&
      !module.viewTypes.contains('assignment') &&
      !module.viewTypes.contains('certificate') &&
      !module.viewTypes.contains('video_lecturer');
}

bool _isCertificateModule(ModuleItem module) {
  return module.viewTypes.contains('certificate') &&
      !module.viewTypes.contains('lesson') &&
      !module.viewTypes.contains('assignment') &&
      !module.viewTypes.contains('ebook') &&
      !module.viewTypes.contains('video_lecturer');
}

bool _isVideoLecturerModule(ModuleItem module) {
  return module.viewTypes.contains('video_lecturer') &&
      !module.viewTypes.contains('lesson');
}

bool _isVideoLikeModule(ModuleItem module) {
  return module.viewTypes.contains('lesson') || _isVideoLecturerModule(module);
}

IconData _moduleCardIcon(ModuleItem module) {
  if (_isAssignmentModule(module)) return Icons.cloud_upload_rounded;
  if (_isCertificateModule(module)) return Icons.workspace_premium_rounded;
  if (_isEbookModule(module)) return Icons.menu_book_rounded;
  if (_isVideoLecturerModule(module)) return Icons.ondemand_video_rounded;
  return Icons.play_arrow_rounded;
}

String _moduleCardEyebrow(ModuleItem module) {
  if (_isAssignmentModule(module)) return 'Assignment Upload';
  if (_isCertificateModule(module)) return 'Certificate Access';
  if (_isEbookModule(module)) return 'Reading Material';
  if (_isVideoLecturerModule(module)) return 'Video Lecturer';
  return 'Learning Module';
}

// ─── Root Screen ──────────────────────────────────────────────────────────────

class ModuleListScreen extends ConsumerWidget {
  const ModuleListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final modulesAsync = ref.watch(moduleListProvider);
    final hasGeneratedCertificate = ref
        .watch(hasGeneratedCertificateProvider)
        .maybeWhen(data: (value) => value, orElse: () => false);

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
              loading: () => const SliverFillRemaining(child: _ModuleListSkeleton()),
              error: (e, _) => SliverFillRemaining(
                child: _ModuleListError(
                  message: e.toString(),
                  onRetry: () => ref.invalidate(moduleListProvider),
                ),
              ),
              data: (data) => _ModuleListContent(
                data: data,
                hasGeneratedCertificate: hasGeneratedCertificate,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void _handleModuleBack(BuildContext context) {
  if (context.canPop()) {
    context.pop();
  } else {
    context.go(AppRoutes.dashboard);
  }
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
      scrolledUnderElevation: 0,
      titleSpacing: 8,
      leading: IconButton(
        onPressed: () => _handleModuleBack(context),
        icon: const Icon(Icons.arrow_back_rounded, color: _kTextPrimary, size: 24),
      ),
      title: const Text(
        'Modules',
        style: TextStyle(
          color: _kTextPrimary,
          fontSize: 24, // DS: Semi Bold / Title 2
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
  final bool hasGeneratedCertificate;

  const _ModuleListContent({
    required this.data,
    required this.hasGeneratedCertificate,
  });

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
          (i) => AnimationController(vsync: this, duration: const Duration(milliseconds: 420)),
    );
    _fades = _controllers
        .map((c) => CurvedAnimation(parent: c, curve: Curves.easeOut))
        .toList();
    _slides = _controllers
        .map((c) => Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero)
        .animate(CurvedAnimation(parent: c, curve: Curves.easeOut)))
        .toList();

    for (int i = 0; i < count; i++) {
      Future.delayed(Duration(milliseconds: 60 * i), () {
        if (!mounted) return;

        if (i < _controllers.length) {
          _controllers[i].forward();
        }
      });
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) c.dispose();
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
    final summary = widget.data.summary;

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 48),
      sliver: SliverList(
        delegate: SliverChildListDelegate([
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _animated(
                  0,
                  _SummaryChip(
                    label: '${summary.total} modules',
                    icon: Icons.layers_rounded,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const RunningLoginTimeCard(),
            ],
          ),
          const SizedBox(height: 24),
          ...widget.data.items.asMap().entries.map(
                (entry) => _animated(
              entry.key + 1,
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _ModuleCard(
                  module: entry.value,
                  hasGeneratedCertificate: widget.hasGeneratedCertificate,
                ),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}

// ─── Summary Bar ──────────────────────────────────────────────────────────────

class _SummaryChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool highlight;

  const _SummaryChip({required this.label, required this.icon, this.highlight = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: highlight ? _kRedSoft : _kElevated,
        borderRadius: BorderRadius.circular(4), // DS: radius 4px
        border: Border.all(
          color: highlight ? _kRedBorder : _kBorderSoft,
          width: 0.8,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: highlight ? _kRed : _kTextMuted),
          const SizedBox(width: 6),
          Text(
            label,
            // DS: Regular / Caption 12px
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
  final bool hasGeneratedCertificate;

  const _ModuleCard({
    required this.module,
    required this.hasGeneratedCertificate,
  });

  @override
  State<_ModuleCard> createState() => _ModuleCardState();
}

class _ModuleCardState extends State<_ModuleCard> with SingleTickerProviderStateMixin {
  late AnimationController _pressCtrl;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _pressCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 150));
    // DS: Card hover scale(1.1) untuk web; mobile pakai subtle 0.98
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.98)
        .animate(CurvedAnimation(parent: _pressCtrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _pressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final module = widget.module;
    final canOpen = _canOpenModule(
      module,
      widget.hasGeneratedCertificate,
    );
    final isVideoLike = _isVideoLikeModule(module);
    final cardIcon = _moduleCardIcon(module);
    final eyebrow = _moduleCardEyebrow(module);

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
            borderRadius: BorderRadius.circular(4), // DS: Card radius 4px
            border: Border.all(color: _kBorderSoft, width: 0.8),
            boxShadow: _kShadowCard, // DS: 0 8px 24px rgba(0,0,0,0.8)
          ),
          clipBehavior: Clip.hardEdge,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Thumbnail 16:9 ──
              AspectRatio(
                aspectRatio: 16 / 9,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    module.thumbnailUrl != null
                        ? AuthNetworkImage(
                      imageUrl: module.thumbnailUrl!,
                      fit: BoxFit.cover,
                      placeholderBuilder: (_) => _ThumbnailPlaceholder(title: module.title),
                      errorBuilderWidget: (_, __) => _ThumbnailPlaceholder(title: module.title),
                    )
                        : _ThumbnailPlaceholder(title: module.title),

                    // Gradient — DS §9 Hero Banner: Black 45% → transparent → bg
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(0.15), // tipis di atas
                            Colors.black.withOpacity(0.80), // gelap di bawah
                          ],
                          stops: const [0.4, 1.0],
                        ),
                      ),
                    ),

                    Positioned(
                      top: 12,
                      right: 12,
                      child: _StatusBadge(
                        status: resolveModuleAccessStatus(
                          module.status,
                          hasGeneratedCertificate: widget.hasGeneratedCertificate,
                        ),
                      ),
                    ),

                    if (canOpen && isVideoLike)
                      Center(
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.60),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white.withOpacity(0.8), width: 1.5),
                          ),
                          child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 28),
                        ),
                      ),

                    if (!isVideoLike)
                      Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.40),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.10),
                              width: 0.8,
                            ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: _kRedSoft,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: _kRedBorder,
                                    width: 0.8,
                                  ),
                                ),
                                child: Icon(cardIcon, color: _kRed, size: 22),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                eyebrow,
                                style: const TextStyle(
                                  color: _kTextSecondary,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Montserrat',
                                  letterSpacing: 0.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // ── Info Panel ──
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      module.title,
                      style: const TextStyle(
                        color: _kTextPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Montserrat',
                      ),
                    ),

                    // Description — DS: Regular / Body 14px, White 65%
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

                    // Meta chips
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
                          const _MetaChip(icon: Icons.menu_book_rounded, label: 'Ebook'),
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
                        if (module.viewTypes.contains('assignment') && module.assignmentsCount > 0)
                          _MetaChip(
                            icon: _isAssignmentModule(module)
                                ? Icons.cloud_upload_outlined
                                : Icons.assignment_outlined,
                            label: '${module.assignmentsCount} assignments',
                            accent: _isAssignmentModule(module),
                          ),
                      ],
                    ),

                    // Progress bar — DS: merah aktif, hijau jika selesai
                    if (module.showProgress) ...[
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(2), // DS: bar radius 2px
                              child: LinearProgressIndicator(
                                value: module.progressPercentage / 100,
                                backgroundColor: _kDivider,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  module.isComplete ? _kGreen : _kRed,
                                ),
                                minHeight: 4,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            '${module.completedLessons}/${module.lessonCount}',
                            // DS: Regular / Caption 12px
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

  const _MetaChip({required this.icon, required this.label, this.accent = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: accent ? _kRed : _kTextMuted, size: 16),
        const SizedBox(width: 6),
        Text(
          label,
          // DS: Medium / Label 14px
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
      color: _kElevated,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.movie_creation_outlined, color: _kTextMuted, size: 36),
            const SizedBox(height: 10),
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
    final resolved = _resolveStatusBadge(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: resolved.backgroundColor,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: resolved.borderColor, width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(resolved.icon, color: resolved.foregroundColor, size: 12),
          const SizedBox(width: 5),
          Text(
            resolved.label,
            style: TextStyle(
              color: resolved.foregroundColor,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              fontFamily: 'Montserrat',
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _ResolvedStatusBadge {
  final String label;
  final IconData icon;
  final Color foregroundColor;
  final Color backgroundColor;
  final Color borderColor;

  const _ResolvedStatusBadge({
    required this.label,
    required this.icon,
    required this.foregroundColor,
    required this.backgroundColor,
    required this.borderColor,
  });
}

_ResolvedStatusBadge _resolveStatusBadge(String status) {
  switch (status.trim().toLowerCase()) {
    case 'completed':
      return const _ResolvedStatusBadge(
        label: 'Completed',
        icon: Icons.check_rounded,
        foregroundColor: Colors.white,
        backgroundColor: _kGreen,
        borderColor: _kGreen,
      );
    case 'active':
    case 'available':
      return const _ResolvedStatusBadge(
        label: 'Available',
        icon: Icons.remove_red_eye_rounded,
        foregroundColor: Colors.black,
        backgroundColor: Colors.white,
        borderColor: Colors.white,
      );
    case 'locked':
    case 'unavailable':
    case 'hidden':
    default:
      return const _ResolvedStatusBadge(
        label: 'Locked',
        icon: Icons.lock_rounded,
        foregroundColor: Colors.white,
        backgroundColor: _kRed,
        borderColor: _kRed,
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
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1100))
      ..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.3, end: 0.7)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
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
        final c = Color.lerp(_kSurface, _kElevated, _anim.value)!;
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
                  child: Container(
                    decoration: BoxDecoration(
                      color: c,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Thumbnail skeleton 16:9
                        AspectRatio(
                          aspectRatio: 16 / 9,
                          child: Container(color: c),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _Bone(width: 200, height: 18, color: Color.lerp(_kSurface, _kElevated, (_anim.value + 0.15).clamp(0.0, 1.0))!),
                              const SizedBox(height: 10),
                              _Bone(width: double.infinity, height: 12, color: Color.lerp(_kSurface, _kElevated, (_anim.value + 0.1).clamp(0.0, 1.0))!),
                              const SizedBox(height: 6),
                              _Bone(width: 260, height: 12, color: Color.lerp(_kSurface, _kElevated, (_anim.value + 0.1).clamp(0.0, 1.0))!),
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

// ─── Error Screen ─────────────────────────────────────────────────────────────

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
                color: _kRedSoft,
                shape: BoxShape.circle,
                border: Border.all(color: _kRedBorder),
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
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            GestureDetector(
              onTap: onRetry,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: _kRed,
                  borderRadius: BorderRadius.circular(4), // DS: button radius 4px
                  boxShadow: _kShadowBtn,
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
