import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/error/app_exception.dart';
import '../../../../core/router/app_router.dart';
import '../../data/repositories/auth_repository.dart';
import '../providers/auth_provider.dart';

// ─── Design tokens (DESIGN_SYSTEM.md) ────────────────────────────────────────
class _DS {
  static const bgPage    = Color(0xFF060908);
  static const bgCard    = Color(0xFF120F0E);
  static const bgHeader  = Color(0xFF141110);
  static const bgOverlay = Color(0xFF161210);
  static const bgInput   = Color(0xFF0E0B0A); // rgba(255,255,255,0.05) on dark
  static const primary   = Color(0xFFDB202C);
  static const primaryHover = Color(0xFFF6121D);
  static const warning   = Color(0xFFDF6739); // warm orange dari DS
  static const white     = Color(0xFFFFFFFF);
  static const textSec   = Color(0xFFA6A6A6); // rgba(255,255,255,0.65)
  static const textMuted = Color(0xFF737373); // rgba(255,255,255,0.45)
  static const border    = Color(0xFF1A1A1A); // rgba(255,255,255,0.10)
  static const borderFocus = Color(0xFFFFFFFF);
  static const fontFamily = 'Montserrat';
}

// ─── Args ─────────────────────────────────────────────────────────────────────

class LoginOtpScreenArgs {
  final String challengeToken;
  final String email;
  final DateTime? expiresAt;

  const LoginOtpScreenArgs({
    required this.challengeToken,
    required this.email,
    required this.expiresAt,
  });
}

// ─── Screen ───────────────────────────────────────────────────────────────────

class LoginOtpScreen extends ConsumerStatefulWidget {
  final LoginOtpScreenArgs challenge;

  const LoginOtpScreen({
    super.key,
    required this.challenge,
  });

  @override
  ConsumerState<LoginOtpScreen> createState() => _LoginOtpScreenState();
}

class _LoginOtpScreenState extends ConsumerState<LoginOtpScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _otpController = TextEditingController();

  bool _isVerifying = false;
  bool _isResending = false;
  String? _errorMessage;
  String? _otpFieldError;
  late String _challengeToken;
  late String _email;
  DateTime? _expiresAt;
  Timer? _timer;
  Duration _timeRemaining = Duration.zero;

  late AnimationController _fadeCtrl;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _challengeToken = widget.challenge.challengeToken;
    _email = widget.challenge.email;
    _expiresAt = widget.challenge.expiresAt;
    _syncTimeRemaining();
    _startTimer();

    _fadeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 450));
    _fade = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut));
    _fadeCtrl.forward();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otpController.dispose();
    _fadeCtrl.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(_syncTimeRemaining);
    });
  }

  void _syncTimeRemaining() {
    final expiresAt = _expiresAt;
    if (expiresAt == null) {
      _timeRemaining = Duration.zero;
      return;
    }
    final diff = expiresAt.difference(DateTime.now());
    _timeRemaining = diff.isNegative ? Duration.zero : diff;
  }

  Future<void> _handleVerify() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isVerifying = true;
      _errorMessage = null;
      _otpFieldError = null;
    });

    final success = await ref.read(authProvider.notifier).verifyLoginOtp(
      challengeToken: _challengeToken,
      otpCode: _otpController.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      context.go(AppRoutes.dashboard);
      return;
    }

    final authError = ref.read(authProvider).error;
    setState(() {
      _errorMessage = authError;
      _otpFieldError = authError;
      _isVerifying = false;
    });
  }

  Future<void> _handleResend() async {
    setState(() {
      _isResending = true;
      _errorMessage = null;
      _otpFieldError = null;
    });

    try {
      final challenge = await ref.read(authRepositoryProvider).resendLoginOtp(
        challengeToken: _challengeToken,
      );
      if (!mounted) return;
      setState(() {
        _challengeToken = challenge.challengeToken;
        _email = challenge.email;
        _expiresAt = challenge.expiresAt;
        _otpController.clear();
        _syncTimeRemaining();
      });
    } on AppException catch (e) {
      if (!mounted) return;
      setState(() => _errorMessage = _resolveErrorMessage(e));
    } catch (e) {
      if (!mounted) return;
      setState(() => _errorMessage = e.toString());
    } finally {
      if (mounted) setState(() => _isResending = false);
    }
  }

  String _resolveErrorMessage(AppException exception) {
    final errors = exception.errors;
    if (errors != null) {
      if (errors['otp_code'] is List &&
          (errors['otp_code'] as List).isNotEmpty) {
        return (errors['otp_code'] as List).first.toString();
      }
      for (final value in errors.values) {
        if (value is List && value.isNotEmpty) return value.first.toString();
        if (value is String && value.isNotEmpty) return value;
      }
    }
    return exception.message;
  }

  String _maskEmail(String email) {
    final parts = email.split('@');
    if (parts.length != 2) return email;
    final local = parts.first;
    final domain = parts.last;
    if (local.length <= 2) return '${local[0]}***@$domain';
    return '${local.substring(0, 2)}***@$domain';
  }

  String _formatRemaining(Duration duration) {
    final m = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final isBusy = _isVerifying || _isResending;
    final expired = _timeRemaining == Duration.zero && _expiresAt != null;

    return Scaffold(
      backgroundColor: _DS.bgPage,
      body: SafeArea(
        child: Center(
          child: FadeTransition(
            opacity: _fade,
            child: SlideTransition(
              position: _slide,
              child: SingleChildScrollView(
                padding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: Container(
                  width: 400,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 32, vertical: 36),
                  decoration: BoxDecoration(
                    // DS: bg card #120F0E dengan shadow dalam
                    color: _DS.bgCard,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: _DS.border, width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.7),
                        blurRadius: 40,
                        offset: const Offset(0, 16),
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // ── Back button ──
                        GestureDetector(
                          onTap: isBusy ? null : () => context.pop(),
                          child: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: _DS.white,
                            size: 18,
                          ),
                        ),

                        const SizedBox(height: 24),

                        // ── Title ──
                        const Text(
                          'Verify OTP',
                          style: TextStyle(
                            color: _DS.white,
                            fontSize: 28, // DS: Semi Bold / Title 1
                            fontWeight: FontWeight.w700,
                            fontFamily: _DS.fontFamily,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // ── Subtitle ──
                        Text(
                          'Enter the OTP code sent to ${_maskEmail(_email)}',
                          style: const TextStyle(
                            color: _DS.textSec,
                            fontSize: 14, // DS: Regular / Body 14px
                            fontFamily: _DS.fontFamily,
                            height: 1.55,
                          ),
                        ),

                        const SizedBox(height: 10),

                        // ── Timer ──
                        if (_expiresAt != null)
                          Row(
                            children: [
                              Icon(
                                expired
                                    ? Icons.timer_off_outlined
                                    : Icons.timer_outlined,
                                size: 14,
                                color: expired ? _DS.warning : _DS.textMuted,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                expired
                                    ? 'This OTP code has expired.'
                                    : 'Expires in ${_formatRemaining(_timeRemaining)}',
                                style: TextStyle(
                                  color:
                                  expired ? _DS.warning : _DS.textMuted,
                                  fontSize: 12,
                                  fontFamily: _DS.fontFamily,
                                ),
                              ),
                            ],
                          ),

                        // ── Error banner ──
                        if (_errorMessage != null) ...[
                          const SizedBox(height: 16),
                          _OtpErrorBanner(message: _errorMessage!),
                        ],

                        const SizedBox(height: 24),

                        // ── Divider ──
                        Container(height: 0.5, color: _DS.border),

                        const SizedBox(height: 24),

                        // ── Label ──
                        const Text(
                          'OTP CODE',
                          style: TextStyle(
                            color: _DS.textMuted,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            fontFamily: _DS.fontFamily,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // ── OTP field ──
                        TextFormField(
                          controller: _otpController,
                          enabled: !isBusy,
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.done,
                          onChanged: (_) {
                            if (_otpFieldError != null) {
                              setState(() => _otpFieldError = null);
                            }
                          },
                          onFieldSubmitted: (_) => _handleVerify(),
                          style: const TextStyle(
                            color: _DS.white,
                            fontFamily: _DS.fontFamily,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 6,
                          ),
                          decoration: InputDecoration(
                            hintText: '• • • • • •',
                            hintStyle: TextStyle(
                              color: _DS.textMuted.withOpacity(0.5),
                              fontFamily: _DS.fontFamily,
                              fontSize: 20,
                              letterSpacing: 6,
                            ),
                            errorText: _otpFieldError,
                            errorStyle: const TextStyle(
                              color: _DS.primary,
                              fontFamily: _DS.fontFamily,
                              fontSize: 11,
                            ),
                            // DS: input filled rgba(255,255,255,0.10)
                            filled: true,
                            fillColor:
                            const Color(0xFF0A0807), // subtle warm dark
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 16),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(4),
                              borderSide:
                              const BorderSide(color: _DS.border),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(4),
                              borderSide:
                              const BorderSide(color: _DS.border),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(4),
                              // DS: focus border #FFFFFF
                              borderSide: const BorderSide(
                                  color: _DS.borderFocus, width: 1),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(4),
                              borderSide:
                              const BorderSide(color: _DS.primary),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(4),
                              borderSide:
                              const BorderSide(color: _DS.primary),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'OTP code is required';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 24),

                        // ── Verify button ──
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: isBusy ? null : _handleVerify,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _DS.primary,
                              overlayColor: _DS.primaryHover,
                              disabledBackgroundColor: _DS.border,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            child: _isVerifying
                                ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: _DS.white,
                                strokeWidth: 2.2,
                              ),
                            )
                                : const Text(
                              'Verify OTP',
                              style: TextStyle(
                                color: _DS.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                fontFamily: _DS.fontFamily,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // ── Resend ──
                        Center(
                          child: TextButton(
                            onPressed: isBusy ? null : _handleResend,
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                            ),
                            child: _isResending
                                ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                color: _DS.primary,
                                strokeWidth: 2,
                              ),
                            )
                                : const Text(
                              'Resend OTP',
                              style: TextStyle(
                                color: _DS.primary,
                                fontFamily: _DS.fontFamily,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Error Banner ─────────────────────────────────────────────────────────────

class _OtpErrorBanner extends StatelessWidget {
  final String message;

  const _OtpErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        // DS: warm overlay dark
        color: _DS.warning.withOpacity(0.07),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: _DS.warning.withOpacity(0.30), width: 1),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: _DS.warning,
            size: 16,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: _DS.warning,
                fontSize: 12,
                fontFamily: _DS.fontFamily,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}