import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/api_provider.dart';
import '../../providers/dashboard_provider.dart';
import '../../providers/food_provider.dart';
import '../../providers/packaging_provider.dart';
import '../../widgets/empty_error_state.dart';
import '../../widgets/stat_kpi_card.dart';

class TechnologistDashboardScreen extends ConsumerStatefulWidget {
  const TechnologistDashboardScreen({super.key});

  @override
  ConsumerState<TechnologistDashboardScreen> createState() =>
      _TechnologistDashboardScreenState();
}

class _TechnologistDashboardScreenState
    extends ConsumerState<TechnologistDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dashAsync = ref.watch(technologistDashboardProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Food Technologist Suite'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondaryLight,
          tabs: const [
            Tab(icon: Icon(Icons.dashboard_outlined), text: 'Overview'),
            Tab(icon: Icon(Icons.fastfood_outlined), text: 'Commodities'),
            Tab(icon: Icon(Icons.inventory_2_outlined), text: 'Materials'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: Overview & Model Metrics
          _buildOverviewTab(dashAsync),
          // Tab 2: Food Commodities
          _buildCommoditiesTab(),
          // Tab 3: Packaging Materials
          _buildPackagingMaterialsTab(),
        ],
      ),
    );
  }

  Widget _buildOverviewTab(AsyncValue dashAsync) {
    final modelService = ref.watch(modelServiceProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          dashAsync.when(
            data: (dash) {
              return Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: StatKpiCard(
                          title: 'Food Commodities',
                          value: '${dash.totalFoods}',
                          subtitle: 'Verified',
                          icon: Icons.fastfood_outlined,
                          iconColor: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: StatKpiCard(
                          title: 'Packaging Films',
                          value: '${dash.totalMaterials}',
                          subtitle: 'In Database',
                          icon: Icons.inventory_2_outlined,
                          iconColor: AppColors.secondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: StatKpiCard(
                          title: 'AI Predictions',
                          value: '${dash.totalRecommendations}',
                          subtitle: 'Total Runs',
                          icon: Icons.auto_awesome,
                          iconColor: const Color(0xFF2563EB),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: StatKpiCard(
                          title: 'Model Version',
                          value: dash.activeModelVersion ?? 'v1.0',
                          subtitle: 'XGBoost Active',
                          icon: Icons.memory_outlined,
                          iconColor: Colors.purple.shade600,
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
            loading: () => const LoadingStateWidget(message: 'Loading overview...'),
            error: (err, _) => ErrorStateWidget(message: err.toString()),
          ),

          const SizedBox(height: 24),
          Text(
            'XGBoost Suitability Predictor',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 10),

          FutureBuilder(
            future: modelService.getModelInfo(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Card(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                );
              }
              final info = snapshot.data;
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
                              const Icon(Icons.psychology_outlined,
                                  color: AppColors.primary),
                              const SizedBox(width: 8),
                              Text(
                                info?.modelName ?? 'XGBoost Packaging Predictor',
                                style: const TextStyle(fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.secondaryContainer,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              info?.status?.toUpperCase() ?? 'ACTIVE',
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: AppColors.onSecondaryContainer,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 20),
                      _buildMetricRow('Algorithm', info?.algorithm ?? 'XGBoost Regressor'),
                      _buildMetricRow('Model Version', info?.version ?? '1.0.0'),
                      _buildMetricRow('Dataset Size', '${info?.datasetSize ?? 1000} samples'),
                      _buildMetricRow('Accuracy / R²', '${((info?.r2Score ?? 0.94) * 100).toStringAsFixed(1)}%'),
                      _buildMetricRow('RMSE', '${info?.rmse ?? 0.045}'),
                      _buildMetricRow('Explainability Engine', 'SHAP TreeExplainer'),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildCommoditiesTab() {
    final foodsAsync = ref.watch(foodsListProvider);

    return foodsAsync.when(
      data: (foods) {
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: foods.length,
          itemBuilder: (context, index) {
            final food = foods[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ExpansionTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.primaryContainer,
                  child: const Icon(Icons.fastfood, color: AppColors.primary, size: 20),
                ),
                title: Text(food.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                subtitle: Text(
                  food.categoryName ?? 'Category',
                  style: const TextStyle(fontSize: 12),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (food.description != null)
                          Text(
                            food.description!,
                            style: const TextStyle(fontSize: 13, height: 1.3),
                          ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _buildPropChip('Moisture', '${food.properties?.moistureContent ?? "-"}%'),
                            _buildPropChip('pH', '${food.properties?.phLevel ?? "-"}'),
                            _buildPropChip('Fat', '${food.properties?.fatContent ?? "-"}%'),
                            _buildPropChip('Protein', '${food.properties?.proteinContent ?? "-"}%'),
                            _buildPropChip('O₂ Sens', food.properties?.oxygenSensitivity ?? '-'),
                            _buildPropChip('H₂O Sens', food.properties?.moistureSensitivity ?? '-'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
      loading: () => const LoadingStateWidget(message: 'Loading commodities database...'),
      error: (e, _) => ErrorStateWidget(message: e.toString()),
    );
  }

  Widget _buildPackagingMaterialsTab() {
    final materialsAsync = ref.watch(packagingMaterialsProvider);

    return materialsAsync.when(
      data: (materials) {
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: materials.length,
          itemBuilder: (context, index) {
            final mat = materials[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ExpansionTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.secondaryContainer,
                  child: const Icon(Icons.inventory_2, color: AppColors.secondary, size: 20),
                ),
                title: Text(mat.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                subtitle: Text(
                  '${mat.materialCode} • ${mat.category ?? "Film"}',
                  style: const TextStyle(fontSize: 12),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (mat.description != null)
                          Text(
                            mat.description!,
                            style: const TextStyle(fontSize: 13, height: 1.3),
                          ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _buildPropChip('OTR', '${mat.properties?.oxygenTransmissionRate ?? "-"} cc/m²/d'),
                            _buildPropChip('WVTR', '${mat.properties?.waterVaporTransmissionRate ?? "-"} g/m²/d'),
                            _buildPropChip('Thickness', '${mat.properties?.thicknessMicrons ?? "-"} µm'),
                            _buildPropChip('Cost', '\$${mat.properties?.estimatedCostPerSqm?.toStringAsFixed(2) ?? "-"}/m²'),
                            _buildPropChip('Eco Score', '${mat.properties?.sustainabilityScore?.toStringAsFixed(0) ?? "-"}/10'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
      loading: () => const LoadingStateWidget(message: 'Loading packaging materials...'),
      error: (e, _) => ErrorStateWidget(message: e.toString()),
    );
  }

  Widget _buildMetricRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textSecondaryLight)),
          Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  Widget _buildPropChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primaryContainer.withOpacity(0.4),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        '$label: $value',
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primaryDark),
      ),
    );
  }
}
