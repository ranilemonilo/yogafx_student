import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/module_model.dart';
import '../../data/repositories/module_repository.dart';

final moduleRepositoryProvider = Provider<ModuleRepository>((ref) {
  return ModuleRepository();
});

final moduleListProvider = FutureProvider<ModuleListData>((ref) async {
  return ref.read(moduleRepositoryProvider).getModules();
});

final moduleDetailProvider =
FutureProvider.family<ModuleDetail, int>((ref, moduleId) async {
  return ref.read(moduleRepositoryProvider).getModuleDetail(moduleId);
});