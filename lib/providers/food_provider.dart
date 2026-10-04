import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/food_commodity.dart';
import 'api_provider.dart';

final foodsListProvider = FutureProvider.autoDispose<List<FoodCommodityDTO>>((ref) async {
  final service = ref.watch(foodServiceProvider);
  return await service.getFoods();
});

final foodCategoriesProvider = FutureProvider.autoDispose<List<FoodCategoryDTO>>((ref) async {
  final service = ref.watch(foodServiceProvider);
  return await service.getCategories();
});
