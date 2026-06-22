import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'features/auth/presentation/widgets/reset_password_deep_link_handler.dart';
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

class YogaFXApp extends ConsumerWidget {
  const YogaFXApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    return MaterialApp.router(
      title: 'YogaFX',
      theme: AppTheme.dark,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      builder: (context, child) => ResetPasswordDeepLinkHandler(
        child: child ?? const SizedBox.shrink(),
      ),
    );
  }
}
