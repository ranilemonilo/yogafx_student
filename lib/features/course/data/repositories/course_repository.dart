import 'package:dio/dio.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/error/app_exception.dart';
import '../models/course_model.dart';

class CourseRepository {
  final Dio _dio;

  CourseRepository() : _dio = ApiClient.create();

  Future<CourseListData> getCourses() async {
    try {
      final response = await _dio.get('/courses');
      return CourseListData.fromJson(
        response.data['data'] as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw e.error as AppException? ?? const ServerException();
    }
  }

  Future<CourseItem> getCourseDetail(int courseId) async {
    try {
      final response = await _dio.get('/courses/$courseId');
      return CourseItem.fromJson(
        response.data['data'] as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw e.error as AppException? ?? const ServerException();
    }
  }
}
