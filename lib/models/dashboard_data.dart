import 'recommendation_history.dart';

class ProducerDashboardDTO {
  final int totalRecommendations;
  final int savedRecommendations;
  final double avgSuitabilityScore;
  final String? mostRecommendedMaterial;
  final List<RecommendationHistoryDTO> recentRecommendations;

  ProducerDashboardDTO({
    this.totalRecommendations = 0,
    this.savedRecommendations = 0,
    this.avgSuitabilityScore = 0.0,
    this.mostRecommendedMaterial,
    this.recentRecommendations = const [],
  });

  factory ProducerDashboardDTO.fromJson(Map<String, dynamic> json) {
    final recent = json['recentRecommendations'] as List<dynamic>?;
    return ProducerDashboardDTO(
      totalRecommendations: json['totalRecommendations'] as int? ?? 0,
      savedRecommendations: json['savedRecommendations'] as int? ?? 0,
      avgSuitabilityScore: (json['avgSuitabilityScore'] as num?)?.toDouble() ?? 0.0,
      mostRecommendedMaterial: json['mostRecommendedMaterial'] as String?,
      recentRecommendations: recent != null
          ? recent.map((e) => RecommendationHistoryDTO.fromJson(e as Map<String, dynamic>)).toList()
          : [],
    );
  }
}

class TechnologistDashboardDTO {
  final int totalFoods;
  final int totalMaterials;
  final int totalRecommendations;
  final double avgModelAccuracy;
  final String? activeModelVersion;

  TechnologistDashboardDTO({
    this.totalFoods = 0,
    this.totalMaterials = 0,
    this.totalRecommendations = 0,
    this.avgModelAccuracy = 0.0,
    this.activeModelVersion,
  });

  factory TechnologistDashboardDTO.fromJson(Map<String, dynamic> json) {
    return TechnologistDashboardDTO(
      totalFoods: json['totalFoods'] as int? ?? 0,
      totalMaterials: json['totalMaterials'] as int? ?? 0,
      totalRecommendations: json['totalRecommendations'] as int? ?? 0,
      avgModelAccuracy: (json['avgModelAccuracy'] as num?)?.toDouble() ?? 0.0,
      activeModelVersion: json['activeModelVersion'] as String?,
    );
  }
}

class AdminDashboardDTO {
  final int totalUsers;
  final int activeUsers;
  final int totalRecommendations;
  final int totalAuditLogs;

  AdminDashboardDTO({
    this.totalUsers = 0,
    this.activeUsers = 0,
    this.totalRecommendations = 0,
    this.totalAuditLogs = 0,
  });

  factory AdminDashboardDTO.fromJson(Map<String, dynamic> json) {
    return AdminDashboardDTO(
      totalUsers: json['totalUsers'] as int? ?? 0,
      activeUsers: json['activeUsers'] as int? ?? 0,
      totalRecommendations: json['totalRecommendations'] as int? ?? 0,
      totalAuditLogs: json['totalAuditLogs'] as int? ?? 0,
    );
  }
}
