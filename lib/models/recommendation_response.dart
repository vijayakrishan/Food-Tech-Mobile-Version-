import 'packaging_material.dart';

class RecommendationFactorDTO {
  final String? factorName;
  final double? factorValue;
  final double? contributionPercentage;
  final String? direction; // "POSITIVE" or "NEGATIVE"

  RecommendationFactorDTO({
    this.factorName,
    this.factorValue,
    this.contributionPercentage,
    this.direction,
  });

  factory RecommendationFactorDTO.fromJson(Map<String, dynamic> json) {
    return RecommendationFactorDTO(
      factorName: json['factorName'] as String?,
      factorValue: (json['factorValue'] as num?)?.toDouble(),
      contributionPercentage: (json['contributionPercentage'] as num?)?.toDouble(),
      direction: json['direction'] as String?,
    );
  }

  bool get isPositive => direction == 'POSITIVE' || (factorValue != null && factorValue! >= 0);
}

class RecommendationResultDTO {
  final int? materialId;
  final String materialName;
  final String materialCode;
  final int rank;
  final double suitabilityScore;
  final double? performanceScore;
  final double? costScore;
  final double? sustainabilityScore;
  final double? overallScore;
  final String? explanation;
  final List<RecommendationFactorDTO> factors;
  final PackagingPropertiesDTO? materialProperties;

  RecommendationResultDTO({
    this.materialId,
    required this.materialName,
    required this.materialCode,
    required this.rank,
    required this.suitabilityScore,
    this.performanceScore,
    this.costScore,
    this.sustainabilityScore,
    this.overallScore,
    this.explanation,
    this.factors = const [],
    this.materialProperties,
  });

  factory RecommendationResultDTO.fromJson(Map<String, dynamic> json) {
    final factorsList = json['factors'] as List<dynamic>?;
    return RecommendationResultDTO(
      materialId: json['materialId'] as int?,
      materialName: json['materialName'] as String? ?? '',
      materialCode: json['materialCode'] as String? ?? '',
      rank: json['rank'] as int? ?? 1,
      suitabilityScore: (json['suitabilityScore'] as num?)?.toDouble() ?? 0.0,
      performanceScore: (json['performanceScore'] as num?)?.toDouble(),
      costScore: (json['costScore'] as num?)?.toDouble(),
      sustainabilityScore: (json['sustainabilityScore'] as num?)?.toDouble(),
      overallScore: (json['overallScore'] as num?)?.toDouble(),
      explanation: json['explanation'] as String?,
      factors: factorsList != null
          ? factorsList.map((e) => RecommendationFactorDTO.fromJson(e as Map<String, dynamic>)).toList()
          : [],
      materialProperties: json['materialProperties'] != null
          ? PackagingPropertiesDTO.fromJson(json['materialProperties'] as Map<String, dynamic>)
          : null,
    );
  }
}

class RecommendationResponseDTO {
  final int? requestId;
  final String? foodCommodityName;
  final String? status;
  final List<RecommendationResultDTO> results;
  final String? createdAt;

  RecommendationResponseDTO({
    this.requestId,
    this.foodCommodityName,
    this.status,
    this.results = const [],
    this.createdAt,
  });

  factory RecommendationResponseDTO.fromJson(Map<String, dynamic> json) {
    final resultsList = json['results'] as List<dynamic>?;
    return RecommendationResponseDTO(
      requestId: json['requestId'] as int?,
      foodCommodityName: json['foodCommodityName'] as String?,
      status: json['status'] as String?,
      results: resultsList != null
          ? resultsList.map((e) => RecommendationResultDTO.fromJson(e as Map<String, dynamic>)).toList()
          : [],
      createdAt: json['createdAt']?.toString(),
    );
  }

  RecommendationResultDTO? get topRecommendation => results.isNotEmpty ? results.first : null;
}
