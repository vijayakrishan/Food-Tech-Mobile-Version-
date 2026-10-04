import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/network/api_client.dart';
import '../services/auth_service.dart';
import '../services/dashboard_service.dart';
import '../services/food_service.dart';
import '../services/model_service.dart';
import '../services/packaging_service.dart';
import '../services/recommendation_service.dart';

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient();
});

final authServiceProvider = Provider<AuthService>((ref) {
  final client = ref.watch(apiClientProvider);
  return AuthService(client);
});

final foodServiceProvider = Provider<FoodService>((ref) {
  final client = ref.watch(apiClientProvider);
  return FoodService(client);
});

final packagingServiceProvider = Provider<PackagingService>((ref) {
  final client = ref.watch(apiClientProvider);
  return PackagingService(client);
});

final recommendationServiceProvider = Provider<RecommendationService>((ref) {
  final client = ref.watch(apiClientProvider);
  return RecommendationService(client);
});

final dashboardServiceProvider = Provider<DashboardService>((ref) {
  final client = ref.watch(apiClientProvider);
  return DashboardService(client);
});

final modelServiceProvider = Provider<ModelService>((ref) {
  final client = ref.watch(apiClientProvider);
  return ModelService(client);
});
