import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/running_login_time_card.dart';
import '../../../../features/auth/presentation/providers/auth_provider.dart';
import '../../data/models/profile_model.dart';
import '../providers/profile_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
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
    backgroundColor: AppColors.surface,
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
                    color: AppColors.divider,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Profile Actions',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
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
              const SizedBox(height: 10),
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
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Log Out',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
            fontFamily: 'Montserrat',
          ),
        ),
        content: const Text(
          'Are you sure you want to log out of your account?',
          style: TextStyle(
            color: AppColors.textSecondary,
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
            child: const Text('Log Out'),
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
        child: CircularProgressIndicator(color: AppColors.primary),
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
            content: Text(
              'A password reset email has been sent to ${profile.email}.',
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
            content: Text(e.toString()),
            backgroundColor: AppColors.error,
          ),
        );
    }
  }
}

// ─── Content ────────────────────────────────────────────────────────────────

class _ProfileContent extends ConsumerWidget {
  final ProfileData profile;

  const _ProfileContent({required this.profile});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () async {
        ref.invalidate(profileProvider);
        await ref.read(profileProvider.future);
      },
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          // ── AppBar ──────────────────────────────────────────────────────
          SliverAppBar(
            backgroundColor: AppColors.background,
            floating: true,
            snap: true,
            elevation: 0,
            titleSpacing: 4,
            leading: IconButton(
              onPressed: () => _handleProfileBack(context),
              icon: const Icon(
                Icons.arrow_back_ios_new,
                size: 18,
                color: AppColors.textPrimary,
              ),
            ),
            title: const Text(
              'My Profile',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w700,
                fontFamily: 'Montserrat',
                letterSpacing: 0.3,
              ),
            ),
            actions: [
              IconButton(
                onPressed: () => _showProfileActions(context, ref),
                icon: const Icon(
                  Icons.more_vert_rounded,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Running time chip ──────────────────────────────────
                  Align(
                    alignment: Alignment.centerRight,
                    child: const RunningLoginTimeCard(),
                  ),
                  const SizedBox(height: 8),

                  // ── Hero header card ───────────────────────────────────
                  _ProfileHeroCard(profile: profile),
                  const SizedBox(height: 12),

                  // ── Primary CTA row ────────────────────────────────────
                  Row(
                    children: [
                      Expanded(
                        child: _NetflixButton(
                          label: 'Edit Profile',
                          icon: Icons.edit_outlined,
                          onTap: () => context.push('/profile/edit'),
                          filled: true,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _NetflixButton(
                          label: 'Reset Password',
                          icon: Icons.lock_reset_outlined,
                          onTap: () =>
                              _sendPasswordResetEmail(context, ref, profile),
                          filled: false,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // ── Secondary CTA row ──────────────────────────────────
                  Row(
                    children: [
                      Expanded(
                        child: _NetflixButton(
                          label: 'Certificates',
                          icon: Icons.workspace_premium_outlined,
                          onTap: () => context.push('/certificates'),
                          filled: false,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _NetflixButton(
                          label: 'More Actions',
                          icon: Icons.more_horiz_rounded,
                          onTap: () => _showProfileActions(context, ref),
                          filled: false,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),

                  // ── Info sections ──────────────────────────────────────
                  _SectionCard(
                    title: 'Account',
                    icon: Icons.person_outline_rounded,
                    children: [
                      _InfoRow(label: 'Full name', value: profile.name),
                      _InfoRow(label: 'Email', value: profile.email),
                      _InfoRow(label: 'WhatsApp', value: profile.whatsapp),
                      _InfoRow(label: 'Instagram', value: profile.instagram),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _SectionCard(
                    title: 'Personal',
                    icon: Icons.badge_outlined,
                    children: [
                      _InfoRow(label: 'Country', value: profile.country),
                      _InfoRow(label: 'Birth date', value: profile.birthDate),
                      _InfoRow(label: 'Gender', value: profile.gender),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _SectionCard(
                    title: 'Practice',
                    icon: Icons.self_improvement_rounded,
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
                        value: profile.hoursPerWeek?.toString(),
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
                  ),
                  const SizedBox(height: 12),
                  _SectionCard(
                    title: 'Motivation',
                    icon: Icons.emoji_objects_outlined,
                    children: [
                      _InfoRow(label: 'Motivation', value: profile.motivation),
                      _InfoRow(label: 'Why YogaFX', value: profile.whyYogafx),
                      _InfoRow(
                        label: 'How you found us',
                        value: profile.howDidYouFindUs,
                      ),
                    ],
                  ),
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.divider, width: 0.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Avatar with red ring accent
          Stack(
            children: [
              Container(
                padding: const EdgeInsets.all(2.5),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primary, width: 2),
                ),
                child: CircleAvatar(
                  radius: 32,
                  backgroundColor: AppColors.surfaceElevated,
                  backgroundImage: profile.profilePhoto != null
                      ? NetworkImage(profile.profilePhoto!)
                      : null,
                  child: profile.profilePhoto == null
                      ? Text(
                    _initials(profile.name),
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Montserrat',
                    ),
                  )
                      : null,
                ),
              ),
              // Online dot
              Positioned(
                bottom: 2,
                right: 2,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: AppColors.success,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.surface, width: 2),
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
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    fontFamily: 'Montserrat',
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  profile.accessTier.name.toUpperCase(),
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Montserrat',
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 10),
                // Profile status badge
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
    final color = completed ? AppColors.success : AppColors.primary;
    final label = completed ? 'PROFILE COMPLETE' : 'PROFILE INCOMPLETE';
    final icon = completed ? Icons.verified_rounded : Icons.info_outline_rounded;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.28), width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 11),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 9,
              fontWeight: FontWeight.w700,
              fontFamily: 'Montserrat',
              letterSpacing: 1.1,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Netflix-style Button ────────────────────────────────────────────────────

class _NetflixButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool filled;

  const _NetflixButton({
    required this.label,
    required this.icon,
    required this.onTap,
    required this.filled,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Ink(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: filled ? AppColors.primary : AppColors.surfaceElevated,
            borderRadius: BorderRadius.circular(6),
            border: filled
                ? null
                : Border.all(color: AppColors.divider, width: 0.8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 15,
                color: filled ? Colors.white : AppColors.textSecondary,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: filled ? Colors.white : AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
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
    final color = isDanger ? AppColors.primary : AppColors.textPrimary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.surfaceElevated,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.divider, width: 0.8),
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

// ─── Section Card ─────────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.divider, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header with subtle left accent bar
          Container(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: AppColors.divider, width: 0.5),
                left: BorderSide(color: AppColors.primary, width: 3),
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, color: AppColors.primary, size: 14),
                const SizedBox(width: 8),
                Text(
                  title.toUpperCase(),
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Montserrat',
                    letterSpacing: 1.4,
                  ),
                ),
              ],
            ),
          ),
          // Info rows
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
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
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 12,
                fontFamily: 'Montserrat',
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 6,
            child: Text(
              isEmpty ? '—' : value!,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: isEmpty
                    ? AppColors.textMuted
                    : AppColors.textPrimary,
                fontSize: 12,
                fontFamily: 'Montserrat',
                fontWeight:
                isEmpty ? FontWeight.w400 : FontWeight.w500,
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
          backgroundColor: AppColors.background,
          floating: true,
          snap: true,
          title: Text(
            'My Profile',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w700,
              fontFamily: 'Montserrat',
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _shimmer(height: 100, radius: 10),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(child: _shimmer(height: 44, radius: 6)),
                    const SizedBox(width: 10),
                    Expanded(child: _shimmer(height: 44, radius: 6)),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(child: _shimmer(height: 44, radius: 6)),
                    const SizedBox(width: 10),
                    Expanded(child: _shimmer(height: 44, radius: 6)),
                  ],
                ),
                const SizedBox(height: 24),
                ...List.generate(
                  4,
                      (_) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _shimmer(height: 140, radius: 10),
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
        color: AppColors.shimmer,
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
              color: AppColors.textMuted,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                fontFamily: 'Montserrat',
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: 140,
              child: ElevatedButton(
                onPressed: onRetry,
                child: const Text('Try again'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}