import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../utils/reset_password_link_parser.dart';

class ResetPasswordDeepLinkHandler extends StatefulWidget {
  final Widget child;

  const ResetPasswordDeepLinkHandler({
    super.key,
    required this.child,
  });

  @override
  State<ResetPasswordDeepLinkHandler> createState() =>
      _ResetPasswordDeepLinkHandlerState();
}

class _ResetPasswordDeepLinkHandlerState
    extends State<ResetPasswordDeepLinkHandler> {
  final AppLinks _appLinks = AppLinks();
  StreamSubscription<Uri>? _subscription;
  bool _handledInitialUri = false;

  @override
  void initState() {
    super.initState();
    _listenInitialUri();
    _subscription = _appLinks.uriLinkStream.listen(
      _handleUri,
      onError: (_) {},
    );
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
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
