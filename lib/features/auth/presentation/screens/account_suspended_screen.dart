import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/app_theme.dart';
import '../../data/models/support_contact.dart';
import '../../data/repositories/support_contact_repository.dart';
import '../providers/auth_provider.dart';

final supportContactRepositoryProvider = Provider<SupportContactRepository>((ref) {
  return SupportContactRepository();
});

final supportContactProvider = FutureProvider<SupportContact>((ref) async {
  return ref.read(supportContactRepositoryProvider).fetchSupportContact();
});

class AccountSuspendedScreen extends ConsumerWidget {
  const AccountSuspendedScreen({super.key});

  Future<void> _openSupport(
    ScaffoldMessengerState messenger,
    Uri uri,
  ) async {
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Unable to open the support application.'),
        ),
      );
    }
  }

  Uri _buildWhatsAppAppUri(String? whatsapp) {
    final number = _normalizeWhatsAppNumber(whatsapp);
    if (number == null || number.isEmpty) {
      return Uri.parse(
        'whatsapp://send?text=Hello%20YogaFX%20Support%2C%20I%20need%20help%20with%20my%20temporarily%20suspended%20account.',
      );
    }

    return Uri.parse(
      'whatsapp://send?phone=$number&text=Hello%20YogaFX%20Support%2C%20I%20need%20help%20with%20my%20temporarily%20suspended%20account.',
    );
  }

  Uri _buildWhatsAppWebUri(String? whatsapp) {
    final number = _normalizeWhatsAppNumber(whatsapp);
    if (number == null || number.isEmpty) {
      return Uri.parse(
        'https://wa.me/?text=Hello%20YogaFX%20Support%2C%20I%20need%20help%20with%20my%20temporarily%20suspended%20account.',
      );
    }

    return Uri.parse(
      'https://wa.me/$number?text=Hello%20YogaFX%20Support%2C%20I%20need%20help%20with%20my%20temporarily%20suspended%20account.',
    );
  }

  Uri _buildFallbackWhatsAppUri() {
    return Uri.parse(
      'https://wa.me/?text=Hello%20YogaFX%20Support%2C%20I%20need%20help%20with%20my%20temporarily%20suspended%20account.',
    );
  }

  String? _normalizeWhatsAppNumber(String? value) {
    final digitsOnly = value?.replaceAll(RegExp(r'[^0-9]'), '');
    if (digitsOnly == null || digitsOnly.isEmpty) {
      return null;
    }

    if (digitsOnly.startsWith('0')) {
      return '62${digitsOnly.substring(1)}';
    }

    return digitsOnly;
  }

  Uri _buildEmailUri(String? email) {
    return Uri(
      scheme: 'mailto',
      path: email ?? '',
      queryParameters: {
        'subject': 'YogaFX suspended account assistance',
        'body':
            'Hello YogaFX Support,\n\nI need help with my temporarily suspended account.',
      },
    );
  }

  Future<void> _openWhatsApp(BuildContext context, String? whatsapp) async {
    final appUri = _buildWhatsAppAppUri(whatsapp);
    final webUri =
        whatsapp == null ? _buildFallbackWhatsAppUri() : _buildWhatsAppWebUri(whatsapp);
    final messenger = ScaffoldMessenger.of(context);

    if (await canLaunchUrl(appUri)) {
      await _openSupport(messenger, appUri);
      return;
    }

    await _openSupport(messenger, webUri);
  }

  Future<void> _openEmail(BuildContext context, String? email) async {
    final emailUri = _buildEmailUri(email ?? 'support@26and2yoga.com');
    final messenger = ScaffoldMessenger.of(context);

    if (await canLaunchUrl(emailUri)) {
      await _openSupport(messenger, emailUri);
      return;
    }

    messenger.showSnackBar(
      const SnackBar(
        content: Text('No email app found on this device.'),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref, {
    required String? whatsapp,
    required String? email,
  }) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.topCenter,
              radius: 1.15,
              colors: [Color(0xFF1A1616), AppColors.background],
            ),
          ),
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 560),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 38,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0xFF211F1F), Color(0xFF121212)],
                      ),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFF343131)),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x99000000),
                          blurRadius: 32,
                          offset: Offset(0, 18),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 66,
                          height: 66,
                          decoration: BoxDecoration(
                            color: const Color(0xFF5A202A),
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0xFF8A3542)),
                          ),
                          child: const Icon(
                            Icons.priority_high_rounded,
                            color: Color(0xFFFFDDE2),
                            size: 31,
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'ACCOUNT SUSPENDED',
                          style: TextStyle(
                            color: Color(0xFFD9A6AE),
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 2.1,
                          ),
                        ),
                        const SizedBox(height: 14),
                        const Text(
                          'Your YogaFX account is\ntemporarily suspended',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 28,
                            height: 1.12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 18),
                        const Text(
                          'Dear Student, Please be advised that we have detected irregular activity on the platform and for security purposes, the account is temporarily blocked. Please contact us for more support, information, and assistance. Thank you, YogaFX IT Support.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                            height: 1.8,
                          ),
                        ),
                        const SizedBox(height: 26),
                        Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            _SupportButton(
                              label: 'Chat WhatsApp',
                              icon: Icons.chat_bubble_outline_rounded,
                              color: const Color(0xFF08A94E),
                              onPressed: () => _openWhatsApp(context, whatsapp),
                            ),
                            _SupportButton(
                              label: 'Send Email',
                              icon: Icons.mail_outline_rounded,
                              color: const Color(0xFF2864DE),
                              onPressed: () => _openEmail(context, email),
                            ),
                            _SupportButton(
                              label: 'Logout',
                              icon: Icons.logout_rounded,
                              color: AppColors.primary,
                              onPressed: () => ref
                                  .read(authProvider.notifier)
                                  .leaveBlockedSession(),
                            ),
                          ],
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final supportContactAsync = ref.watch(supportContactProvider);

    return supportContactAsync.when(
      data: (contact) => _buildContent(
        context,
        ref,
        whatsapp: contact.whatsapp,
        email: contact.email,
      ),
      loading: () => _buildContent(
        context,
        ref,
        whatsapp: null,
        email: null,
      ),
      error: (error, stackTrace) {
        return _buildContent(
          context,
          ref,
          whatsapp: null,
          email: null,
        );
      },
    );
  }

}

class _SupportButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback? onPressed;

  const _SupportButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 17),
      label: Text(label),
      style: FilledButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        disabledBackgroundColor: color.withValues(alpha: 0.45),
        disabledForegroundColor: Colors.white.withValues(alpha: 0.7),
        minimumSize: const Size(0, 42),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        textStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
