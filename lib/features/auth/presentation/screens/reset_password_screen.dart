import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/error/app_exception.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/auth_provider.dart';

class ResetPasswordScreen extends ConsumerStatefulWidget {
  final String? token;
  final String? initialEmail;

  const ResetPasswordScreen({
    super.key,
    this.token,
    this.initialEmail,
  });

  @override
  ConsumerState<ResetPasswordScreen> createState() =>
      _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final _forgotFormKey = GlobalKey<FormState>();
  final _resetFormKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmationController = TextEditingController();

  bool _submitting = false;
  bool _obscurePassword = true;
  bool _obscurePasswordConfirmation = true;
  bool _forgotSuccess = false;
  String? _generalError;
  String? _emailError;
  String? _passwordError;
  String? _passwordConfirmationError;
  bool _isHandlingBackNavigation = false;

  bool get _isResetMode => widget.token != null && widget.token!.trim().isNotEmpty;

  Future<void> _handleBackToLogin() async {
    if (_isHandlingBackNavigation || !mounted) return;
    _isHandlingBackNavigation = true;
    FocusManager.instance.primaryFocus?.unfocus();
    context.go(AppRoutes.login);
  }

  @override
  void initState() {
    super.initState();
    if (widget.initialEmail != null) {
      _emailController.text = widget.initialEmail!;
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _passwordConfirmationController.dispose();
    super.dispose();
  }

  Future<void> _submitForgotPassword() async {
    if (!_forgotFormKey.currentState!.validate()) return;

    setState(() {
      _submitting = true;
      _forgotSuccess = false;
      _clearErrors();
    });

    try {
      await ref.read(authRepositoryProvider).forgotPassword(
            email: _emailController.text.trim(),
          );
      if (!mounted) return;
      setState(() {
        _forgotSuccess = true;
      });
    } on AppException catch (e) {
      if (!mounted) return;
      setState(() {
        _applyErrors(e);
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _generalError = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _submitting = false;
        });
      }
    }
  }

  Future<void> _submitResetPassword() async {
    if (!_resetFormKey.currentState!.validate()) return;

    final token = widget.token;
    if (token == null || token.trim().isEmpty) {
      setState(() {
        _generalError =
            'Reset link is incomplete. Please request a new password reset email.';
      });
      return;
    }

    setState(() {
      _submitting = true;
      _clearErrors();
    });

    try {
      await ref.read(authRepositoryProvider).resetPassword(
            token: token,
            email: _emailController.text.trim(),
            password: _passwordController.text,
            passwordConfirmation: _passwordConfirmationController.text,
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Password reset successful. Please sign in.'),
          ),
        );
      context.go(AppRoutes.login);
    } on AppException catch (e) {
      if (!mounted) return;
      setState(() {
        _applyErrors(e);
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _generalError = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _submitting = false;
        });
      }
    }
  }

  void _clearErrors() {
    _generalError = null;
    _emailError = null;
    _passwordError = null;
    _passwordConfirmationError = null;
  }

  void _applyErrors(AppException exception) {
    final errors = exception.errors;
    _generalError = exception.message;

    if (errors == null) return;

    _emailError = _firstError(errors['email']);
    _passwordError = _firstError(errors['password']);
    _passwordConfirmationError =
        _firstError(errors['password_confirmation']);
    _generalError = _firstNonFieldError(errors) ?? exception.message;
  }

  String? _firstNonFieldError(Map<String, dynamic> errors) {
    final prioritized = [
      'token',
      'reset',
      'message',
    ];

    for (final key in prioritized) {
      final value = errors[key];
      final message = _firstError(value);
      if (message != null && message.isNotEmpty) {
        return message;
      }
    }

    for (final entry in errors.entries) {
      final message = _firstError(entry.value);
      if (message != null && message.isNotEmpty) {
        return message;
      }
    }

    return null;
  }

  String? _firstError(dynamic value) {
    if (value is List && value.isNotEmpty) {
      return value.first.toString();
    }
    if (value is String && value.isNotEmpty) {
      return value;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        await _handleBackToLogin();
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          leading: IconButton(
            onPressed: _submitting ? null : _handleBackToLogin,
            icon: const Icon(Icons.arrow_back_rounded),
          ),
          title: Text(_isResetMode ? 'Set New Password' : 'Forgot Password'),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: _isResetMode ? _buildResetForm() : _buildForgotForm(),
        ),
      ),
    );
  }

  Widget _buildForgotForm() {
    return Form(
      key: _forgotFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Enter your student email. We will send a password reset link to your email address.',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              fontFamily: 'Montserrat',
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: 'Email',
              errorText: _emailError,
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Email is required';
              }
              if (!value.contains('@')) {
                return 'Enter a valid email';
              }
              return null;
            },
          ),
          if (_forgotSuccess) ...[
            const SizedBox(height: 16),
            const _SuccessBanner(
              message:
                  'Check your email for a password reset link. Open it on this device to continue natively in the app.',
            ),
          ],
          if (_generalError != null) ...[
            const SizedBox(height: 16),
            _ErrorBanner(message: _generalError!),
          ],
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _submitting ? null : _submitForgotPassword,
            child: Text(_submitting ? 'Sending...' : 'Send Reset Link'),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: _submitting ? null : _handleBackToLogin,
            child: const Text('Back to login'),
          ),
        ],
      ),
    );
  }

  Widget _buildResetForm() {
    final hasEmailFromLink =
        widget.initialEmail != null && widget.initialEmail!.trim().isNotEmpty;

    return Form(
      key: _resetFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            hasEmailFromLink
                ? 'Set a new password for ${widget.initialEmail}.'
                : 'Set a new password using your reset link. If the email is missing, enter the same email address used for the reset request.',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              fontFamily: 'Montserrat',
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: 'Email',
              errorText: _emailError,
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Email is required';
              }
              if (!value.contains('@')) {
                return 'Enter a valid email';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            decoration: InputDecoration(
              labelText: 'New Password',
              errorText: _passwordError,
              suffixIcon: IconButton(
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'New password is required';
              }
              if (value.length < 6) {
                return 'Password must be at least 6 characters';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _passwordConfirmationController,
            obscureText: _obscurePasswordConfirmation,
            decoration: InputDecoration(
              labelText: 'Confirm New Password',
              errorText: _passwordConfirmationError,
              suffixIcon: IconButton(
                onPressed: () {
                  setState(() {
                    _obscurePasswordConfirmation =
                        !_obscurePasswordConfirmation;
                  });
                },
                icon: Icon(
                  _obscurePasswordConfirmation
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Password confirmation is required';
              }
              if (value != _passwordController.text) {
                return 'Password confirmation does not match';
              }
              return null;
            },
          ),
          if (_generalError != null) ...[
            const SizedBox(height: 16),
            _ErrorBanner(message: _generalError!),
          ],
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _submitting ? null : _submitResetPassword,
            child: Text(_submitting ? 'Saving...' : 'Reset Password'),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: _submitting ? null : _handleBackToLogin,
            child: const Text('Back to login'),
          ),
        ],
      ),
    );
  }
}

class _SuccessBanner extends StatelessWidget {
  final String message;

  const _SuccessBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.success.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: AppColors.success.withOpacity(0.24),
          width: 0.8,
        ),
      ),
      child: Text(
        message,
        style: const TextStyle(
          color: AppColors.success,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          fontFamily: 'Montserrat',
          height: 1.5,
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;

  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: AppColors.error.withOpacity(0.24),
          width: 0.8,
        ),
      ),
      child: Text(
        message,
        style: const TextStyle(
          color: AppColors.error,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          fontFamily: 'Montserrat',
          height: 1.5,
        ),
      ),
    );
  }
}
