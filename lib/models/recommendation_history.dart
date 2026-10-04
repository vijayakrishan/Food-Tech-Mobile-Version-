class RecommendationHistoryDTO {
  final int id;
  final String? foodCommodityName;
  final String? topMaterial;
  final double? topScore;
  final String? status;
  final String? createdAt;

  RecommendationHistoryDTO({
    required this.id,
    this.foodCommodityName,
    this.topMaterial,
    this.topScore,
    this.status,
    this.createdAt,
  });

  factory RecommendationHistoryDTO.fromJson(Map<String, dynamic> json) {
    return RecommendationHistoryDTO(
      id: json['id'] as int? ?? 0,
      foodCommodityName: json['foodCommodityName'] as String?,
      topMaterial: json['topMaterial'] as String?,
      topScore: (json['topScore'] as num?)?.toDouble(),
      status: json['status'] as String?,
      createdAt: json['createdAt']?.toString(),
    );
  }
}
