import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../dashboard/presentation/providers/dashboard_provider.dart';
import '../../../profile/presentation/providers/profile_provider.dart';
import '../providers/auth_provider.dart';
import '../utils/reset_password_link_parser.dart';

class ResetPasswordDeepLinkHandler extends ConsumerStatefulWidget {
  final Widget child;

  const ResetPasswordDeepLinkHandler({
    super.key,
    required this.child,
  });

  @override
  ConsumerState<ResetPasswordDeepLinkHandler> createState() =>
      _ResetPasswordDeepLinkHandlerState();
}

class _ResetPasswordDeepLinkHandlerState
    extends ConsumerState<ResetPasswordDeepLinkHandler>
    with WidgetsBindingObserver {
  final AppLinks _appLinks = AppLinks();
  StreamSubscription<Uri>? _subscription;
  bool _handledInitialUri = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _listenInitialUri();
    _subscription = _appLinks.uriLinkStream.listen(
      _handleUri,
      onError: (_) {},
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) return;

    final authState = ref.read(authProvider);
    if (!authState.isAuthenticated) return;

    ref.read(authProvider.notifier).refreshCurrentUser();
    ref.invalidate(profileProvider);
    ref.invalidate(dashboardProvider);
  }

  Future<void> _listenInitialUri() async {
    if (_handledInitialUri) return;
    _handledInitialUri = true;

    try {
      final initialUri = await _appLinks.getInitialLink();
      if (!mounted || initialUri == null) return;
      _handleUri(initialUri);
    } catch (_) {}
  }

  void _handleUri(Uri uri) {
    final parsed = ResetPasswordLinkParser.parse(uri.toString());
    if (parsed == null || !mounted) return;

    final route = ResetPasswordLinkParser.buildAppRoute(parsed);
    final router = GoRouter.of(context);
    if (router.state.matchedLocation != AppRoutes.login) {
      router.push(route);
      return;
    }

    router.go(route);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
