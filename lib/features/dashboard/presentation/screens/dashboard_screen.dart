import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/router/app_router.dart';
import '../../../../features/auth/presentation/providers/auth_provider.dart';
import '../../../../core/widgets/auth_network_image.dart';
import '../../../../core/widgets/running_login_time_card.dart';
import '../../../profile/presentation/providers/profile_provider.dart';
import '../providers/dashboard_provider.dart';
import '../../data/models/dashboard_model.dart';

// ─── Design Tokens ────────────────────────────────────────────────────────────

const _kRed = Color(0xFFE50914);
const _kRedDim = Color(0xFFB20710);
const _kBg = Color(0xFF0D0D0D);
const _kSurface = Color(0xFF161616);
const _kSurfaceElevated = Color(0xFF1E1E1E);
const _kSurfaceHigh = Color(0xFF262626);
const _kDivider = Color(0xFF252525);
const _kWhite = Colors.white;
const _kTextPrimary = Colors.white;
const _kTextSecondary = Color(0xFFB3B3B3);
const _kTextMuted = Color(0xFF6B6B6B);
const _kGreen = Color(0xFF46D369);

// ─── Root Screen ──────────────────────────────────────────────────────────────

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(dashboardProvider);

    return Scaffold(
      backgroundColor: _kBg,
      extendBodyBehindAppBar: true,
      body: dashboardAsync.when(
        loading: () => const _DashboardSkeleton(),
        error: (e, _) => _DashboardError(
          message: e.toString(),
          onRetry: () => ref.invalidate(dashboardProvider),
        ),
        data: (data) => _DashboardContent(data: data),
      ),
    );
  }
}

Future<void> _showProfileMenu(BuildContext context, WidgetRef ref) async {
  await showModalBottomSheet<void>(
    context: context,
    backgroundColor: _kSurface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (sheetContext) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: _kDivider,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Profile Menu',
                style: TextStyle(
                  color: _kTextPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Montserrat',
                ),
              ),
              const SizedBox(height: 16),
              _ProfileMenuTile(
                icon: Icons.person_outline_rounded,
                title: 'View Profile',
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  context.push(AppRoutes.profile);
                },
              ),
              const SizedBox(height: 10),
              _ProfileMenuTile(
                icon: Icons.logout_rounded,
                title: 'Log Out',
                isDanger: true,
                onTap: () async {
                  Navigator.of(sheetContext).pop();
                  final confirmed = await _confirmLogout(context);
                  if (confirmed == true) {
                    await ref.read(authProvider.notifier).logout();
                  }
                },
              ),
            ],
          ),
        ),
      );
    },
  );
}

Future<void> _showInstantDialogMenu(BuildContext context) async {
  await showModalBottomSheet<void>(
    context: context,
    backgroundColor: _kSurface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (sheetContext) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: _kDivider,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Instant Access Dialog',
                style: TextStyle(
                  color: _kTextPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Montserrat',
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Choose the dialog you want to open.',
                style: TextStyle(
                  color: _kTextSecondary,
                  fontSize: 12,
                  fontFamily: 'Montserrat',
                ),
              ),
              const SizedBox(height: 16),
              _QuickDialogTile(
                icon: Icons.accessibility_new_rounded,
                title: 'Standing',
                subtitle: 'Open the standing dialog sequence.',
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  context.push('/dialogs/full-standing');
                },
              ),
              const SizedBox(height: 10),
              _QuickDialogTile(
                icon: Icons.airline_seat_recline_normal_rounded,
                title: 'Floor',
                subtitle: 'Open the floor dialog sequence.',
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  context.push('/dialogs/full-floor');
                },
              ),
            ],
          ),
        ),
      );
    },
  );
}

Future<bool?> _confirmLogout(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        backgroundColor: _kSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Log Out',
          style: TextStyle(
            color: _kTextPrimary,
            fontWeight: FontWeight.w700,
            fontFamily: 'Montserrat',
          ),
        ),
        content: const Text(
          'Are you sure you want to log out of your account?',
          style: TextStyle(
            color: _kTextSecondary,
            fontFamily: 'Montserrat',
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: _kRed,
              foregroundColor: _kWhite,
            ),
            child: const Text('Log Out'),
          ),
        ],
      );
    },
  );
}

// ─── Content ──────────────────────────────────────────────────────────────────

class _DashboardContent extends StatefulWidget {
  final DashboardData data;
  const _DashboardContent({required this.data});

  @override
  State<_DashboardContent> createState() => _DashboardContentState();
}

class _DashboardContentState extends State<_DashboardContent>
    with TickerProviderStateMixin {
  late final List<AnimationController> _controllers;
  late final List<Animation<double>> _fades;
  late final List<Animation<Offset>> _slides;

  static const int _sectionCount = 6;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      _sectionCount,
          (i) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 550),
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

    for (int i = 0; i < _sectionCount; i++) {
      Future.delayed(Duration(milliseconds: 90 * i), () {
        if (mounted) _controllers[i].forward();
      });
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) c.dispose();
    super.dispose();
  }

  Widget _animated(int index, Widget child) => FadeTransition(
    opacity: _fades[index],
    child: SlideTransition(position: _slides[index], child: child),
  );

  @override
  Widget build(BuildContext context) {
    final data = widget.data;

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        _YogaFXAppBar(student: data.student),
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _animated(0, _HeroSection(data: data)),
              if (data.continueLearningSection.state != 'empty') ...[
                const SizedBox(height: 28),
                _animated(
                  1,
                  _ContinueLearningSection(section: data.continueLearningSection),
                ),
              ],
              const SizedBox(height: 32),
              _animated(
                2,
                _ProgressSection(
                  section: data.progressSummarySection,
                  continueLearningSection: data.continueLearningSection,
                ),
              ),
              const SizedBox(height: 32),
              _animated(3, _ModulesSection(section: data.availableModulesSection)),
              const SizedBox(height: 32),
              _animated(
                4,
                _AssessmentBanner(
                  continueLearningSection: data.continueLearningSection,
                ),
              ),
              const SizedBox(height: 56),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── App Bar ──────────────────────────────────────────────────────────────────

class _YogaFXAppBar extends ConsumerWidget {
  final dynamic student;
  const _YogaFXAppBar({required this.student});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileProvider);
    final authState = ref.watch(authProvider);

    return SliverAppBar(
      backgroundColor: Colors.transparent,
      expandedHeight: 0,
      floating: true,
      snap: true,
      pinned: false,
      elevation: 0,
      titleSpacing: 20,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xD0000000), Colors.transparent],
          ),
        ),
      ),
      title: Image.asset(
        'assets/images/yogafx_logo.png',
        height: 26,
        fit: BoxFit.contain,
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(left: 8, right: 8),
          child: _InstantDialogButton(
            onTap: () => _showInstantDialogMenu(context),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 16, left: 4),
          child: GestureDetector(
            onTap: () => _showProfileMenu(context, ref),
            child: _DashboardProfileAvatar(
              imageUrl: profileAsync.value?.profilePhoto ?? authState.user?.avatar,
              displayName: profileAsync.value?.name ?? authState.user?.name ?? 'Student',
            ),
          ),
        ),
      ],
    );
  }
}

class _DashboardProfileAvatar extends StatelessWidget {
  final String? imageUrl;
  final String displayName;

  const _DashboardProfileAvatar({
    required this.imageUrl,
    required this.displayName,
  });

  @override
  Widget build(BuildContext context) {
    final hasImage = imageUrl != null && imageUrl!.trim().isNotEmpty;

    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: _kRed,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withOpacity(0.12)),
      ),
      clipBehavior: Clip.antiAlias,
      child: hasImage
          ? AuthNetworkImage(
              imageUrl: imageUrl!,
              fit: BoxFit.cover,
              placeholderBuilder: (_) => _DashboardProfileFallback(
                displayName: displayName,
              ),
              errorBuilderWidget: (_, __) => _DashboardProfileFallback(
                displayName: displayName,
              ),
            )
          : _DashboardProfileFallback(displayName: displayName),
    );
  }
}

class _DashboardProfileFallback extends StatelessWidget {
  final String displayName;

  const _DashboardProfileFallback({required this.displayName});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        _initials(displayName),
        style: const TextStyle(
          color: _kWhite,
          fontSize: 12,
          fontWeight: FontWeight.w700,
          fontFamily: 'Montserrat',
        ),
      ),
    );
  }
}

String _initials(String value) {
  final parts = value
      .trim()
      .split(RegExp(r'\s+'))
      .where((part) => part.isNotEmpty)
      .toList();
  if (parts.isEmpty) return 'Y';
  if (parts.length == 1) {
    return parts.first.substring(0, 1).toUpperCase();
  }
  return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
      .toUpperCase();
}

class _InstantDialogButton extends StatelessWidget {
  final VoidCallback onTap;

  const _InstantDialogButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: _kSurfaceElevated,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: _kDivider, width: 0.8),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  'Instant Access Dialog',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _kTextPrimary,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Montserrat',
                  ),
                ),
              ),
              SizedBox(width: 6),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                color: _kTextSecondary,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickDialogTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _QuickDialogTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _kSurfaceElevated,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _kDivider, width: 0.8),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: _kRed.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: _kRed, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: _kTextPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: _kTextSecondary,
                        fontSize: 12,
                        fontFamily: 'Montserrat',
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.chevron_right_rounded,
                color: _kTextSecondary,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileMenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isDanger;
  final VoidCallback onTap;

  const _ProfileMenuTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.isDanger = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDanger ? AppColors.primary : _kTextPrimary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: _kSurfaceElevated,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _kDivider, width: 0.8),
          ),
          child: Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  color: color,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Montserrat',
                ),
              ),
              const Spacer(),
              Icon(Icons.chevron_right_rounded, color: color, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Hero Section ─────────────────────────────────────────────────────────────

class _HeroSection extends StatefulWidget {
  final DashboardData data;
  const _HeroSection({required this.data});

  @override
  State<_HeroSection> createState() => _HeroSectionState();
}

class _HeroSectionState extends State<_HeroSection>
    with SingleTickerProviderStateMixin {
  late AnimationController _glowCtrl;
  late Animation<double> _glowAnim;

  @override
  void initState() {
    super.initState();
    _glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);
    _glowAnim = CurvedAnimation(parent: _glowCtrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _glowCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final student = widget.data.student;
    final tier = student.accessTier;

    return Stack(
      children: [
        // Background cinematic gradient
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 36),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF1A0A0A), Color(0xFF0D0D0D)],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tier badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _kRed.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(3),
                  border: Border.all(color: _kRed.withOpacity(0.5), width: 0.8),
                ),
                child: Text(
                  tier.name.toUpperCase(),
                  style: const TextStyle(
                    color: _kRed,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Montserrat',
                    letterSpacing: 2,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              // Welcome line
              const Text(
                'SELAMAT DATANG KEMBALI',
                style: TextStyle(
                  color: _kTextMuted,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Montserrat',
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 6),
              // Name with shimmer
              _ShimmerText(
                text: student.firstName,
                style: const TextStyle(
                  color: _kTextPrimary,
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                  fontFamily: 'Montserrat',
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 20),
              // Red divider line — Netflix signature
              AnimatedBuilder(
                animation: _glowAnim,
                builder: (_, __) => Container(
                  width: 48,
                  height: 3,
                  decoration: BoxDecoration(
                    color: _kRed,
                    borderRadius: BorderRadius.circular(2),
                    boxShadow: [
                      BoxShadow(
                        color: _kRed.withOpacity(0.3 + _glowAnim.value * 0.4),
                        blurRadius: 8 + _glowAnim.value * 8,
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          top: 110,  // tepat di bawah AppBar, sejajar dengan tier badge
          right: 20,
          child: const RunningLoginTimeCard(),
        ),
        // Subtle scanline texture overlay
        Positioned.fill(
          child: IgnorePointer(
            child: CustomPaint(painter: _ScanlinePainter()),
          ),
        ),
      ],
    );
  }
}

// ─── Scanline Painter (cinematic texture) ─────────────────────────────────────

class _ScanlinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.015)
      ..strokeWidth = 1;
    for (double y = 0; y < size.height; y += 4) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_ScanlinePainter oldDelegate) => false;
}

// ─── Shimmer Text ─────────────────────────────────────────────────────────────

class _ShimmerText extends StatefulWidget {
  final String text;
  final TextStyle style;
  const _ShimmerText({required this.text, required this.style});

  @override
  State<_ShimmerText> createState() => _ShimmerTextState();
}

class _ShimmerTextState extends State<_ShimmerText>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat();
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
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
        return ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: const [
              Colors.white,
              Color(0xFFFFFFFF),
              Color(0xFFE8E8E8),
              Colors.white,
            ],
            stops: [
              (_anim.value - 0.3).clamp(0.0, 1.0),
              (_anim.value - 0.1).clamp(0.0, 1.0),
              (_anim.value + 0.1).clamp(0.0, 1.0),
              (_anim.value + 0.3).clamp(0.0, 1.0),
            ],
          ).createShader(bounds),
          child: Text(widget.text, style: widget.style),
        );
      },
    );
  }
}

// ─── Continue Learning ────────────────────────────────────────────────────────

class _ContinueLearningSection extends StatelessWidget {
  final ContinueLearningSection section;
  const _ContinueLearningSection({required this.section});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionLabel(text: section.eyebrow),
          const SizedBox(height: 14),
          _ContinueCard(section: section),
        ],
      ),
    );
  }
}

class _ContinueCard extends StatefulWidget {
  final ContinueLearningSection section;
  const _ContinueCard({required this.section});

  @override
  State<_ContinueCard> createState() => _ContinueCardState();
}

class _ContinueCardState extends State<_ContinueCard>
    with TickerProviderStateMixin {
  late AnimationController _scaleCtrl;
  late AnimationController _progressCtrl;
  late Animation<double> _scaleAnim;
  late Animation<double> _progressAnim;

  @override
  void initState() {
    super.initState();
    _scaleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 1.015).animate(
      CurvedAnimation(parent: _scaleCtrl, curve: Curves.easeOut),
    );

    _progressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _progressAnim = Tween<double>(
      begin: 0,
      end: widget.section.progressPercentage / 100,
    ).animate(CurvedAnimation(parent: _progressCtrl, curve: Curves.easeOut));

    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _progressCtrl.forward();
    });
  }

  @override
  void dispose() {
    _scaleCtrl.dispose();
    _progressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final section = widget.section;

    return GestureDetector(
      onTap: () => context.push('/lessons/${section.lesson.id}'),
      onTapDown: (_) => _scaleCtrl.forward(),
      onTapUp: (_) => _scaleCtrl.reverse(),
      onTapCancel: () => _scaleCtrl.reverse(),
      child: ScaleTransition(
        scale: _scaleAnim,
        child: Container(
          width: double.infinity,
          height: 220,
          decoration: BoxDecoration(
            color: _kSurface,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
            image: section.thumbnailUrl != null
                ? DecorationImage(
              image: NetworkImage(section.thumbnailUrl!),
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(
                Colors.black.withOpacity(0.5),
                BlendMode.darken,
              ),
            )
                : null,
          ),
          clipBehavior: Clip.hardEdge,
          child: Stack(
            children: [
              // Gradient overlay
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.95),
                    ],
                    stops: const [0.2, 1.0],
                  ),
                ),
              ),
              // Left red accent stripe
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                child: Container(
                  width: 3,
                  color: _kRed,
                ),
              ),
              // Content
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Module label
                    Text(
                      section.module.title.toUpperCase(),
                      style: const TextStyle(
                        color: _kRed,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Montserrat',
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 5),
                    // Lesson title
                    Text(
                      section.lesson.title,
                      style: const TextStyle(
                        color: _kTextPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        fontFamily: 'Montserrat',
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 14),
                    // Animated progress bar
                    AnimatedBuilder(
                      animation: _progressAnim,
                      builder: (_, __) => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(2),
                            child: LinearProgressIndicator(
                              value: _progressAnim.value,
                              backgroundColor: Colors.white.withOpacity(0.12),
                              valueColor: const AlwaysStoppedAnimation<Color>(_kRed),
                              minHeight: 2.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Text(
                          section.status,
                          style: const TextStyle(
                            color: _kTextSecondary,
                            fontSize: 11,
                            fontFamily: 'Montserrat',
                          ),
                        ),
                        const Spacer(),
                        // CTA Button
                        _RedButton(
                          label: section.ctaLabel,
                          icon: Icons.play_arrow_rounded,
                          onTap: () => context.push('/lessons/${section.lesson.id}'),
                        ),
                      ],
                    ),
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

// ─── Progress Section ─────────────────────────────────────────────────────────

class _ProgressSection extends StatefulWidget {
  final ProgressSummarySection section;
  final ContinueLearningSection continueLearningSection;

  const _ProgressSection({
    required this.section,
    required this.continueLearningSection,
  });

  @override
  State<_ProgressSection> createState() => _ProgressSectionState();
}

class _ProgressSectionState extends State<_ProgressSection>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    Future.delayed(const Duration(milliseconds: 300), () {
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionLabel(text: widget.section.eyebrow),
          const SizedBox(height: 14),
          Row(
            children: [
              _AnimatedStatCard(
                label: 'Modules',
                value: '${widget.section.modulesCompleted}/${widget.section.modulesTotal}',
                icon: Icons.layers_rounded,
                animation: _anim,
                onTap: () => context.push(AppRoutes.modules),
              ),
              const SizedBox(width: 10),
              _AnimatedStatCard(
                label: 'Lessons',
                value: '${widget.section.lessonsCompleted}/${widget.section.lessonsTotal}',
                icon: Icons.play_circle_rounded,
                animation: _anim,
                onTap: () => context.push(
                  '/lessons/${widget.continueLearningSection.lesson.id}',
                ),
              ),
              const SizedBox(width: 10),
              _AnimatedStatCard(
                label: 'Overall',
                value: '${widget.section.overallProgressPercentage}%',
                icon: Icons.bar_chart_rounded,
                animation: _anim,
                highlight: true,
                onTap: () => context.push(
                  AppRoutes.overallProgress,
                  extra: {
                    'modulesCompleted': widget.section.modulesCompleted,
                    'modulesTotal': widget.section.modulesTotal,
                    'lessonsCompleted': widget.section.lessonsCompleted,
                    'lessonsTotal': widget.section.lessonsTotal,
                    'overallProgressPercentage':
                        widget.section.overallProgressPercentage,
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AnimatedStatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Animation<double> animation;
  final bool highlight;
  final VoidCallback onTap;

  const _AnimatedStatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.animation,
    required this.onTap,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: AnimatedBuilder(
        animation: animation,
        builder: (_, __) => Transform.scale(
          scale: 0.85 + animation.value * 0.15,
          child: Opacity(
            opacity: animation.value,
            child: GestureDetector(
              onTap: onTap,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: highlight ? const Color(0xFF1A0A0A) : _kSurfaceElevated,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: highlight ? _kRed.withOpacity(0.4) : _kDivider,
                    width: 0.8,
                  ),
                  boxShadow: highlight
                      ? [
                          BoxShadow(
                            color: _kRed.withOpacity(0.12),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          )
                        ]
                      : [],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(icon,
                        color: highlight ? _kRed : _kTextMuted, size: 18),
                    const SizedBox(height: 10),
                    Text(
                      value,
                      style: TextStyle(
                        color: highlight ? _kRed : _kTextPrimary,
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      label,
                      style: const TextStyle(
                        color: _kTextMuted,
                        fontSize: 10,
                        fontFamily: 'Montserrat',
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Assessment Banner ────────────────────────────────────────────────────────

class _AssessmentBanner extends StatefulWidget {
  final ContinueLearningSection continueLearningSection;

  const _AssessmentBanner({required this.continueLearningSection});

  @override
  State<_AssessmentBanner> createState() => _AssessmentBannerState();
}

class _AssessmentBannerState extends State<_AssessmentBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
    _pulseAnim = CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: AnimatedBuilder(
        animation: _pulseAnim,
        builder: (_, __) => GestureDetector(
          onTap: () {
            context.push(
              '/lessons/${widget.continueLearningSection.lesson.id}/assessment',
            );
          },
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [Color(0xFF1A0A0A), Color(0xFF0D0D0D)],
              ),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: _kRed.withOpacity(0.25 + _pulseAnim.value * 0.2),
                width: 0.8,
              ),
              boxShadow: [
                BoxShadow(
                  color: _kRed.withOpacity(0.06 + _pulseAnim.value * 0.06),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: _kRed.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: _kRed.withOpacity(0.25), width: 0.8),
                  ),
                  child: const Icon(Icons.quiz_rounded, color: _kRed, size: 20),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Assessments',
                        style: TextStyle(
                          color: _kTextPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Montserrat',
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Continue the assessment from ${widget.continueLearningSection.lesson.title}',
                        style: const TextStyle(
                          color: _kTextMuted,
                          fontSize: 11,
                          fontFamily: 'Montserrat',
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.chevron_right_rounded,
                  color: _kRed.withOpacity(0.7),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Modules Section ──────────────────────────────────────────────────────────

class _ModulesSection extends StatefulWidget {
  final AvailableModulesSection section;
  const _ModulesSection({required this.section});

  @override
  State<_ModulesSection> createState() => _ModulesSectionState();
}

class _ModulesSectionState extends State<_ModulesSection>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchCtrl = TextEditingController();
  bool _searchOpen = false;
  String _query = '';

  late AnimationController _searchAnimCtrl;
  late Animation<double> _searchWidthAnim;
  late Animation<double> _searchFadeAnim;

  @override
  void initState() {
    super.initState();
    _searchAnimCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    _searchWidthAnim =
        CurvedAnimation(parent: _searchAnimCtrl, curve: Curves.easeOut);
    _searchFadeAnim =
        CurvedAnimation(parent: _searchAnimCtrl, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _searchAnimCtrl.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() => _searchOpen = !_searchOpen);
    if (_searchOpen) {
      _searchAnimCtrl.forward();
    } else {
      _searchAnimCtrl.reverse();
      _searchCtrl.clear();
      setState(() => _query = '');
    }
  }

  List<DashboardModuleItem> get _filtered {
    if (_query.trim().isEmpty) return widget.section.items;
    final q = _query.toLowerCase();
    return widget.section.items
        .where((m) => m.title.toLowerCase().contains(q))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.section.items.isEmpty) return const SizedBox.shrink();
    final filtered = _filtered;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header row
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (!_searchOpen) _SectionLabel(text: widget.section.eyebrow),
              const Spacer(),
              // Animated search
              AnimatedBuilder(
                animation: _searchWidthAnim,
                builder: (context, child) => SizedBox(
                  width: _searchWidthAnim.value * 190,
                  child: FadeTransition(
                    opacity: _searchFadeAnim,
                    child: _searchOpen
                        ? TextField(
                      controller: _searchCtrl,
                      autofocus: true,
                      onChanged: (v) => setState(() => _query = v),
                      style: const TextStyle(
                        color: _kTextPrimary,
                        fontSize: 13,
                        fontFamily: 'Montserrat',
                      ),
                      decoration: InputDecoration(
                        hintText: 'Search modules...',
                        hintStyle: const TextStyle(
                          color: _kTextMuted,
                          fontSize: 13,
                          fontFamily: 'Montserrat',
                        ),
                        filled: true,
                        fillColor: _kSurfaceElevated,
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4),
                          borderSide: const BorderSide(
                              color: _kRed, width: 1),
                        ),
                      ),
                    )
                        : const SizedBox.shrink(),
                  ),
                ),
              ),
              if (_searchOpen) const SizedBox(width: 8),
              GestureDetector(
                onTap: _toggleSearch,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    _searchOpen ? Icons.close_rounded : Icons.search_rounded,
                    key: ValueKey(_searchOpen),
                    color: _searchOpen ? _kRed : _kTextSecondary,
                    size: 20,
                  ),
                ),
              ),
              if (!_searchOpen) ...[
                const SizedBox(width: 18),
                GestureDetector(
                  onTap: () => context.go(AppRoutes.modules),
                  child: const Row(
                    children: [
                      Text(
                        'Lihat semua',
                        style: TextStyle(
                          color: _kRed,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Montserrat',
                        ),
                      ),
                      SizedBox(width: 2),
                      Icon(Icons.chevron_right_rounded,
                          color: _kRed, size: 16),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Results
        if (filtered.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Row(
              children: [
                const Icon(Icons.search_off_rounded,
                    color: _kTextMuted, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Tidak ada modul untuk "$_query"',
                    style: const TextStyle(
                      color: _kTextMuted,
                      fontSize: 13,
                      fontFamily: 'Montserrat',
                    ),
                  ),
                ),
              ],
            ),
          )
        else
          SizedBox(
            height: 270,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              clipBehavior: Clip.none,
              itemCount: filtered.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) =>
                  _ModuleCard(module: filtered[index], index: index),
            ),
          ),
      ],
    );
  }
}

class _ModuleCard extends StatefulWidget {
  final DashboardModuleItem module;
  final int index;
  const _ModuleCard({required this.module, required this.index});

  @override
  State<_ModuleCard> createState() => _ModuleCardState();
}

class _ModuleCardState extends State<_ModuleCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _hoverCtrl;
  late Animation<double> _scaleAnim;
  late Animation<double> _glowAnim;

  @override
  void initState() {
    super.initState();
    _hoverCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 1.06).animate(
      CurvedAnimation(parent: _hoverCtrl, curve: Curves.easeOut),
    );
    _glowAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _hoverCtrl, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _hoverCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final module = widget.module;

    return GestureDetector(
      onTap: () => context.push('/modules/${module.id}'),
      onTapDown: (_) => _hoverCtrl.forward(),
      onTapUp: (_) => _hoverCtrl.reverse(),
      onTapCancel: () => _hoverCtrl.reverse(),
      child: AnimatedBuilder(
        animation: _hoverCtrl,
        builder: (_, child) => Transform.scale(
          scale: _scaleAnim.value,
          child: Container(
            width: 200,
            decoration: BoxDecoration(
              color: _kSurface,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
                BoxShadow(
                  color: _kRed.withOpacity(_glowAnim.value * 0.15),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            clipBehavior: Clip.hardEdge,
            child: child,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail
            AspectRatio(
              aspectRatio: 16 / 7,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  module.thumbnailUrl != null
                      ? AuthNetworkImage(
                    imageUrl: module.thumbnailUrl!,
                    fit: BoxFit.cover,
                    placeholderBuilder: (_) =>
                        _ModuleThumbnailPlaceholder(title: module.title),
                    errorBuilderWidget: (_, __) =>
                        _ModuleThumbnailPlaceholder(title: module.title),
                  )
                      : _ModuleThumbnailPlaceholder(title: module.title),
                  // Gradient
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.75),
                        ],
                        stops: const [0.3, 1.0],
                      ),
                    ),
                  ),
                  // Progress overlay
                  if (module.showProgress)
                    Positioned(
                      left: 12,
                      right: 12,
                      bottom: 10,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(2),
                            child: LinearProgressIndicator(
                              value: module.progressPercentage / 100,
                              backgroundColor: Colors.white.withOpacity(0.15),
                              valueColor:
                              const AlwaysStoppedAnimation<Color>(_kRed),
                              minHeight: 2.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${module.completedLessons}/${module.lessonCount} lessons',
                            style: const TextStyle(
                              color: Colors.white60,
                              fontSize: 9,
                              fontFamily: 'Montserrat',
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            // Info
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    module.title,
                    style: const TextStyle(
                      color: _kTextPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Montserrat',
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    module.statusLabel,
                    style: const TextStyle(
                      color: _kTextSecondary,
                      fontSize: 11,
                      fontFamily: 'Montserrat',
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.play_circle_outline_rounded,
                          color: _kTextMuted, size: 12),
                      const SizedBox(width: 4),
                      Text(
                        '${module.lessonCount} lessons',
                        style: const TextStyle(
                          color: _kTextMuted,
                          fontSize: 10,
                          fontFamily: 'Montserrat',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModuleThumbnailPlaceholder extends StatelessWidget {
  final String title;
  const _ModuleThumbnailPlaceholder({required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _kSurfaceHigh,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.play_circle_outline_rounded,
                color: _kTextMuted.withOpacity(0.6), size: 24),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                title,
                style: const TextStyle(
                    color: _kTextMuted, fontSize: 10, fontFamily: 'Montserrat'),
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

// ─── Access Time Section ──────────────────────────────────────────────────────

class _AccessTimeSection extends StatelessWidget {
  final AccessTimeSummary summary;
  const _AccessTimeSection({required this.summary});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: _kSurfaceElevated,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: _kDivider, width: 0.8),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _kRed.withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.timer_rounded, color: _kRed, size: 18),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'TOTAL WAKTU BELAJAR',
                  style: TextStyle(
                    color: _kTextMuted,
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Montserrat',
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  summary.formattedTotal,
                  style: const TextStyle(
                    color: _kTextPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Montserrat',
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
            color: _kTextSecondary,
            fontSize: 10,
            fontWeight: FontWeight.w700,
            fontFamily: 'Montserrat',
            letterSpacing: 2,
          ),
        ),
      ],
    );
  }
}

class _RedButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  const _RedButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: _kWhite, size: 15),
            const SizedBox(width: 5),
            Text(
              label,
              style: const TextStyle(
                color: _kWhite,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                fontFamily: 'Montserrat',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Skeleton ─────────────────────────────────────────────────────────────────

class _DashboardSkeleton extends StatefulWidget {
  const _DashboardSkeleton();

  @override
  State<_DashboardSkeleton> createState() => _DashboardSkeletonState();
}

class _DashboardSkeletonState extends State<_DashboardSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerCtrl;
  late Animation<double> _shimmerAnim;

  @override
  void initState() {
    super.initState();
    _shimmerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _shimmerAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _shimmerCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _shimmerCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shimmerAnim,
      builder: (context, _) {
        final shimmerColor =
        Color.lerp(_kSurface, _kSurfaceHigh, _shimmerAnim.value)!;
        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 90, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Bone(width: 80, height: 10, color: shimmerColor),
              const SizedBox(height: 10),
              _Bone(width: 200, height: 36, color: shimmerColor),
              const SizedBox(height: 6),
              _Bone(width: 48, height: 3, color: _kRed.withOpacity(0.3)),
              const SizedBox(height: 32),
              _Bone(width: double.infinity, height: 220, color: shimmerColor),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(child: _Bone(width: double.infinity, height: 90, color: shimmerColor)),
                  const SizedBox(width: 10),
                  Expanded(child: _Bone(width: double.infinity, height: 90, color: shimmerColor)),
                  const SizedBox(width: 10),
                  Expanded(child: _Bone(width: double.infinity, height: 90, color: shimmerColor)),
                ],
              ),
              const SizedBox(height: 32),
              _Bone(width: 100, height: 10, color: shimmerColor),
              const SizedBox(height: 14),
              SizedBox(
                height: 270,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: 3,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (_, __) => _Bone(
                    width: 200,
                    height: 270,
                    color: shimmerColor,
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

class _DashboardError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _DashboardError({required this.message, required this.onRetry});

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
              child: const Icon(Icons.wifi_off_rounded,
                  color: _kRed, size: 28),
            ),
            const SizedBox(height: 20),
            Text(
              message,
              style: const TextStyle(
                color: _kTextSecondary,
                fontSize: 13,
                fontFamily: 'Montserrat',
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            _RedButton(
              label: 'Try again',
              icon: Icons.refresh_rounded,
              onTap: onRetry,
            ),
          ],
        ),
      ),
    );
  }
}
