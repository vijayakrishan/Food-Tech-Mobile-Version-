import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../models/food_commodity.dart';
import '../models/recommendation_request.dart';
import '../models/recommendation_response.dart';
import 'api_provider.dart';
import 'dashboard_provider.dart';
import 'history_provider.dart';

class RecommendationWizardState {
  final int currentStep; // 0, 1, 2, 3
  final FoodCommodityDTO? selectedFood;

  // Food Properties
  final double moistureContent;
  final double phLevel;
  final double fatContent;
  final double proteinContent;
  final double carbohydrateContent;
  final double respirationRate;
  final String oxygenSensitivity;
  final String moistureSensitivity;
  final String lightSensitivity;

  // Storage Conditions
  final double storageTemperature;
  final double storageHumidity;
  final int requiredShelfLifeDays;
  final bool isRefrigerated;
  final String lightExposure; // "Dark", "Ambient", "Direct Light"

  // Multi-objective Weights (0.0 to 1.0)
  final double costPreference;
  final double sustainabilityPreference;
  final double performancePreference;
  final double shelfLifePreference;

  // Execution State
  final bool isGenerating;
  final String loadingStage;
  final String? errorMessage;
  final RecommendationResponseDTO? result;

  const RecommendationWizardState({
    this.currentStep = 0,
    this.selectedFood,
    this.moistureContent = 10.0,
    this.phLevel = 6.0,
    this.fatContent = 5.0,
    this.proteinContent = 8.0,
    this.carbohydrateContent = 50.0,
    this.respirationRate = 0.0,
    this.oxygenSensitivity = 'Medium',
    this.moistureSensitivity = 'Medium',
    this.lightSensitivity = 'Medium',
    this.storageTemperature = 25.0,
    this.storageHumidity = 60.0,
    this.requiredShelfLifeDays = 90,
    this.isRefrigerated = false,
    this.lightExposure = 'Ambient',
    this.costPreference = 0.25,
    this.sustainabilityPreference = 0.25,
    this.performancePreference = 0.25,
    this.shelfLifePreference = 0.25,
    this.isGenerating = false,
    this.loadingStage = '',
    this.errorMessage,
    this.result,
  });

  RecommendationWizardState copyWith({
    int? currentStep,
    FoodCommodityDTO? selectedFood,
    double? moistureContent,
    double? phLevel,
    double? fatContent,
    double? proteinContent,
    double? carbohydrateContent,
    double? respirationRate,
    String? oxygenSensitivity,
    String? moistureSensitivity,
    String? lightSensitivity,
    double? storageTemperature,
    double? storageHumidity,
    int? requiredShelfLifeDays,
    bool? isRefrigerated,
    String? lightExposure,
    double? costPreference,
    double? sustainabilityPreference,
    double? performancePreference,
    double? shelfLifePreference,
    bool? isGenerating,
    String? loadingStage,
    String? errorMessage,
    bool clearError = false,
    RecommendationResponseDTO? result,
    bool clearResult = false,
  }) {
    return RecommendationWizardState(
      currentStep: currentStep ?? this.currentStep,
      selectedFood: selectedFood ?? this.selectedFood,
      moistureContent: moistureContent ?? this.moistureContent,
      phLevel: phLevel ?? this.phLevel,
      fatContent: fatContent ?? this.fatContent,
      proteinContent: proteinContent ?? this.proteinContent,
      carbohydrateContent: carbohydrateContent ?? this.carbohydrateContent,
      respirationRate: respirationRate ?? this.respirationRate,
      oxygenSensitivity: oxygenSensitivity ?? this.oxygenSensitivity,
      moistureSensitivity: moistureSensitivity ?? this.moistureSensitivity,
      lightSensitivity: lightSensitivity ?? this.lightSensitivity,
      storageTemperature: storageTemperature ?? this.storageTemperature,
      storageHumidity: storageHumidity ?? this.storageHumidity,
      requiredShelfLifeDays: requiredShelfLifeDays ?? this.requiredShelfLifeDays,
      isRefrigerated: isRefrigerated ?? this.isRefrigerated,
      lightExposure: lightExposure ?? this.lightExposure,
      costPreference: costPreference ?? this.costPreference,
      sustainabilityPreference: sustainabilityPreference ?? this.sustainabilityPreference,
      performancePreference: performancePreference ?? this.performancePreference,
      shelfLifePreference: shelfLifePreference ?? this.shelfLifePreference,
      isGenerating: isGenerating ?? this.isGenerating,
      loadingStage: loadingStage ?? this.loadingStage,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      result: clearResult ? null : (result ?? this.result),
    );
  }
}

class RecommendationNotifier extends StateNotifier<RecommendationWizardState> {
  final Ref _ref;

  RecommendationNotifier(this._ref) : super(const RecommendationWizardState());

  void setStep(int step) {
    state = state.copyWith(currentStep: step);
  }

  void nextStep() {
    if (state.currentStep < 3) {
      state = state.copyWith(currentStep: state.currentStep + 1);
    }
  }

  void previousStep() {
    if (state.currentStep > 0) {
      state = state.copyWith(currentStep: state.currentStep - 1);
    }
  }

  /// Select a food commodity from database and auto-fill its scientific properties
  void selectFood(FoodCommodityDTO food) {
    final props = food.properties;
    state = state.copyWith(
      selectedFood: food,
      moistureContent: props?.moistureContent ?? state.moistureContent,
      phLevel: props?.phLevel ?? state.phLevel,
      fatContent: props?.fatContent ?? state.fatContent,
      proteinContent: props?.proteinContent ?? state.proteinContent,
      carbohydrateContent: props?.carbohydrateContent ?? state.carbohydrateContent,
      respirationRate: props?.respirationRate ?? state.respirationRate,
      oxygenSensitivity: props?.oxygenSensitivity ?? state.oxygenSensitivity,
      moistureSensitivity: props?.moistureSensitivity ?? state.moistureSensitivity,
      lightSensitivity: props?.lightSensitivity ?? state.lightSensitivity,
      isRefrigerated: props?.isPerishable ?? state.isRefrigerated,
    );
  }

  void updateFoodProperties({
    double? moisture,
    double? ph,
    double? fat,
    double? protein,
    double? carbs,
    double? respiration,
    String? oxygenSens,
    String? moistureSens,
    String? lightSens,
  }) {
    state = state.copyWith(
      moistureContent: moisture,
      phLevel: ph,
      fatContent: fat,
      proteinContent: protein,
      carbohydrateContent: carbs,
      respirationRate: respiration,
      oxygenSensitivity: oxygenSens,
      moistureSensitivity: moistureSens,
      lightSensitivity: lightSens,
    );
  }

  void updateStorageConditions({
    double? temp,
    double? humidity,
    int? shelfLife,
    bool? refrigerated,
    String? light,
  }) {
    state = state.copyWith(
      storageTemperature: temp,
      storageHumidity: humidity,
      requiredShelfLifeDays: shelfLife,
      isRefrigerated: refrigerated,
      lightExposure: light,
    );
  }

  void updatePreferences({
    double? cost,
    double? sustainability,
    double? performance,
    double? shelfLife,
  }) {
    state = state.copyWith(
      costPreference: cost,
      sustainabilityPreference: sustainability,
      performancePreference: performance,
      shelfLifePreference: shelfLife,
    );
  }

  /// Submit request to Spring Boot -> FastAPI XGBoost + SHAP
  Future<bool> generateRecommendation() async {
    state = state.copyWith(
      isGenerating: true,
      clearError: true,
      loadingStage: 'Analyzing food chemical properties...',
    );

    try {
      final request = RecommendationRequestDTO(
        foodCommodityId: state.selectedFood?.id,
        moistureContent: state.moistureContent,
        phLevel: state.phLevel,
        fatContent: state.fatContent,
        proteinContent: state.proteinContent,
        carbohydrateContent: state.carbohydrateContent,
        respirationRate: state.respirationRate,
        oxygenSensitivity: state.oxygenSensitivity,
        moistureSensitivity: state.moistureSensitivity,
        lightSensitivity: state.lightSensitivity,
        storageTemperature: state.storageTemperature,
        storageHumidity: state.storageHumidity,
        requiredShelfLifeDays: state.requiredShelfLifeDays,
        isRefrigerated: state.isRefrigerated,
        lightExposure: state.lightExposure,
        costPreference: state.costPreference,
        sustainabilityPreference: state.sustainabilityPreference,
        performancePreference: state.performancePreference,
        shelfLifePreference: state.shelfLifePreference,
      );

      final service = _ref.read(recommendationServiceProvider);
      final result = await service.generateRecommendation(request);

      state = state.copyWith(
        isGenerating: false,
        result: result,
      );

      // Invalidate dashboard and history providers so stats update automatically
      _ref.invalidate(producerDashboardProvider);
      _ref.invalidate(historyProvider);

      return true;
    } catch (e) {
      state = state.copyWith(
        isGenerating: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
      return false;
    }
  }

  void resetForm() {
    state = const RecommendationWizardState();
  }

  void setResult(RecommendationResponseDTO res) {
    state = state.copyWith(result: res);
  }
}

final recommendationProvider =
    StateNotifierProvider<RecommendationNotifier, RecommendationWizardState>((ref) {
  return RecommendationNotifier(ref);
});
