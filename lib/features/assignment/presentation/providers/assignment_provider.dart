import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/assignment_model.dart';
import '../../data/repositories/assignment_repository.dart';

final assignmentRepositoryProvider = Provider<AssignmentRepository>((ref) {
  return AssignmentRepository();
});

final assignmentDetailProvider =
    FutureProvider.family<AssignmentDetail, int>((ref, assignmentId) async {
  return ref.read(assignmentRepositoryProvider).getAssignmentDetail(assignmentId);
});
