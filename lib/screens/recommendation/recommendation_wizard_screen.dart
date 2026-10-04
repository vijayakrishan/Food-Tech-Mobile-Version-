import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../models/food_commodity.dart';
import '../../providers/food_provider.dart';
import '../../providers/recommendation_provider.dart';
import '../results/recommendation_result_screen.dart';

class RecommendationWizardScreen extends ConsumerStatefulWidget {
  const RecommendationWizardScreen({super.key});

  @override
  ConsumerState<RecommendationWizardScreen> createState() =>
      _RecommendationWizardScreenState();
}

class _RecommendationWizardScreenState
    extends ConsumerState<RecommendationWizardScreen> {
  final _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToStep(int step) {
    ref.read(recommendationProvider.notifier).setStep(step);
    _pageController.animateToPage(
      step,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _submitRecommendation() async {
    final notifier = ref.read(recommendationProvider.notifier);
    final success = await notifier.generateRecommendation();

    if (success && mounted) {
      final state = ref.read(recommendationProvider);
      if (state.result != null) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => RecommendationResultScreen(
              recommendation: state.result,
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final wizardState = ref.watch(recommendationProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Packaging Assistant'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: _buildStepProgressIndicator(wizardState.currentStep),
        ),
      ),
      body: wizardState.isGenerating
          ? _buildScientificLoadingView(wizardState)
          : PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildStep1FoodInfo(wizardState),
                _buildStep2StorageConditions(wizardState),
                _buildStep3Preferences(wizardState),
                _buildStep4Review(wizardState),
              ],
            ),
      bottomNavigationBar: wizardState.isGenerating
          ? null
          : _buildBottomNavButtons(wizardState),
    );
  }

  Widget _buildStepProgressIndicator(int currentStep) {
    final steps = ['Food Info', 'Storage', 'Priorities', 'Review'];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).brightness == Brightness.dark
                ? AppColors.borderDark
                : AppColors.borderLight,
          ),
        ),
      ),
      child: Row(
        children: List.generate(steps.length, (index) {
          final isCompleted = index < currentStep;
          final isCurrent = index == currentStep;
          final color = isCurrent
              ? AppColors.primary
              : isCompleted
                  ? AppColors.secondary
                  : AppColors.textMutedLight;

          return Expanded(
            child: Row(
              children: [
                CircleAvatar(
                  radius: 12,
                  backgroundColor: isCurrent || isCompleted
                      ? color
                      : color.withOpacity(0.2),
                  child: isCompleted
                      ? const Icon(Icons.check, size: 14, color: Colors.white)
                      : Text(
                          '${index + 1}',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: isCurrent ? Colors.white : color,
                          ),
                        ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    steps[index],
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
                      color: isCurrent
                          ? Theme.of(context).colorScheme.onSurface
                          : AppColors.textSecondaryLight,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (index < steps.length - 1)
                  Container(
                    width: 12,
                    height: 1.5,
                    color: index < currentStep
                        ? AppColors.secondary
                        : AppColors.borderLight,
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  // ----------------------------------------------------
  // STEP 1: FOOD INFORMATION
  // ----------------------------------------------------
  Widget _buildStep1FoodInfo(RecommendationWizardState state) {
    final foodsAsync = ref.watch(foodsListProvider);
    final notifier = ref.read(recommendationProvider.notifier);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select Food Commodity',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            'Choose from verified laboratory commodities to auto-populate properties, or adjust manually.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),

          // Food Commodity Dropdown
          foodsAsync.when(
            data: (foods) {
              return DropdownButtonFormField<FoodCommodityDTO>(
                value: state.selectedFood,
                decoration: const InputDecoration(
                  labelText: 'Food Commodity',
                  prefixIcon: Icon(Icons.fastfood_outlined),
                ),
                hint: const Text('Choose a food commodity...'),
                items: foods.map((food) {
                  return DropdownMenuItem<FoodCommodityDTO>(
                    value: food,
                    child: Text(food.name),
                  );
                }).toList(),
                onChanged: (food) {
                  if (food != null) {
                    notifier.selectFood(food);
                  }
                },
              );
            },
            loading: () => const LinearProgressIndicator(),
            error: (err, stack) => const Text('Failed to load foods catalog'),
          ),

          if (state.selectedFood != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primaryContainer.withOpacity(0.4),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.primary.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_outline,
                      size: 18, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Auto-filled from food database: ${state.selectedFood!.description ?? state.selectedFood!.name}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.onPrimaryContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 24),
          Text(
            'Nutritional & Chemical Profile',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 14),

          // Sliders for Moisture & pH
          _buildSliderInput(
            title: 'Moisture Content',
            value: state.moistureContent,
            min: 0,
            max: 100,
            unit: '%',
            onChanged: (val) => notifier.updateFoodProperties(moisture: val),
          ),

          _buildSliderInput(
            title: 'pH Level',
            value: state.phLevel,
            min: 2,
            max: 10,
            unit: 'pH',
            onChanged: (val) => notifier.updateFoodProperties(ph: val),
          ),

          _buildSliderInput(
            title: 'Fat Content',
            value: state.fatContent,
            min: 0,
            max: 100,
            unit: '%',
            onChanged: (val) => notifier.updateFoodProperties(fat: val),
          ),

          _buildSliderInput(
            title: 'Respiration Rate',
            value: state.respirationRate,
            min: 0,
            max: 100,
            unit: 'mg CO₂/kg/h',
            onChanged: (val) => notifier.updateFoodProperties(respiration: val),
          ),

          const SizedBox(height: 18),
          Text(
            'Environmental Sensitivities',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 12),

          _buildSensitivityDropdown(
            label: 'Oxygen Sensitivity',
            value: state.oxygenSensitivity,
            onChanged: (v) => notifier.updateFoodProperties(oxygenSens: v),
          ),
          const SizedBox(height: 12),

          _buildSensitivityDropdown(
            label: 'Moisture Sensitivity',
            value: state.moistureSensitivity,
            onChanged: (v) => notifier.updateFoodProperties(moistureSens: v),
          ),
          const SizedBox(height: 12),

          _buildSensitivityDropdown(
            label: 'Light Sensitivity',
            value: state.lightSensitivity,
            onChanged: (v) => notifier.updateFoodProperties(lightSens: v),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // ----------------------------------------------------
  // STEP 2: STORAGE CONDITIONS
  // ----------------------------------------------------
  Widget _buildStep2StorageConditions(RecommendationWizardState state) {
    final notifier = ref.read(recommendationProvider.notifier);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Storage & Distribution',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            'Specify the expected temperature, humidity, and shelf life requirements.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 20),

          // Refrigeration Switch
          Card(
            child: SwitchListTile(
              secondary: Icon(
                state.isRefrigerated ? Icons.ac_unit : Icons.thermostat_outlined,
                color: state.isRefrigerated ? AppColors.accent : AppColors.primary,
              ),
              title: const Text(
                'Refrigerated Chain',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              subtitle: Text(
                state.isRefrigerated
                    ? 'Chilled storage (0°C to 10°C)'
                    : 'Ambient room storage (20°C to 30°C)',
                style: const TextStyle(fontSize: 12),
              ),
              value: state.isRefrigerated,
              onChanged: (val) {
                notifier.updateStorageConditions(
                  refrigerated: val,
                  temp: val ? 4.0 : 25.0,
                );
              },
            ),
          ),
          const SizedBox(height: 16),

          _buildSliderInput(
            title: 'Storage Temperature',
            value: state.storageTemperature,
            min: -20,
            max: 50,
            unit: '°C',
            onChanged: (val) => notifier.updateStorageConditions(temp: val),
          ),

          _buildSliderInput(
            title: 'Storage Relative Humidity',
            value: state.storageHumidity,
            min: 10,
            max: 100,
            unit: '% RH',
            onChanged: (val) => notifier.updateStorageConditions(humidity: val),
          ),

          _buildSliderInput(
            title: 'Required Shelf Life',
            value: state.requiredShelfLifeDays.toDouble(),
            min: 1,
            max: 365,
            unit: 'Days',
            onChanged: (val) =>
                notifier.updateStorageConditions(shelfLife: val.toInt()),
          ),

          const SizedBox(height: 16),
          Text(
            'Light Exposure During Storage',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 8),

          SegmentedButton<String>(
            segments: const [
              ButtonSegment(
                value: 'Dark',
                label: Text('Dark'),
                icon: Icon(Icons.dark_mode_outlined),
              ),
              ButtonSegment(
                value: 'Ambient',
                label: Text('Ambient'),
                icon: Icon(Icons.wb_twilight_outlined),
              ),
              ButtonSegment(
                value: 'Direct Light',
                label: Text('Direct'),
                icon: Icon(Icons.light_mode_outlined),
              ),
            ],
            selected: {state.lightExposure},
            onSelectionChanged: (set) {
              notifier.updateStorageConditions(light: set.first);
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // ----------------------------------------------------
  // STEP 3: PREFERENCES & PRIORITIES
  // ----------------------------------------------------
  Widget _buildStep3Preferences(RecommendationWizardState state) {
    final notifier = ref.read(recommendationProvider.notifier);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Packaging Priorities',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            'Balance multi-objective trade-offs between performance, cost, sustainability, and longevity.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 20),

          _buildPrioritySlider(
            title: 'Barrier Performance Priority',
            subtitle: 'Max barrier against O₂ and moisture',
            value: state.performancePreference,
            icon: Icons.shield_outlined,
            color: AppColors.primary,
            onChanged: (v) => notifier.updatePreferences(performance: v),
          ),

          _buildPrioritySlider(
            title: 'Budget / Cost Efficiency',
            subtitle: 'Prioritize lower material cost per m²',
            value: state.costPreference,
            icon: Icons.attach_money,
            color: Colors.amber.shade700,
            onChanged: (v) => notifier.updatePreferences(cost: v),
          ),

          _buildPrioritySlider(
            title: 'Sustainability & Eco Impact',
            subtitle: 'Prioritize recyclable & biodegradable polymers',
            value: state.sustainabilityPreference,
            icon: Icons.eco_outlined,
            color: AppColors.secondary,
            onChanged: (v) => notifier.updatePreferences(sustainability: v),
          ),

          _buildPrioritySlider(
            title: 'Shelf-Life Maximization',
            subtitle: 'Extend storage duration before degradation',
            value: state.shelfLifePreference,
            icon: Icons.timelapse_outlined,
            color: const Color(0xFF2563EB),
            onChanged: (v) => notifier.updatePreferences(shelfLife: v),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // ----------------------------------------------------
  // STEP 4: REVIEW & GENERATE
  // ----------------------------------------------------
  Widget _buildStep4Review(RecommendationWizardState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Review & Confirm',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            'Verify your parameters before launching XGBoost prediction and SHAP analysis.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 18),

          // Error if any
          if (state.errorMessage != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.error.withOpacity(0.3)),
              ),
              child: Text(
                state.errorMessage!,
                style: const TextStyle(
                  color: AppColors.error,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Card 1: Food Properties Review
          _buildReviewCard(
            title: 'Food Commodity',
            icon: Icons.fastfood_outlined,
            onEdit: () => _goToStep(0),
            items: {
              'Name': state.selectedFood?.name ?? 'Custom Commodity',
              'Moisture': '${state.moistureContent.toStringAsFixed(1)}%',
              'pH Level': state.phLevel.toStringAsFixed(1),
              'Fat Content': '${state.fatContent.toStringAsFixed(1)}%',
              'Oxygen Sensitivity': state.oxygenSensitivity,
              'Moisture Sensitivity': state.moistureSensitivity,
            },
          ),
          const SizedBox(height: 12),

          // Card 2: Storage Review
          _buildReviewCard(
            title: 'Storage & Shelf Life',
            icon: Icons.thermostat_outlined,
            onEdit: () => _goToStep(1),
            items: {
              'Temperature': '${state.storageTemperature.toStringAsFixed(1)} °C',
              'Humidity': '${state.storageHumidity.toStringAsFixed(0)} % RH',
              'Required Shelf Life': '${state.requiredShelfLifeDays} Days',
              'Refrigeration': state.isRefrigerated ? 'Yes (Chilled)' : 'Ambient',
              'Light Exposure': state.lightExposure,
            },
          ),
          const SizedBox(height: 12),

          // Card 3: Priorities Review
          _buildReviewCard(
            title: 'Target Priorities',
            icon: Icons.tune_outlined,
            onEdit: () => _goToStep(2),
            items: {
              'Performance': '${(state.performancePreference * 100).toInt()}%',
              'Cost Efficiency': '${(state.costPreference * 100).toInt()}%',
              'Sustainability': '${(state.sustainabilityPreference * 100).toInt()}%',
              'Shelf Life': '${(state.shelfLifePreference * 100).toInt()}%',
            },
          ),
          const SizedBox(height: 24),

          // Big Generate Button
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(54),
              backgroundColor: AppColors.primary,
            ),
            onPressed: _submitRecommendation,
            icon: const Icon(Icons.auto_awesome, size: 20),
            label: const Text(
              'Generate AI Recommendation',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // ----------------------------------------------------
  // SCIENTIFIC LOADING VIEW (Requirement 9 & 10)
  // ----------------------------------------------------
  Widget _buildScientificLoadingView(RecommendationWizardState state) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primaryContainer,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.2),
                    blurRadius: 20,
                  ),
                ],
              ),
              child: const Center(
                child: SizedBox(
                  width: 44,
                  height: 44,
                  child: CircularProgressIndicator(
                    strokeWidth: 3.5,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'AI Engine Processing...',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              state.loadingStage.isNotEmpty
                  ? state.loadingStage
                  : 'Evaluating packaging barrier specifications...',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            _buildLoadingStep('1. Querying packaging materials from MySQL', true),
            _buildLoadingStep('2. Normalizing biochemical features', true),
            _buildLoadingStep('3. Running XGBoost Suitability Regressor', true),
            _buildLoadingStep('4. Generating SHAP TreeExplainer values', true),
            _buildLoadingStep('5. Applying multi-objective Pareto ranking', true),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingStep(String label, bool active) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_circle, size: 16, color: AppColors.secondary),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryLight),
          ),
        ],
      ),
    );
  }

  // ----------------------------------------------------
  // HELPER CONTROLS
  // ----------------------------------------------------
  Widget _buildBottomNavButtons(RecommendationWizardState state) {
    final current = state.currentStep;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).brightness == Brightness.dark
                ? AppColors.borderDark
                : AppColors.borderLight,
          ),
        ),
      ),
      child: Row(
        children: [
          if (current > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: () => _goToStep(current - 1),
                child: const Text('Back'),
              ),
            ),
          if (current > 0) const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: () {
                if (current < 3) {
                  _goToStep(current + 1);
                } else {
                  _submitRecommendation();
                }
              },
              child: Text(current == 3 ? 'Generate Match' : 'Continue'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliderInput({
    required String title,
    required double value,
    required double min,
    required double max,
    required String unit,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.primaryContainer.withOpacity(0.5),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '${value.toStringAsFixed(1)} $unit',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                  color: AppColors.primaryDark,
                ),
              ),
            ),
          ],
        ),
        Slider(
          value: value.clamp(min, max),
          min: min,
          max: max,
          activeColor: AppColors.primary,
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildPrioritySlider({
    required String title,
    required String subtitle,
    required double value,
    required IconData icon,
    required Color color,
    required ValueChanged<double> onChanged,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 18, color: color),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
                      Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.textSecondaryLight)),
                    ],
                  ),
                ),
                Text(
                  '${(value * 100).toInt()}%',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: color),
                ),
              ],
            ),
            Slider(
              value: value.clamp(0.0, 1.0),
              min: 0.0,
              max: 1.0,
              activeColor: color,
              onChanged: onChanged,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSensitivityDropdown({
    required String label,
    required String value,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(labelText: label),
      items: const [
        DropdownMenuItem(value: 'Low', child: Text('Low')),
        DropdownMenuItem(value: 'Medium', child: Text('Medium')),
        DropdownMenuItem(value: 'High', child: Text('High')),
        DropdownMenuItem(value: 'Very High', child: Text('Very High')),
      ],
      onChanged: onChanged,
    );
  }

  Widget _buildReviewCard({
    required String title,
    required IconData icon,
    required VoidCallback onEdit,
    required Map<String, String> items,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(icon, size: 18, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
                  ],
                ),
                TextButton(
                  onPressed: onEdit,
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(40, 24),
                  ),
                  child: const Text('Edit', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
            const Divider(height: 16),
            ...items.entries.map((e) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(e.key, style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryLight)),
                    Text(e.value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
