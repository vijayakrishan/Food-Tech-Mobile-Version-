import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/dashboard_data.dart';
import 'api_provider.dart';

final producerDashboardProvider = FutureProvider.autoDispose<ProducerDashboardDTO>((ref) async {
  final service = ref.watch(dashboardServiceProvider);
  return await service.getProducerDashboard();
});

final technologistDashboardProvider = FutureProvider.autoDispose<TechnologistDashboardDTO>((ref) async {
  final service = ref.watch(dashboardServiceProvider);
  return await service.getTechnologistDashboard();
});

final adminDashboardProvider = FutureProvider.autoDispose<AdminDashboardDTO>((ref) async {
  final service = ref.watch(dashboardServiceProvider);
  return await service.getAdminDashboard();
});
