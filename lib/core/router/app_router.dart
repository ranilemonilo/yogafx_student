import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/assessment/presentation/screens/assessment_intro_screen.dart';
import '../../features/assessment/presentation/screens/assessment_result_screen.dart';
import '../../features/assessment/presentation/screens/assessment_screen.dart';
import '../../features/assignment/presentation/screens/assignment_screen.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/login_otp_screen.dart';
import '../../features/auth/presentation/screens/reset_password_screen.dart';
import '../../features/certificate/presentation/screens/certificate_detail_screen.dart';
import '../../features/certificate/presentation/screens/certificate_list_screen.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/dashboard/presentation/screens/overall_progress_screen.dart';
import '../../features/dialog/presentation/screens/dialog_detail_screen.dart';
import '../../features/dialog/presentation/screens/dialog_list_screen.dart';
import '../../features/ebook/presentation/screens/ebook_detail_screen.dart';
import '../../features/lesson/presentation/screens/lesson_screen.dart';
import '../../features/lesson/presentation/screens/workbook_viewer_screen.dart';
import '../../features/module/presentation/screens/module_detail_screen.dart';
import '../../features/module/presentation/screens/module_list_screen.dart';
import '../../features/profile/presentation/screens/change_password_screen.dart';
import '../../features/profile/presentation/screens/edit_profile_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/splash/presentation/screens/splash_screen.dart';
import '../shell/main_shell.dart';

class AppRoutes {
  static const splash = '/splash';
  static const login = '/login';
  static const loginOtp = '/login/otp';
  static const resetPassword = '/reset-password';
  static const resetPasswordNative = '/reset-password/:token';
  static const dashboard = '/dashboard';
  static const modules = '/modules';
  static const moduleDetail = '/modules/:moduleId';
  static const ebookDetail = '/ebooks/:ebookId';
  static const certificates = '/certificates';
  static const certificateDetail = '/certificates/:certificateId';
  static const profile = '/profile';
  static const editProfile = '/profile/edit';
  static const changePassword = '/profile/change-password';
  static const dialogs = '/dialogs';
  static const dialogDetail = '/dialogs/:dialogKey';
  static const lesson = '/lessons/:lessonId';
  static const assessmentIntro = '/lessons/:lessonId/assessment';
  static const assessmentPlay =
      '/lessons/:lessonId/assessment/attempts/:attemptId';
  static const assessmentResult =
      '/lessons/:lessonId/assessment/attempts/:attemptId/result';
  static const assignment = '/assignments/:assignmentId';
  static const workbookViewer = '/workbook-viewer';
  static const overallProgress = '/overall-progress';
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: AppRoutes.splash,
    redirect: (context, state) {
      final isInitial = authState.status == AuthStatus.initial;
      final isLoading = authState.status == AuthStatus.loading;
      final isAuthenticated = authState.isAuthenticated;

      final isSplashRoute = state.matchedLocation == AppRoutes.splash;

      final publicRoutes = {
        AppRoutes.login,
        AppRoutes.loginOtp,
        AppRoutes.resetPassword,
        AppRoutes.resetPasswordNative,
      };
      final isResetPasswordNativeRoute =
      state.matchedLocation.startsWith('/reset-password/');
      final isPublicRoute = publicRoutes.contains(state.matchedLocation) ||
          isResetPasswordNativeRoute;

      // Splash selalu boleh tampil duluan, navigasi diatur sendiri oleh splash
      if (isSplashRoute) return null;

      if (isInitial || isLoading) return null;
      if (!isAuthenticated && !isPublicRoute) return AppRoutes.login;
      if (isAuthenticated && state.matchedLocation == AppRoutes.login) {
        return AppRoutes.dashboard;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.loginOtp,
        name: 'loginOtp',
        builder: (context, state) => LoginOtpScreen(
          challenge: state.extra
          as LoginOtpScreenArgs,
        ),
      ),
      GoRoute(
        path: AppRoutes.resetPassword,
        name: 'resetPassword',
        builder: (context, state) => const ResetPasswordScreen(),
      ),
      GoRoute(
        path: AppRoutes.resetPasswordNative,
        name: 'resetPasswordNative',
        builder: (context, state) => ResetPasswordScreen(
          token: state.pathParameters['token'],
          initialEmail: state.uri.queryParameters['email'],
        ),
      ),
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.dashboard,
            name: 'dashboard',
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: AppRoutes.modules,
            name: 'modules',
            builder: (context, state) => const ModuleListScreen(),
            routes: [
              GoRoute(
                path: ':moduleId',
                name: 'moduleDetail',
                builder: (context, state) => ModuleDetailScreen(
                  moduleId: int.parse(state.pathParameters['moduleId']!),
                ),
              ),
            ],
          ),
          GoRoute(
            path: AppRoutes.profile,
            name: 'profile',
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/ebooks/:ebookId',
        name: 'ebookDetail',
        builder: (context, state) => EbookDetailScreen(
          ebookId: int.parse(state.pathParameters['ebookId']!),
        ),
      ),
      GoRoute(
        path: AppRoutes.certificates,
        name: 'certificates',
        builder: (context, state) => const CertificateListScreen(),
        routes: [
          GoRoute(
            path: ':certificateId',
            name: 'certificateDetail',
            builder: (context, state) => CertificateDetailScreen(
              certificateId: int.parse(state.pathParameters['certificateId']!),
            ),
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.dialogs,
        name: 'dialogs',
        builder: (context, state) => const DialogListScreen(),
        routes: [
          GoRoute(
            path: ':dialogKey',
            name: 'dialogDetail',
            builder: (context, state) => DialogDetailScreen(
              dialogKey: state.pathParameters['dialogKey']!,
            ),
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.editProfile,
        name: 'editProfile',
        builder: (context, state) => const EditProfileScreen(),
      ),
      GoRoute(
        path: AppRoutes.changePassword,
        name: 'changePassword',
        builder: (context, state) => const ChangePasswordScreen(),
      ),
      GoRoute(
        path: AppRoutes.lesson,
        name: 'lesson',
        builder: (context, state) => LessonScreen(
          lessonId: int.parse(state.pathParameters['lessonId']!),
          autoPlayVideo: state.uri.queryParameters['autoplay'] == '1',
        ),
        routes: [
          GoRoute(
            path: 'assessment',
            name: 'assessmentIntro',
            builder: (context, state) => AssessmentIntroScreen(
              lessonId: int.parse(state.pathParameters['lessonId']!),
            ),
            routes: [
              GoRoute(
                path: 'attempts/:attemptId',
                name: 'assessmentPlay',
                builder: (context, state) => AssessmentScreen(
                  lessonId: int.parse(state.pathParameters['lessonId']!),
                  attemptId: int.parse(state.pathParameters['attemptId']!),
                ),
                routes: [
                  GoRoute(
                    path: 'result',
                    name: 'assessmentResult',
                    builder: (context, state) => AssessmentResultScreen(
                      lessonId: int.parse(state.pathParameters['lessonId']!),
                      attemptId: int.parse(state.pathParameters['attemptId']!),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.assignment,
        name: 'assignment',
        builder: (context, state) => AssignmentScreen(
          assignmentId: int.parse(state.pathParameters['assignmentId']!),
        ),
      ),
      GoRoute(
        path: AppRoutes.overallProgress,
        name: 'overallProgress',
        builder: (context, state) {
          final extra = state.extra! as Map<String, int>;
          return OverallProgressScreen(
            modulesCompleted: extra['modulesCompleted']!,
            modulesTotal: extra['modulesTotal']!,
            lessonsCompleted: extra['lessonsCompleted']!,
            lessonsTotal: extra['lessonsTotal']!,
            overallProgressPercentage: extra['overallProgressPercentage']!,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.workbookViewer,
        name: 'workbookViewer',
        builder: (context, state) {
          final extra = state.extra! as Map<String, String>;
          return WorkbookViewerScreen(
            url: extra['url']!,
            title: extra['title'] ?? 'Workbook',
          );
        },
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: const Center(
        child: Text(
          'Page not found',
          style: TextStyle(color: Colors.white),
        ),
      ),
    ),
  );
});