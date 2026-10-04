import '../core/network/api_client.dart';
import '../models/api_response.dart';
import '../models/recommendation_history.dart';
import '../models/recommendation_request.dart';
import '../models/recommendation_response.dart';

class RecommendationService {
  final ApiClient _client;

  RecommendationService(this._client);

  /// Generate AI Recommendation calling Spring Boot -> FastAPI XGBoost + SHAP
  Future<RecommendationResponseDTO> generateRecommendation(
    RecommendationRequestDTO request,
  ) async {
    final responseData = await _client.post(
      '/recommendations',
      data: request.toJson(),
    );

    final apiResponse = ApiResponse<RecommendationResponseDTO>.fromJson(
      responseData as Map<String, dynamic>,
      (json) => RecommendationResponseDTO.fromJson(json as Map<String, dynamic>),
    );

    if (apiResponse.success && apiResponse.data != null) {
      return apiResponse.data!;
    }
    throw Exception(
      apiResponse.message.isNotEmpty
          ? apiResponse.message
          : 'Failed to generate recommendation',
    );
  }

  /// Retrieve existing recommendation by Request ID
  Future<RecommendationResponseDTO> getRecommendation(int id) async {
    final responseData = await _client.get('/recommendations/$id');
    final apiResponse = ApiResponse<RecommendationResponseDTO>.fromJson(
      responseData as Map<String, dynamic>,
      (json) => RecommendationResponseDTO.fromJson(json as Map<String, dynamic>),
    );

    if (apiResponse.success && apiResponse.data != null) {
      return apiResponse.data!;
    }
    throw Exception(
      apiResponse.message.isNotEmpty
          ? apiResponse.message
          : 'Recommendation not found',
    );
  }

  /// Retrieve recommendation history for current user
  Future<List<RecommendationHistoryDTO>> getHistory() async {
    final responseData = await _client.get('/recommendations/history');
    final apiResponse = ApiResponse<List<RecommendationHistoryDTO>>.fromJson(
      responseData as Map<String, dynamic>,
      (json) => (json as List<dynamic>)
          .map((e) => RecommendationHistoryDTO.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

    return apiResponse.data ?? [];
  }

  /// Save recommendation with optional notes
  Future<void> saveRecommendation(int id, {String notes = ''}) async {
    final responseData = await _client.post(
      '/recommendations/$id/save',
      data: {'notes': notes},
    );
    final apiResponse = ApiResponse<dynamic>.fromJson(
      responseData as Map<String, dynamic>,
      null,
    );
    if (!apiResponse.success) {
      throw Exception(apiResponse.message);
    }
  }

  /// Unsave recommendation
  Future<void> unsaveRecommendation(int id) async {
    try {
      await _client.post('/recommendations/$id/unsave');
    } catch (_) {
      // Fallback to DELETE
      await _client.delete('/recommendations/$id/save');
    }
  }

  /// Check if a recommendation is saved
  Future<bool> isSaved(int id) async {
    try {
      final responseData = await _client.get('/recommendations/$id/is-saved');
      final apiResponse = ApiResponse<bool>.fromJson(
        responseData as Map<String, dynamic>,
        (json) => json as bool? ?? false,
      );
      return apiResponse.data ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Retrieve list of saved recommendations
  Future<List<RecommendationResponseDTO>> getSavedRecommendations() async {
    try {
      final responseData = await _client.get('/recommendations/saved');
      final apiResponse = ApiResponse<List<RecommendationResponseDTO>>.fromJson(
        responseData as Map<String, dynamic>,
        (json) => (json as List<dynamic>)
            .map((e) => RecommendationResponseDTO.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
      return apiResponse.data ?? [];
    } catch (_) {
      // Fallback: If running against a backend where /saved is not yet restarted,
      // load user history and return empty or partial
      return [];
    }
  }
}
