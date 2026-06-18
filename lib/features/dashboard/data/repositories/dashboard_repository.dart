import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/error/app_exception.dart';
import '../models/dashboard_model.dart';

class DashboardRepository {
  final Dio _dio;

  DashboardRepository() : _dio = ApiClient.create();

  Future<DashboardData> getDashboard() async {
    try {
      final response = await _dio.get('/dashboard');
      final data = Map<String, dynamic>.from(
        response.data['data'] as Map<String, dynamic>,
      );
      _normalizeThumbnailUrls(data);
      return DashboardData.fromJson(data);
    } on DioException catch (e) {
      throw e.error as AppException? ?? const ServerException();
    }
  }

  void _normalizeThumbnailUrls(Map<String, dynamic> data) {
    final continueLearningRaw = data['continue_learning_section'];
    final continueLearning = continueLearningRaw is Map
        ? Map<String, dynamic>.from(continueLearningRaw)
        : null;
    if (continueLearning != null) {
      continueLearning['thumbnail_url'] =
          ApiClient.resolveUrl(continueLearning['thumbnail_url'] as String?);
      data['continue_learning_section'] = continueLearning;
    }

    final modulesSectionRaw = data['available_modules_section'];
    final modulesSection = modulesSectionRaw is Map
        ? Map<String, dynamic>.from(modulesSectionRaw)
        : null;
    final items = modulesSection?['items'] as List<dynamic>?;
    if (items != null) {
      for (var i = 0; i < items.length; i++) {
        final item = items[i];
        if (item is Map) {
          final normalizedItem = Map<String, dynamic>.from(item);
          final resolvedThumbnail = _resolveModuleThumbnail(normalizedItem);
          _debugLogAvailableModuleItem(
            index: i,
            rawItem: normalizedItem,
            resolvedThumbnail: resolvedThumbnail,
          );
          normalizedItem['thumbnail_url'] = resolvedThumbnail;
          items[i] = normalizedItem;
        }
      }
    }
    if (modulesSection != null) {
      data['available_modules_section'] = modulesSection;
    }
  }

  String? _resolveModuleThumbnail(Map<String, dynamic> item) {
    final direct = ApiClient.resolveUrl(item['thumbnail_url'] as String?);
    if (direct != null) return direct;

    final imageUrl = ApiClient.resolveUrl(item['image_url'] as String?);
    if (imageUrl != null) return imageUrl;

    final thumbnailRaw = item['thumbnail'];
    if (thumbnailRaw is String) {
      return ApiClient.resolveUrl(thumbnailRaw);
    }

    if (thumbnailRaw is Map) {
      final thumbnail = Map<String, dynamic>.from(thumbnailRaw);
      return ApiClient.resolveUrl(
        thumbnail['url'] as String? ??
            thumbnail['path'] as String? ??
            thumbnail['image_url'] as String? ??
            thumbnail['thumbnail_url'] as String?,
      );
    }

    return null;
  }

  void _debugLogAvailableModuleItem({
    required int index,
    required Map<String, dynamic> rawItem,
    required String? resolvedThumbnail,
  }) {
    if (!kDebugMode) return;

    final thumbnailRaw = rawItem['thumbnail'];
    final thumbnailMap = thumbnailRaw is Map
        ? Map<String, dynamic>.from(thumbnailRaw)
        : null;

    debugPrint(
      '[DashboardRepository] Available Modules item[$index]\n'
      'raw: ${jsonEncode(rawItem)}\n'
      'thumbnail_url: ${rawItem['thumbnail_url']}\n'
      'image_url: ${rawItem['image_url']}\n'
      'thumbnail: ${thumbnailMap != null ? jsonEncode(thumbnailMap) : thumbnailRaw}\n'
      'resolved_thumbnail_url: $resolvedThumbnail',
    );
  }
}
