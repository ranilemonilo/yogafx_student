import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/auth_network_image.dart';
import '../../../certificate/presentation/providers/certificate_provider.dart';
import '../../data/models/module_model.dart';
import '../providers/module_provider.dart';
import '../../utils/module_access_helper.dart';

// ─── Design Tokens (Sesuai DESIGN_SYSTEM.md & AppColors) ──────────────────────

const _kRed        = Color(0xFFDB202C); // Primary / Red
const _kRedHover   = Color(0xFFF6121D); // Primary / Red Hover
const _kGreen      = Color(0xFF00B14F); // Secondary / Emerald
const _kBg         = Color(0xFF060908); // Neutral Black 1 — bg utama
const _kHeaderBg   = Color(0xFF141110); // Neutral Black 2 — header
const _kSurface    = Color(0xFF120F0E); // Neutral Black 3 — card/panel
const _kElevated   = Color(0xFF281D16); // Neutral Brown — elevated/hover
const _kOverlay    = Color(0xFF161210); // Neutral Brown — overlay gelap

const _kTextPrimary   = Color(0xFFFFFFFF);           // White
const _kTextSecondary = Color(0xA6FFFFFF);            // White 65%
const _kTextMuted     = Color(0x73FFFFFF);            // White 45%

const _kDivider    = Color(0x1AFFFFFF);               // White 10%
const _kBorderSoft = Color(0x4DFFFFFF);               // White 30%

const _kRedSoft    = Color(0x1ADB202C);               // Red 10%
const _kRedBorder  = Color(0x4DDB202C);               // Red 30%

// Shadow sesuai DS §Catatan Implementasi
const _kShadowCard  = [BoxShadow(color: Color(0xCC000000), blurRadius: 24, offset: Offset(0, 8))];
const _kShadowModal = [BoxShadow(color: Color(0xE6000000), blurRadius: 40, offset: Offset(0, 16))];
const _kShadowBtn   = [BoxShadow(color: Color(0xB3000000), blurRadius: 12, offset: Offset(0, 4))];

// ─── Logic CTA (tidak diubah) ─────────────────────────────────────────────────

void _openPrimaryModuleContent(BuildContext context, ModuleDetail module) {
  final kind = module.primaryCtaKind;

  if (kind == 'play') {
    if (module.viewTypes.contains('lesson')) {
      final firstLesson = module.lessons.where((l) => !l.isLocked).firstOrNull;
      if (firstLesson != null) {
        context.push('/lessons/${firstLesson.id}');
      }
    } else if (module.viewTypes.contains('video_lecturer')) {
      final videos = module.videoLecturers;
      final firstVideoIndex = videos.indexWhere(_isVideoAccessible);

      if (firstVideoIndex != -1) {
        final firstVideo = videos[firstVideoIndex];
        final hasNextVideo = firstVideoIndex < videos.length - 1;
        final nextVideo = hasNextVideo ? videos[firstVideoIndex + 1] : null;

        context.pushNamed(
          'videoLecturer',
          pathParameters: {'videoId': firstVideo.id.toString()},
          queryParameters: {
            'title': firstVideo.title,
            'url': firstVideo.hlsUrl ?? '',
            if (hasNextVideo && nextVideo != null) 'nextVideoId': nextVideo.id.toString(),
            if (hasNextVideo && nextVideo != null) 'nextVideoTitle': nextVideo.title,
            if (hasNextVideo && nextVideo != null) 'nextVideoUrl': nextVideo.hlsUrl ?? '',
          },
        );
      }
    }
  } else if (kind == 'download') {
    return;
  } else if (kind == 'document') {
    final firstEbook = module.ebooks.firstOrNull;
    if (firstEbook != null) {
      context.push('/ebooks/${firstEbook.id}');
    }
  }
}

// ─── Root Screen ──────────────────────────────────────────────────────────────

class ModuleDetailScreen extends ConsumerWidget {
  final int moduleId;

  const ModuleDetailScreen({super.key, required this.moduleId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final moduleAsync = ref.watch(moduleDetailProvider(moduleId));
    final hasGeneratedCertificate = ref
        .watch(hasGeneratedCertificateProvider)
        .maybeWhen(data: (value) => value, orElse: () => false);

    return Scaffold(
      backgroundColor: _kBg,
      body: moduleAsync.when(
        loading: () => const _ModuleDetailSkeleton(),
        error: (e, _) => _ModuleDetailError(
          message: e.toString(),
          onRetry: () => ref.invalidate(moduleDetailProvider(moduleId)),
          onBack: () => context.pop(),
        ),
        data: (module) => _ModuleDetailContent(
          moduleId: moduleId,
          module: module,
          hasGeneratedCertificate: hasGeneratedCertificate,
        ),
      ),
    );
  }
}

// ─── Content ──────────────────────────────────────────────────────────────────

class _ModuleDetailContent extends StatefulWidget {
  final int moduleId;
  final ModuleDetail module;
  final bool hasGeneratedCertificate;

  const _ModuleDetailContent({
    required this.moduleId,
    required this.module,
    required this.hasGeneratedCertificate,
  });

  @override
  State<_ModuleDetailContent> createState() => _ModuleDetailContentState();
}

class _ModuleDetailContentState extends State<_ModuleDetailContent>
    with TickerProviderStateMixin {
  late AnimationController _heroCtrl;
  late Animation<double> _heroFade;
  late List<AnimationController> _itemCtrlList;
  late List<Animation<double>> _itemFades;
  late List<Animation<Offset>> _itemSlides;

  int _animIndex = 0;

  @override
  void initState() {
    super.initState();

    _heroCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _heroFade = CurvedAnimation(parent: _heroCtrl, curve: Curves.easeOut);
    _heroCtrl.forward();

    final itemCount = widget.module.lessons.length +
        widget.module.assignments.length +
        widget.module.ebooks.length +
        widget.module.certificates.length +
        widget.module.videoLecturers.length +
        15;

    _itemCtrlList = List.generate(
      itemCount,
          (_) => AnimationController(vsync: this, duration: const Duration(milliseconds: 400)),
    );

    _itemFades = _itemCtrlList
        .map((c) => CurvedAnimation(parent: c, curve: Curves.easeOut))
        .toList();

    _itemSlides = _itemCtrlList
        .map((c) => Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero)
        .animate(CurvedAnimation(parent: c, curve: Curves.easeOut)))
        .toList();

    for (int i = 0; i < itemCount; i++) {
      Future.delayed(Duration(milliseconds: 120 + 55 * i), () {
        if (mounted) _itemCtrlList[i].forward();
      });
    }

  }

  @override
  void dispose() {
    _heroCtrl.dispose();
    for (final c in _itemCtrlList) c.dispose();
    super.dispose();
  }

  Widget _buildAnimated(Widget child) {
    final index = _animIndex++;
    if (index >= _itemFades.length) return child;
    return FadeTransition(
      opacity: _itemFades[index],
      child: SlideTransition(position: _itemSlides[index], child: child),
    );
  }

  @override
  Widget build(BuildContext context) {
    final module = widget.module;
    final assignments = _parseAssignments(module, widget.hasGeneratedCertificate);

    final shouldShowPrimaryCta = module.primaryCtaLabel != null &&
        !module.viewTypes.contains('ebook') &&
        !module.viewTypes.contains('video_lecturer') &&
        !module.viewTypes.contains('certificate');

    _animIndex = 0;

    return RefreshIndicator(
      color: _kRed,
      backgroundColor: _kSurface,
      onRefresh: () async {
        final container = ProviderScope.containerOf(context, listen: false);
        container.invalidate(moduleDetailProvider(widget.moduleId));
        await container.read(moduleDetailProvider(widget.moduleId).future);
      },
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: _kHeaderBg.withOpacity(0.95),
            elevation: 0,
            scrolledUnderElevation: 0,
            leading: Padding(
              padding: const EdgeInsets.all(8),
              child: GestureDetector(
                onTap: () => context.pop(),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Icon(Icons.arrow_back_rounded, color: _kTextPrimary, size: 20),
                ),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: FadeTransition(
                opacity: _heroFade,
                child: _HeroBanner(
                  module: module,
                  hasGeneratedCertificate: widget.hasGeneratedCertificate,
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 48),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (shouldShowPrimaryCta) ...[
                    _buildAnimated(
                      _ActionRow(module: module),
                    ),
                    const SizedBox(height: 24),
                  ],
                  _buildAnimated(
                    _ModuleHeader(
                      module: module,
                      hasGeneratedCertificate: widget.hasGeneratedCertificate,
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (module.showProgress) ...[
                    _buildAnimated(_ModuleProgress(module: module)),
                    const SizedBox(height: 24),
                  ],
                  if (module.description != null) ...[
                    _buildAnimated(_Description(text: module.description!)),
                    const SizedBox(height: 28),
                  ],
                  if (module.viewTypes.contains('video_lecturer'))
                    ..._buildVideoLecturerList(module),
                  if (module.viewTypes.contains('ebook')) ..._buildEbookList(module),
                  if (module.viewTypes.contains('certificate')) ..._buildCertificateInfo(module),
                  if (module.viewTypes.contains('lesson')) ..._buildLessonList(module),
                  if (module.viewTypes.contains('assignment')) ..._buildAssignmentList(assignments),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildLessonList(ModuleDetail module) {
    if (module.lessons.isEmpty) return [];
    return [
      _buildAnimated(_SectionHeader(title: 'Lessons', count: module.lessons.length)),
      const SizedBox(height: 12),
      ...module.lessons.asMap().entries.map((entry) => _buildAnimated(
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: _LessonRow(lesson: entry.value, index: entry.key),
        ),
      )),
      const SizedBox(height: 16),
    ];
  }

  List<Widget> _buildEbookList(ModuleDetail module) {
    if (module.ebooks.isEmpty) return [];
    return [
      _buildAnimated(_SectionHeader(title: 'Ebooks', count: module.ebooks.length)),
      const SizedBox(height: 12),
      ...module.ebooks.asMap().entries.map((entry) => _buildAnimated(
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: _EbookRow(ebook: entry.value, index: entry.key),
        ),
      )),
      const SizedBox(height: 16),
    ];
  }

  List<Widget> _buildCertificateInfo(ModuleDetail module) {
    if (module.certificates.isEmpty) return [];
    return [
      _buildAnimated(_SectionHeader(title: 'Certificates', count: module.certificates.length)),
      const SizedBox(height: 12),
      ...module.certificates.asMap().entries.map((entry) => _buildAnimated(
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: _CertificateRow(certificate: entry.value, index: entry.key),
        ),
      )),
      const SizedBox(height: 16),
    ];
  }

  List<Widget> _buildAssignmentList(List<_ModuleAssignmentItem> assignments) {
    if (assignments.isEmpty) return [];
    return [
      _buildAnimated(_SectionHeader(title: 'Assignments', count: assignments.length)),
      const SizedBox(height: 12),
      ...assignments.asMap().entries.map((entry) => _buildAnimated(
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: _AssignmentRow(assignment: entry.value, index: entry.key),
        ),
      )),
      const SizedBox(height: 16),
    ];
  }

  List<Widget> _buildVideoLecturerList(ModuleDetail module) {
    if (module.videoLecturers.isEmpty) return [];
    return [
      _buildAnimated(_SectionHeader(title: 'Video Lecturer', count: module.videoLecturers.length)),
      const SizedBox(height: 12),
      ...module.videoLecturers.asMap().entries.map((entry) {
        final isLast = entry.key == module.videoLecturers.length - 1;
        final nextVideo = !isLast ? module.videoLecturers[entry.key + 1] : null;
        return _buildAnimated(
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _VideoLecturerRow(video: entry.value, nextVideo: nextVideo, index: entry.key),
          ),
        );
      }),
      const SizedBox(height: 16),
    ];
  }
}

// ─── Hero Banner ──────────────────────────────────────────────────────────────

class _HeroBanner extends StatelessWidget {
  final ModuleDetail module;
  final bool hasGeneratedCertificate;

  const _HeroBanner({
    required this.module,
    required this.hasGeneratedCertificate,
  });

  @override
  Widget build(BuildContext context) {
    final isVideoLike = module.viewTypes.contains('lesson') || _isVideoLecturerModule(module);
    final heroIcon = _moduleHeroIcon(module);

    return Stack(
      fit: StackFit.expand,
      children: [
        // Thumbnail
        module.thumbnailUrl != null
            ? AuthNetworkImage(
          imageUrl: module.thumbnailUrl!,
          fit: BoxFit.cover,
          placeholderBuilder: (_) => Container(
            color: _kElevated,
            child: const Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2, color: _kTextMuted),
              ),
            ),
          ),
          errorBuilderWidget: (_, __) => Container(
            color: _kElevated,
            child: const Center(
              child: Icon(Icons.broken_image_rounded, color: _kTextMuted, size: 32),
            ),
          ),
        )
            : Container(
          color: _kElevated,
          child: const Center(
            child: Icon(Icons.image_not_supported_rounded, color: _kTextMuted, size: 32),
          ),
        ),

        // Gradient overlay — DS §9 Hero Banner
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.45),   // DS: Transparent Black 45%
                Colors.black.withOpacity(0.10),   // tengah tipis
                _kBg,                              // fade ke background
              ],
              stops: const [0.0, 0.45, 1.0],
            ),
          ),
        ),

        if (isVideoLike && module.primaryCtaLabel != null)
          Center(
            child: GestureDetector(
              onTap: () => _openPrimaryModuleContent(context, module),
              child: Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  // DS §Media Control Buttons: rgba(0,0,0,0.6), border putih tipis
                  color: Colors.black.withOpacity(0.60),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withOpacity(0.8), width: 1.5),
                ),
                child: Icon(heroIcon, color: Colors.white, size: 36),
              ),
            ),
          ),

        if (!isVideoLike)
          Positioned(
            left: 20,
            right: 20,
            bottom: 28,
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.38),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white.withOpacity(0.10)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: _kRedSoft,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: _kRedBorder, width: 0.8),
                    ),
                    child: Icon(heroIcon, color: _kRed, size: 24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _moduleEyebrow(module).toUpperCase(),
                          style: const TextStyle(
                            color: _kTextSecondary,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Montserrat',
                            letterSpacing: 1.8,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _primaryActionLabel(module),
                          style: const TextStyle(
                            color: _kTextPrimary,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Montserrat',
                            height: 1.15,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

        // Status badge — pojok kanan atas
        Positioned(
          top: 52,
          right: 16,
          child: _StatusBadge(
            status: resolveModuleAccessStatus(
              module.status,
              hasGeneratedCertificate: hasGeneratedCertificate,
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Action Row (Primary CTA) — DS §4 Play + More Info Buttons ───────────────

class _ActionRow extends StatelessWidget {
  final ModuleDetail module;

  const _ActionRow({required this.module});

  @override
  Widget build(BuildContext context) {
    final primaryLabel = _primaryActionLabel(module);
    final ctaIcon = _moduleHeroIcon(module);

    final hasLessons = module.viewTypes.contains('lesson');
    final showResume = hasLessons &&
        module.showProgress &&
        !module.isComplete &&
        module.progressPercentage > 0;

    return Row(
      children: [
        Expanded(
          flex: 3,
          child: GestureDetector(
            onTap: () => _openPrimaryModuleContent(context, module),
            child: Container(
              height: 42, // DS: Large/Default ~42px
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
                boxShadow: _kShadowBtn,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                    Icon(ctaIcon, color: Colors.black, size: 20),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      primaryLabel,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 16,           // DS: Large Button 16px Bold
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Montserrat',
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (showResume) ...[
          const SizedBox(width: 8), // DS: gap antar tombol 8px
          Expanded(
            flex: 3,
            child: GestureDetector(
              onTap: () => _openPrimaryModuleContent(context, module),
              child: Container(
                height: 42,
                decoration: BoxDecoration(
                  // DS: §4 Sekunder — rgba(255,255,255,0.2) → tapi di sini merah sesuai konteks "resume"
                  color: _kRed,
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: _kShadowBtn,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.play_circle_outline_rounded, color: Colors.white, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Resume',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

// ─── Module Header ────────────────────────────────────────────────────────────

class _ModuleHeader extends StatelessWidget {
  final ModuleDetail module;
  final bool hasGeneratedCertificate;

  const _ModuleHeader({
    required this.module,
    required this.hasGeneratedCertificate,
  });

  @override
  Widget build(BuildContext context) {
    final hasAssignmentsOnly = _isAssignmentModule(module);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _moduleEyebrow(module).toUpperCase(),
          style: const TextStyle(
            color: _kTextSecondary,
            fontSize: 10,
            fontWeight: FontWeight.w700,
            fontFamily: 'Montserrat',
            letterSpacing: 1.8,
          ),
        ),
        const SizedBox(height: 8),
        // Judul — DS: Semi Bold / Title 2 — 24px
        Text(
          module.title,
          style: const TextStyle(
            color: _kTextPrimary,
            fontSize: 24,
            fontWeight: FontWeight.w600,
            fontFamily: 'Montserrat',
          ),
        ),
        const SizedBox(height: 12),
        Text(
          _moduleHeroDescription(module),
          style: const TextStyle(
            color: _kTextSecondary,
            fontSize: 14,
            fontFamily: 'Montserrat',
            height: 1.5,
          ),
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 12,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            _StatusBadge(
              status: resolveModuleAccessStatus(
                module.status,
                hasGeneratedCertificate: hasGeneratedCertificate,
              ),
            ),
            if (module.viewTypes.contains('lesson'))
              _MetaItem(
                icon: Icons.play_circle_outline_rounded,
                label: '${module.lessonCount} lessons',
              ),
            if (module.viewTypes.contains('assignment'))
              _MetaItem(
                icon: hasAssignmentsOnly
                    ? Icons.cloud_upload_outlined
                    : Icons.assignment_outlined,
                label: '${module.assignmentsCount} assignments',
                accent: hasAssignmentsOnly,
              ),
            if (module.viewTypes.contains('certificate'))
              const _MetaItem(
                icon: Icons.workspace_premium_outlined,
                label: 'Certificate',
                accent: true,
              ),
            if (module.viewTypes.contains('ebook'))
              const _MetaItem(icon: Icons.menu_book_rounded, label: 'Ebook'),
            if (module.viewTypes.contains('video_lecturer'))
              const _MetaItem(icon: Icons.play_circle_fill_rounded, label: 'Video Lecturer'),
          ],
        ),
      ],
    );
  }
}

class _MetaItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool accent;

  const _MetaItem({required this.icon, required this.label, this.accent = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: accent ? _kRed : _kTextMuted, size: 16),
        const SizedBox(width: 4),
        Text(
          label,
          // DS: Medium / Label — 14px
          style: TextStyle(
            color: accent ? _kRed : _kTextSecondary,
            fontSize: 14,
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// ─── Description ─────────────────────────────────────────────────────────────

class _Description extends StatefulWidget {
  final String text;

  const _Description({required this.text});

  @override
  State<_Description> createState() => _DescriptionState();
}

class _DescriptionState extends State<_Description> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    // DS: Regular / Body 14px, line-height ~1.6, warna teks sekunder 65%
    const textStyle = TextStyle(
      color: _kTextSecondary,
      fontSize: 14,
      fontFamily: 'Montserrat',
      height: 1.6,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedCrossFade(
          firstChild: Text(widget.text, style: textStyle, maxLines: 3, overflow: TextOverflow.ellipsis),
          secondChild: Text(widget.text, style: textStyle),
          crossFadeState: _expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 200),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => setState(() => _expanded = !_expanded),
          child: Text(
            _expanded ? 'Show less' : 'Show more',
            style: const TextStyle(
              color: _kTextPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              fontFamily: 'Montserrat',
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Module Progress ──────────────────────────────────────────────────────────

class _ModuleProgress extends StatelessWidget {
  final ModuleDetail module;

  const _ModuleProgress({required this.module});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: _kBorderSoft, width: 0.8),
        boxShadow: _kShadowCard,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Your progress',
                // DS: Semi Bold / Headline 2 — 14px
                style: TextStyle(
                  color: _kTextSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Montserrat',
                ),
              ),
              const Spacer(),
              Text(
                '${module.completedLessons}/${module.lessonCount} lessons',
                // DS: Regular / Caption — 12px
                style: const TextStyle(
                  color: _kTextMuted,
                  fontSize: 12,
                  fontFamily: 'Montserrat',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: module.progressPercentage / 100,
              backgroundColor: _kDivider,
              valueColor: AlwaysStoppedAnimation<Color>(
                module.isComplete ? _kGreen : _kRed,
              ),
              minHeight: 4,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            module.isComplete ? '✓ Module completed' : '${module.progressPercentage}% complete',
            style: TextStyle(
              color: module.isComplete ? _kGreen : _kTextMuted,
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

// ─── Section Header ───────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  final int count;

  const _SectionHeader({required this.title, required this.count});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Garis merah vertikal — aksen merah DS
        Container(
          width: 3,
          height: 16,
          decoration: BoxDecoration(
            color: _kRed,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title.toUpperCase(),
          // DS: Semi Bold / Headline 2, letter-spacing lebih rapat
          style: const TextStyle(
            color: _kTextSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            fontFamily: 'Montserrat',
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(width: 8),
        // Count badge — DS §3 badge kecil, border-radius 2px
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: _kElevated,
            borderRadius: BorderRadius.circular(2),
          ),
          child: Text(
            '$count',
            style: const TextStyle(
              color: _kTextMuted,
              fontSize: 10,
              fontWeight: FontWeight.w600,
              fontFamily: 'Montserrat',
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Video Lecturer Row ──────────────────────────────────────────────────────

class _VideoLecturerRow extends StatefulWidget {
  final ModuleVideoLecturerItem video;
  final ModuleVideoLecturerItem? nextVideo;
  final int index;

  const _VideoLecturerRow({required this.video, required this.nextVideo, required this.index});

  @override
  State<_VideoLecturerRow> createState() => _VideoLecturerRowState();
}

class _VideoLecturerRowState extends State<_VideoLecturerRow>
    with SingleTickerProviderStateMixin {
  late AnimationController _pressCtrl;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _pressCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 130));
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.97)
        .animate(CurvedAnimation(parent: _pressCtrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _pressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final video = widget.video;
    final isReady = _isVideoAccessible(video);
    final nextVideo = widget.nextVideo;

    return GestureDetector(
      onTap: isReady
          ? () => context.pushNamed(
        'videoLecturer',
        pathParameters: {'videoId': video.id.toString()},
        queryParameters: {
          'title': video.title,
          'url': video.hlsUrl ?? '',
          if (nextVideo != null) 'nextVideoId': nextVideo.id.toString(),
          if (nextVideo != null) 'nextVideoTitle': nextVideo.title,
          if (nextVideo != null) 'nextVideoUrl': nextVideo.hlsUrl ?? '',
        },
      )
          : null,
      onTapDown: (_) => _pressCtrl.forward(),
      onTapUp: (_) => _pressCtrl.reverse(),
      onTapCancel: () => _pressCtrl.reverse(),
      child: ScaleTransition(
        scale: _scaleAnim,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _kSurface,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: _kBorderSoft, width: 0.8),
            boxShadow: _kShadowCard, // DS: card hover 0 8px 24px rgba(0,0,0,0.8)
          ),
          child: Row(
            children: [
              // Thumbnail 16:9 — DS: card thumbnail radius 4px
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: SizedBox(
                  width: 120,
                  height: 68,
                  child: video.thumbnailUrl != null
                      ? Stack(
                    fit: StackFit.expand,
                    children: [
                      AuthNetworkImage(
                        imageUrl: video.thumbnailUrl!,
                        fit: BoxFit.cover,
                        placeholderBuilder: (_) => _VideoThumbnailFallback(index: widget.index),
                        errorBuilderWidget: (_, __) => _VideoThumbnailFallback(index: widget.index),
                      ),
                      Container(
                        color: Colors.black.withOpacity(0.35),
                        child: const Center(
                          child: Icon(Icons.play_arrow_rounded, color: Colors.white, size: 28),
                        ),
                      ),
                    ],
                  )
                      : _VideoThumbnailFallback(index: widget.index),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${widget.index + 1}. ',
                          style: const TextStyle(
                            color: _kTextMuted,
                            fontSize: 14,
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            video.title,
                            style: TextStyle(
                              color: isReady ? _kTextPrimary : _kTextMuted,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Montserrat',
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _StatusBadge(status: video.status),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                isReady ? Icons.chevron_right_rounded : Icons.lock_rounded,
                color: isReady ? _kTextSecondary : _kTextMuted,
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VideoThumbnailFallback extends StatelessWidget {
  final int index;

  const _VideoThumbnailFallback({required this.index});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _kElevated,
      child: Center(
        child: Text(
          '${index + 1}',
          style: const TextStyle(
            color: _kTextSecondary,
            fontSize: 24,
            fontWeight: FontWeight.w700,
            fontFamily: 'Montserrat',
          ),
        ),
      ),
    );
  }
}

// ─── Assignment Parser ────────────────────────────────────────────────────────

List<_ModuleAssignmentItem> _parseAssignments(
  ModuleDetail module,
  bool hasGeneratedCertificate,
) {
  final unlockAssignmentsWithModule =
      _isAssignmentModule(module) &&
      _isModuleDetailAccessible(module, hasGeneratedCertificate);

  return module.assignments
      .whereType<Map>()
      .map((raw) {
    final data = Map<String, dynamic>.from(raw);
    final backendLocked = data['is_locked'] as bool? ?? false;
    final isLocked = unlockAssignmentsWithModule ? false : backendLocked;

    return _ModuleAssignmentItem(
      id: data['id'] as int? ?? 0,
      title: (data['title'] ?? data['name'] ?? 'Assignment').toString(),
      description: data['description']?.toString(),
      isLocked: isLocked,
      lockReason: isLocked ? data['lock_reason']?.toString() : null,
      status: isLocked
          ? (data['status'] ?? data['submission_status'] ?? 'locked').toString()
          : (data['status'] ?? data['submission_status'] ?? 'available')
              .toString(),
    );
  })
      .where((item) => item.id > 0)
      .toList();
}

class _ModuleAssignmentItem {
  final int id;
  final String title;
  final String? description;
  final bool isLocked;
  final String? lockReason;
  final String status;

  const _ModuleAssignmentItem({
    required this.id,
    required this.title,
    required this.description,
    required this.isLocked,
    required this.lockReason,
    required this.status,
  });
}

// ─── Ebook Row ────────────────────────────────────────────────────────────────

class _EbookRow extends StatefulWidget {
  final ModuleEbookItem ebook;
  final int index;

  const _EbookRow({required this.ebook, required this.index});

  @override
  State<_EbookRow> createState() => _EbookRowState();
}

class _EbookRowState extends State<_EbookRow> with SingleTickerProviderStateMixin {
  late AnimationController _pressCtrl;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _pressCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 130));
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.97)
        .animate(CurvedAnimation(parent: _pressCtrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _pressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ebook = widget.ebook;

    return GestureDetector(
      onTap: () => context.push('/ebooks/${ebook.id}'),
      onTapDown: (_) => _pressCtrl.forward(),
      onTapUp: (_) => _pressCtrl.reverse(),
      onTapCancel: () => _pressCtrl.reverse(),
      child: ScaleTransition(
        scale: _scaleAnim,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _kSurface,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: _kBorderSoft, width: 0.8),
            boxShadow: _kShadowCard,
          ),
          child: Row(
            children: [
              // Ikon kontainer — DS: aksen merah soft, radius 4px
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: _kRedSoft,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: _kRedBorder, width: 0.8),
                ),
                child: const Icon(Icons.menu_book_rounded, color: _kRed, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${widget.index + 1}. ${ebook.title}',
                      style: const TextStyle(
                        color: _kTextPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Montserrat',
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if ((ebook.fileName ?? '').trim().isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        ebook.fileName!,
                        style: const TextStyle(
                          color: _kTextMuted,
                          fontSize: 12,
                          fontFamily: 'Montserrat',
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right_rounded, color: _kTextMuted, size: 24),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Certificate Row ──────────────────────────────────────────────────────────

class _CertificateRow extends StatelessWidget {
  final ModuleCertificateItem certificate;
  final int index;

  const _CertificateRow({required this.certificate, required this.index});

  @override
  Widget build(BuildContext context) {
    final certificate = this.certificate;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: _kBorderSoft, width: 0.8),
        boxShadow: _kShadowCard,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: _kRedSoft,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: _kRedBorder, width: 0.8),
            ),
            child: const Icon(Icons.workspace_premium_outlined, color: _kRed, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${index + 1}. ${certificate.typeLabel}',
                  style: const TextStyle(
                    color: _kTextPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Montserrat',
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if ((certificate.generatedAt ?? '').trim().isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    certificate.generatedAt!,
                    style: const TextStyle(
                      color: _kTextMuted,
                      fontSize: 12,
                      fontFamily: 'Montserrat',
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                if ((certificate.generatedBy ?? '').trim().isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Generated by ${certificate.generatedBy!}',
                    style: const TextStyle(
                      color: _kTextMuted,
                      fontSize: 12,
                      fontFamily: 'Montserrat',
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                if ((certificate.downloadUrl ?? '').trim().isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: _kGreen.withOpacity(0.14),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: _kGreen.withOpacity(0.35), width: 0.8),
                    ),
                    child: const Text(
                      'Certificate ready to download',
                      style: TextStyle(
                        color: _kGreen,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Lesson Row ───────────────────────────────────────────────────────────────

class _LessonRow extends StatefulWidget {
  final ModuleLesson lesson;
  final int index;

  const _LessonRow({required this.lesson, required this.index});

  @override
  State<_LessonRow> createState() => _LessonRowState();
}

class _LessonRowState extends State<_LessonRow> with SingleTickerProviderStateMixin {
  late AnimationController _pressCtrl;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _pressCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 130));
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.97)
        .animate(CurvedAnimation(parent: _pressCtrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _pressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lesson = widget.lesson;
    final isLocked = lesson.isLocked;

    return GestureDetector(
      onTap: isLocked
          ? () => _showLockedDialog(context, lesson.lockReason)
          : () => context.push('/lessons/${lesson.id}'),
      onTapDown: (_) => _pressCtrl.forward(),
      onTapUp: (_) => _pressCtrl.reverse(),
      onTapCancel: () => _pressCtrl.reverse(),
      child: ScaleTransition(
        scale: _scaleAnim,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _kSurface,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: _kBorderSoft, width: 0.8),
            boxShadow: _kShadowCard,
          ),
          child: Row(
            children: [
              // Thumbnail 16:9
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: SizedBox(
                  width: 120,
                  height: 68,
                  child: lesson.thumbnailUrl != null
                      ? Stack(
                    fit: StackFit.expand,
                    children: [
                      AuthNetworkImage(
                        imageUrl: lesson.thumbnailUrl!,
                        fit: BoxFit.cover,
                        placeholderBuilder: (_) => _LessonThumbnailFallback(
                          index: widget.index,
                          isLocked: isLocked,
                        ),
                        errorBuilderWidget: (_, __) => _LessonThumbnailFallback(
                          index: widget.index,
                          isLocked: isLocked,
                        ),
                      ),
                      if (isLocked)
                        Container(
                          color: Colors.black.withOpacity(0.65),
                          child: const Icon(Icons.lock_rounded, color: _kTextMuted, size: 20),
                        )
                      else
                        Container(
                          color: Colors.black.withOpacity(0.35),
                          child: const Center(
                            child: Icon(Icons.play_arrow_rounded, color: Colors.white, size: 28),
                          ),
                        ),
                    ],
                  )
                      : _LessonThumbnailFallback(index: widget.index, isLocked: isLocked),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${widget.index + 1}. ',
                          style: const TextStyle(
                            color: _kTextMuted,
                            fontSize: 14,
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            lesson.title,
                            style: TextStyle(
                              color: isLocked ? _kTextMuted : _kTextPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Montserrat',
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (!isLocked && lesson.progressPercentage >= 100) ...[
                          const SizedBox(width: 8),
                          const _StatusBadge(status: 'completed'),
                        ],
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        if (lesson.hasVideo) const _MediaIcon(icon: Icons.play_circle_outline_rounded),
                        if (lesson.hasAudio) const _MediaIcon(icon: Icons.headphones_rounded),
                        if (lesson.hasWorkbook) const _MediaIcon(icon: Icons.description_rounded),
                      ],
                    ),
                    if (!isLocked && lesson.progressPercentage > 0) ...[
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(2),
                        child: LinearProgressIndicator(
                          value: lesson.progressPercentage / 100,
                          backgroundColor: _kDivider,
                          valueColor: const AlwaysStoppedAnimation<Color>(_kRed),
                          minHeight: 3,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                isLocked ? Icons.lock_rounded : Icons.chevron_right_rounded,
                color: isLocked ? _kTextMuted : _kTextSecondary,
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Assignment Row ───────────────────────────────────────────────────────────

class _AssignmentRow extends StatefulWidget {
  final _ModuleAssignmentItem assignment;
  final int index;

  const _AssignmentRow({required this.assignment, required this.index});

  @override
  State<_AssignmentRow> createState() => _AssignmentRowState();
}

class _AssignmentRowState extends State<_AssignmentRow> with SingleTickerProviderStateMixin {
  late AnimationController _pressCtrl;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _pressCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 130));
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.97)
        .animate(CurvedAnimation(parent: _pressCtrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _pressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final assignment = widget.assignment;
    final isLocked = assignment.isLocked;

    return GestureDetector(
      onTap: isLocked
          ? () => _showLockedDialog(context, assignment.lockReason)
          : () => context.pushNamed(
        'assignment',
        pathParameters: {'assignmentId': assignment.id.toString()},
      ),
      onTapDown: (_) => _pressCtrl.forward(),
      onTapUp: (_) => _pressCtrl.reverse(),
      onTapCancel: () => _pressCtrl.reverse(),
      child: ScaleTransition(
        scale: _scaleAnim,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _kSurface,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: _kBorderSoft, width: 0.8),
            boxShadow: _kShadowCard,
          ),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: isLocked ? Colors.black.withOpacity(0.25) : _kRedSoft,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: isLocked ? Colors.transparent : _kRedBorder,
                    width: 0.8,
                  ),
                ),
                child: Icon(
                  isLocked ? Icons.lock_outline_rounded : Icons.assignment_rounded,
                  color: isLocked ? _kTextMuted : _kRed,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${widget.index + 1}. ',
                          style: const TextStyle(
                            color: _kTextMuted,
                            fontSize: 14,
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            assignment.title,
                            style: TextStyle(
                              color: isLocked ? _kTextMuted : _kTextPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Montserrat',
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    if (assignment.description != null && assignment.description!.trim().isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        assignment.description!,
                        style: const TextStyle(
                          color: _kTextMuted,
                          fontSize: 12,
                          height: 1.5,
                          fontFamily: 'Montserrat',
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                isLocked ? Icons.lock_rounded : Icons.chevron_right_rounded,
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

// ─── Locked Dialog ────────────────────────────────────────────────────────────

void _showLockedDialog(BuildContext context, String? reason) {
  showDialog(
    context: context,
    builder: (ctx) => Dialog(
      backgroundColor: _kSurface,
      // DS: Modal border-radius 8px
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Container(
        decoration: BoxDecoration(
          color: _kSurface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: _kBorderSoft, width: 0.8),
          boxShadow: _kShadowModal,
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.lock_rounded, color: _kTextMuted, size: 22),
                SizedBox(width: 12),
                Text(
                  'Lesson locked',
                  // DS: Semi Bold / Title 1 — 28px terlalu besar untuk dialog kecil, pakai 18px Semi Bold
                  style: TextStyle(
                    color: _kTextPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Montserrat',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              reason ?? 'You need to complete the previous lesson first.',
              style: const TextStyle(
                color: _kTextSecondary,
                fontSize: 14,
                fontFamily: 'Montserrat',
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: () => Navigator.pop(ctx),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                  decoration: BoxDecoration(
                    color: _kRed,
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: _kShadowBtn,
                  ),
                  child: const Text(
                    'Got it',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Montserrat',
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

// ─── Lesson Thumbnail Fallback ────────────────────────────────────────────────

class _LessonThumbnailFallback extends StatelessWidget {
  final int index;
  final bool isLocked;

  const _LessonThumbnailFallback({required this.index, required this.isLocked});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _kElevated,
      child: Center(
        child: isLocked
            ? const Icon(Icons.lock_rounded, color: _kTextMuted, size: 24)
            : Text(
          '${index + 1}',
          style: const TextStyle(
            color: _kTextSecondary,
            fontSize: 24,
            fontWeight: FontWeight.w700,
            fontFamily: 'Montserrat',
          ),
        ),
      ),
    );
  }
}

// ─── Media Icon ───────────────────────────────────────────────────────────────

class _MediaIcon extends StatelessWidget {
  final IconData icon;

  const _MediaIcon({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: Icon(icon, color: _kTextMuted, size: 16),
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
    case 'ready':
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

class _ModuleDetailSkeleton extends StatefulWidget {
  const _ModuleDetailSkeleton();

  @override
  State<_ModuleDetailSkeleton> createState() => _ModuleDetailSkeletonState();
}

class _ModuleDetailSkeletonState extends State<_ModuleDetailSkeleton>
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
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Bone(width: double.infinity, height: 280, color: c, radius: 0),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Bone(width: double.infinity, height: 42, color: c),
                    const SizedBox(height: 24),
                    _Bone(width: 64, height: 20, color: c),
                    const SizedBox(height: 12),
                    _Bone(width: 220, height: 28, color: c),
                    const SizedBox(height: 24),
                    ...List.generate(
                      4,
                      (_) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _Bone(
                          width: double.infinity,
                          height: 92,
                          color: c,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

bool _isVideoAccessible(ModuleVideoLecturerItem video) {
  final status = video.status.trim().toLowerCase();
  if (status == 'locked' || status == 'hidden' || status == 'unavailable') {
    return false;
  }
  return (video.hlsUrl ?? '').trim().isNotEmpty;
}

bool _isModuleDetailAccessible(
  ModuleDetail module,
  bool hasGeneratedCertificate,
) {
  final status = resolveModuleAccessStatus(
    module.status,
    hasGeneratedCertificate: hasGeneratedCertificate,
  );
  if (!module.isVisible) return false;
  return status != 'locked' && status != 'hidden' && status != 'unavailable';
}

bool _isAssignmentModule(ModuleDetail module) {
  return module.viewTypes.contains('assignment') &&
      !module.viewTypes.contains('lesson') &&
      !module.viewTypes.contains('ebook') &&
      !module.viewTypes.contains('certificate') &&
      !module.viewTypes.contains('video_lecturer');
}

bool _isEbookModule(ModuleDetail module) {
  return module.viewTypes.contains('ebook') &&
      !module.viewTypes.contains('lesson') &&
      !module.viewTypes.contains('assignment') &&
      !module.viewTypes.contains('certificate') &&
      !module.viewTypes.contains('video_lecturer');
}

bool _isCertificateModule(ModuleDetail module) {
  return module.viewTypes.contains('certificate') &&
      !module.viewTypes.contains('lesson') &&
      !module.viewTypes.contains('assignment') &&
      !module.viewTypes.contains('ebook') &&
      !module.viewTypes.contains('video_lecturer');
}

bool _isVideoLecturerModule(ModuleDetail module) {
  return module.viewTypes.contains('video_lecturer') &&
      !module.viewTypes.contains('lesson');
}

IconData _moduleHeroIcon(ModuleDetail module) {
  if (_isAssignmentModule(module)) return Icons.cloud_upload_rounded;
  if (_isCertificateModule(module)) return Icons.workspace_premium_rounded;
  if (_isEbookModule(module)) return Icons.menu_book_rounded;
  if (_isVideoLecturerModule(module)) return Icons.ondemand_video_rounded;
  return Icons.play_arrow_rounded;
}

String _moduleEyebrow(ModuleDetail module) {
  if (_isAssignmentModule(module)) return 'Final Assignment';
  if (_isCertificateModule(module)) return 'Certificate Access';
  if (_isEbookModule(module)) return 'Learning Material';
  if (_isVideoLecturerModule(module)) return 'Video Lecturer';
  return 'Learning Module';
}

String _moduleHeroDescription(ModuleDetail module) {
  if (_isAssignmentModule(module)) {
    return 'Upload your work, review submission progress, and track feedback from the academy.';
  }
  if (_isCertificateModule(module)) {
    return 'Your certificate is shown directly on this page when it is available.';
  }
  if (_isEbookModule(module)) {
    return 'Read the supporting material for this module and open each ebook from the list below.';
  }
  if (_isVideoLecturerModule(module)) {
    return 'Watch each lecturer video in sequence and continue with the next session when ready.';
  }
  return 'Open the learning content for this module and continue your progress from where you left off.';
}

String _primaryActionLabel(ModuleDetail module) {
  if (_isAssignmentModule(module)) return 'Open Assignments';
  if (_isCertificateModule(module)) return 'Certificate Ready';
  if (_isEbookModule(module)) return 'Open Ebook';
  if (_isVideoLecturerModule(module)) return 'Watch Video';
  return module.primaryCtaLabel ?? 'Open Module';
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

class _ModuleDetailError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  final VoidCallback onBack;

  const _ModuleDetailError({
    required this.message,
    required this.onRetry,
    required this.onBack,
  });

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
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: onBack,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      // DS: Sekunder — rgba(255,255,255,0.2)
                      color: const Color(0x33FFFFFF),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: _kBorderSoft, width: 0.8),
                    ),
                    child: const Text(
                      'Back',
                      style: TextStyle(
                        color: _kTextSecondary,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: onRetry,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      color: _kRed,
                      borderRadius: BorderRadius.circular(4),
                      boxShadow: _kShadowBtn,
                    ),
                    child: const Text(
                      'Try again',
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
