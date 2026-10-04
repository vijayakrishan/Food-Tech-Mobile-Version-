import '../core/network/api_client.dart';
import '../models/api_response.dart';
import '../models/model_info.dart';

class ModelService {
  final ApiClient _client;

  ModelService(this._client);

  /// Fetch active XGBoost model information
  Future<ModelInfoDTO> getModelInfo() async {
    final responseData = await _client.get('/model/info');
    final apiResponse = ApiResponse<ModelInfoDTO>.fromJson(
      responseData as Map<String, dynamic>,
      (json) => ModelInfoDTO.fromJson(json as Map<String, dynamic>),
    );
    return apiResponse.data ?? ModelInfoDTO();
  }

  /// Fetch active model performance metrics (RMSE, R2, etc.)
  Future<Map<String, dynamic>> getModelMetrics() async {
    final responseData = await _client.get('/model/metrics');
    final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
      responseData as Map<String, dynamic>,
      (json) => json as Map<String, dynamic>,
    );
    return apiResponse.data ?? {};
  }
}
