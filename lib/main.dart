import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:app_links/app_links.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Force portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  // Status bar style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  runApp(
    const ProviderScope(
      child: YogaFXApp(),
    ),
  );
}

class YogaFXApp extends ConsumerStatefulWidget {
  const YogaFXApp({super.key});

  @override
  ConsumerState<YogaFXApp> createState() => _YogaFXAppState();
}

class _YogaFXAppState extends ConsumerState<YogaFXApp> {
  late final AppLinks _appLinks;
  StreamSubscription<Uri>? _deepLinkSubscription;

  @override
  void initState() {
    super.initState();
    _appLinks = AppLinks();
    _listenToDeepLinks();
  }

  Future<void> _listenToDeepLinks() async {
    try {
      final initialUri = await _appLinks.getInitialLink();
      _openDeepLink(initialUri);
    } catch (_) {}

    _deepLinkSubscription = _appLinks.uriLinkStream.listen(_openDeepLink);
  }

  void _openDeepLink(Uri? uri) {
    if (uri == null) return;
    final route = mapDeepLinkToRoute(uri);
    if (route == null || route.isEmpty) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(appRouterProvider).go(route);
    });
  }

  @override
  void dispose() {
    _deepLinkSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(appRouterProvider);
    return MaterialApp.router(
      title: 'YogaFX',
      theme: AppTheme.dark,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
