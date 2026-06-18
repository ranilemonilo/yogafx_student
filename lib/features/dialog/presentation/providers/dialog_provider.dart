import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/dialog_model.dart';
import '../../data/repositories/dialog_repository.dart';

final dialogRepositoryProvider = Provider<DialogRepository>((ref) {
  return DialogRepository();
});

final dialogListProvider = FutureProvider<DialogListData>((ref) async {
  return ref.read(dialogRepositoryProvider).getDialogs();
});

final dialogDetailProvider =
    FutureProvider.family<DialogItem, String>((ref, key) async {
  return ref.read(dialogRepositoryProvider).getDialogDetail(key);
});
