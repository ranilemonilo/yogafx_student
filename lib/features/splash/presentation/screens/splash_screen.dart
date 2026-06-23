import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/router/app_router.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _rotationController;

  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeInAnimation;
  late Animation<double> _fadeOutAnimation;
  late Animation<double> _glowAnimation;

  static const _logoUrl =
      'https://yogafx.b-cdn.net/content/Logo%20YogAFX.png';

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    );

    // Rotasi glow ring — looping terus selama splash tampil
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat();

    _fadeInAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.25, curve: Curves.easeOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.75, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.55, curve: Curves.easeOutBack),
      ),
    );

    _glowAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 0.6, curve: Curves.easeInOut),
      ),
    );

    _fadeOutAnimation = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.8, 1.0, curve: Curves.easeIn),
      ),
    );

    _controller.forward();

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _navigateNext();
      }
    });
  }

  void _navigateNext() {
    if (!mounted) return;
    final authState = ref.read(authProvider);
    if (authState.isAuthenticated) {
      context.go(AppRoutes.dashboard);
    } else {
      context.go(AppRoutes.login);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: AnimatedBuilder(
        animation: Listenable.merge([_controller, _rotationController]),
        builder: (context, child) {
          return Opacity(
            opacity: _fadeOutAnimation.value,
            child: Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Outer soft glow — radial, statis
                  Opacity(
                    opacity: _glowAnimation.value * 0.45,
                    child: Container(
                      width: 280,
                      height: 280,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            AppColors.primary.withOpacity(0.35),
                            AppColors.primary.withOpacity(0),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Rotating light ring — efek cahaya mengelilingi
                  Opacity(
                    opacity: _glowAnimation.value,
                    child: Transform.rotate(
                      angle: _rotationController.value * 2 * 3.14159,
                      child: Container(
                        width: 220,
                        height: 220,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: SweepGradient(
                            colors: [
                              AppColors.primary.withOpacity(0),
                              AppColors.primary.withOpacity(0),
                              AppColors.primary.withOpacity(0.8),
                              AppColors.primary.withOpacity(0),
                              AppColors.primary.withOpacity(0),
                            ],
                            stops: const [0.0, 0.35, 0.5, 0.65, 1.0],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Mask lingkaran dalam supaya jadi ring (bukan disk penuh)
                  Container(
                    width: 196,
                    height: 196,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.background,
                    ),
                  ),

                  // Logo dengan scale + fade
                  Opacity(
                    opacity: _fadeInAnimation.value,
                    child: Transform.scale(
                      scale: _scaleAnimation.value,
                      child: CachedNetworkImage(
                        imageUrl: _logoUrl,
                        width: 160,
                        height: 160,
                        fit: BoxFit.contain,
                        errorWidget: (_, __, ___) => Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Center(
                            child: Text(
                              'YFX',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.w700,
                                fontFamily: 'Montserrat',
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}