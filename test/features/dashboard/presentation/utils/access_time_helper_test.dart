import 'package:flutter_test/flutter_test.dart';
import 'package:yogafx_student/features/dashboard/presentation/utils/access_time_helper.dart';
import 'package:yogafx_student/features/dashboard/data/models/dashboard_model.dart';

void main() {
  group('formatAccessDuration', () {
    test('returns 00:00:00 for zero duration', () {
      expect(
        formatAccessDuration(Duration.zero),
        '00:00:00',
      );
    });

    test('formats 1 hour 1 minute 1 second correctly', () {
      expect(
        formatAccessDuration(
          const Duration(
            hours: 1,
            minutes: 1,
            seconds: 1,
          ),
        ),
        '01:01:01',
      );
    });

    test('formats only seconds correctly', () {
      expect(
        formatAccessDuration(
          const Duration(seconds: 59),
        ),
        '00:00:59',
      );
    });

    test('formats only minutes correctly', () {
      expect(
        formatAccessDuration(
          const Duration(minutes: 1),
        ),
        '00:01:00',
      );
    });

    test('negative duration becomes zero', () {
      expect(
        formatAccessDuration(
          const Duration(seconds: -5),
        ),
        '00:00:00',
      );
    });
  });
  group('parseAccessDuration', () {
    test('parses 00:00:00 correctly', () {
      expect(
        parseAccessDuration('00:00:00'),
        Duration.zero,
      );
    });

    test('parses 01:01:01 correctly', () {
      expect(
        parseAccessDuration('01:01:01'),
        const Duration(
          hours: 1,
          minutes: 1,
          seconds: 1,
        ),
      );
    });

    test('returns zero for invalid format', () {
      expect(
        parseAccessDuration('abc'),
        Duration.zero,
      );
    });

    test('returns zero for empty string', () {
      expect(
        parseAccessDuration(''),
        Duration.zero,
      );
    });

    test('negative values become zero', () {
      expect(
        parseAccessDuration('-1:-5:-9'),
        Duration.zero,
      );
    });
  });
  group('calculateDisplayedAccessSeconds', () {
    test('returns total + elapsed when user is currently active', () {
      final now = DateTime(2026, 1, 1, 12, 0, 0);

      final summary = AccessTimeSummary(
        formattedTotal: '00:00:00',
        totalAccessDurationSeconds: 100,
        runningTotalAccessDurationSeconds: null,
        activeSessionLoginAt: '2026-01-01T11:59:30',
        lastVisitAt: null,
        currentlyActive: true,
      );

      expect(
        calculateDisplayedAccessSeconds(summary, now),
        130,
      );
    });

    test('returns running total when user is not active', () {
      final summary = AccessTimeSummary(
        formattedTotal: '00:00:00',
        totalAccessDurationSeconds: 100,
        runningTotalAccessDurationSeconds: 250,
        activeSessionLoginAt: null,
        lastVisitAt: null,
        currentlyActive: false,
      );

      expect(
        calculateDisplayedAccessSeconds(summary, DateTime.now()),
        250,
      );
    });

    test('returns total access duration when running total is null', () {
      final summary = AccessTimeSummary(
        formattedTotal: '00:00:00',
        totalAccessDurationSeconds: 180,
        runningTotalAccessDurationSeconds: null,
        activeSessionLoginAt: null,
        lastVisitAt: null,
        currentlyActive: false,
      );

      expect(
        calculateDisplayedAccessSeconds(summary, DateTime.now()),
        180,
      );
    });

    test('falls back to formatted duration', () {
      final summary = AccessTimeSummary(
        formattedTotal: '01:02:03',
        totalAccessDurationSeconds: null,
        runningTotalAccessDurationSeconds: null,
        activeSessionLoginAt: null,
        lastVisitAt: null,
        currentlyActive: false,
      );

      expect(
        calculateDisplayedAccessSeconds(summary, DateTime.now()),
        3723,
      );
    });
  });
}