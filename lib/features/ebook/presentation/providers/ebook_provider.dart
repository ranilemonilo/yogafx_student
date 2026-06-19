import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/ebook_model.dart';
import '../../data/repositories/ebook_repository.dart';

final ebookRepositoryProvider = Provider<EbookRepository>((ref) {
  return EbookRepository();
});

final ebookDetailProvider =
    FutureProvider.family<EbookItem, int>((ref, ebookId) async {
  return ref.read(ebookRepositoryProvider).getEbookDetail(ebookId);
});
