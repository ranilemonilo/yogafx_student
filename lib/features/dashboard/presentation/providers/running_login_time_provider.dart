import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'dashboard_provider.dart';

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

      _baseDuration = _parseDuration(summary.formattedTotal);
      _startedAt = DateTime.now();

      state = AsyncData(_currentDuration());
      _startTicker();
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    }
  }

  void _startTicker() {
    _timer?.cancel();

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
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

Duration _parseDuration(String value) {
  final parts = value.split(':');
  if (parts.length != 3) return Duration.zero;

  final hours = int.tryParse(parts[0]) ?? 0;
  final minutes = int.tryParse(parts[1]) ?? 0;
  final seconds = int.tryParse(parts[2]) ?? 0;

  return Duration(
    hours: hours,
    minutes: minutes,
    seconds: seconds,
  );
}
