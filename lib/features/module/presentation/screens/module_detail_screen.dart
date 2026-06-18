import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/auth_network_image.dart';
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
        data: (module) => _ModuleDetailContent(module: module),
      ),
    );
  }
}

// ─── Content ──────────────────────────────────────────────────────────────────

class _ModuleDetailContent extends StatefulWidget {
  final ModuleDetail module;

  const _ModuleDetailContent({required this.module});

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

    final itemCount = widget.module.lessons.length + 3; // header + progress + desc
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

    return CustomScrollView(
      slivers: [
        // ── Hero with play button ──
        SliverAppBar(
          expandedHeight: 240,
          pinned: true,
          backgroundColor: _kBg,
          elevation: 0,
          leading: Padding(
            padding: const EdgeInsets.all(8),
            child: GestureDetector(
              onTap: () => context.pop(),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.55),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new,
                  color: _kTextPrimary,
                  size: 16,
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
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 48),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Netflix-style action row (Play + My List)
                _animated(0, _ActionRow(module: module)),
                const SizedBox(height: 20),

                // Title + meta
                _animated(1, _ModuleHeader(module: module)),
                const SizedBox(height: 20),

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
                  const SizedBox(height: 12),
                  ...module.lessons.asMap().entries.map(
                        (entry) => _animated(
                      entry.key + 3,
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _LessonRow(
                          lesson: entry.value,
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
                      width: 22,
                      height: 22,
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
                      Icons.broken_image_outlined,
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
              Icons.image_not_supported_outlined,
              color: _kTextMuted,
              size: 32,
            ),
          ),
        ),

        // Dark vignette
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.3),
                Colors.black.withOpacity(0.15),
                _kBg,
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
                color: Colors.white.withOpacity(0.15),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity(0.8),
                  width: 2,
                ),
              ),
              child: const Icon(
                Icons.play_arrow,
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
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.play_arrow, color: Colors.black, size: 22),
                  SizedBox(width: 6),
                  Text(
                    'Play',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Montserrat',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),

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
                height: 44,
                decoration: BoxDecoration(
                  color: _kNetflixRed,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.play_circle_outline,
                        color: Colors.white, size: 18),
                    SizedBox(width: 6),
                    Text(
                      'Resume',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
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
        // Status chip
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: _kNetflixRed.withOpacity(0.15),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: _kNetflixRed.withOpacity(0.35),
              width: 0.5,
            ),
          ),
          child: Text(
            module.status.toUpperCase(),
            style: const TextStyle(
              color: _kNetflixRed,
              fontSize: 10,
              fontWeight: FontWeight.w600,
              fontFamily: 'Montserrat',
              letterSpacing: 1,
            ),
          ),
        ),
        const SizedBox(height: 10),

        // Title
        Text(
          module.title,
          style: const TextStyle(
            color: _kTextPrimary,
            fontSize: 24,
            fontWeight: FontWeight.w700,
            fontFamily: 'Montserrat',
          ),
        ),
        const SizedBox(height: 12),

        // Meta
        Wrap(
          spacing: 14,
          runSpacing: 6,
          children: [
            _MetaItem(
              icon: Icons.play_circle_outline,
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
                icon: Icons.menu_book_outlined,
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
            color: accent ? _kNetflixRed : _kTextMuted, size: 14),
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
          crossFadeState: _expanded
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 200),
        ),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: () => setState(() => _expanded = !_expanded),
          child: Text(
            _expanded ? 'Show less' : 'Show more',
            style: const TextStyle(
              color: _kTextPrimary,
              fontSize: 13,
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
        color: _kSurfaceElevated,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: _kDivider, width: 0.5),
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
                  fontSize: 12,
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
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: module.progressPercentage / 100,
              backgroundColor: _kDivider,
              valueColor: AlwaysStoppedAnimation<Color>(
                module.isComplete ? _kGreenCheck : _kNetflixRed,
              ),
              minHeight: 4,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            module.isComplete
                ? '✓ Module completed'
                : '${module.progressPercentage}% complete',
            style: TextStyle(
              color: module.isComplete ? _kGreenCheck : _kTextMuted,
              fontSize: 11,
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
        Text(
          title.toUpperCase(),
          style: const TextStyle(
            color: _kTextSecondary,
            fontSize: 11,
            fontWeight: FontWeight.w600,
            fontFamily: 'Montserrat',
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
          decoration: BoxDecoration(
            color: _kSurfaceElevated,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            '$count',
            style: const TextStyle(
              color: _kTextMuted,
              fontSize: 10,
              fontFamily: 'Montserrat',
            ),
          ),
        ),
      ],
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
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: _kDivider, width: 0.5),
          ),
          child: Row(
            children: [
              // Thumbnail
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: SizedBox(
                  width: 76,
                  height: 52,
                  child: lesson.thumbnailUrl != null
                      ? Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        lesson.thumbnailUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, error, __) {
                          return _LessonThumbnailFallback(
                            index: widget.index,
                            isLocked: isLocked,
                          );
                        },
                      ),
                      if (isLocked)
                        Container(
                          color: Colors.black.withOpacity(0.55),
                          child: const Icon(
                            Icons.lock_outline,
                            color: _kTextMuted,
                            size: 18,
                          ),
                        )
                      else
                      // Mini play overlay
                        Container(
                          color: Colors.black.withOpacity(0.25),
                          child: const Center(
                            child: Icon(
                              Icons.play_arrow,
                              color: Colors.white,
                              size: 22,
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
              const SizedBox(width: 12),

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
                            fontSize: 12,
                            fontFamily: 'Montserrat',
                          ),
                        ),
                        Expanded(
                          child: Text(
                            lesson.title,
                            style: TextStyle(
                              color: isLocked ? _kTextMuted : _kTextPrimary,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Montserrat',
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),

                    // Media icons
                    Row(
                      children: [
                        if (lesson.hasVideo)
                          const _MediaIcon(icon: Icons.play_circle_outline),
                        if (lesson.hasAudio)
                          const _MediaIcon(icon: Icons.headphones_outlined),
                        if (lesson.hasWorkbook)
                          const _MediaIcon(icon: Icons.description_outlined),
                      ],
                    ),

                    // Progress bar
                    if (!isLocked && lesson.progressPercentage > 0) ...[
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(2),
                        child: LinearProgressIndicator(
                          value: lesson.progressPercentage / 100,
                          backgroundColor: _kDivider,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                              _kNetflixRed),
                          minHeight: 2,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // Right icon
              Icon(
                isLocked ? Icons.lock_outline : Icons.chevron_right,
                color: isLocked ? _kTextMuted : _kTextSecondary,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLockedDialog(BuildContext context, String? reason) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: _kSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.lock_outline, color: _kTextMuted, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'Lesson locked',
                    style: TextStyle(
                      color: _kTextPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Montserrat',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                reason ?? 'Complete the previous lesson to unlock this one.',
                style: const TextStyle(
                  color: _kTextSecondary,
                  fontSize: 13,
                  fontFamily: 'Montserrat',
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () => Navigator.pop(ctx),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: _kNetflixRed,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'Got it',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
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
            ? const Icon(Icons.lock_outline, color: _kTextMuted, size: 18)
            : Text(
          '${index + 1}',
          style: const TextStyle(
            color: _kTextSecondary,
            fontSize: 18,
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
      padding: const EdgeInsets.only(right: 8),
      child: Icon(icon, color: _kTextMuted, size: 14),
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
            _Bone(width: double.infinity, height: 240, color: c, radius: 0),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    _Bone(width: double.infinity, height: 44, color: c),
                  ]),
                  const SizedBox(height: 20),
                  _Bone(width: 70, height: 20, color: c),
                  const SizedBox(height: 10),
                  _Bone(width: 220, height: 26, color: c),
                  const SizedBox(height: 24),
                  ...List.generate(
                    4,
                        (_) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _Bone(
                          width: double.infinity, height: 76, color: c),
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
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: _kDivider, width: 0.5),
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
                      color: _kNetflixRed,
                      borderRadius: BorderRadius.circular(4),
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
