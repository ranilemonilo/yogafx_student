import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';

import 'package:yogafx_student/core/error/app_exception.dart';
import 'package:yogafx_student/features/dashboard/data/models/dashboard_model.dart';
import 'package:yogafx_student/features/dashboard/data/repositories/dashboard_repository.dart';
import 'package:yogafx_student/features/dashboard/presentation/providers/dashboard_provider.dart';

class MockDashboardRepository extends Mock
    implements DashboardRepository {}
DashboardData createDashboard() {
  return DashboardData.fromJson({
    'student': {
      'id': 1,
      'name': 'John',
      'email': 'john@test.com',
      'first_name': 'John',
      'access_tier': {
        'id': 1,
        'name': 'Premium',
        'slug': 'premium',
      }
    },
    'continue_learning_section': {
      'state': 'active',
      'eyebrow': 'Continue',
      'title': 'Flutter',
      'description': 'Learn',
      'progress_percentage': 80,
      'cta_label': 'Continue',
      'thumbnail_url': null,
      'lesson': null,
      'module': null,
      'status': 'ongoing',
    },
    'progress_summary_section': {
      'state': 'active',
      'eyebrow': 'Progress',
      'title': 'Overall',
      'overall_progress_percentage': 80,
      'modules_completed': 8,
      'modules_total': 10,
      'lessons_completed': 40,
      'lessons_total': 50,
      'status': 'good',
    },
    'available_modules_section': {
      'state': 'available',
      'eyebrow': 'Modules',
      'title': 'Modules',
      'items': [],
    },
    'certificate_milestone': {
      'state': 'eligible',
      'eyebrow': 'Certificate',
      'title': 'Certificate',
      'status': 'ready',
      'eligibility_label': 'Eligible',
      'cta_label': 'Download',
      'milestones': [],
    },
    'access_time_summary': {
      'formatted_total_access_duration': '00:00:00',
      'currently_active': false,
    }
  });
}
void main() {
  late MockDashboardRepository repository;

  setUp(() {
    repository = MockDashboardRepository();
  });

  test('dashboardProvider returns dashboard data', () async {
    when(() => repository.getDashboard())
        .thenAnswer((_) async => createDashboard());

    final container = ProviderContainer(
      overrides: [
        dashboardRepositoryProvider.overrideWithValue(repository),
      ],
    );

    final result = await container.read(dashboardProvider.future);

    expect(result.student.name, 'John');

    verify(() => repository.getDashboard()).called(1);
  });
  test('dashboardProvider returns error when repository fails', () async {
    when(() => repository.getDashboard())
        .thenThrow(const ServerException());

    final container = ProviderContainer(
      overrides: [
        dashboardRepositoryProvider.overrideWithValue(repository),
      ],
    );

    expect(
      container.read(dashboardProvider.future),
      throwsA(isA<ServerException>()),
    );

    verify(() => repository.getDashboard()).called(1);
  });
  test('dashboardProvider calls repository once', () async {
    when(() => repository.getDashboard())
        .thenAnswer((_) async => createDashboard());

    final container = ProviderContainer(
      overrides: [
        dashboardRepositoryProvider.overrideWithValue(repository),
      ],
    );

    await container.read(dashboardProvider.future);

    verify(() => repository.getDashboard()).called(1);

    verifyNoMoreInteractions(repository);
  });
}
