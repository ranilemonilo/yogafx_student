import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/running_login_time_card.dart';
import '../../../../features/auth/presentation/providers/auth_provider.dart';
import '../../data/models/profile_model.dart';
import '../providers/profile_provider.dart';

// ─── Design System Colors ────────────────────────────────────────────────────
class _DSColors {
  static const Color bg = Color(0xFF060908); // Neutral / Black (Main Bg)
  static const Color header = Color(0xFF141110); // Neutral / Black (Header)
  static const Color card = Color(0xFF120F0E); // Neutral / Black (Card/Panel)
  static const Color primary = Color(0xFFDB202C); // Primary / Red
  static const Color primaryHover = Color(0xFFF6121D); // Red Hover
  static const Color success = Color(0xFF00B14F); // Secondary / Emerald
  static const Color textMain = Color(0xFFFFFFFF); // White
  static const Color textSec = Color(0xA6FFFFFF); // Transparent White 65%
  static const Color textMuted = Color(0x73FFFFFF); // Transparent White 45%
  static const Color overlay10 = Color(0x1AFFFFFF); // Transparent White 10%
  static const Color overlay20 = Color(0x33FFFFFF); // Button Secondary
  static const Color border = Color(0x4DFFFFFF); // Transparent White 30%
}

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileProvider);

    return Scaffold(
      backgroundColor: _DSColors.bg,
      body: profileAsync.when(
        loading: () => const _ProfileSkeleton(),
        error: (e, _) => _ProfileError(
          message: e.toString(),
          onRetry: () => ref.invalidate(profileProvider),
        ),
        data: (profile) => _ProfileContent(profile: profile),
      ),
    );
  }
}

void _handleProfileBack(BuildContext context) {
  if (Navigator.of(context).canPop()) {
    context.pop();
    return;
  }
  context.go(AppRoutes.dashboard);
}

Future<void> _showProfileActions(BuildContext context, WidgetRef ref) async {
  await showModalBottomSheet<void>(
    context: context,
    backgroundColor: const Color(0xFF1A1A1A), // Modal background
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
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
                    color: _DSColors.border,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Profile Actions',
                style: TextStyle(
                  color: _DSColors.textMain,
                  fontSize: 22, // Headline 1
                  fontWeight: FontWeight.w500, // Medium
                  fontFamily: 'Montserrat',
                ),
              ),
              const SizedBox(height: 16),
              _ProfileActionTile(
                icon: Icons.person_outline_rounded,
                title: 'View Profile',
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  if (GoRouterState.of(context).matchedLocation !=
                      AppRoutes.profile) {
                    context.push(AppRoutes.profile);
                  }
                },
              ),
              const SizedBox(height: 8),
              _ProfileActionTile(
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

Future<bool?> _confirmLogout(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), // Modal radius
        title: const Text(
          'Log Out',
          style: TextStyle(
            color: _DSColors.textMain,
            fontSize: 24, // Title 2
            fontWeight: FontWeight.w600, // Semi Bold
            fontFamily: 'Montserrat',
          ),
        ),
        content: const Text(
          'Are you sure you want to log out of your account?',
          style: TextStyle(
            color: _DSColors.textSec,
            fontSize: 14,
            fontFamily: 'Montserrat',
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            style: TextButton.styleFrom(foregroundColor: _DSColors.textMain),
            child: const Text(
              'Cancel',
              style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w600),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: _DSColors.primary,
              foregroundColor: _DSColors.textMain,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            ),
            child: const Text(
              'Log Out',
              style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w700),
            ),
          ),
        ],
      );
    },
  );
}

Future<void> _sendPasswordResetEmail(
    BuildContext context,
    WidgetRef ref,
    ProfileData profile,
    ) async {
  showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) {
      return const Center(
        child: CircularProgressIndicator(color: _DSColors.primary),
      );
    },
  );

  try {
    await ref.read(authRepositoryProvider).forgotPassword(
      email: profile.email,
    );
    if (context.mounted) {
      Navigator.of(context, rootNavigator: true).pop();
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            backgroundColor: _DSColors.success,
            content: Text(
              'A password reset email has been sent to ${profile.email}.',
              style: const TextStyle(fontFamily: 'Montserrat', color: _DSColors.textMain),
            ),
          ),
        );
    }
  } catch (e) {
    if (context.mounted) {
      Navigator.of(context, rootNavigator: true).pop();
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              e.toString(),
              style: const TextStyle(fontFamily: 'Montserrat', color: _DSColors.textMain),
            ),
            backgroundColor: _DSColors.primary,
          ),
        );
    }
  }
}

// ─── Content ────────────────────────────────────────────────────────────────

class _ProfileContent extends ConsumerStatefulWidget {
  final ProfileData profile;

  const _ProfileContent({required this.profile});

  @override
  ConsumerState<_ProfileContent> createState() => _ProfileContentState();
}

class _ProfileContentState extends ConsumerState<_ProfileContent>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  static const int _slots = 8;
  late final List<Animation<double>> _fades;
  late final List<Animation<Offset>> _slides;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 820),
    );
    _fades = List.generate(_slots, (i) {
      final start = (i * 0.10).clamp(0.0, 1.0);
      final end = (start + 0.45).clamp(0.0, 1.0);
      return Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
          parent: _ctrl,
          curve: Interval(start, end, curve: Curves.easeOut),
        ),
      );
    });
    _slides = List.generate(_slots, (i) {
      final start = (i * 0.10).clamp(0.0, 1.0);
      final end = (start + 0.45).clamp(0.0, 1.0);
      return Tween<Offset>(
        begin: const Offset(0, 0.06),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: _ctrl,
          curve: Interval(start, end, curve: Curves.easeOutCubic),
        ),
      );
    });
    Future.delayed(const Duration(milliseconds: 80), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Widget _a(int slot, Widget child) => FadeTransition(
    opacity: _fades[slot],
    child: SlideTransition(position: _slides[slot], child: child),
  );

  @override
  Widget build(BuildContext context) {
    final profile = widget.profile;
    return RefreshIndicator(
      color: _DSColors.primary,
      backgroundColor: _DSColors.card,
      onRefresh: () async {
        ref.invalidate(profileProvider);
        await ref.read(profileProvider.future);
      },
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          // ── AppBar ──────────────────────────────────────────────────────
          SliverAppBar(
            backgroundColor: _DSColors.header,
            floating: true,
            snap: true,
            elevation: 4,
            shadowColor: Colors.black.withOpacity(0.7), // shadow depth per DS
            titleSpacing: 4,
            leading: IconButton(
              onPressed: () => _handleProfileBack(context),
              icon: const Icon(
                Icons.arrow_back,
                size: 24,
                color: _DSColors.textMain,
              ),
            ),
            title: const Text(
              'My Profile',
              style: TextStyle(
                color: _DSColors.textMain,
                fontSize: 22, // Headline 1
                fontWeight: FontWeight.w500, // Medium
                fontFamily: 'Montserrat',
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 40), // 4% horizontal
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _a(0, Align(
                    alignment: Alignment.centerRight,
                    child: const RunningLoginTimeCard(),
                  )),
                  const SizedBox(height: 16),
                  _a(1, _ProfileHeroCard(profile: profile)),
                  const SizedBox(height: 16),
                  _a(2, Row(
                    children: [
                      Expanded(
                        child: _NetflixButton(
                          label: 'Edit Profile',
                          icon: Icons.edit_outlined,
                          onTap: () => context.push('/profile/edit'),
                          isPrimary: true,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _NetflixButton(
                          label: 'Reset Password',
                          icon: Icons.lock_reset_outlined,
                          onTap: () =>
                              _sendPasswordResetEmail(context, ref, profile),
                          isPrimary: false,
                        ),
                      ),
                    ],
                  )),
                  const SizedBox(height: 24),
                  _a(4, _SectionCard(
                    title: 'Account',
                    children: [
                      _InfoRow(label: 'Full name', value: profile.name),
                      _InfoRow(label: 'Email', value: profile.email),
                      _InfoRow(label: 'WhatsApp', value: profile.whatsapp),
                      _InfoRow(label: 'Instagram', value: profile.instagram),
                    ],
                  )),
                  const SizedBox(height: 16),
                  _a(5, _SectionCard(
                    title: 'Personal',
                    children: [
                      _InfoRow(label: 'Country', value: profile.country),
                      _InfoRow(label: 'Birth date', value: profile.birthDate),
                      _InfoRow(label: 'Gender', value: profile.gender),
                    ],
                  )),
                  const SizedBox(height: 16),
                  _a(6, _SectionCard(
                    title: 'Practice',
                    children: [
                      _InfoRow(
                        label: 'Practicing yoga for',
                        value: profile.practicingYogaFor,
                      ),
                      _InfoRow(
                        label: 'Sequence experience',
                        value: profile.yogaSequenceExperience,
                      ),
                      _InfoRow(
                        label: 'Hours per week',
                        value: profile.hoursPerWeek,
                      ),
                      _InfoRow(
                        label: 'Fitness level',
                        value: profile.currentFitnessLevel,
                      ),
                      _InfoRow(
                        label: 'Flexibility',
                        value: profile.flexibilityRating,
                      ),
                    ],
                  )),
                  const SizedBox(height: 16),
                  _a(7, _SectionCard(
                    title: 'Motivation',
                    children: [
                      _InfoRow(label: 'Motivation', value: profile.motivation),
                      _InfoRow(label: 'Why YogaFX', value: profile.whyYogafx),
                      _InfoRow(
                        label: 'How you found us',
                        value: profile.howDidYouFindUs,
                      ),
                    ],
                  )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Hero Card ───────────────────────────────────────────────────────────────

class _ProfileHeroCard extends StatelessWidget {
  final ProfileData profile;

  const _ProfileHeroCard({required this.profile});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _DSColors.card,
        borderRadius: BorderRadius.circular(8), // Modal/panel radius
        border: Border.all(color: _DSColors.border, width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Avatar with Netflix style shape & border
          Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: _DSColors.primary, width: 2), // Active red border
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                    width: 64,
                    height: 64,
                    color: _DSColors.overlay10,
                    child: profile.profilePhoto != null
                        ? Image.network(
                      profile.profilePhoto!,
                      fit: BoxFit.cover,
                    )
                        : Center(
                      child: Text(
                        _initials(profile.name),
                        style: const TextStyle(
                          color: _DSColors.textMain,
                          fontSize: 24, // Title 2
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Montserrat',
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _DSColors.textMain,
                    fontSize: 24, // Title 2
                    fontWeight: FontWeight.w600, // Semi Bold
                    fontFamily: 'Montserrat',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  profile.accessTier.name.toUpperCase(),
                  style: const TextStyle(
                    color: _DSColors.primary,
                    fontSize: 12, // Caption
                    fontWeight: FontWeight.w700, // Bold
                    fontFamily: 'Montserrat',
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 12),
                _StatusBadge(completed: profile.profileCompleted),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return '${parts.first.substring(0, 1)}${parts.last.substring(0, 1)}'
        .toUpperCase();
  }
}

class _StatusBadge extends StatelessWidget {
  final bool completed;

  const _StatusBadge({required this.completed});

  @override
  Widget build(BuildContext context) {
    final color = completed ? _DSColors.success : _DSColors.primary;
    final label = completed ? 'PROFILE COMPLETE' : 'PROFILE INCOMPLETE';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(2), // Badge small radius
        border: Border.all(color: color.withOpacity(0.6), width: 1), // 0.6 border opacity
      ),
      child: Text(
        label,
        style: TextStyle(
          color: _DSColors.textMain,
          fontSize: 12,
          fontWeight: FontWeight.w600, // Semi Bold
          fontFamily: 'Montserrat',
        ),
      ),
    );
  }
}

// ─── Netflix-style Button ────────────────────────────────────────────────────

class _NetflixButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool isPrimary; // True = Red, False = Gray transparent

  const _NetflixButton({
    required this.label,
    required this.icon,
    required this.onTap,
    required this.isPrimary,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4), // Button radius 4px
        child: Ink(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: isPrimary ? _DSColors.primary : _DSColors.overlay20,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: _DSColors.textMain,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _DSColors.textMain,
                    fontSize: 14,
                    fontWeight: FontWeight.w700, // Bold
                    fontFamily: 'Montserrat',
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

// ─── Action Tile ─────────────────────────────────────────────────────────────

class _ProfileActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isDanger;
  final VoidCallback onTap;

  const _ProfileActionTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.isDanger = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: _DSColors.overlay10,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: _DSColors.border, width: 1),
          ),
          child: Row(
            children: [
              Icon(icon, color: isDanger ? _DSColors.primary : _DSColors.textMain, size: 20),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  color: isDanger ? _DSColors.primary : _DSColors.textMain,
                  fontSize: 16,
                  fontWeight: FontWeight.w400, // Regular
                  fontFamily: 'Montserrat',
                ),
              ),
              const Spacer(),
              Icon(Icons.chevron_right_rounded, color: _DSColors.textMuted, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Section Card ─────────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SectionCard({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: _DSColors.card,
        borderRadius: BorderRadius.circular(8), // Modal/Panel radius
        border: Border.all(color: _DSColors.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header (simpler layout aligned with Netflix style info dropdowns)
          Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: _DSColors.border, width: 1),
              ),
            ),
            child: Text(
              title,
              style: const TextStyle(
                color: _DSColors.textMain,
                fontSize: 22, // Headline 1
                fontWeight: FontWeight.w500, // Medium
                fontFamily: 'Montserrat',
              ),
            ),
          ),
          // Info rows
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: Column(
              children: children,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Info Row ─────────────────────────────────────────────────────────────────

class _InfoRow extends StatelessWidget {
  final String label;
  final String? value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final isEmpty = value == null || value!.trim().isEmpty;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Text(
              label,
              style: const TextStyle(
                color: _DSColors.textSec, // 65% transparency
                fontSize: 14,
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w400, // Regular
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 6,
            child: Text(
              isEmpty ? '—' : value!,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: isEmpty ? _DSColors.textMuted : _DSColors.textMain,
                fontSize: 14,
                fontFamily: 'Montserrat',
                fontWeight: isEmpty ? FontWeight.w400 : FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Skeleton ─────────────────────────────────────────────────────────────────

class _ProfileSkeleton extends StatelessWidget {
  const _ProfileSkeleton();

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        const SliverAppBar(
          backgroundColor: _DSColors.header,
          floating: true,
          snap: true,
          title: Text(
            'My Profile',
            style: TextStyle(
              color: _DSColors.textMain,
              fontSize: 22,
              fontWeight: FontWeight.w500,
              fontFamily: 'Montserrat',
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _shimmer(height: 100, radius: 8),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: _shimmer(height: 42, radius: 4)),
                    const SizedBox(width: 8),
                    Expanded(child: _shimmer(height: 42, radius: 4)),
                  ],
                ),
                const SizedBox(height: 24),
                ...List.generate(
                  4,
                      (_) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _shimmer(height: 140, radius: 8),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _shimmer({required double height, required double radius}) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: _DSColors.overlay10,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

// ─── Error ────────────────────────────────────────────────────────────────────

class _ProfileError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ProfileError({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.wifi_off_outlined,
              color: _DSColors.textMuted,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: _DSColors.textSec,
                fontSize: 14,
                fontFamily: 'Montserrat',
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: 140,
              child: ElevatedButton(
                onPressed: onRetry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _DSColors.primary,
                  foregroundColor: _DSColors.textMain,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                ),
                child: const Text(
                  'Try again',
                  style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}