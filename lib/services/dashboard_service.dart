import '../core/network/api_client.dart';
import '../models/api_response.dart';
import '../models/dashboard_data.dart';

class DashboardService {
  final ApiClient _client;

  DashboardService(this._client);

  /// Fetch dashboard metrics for Producer role
  Future<ProducerDashboardDTO> getProducerDashboard() async {
    final responseData = await _client.get('/dashboard/producer');
    final apiResponse = ApiResponse<ProducerDashboardDTO>.fromJson(
      responseData as Map<String, dynamic>,
      (json) => ProducerDashboardDTO.fromJson(json as Map<String, dynamic>),
    );
    return apiResponse.data ?? ProducerDashboardDTO();
  }

  /// Fetch dashboard metrics for Technologist role
  Future<TechnologistDashboardDTO> getTechnologistDashboard() async {
    final responseData = await _client.get('/dashboard/technologist');
    final apiResponse = ApiResponse<TechnologistDashboardDTO>.fromJson(
      responseData as Map<String, dynamic>,
      (json) => TechnologistDashboardDTO.fromJson(json as Map<String, dynamic>),
    );
    return apiResponse.data ?? TechnologistDashboardDTO();
  }

  /// Fetch dashboard metrics for Admin role
  Future<AdminDashboardDTO> getAdminDashboard() async {
    final responseData = await _client.get('/dashboard/admin');
    final apiResponse = ApiResponse<AdminDashboardDTO>.fromJson(
      responseData as Map<String, dynamic>,
      (json) => AdminDashboardDTO.fromJson(json as Map<String, dynamic>),
    );
    return apiResponse.data ?? AdminDashboardDTO();
  }
}
