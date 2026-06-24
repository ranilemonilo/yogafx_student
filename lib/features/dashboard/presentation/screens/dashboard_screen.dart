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
import '../providers/running_login_time_provider.dart';
import '../utils/access_time_helper.dart';
import '../../data/models/dashboard_model.dart';
import 'package:cached_network_image/cached_network_image.dart';

// ─── Design tokens (DESIGN_SYSTEM.md) ────────────────────────────────────────
// bg utama   : #060908   (Neutral/Black paling gelap)
// bg card    : #120F0E   (card & panel)
// bg header  : #141110   (header, bottom sheet)
// overlay    : #161210   (card hover layer)
// elevated   : #1A1410   (elevated surface, warm dark)
// high       : #281D16   (card hover warm)
// primary    : #DB202C
// success    : #00B14F
// warm-orange: #DF6739   (aksen sekunder)
// white      : #FFFFFF
// text sec   : rgba(255,255,255,0.65) → #A6A6A6
// text muted : rgba(255,255,255,0.45) → #737373
// border     : rgba(255,255,255,0.10) → #1A1A1A

class _DS {
  static const bgPage    = Color(0xFF060908);
  static const bgCard    = Color(0xFF120F0E);
  static const bgHeader  = Color(0xFF141110);
  static const bgOverlay = Color(0xFF161210);
  static const bgElevated= Color(0xFF1A1410);
  static const bgHigh    = Color(0xFF281D16);
  static const primary   = Color(0xFFDB202C);
  static const success   = Color(0xFF00B14F);
  static const orange    = Color(0xFFDF6739);
  static const white     = Color(0xFFFFFFFF);
  static const textSec   = Color(0xFFA6A6A6);
  static const textMuted = Color(0xFF737373);
  static const border    = Color(0xFF1A1A1A);
  static const fontFamily = 'Montserrat';
}

// ─── Helpers ──────────────────────────────────────────────────────────────────

const _kLockedModuleMessage =
    'This page is not available yet. Please complete the previous module first.';

void _showLockedModuleSnackBar(BuildContext context) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: const Text(_kLockedModuleMessage,
            style: TextStyle(fontFamily: _DS.fontFamily, fontSize: 13)),
        backgroundColor: _DS.bgHeader,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
}

bool _canOpenModule(String status) {
  final s = status.toLowerCase();
  return s != 'locked' && s != 'unavailable' && s != 'hidden';
}

// ─── Root Screen ──────────────────────────────────────────────────────────────

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final authStatus = authState.status;

    if (authStatus == AuthStatus.initial || authStatus == AuthStatus.loading) {
      return const Scaffold(
        backgroundColor: _DS.bgPage,
        body: _DashboardSkeleton(),
      );
    }

    if (authStatus != AuthStatus.authenticated) {
      return const Scaffold(
        backgroundColor: _DS.bgPage,
        body: SizedBox.shrink(),
      );
    }

    final dashboardAsync = ref.watch(dashboardProvider);

    return Scaffold(
      backgroundColor: _DS.bgPage,
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

// ─── Profile & Dialog Menus ───────────────────────────────────────────────────

Future<void> _showProfileMenu(BuildContext context, WidgetRef ref) async {
  await showModalBottomSheet<void>(
    context: context,
    backgroundColor: _DS.bgHeader,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
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
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: _DS.border,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Profile Menu',
                style: TextStyle(
                  color: _DS.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  fontFamily: _DS.fontFamily,
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
    backgroundColor: _DS.bgHeader,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
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
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: _DS.border,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Instant Access Dialog',
                style: TextStyle(
                  color: _DS.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  fontFamily: _DS.fontFamily,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Choose the dialog you want to open.',
                style: TextStyle(
                  color: _DS.textSec,
                  fontSize: 12,
                  fontFamily: _DS.fontFamily,
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
        backgroundColor: _DS.bgCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        title: const Text(
          'Log Out',
          style: TextStyle(
            color: _DS.white,
            fontWeight: FontWeight.w700,
            fontFamily: _DS.fontFamily,
          ),
        ),
        content: const Text(
          'Are you sure you want to log out of your account?',
          style: TextStyle(
            color: _DS.textSec,
            fontFamily: _DS.fontFamily,
            height: 1.5,
            fontSize: 14,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text('Cancel',
                style: TextStyle(
                    color: _DS.textSec, fontFamily: _DS.fontFamily)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: _DS.primary,
              foregroundColor: _DS.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4)),
            ),
            child: const Text('Log Out',
                style: TextStyle(fontFamily: _DS.fontFamily)),
          ),
        ],
      );
    },
  );
}

// ─── Content ──────────────────────────────────────────────────────────────────

class _DashboardContent extends ConsumerStatefulWidget {
  final DashboardData data;
  const _DashboardContent({required this.data});

  @override
  ConsumerState<_DashboardContent> createState() => _DashboardContentState();
}

class _DashboardContentState extends ConsumerState<_DashboardContent>
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

    return RefreshIndicator(
      color: _DS.primary,
      backgroundColor: _DS.bgCard,
      onRefresh: () async {
        ref.invalidate(dashboardProvider);
        await ref.read(dashboardProvider.future);
      },
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
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
                    _ContinueLearningSection(
                        section: data.continueLearningSection),
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
                _animated(
                    3, _ModulesSection(section: data.availableModulesSection)),
                const SizedBox(height: 56),
              ],
            ),
          ),
        ],
      ),
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
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              _DS.bgPage.withOpacity(0.95),
              Colors.transparent,
            ],
          ),
        ),
      ),
      title: CachedNetworkImage(
        imageUrl: 'https://yogafx.b-cdn.net/content/Logo%20YogAFX.png',
        height: 26,
        fit: BoxFit.contain,
        placeholder: (_, __) => const SizedBox(height: 26, width: 90),
        errorWidget: (_, __, ___) => const Text(
          'YogaFX',
          style: TextStyle(
            color: _DS.white,
            fontSize: 16,
            fontWeight: FontWeight.w700,
            fontFamily: _DS.fontFamily,
          ),
        ),
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
              imageUrl: profileAsync.value?.profilePhoto ??
                  authState.user?.avatar,
              displayName: profileAsync.value?.name ??
                  authState.user?.name ??
                  'Student',
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
        color: _DS.primary,
        borderRadius: BorderRadius.circular(8),
        // DS: avatar active border merah; here using subtle white border
        border: Border.all(color: _DS.white.withOpacity(0.10)),
      ),
      clipBehavior: Clip.antiAlias,
      child: hasImage
          ? AuthNetworkImage(
        imageUrl: imageUrl!,
        fit: BoxFit.cover,
        placeholderBuilder: (_) =>
            _DashboardProfileFallback(displayName: displayName),
        errorBuilderWidget: (_, __) =>
            _DashboardProfileFallback(displayName: displayName),
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
          color: _DS.white,
          fontSize: 12,
          fontWeight: FontWeight.w700,
          fontFamily: _DS.fontFamily,
        ),
      ),
    );
  }
}

String _initials(String value) {
  final parts = value
      .trim()
      .split(RegExp(r'\s+'))
      .where((p) => p.isNotEmpty)
      .toList();
  if (parts.isEmpty) return 'Y';
  if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
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
        borderRadius: BorderRadius.circular(4),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            // DS: rgba(255,255,255,0.10) background
            color: _DS.bgOverlay,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: _DS.border, width: 0.8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  'Instant Access Dialog',
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _DS.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    fontFamily: _DS.fontFamily,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: _DS.textSec,
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
        borderRadius: BorderRadius.circular(8),
        child: Ink(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _DS.bgOverlay,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: _DS.border, width: 0.8),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: _DS.primary.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: _DS.primary, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: _DS.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        fontFamily: _DS.fontFamily,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: _DS.textSec,
                        fontSize: 12,
                        fontFamily: _DS.fontFamily,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right_rounded,
                  color: _DS.textSec, size: 20),
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
    final color = isDanger ? _DS.primary : _DS.white;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: _DS.bgOverlay,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: _DS.border, width: 0.8),
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
                  fontFamily: _DS.fontFamily,
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
        // DS: warm dark gradient sesuai palette brown/black
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 36),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF161210), _DS.bgPage],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tier badge — DS: primary badge styling
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _DS.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(2),
                  border: Border.all(
                      color: _DS.primary.withOpacity(0.35), width: 0.8),
                ),
                child: Text(
                  tier.name.toUpperCase(),
                  style: const TextStyle(
                    color: _DS.primary,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    fontFamily: _DS.fontFamily,
                    letterSpacing: 2,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'SELAMAT DATANG KEMBALI',
                style: TextStyle(
                  color: _DS.textMuted,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  fontFamily: _DS.fontFamily,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 6),
              _ShimmerText(
                text: student.firstName,
                style: const TextStyle(
                  color: _DS.white,
                  fontSize: 36, // DS: Bold / Display
                  fontWeight: FontWeight.w800,
                  fontFamily: _DS.fontFamily,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 20),
              // DS: red accent line with glow
              AnimatedBuilder(
                animation: _glowAnim,
                builder: (_, __) => Container(
                  width: 48,
                  height: 3,
                  decoration: BoxDecoration(
                    color: _DS.primary,
                    borderRadius: BorderRadius.circular(2),
                    boxShadow: [
                      BoxShadow(
                        color: _DS.primary
                            .withOpacity(0.3 + _glowAnim.value * 0.4),
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
          top: 110,
          right: 20,
          child: const RunningLoginTimeCard(),
        ),
        Positioned.fill(
          child: IgnorePointer(
            child: CustomPaint(painter: _ScanlinePainter()),
          ),
        ),
      ],
    );
  }
}

// ─── Scanline Painter ─────────────────────────────────────────────────────────

class _ScanlinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.012)
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
        vsync: this, duration: const Duration(milliseconds: 2800))
      ..repeat();
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
      builder: (_, __) => ShaderMask(
        shaderCallback: (bounds) => LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: const [
            _DS.white,
            _DS.white,
            Color(0xFFE8E8E8),
            _DS.white,
          ],
          stops: [
            (_anim.value - 0.3).clamp(0.0, 1.0),
            (_anim.value - 0.1).clamp(0.0, 1.0),
            (_anim.value + 0.1).clamp(0.0, 1.0),
            (_anim.value + 0.3).clamp(0.0, 1.0),
          ],
        ).createShader(bounds),
        child: Text(widget.text, style: widget.style),
      ),
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
        vsync: this, duration: const Duration(milliseconds: 200));
    _scaleAnim = Tween<double>(begin: 1.0, end: 1.015).animate(
      CurvedAnimation(parent: _scaleCtrl, curve: Curves.easeOut),
    );
    _progressCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200));
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
            // DS: card bg #120F0E
            color: _DS.bgCard,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.6),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          clipBehavior: Clip.hardEdge,
          child: Stack(
            children: [
              if (section.thumbnailUrl != null)
                Positioned.fill(
                  child: AuthNetworkImage(
                    imageUrl: section.thumbnailUrl!,
                    fit: BoxFit.cover,
                    placeholderBuilder: (_) =>
                        Container(color: _DS.bgCard),
                    errorBuilderWidget: (_, __) =>
                        Container(color: _DS.bgCard),
                  ),
                ),
              Positioned.fill(
                child: Container(color: Colors.black.withOpacity(0.5)),
              ),
              // DS: gradient overlay — transparent black
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
              // Left red stripe
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                child: Container(width: 3, color: _DS.primary),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      section.module.title.toUpperCase(),
                      style: const TextStyle(
                        color: _DS.primary,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        fontFamily: _DS.fontFamily,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      section.lesson.title,
                      style: const TextStyle(
                        color: _DS.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        fontFamily: _DS.fontFamily,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 14),
                    AnimatedBuilder(
                      animation: _progressAnim,
                      builder: (_, __) => ClipRRect(
                        borderRadius: BorderRadius.circular(2),
                        child: LinearProgressIndicator(
                          value: _progressAnim.value,
                          backgroundColor:
                          Colors.white.withOpacity(0.10),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                              _DS.primary),
                          minHeight: 2.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Text(
                          section.status,
                          style: const TextStyle(
                            color: _DS.textSec,
                            fontSize: 11,
                            fontFamily: _DS.fontFamily,
                          ),
                        ),
                        const Spacer(),
                        _RedButton(
                          label: section.ctaLabel,
                          icon: Icons.play_arrow_rounded,
                          onTap: () => context
                              .push('/lessons/${section.lesson.id}'),
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
        vsync: this, duration: const Duration(milliseconds: 1000));
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
                value:
                '${widget.section.modulesCompleted}/${widget.section.modulesTotal}',
                icon: Icons.layers_rounded,
                animation: _anim,
                onTap: () => context.push(AppRoutes.modules),
              ),
              const SizedBox(width: 10),
              _AnimatedStatCard(
                label: 'Lessons',
                value:
                '${widget.section.lessonsCompleted}/${widget.section.lessonsTotal}',
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
                  // DS: highlight card = warm dark #161210, normal = bgCard
                  color: highlight ? _DS.bgElevated : _DS.bgCard,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: highlight
                        ? _DS.primary.withOpacity(0.35)
                        : _DS.border,
                    width: 0.8,
                  ),
                  boxShadow: highlight
                      ? [
                    BoxShadow(
                      color: _DS.primary.withOpacity(0.10),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ]
                      : [],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(icon,
                        color: highlight ? _DS.primary : _DS.textMuted,
                        size: 18),
                    const SizedBox(height: 10),
                    Text(
                      value,
                      style: TextStyle(
                        color: highlight ? _DS.primary : _DS.white,
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                        fontFamily: _DS.fontFamily,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      label,
                      style: const TextStyle(
                        color: _DS.textMuted,
                        fontSize: 10,
                        fontFamily: _DS.fontFamily,
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
        vsync: this, duration: const Duration(milliseconds: 1600))
      ..repeat(reverse: true);
    _pulseAnim =
        CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut);
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
                colors: [_DS.bgElevated, _DS.bgPage],
              ),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: _DS.primary
                    .withOpacity(0.20 + _pulseAnim.value * 0.18),
                width: 0.8,
              ),
              boxShadow: [
                BoxShadow(
                  color: _DS.primary
                      .withOpacity(0.05 + _pulseAnim.value * 0.05),
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
                    color: _DS.primary.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: _DS.primary.withOpacity(0.20), width: 0.8),
                  ),
                  child: const Icon(Icons.quiz_rounded,
                      color: _DS.primary, size: 20),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Assessments',
                        style: TextStyle(
                          color: _DS.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          fontFamily: _DS.fontFamily,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Continue the assessment from ${widget.continueLearningSection.lesson.title}',
                        style: const TextStyle(
                          color: _DS.textMuted,
                          fontSize: 11,
                          fontFamily: _DS.fontFamily,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(Icons.chevron_right_rounded,
                    color: _DS.primary.withOpacity(0.7), size: 20),
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
        vsync: this, duration: const Duration(milliseconds: 280));
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
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (!_searchOpen)
                Expanded(child: _SectionLabel(text: widget.section.eyebrow))
              else
                const Spacer(),
              Flexible(
                child: Wrap(
                  alignment: WrapAlignment.end,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8,
                  runSpacing: 8,
                  children: [
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
                            onChanged: (v) =>
                                setState(() => _query = v),
                            style: const TextStyle(
                              color: _DS.white,
                              fontSize: 13,
                              fontFamily: _DS.fontFamily,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Search modules...',
                              hintStyle: const TextStyle(
                                color: _DS.textMuted,
                                fontSize: 13,
                                fontFamily: _DS.fontFamily,
                              ),
                              filled: true,
                              fillColor: _DS.bgOverlay,
                              isDense: true,
                              contentPadding:
                              const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              border: OutlineInputBorder(
                                borderRadius:
                                BorderRadius.circular(4),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius:
                                BorderRadius.circular(4),
                                borderSide: const BorderSide(
                                    color: _DS.primary, width: 1),
                              ),
                            ),
                          )
                              : const SizedBox.shrink(),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: _toggleSearch,
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: Icon(
                          _searchOpen
                              ? Icons.close_rounded
                              : Icons.search_rounded,
                          key: ValueKey(_searchOpen),
                          color: _searchOpen ? _DS.primary : _DS.textSec,
                          size: 20,
                        ),
                      ),
                    ),
                    if (!_searchOpen) ...[
                      GestureDetector(
                        onTap: () => context.go(AppRoutes.modules),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'Lihat semua',
                              style: TextStyle(
                                color: _DS.primary,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                fontFamily: _DS.fontFamily,
                              ),
                            ),
                            const SizedBox(width: 2),
                            const Icon(Icons.chevron_right_rounded,
                                color: _DS.primary, size: 16),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        if (filtered.isEmpty)
          Padding(
            padding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Row(
              children: [
                const Icon(Icons.search_off_rounded,
                    color: _DS.textMuted, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Tidak ada modul untuk "$_query"',
                    style: const TextStyle(
                      color: _DS.textMuted,
                      fontSize: 13,
                      fontFamily: _DS.fontFamily,
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
        vsync: this, duration: const Duration(milliseconds: 180));
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
    final canOpen = _canOpenModule(module.status);

    return GestureDetector(
      onTap: () {
        if (!canOpen) {
          _showLockedModuleSnackBar(context);
          return;
        }
        context.push('/modules/${module.id}');
      },
      onTapDown: canOpen ? (_) => _hoverCtrl.forward() : null,
      onTapUp: canOpen ? (_) => _hoverCtrl.reverse() : null,
      onTapCancel: canOpen ? () => _hoverCtrl.reverse() : null,
      child: AnimatedBuilder(
        animation: _hoverCtrl,
        builder: (_, child) => Transform.scale(
          scale: _scaleAnim.value,
          child: Container(
            width: 200,
            decoration: BoxDecoration(
              color: _DS.bgCard,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
                BoxShadow(
                  color: _DS.primary.withOpacity(_glowAnim.value * 0.12),
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
                        _ModuleThumbnailPlaceholder(
                            title: module.title),
                    errorBuilderWidget: (_, __) =>
                        _ModuleThumbnailPlaceholder(
                            title: module.title),
                  )
                      : _ModuleThumbnailPlaceholder(title: module.title),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.80),
                        ],
                        stops: const [0.3, 1.0],
                      ),
                    ),
                  ),
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
                              backgroundColor:
                              Colors.white.withOpacity(0.12),
                              valueColor:
                              const AlwaysStoppedAnimation<Color>(
                                  _DS.primary),
                              minHeight: 2.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${module.completedLessons}/${module.lessonCount} lessons',
                            style: const TextStyle(
                              color: Colors.white60,
                              fontSize: 9,
                              fontFamily: _DS.fontFamily,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    module.title,
                    style: const TextStyle(
                      color: _DS.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      fontFamily: _DS.fontFamily,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    module.statusLabel,
                    style: const TextStyle(
                      color: _DS.textSec,
                      fontSize: 11,
                      fontFamily: _DS.fontFamily,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.play_circle_outline_rounded,
                          color: _DS.textMuted, size: 12),
                      const SizedBox(width: 4),
                      Text(
                        '${module.lessonCount} lessons',
                        style: const TextStyle(
                          color: _DS.textMuted,
                          fontSize: 10,
                          fontFamily: _DS.fontFamily,
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
      // DS: bgHigh #281D16 untuk placeholder warm
      color: _DS.bgHigh,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.play_circle_outline_rounded,
                color: _DS.textMuted.withOpacity(0.5), size: 24),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                title,
                style: const TextStyle(
                    color: _DS.textMuted,
                    fontSize: 10,
                    fontFamily: _DS.fontFamily),
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

class _AccessTimeSection extends ConsumerWidget {
  final AccessTimeSummary summary;
  const _AccessTimeSection({required this.summary});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final durationAsync = ref.watch(runningLoginTimeProvider);
    final displayedAccessDuration = durationAsync.value ??
        Duration(
          seconds: calculateDisplayedAccessSeconds(summary, DateTime.now()),
        );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: _DS.bgCard,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: _DS.border, width: 0.8),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _DS.primary.withOpacity(0.10),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.timer_rounded,
                  color: _DS.primary, size: 18),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'TOTAL WAKTU BELAJAR',
                  style: TextStyle(
                    color: _DS.textMuted,
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    fontFamily: _DS.fontFamily,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  formatAccessDuration(displayedAccessDuration),
                  style: const TextStyle(
                    color: _DS.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    fontFamily: _DS.fontFamily,
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
            color: _DS.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          text.toUpperCase(),
          style: const TextStyle(
            color: _DS.textSec,
            fontSize: 10,
            fontWeight: FontWeight.w700,
            fontFamily: _DS.fontFamily,
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
          color: _DS.primary,
          borderRadius: BorderRadius.circular(4),
          boxShadow: [
            BoxShadow(
              color: _DS.primary.withOpacity(0.30),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: _DS.white, size: 15),
            const SizedBox(width: 5),
            Text(
              label,
              style: const TextStyle(
                color: _DS.white,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                fontFamily: _DS.fontFamily,
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
  late AnimationController _shimCtrl;
  late Animation<double> _shimAnim;

  @override
  void initState() {
    super.initState();
    _shimCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1400))
      ..repeat(reverse: true);
    _shimAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _shimCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _shimCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shimAnim,
      builder: (context, _) {
        final shimColor = Color.lerp(
          _DS.bgCard,
          _DS.bgHigh, // warm shimmer sesuai DS palette
          _shimAnim.value,
        )!;
        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 90, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Bone(width: 80, height: 10, color: shimColor),
              const SizedBox(height: 10),
              _Bone(width: 200, height: 36, color: shimColor),
              const SizedBox(height: 6),
              _Bone(
                  width: 48,
                  height: 3,
                  color: _DS.primary.withOpacity(0.25)),
              const SizedBox(height: 32),
              _Bone(
                  width: double.infinity, height: 220, color: shimColor),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                      child: _Bone(
                          width: double.infinity,
                          height: 90,
                          color: shimColor)),
                  const SizedBox(width: 10),
                  Expanded(
                      child: _Bone(
                          width: double.infinity,
                          height: 90,
                          color: shimColor)),
                  const SizedBox(width: 10),
                  Expanded(
                      child: _Bone(
                          width: double.infinity,
                          height: 90,
                          color: shimColor)),
                ],
              ),
              const SizedBox(height: 32),
              _Bone(width: 100, height: 10, color: shimColor),
              const SizedBox(height: 14),
              SizedBox(
                height: 270,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: 3,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (_, __) =>
                      _Bone(width: 200, height: 270, color: shimColor),
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
  const _Bone(
      {required this.width, required this.height, required this.color});

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
                color: _DS.primary.withOpacity(0.08),
                // DS: icon error container pakai borderRadius 8, bukan circle
                borderRadius: BorderRadius.circular(8),
                border:
                Border.all(color: _DS.primary.withOpacity(0.20)),
              ),
              child: const Icon(Icons.wifi_off_rounded,
                  color: _DS.primary, size: 28),
            ),
            const SizedBox(height: 20),
            Text(
              message,
              style: const TextStyle(
                color: _DS.textSec,
                fontSize: 13,
                fontFamily: _DS.fontFamily,
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