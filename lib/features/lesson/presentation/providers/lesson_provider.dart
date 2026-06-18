import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/lesson_model.dart';
import '../../data/repositories/lesson_repository.dart';

final lessonRepositoryProvider = Provider<LessonRepository>((ref) {
  return LessonRepository();
});

final lessonDetailProvider =
FutureProvider.family<LessonDetail, int>((ref, lessonId) async {
  return ref.read(lessonRepositoryProvider).getLessonDetail(lessonId);
});