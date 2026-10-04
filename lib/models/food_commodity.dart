class FoodCategoryDTO {
  final int id;
  final String name;
  final String? description;

  FoodCategoryDTO({
    required this.id,
    required this.name,
    this.description,
  });

  factory FoodCategoryDTO.fromJson(Map<String, dynamic> json) {
    return FoodCategoryDTO(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
    );
  }
}

class FoodPropertiesDTO {
  final double? moistureContent;
  final double? phLevel;
  final double? fatContent;
  final double? proteinContent;
  final double? carbohydrateContent;
  final double? respirationRate;
  final String? oxygenSensitivity;
  final String? moistureSensitivity;
  final String? lightSensitivity;
  final String? microbialSensitivity;
  final bool? isPerishable;

  FoodPropertiesDTO({
    this.moistureContent,
    this.phLevel,
    this.fatContent,
    this.proteinContent,
    this.carbohydrateContent,
    this.respirationRate,
    this.oxygenSensitivity,
    this.moistureSensitivity,
    this.lightSensitivity,
    this.microbialSensitivity,
    this.isPerishable,
  });

  factory FoodPropertiesDTO.fromJson(Map<String, dynamic> json) {
    return FoodPropertiesDTO(
      moistureContent: (json['moistureContent'] as num?)?.toDouble(),
      phLevel: (json['phLevel'] as num?)?.toDouble(),
      fatContent: (json['fatContent'] as num?)?.toDouble(),
      proteinContent: (json['proteinContent'] as num?)?.toDouble(),
      carbohydrateContent: (json['carbohydrateContent'] as num?)?.toDouble(),
      respirationRate: (json['respirationRate'] as num?)?.toDouble(),
      oxygenSensitivity: json['oxygenSensitivity'] as String?,
      moistureSensitivity: json['moistureSensitivity'] as String?,
      lightSensitivity: json['lightSensitivity'] as String?,
      microbialSensitivity: json['microbialSensitivity'] as String?,
      isPerishable: json['isPerishable'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'moistureContent': moistureContent,
      'phLevel': phLevel,
      'fatContent': fatContent,
      'proteinContent': proteinContent,
      'carbohydrateContent': carbohydrateContent,
      'respirationRate': respirationRate,
      'oxygenSensitivity': oxygenSensitivity,
      'moistureSensitivity': moistureSensitivity,
      'lightSensitivity': lightSensitivity,
      'microbialSensitivity': microbialSensitivity,
      'isPerishable': isPerishable,
    };
  }
}

class FoodCommodityDTO {
  final int id;
  final String name;
  final int? categoryId;
  final String? categoryName;
  final String? description;
  final String? imageUrl;
  final FoodPropertiesDTO? properties;

  FoodCommodityDTO({
    required this.id,
    required this.name,
    this.categoryId,
    this.categoryName,
    this.description,
    this.imageUrl,
    this.properties,
  });

  factory FoodCommodityDTO.fromJson(Map<String, dynamic> json) {
    return FoodCommodityDTO(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      categoryId: json['categoryId'] as int?,
      categoryName: json['categoryName'] as String?,
      description: json['description'] as String?,
      imageUrl: json['imageUrl'] as String?,
      properties: json['properties'] != null
          ? FoodPropertiesDTO.fromJson(json['properties'] as Map<String, dynamic>)
          : null,
    );
  }
}
