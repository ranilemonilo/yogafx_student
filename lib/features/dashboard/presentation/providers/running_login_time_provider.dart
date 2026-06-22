import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'dashboard_provider.dart';
import '../utils/access_time_helper.dart';

final runningLoginTimeProvider = StateNotifierProvider<
    RunningLoginTimeController, AsyncValue<Duration>>((ref) {
  return RunningLoginTimeController(ref);
});

class RunningLoginTimeController extends StateNotifier<AsyncValue<Duration>> {
  final Ref ref;
  Timer? _timer;
  Duration _baseDuration = Duration.zero;
  DateTime? _startedAt;

  RunningLoginTimeController(this.ref) : super(const AsyncLoading()) {
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    try {
      final dashboard = await ref.read(dashboardProvider.future);
      final summary = dashboard.accessTimeSummary;
      final now = DateTime.now();
      final activeSessionStartedAt = DateTime.tryParse(
        summary.activeSessionLoginAt ?? '',
      );
      final canTickFromActiveSession =
          summary.currentlyActive && activeSessionStartedAt != null;

      if (canTickFromActiveSession) {
        final persistedSeconds = summary.totalAccessDurationSeconds ?? 0;
        _baseDuration = Duration(
          seconds: persistedSeconds < 0 ? 0 : persistedSeconds,
        );
        _startedAt = activeSessionStartedAt;
      } else {
        final displayedSeconds = calculateDisplayedAccessSeconds(summary, now);
        _baseDuration = Duration(seconds: displayedSeconds);
        _startedAt = null;
      }

      state = AsyncData(_currentDuration());

      if (canTickFromActiveSession) {
        _startTicker();
      }
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    }
  }

  void _startTicker() {
    _timer?.cancel();

    _timer = Timer.periodic(const Duration(seconds: 1), (_) async {
      state = AsyncData(_currentDuration());
    });
  }

  Duration _currentDuration() {
    if (_startedAt == null) return _baseDuration;
    return _baseDuration + DateTime.now().difference(_startedAt!);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
