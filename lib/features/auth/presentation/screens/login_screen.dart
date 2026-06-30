import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/error/app_exception.dart';
import '../../../../core/router/app_router.dart';
import '../../data/repositories/auth_repository.dart';
import 'login_otp_screen.dart';
import '../providers/auth_provider.dart';
import '../../../../core/theme/app_theme.dart'; // pastikan path sesuai project

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isSubmitting = false;
  String? _requestError;

  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  late AnimationController _logoCtrl;
  late Animation<double> _logoScale;

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim =
        CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
        CurvedAnimation(parent: _animController, curve: Curves.easeOut));

    _logoCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _logoScale = Tween<double>(begin: 0.85, end: 1.0).animate(
        CurvedAnimation(parent: _logoCtrl, curve: Curves.elasticOut));

    _logoCtrl.forward();
    Future.delayed(const Duration(milliseconds: 150),
            () => _animController.forward());
  }

  @override
  void dispose() {
    _animController.dispose();
    _logoCtrl.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
      _requestError = null;
    });

    try {
      final challenge = await ref.read(authRepositoryProvider).requestLoginOtp(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (!mounted) return;

      context.push(
        AppRoutes.loginOtp,
        extra: LoginOtpScreenArgs(
          challengeToken: challenge.challengeToken,
          email: challenge.email,
          expiresAt: challenge.expiresAt,
        ),
      );
    } on AppException catch (e) {
      if (!mounted) return;
      setState(() {
        _requestError = _resolveErrorMessage(e);
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _requestError = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  String _resolveErrorMessage(AppException exception) {
    final errors = exception.errors;
    if (errors != null) {
      for (final value in errors.values) {
        if (value is List && value.isNotEmpty) {
          return value.first.toString();
        }
        if (value is String && value.isNotEmpty) {
          return value;
        }
      }
    }

    return exception.message;
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isLoading = _isSubmitting;
    final error = _requestError ?? authState.error;
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 768;
    final horizontalPadding = isTablet ? 48.0 : 32.0;

    return Scaffold(
      // ── §1: background utama = Neutral Black 1 ──
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // ── Vignette — warna primary sesuai design system ──
          Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.topRight,
                radius: 1.8,
                colors: [
                  AppColors.primary.withOpacity(0.09),
                  Colors.transparent,
                ],
              ),
            ),
          ),

          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight),
                    child: Center(
                      child: FadeTransition(
                        opacity: _fadeAnim,
                        child: SlideTransition(
                          position: _slideAnim,
                          child: _buildContent(
                            isLoading,
                            error,
                            isTablet: isTablet,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(
    bool isLoading,
    String? error, {
    required bool isTablet,
  }) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: isTablet ? double.infinity : 360),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [

          // ── Logo ──
          ScaleTransition(
            scale: _logoScale,
            child: _buildLogo(),
          ),

          const SizedBox(height: 24),

          // ── Title — §2: Title 1 = 28px SemiBold ──
          const Text(
            'Sign in to Your Account',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 28,
              fontWeight: FontWeight.w700,
              fontFamily: 'Montserrat',
              letterSpacing: -0.5,
            ),
          ),

          const SizedBox(height: 24),

          // ── Error banner ──
          if (error != null) ...[
            _buildErrorBanner(error),
            const SizedBox(height: 20),
          ],

          // ── Form ──
          Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Email ──
                _buildLabel('Email'),
                const SizedBox(height: 8),
                _DSInputField(
                  controller: _emailController,
                  hintText: 'your@email.com',
                  keyboardType: TextInputType.emailAddress,
                  enabled: !isLoading,
                  suffixIcon: Icons.mail_outline_rounded,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Email is required';
                    }
                    if (!value.contains('@')) return 'Enter a valid email';
                    return null;
                  },
                ),
                const SizedBox(height: 18),

                // ── Password ──
                _buildLabel('Password'),
                const SizedBox(height: 8),
                _DSInputField(
                  controller: _passwordController,
                  hintText: '••••••••',
                  obscureText: _obscurePassword,
                  enabled: !isLoading,
                  suffixIcon: _obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  onSuffixTap: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Password is required';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                  onSubmitted: (_) => _handleLogin(),
                ),
                const SizedBox(height: 28),

                // ── Sign In button ──
                _SignInButton(isLoading: isLoading, onTap: _handleLogin),

                const SizedBox(height: 20),

                // ── Footer links ──
                Row(
                  children: [
                    _LinkButton(
                      label: 'Reset password',
                      onTap: () => context.push(AppRoutes.resetPassword),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogo() {
    return Image.network(
      'https://yogafx.b-cdn.net/content/Logo%20YogAFX.png',
      width: 260,
      height: 120,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return const Icon(Icons.image_not_supported,
            color: AppColors.textPrimary, size: 80);
      },
    );
  }

  // ── §2: Caption 12px, letter-spacing 1.2 — label form ──
  Widget _buildLabel(String text) {
    return Text(
      text.toUpperCase(),
      style: const TextStyle(
        color: AppColors.textSecondary, // rgba(255,255,255,0.65)
        fontSize: 10,
        fontWeight: FontWeight.w600,
        fontFamily: 'Montserrat',
        letterSpacing: 1.2,
      ),
    );
  }

  // ── §5: Error border merah #DB202C, bukan oranye ──
  Widget _buildErrorBanner(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        // Dark reddish bg sesuai tema gelap
        color: AppColors.primary.withOpacity(0.10),
        borderRadius: BorderRadius.circular(AppRadius.modal),
        border: Border.all(color: AppColors.error.withOpacity(0.6)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded,
              color: AppColors.error, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: AppColors.error,
                fontSize: 13,
                fontFamily: 'Montserrat',
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Design System Input Field ────────────────────────────────────────────────
// §5: Default border rgba(255,255,255,0.3) | Focus border #FFFFFF solid
//     Fill default rgba(255,255,255,0.1) | Fill focus rgba(255,255,255,0.15)
//     Error border #DB202C

class _DSInputField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final bool obscureText;
  final bool enabled;
  final TextInputType keyboardType;
  final IconData suffixIcon;
  final VoidCallback? onSuffixTap;
  final String? Function(String?)? validator;
  final void Function(String)? onSubmitted;

  const _DSInputField({
    required this.controller,
    required this.hintText,
    this.obscureText = false,
    this.enabled = true,
    this.keyboardType = TextInputType.text,
    required this.suffixIcon,
    this.onSuffixTap,
    this.validator,
    this.onSubmitted,
  });

  @override
  State<_DSInputField> createState() => _DSInputFieldState();
}

class _DSInputFieldState extends State<_DSInputField> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    return Focus(
      onFocusChange: (v) => setState(() => _focused = v),
      child: TextFormField(
        controller: widget.controller,
        obscureText: widget.obscureText,
        enabled: widget.enabled,
        keyboardType: widget.keyboardType,
        autocorrect: false,
        onFieldSubmitted: widget.onSubmitted,
        validator: widget.validator,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontFamily: 'Montserrat',
          fontSize: 15,
        ),
        decoration: InputDecoration(
          hintText: widget.hintText,
          // §2: placeholder = rgba(255,255,255,0.45)
          hintStyle: const TextStyle(color: AppColors.textMuted),
          filled: true,
          // §5: fill default rgba(255,255,255,0.1), focus rgba(255,255,255,0.15)
          fillColor: _focused ? AppColors.inputFillFocus : AppColors.inputFill,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.input),
            borderSide: const BorderSide(
                color: Color(0x4DFFFFFF)), // rgba(255,255,255,0.3)
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.input),
            borderSide: const BorderSide(color: Color(0x4DFFFFFF)),
          ),
          // §5: focus = border putih solid
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.input),
            borderSide:
            const BorderSide(color: AppColors.textPrimary, width: 1.5),
          ),
          // §5: error = border merah #DB202C
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.input),
            borderSide: const BorderSide(color: AppColors.error),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.input),
            borderSide: const BorderSide(color: AppColors.error),
          ),
          errorStyle: const TextStyle(
            color: AppColors.error,
            fontFamily: 'Montserrat',
            fontSize: 11,
          ),
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          suffixIcon: widget.onSuffixTap != null
              ? IconButton(
            onPressed: widget.onSuffixTap,
            icon: Icon(widget.suffixIcon,
                // §3: ikon outline tipis, warna textMuted
                color: AppColors.textMuted,
                size: 20),
          )
              : Icon(widget.suffixIcon,
              color: AppColors.textMuted, size: 20),
        ),
      ),
    );
  }
}

// ─── Sign In Button ───────────────────────────────────────────────────────────
// §4: Large/Default h=42px | bg #DB202C | hover #F6121D | radius 4px

class _SignInButton extends StatefulWidget {
  final bool isLoading;
  final VoidCallback onTap;

  const _SignInButton({required this.isLoading, required this.onTap});

  @override
  State<_SignInButton> createState() => _SignInButtonState();
}

class _SignInButtonState extends State<_SignInButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleCtrl;
  bool _hovering = false;

  @override
  void initState() {
    super.initState();
    _scaleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 90),
      lowerBound: 0.97,
      upperBound: 1.0,
      value: 1.0,
    );
  }

  @override
  void dispose() {
    _scaleCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.isLoading
          ? null
          : (_) {
        _scaleCtrl.reverse();
        setState(() => _hovering = true);
      },
      onTapUp: widget.isLoading
          ? null
          : (_) {
        _scaleCtrl.forward();
        setState(() => _hovering = false);
        widget.onTap();
      },
      onTapCancel: () {
        _scaleCtrl.forward();
        setState(() => _hovering = false);
      },
      child: ScaleTransition(
        scale: _scaleCtrl,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: double.infinity,
          // §4: Large button height ~42px
          height: 48,
          decoration: BoxDecoration(
            color: widget.isLoading
                ? AppColors.primary.withOpacity(0.5)
                : _hovering
                ? AppColors.primaryHover // §4: hover lebih cerah
                : AppColors.primary,
            borderRadius: BorderRadius.circular(AppRadius.button), // §: 4px
            boxShadow: widget.isLoading || _hovering
                ? []
                : [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.35),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: widget.isLoading
                ? const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                  color: AppColors.textPrimary, strokeWidth: 2.5),
            )
                : const Text(
              'Sign In',
              style: TextStyle(
                color: AppColors.textPrimary,
                // §4: Large button = 16px Bold
                fontSize: 16,
                fontWeight: FontWeight.w700,
                fontFamily: 'Montserrat',
                letterSpacing: 0.3,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Link Button ──────────────────────────────────────────────────────────────

class _LinkButton extends StatefulWidget {
  final String label;
  final VoidCallback onTap;

  const _LinkButton({required this.label, required this.onTap});

  @override
  State<_LinkButton> createState() => _LinkButtonState();
}

class _LinkButtonState extends State<_LinkButton> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _hovering = true),
      onTapUp: (_) => setState(() => _hovering = false),
      onTapCancel: () => setState(() => _hovering = false),
      child: AnimatedDefaultTextStyle(
        duration: const Duration(milliseconds: 120),
        style: TextStyle(
          // hover → textPrimary, default → textSecondary
          color: _hovering ? AppColors.textPrimary : AppColors.textSecondary,
          fontSize: 12,
          fontFamily: 'Montserrat',
          fontWeight: FontWeight.w500,
          decoration:
          _hovering ? TextDecoration.underline : TextDecoration.none,
          decorationColor: AppColors.textPrimary,
        ),
        child: Text(widget.label),
      ),
    );
  }
}
