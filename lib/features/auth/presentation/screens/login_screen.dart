import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/error/app_exception.dart';
import '../../../../core/router/app_router.dart';
import '../../data/repositories/auth_repository.dart';
import 'login_otp_screen.dart';
import '../providers/auth_provider.dart';

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
    final isLoading =
        _isSubmitting || authState.status == AuthStatus.loading;
    final error = _requestError ?? authState.error;

    return Scaffold(
      backgroundColor: const Color(0xFF141414),
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // ── Subtle vignette ──
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.topRight,
                radius: 1.8,
                colors: [
                  Color(0x18E50914),
                  Colors.transparent,
                ],
              ),
            ),
          ),

          // ── Full centered layout ──
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: FadeTransition(
                  opacity: _fadeAnim,
                  child: SlideTransition(
                    position: _slideAnim,
                    child: _buildContent(isLoading, error),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(bool isLoading, String? error) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 360),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 48),

          // ── Centered Logo ──
          ScaleTransition(
            scale: _logoScale,
            child: _buildLogo(),
          ),

          const SizedBox(height: 40),

          // ── Title ──
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Sign In',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w800,
                fontFamily: 'Montserrat',
                letterSpacing: -0.5,
              ),
            ),
          ),

          const SizedBox(height: 28),

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
                _NetflixField(
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
                _NetflixField(
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

          const SizedBox(height: 48),
        ],
      ),
    );
  }

  // ── UPDATE: Membesarkan ukuran logo, pakai Network Image ──
  Widget _buildLogo() {
    return Image.network(
      'https://yogafx.b-cdn.net/content/Logo%20YogAFX.png',
      width: 260,
      height: 120,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        // Fallback jika gambar gagal dimuat
        return const Icon(Icons.image_not_supported, color: Colors.white, size: 80);
      },
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text.toUpperCase(),
      style: const TextStyle(
        color: Color(0xFFB3B3B3),
        fontSize: 10,
        fontWeight: FontWeight.w600,
        fontFamily: 'Montserrat',
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildErrorBanner(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A0A00),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0xFFE87C03).withOpacity(0.6)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded,
              color: Color(0xFFE87C03), size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Color(0xFFE87C03),
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

// ─── Netflix Field ────────────────────────────────────────────────────────────

class _NetflixField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final bool obscureText;
  final bool enabled;
  final TextInputType keyboardType;
  final IconData suffixIcon;
  final VoidCallback? onSuffixTap;
  final String? Function(String?)? validator;
  final void Function(String)? onSubmitted;

  const _NetflixField({
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
  State<_NetflixField> createState() => _NetflixFieldState();
}

class _NetflixFieldState extends State<_NetflixField> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    return Focus(
      onFocusChange: (v) => setState(() => _focused = v),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          boxShadow: _focused
              ? [
            BoxShadow(
              color: const Color(0xFFE50914).withOpacity(0.15),
              blurRadius: 10,
              offset: const Offset(0, 2),
            )
          ]
              : [],
        ),
        child: TextFormField(
          controller: widget.controller,
          obscureText: widget.obscureText,
          enabled: widget.enabled,
          keyboardType: widget.keyboardType,
          autocorrect: false,
          onFieldSubmitted: widget.onSubmitted,
          validator: widget.validator,
          style: const TextStyle(
            color: Colors.white,
            fontFamily: 'Montserrat',
            fontSize: 15,
          ),
          decoration: InputDecoration(
            hintText: widget.hintText,
            hintStyle: const TextStyle(color: Color(0xFF555555)),
            filled: true,
            fillColor: _focused
                ? const Color(0xFF3A3A3A)
                : const Color(0xFF2E2E2E),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide:
              const BorderSide(color: Color(0xFF3A3A3A), width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide:
              const BorderSide(color: Color(0xFFE50914), width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: const BorderSide(color: Color(0xFFE87C03)),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: const BorderSide(color: Color(0xFFE87C03)),
            ),
            errorStyle: const TextStyle(
              color: Color(0xFFE87C03),
              fontFamily: 'Montserrat',
              fontSize: 11,
            ),
            contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            suffixIcon: widget.onSuffixTap != null
                ? IconButton(
              onPressed: widget.onSuffixTap,
              icon: Icon(widget.suffixIcon,
                  color: const Color(0xFF666666), size: 20),
            )
                : Icon(widget.suffixIcon,
                color: const Color(0xFF555555), size: 20),
          ),
        ),
      ),
    );
  }
}

// ─── Sign In Button ───────────────────────────────────────────────────────────

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
      onTapDown: widget.isLoading ? null : (_) => _scaleCtrl.reverse(),
      onTapUp: widget.isLoading
          ? null
          : (_) {
        _scaleCtrl.forward();
        widget.onTap();
      },
      onTapCancel: () => _scaleCtrl.forward(),
      child: ScaleTransition(
        scale: _scaleCtrl,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: double.infinity,
          height: 52,
          decoration: BoxDecoration(
            color: widget.isLoading
                ? const Color(0x80E50914)
                : const Color(0xFFE50914),
            borderRadius: BorderRadius.circular(4),
            boxShadow: widget.isLoading
                ? []
                : [
              BoxShadow(
                color: const Color(0xFFE50914).withOpacity(0.4),
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
                  color: Colors.white, strokeWidth: 2.5),
            )
                : const Text(
              'Sign In',
              style: TextStyle(
                color: Colors.white,
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
          color: _hovering ? Colors.white : const Color(0xFF808080),
          fontSize: 12,
          fontFamily: 'Montserrat',
          fontWeight: FontWeight.w500,
          decoration:
          _hovering ? TextDecoration.underline : TextDecoration.none,
          decorationColor: Colors.white,
        ),
        child: Text(widget.label),
      ),
    );
  }
}