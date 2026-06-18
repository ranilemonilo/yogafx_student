import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/course_model.dart';
import '../../data/repositories/course_repository.dart';

final courseRepositoryProvider = Provider<CourseRepository>((ref) {
  return CourseRepository();
});

final courseListProvider = FutureProvider<CourseListData>((ref) async {
  return ref.read(courseRepositoryProvider).getCourses();
});

final courseDetailProvider =
    FutureProvider.family<CourseItem, int>((ref, courseId) async {
  return ref.read(courseRepositoryProvider).getCourseDetail(courseId);
});
