import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../router/app_router.dart';
import '../theme/app_theme.dart';

class MainShell extends ConsumerWidget {
  final Widget child;

  const MainShell({super.key, required this.child});

  int _selectedIndex(BuildContext context, bool hasUpgradeAccess) {
    final location = GoRouterState.of(context).matchedLocation;
    final state = GoRouterState.of(context);
    final isUpgradeFocus =
        state.uri.queryParameters['focus'] == 'upgrade' &&
        location.startsWith(AppRoutes.profile);

    if (location.startsWith(AppRoutes.modules)) return 1;
    if (hasUpgradeAccess && isUpgradeFocus) return 2;
    if (location.startsWith(AppRoutes.profile)) return hasUpgradeAccess ? 3 : 2;
    return 0; // dashboard
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final hasUpgradeAccess = authState.user?.upgradeOptions.isNotEmpty ?? false;
    final selectedIndex = _selectedIndex(context, hasUpgradeAccess);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: child,
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: AppColors.divider, width: 0.5),
              ),
            ),
            child: BottomNavigationBar(
              currentIndex: selectedIndex,
              onTap: (index) {
                switch (index) {
                  case 0:
                    context.go(AppRoutes.dashboard);
                    return;
                  case 1:
                    context.go(AppRoutes.modules);
                    return;
                  case 2:
                    if (hasUpgradeAccess) {
                      context.go('${AppRoutes.profile}?focus=upgrade');
                      return;
                    }
                    context.go(AppRoutes.profile);
                    return;
                  case 3:
                    context.go(AppRoutes.profile);
                    return;
                }
              },
              items: [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home_outlined),
                  activeIcon: Icon(Icons.home),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.play_circle_outline),
                  activeIcon: Icon(Icons.play_circle),
                  label: 'Modules',
                ),
                if (hasUpgradeAccess)
                  const BottomNavigationBarItem(
                    icon: Icon(Icons.workspace_premium_outlined),
                    activeIcon: Icon(Icons.workspace_premium),
                    label: 'Upgrade Access',
                  ),
                const BottomNavigationBarItem(
                  icon: Icon(Icons.person_outline),
                  activeIcon: Icon(Icons.person),
                  label: 'Profile',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
