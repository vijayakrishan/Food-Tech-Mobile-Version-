class PackagingPropertiesDTO {
  final double? oxygenTransmissionRate;
  final double? waterVaporTransmissionRate;
  final double? lightTransmission;
  final double? thicknessMicrons;
  final double? tensileStrength;
  final String? flexibility;
  final bool? heatSealability;
  final double? transparency;
  final double? recyclabilityScore;
  final double? biodegradabilityScore;
  final double? estimatedCostPerSqm;
  final double? sustainabilityScore;
  final double? maxTemperature;
  final double? minTemperature;
  final double? greaseResistance;

  PackagingPropertiesDTO({
    this.oxygenTransmissionRate,
    this.waterVaporTransmissionRate,
    this.lightTransmission,
    this.thicknessMicrons,
    this.tensileStrength,
    this.flexibility,
    this.heatSealability,
    this.transparency,
    this.recyclabilityScore,
    this.biodegradabilityScore,
    this.estimatedCostPerSqm,
    this.sustainabilityScore,
    this.maxTemperature,
    this.minTemperature,
    this.greaseResistance,
  });

  factory PackagingPropertiesDTO.fromJson(Map<String, dynamic> json) {
    return PackagingPropertiesDTO(
      oxygenTransmissionRate: (json['oxygenTransmissionRate'] as num?)?.toDouble(),
      waterVaporTransmissionRate: (json['waterVaporTransmissionRate'] as num?)?.toDouble(),
      lightTransmission: (json['lightTransmission'] as num?)?.toDouble(),
      thicknessMicrons: (json['thicknessMicrons'] as num?)?.toDouble(),
      tensileStrength: (json['tensileStrength'] as num?)?.toDouble(),
      flexibility: json['flexibility'] as String?,
      heatSealability: json['heatSealability'] as bool?,
      transparency: (json['transparency'] as num?)?.toDouble(),
      recyclabilityScore: (json['recyclabilityScore'] as num?)?.toDouble(),
      biodegradabilityScore: (json['biodegradabilityScore'] as num?)?.toDouble(),
      estimatedCostPerSqm: (json['estimatedCostPerSqm'] as num?)?.toDouble(),
      sustainabilityScore: (json['sustainabilityScore'] as num?)?.toDouble(),
      maxTemperature: (json['maxTemperature'] as num?)?.toDouble(),
      minTemperature: (json['minTemperature'] as num?)?.toDouble(),
      greaseResistance: (json['greaseResistance'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'oxygenTransmissionRate': oxygenTransmissionRate,
      'waterVaporTransmissionRate': waterVaporTransmissionRate,
      'lightTransmission': lightTransmission,
      'thicknessMicrons': thicknessMicrons,
      'tensileStrength': tensileStrength,
      'flexibility': flexibility,
      'heatSealability': heatSealability,
      'transparency': transparency,
      'recyclabilityScore': recyclabilityScore,
      'biodegradabilityScore': biodegradabilityScore,
      'estimatedCostPerSqm': estimatedCostPerSqm,
      'sustainabilityScore': sustainabilityScore,
      'maxTemperature': maxTemperature,
      'minTemperature': minTemperature,
      'greaseResistance': greaseResistance,
    };
  }
}

class PackagingMaterialDTO {
  final int id;
  final String name;
  final String materialCode;
  final String? category;
  final String? description;
  final PackagingPropertiesDTO? properties;

  PackagingMaterialDTO({
    required this.id,
    required this.name,
    required this.materialCode,
    this.category,
    this.description,
    this.properties,
  });

  factory PackagingMaterialDTO.fromJson(Map<String, dynamic> json) {
    return PackagingMaterialDTO(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      materialCode: json['materialCode'] as String? ?? '',
      category: json['category'] as String?,
      description: json['description'] as String?,
      properties: json['properties'] != null
          ? PackagingPropertiesDTO.fromJson(json['properties'] as Map<String, dynamic>)
          : null,
    );
  }
}
