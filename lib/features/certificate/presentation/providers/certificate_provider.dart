import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/certificate_model.dart';
import '../../data/repositories/certificate_repository.dart';

final certificateRepositoryProvider = Provider<CertificateRepository>((ref) {
  return CertificateRepository();
});

final certificateListProvider = FutureProvider<CertificateListData>((ref) async {
  return ref.read(certificateRepositoryProvider).getCertificates();
});

final hasGeneratedCertificateProvider = FutureProvider<bool>((ref) async {
  final data = await ref.watch(certificateListProvider.future);
  return data.summary.generatedCount > 0;
});

final certificateDetailProvider =
    FutureProvider.family<CertificateItem, int>((ref, certificateId) async {
  return ref
      .read(certificateRepositoryProvider)
      .getCertificateDetail(certificateId);
});
