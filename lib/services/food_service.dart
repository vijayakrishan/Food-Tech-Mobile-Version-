import '../core/network/api_client.dart';
import '../models/api_response.dart';
import '../models/food_commodity.dart';

class FoodService {
  final ApiClient _client;

  FoodService(this._client);

  /// Fetch list of food commodities with optional search filter or category
  Future<List<FoodCommodityDTO>> getFoods({String? search, int? categoryId}) async {
    final query = <String, dynamic>{};
    if (search != null && search.isNotEmpty) query['search'] = search;
    if (categoryId != null) query['categoryId'] = categoryId;

    final responseData = await _client.get(
      '/foods',
      queryParameters: query.isNotEmpty ? query : null,
    );

    final apiResponse = ApiResponse<List<FoodCommodityDTO>>.fromJson(
      responseData as Map<String, dynamic>,
      (json) => (json as List<dynamic>)
          .map((e) => FoodCommodityDTO.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

    return apiResponse.data ?? [];
  }

  /// Fetch single food commodity by ID
  Future<FoodCommodityDTO> getFoodById(int id) async {
    final responseData = await _client.get('/foods/$id');
    final apiResponse = ApiResponse<FoodCommodityDTO>.fromJson(
      responseData as Map<String, dynamic>,
      (json) => FoodCommodityDTO.fromJson(json as Map<String, dynamic>),
    );
    if (apiResponse.data != null) {
      return apiResponse.data!;
    }
    throw Exception(apiResponse.message.isNotEmpty ? apiResponse.message : 'Food commodity not found');
  }

  /// Fetch all food categories
  Future<List<FoodCategoryDTO>> getCategories() async {
    final responseData = await _client.get('/foods/categories');
    final apiResponse = ApiResponse<List<FoodCategoryDTO>>.fromJson(
      responseData as Map<String, dynamic>,
      (json) => (json as List<dynamic>)
          .map((e) => FoodCategoryDTO.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
    return apiResponse.data ?? [];
  }
}
