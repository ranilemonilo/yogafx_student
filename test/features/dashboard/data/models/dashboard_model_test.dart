import 'package:flutter_test/flutter_test.dart';
import 'package:yogafx_student/features/dashboard/data/models/dashboard_model.dart';

void main() {
  group('AccessTimeSummary.fromJson', () {
    test('parses complete JSON correctly', () {
      final json = {
        'formatted_total_access_duration': '01:20:30',
        'total_access_duration_seconds': 4830,
        'running_total_access_duration_seconds': 5000,
        'active_session_login_at': '2026-06-27T10:00:00Z',
        'last_visit_at': '2026-06-26T10:00:00Z',
        'currently_active': true,
      };

      final model = AccessTimeSummary.fromJson(json);

      expect(model.formattedTotal, '01:20:30');
      expect(model.totalAccessDurationSeconds, 4830);
      expect(model.runningTotalAccessDurationSeconds, 5000);
      expect(model.activeSessionLoginAt, '2026-06-27T10:00:00Z');
      expect(model.lastVisitAt, '2026-06-26T10:00:00Z');
      expect(model.currentlyActive, true);
    });

    test('parses nullable values', () {
      final json = {
        'formatted_total_access_duration': '00:00:00',
        'total_access_duration_seconds': null,
        'running_total_access_duration_seconds': null,
        'active_session_login_at': null,
        'last_visit_at': null,
        'currently_active': false,
      };

      final model = AccessTimeSummary.fromJson(json);

      expect(model.totalAccessDurationSeconds, isNull);
      expect(model.runningTotalAccessDurationSeconds, isNull);
      expect(model.activeSessionLoginAt, isNull);
      expect(model.lastVisitAt, isNull);
      expect(model.currentlyActive, false);
    });
  });

  group('AccessTimeSummary.toJson', () {
    test('serializes correctly', () {
      const model = AccessTimeSummary(
        formattedTotal: '01:20:30',
        totalAccessDurationSeconds: 4830,
        runningTotalAccessDurationSeconds: 5000,
        activeSessionLoginAt: '2026-06-27T10:00:00Z',
        lastVisitAt: '2026-06-26T10:00:00Z',
        currentlyActive: true,
      );

      final json = model.toJson();

      expect(
        json['formatted_total_access_duration'],
        '01:20:30',
      );

      expect(
        json['currently_active'],
        true,
      );
    });
  });
  group('DashboardTier', () {
    test('fromJson parses correctly', () {
      final model = DashboardTier.fromJson({
        'id': 1,
        'name': 'Premium',
        'slug': 'premium',
      });

      expect(model.id, 1);
      expect(model.name, 'Premium');
      expect(model.slug, 'premium');
    });

    test('toJson serializes correctly', () {
      const model = DashboardTier(
        id: 1,
        name: 'Premium',
        slug: 'premium',
      );

      final json = model.toJson();

      expect(json['id'], 1);
      expect(json['name'], 'Premium');
      expect(json['slug'], 'premium');
    });
  });
  group('DashboardStudent', () {
    test('fromJson parses correctly', () {
      final model = DashboardStudent.fromJson({
        'id': 10,
        'name': 'John Doe',
        'email': 'john@example.com',
        'first_name': 'John',
        'access_tier': {
          'id': 1,
          'name': 'Premium',
          'slug': 'premium',
        }
      });

      expect(model.id, 10);
      expect(model.name, 'John Doe');
      expect(model.firstName, 'John');
      expect(model.accessTier.name, 'Premium');
    });

    test('toJson serializes correctly', () {
      const model = DashboardStudent(
        id: 10,
        name: 'John Doe',
        email: 'john@example.com',
        firstName: 'John',
        accessTier: DashboardTier(
          id: 1,
          name: 'Premium',
          slug: 'premium',
        ),
      );

      final json = model.toJson();

      expect(json['id'], 10);
      expect(json['email'], 'john@example.com');
      expect(json['first_name'], 'John');
    });
  });
  group('DashboardLesson', () {
    test('fromJson parses correctly', () {
      final model = DashboardLesson.fromJson({
        'id': 1,
        'title': 'Introduction',
        'sort_order': 2,
      });

      expect(model.id, 1);
      expect(model.title, 'Introduction');
      expect(model.sortOrder, 2);
    });

    test('toJson serializes correctly', () {
      const model = DashboardLesson(
        id: 1,
        title: 'Introduction',
        sortOrder: 2,
      );

      final json = model.toJson();

      expect(json['id'], 1);
      expect(json['title'], 'Introduction');
      expect(json['sort_order'], 2);
    });
  });
  group('DashboardModule', () {
    test('fromJson parses correctly', () {
      final model = DashboardModule.fromJson({
        'title': 'Flutter Basic',
        'url_slug': 'flutter-basic',
      });

      expect(model.title, 'Flutter Basic');
      expect(model.urlSlug, 'flutter-basic');
    });

    test('toJson serializes correctly', () {
      const model = DashboardModule(
        title: 'Flutter Basic',
        urlSlug: 'flutter-basic',
      );

      final json = model.toJson();

      expect(json['title'], 'Flutter Basic');
      expect(json['url_slug'], 'flutter-basic');
    });
  });
  group('DashboardModuleItem', () {
    test('fromJson parses correctly', () {
      final model = DashboardModuleItem.fromJson({
        'id': 1,
        'title': 'Flutter',
        'url_slug': 'flutter',
        'lesson_count': 12,
        'completed_lessons': 6,
        'progress_percentage': 50,
        'show_progress': true,
        'status': 'ongoing',
        'status_label': 'In Progress',
        'cta_label': 'Continue',
        'thumbnail_url': '/images/flutter.png',
      });

      expect(model.id, 1);
      expect(model.lessonCount, 12);
      expect(model.completedLessons, 6);
      expect(model.progressPercentage, 50);
      expect(model.showProgress, true);
      expect(model.statusLabel, 'In Progress');
      expect(model.ctaLabel, 'Continue');
    });

    test('toJson serializes correctly', () {
      const model = DashboardModuleItem(
        id: 1,
        title: 'Flutter',
        urlSlug: 'flutter',
        lessonCount: 12,
        completedLessons: 6,
        progressPercentage: 50,
        showProgress: true,
        status: 'ongoing',
        statusLabel: 'In Progress',
        ctaLabel: 'Continue',
        thumbnailUrl: '/images/flutter.png',
      );

      final json = model.toJson();

      expect(json['lesson_count'], 12);
      expect(json['completed_lessons'], 6);
      expect(json['progress_percentage'], 50);
      expect(json['show_progress'], true);
    });
  });
  group('ContinueLearningSection', () {
    test('fromJson parses correctly', () {
      final model = ContinueLearningSection.fromJson({
        'state': 'active',
        'eyebrow': 'Continue',
        'title': 'Flutter',
        'description': 'Learn Flutter',
        'progress_percentage': 70,
        'cta_label': 'Continue',
        'thumbnail_url': '/thumb.png',
        'lesson': {
          'id': 1,
          'title': 'Lesson 1',
          'sort_order': 1,
        },
        'module': {
          'title': 'Flutter Basic',
          'url_slug': 'flutter-basic',
        },
        'status': 'ongoing',
      });

      expect(model.progressPercentage, 70);
      expect(model.lesson?.title, 'Lesson 1');
      expect(model.module?.title, 'Flutter Basic');
    });
  });
  group('ProgressSummarySection', () {
    test('fromJson parses correctly', () {
      final model = ProgressSummarySection.fromJson({
        'state': 'active',
        'eyebrow': 'Progress',
        'title': 'Overall Progress',
        'overall_progress_percentage': 80,
        'modules_completed': 8,
        'modules_total': 10,
        'lessons_completed': 40,
        'lessons_total': 50,
        'status': 'good',
      });

      expect(model.overallProgressPercentage, 80);
      expect(model.modulesCompleted, 8);
      expect(model.modulesTotal, 10);
      expect(model.lessonsCompleted, 40);
      expect(model.lessonsTotal, 50);
    });
  });
  group('AvailableModulesSection', () {
    test('fromJson parses correctly', () {
      final model = AvailableModulesSection.fromJson({
        'state': 'available',
        'eyebrow': 'Modules',
        'title': 'Available Modules',
        'items': [
          {
            'id': 1,
            'title': 'Flutter',
            'url_slug': 'flutter',
            'lesson_count': 12,
            'completed_lessons': 6,
            'progress_percentage': 50,
            'show_progress': true,
            'status': 'ongoing',
            'status_label': 'In Progress',
            'cta_label': 'Continue',
            'thumbnail_url': null,
          }
        ]
      });

      expect(model.items.length, 1);
      expect(model.items.first.title, 'Flutter');
    });
  });
  group('CertificateMilestone', () {
    test('fromJson parses correctly', () {
      final model = CertificateMilestone.fromJson({
        'state': 'eligible',
        'eyebrow': 'Certificate',
        'title': 'Your Certificate',
        'status': 'ready',
        'eligibility_label': 'Eligible',
        'cta_label': 'Download',
        'milestones': [
          {
            'label': 'Complete Modules',
            'status': 'done',
            'detail': 'Completed',
          }
        ]
      });

      expect(model.milestones.length, 1);
      expect(model.milestones.first.label, 'Complete Modules');
    });
  });
  group('DashboardData', () {
    test('fromJson parses nested object correctly', () {
      final json = {
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
          'progress_percentage': 70,
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

      final model = DashboardData.fromJson(json);

      expect(model.student.name, 'John');
      expect(model.progressSummarySection.modulesCompleted, 8);
      expect(model.availableModulesSection.items, isEmpty);
      expect(model.accessTimeSummary.currentlyActive, isFalse);
    });
  });
}