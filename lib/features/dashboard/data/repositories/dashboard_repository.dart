import 'package:dio/dio.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/error/app_exception.dart';
import '../models/dashboard_model.dart';

class DashboardRepository {
  final Dio _dio;

  DashboardRepository({
    Dio? dio,
  }) : _dio = dio ?? ApiClient.create();


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
    if (continueLearningRaw is Map) {
      continueLearningRaw['thumbnail_url'] = ApiClient.resolveUrl(
        continueLearningRaw['thumbnail_url'] as String?,
      );
    }

    final modulesSectionRaw = data['available_modules_section'];
    final items = modulesSectionRaw is Map
        ? modulesSectionRaw['items'] as List<dynamic>?
        : null;
    if (items != null) {
      for (var index = 0; index < items.length; index++) {
        final item = items[index];
        if (item is Map) {
          item['thumbnail_url'] = ApiClient.resolveUrl(
            item['thumbnail_url'] as String?,
          );
        }
      }
    }

    final certificateSummaryRaw = data['certificate_summary'];
    if (certificateSummaryRaw is Map) {
      final summary = Map<String, dynamic>.from(certificateSummaryRaw);
      data['certificate_milestone'] = {
        'state': summary['state'] ?? 'ready',
        'eyebrow': summary['status'] ?? 'Certificate',
        'title': summary['message'] ?? 'Certificate',
        'status': summary['status'] ?? 'available',
        'eligibility_label': summary['message'] ?? '',
        'cta_label': summary['latest_certificate'] != null
            ? 'View Certificate'
            : 'Generate Certificate',
        'milestones': _certificateRequirementsAsMilestones(
          summary['requirements'] as List<dynamic>? ?? const [],
        ),
      };
    }
  }

  List<dynamic> _certificateRequirementsAsMilestones(List<dynamic> raw) {
    return raw.map((item) {
      if (item is Map) {
        final requirement = Map<String, dynamic>.from(item);
        final completed = requirement['completed'] as int? ?? 0;
        final total = requirement['total'] as int? ?? 0;
        return <String, dynamic>{
          'label': requirement['label'] ?? requirement['key'] ?? 'Requirement',
          'status': requirement['status'] ?? '',
          'detail': '$completed/$total completed',
        };
      }
      return <String, dynamic>{
        'label': item.toString(),
        'status': '',
        'detail': '',
      };
    }).toList();
  }
}
