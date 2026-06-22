import 'package:flutter/foundation.dart';

import '../../data/models/reset_password_link_data.dart';

class ResetPasswordLinkParser {
  static ResetPasswordLinkData? parse(String rawLink) {
    final uri = Uri.tryParse(rawLink.trim());
    if (uri == null) return null;

    final segments = uri.pathSegments;
    final resetIndex = segments.indexOf('reset-password');
    if (resetIndex == -1 || resetIndex + 1 >= segments.length) {
      return null;
    }

    final token = segments[resetIndex + 1].trim();
    if (token.isEmpty) return null;

    final email = uri.queryParameters['email']?.trim();
    return ResetPasswordLinkData(
      token: token,
      email: email != null && email.isNotEmpty ? email : null,
    );
  }

  static String buildAppRoute(ResetPasswordLinkData data) {
    final token = Uri.encodeComponent(data.token);
    final email = data.email != null && data.email!.isNotEmpty
        ? '?email=${Uri.encodeQueryComponent(data.email!)}'
        : '';
    return '/reset-password/$token$email';
  }

  static bool isResetPasswordLink(String rawLink) {
    return parse(rawLink) != null;
  }

  static void debugPrintInvalid(String rawLink) {
    debugPrint('Unable to parse reset password link: $rawLink');
  }
}
