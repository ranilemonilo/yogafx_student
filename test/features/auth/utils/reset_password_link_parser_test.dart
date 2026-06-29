import 'package:flutter_test/flutter_test.dart';
import 'package:yogafx_student/features/auth/data/models/reset_password_link_data.dart';
import 'package:yogafx_student/features/auth/presentation/utils/reset_password_link_parser.dart';

void main() {
  group('ResetPasswordLinkParser.parse', () {
    test('parses token from path', () {
      final result = ResetPasswordLinkParser.parse(
        'https://example.com/reset-password/abc123',
      );

      expect(result, isNotNull);
      expect(result!.token, 'abc123');
      expect(result.email, isNull);
    });

    test('parses token from query parameter', () {
      final result = ResetPasswordLinkParser.parse(
        'https://example.com/reset-password?token=abc123',
      );

      expect(result, isNotNull);
      expect(result!.token, 'abc123');
    });

    test('parses email when provided', () {
      final result = ResetPasswordLinkParser.parse(
        'https://example.com/reset-password?token=abc123&email=user@example.com',
      );

      expect(result, isNotNull);
      expect(result!.token, 'abc123');
      expect(result.email, 'user@example.com');
    });

    test('supports hash route', () {
      final result = ResetPasswordLinkParser.parse(
        'https://example.com/#/reset-password/abc123',
      );

      expect(result, isNotNull);
      expect(result!.token, 'abc123');
    });

    test('trims whitespace', () {
      final result = ResetPasswordLinkParser.parse(
        '   https://example.com/reset-password/abc123   ',
      );

      expect(result, isNotNull);
      expect(result!.token, 'abc123');
    });

    test('returns null for empty string', () {
      expect(
        ResetPasswordLinkParser.parse(''),
        isNull,
      );
    });

    test('returns null when token does not exist', () {
      expect(
        ResetPasswordLinkParser.parse(
          'https://example.com/login',
        ),
        isNull,
      );
    });
  });

  group('ResetPasswordLinkParser.buildAppRoute', () {
    test('builds route without email', () {
      final route = ResetPasswordLinkParser.buildAppRoute(
        const ResetPasswordLinkData(
          token: 'abc123',
          email: null,
        ),
      );

      expect(route, '/reset-password/abc123');
    });

    test('builds route with email', () {
      final route = ResetPasswordLinkParser.buildAppRoute(
        const ResetPasswordLinkData(
          token: 'abc123',
          email: 'user@example.com',
        ),
      );

      expect(
        route,
        '/reset-password/abc123?email=user%40example.com',
      );
    });
  });

  group('ResetPasswordLinkParser.isResetPasswordLink', () {
    test('returns true for valid reset link', () {
      expect(
        ResetPasswordLinkParser.isResetPasswordLink(
          'https://example.com/reset-password/abc123',
        ),
        isTrue,
      );
    });

    test('returns false for invalid link', () {
      expect(
        ResetPasswordLinkParser.isResetPasswordLink(
          'https://example.com/login',
        ),
        isFalse,
      );
    });

    test('returns false for empty string', () {
      expect(
        ResetPasswordLinkParser.isResetPasswordLink(''),
        isFalse,
      );
    });
  });
}