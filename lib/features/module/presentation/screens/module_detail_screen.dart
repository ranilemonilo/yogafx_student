import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/auth_network_image.dart';
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
const _kRedSoft = Color(0x1ADB202C);
const _kRedBorder = Color(0x4DDB202C);

// ─── Logic CTA Berdasarkan Source of Truth Backend ────────────────────────────

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
      final firstVideoIndex = videos.indexWhere((v) => v.status == 'ready');

      if (firstVideoIndex != -1) {
        final firstVideo = videos[firstVideoIndex];
        final hasNextVideo = firstVideoIndex < videos.length - 1;
        final nextVideo = hasNextVideo ? videos[firstVideoIndex + 1] : null;

        context.pushNamed(
          'videoLecturer',
          pathParameters: {
            'videoId': firstVideo.id.toString(),
          },
          queryParameters: {
            'title': firstVideo.title,
            'url': firstVideo.hlsUrl ?? '',
            if (hasNextVideo && nextVideo != null)
              'nextVideoId': nextVideo.id.toString(),
            if (hasNextVideo && nextVideo != null)
              'nextVideoTitle': nextVideo.title,
            if (hasNextVideo && nextVideo != null)
              'nextVideoUrl': nextVideo.hlsUrl ?? '',
          },
        );
      }
    }
  } else if (kind == 'download') {
    final firstCertificate = module.certificates.firstOrNull;

    if (firstCertificate != null) {
      context.push('/certificates/${firstCertificate.id}');
    } else {
      context.push('/certificates');
    }
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

  const ModuleDetailScreen({
    super.key,
    required this.moduleId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final moduleAsync = ref.watch(moduleDetailProvider(moduleId));

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
        ),
      ),
    );
  }
}

// ─── Content ──────────────────────────────────────────────────────────────────

class _ModuleDetailContent extends StatefulWidget {
  final int moduleId;
  final ModuleDetail module;

  const _ModuleDetailContent({
    required this.moduleId,
    required this.module,
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

    _heroCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
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
      (i) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 400),
      ),
    );

    _itemFades = _itemCtrlList
        .map((c) => CurvedAnimation(parent: c, curve: Curves.easeOut))
        .toList();

    _itemSlides = _itemCtrlList
        .map(
          (c) => Tween<Offset>(
            begin: const Offset(0, 0.08),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: c, curve: Curves.easeOut)),
        )
        .toList();

    for (int i = 0; i < itemCount; i++) {
      Future.delayed(Duration(milliseconds: 120 + 55 * i), () {
        if (mounted) {
          _itemCtrlList[i].forward();
        }
      });
    }
  }

  @override
  void dispose() {
    _heroCtrl.dispose();

    for (final c in _itemCtrlList) {
      c.dispose();
    }

    super.dispose();
  }

  Widget _buildAnimated(Widget child) {
    final index = _animIndex++;

    if (index >= _itemFades.length) {
      return child;
    }

    return FadeTransition(
      opacity: _itemFades[index],
      child: SlideTransition(
        position: _itemSlides[index],
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final module = widget.module;
    final assignments = _parseAssignments(module.assignments);

    final shouldShowPrimaryCta = module.primaryCtaLabel != null &&
        !module.viewTypes.contains('ebook') &&
        !module.viewTypes.contains('video_lecturer');

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
            leading: Padding(
              padding: const EdgeInsets.all(8),
              child: GestureDetector(
                onTap: () => context.pop(),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.55),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Icon(
                    Icons.arrow_back,
                    color: _kTextPrimary,
                    size: 20,
                  ),
                ),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: FadeTransition(
                opacity: _heroFade,
                child: _HeroBanner(module: module),
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
                    _buildAnimated(_ActionRow(module: module)),
                    const SizedBox(height: 24),
                  ],
                  _buildAnimated(_ModuleHeader(module: module)),
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
                  if (module.viewTypes.contains('certificate'))
                    ..._buildCertificateInfo(module),
                  if (module.viewTypes.contains('lesson'))
                    ..._buildLessonList(module),
                  if (module.viewTypes.contains('assignment'))
                    ..._buildAssignmentList(assignments),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildLessonList(ModuleDetail module) {
    if (module.lessons.isEmpty) {
      return [];
    }

    return [
      _buildAnimated(
        _SectionHeader(
          title: 'Lessons',
          count: module.lessons.length,
        ),
      ),
      const SizedBox(height: 16),
      ...module.lessons.asMap().entries.map(
            (entry) => _buildAnimated(
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _LessonRow(
                  lesson: entry.value,
                  index: entry.key,
                ),
              ),
            ),
          ),
      const SizedBox(height: 16),
    ];
  }

  List<Widget> _buildEbookList(ModuleDetail module) {
    if (module.ebooks.isEmpty) {
      return [];
    }

    return [
      _buildAnimated(
        _SectionHeader(
          title: 'Ebooks',
          count: module.ebooks.length,
        ),
      ),
      const SizedBox(height: 16),
      ...module.ebooks.asMap().entries.map(
            (entry) => _buildAnimated(
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _EbookRow(
                  ebook: entry.value,
                  index: entry.key,
                ),
              ),
            ),
          ),
      const SizedBox(height: 16),
    ];
  }

  List<Widget> _buildCertificateInfo(ModuleDetail module) {
    if (module.certificates.isEmpty) {
      return [];
    }

    return [
      _buildAnimated(
        _SectionHeader(
          title: 'Certificates',
          count: module.certificates.length,
        ),
      ),
      const SizedBox(height: 16),
      ...module.certificates.asMap().entries.map(
            (entry) => _buildAnimated(
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _CertificateRow(
                  certificate: entry.value,
                  index: entry.key,
                ),
              ),
            ),
          ),
      const SizedBox(height: 16),
    ];
  }

  List<Widget> _buildAssignmentList(List<_ModuleAssignmentItem> assignments) {
    if (assignments.isEmpty) {
      return [];
    }

    return [
      _buildAnimated(
        _SectionHeader(
          title: 'Assignments',
          count: assignments.length,
        ),
      ),
      const SizedBox(height: 16),
      ...assignments.asMap().entries.map(
            (entry) => _buildAnimated(
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _AssignmentRow(
                  assignment: entry.value,
                  index: entry.key,
                ),
              ),
            ),
          ),
      const SizedBox(height: 16),
    ];
  }

  List<Widget> _buildVideoLecturerList(ModuleDetail module) {
    if (module.videoLecturers.isEmpty) {
      return [];
    }

    return [
      _buildAnimated(
        _SectionHeader(
          title: 'Video Lecturer',
          count: module.videoLecturers.length,
        ),
      ),
      const SizedBox(height: 16),
      ...module.videoLecturers.asMap().entries.map(
        (entry) {
          final isLast = entry.key == module.videoLecturers.length - 1;
          final nextVideo = !isLast ? module.videoLecturers[entry.key + 1] : null;

          return _buildAnimated(
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _VideoLecturerRow(
                video: entry.value,
                nextVideo: nextVideo,
                index: entry.key,
              ),
            ),
          );
        },
      ),
      const SizedBox(height: 16),
    ];
  }
}

// ─── Hero Banner ──────────────────────────────────────────────────────────────

class _HeroBanner extends StatelessWidget {
  final ModuleDetail module;

  const _HeroBanner({required this.module});

  @override
  Widget build(BuildContext context) {
    IconData centerIcon = Icons.play_arrow_rounded;

    if (module.primaryCtaKind == 'document') {
      centerIcon = Icons.menu_book_rounded;
    }

    if (module.primaryCtaKind == 'download') {
      centerIcon = Icons.workspace_premium_outlined;
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        module.thumbnailUrl != null
            ? AuthNetworkImage(
                imageUrl: module.thumbnailUrl!,
                fit: BoxFit.cover,
                placeholderBuilder: (_) => Container(
                  color: _kSurfaceElevated,
                  child: const Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: _kTextMuted,
                      ),
                    ),
                  ),
                ),
                errorBuilderWidget: (_, __) => Container(
                  color: _kSurfaceElevated,
                  child: const Center(
                    child: Icon(
                      Icons.broken_image_rounded,
                      color: _kTextMuted,
                      size: 32,
                    ),
                  ),
                ),
              )
            : Container(
                color: _kSurfaceElevated,
                child: const Center(
                  child: Icon(
                    Icons.image_not_supported_rounded,
                    color: _kTextMuted,
                    size: 32,
                  ),
                ),
              ),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.4),
                Colors.black.withOpacity(0.15),
                _kBg,
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        ),
        if (module.primaryCtaLabel != null &&
            !module.viewTypes.contains('certificate') &&
            !module.viewTypes.contains('ebook') &&
            !module.viewTypes.contains('video_lecturer'))
          Center(
            child: GestureDetector(
              onTap: () => _openPrimaryModuleContent(context, module),
              child: Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.45),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withOpacity(0.8),
                    width: 1.5,
                  ),
                ),
                child: Icon(
                  centerIcon,
                  color: Colors.white,
                  size: 36,
                ),
              ),
            ),
          ),
        Positioned(
          top: 52,
          right: 16,
          child: _StatusBadge(status: module.status),
        ),
      ],
    );
  }
}

// ─── Action Row (Primary CTA) ─────────────────────────────────────────────────

class _ActionRow extends StatelessWidget {
  final ModuleDetail module;

  const _ActionRow({required this.module});

  @override
  Widget build(BuildContext context) {
    final primaryLabel = module.primaryCtaLabel ?? 'Open Module';

    IconData ctaIcon = Icons.play_arrow_rounded;

    if (module.primaryCtaKind == 'document') {
      ctaIcon = Icons.menu_book_rounded;
    }

    if (module.primaryCtaKind == 'download') {
      ctaIcon = Icons.workspace_premium_outlined;
    }

    final hasLessons = module.viewTypes.contains('lesson');

    return Row(
      children: [
        Expanded(
          flex: 3,
          child: GestureDetector(
            onTap: () => _openPrimaryModuleContent(context, module),
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    ctaIcon,
                    color: Colors.black,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      primaryLabel,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 16,
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
        if (hasLessons &&
            module.showProgress &&
            !module.isComplete &&
            module.progressPercentage > 0) ...[
          const SizedBox(width: 12),
          Expanded(
            flex: 3,
            child: GestureDetector(
              onTap: () => _openPrimaryModuleContent(context, module),
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: _kRed,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.play_circle_outline_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
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

  const _ModuleHeader({required this.module});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
        Wrap(
          spacing: 16,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: _kRedSoft,
                borderRadius: BorderRadius.circular(2),
                border: Border.all(
                  color: _kRedBorder,
                  width: 0.8,
                ),
              ),
              child: Text(
                module.status.toUpperCase(),
                style: const TextStyle(
                  color: _kRed,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Montserrat',
                  letterSpacing: 0.5,
                ),
              ),
            ),
            if (module.viewTypes.contains('lesson'))
              _MetaItem(
                icon: Icons.play_circle_outline_rounded,
                label: '${module.lessonCount} lessons',
              ),
            if (module.viewTypes.contains('assignment'))
              _MetaItem(
                icon: Icons.assignment_outlined,
                label: '${module.assignmentsCount} assignments',
              ),
            if (module.viewTypes.contains('certificate'))
              const _MetaItem(
                icon: Icons.workspace_premium_outlined,
                label: 'Certificate',
                accent: true,
              ),
            if (module.viewTypes.contains('ebook'))
              const _MetaItem(
                icon: Icons.menu_book_rounded,
                label: 'Ebook',
              ),
            if (module.viewTypes.contains('video_lecturer'))
              const _MetaItem(
                icon: Icons.play_circle_fill_rounded,
                label: 'Video Lecturer',
              ),
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

  const _MetaItem({
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
        const SizedBox(width: 4),
        Text(
          label,
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedCrossFade(
          firstChild: Text(
            widget.text,
            style: const TextStyle(
              color: _kTextSecondary,
              fontSize: 14,
              fontFamily: 'Montserrat',
              height: 1.6,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          secondChild: Text(
            widget.text,
            style: const TextStyle(
              color: _kTextSecondary,
              fontSize: 14,
              fontFamily: 'Montserrat',
              height: 1.6,
            ),
          ),
          crossFadeState:
              _expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
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
          Row(
            children: [
              const Text(
                'Your progress',
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
            module.isComplete
                ? '✓ Module completed'
                : '${module.progressPercentage}% complete',
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

  const _SectionHeader({
    required this.title,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 16,
          decoration: BoxDecoration(
            color: _kRed,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title.toUpperCase(),
          style: const TextStyle(
            color: _kTextSecondary,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            fontFamily: 'Montserrat',
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: _kSurfaceElevated,
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

  const _VideoLecturerRow({
    required this.video,
    required this.nextVideo,
    required this.index,
  });

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

    _pressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 130),
    );

    _scaleAnim = Tween<double>(begin: 1.0, end: 0.97).animate(
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
    final video = widget.video;
    final isReady = video.status == 'ready';
    final nextVideo = widget.nextVideo;

    return GestureDetector(
      onTap: isReady
          ? () {
              context.pushNamed(
                'videoLecturer',
                pathParameters: {
                  'videoId': video.id.toString(),
                },
                queryParameters: {
                  'title': video.title,
                  'url': video.hlsUrl ?? '',
                  if (nextVideo != null)
                    'nextVideoId': nextVideo.id.toString(),
                  if (nextVideo != null) 'nextVideoTitle': nextVideo.title,
                  if (nextVideo != null) 'nextVideoUrl': nextVideo.hlsUrl ?? '',
                },
              );
            }
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
            border: Border.all(color: _kDivider, width: 0.8),
            boxShadow: const [
              BoxShadow(
                color: Color(0x66000000),
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
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
                              placeholderBuilder: (_) =>
                                  _VideoThumbnailFallback(index: widget.index),
                              errorBuilderWidget: (_, __) =>
                                  _VideoThumbnailFallback(index: widget.index),
                            ),
                            Container(
                              color: Colors.black.withOpacity(0.35),
                              child: const Center(
                                child: Icon(
                                  Icons.play_arrow_rounded,
                                  color: Colors.white,
                                  size: 28,
                                ),
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
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isReady ? _kRedSoft : _kSurfaceElevated,
                        borderRadius: BorderRadius.circular(2),
                        border: Border.all(
                          color: isReady ? _kRedBorder : Colors.transparent,
                          width: 0.8,
                        ),
                      ),
                      child: Text(
                        isReady ? 'Ready' : 'Unavailable',
                        style: TextStyle(
                          color: isReady ? _kRed : _kTextMuted,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Montserrat',
                        ),
                      ),
                    ),
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
      color: _kSurfaceElevated,
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

List<_ModuleAssignmentItem> _parseAssignments(List<dynamic> assignments) {
  return assignments
      .whereType<Map>()
      .map((raw) {
        final data = Map<String, dynamic>.from(raw);

        return _ModuleAssignmentItem(
          id: data['id'] as int? ?? 0,
          title: (data['title'] ?? data['name'] ?? 'Assignment').toString(),
          description: data['description']?.toString(),
          isLocked: data['is_locked'] as bool? ?? false,
          lockReason: data['lock_reason']?.toString(),
          status: (data['status'] ?? data['submission_status'] ?? 'available')
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

  const _EbookRow({
    required this.ebook,
    required this.index,
  });

  @override
  State<_EbookRow> createState() => _EbookRowState();
}

class _EbookRowState extends State<_EbookRow> with SingleTickerProviderStateMixin {
  late AnimationController _pressCtrl;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();

    _pressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 130),
    );

    _scaleAnim = Tween<double>(begin: 1.0, end: 0.97).animate(
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
            border: Border.all(color: _kDivider, width: 0.8),
            boxShadow: const [
              BoxShadow(
                color: Color(0x66000000),
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: _kRedSoft,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: _kRedBorder, width: 0.8),
                ),
                child: const Icon(
                  Icons.menu_book_rounded,
                  color: _kRed,
                  size: 24,
                ),
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

// ─── Certificate Row ──────────────────────────────────────────────────────────

class _CertificateRow extends StatefulWidget {
  final ModuleCertificateItem certificate;
  final int index;

  const _CertificateRow({
    required this.certificate,
    required this.index,
  });

  @override
  State<_CertificateRow> createState() => _CertificateRowState();
}

class _CertificateRowState extends State<_CertificateRow>
    with SingleTickerProviderStateMixin {
  late AnimationController _pressCtrl;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();

    _pressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 130),
    );

    _scaleAnim = Tween<double>(begin: 1.0, end: 0.97).animate(
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
    final certificate = widget.certificate;

    return GestureDetector(
      onTap: () => context.push('/certificates/${certificate.id}'),
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
            border: Border.all(color: _kDivider, width: 0.8),
            boxShadow: const [
              BoxShadow(
                color: Color(0x66000000),
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: _kRedSoft,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: _kRedBorder, width: 0.8),
                ),
                child: const Icon(
                  Icons.workspace_premium_outlined,
                  color: _kRed,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${widget.index + 1}. ${certificate.typeLabel}',
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
                  ],
                ),
              ),
              const SizedBox(width: 8),
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

// ─── Lesson Row ───────────────────────────────────────────────────────────────

class _LessonRow extends StatefulWidget {
  final ModuleLesson lesson;
  final int index;

  const _LessonRow({
    required this.lesson,
    required this.index,
  });

  @override
  State<_LessonRow> createState() => _LessonRowState();
}

class _LessonRowState extends State<_LessonRow>
    with SingleTickerProviderStateMixin {
  late AnimationController _pressCtrl;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();

    _pressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 130),
    );

    _scaleAnim = Tween<double>(begin: 1.0, end: 0.97).animate(
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
            border: Border.all(color: _kDivider, width: 0.8),
            boxShadow: const [
              BoxShadow(
                color: Color(0x66000000),
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
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
                              placeholderBuilder: (_) =>
                                  _LessonThumbnailFallback(
                                index: widget.index,
                                isLocked: isLocked,
                              ),
                              errorBuilderWidget: (_, __) =>
                                  _LessonThumbnailFallback(
                                index: widget.index,
                                isLocked: isLocked,
                              ),
                            ),
                            if (isLocked)
                              Container(
                                color: Colors.black.withOpacity(0.65),
                                child: const Icon(
                                  Icons.lock_rounded,
                                  color: _kTextMuted,
                                  size: 20,
                                ),
                              )
                            else
                              Container(
                                color: Colors.black.withOpacity(0.35),
                                child: const Center(
                                  child: Icon(
                                    Icons.play_arrow_rounded,
                                    color: Colors.white,
                                    size: 28,
                                  ),
                                ),
                              ),
                          ],
                        )
                      : _LessonThumbnailFallback(
                          index: widget.index,
                          isLocked: isLocked,
                        ),
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
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        if (lesson.hasVideo)
                          const _MediaIcon(
                            icon: Icons.play_circle_outline_rounded,
                          ),
                        if (lesson.hasAudio)
                          const _MediaIcon(
                            icon: Icons.headphones_rounded,
                          ),
                        if (lesson.hasWorkbook)
                          const _MediaIcon(
                            icon: Icons.description_rounded,
                          ),
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
                          minHeight: 2.5,
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

  const _AssignmentRow({
    required this.assignment,
    required this.index,
  });

  @override
  State<_AssignmentRow> createState() => _AssignmentRowState();
}

class _AssignmentRowState extends State<_AssignmentRow>
    with SingleTickerProviderStateMixin {
  late AnimationController _pressCtrl;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();

    _pressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 130),
    );

    _scaleAnim = Tween<double>(begin: 1.0, end: 0.97).animate(
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
    final assignment = widget.assignment;
    final isLocked = assignment.isLocked;
    final statusLabel = assignment.status.replaceAll('_', ' ');

    return GestureDetector(
      onTap: isLocked
          ? () => _showLockedDialog(context, assignment.lockReason)
          : () => context.pushNamed(
                'assignment',
                pathParameters: {
                  'assignmentId': assignment.id.toString(),
                },
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
            border: Border.all(color: _kDivider, width: 0.8),
            boxShadow: const [
              BoxShadow(
                color: Color(0x66000000),
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
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
                    if (assignment.description != null &&
                        assignment.description!.trim().isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        assignment.description!,
                        style: const TextStyle(
                          color: _kTextMuted,
                          fontSize: 12,
                          height: 1.45,
                          fontFamily: 'Montserrat',
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isLocked ? _kSurfaceElevated : _kRedSoft,
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: Text(
                        isLocked ? 'Locked' : statusLabel,
                        style: TextStyle(
                          color: isLocked ? _kTextMuted : _kRed,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Montserrat',
                        ),
                      ),
                    ),
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

void _showLockedDialog(BuildContext context, String? reason) {
  showDialog(
    context: context,
    builder: (ctx) => Dialog(
      backgroundColor: _kSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.lock_rounded,
                  color: _kTextMuted,
                  size: 24,
                ),
                SizedBox(width: 12),
                Text(
                  'Lesson locked',
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: _kRed,
                    borderRadius: BorderRadius.circular(4),
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

class _LessonThumbnailFallback extends StatelessWidget {
  final int index;
  final bool isLocked;

  const _LessonThumbnailFallback({
    required this.index,
    required this.isLocked,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _kSurfaceElevated,
      child: Center(
        child: isLocked
            ? const Icon(
                Icons.lock_rounded,
                color: _kTextMuted,
                size: 24,
              )
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

class _MediaIcon extends StatelessWidget {
  final IconData icon;

  const _MediaIcon({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: Icon(
        icon,
        color: _kTextMuted,
        size: 18,
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
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.65),
        borderRadius: BorderRadius.circular(2),
        border: Border.all(
          color: color.withOpacity(0.5),
          width: 0.8,
        ),
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

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Bone(
              width: double.infinity,
              height: 280,
              color: c,
              radius: 0,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Bone(
                    width: double.infinity,
                    height: 48,
                    color: c,
                  ),
                  const SizedBox(height: 24),
                  _Bone(
                    width: 80,
                    height: 20,
                    color: c,
                  ),
                  const SizedBox(height: 12),
                  _Bone(
                    width: 240,
                    height: 28,
                    color: c,
                  ),
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
              child: const Icon(
                Icons.wifi_off_rounded,
                color: _kRed,
                size: 28,
              ),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: onBack,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: _kSurfaceElevated,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: _kDivider, width: 0.8),
                    ),
                    child: const Text(
                      'Back',
                      style: TextStyle(
                        color: _kTextSecondary,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: onRetry,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: _kRed,
                      borderRadius: BorderRadius.circular(4),
                      boxShadow: const [
                        BoxShadow(
                          color: _kRedBorder,
                          blurRadius: 12,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Text(
                      'Try again',
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w600,
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
