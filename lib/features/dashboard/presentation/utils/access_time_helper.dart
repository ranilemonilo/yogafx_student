import '../../data/models/dashboard_model.dart';

int calculateDisplayedAccessSeconds(
  AccessTimeSummary summary,
  DateTime now,
) {
  final totalSeconds = _nonNegative(summary.totalAccessDurationSeconds);
  final runningSeconds = _nonNegative(summary.runningTotalAccessDurationSeconds);

  if (summary.currentlyActive) {
    final startedAt = _tryParseDateTime(summary.activeSessionLoginAt);
    if (startedAt != null) {
      final elapsed = now.difference(startedAt).inSeconds;
      return (totalSeconds ?? 0) + (elapsed < 0 ? 0 : elapsed);
    }
  }

  if (runningSeconds != null) {
    return runningSeconds;
  }

  if (totalSeconds != null) {
    return totalSeconds;
  }

  return _parseFormattedDuration(summary.formattedTotal).inSeconds;
}

String formatAccessDuration(Duration duration) {
  final safeDuration = duration.isNegative ? Duration.zero : duration;
  final totalHours = safeDuration.inHours;
  final minutes = safeDuration.inMinutes.remainder(60);
  final seconds = safeDuration.inSeconds.remainder(60);

  return '${totalHours.toString().padLeft(2, '0')}:'
      '${minutes.toString().padLeft(2, '0')}:'
      '${seconds.toString().padLeft(2, '0')}';
}

Duration parseAccessDuration(String value) {
  return _parseFormattedDuration(value);
}

int? _nonNegative(int? value) {
  if (value == null) return null;
  return value < 0 ? 0 : value;
}

DateTime? _tryParseDateTime(String? value) {
  if (value == null || value.trim().isEmpty) return null;
  return DateTime.tryParse(value);
}

Duration _parseFormattedDuration(String value) {
  final parts = value.split(':');
  if (parts.length != 3) return Duration.zero;

  final hours = int.tryParse(parts[0]) ?? 0;
  final minutes = int.tryParse(parts[1]) ?? 0;
  final seconds = int.tryParse(parts[2]) ?? 0;

  return Duration(
    hours: hours < 0 ? 0 : hours,
    minutes: minutes < 0 ? 0 : minutes,
    seconds: seconds < 0 ? 0 : seconds,
  );
}
