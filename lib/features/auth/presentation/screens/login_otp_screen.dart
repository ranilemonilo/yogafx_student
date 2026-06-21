import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/error/app_exception.dart';
import '../../../../core/router/app_router.dart';
import '../../data/repositories/auth_repository.dart';
import '../providers/auth_provider.dart';

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

class LoginOtpScreen extends ConsumerStatefulWidget {
  final LoginOtpScreenArgs challenge;

  const LoginOtpScreen({
    super.key,
    required this.challenge,
  });

  @override
  ConsumerState<LoginOtpScreen> createState() => _LoginOtpScreenState();
}

class _LoginOtpScreenState extends ConsumerState<LoginOtpScreen> {
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

  @override
  void initState() {
    super.initState();
    _challengeToken = widget.challenge.challengeToken;
    _email = widget.challenge.email;
    _expiresAt = widget.challenge.expiresAt;
    _syncTimeRemaining();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otpController.dispose();
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
      setState(() {
        _errorMessage = _resolveErrorMessage(e);
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isResending = false;
        });
      }
    }
  }

  String _resolveErrorMessage(AppException exception) {
    final errors = exception.errors;
    if (errors != null) {
      if (errors['otp_code'] is List && (errors['otp_code'] as List).isNotEmpty) {
        return (errors['otp_code'] as List).first.toString();
      }

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

  String _maskEmail(String email) {
    final parts = email.split('@');
    if (parts.length != 2) return email;

    final local = parts.first;
    final domain = parts.last;
    if (local.length <= 2) {
      return '${local[0]}***@$domain';
    }

    return '${local.substring(0, 2)}***@$domain';
  }

  String _formatRemaining(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final isBusy = _isVerifying || _isResending;

    return Scaffold(
      backgroundColor: const Color(0xFF141414),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Container(
              width: 400,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 36),
              decoration: BoxDecoration(
                color: const Color(0xE6000000),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: isBusy ? null : () => context.pop(),
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Verify OTP',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Enter the OTP code sent to ${_maskEmail(_email)}',
                      style: const TextStyle(
                        color: Color(0xFFB3B3B3),
                        fontSize: 13,
                        fontFamily: 'Montserrat',
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (_expiresAt != null)
                      Text(
                        _timeRemaining > Duration.zero
                            ? 'Code expires in ${_formatRemaining(_timeRemaining)}'
                            : 'This OTP code has expired.',
                        style: TextStyle(
                          color: _timeRemaining > Duration.zero
                              ? const Color(0xFF808080)
                              : const Color(0xFFE87C03),
                          fontSize: 12,
                          fontFamily: 'Montserrat',
                        ),
                      ),
                    if (_errorMessage != null) ...[
                      const SizedBox(height: 20),
                      _OtpErrorBanner(message: _errorMessage!),
                    ],
                    const SizedBox(height: 24),
                    const Text(
                      'OTP CODE',
                      style: TextStyle(
                        color: Color(0xFFB3B3B3),
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Montserrat',
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
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
                        color: Colors.white,
                        fontFamily: 'Montserrat',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 4,
                      ),
                      decoration: InputDecoration(
                        hintText: '123456',
                        hintStyle: const TextStyle(
                          color: Color(0xFF555555),
                          fontFamily: 'Montserrat',
                          letterSpacing: 4,
                        ),
                        errorText: _otpFieldError,
                        filled: true,
                        fillColor: const Color(0xFF1C1C1C),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4),
                          borderSide: const BorderSide(color: Color(0xFF2A2A2A)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4),
                          borderSide: const BorderSide(color: Color(0xFF2A2A2A)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4),
                          borderSide: const BorderSide(color: Color(0xFFE50914)),
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
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: isBusy ? null : _handleVerify,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE50914),
                          disabledBackgroundColor: const Color(0xFF2A2A2A),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        child: _isVerifying
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.2,
                                ),
                              )
                            : const Text(
                                'Verify OTP',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  fontFamily: 'Montserrat',
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: TextButton(
                        onPressed: isBusy ? null : _handleResend,
                        child: _isResending
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  color: Color(0xFFE50914),
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Resend OTP',
                                style: TextStyle(
                                  color: Color(0xFFE50914),
                                  fontFamily: 'Montserrat',
                                  fontWeight: FontWeight.w600,
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
    );
  }
}

class _OtpErrorBanner extends StatelessWidget {
  final String message;

  const _OtpErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
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
          const Icon(
            Icons.error_outline_rounded,
            color: Color(0xFFE87C03),
            size: 18,
          ),
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
