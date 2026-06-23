import 'package:flutter_test/flutter_test.dart';
import 'package:yogafx_student/features/auth/presentation/utils/reset_password_link_parser.dart';

void main() {
  group('ResetPasswordLinkParser', () {
    test('parses legacy path-based reset link', () {
      final result = ResetPasswordLinkParser.parse(
        'https://example.com/reset-password/abc123?email=user@example.com',
      );

      expect(result, isNotNull);
      expect(result!.token, 'abc123');
      expect(result.email, 'user@example.com');
    });

    test('parses website link with token in query string', () {
      final result = ResetPasswordLinkParser.parse(
        'https://example.com/reset-password?token=abc123&email=user@example.com',
      );

      expect(result, isNotNull);
      expect(result!.token, 'abc123');
      expect(result.email, 'user@example.com');
    });

    test('parses password reset link from nested web route', () {
      final result = ResetPasswordLinkParser.parse(
        'https://example.com/password/reset/abc123?email=user@example.com',
      );

      expect(result, isNotNull);
      expect(result!.token, 'abc123');
      expect(result.email, 'user@example.com');
    });

    test('parses reset link from hash-based web route', () {
      final result = ResetPasswordLinkParser.parse(
        'https://example.com/#/reset-password/abc123?email=user@example.com',
      );

      expect(result, isNotNull);
      expect(result!.token, 'abc123');
      expect(result.email, 'user@example.com');
    });
  });
}
