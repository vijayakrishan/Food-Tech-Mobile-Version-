class ModelInfoDTO {
  final String? modelName;
  final String? algorithm;
  final String? version;
  final String? trainingDate;
  final int? datasetSize;
  final double? accuracy;
  final double? precisionScore;
  final double? recallScore;
  final double? f1Score;
  final double? rmse;
  final double? r2Score;
  final double? mae;
  final String? status;

  ModelInfoDTO({
    this.modelName,
    this.algorithm,
    this.version,
    this.trainingDate,
    this.datasetSize,
    this.accuracy,
    this.precisionScore,
    this.recallScore,
    this.f1Score,
    this.rmse,
    this.r2Score,
    this.mae,
    this.status,
  });

  factory ModelInfoDTO.fromJson(Map<String, dynamic> json) {
    return ModelInfoDTO(
      modelName: json['modelName'] as String? ?? json['model_name'] as String?,
      algorithm: json['algorithm'] as String?,
      version: json['version'] as String?,
      trainingDate: json['trainingDate'] as String?,
      datasetSize: json['datasetSize'] as int?,
      accuracy: (json['accuracy'] as num?)?.toDouble(),
      precisionScore: (json['precisionScore'] as num?)?.toDouble(),
      recallScore: (json['recallScore'] as num?)?.toDouble(),
      f1Score: (json['f1Score'] as num?)?.toDouble(),
      rmse: (json['rmse'] as num?)?.toDouble(),
      r2Score: (json['r2Score'] as num?)?.toDouble(),
      mae: (json['mae'] as num?)?.toDouble(),
      status: json['status'] as String?,
    );
  }
}
