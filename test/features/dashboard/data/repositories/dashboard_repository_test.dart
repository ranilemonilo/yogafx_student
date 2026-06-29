import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:yogafx_student/core/error/app_exception.dart';
import 'package:yogafx_student/features/dashboard/data/models/dashboard_model.dart';
import 'package:yogafx_student/features/dashboard/data/repositories/dashboard_repository.dart';

class MockDio extends Mock implements Dio {}

void main() {
  late MockDio dio;
  late DashboardRepository repository;

  setUp(() {
    dio = MockDio();
    repository = DashboardRepository(dio: dio);
  });

  group('DashboardRepository', () {

  });
  Map<String, dynamic> dashboardJson() {
    return {
      'student': {
        'id': 1,
        'name': 'John Doe',
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
        'description': 'Learn Flutter',
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
    };
  }
  test('returns DashboardData when request succeeds', () async {
    when(() => dio.get('/dashboard')).thenAnswer(
          (_) async => Response(
        requestOptions: RequestOptions(path: '/dashboard'),
        data: {
          'data': dashboardJson(),
        },
      ),
    );

    final result = await repository.getDashboard();

    expect(result, isA<DashboardData>());
    expect(result.student.name, 'John Doe');
    expect(result.progressSummarySection.modulesCompleted, 8);
  });
  test('throws UnauthorizedException when API returns unauthorized', () async {
    when(() => dio.get('/dashboard')).thenThrow(
      DioException(
        requestOptions: RequestOptions(path: '/dashboard'),
        error: const UnauthorizedException(),
      ),
    );

    expect(
      repository.getDashboard,
      throwsA(isA<UnauthorizedException>()),
    );
  });
  test('throws ServerException when unknown server error occurs', () async {
    when(() => dio.get('/dashboard')).thenThrow(
      DioException(
        requestOptions: RequestOptions(path: '/dashboard'),
        error: const ServerException(),
      ),
    );

    expect(
      repository.getDashboard,
      throwsA(isA<ServerException>()),
    );
  });
  test('throws NetworkException when no internet connection', () async {
    when(() => dio.get('/dashboard')).thenThrow(
      DioException(
        requestOptions: RequestOptions(path: '/dashboard'),
        error: const NetworkException(),
      ),
    );

    expect(
      repository.getDashboard,
      throwsA(isA<NetworkException>()),
    );
  });
  test('throws ValidationException when validation fails', () async {
    when(() => dio.get('/dashboard')).thenThrow(
      DioException(
        requestOptions: RequestOptions(path: '/dashboard'),
        error: const ValidationException(
          message: 'Validation failed',
          errors: {},
        ),
      ),
    );

    expect(
      repository.getDashboard,
      throwsA(isA<ValidationException>()),
    );
  });
  test('normalizes relative thumbnail URLs', () async {
    final json = dashboardJson();

    json['continue_learning_section']['thumbnail_url'] =
    '/storage/continue/flutter.png';

    json['available_modules_section']['items'] = [
      {
        'id': 1,
        'title': 'Flutter',
        'url_slug': 'flutter',
        'lesson_count': 10,
        'completed_lessons': 5,
        'progress_percentage': 50,
        'show_progress': true,
        'status': 'ongoing',
        'status_label': 'In Progress',
        'cta_label': 'Continue',
        'thumbnail_url': '/storage/modules/flutter.png',
      }
    ];

    when(() => dio.get('/dashboard')).thenAnswer(
          (_) async => Response(
        requestOptions: RequestOptions(path: '/dashboard'),
        data: {
          'data': json,
        },
      ),
    );

    final result = await repository.getDashboard();

    expect(
      result.continueLearningSection.thumbnailUrl,
      startsWith('https://'),
    );

    expect(
      result.availableModulesSection.items.first.thumbnailUrl,
      startsWith('https://'),
    );
  });
}