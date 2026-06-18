import 'package:dio/dio.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/error/app_exception.dart';
import '../models/dialog_model.dart';

class DialogRepository {
  final Dio _dio;

  DialogRepository() : _dio = ApiClient.create();

  Future<DialogListData> getDialogs() async {
    try {
      final response = await _dio.get('/dialogs');
      return DialogListData.fromJson(
        response.data['data'] as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw e.error as AppException? ?? const ServerException();
    }
  }

  Future<DialogItem> getDialogDetail(String key) async {
    try {
      final response = await _dio.get('/dialogs/$key');
      return DialogItem.fromJson(
        response.data['data'] as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw e.error as AppException? ?? const ServerException();
    }
  }
}
