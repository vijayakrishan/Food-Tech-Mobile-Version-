import '../core/network/api_client.dart';
import '../models/api_response.dart';
import '../models/packaging_material.dart';

class PackagingService {
  final ApiClient _client;

  PackagingService(this._client);

  /// Fetch list of packaging materials with optional category filter
  Future<List<PackagingMaterialDTO>> getMaterials({String? category}) async {
    final query = <String, dynamic>{};
    if (category != null && category.isNotEmpty) query['category'] = category;

    final responseData = await _client.get(
      '/packaging-materials',
      queryParameters: query.isNotEmpty ? query : null,
    );

    final apiResponse = ApiResponse<List<PackagingMaterialDTO>>.fromJson(
      responseData as Map<String, dynamic>,
      (json) => (json as List<dynamic>)
          .map((e) => PackagingMaterialDTO.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

    return apiResponse.data ?? [];
  }

  /// Fetch single packaging material by ID
  Future<PackagingMaterialDTO> getMaterialById(int id) async {
    final responseData = await _client.get('/packaging-materials/$id');
    final apiResponse = ApiResponse<PackagingMaterialDTO>.fromJson(
      responseData as Map<String, dynamic>,
      (json) => PackagingMaterialDTO.fromJson(json as Map<String, dynamic>),
    );
    if (apiResponse.data != null) {
      return apiResponse.data!;
    }
    throw Exception(apiResponse.message.isNotEmpty ? apiResponse.message : 'Packaging material not found');
  }
}
