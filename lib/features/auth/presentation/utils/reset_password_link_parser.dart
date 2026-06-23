import 'package:flutter/foundation.dart';

import '../../data/models/reset_password_link_data.dart';

class ResetPasswordLinkParser {
  static ResetPasswordLinkData? parse(String rawLink) {
    final uri = Uri.tryParse(rawLink.trim());
    if (uri == null) return null;

    final candidates = <Uri>[
      uri,
      ..._fragmentCandidates(uri),
    ];

    for (final candidate in candidates) {
      final parsed = _parseCandidate(candidate);
      if (parsed != null) return parsed;
    }

    return null;
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

  static ResetPasswordLinkData? _parseCandidate(Uri uri) {
    final token = _extractToken(uri);
    if (token == null) return null;

    final email = _extractEmail(uri);
    return ResetPasswordLinkData(
      token: token,
      email: email,
    );
  }

  static List<Uri> _fragmentCandidates(Uri uri) {
    final fragment = uri.fragment.trim();
    if (fragment.isEmpty) return const [];

    final normalized = fragment.startsWith('/') ? fragment : '/$fragment';
    final fragmentUri = Uri.tryParse(normalized);
    if (fragmentUri == null) return const [];

    return [
      fragmentUri,
      Uri(
        path: fragmentUri.path,
        query: fragmentUri.hasQuery ? fragmentUri.query : null,
      ),
    ];
  }

  static String? _extractToken(Uri uri) {
    final segments = uri.pathSegments;
    for (var index = 0; index < segments.length; index++) {
      final segment = segments[index];
      if (!_isResetSegment(segment)) continue;

      if (index + 1 < segments.length) {
        final nextSegment = segments[index + 1].trim();
        if (nextSegment.isNotEmpty) return nextSegment;
      }
    }

    for (final key in const ['token', 'reset_token']) {
      final value = uri.queryParameters[key]?.trim();
      if (value != null && value.isNotEmpty) {
        return value;
      }
    }

    return null;
  }

  static String? _extractEmail(Uri uri) {
    for (final key in const ['email', 'user', 'username']) {
      final value = uri.queryParameters[key]?.trim();
      if (value != null && value.isNotEmpty) {
        return value;
      }
    }

    return null;
  }

  static bool _isResetSegment(String segment) {
    final normalized = segment.trim().toLowerCase();
    return normalized == 'reset-password' ||
        normalized == 'password' ||
        normalized == 'reset' ||
        normalized == 'change';
  }
}
