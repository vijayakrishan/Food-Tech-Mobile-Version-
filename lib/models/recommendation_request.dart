class RecommendationRequestDTO {
  final int? foodCommodityId;

  // Food properties
  final double? moistureContent;
  final double? phLevel;
  final double? fatContent;
  final double? proteinContent;
  final double? carbohydrateContent;
  final double? respirationRate;
  final String? oxygenSensitivity;
  final String? moistureSensitivity;
  final String? lightSensitivity;

  // Storage conditions
  final double? storageTemperature;
  final double? storageHumidity;
  final int? requiredShelfLifeDays;
  final bool? isRefrigerated;
  final String? lightExposure;

  // Multi-objective preferences (0.0 to 1.0)
  final double? costPreference;
  final double? sustainabilityPreference;
  final double? performancePreference;
  final double? shelfLifePreference;

  RecommendationRequestDTO({
    this.foodCommodityId,
    this.moistureContent,
    this.phLevel,
    this.fatContent,
    this.proteinContent,
    this.carbohydrateContent,
    this.respirationRate,
    this.oxygenSensitivity,
    this.moistureSensitivity,
    this.lightSensitivity,
    this.storageTemperature,
    this.storageHumidity,
    this.requiredShelfLifeDays,
    this.isRefrigerated,
    this.lightExposure,
    this.costPreference,
    this.sustainabilityPreference,
    this.performancePreference,
    this.shelfLifePreference,
  });

  Map<String, dynamic> toJson() {
    return {
      'foodCommodityId': foodCommodityId,
      'moistureContent': moistureContent,
      'phLevel': phLevel,
      'fatContent': fatContent,
      'proteinContent': proteinContent,
      'carbohydrateContent': carbohydrateContent,
      'respirationRate': respirationRate,
      'oxygenSensitivity': oxygenSensitivity,
      'moistureSensitivity': moistureSensitivity,
      'lightSensitivity': lightSensitivity,
      'storageTemperature': storageTemperature,
      'storageHumidity': storageHumidity,
      'requiredShelfLifeDays': requiredShelfLifeDays,
      'isRefrigerated': isRefrigerated,
      'lightExposure': lightExposure,
      'costPreference': costPreference,
      'sustainabilityPreference': sustainabilityPreference,
      'performancePreference': performancePreference,
      'shelfLifePreference': shelfLifePreference,
    };
  }

  factory RecommendationRequestDTO.fromJson(Map<String, dynamic> json) {
    return RecommendationRequestDTO(
      foodCommodityId: json['foodCommodityId'] as int?,
      moistureContent: (json['moistureContent'] as num?)?.toDouble(),
      phLevel: (json['phLevel'] as num?)?.toDouble(),
      fatContent: (json['fatContent'] as num?)?.toDouble(),
      proteinContent: (json['proteinContent'] as num?)?.toDouble(),
      carbohydrateContent: (json['carbohydrateContent'] as num?)?.toDouble(),
      respirationRate: (json['respirationRate'] as num?)?.toDouble(),
      oxygenSensitivity: json['oxygenSensitivity'] as String?,
      moistureSensitivity: json['moistureSensitivity'] as String?,
      lightSensitivity: json['lightSensitivity'] as String?,
      storageTemperature: (json['storageTemperature'] as num?)?.toDouble(),
      storageHumidity: (json['storageHumidity'] as num?)?.toDouble(),
      requiredShelfLifeDays: json['requiredShelfLifeDays'] as int?,
      isRefrigerated: json['isRefrigerated'] as bool?,
      lightExposure: json['lightExposure'] as String?,
      costPreference: (json['costPreference'] as num?)?.toDouble(),
      sustainabilityPreference: (json['sustainabilityPreference'] as num?)?.toDouble(),
      performancePreference: (json['performancePreference'] as num?)?.toDouble(),
      shelfLifePreference: (json['shelfLifePreference'] as num?)?.toDouble(),
    );
  }
}
