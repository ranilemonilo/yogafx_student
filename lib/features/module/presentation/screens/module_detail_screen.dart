import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
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

// ─── Root Screen ──────────────────────────────────────────────────────────────

class ModuleDetailScreen extends ConsumerWidget {
  final int moduleId;

  const ModuleDetailScreen({super.key, required this.moduleId});

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
        data: (module) => _ModuleDetailContent(moduleId: moduleId, module: module),
      ),
    );
  }
}

// ─── Content ──────────────────────────────────────────────────────────────────

class _ModuleDetailContent extends StatefulWidget {
  final int moduleId;
  final ModuleDetail module;

  const _ModuleDetailContent({required this.moduleId, required this.module});

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

  @override
  void initState() {
    super.initState();

    _heroCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _heroFade = CurvedAnimation(parent: _heroCtrl, curve: Curves.easeOut);
    _heroCtrl.forward();

    final itemCount =
        widget.module.lessons.length + widget.module.assignments.length + 5;
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
        .map((c) => Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: c, curve: Curves.easeOut)))
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
    for (final c in _itemCtrlList) {
      c.dispose();
    }
    super.dispose();
  }

  Widget _animated(int index, Widget child) {
    if (index >= _itemFades.length) return child;
    return FadeTransition(
      opacity: _itemFades[index],
      child: SlideTransition(position: _itemSlides[index], child: child),
    );
  }

  @override
  Widget build(BuildContext context) {
    final module = widget.module;
    final assignments = _parseAssignments(module.assignments);

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
          // ── Hero with play button ──
          SliverAppBar(
            expandedHeight: 280, // Sedikit diperbesar untuk hero
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
                    borderRadius: BorderRadius.circular(4), // Radius standar
                  ),
                  child: const Icon(
                    Icons.arrow_back, // Ikon panah yang lebih minimalis
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

          // ── Body ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 48), // Padding horizontal 4% (~16px)
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Netflix-style action row (Play + Resume)
                  _animated(0, _ActionRow(module: module)),
                  const SizedBox(height: 24),

                  // Title + meta
                  _animated(1, _ModuleHeader(module: module)),
                  const SizedBox(height: 24),

                  // Progress
                  if (module.showProgress) ...[
                    _animated(2, _ModuleProgress(module: module)),
                    const SizedBox(height: 24),
                  ],

                  // Description
                  if (module.description != null) ...[
                    _animated(2, _Description(text: module.description!)),
                    const SizedBox(height: 28),
                  ],

                  // Lessons
                  if (module.lessons.isNotEmpty) ...[
                    _animated(
                      2,
                      _SectionHeader(
                        title: 'Lessons',
                        count: module.lessons.length,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...module.lessons.asMap().entries.map(
                          (entry) => _animated(
                        entry.key + 3,
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8), // Gutter antar card 8px
                          child: _LessonRow(
                            lesson: entry.value,
                            index: entry.key,
                          ),
                        ),
                      ),
                    ),
                  ],
                  if (assignments.isNotEmpty) ...[
                    const SizedBox(height: 28),
                    _animated(
                      module.lessons.length + 3,
                      _SectionHeader(
                        title: 'Assignments',
                        count: assignments.length,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...assignments.asMap().entries.map(
                          (entry) => _animated(
                        module.lessons.length + entry.key + 4,
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8), // Gutter antar card 8px
                          child: _AssignmentRow(
                            assignment: entry.value,
                            index: entry.key,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Hero Banner ──────────────────────────────────────────────────────────────

class _HeroBanner extends StatelessWidget {
  final ModuleDetail module;

  const _HeroBanner({required this.module});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Thumbnail
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

        // Dark vignette blending to Background
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.4),
                Colors.black.withOpacity(0.15),
                _kBg, // Transisi mulus ke warna background utama
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        ),

        // Big play button — center
        Center(
          child: GestureDetector(
            onTap: () {
              // Navigate to first available lesson
              final firstLesson = module.lessons
                  .where((l) => !l.isLocked)
                  .firstOrNull;
              if (firstLesson != null) {
                context.push('/lessons/${firstLesson.id}');
              }
            },
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.45), // Transparan gelap seperti pemutar video
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity(0.8),
                  width: 1.5,
                ),
              ),
              child: const Icon(
                Icons.play_arrow_rounded,
                color: Colors.white,
                size: 36,
              ),
            ),
          ),
        ),

        // Status badge top right
        Positioned(
          top: 52,
          right: 16,
          child: _StatusBadge(status: module.status),
        ),
      ],
    );
  }
}

// ─── Action Row (Netflix Play + Info buttons) ─────────────────────────────────

class _ActionRow extends StatelessWidget {
  final ModuleDetail module;

  const _ActionRow({required this.module});

  @override
  Widget build(BuildContext context) {
    final firstLesson = module.lessons
        .where((l) => !l.isLocked)
        .firstOrNull;

    return Row(
      children: [
        // Play button — primary CTA
        Expanded(
          flex: 3,
          child: GestureDetector(
            onTap: () {
              if (firstLesson != null) {
                context.push('/lessons/${firstLesson.id}');
              }
            },
            child: Container(
              height: 48, // Minimal tinggi tap target (48px)
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4), // Radius desain 4px
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.play_arrow_rounded, color: Colors.black, size: 24),
                  SizedBox(width: 8),
                  Text(
                    'Play',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16, // Body/Button Text
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Montserrat',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12), // Gutter kelipatan 4/8

        // Resume / Continue — if in progress
        if (module.showProgress && !module.isComplete && module.progressPercentage > 0)
          Expanded(
            flex: 3,
            child: GestureDetector(
              onTap: () {
                if (firstLesson != null) {
                  context.push('/lessons/${firstLesson.id}');
                }
              },
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: _kRed,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.play_circle_outline_rounded,
                        color: Colors.white, size: 20),
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
        // Title
        Text(
          module.title,
          style: const TextStyle(
            color: _kTextPrimary,
            fontSize: 24, // Title 2 / Semi Bold
            fontWeight: FontWeight.w600,
            fontFamily: 'Montserrat',
          ),
        ),
        const SizedBox(height: 12),

        // Meta
        Wrap(
          spacing: 16, // Spasi horizontal meta data
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            // Status Chip disatukan dalam Meta
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0x1ADB202C), // Transparan merah
                borderRadius: BorderRadius.circular(2), // Badge 2px
                border: Border.all(
                  color: const Color(0x4DDB202C),
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
            _MetaItem(
              icon: Icons.play_circle_outline_rounded,
              label: '${module.lessonCount} lessons',
            ),
            if (module.assignmentsCount > 0)
              _MetaItem(
                icon: Icons.assignment_outlined,
                label: '${module.assignmentsCount} assignments',
              ),
            if (module.certificateEnabled)
              const _MetaItem(
                icon: Icons.workspace_premium_outlined,
                label: 'Certificate',
                accent: true,
              ),
            if (module.ebookEnabled)
              const _MetaItem(
                icon: Icons.menu_book_rounded,
                label: 'Ebook',
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
        Icon(icon,
            color: accent ? _kRed : _kTextMuted, size: 16),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            color: accent ? _kRed : _kTextSecondary,
            fontSize: 14, // Body Size
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
              fontSize: 14, // Body 14px
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
          crossFadeState: _expanded
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
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
        color: _kSurface, // Card standard surface
        borderRadius: BorderRadius.circular(4), // Radius 4px
        border: Border.all(color: _kDivider, width: 0.8),
        boxShadow: const [
          BoxShadow(
            color: Color(0x66000000), // Shadow subtle
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
            borderRadius: BorderRadius.circular(2), // Badge/bar radius 2px
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

  const _SectionHeader({required this.title, required this.count});

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
            fontSize: 14, // Headline 2 size equivalent
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
            borderRadius: BorderRadius.circular(2), // Badge radius 2px
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

// ─── Lesson Row ───────────────────────────────────────────────────────────────

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

class _LessonRow extends StatefulWidget {
  final ModuleLesson lesson;
  final int index;

  const _LessonRow({required this.lesson, required this.index});

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
            color: _kSurface, // Card default
            borderRadius: BorderRadius.circular(4), // Radius 4px
            border: Border.all(color: _kDivider, width: 0.8),
            boxShadow: const [
              BoxShadow(
                color: Color(0x66000000), // Card subtle shadow
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // Thumbnail (Aspect ratio 16:9 disesuaikan)
              ClipRRect(
                borderRadius: BorderRadius.circular(4), // Radius dalam 4px
                child: SizedBox(
                  width: 120, // Lebar ideal untuk thumbnail 16:9 di mobile
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
                      // Mini play overlay
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

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Lesson number + title
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

                    // Media icons
                    Row(
                      children: [
                        if (lesson.hasVideo)
                          const _MediaIcon(icon: Icons.play_circle_outline_rounded),
                        if (lesson.hasAudio)
                          const _MediaIcon(icon: Icons.headphones_rounded),
                        if (lesson.hasWorkbook)
                          const _MediaIcon(icon: Icons.description_rounded),
                      ],
                    ),

                    // Progress bar
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

              // Right icon
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
          padding: const EdgeInsets.all(16), // Padding distandardkan
          decoration: BoxDecoration(
            color: _kSurface,
            borderRadius: BorderRadius.circular(4), // Radius 4px
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
                  color: isLocked
                      ? Colors.black.withOpacity(0.25)
                      : const Color(0x1ADB202C), // Transparan Red
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: isLocked ? Colors.transparent : const Color(0x4DDB202C),
                    width: 0.8,
                  ),
                ),
                child: Icon(
                  isLocked
                      ? Icons.lock_outline_rounded
                      : Icons.assignment_rounded,
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
                        color: isLocked
                            ? _kSurfaceElevated
                            : const Color(0x1ADB202C),
                        borderRadius: BorderRadius.circular(2), // Badge radius 2px
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), // Modal Radius 8px sesuai sistem
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.lock_rounded, color: _kTextMuted, size: 24),
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
                  padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    color: _kRed,
                    borderRadius: BorderRadius.circular(4), // Button radius 4px
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

class _MediaIcon extends StatelessWidget {
  final IconData icon;

  const _MediaIcon({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: Icon(icon, color: _kTextMuted, size: 18),
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
      case 'completed':
        color = _kGreen;
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
            _Bone(width: double.infinity, height: 280, color: c, radius: 0),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    _Bone(width: double.infinity, height: 48, color: c),
                  ]),
                  const SizedBox(height: 24),
                  _Bone(width: 80, height: 20, color: c),
                  const SizedBox(height: 12),
                  _Bone(width: 240, height: 28, color: c),
                  const SizedBox(height: 24),
                  ...List.generate(
                    4,
                        (_) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _Bone(
                          width: double.infinity, height: 92, color: c),
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
    this.radius = 4, // Skeleton radius sesuai border card (4px)
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
                color: const Color(0x1ADB202C),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0x4DDB202C)),
              ),
              child: const Icon(Icons.wifi_off_rounded,
                  color: _kRed, size: 28),
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
                        horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      color: _kSurfaceElevated,
                      borderRadius: BorderRadius.circular(4), // Button radius 4px
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
                        horizontal: 20, vertical: 12),
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