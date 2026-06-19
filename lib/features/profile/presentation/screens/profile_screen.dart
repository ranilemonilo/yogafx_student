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
          SliverAppBar(
            backgroundColor: AppColors.background,
            floating: true,
            snap: true,
            elevation: 0,
            titleSpacing: 20,
            leading: IconButton(
              onPressed: () => _handleProfileBack(context),
              icon: const Icon(Icons.arrow_back_ios_new, size: 18),
            ),
            title: const Text('Profile'),
            actions: [
              IconButton(
                onPressed: () => _showProfileActions(context, ref),
                icon: const Icon(Icons.more_vert_rounded),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Align(
                    alignment: Alignment.centerRight,
                    child: RunningLoginTimeCard(),
                  ),
                  const SizedBox(height: 16),
                  _ProfileHeader(profile: profile),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => context.push('/profile/edit'),
                          child: const Text('Edit Profile'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () =>
                              _sendPasswordResetEmail(context, ref, profile),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.textSecondary,
                            side: const BorderSide(color: AppColors.divider),
                          ),
                          child: const Text('Reset Password'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => context.push('/certificates'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.textSecondary,
                            side: const BorderSide(color: AppColors.divider),
                          ),
                          child: const Text('Certificates'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _showProfileActions(context, ref),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textSecondary,
                        side: const BorderSide(color: AppColors.divider),
                      ),
                      icon: const Icon(Icons.more_horiz_rounded),
                      label: const Text('More Actions'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _SectionCard(
                    title: 'Account',
                    children: [
                      _InfoRow(label: 'Full name', value: profile.name),
                      _InfoRow(label: 'Email', value: profile.email),
                      _InfoRow(label: 'WhatsApp', value: profile.whatsapp),
                      _InfoRow(label: 'Instagram', value: profile.instagram),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _SectionCard(
                    title: 'Personal',
                    children: [
                      _InfoRow(label: 'Country', value: profile.country),
                      _InfoRow(label: 'Birth date', value: profile.birthDate),
                      _InfoRow(label: 'Gender', value: profile.gender),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _SectionCard(
                    title: 'Practice',
                    children: [
                      _InfoRow(
                        label: 'Practicing yoga for',
                        value: profile.practicingYogaFor,
                      ),
                      _InfoRow(
                        label: 'Yoga sequence experience',
                        value: profile.yogaSequenceExperience,
                      ),
                      _InfoRow(
                        label: 'Hours per week',
                        value: profile.hoursPerWeek?.toString(),
                      ),
                      _InfoRow(
                        label: 'Current fitness level',
                        value: profile.currentFitnessLevel,
                      ),
                      _InfoRow(
                        label: 'Flexibility rating',
                        value: profile.flexibilityRating,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _SectionCard(
                    title: 'Motivation',
                    children: [
                      _InfoRow(label: 'Motivation', value: profile.motivation),
                      _InfoRow(label: 'Why YogaFX', value: profile.whyYogafx),
                      _InfoRow(
                        label: 'How did you find us',
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

class _ProfileHeader extends StatelessWidget {
  final ProfileData profile;

  const _ProfileHeader({required this.profile});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.divider, width: 0.5),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: AppColors.surfaceElevated,
            backgroundImage: profile.profilePhoto != null
                ? NetworkImage(profile.profilePhoto!)
                : null,
            child: profile.profilePhoto == null
                ? Text(
                    _initials(profile.name),
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Montserrat',
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.name,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Montserrat',
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  profile.accessTier.name,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Montserrat',
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: profile.profileCompleted
                        ? AppColors.success.withOpacity(0.12)
                        : AppColors.primary.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: profile.profileCompleted
                          ? AppColors.success.withOpacity(0.3)
                          : AppColors.primary.withOpacity(0.3),
                      width: 0.5,
                    ),
                  ),
                  child: Text(
                    profile.profileCompleted
                        ? 'PROFILE COMPLETED'
                        : 'PROFILE INCOMPLETE',
                    style: TextStyle(
                      color: profile.profileCompleted
                          ? AppColors.success
                          : AppColors.primary,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Montserrat',
                      letterSpacing: 1,
                    ),
                  ),
                ),
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

class _SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SectionCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.divider, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              fontFamily: 'Montserrat',
              letterSpacing: 1.4,
            ),
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String? value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
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
              (value == null || value!.trim().isEmpty) ? '-' : value!,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 12,
                fontFamily: 'Montserrat',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

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
          title: Text('Profile'),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Container(
                  height: 110,
                  decoration: BoxDecoration(
                    color: AppColors.shimmer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(height: 16),
                ...List.generate(
                  3,
                  (_) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Container(
                      height: 150,
                      decoration: BoxDecoration(
                        color: AppColors.shimmer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

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
