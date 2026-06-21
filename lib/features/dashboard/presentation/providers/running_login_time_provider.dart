import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/storage/secure_storage.dart';
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
  String? _storageKey;
  int _tickCount = 0;

  RunningLoginTimeController(this.ref) : super(const AsyncLoading()) {
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    try {
      final dashboard = await ref.read(dashboardProvider.future);
      final summary = dashboard.accessTimeSummary;
      final backendDuration = _parseDuration(summary.formattedTotal);
      _storageKey = 'total_access_duration_user_${dashboard.student.id}';
      final persistedDuration = await _readPersistedDuration();

      _baseDuration = backendDuration >= persistedDuration
          ? backendDuration
          : persistedDuration;
      _startedAt = summary.currentlyActive ? DateTime.now() : null;

      state = AsyncData(_currentDuration());
      await _persistCurrentDuration();

      if (summary.currentlyActive) {
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

      _tickCount++;
      if (_tickCount % 10 == 0) {
        await _persistCurrentDuration();
      }
    });
  }

  Duration _currentDuration() {
    if (_startedAt == null) return _baseDuration;
    return _baseDuration + DateTime.now().difference(_startedAt!);
  }

  Future<Duration> _readPersistedDuration() async {
    final key = _storageKey;
    if (key == null) return Duration.zero;

    final storedValue = await SecureStorageService.readValue(key);
    final storedSeconds = int.tryParse(storedValue ?? '');
    if (storedSeconds == null || storedSeconds < 0) {
      return Duration.zero;
    }

    return Duration(seconds: storedSeconds);
  }

  Future<void> _persistCurrentDuration() async {
    final key = _storageKey;
    if (key == null) return;

    await SecureStorageService.writeValue(
      key,
      _currentDuration().inSeconds.toString(),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    unawaited(_persistCurrentDuration());
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
