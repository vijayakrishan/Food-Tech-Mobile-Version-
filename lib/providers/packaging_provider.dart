import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/packaging_material.dart';
import 'api_provider.dart';

final packagingMaterialsProvider = FutureProvider.autoDispose<List<PackagingMaterialDTO>>((ref) async {
  final service = ref.watch(packagingServiceProvider);
  return await service.getMaterials();
});
