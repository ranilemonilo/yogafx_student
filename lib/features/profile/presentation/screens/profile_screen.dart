import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/auth_network_image.dart';
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
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadius.modal),
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
                'Profile Menu',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Montserrat',
                ),
              ),
              const SizedBox(height: 16),
              _ProfileActionTile(
                icon: Icons.edit_outlined,
                title: 'Edit Profile',
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  context.push(AppRoutes.editProfile);
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.modal),
        ),
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
    await ref.read(authRepositoryProvider).forgotPassword(email: profile.email);
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

class _ProfileContent extends ConsumerStatefulWidget {
  final ProfileData profile;

  const _ProfileContent({required this.profile});

  @override
  ConsumerState<_ProfileContent> createState() => _ProfileContentState();
}

class _ProfileContentState extends ConsumerState<_ProfileContent>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  static const int _slotCount = 7;
  late final List<Animation<double>> _fades;
  late final List<Animation<Offset>> _slides;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 760),
    );
    _fades = List.generate(_slotCount, (index) {
      final start = (index * 0.1).clamp(0.0, 1.0);
      final end = (start + 0.42).clamp(0.0, 1.0);
      return Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(start, end, curve: Curves.easeOut),
        ),
      );
    });
    _slides = List.generate(_slotCount, (index) {
      final start = (index * 0.1).clamp(0.0, 1.0);
      final end = (start + 0.42).clamp(0.0, 1.0);
      return Tween<Offset>(
        begin: const Offset(0, 0.07),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(start, end, curve: Curves.easeOutCubic),
        ),
      );
    });
    Future.delayed(const Duration(milliseconds: 60), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _animated(int slot, Widget child) {
    return FadeTransition(
      opacity: _fades[slot],
      child: SlideTransition(position: _slides[slot], child: child),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profile = widget.profile;

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () async {
        ref.invalidate(profileProvider);
        await ref.read(profileProvider.future);
      },
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        slivers: [
          SliverAppBar(
            backgroundColor: AppColors.background,
            floating: true,
            snap: true,
            elevation: 0,
            titleSpacing: 4,
            leading: IconButton(
              onPressed: () => _handleProfileBack(context),
              icon: const Icon(
                Icons.arrow_back,
                size: 24,
                color: AppColors.textPrimary,
              ),
            ),
            title: const Text(
              'My Profile',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 24,
                fontWeight: FontWeight.w600,
                fontFamily: 'Montserrat',
                letterSpacing: 0.2,
              ),
            ),
            actions: [
              IconButton(
                onPressed: () => _showProfileActions(context, ref),
                icon: const Icon(
                  Icons.more_horiz_rounded,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: 8),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _animated(
                    0,
                    Align(
                      alignment: Alignment.centerRight,
                      child: const RunningLoginTimeCard(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _animated(1, _ProfileHeroCard(profile: profile)),
                  const SizedBox(height: 20),
                  _animated(
                    2,
                    Row(
                      children: [
                        Expanded(
                          child: _ProfileButton(
                            label: 'Edit Profile',
                            icon: Icons.edit_outlined,
                            onTap: () => context.push(AppRoutes.editProfile),
                            variant: _ProfileButtonVariant.primary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _ProfileButton(
                            label: 'Reset Password',
                            icon: Icons.lock_reset_outlined,
                            onTap: () =>
                                _sendPasswordResetEmail(context, ref, profile),
                            variant: _ProfileButtonVariant.secondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  _animated(
                    3,
                    _ProfileSectionCard(
                      title: 'Account',
                      icon: Icons.person_outline_rounded,
                      children: [
                        _InfoRow(label: 'Full name', value: profile.name),
                        _InfoRow(label: 'Email', value: profile.email),
                        _InfoRow(label: 'WhatsApp', value: profile.whatsapp),
                        _InfoRow(label: 'Instagram', value: profile.instagram),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  _animated(
                    4,
                    _ProfileSectionCard(
                      title: 'Personal',
                      icon: Icons.badge_outlined,
                      children: [
                        _InfoRow(label: 'Country', value: profile.country),
                        _InfoRow(label: 'Birth date', value: profile.birthDate),
                        _InfoRow(label: 'Gender', value: profile.gender),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  _animated(
                    5,
                    _ProfileSectionCard(
                      title: 'Practice',
                      icon: Icons.self_improvement_outlined,
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
                    ),
                  ),
                  const SizedBox(height: 12),
                  _animated(
                    6,
                    _ProfileSectionCard(
                      title: 'Motivation',
                      icon: Icons.lightbulb_outline_rounded,
                      children: [
                        _InfoRow(label: 'Motivation', value: profile.motivation),
                        _InfoRow(
                          label: 'Why YogaFX',
                          value: profile.whyYogafx,
                        ),
                        _InfoRow(
                          label: 'How you found us',
                          value: profile.howDidYouFindUs,
                        ),
                      ],
                    ),
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

class _ProfileHeroCard extends StatelessWidget {
  final ProfileData profile;

  const _ProfileHeroCard({required this.profile});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.divider, width: 0.8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.28),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ProfileAvatar(profile: profile),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _SectionEyebrow(text: 'Student Profile'),
                    const SizedBox(height: 10),
                    Text(
                      profile.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Montserrat',
                        height: 1.15,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      profile.email,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _MetaBadge(
                icon: Icons.workspace_premium_outlined,
                label: profile.accessTier.name.toUpperCase(),
                tone: AppColors.primary,
              ),
              _MetaBadge(
                icon: profile.profileCompleted
                    ? Icons.verified_rounded
                    : Icons.pending_outlined,
                label: profile.profileCompleted
                    ? 'PROFILE COMPLETE'
                    : 'PROFILE INCOMPLETE',
                tone: profile.profileCompleted
                    ? AppColors.success
                    : AppColors.warning,
              ),
              if ((profile.country ?? '').trim().isNotEmpty)
                _MetaBadge(
                  icon: Icons.public_outlined,
                  label: profile.country!.trim(),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  final ProfileData profile;

  const _ProfileAvatar({required this.profile});

  @override
  Widget build(BuildContext context) {
    final imageUrl = profile.profilePhoto?.trim();
    final hasImage = imageUrl != null && imageUrl.isNotEmpty;

    return Container(
      width: 84,
      height: 84,
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(AppRadius.avatar),
        border: Border.all(color: AppColors.primary, width: 1.5),
      ),
      clipBehavior: Clip.antiAlias,
      child: hasImage
          ? AuthNetworkImage(
              imageUrl: imageUrl!,
              fit: BoxFit.cover,
              placeholderBuilder: (_) =>
                  _ProfileAvatarFallback(name: profile.name),
              errorBuilderWidget: (_, __) =>
                  _ProfileAvatarFallback(name: profile.name),
            )
          : _ProfileAvatarFallback(name: profile.name),
    );
  }
}

class _ProfileAvatarFallback extends StatelessWidget {
  final String name;

  const _ProfileAvatarFallback({required this.name});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        _initials(name),
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 26,
          fontWeight: FontWeight.w700,
          fontFamily: 'Montserrat',
        ),
      ),
    );
  }
}

class _MetaBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? tone;

  const _MetaBadge({
    required this.icon,
    required this.label,
    this.tone,
  });

  @override
  Widget build(BuildContext context) {
    final badgeColor = tone ?? AppColors.textSecondary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.12),
        borderRadius: BorderRadius.circular(AppRadius.badge),
        border: Border.all(color: badgeColor.withOpacity(0.24)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: badgeColor, size: 12),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: badgeColor,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              fontFamily: 'Montserrat',
              letterSpacing: 0.6,
            ),
          ),
        ],
      ),
    );
  }
}

enum _ProfileButtonVariant { primary, secondary }

class _ProfileButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final _ProfileButtonVariant variant;

  const _ProfileButton({
    required this.label,
    required this.icon,
    required this.onTap,
    required this.variant,
  });

  @override
  Widget build(BuildContext context) {
    final isPrimary = variant == _ProfileButtonVariant.primary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.button),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color:
                isPrimary ? AppColors.primary : Colors.white.withOpacity(0.12),
            borderRadius: BorderRadius.circular(AppRadius.button),
            border: isPrimary
                ? null
                : Border.all(
                    color: Colors.white.withOpacity(0.16),
                    width: 0.8,
                  ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: AppColors.textPrimary,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
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
        borderRadius: BorderRadius.circular(AppRadius.modal),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.surfaceElevated,
            borderRadius: BorderRadius.circular(AppRadius.modal),
            border: Border.all(color: AppColors.divider, width: 0.8),
          ),
          child: Row(
            children: [
              Icon(icon, color: color, size: 18),
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
              Icon(Icons.chevron_right_rounded, color: color, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileSectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _ProfileSectionCard({
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
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.divider, width: 0.8),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppColors.primary, size: 15),
                const SizedBox(width: 8),
                Expanded(child: _SectionEyebrow(text: title)),
              ],
            ),
            const SizedBox(height: 14),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _SectionEyebrow extends StatelessWidget {
  final String text;

  const _SectionEyebrow({required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 12,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text.toUpperCase(),
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              fontFamily: 'Montserrat',
              letterSpacing: 1.8,
            ),
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String? value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final displayValue = value?.trim() ?? '';
    final isEmpty = displayValue.isEmpty;

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
              isEmpty ? '-' : displayValue,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: isEmpty ? AppColors.textMuted : AppColors.textPrimary,
                fontSize: 12,
                fontWeight: isEmpty ? FontWeight.w400 : FontWeight.w500,
                fontFamily: 'Montserrat',
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileSkeleton extends StatefulWidget {
  const _ProfileSkeleton();

  @override
  State<_ProfileSkeleton> createState() => _ProfileSkeletonState();
}

class _ProfileSkeletonState extends State<_ProfileSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shimmerController;
  late final Animation<double> _shimmerAnimation;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _shimmerAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shimmerAnimation,
      builder: (context, _) {
        final shimmerColor = Color.lerp(
          AppColors.shimmer,
          AppColors.shimmerHighlight,
          _shimmerAnimation.value,
        )!;

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
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.centerRight,
                      child: _bone(
                        width: 158,
                        height: 34,
                        radius: 999,
                        color: shimmerColor,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _bone(
                      width: double.infinity,
                      height: 180,
                      radius: AppRadius.card,
                      color: shimmerColor,
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: _bone(
                            width: double.infinity,
                            height: 44,
                            radius: AppRadius.button,
                            color: shimmerColor,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _bone(
                            width: double.infinity,
                            height: 44,
                            radius: AppRadius.button,
                            color: shimmerColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                    ...List.generate(
                      4,
                      (_) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _bone(
                          width: double.infinity,
                          height: 164,
                          radius: AppRadius.card,
                          color: shimmerColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _bone({
    required double width,
    required double height,
    required double radius,
    required Color color,
  }) {
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
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.25),
                ),
              ),
              child: const Icon(
                Icons.wifi_off_rounded,
                color: AppColors.primary,
                size: 28,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                fontFamily: 'Montserrat',
                height: 1.5,
              ),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: 148,
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

String _initials(String value) {
  final parts = value
      .trim()
      .split(RegExp(r'\s+'))
      .where((part) => part.isNotEmpty)
      .toList();

  if (parts.isEmpty) return 'Y';
  if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();

  return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
      .toUpperCase();
}
