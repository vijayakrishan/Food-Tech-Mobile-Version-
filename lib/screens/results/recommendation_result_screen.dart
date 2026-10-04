import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../models/recommendation_response.dart';
import '../../providers/api_provider.dart';
import '../../providers/saved_provider.dart';
import '../../widgets/empty_error_state.dart';
import '../../widgets/material_card.dart';
import '../../widgets/property_pill.dart';
import '../../widgets/score_radial_gauge.dart';
import '../../widgets/shap_bar_chart.dart';
import 'comparison_screen.dart';
import 'report_preview_screen.dart';

class RecommendationResultScreen extends ConsumerStatefulWidget {
  final int? requestId;
  final RecommendationResponseDTO? recommendation;

  const RecommendationResultScreen({
    super.key,
    this.requestId,
    this.recommendation,
  });

  @override
  ConsumerState<RecommendationResultScreen> createState() =>
      _RecommendationResultScreenState();
}

class _RecommendationResultScreenState
    extends ConsumerState<RecommendationResultScreen> {
  RecommendationResponseDTO? _data;
  bool _isLoading = false;
  String? _error;
  bool _isSaved = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.recommendation != null) {
      _data = widget.recommendation;
      _checkIfSaved();
    } else if (widget.requestId != null) {
      _loadById(widget.requestId!);
    }
  }

  Future<void> _loadById(int id) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final service = ref.read(recommendationServiceProvider);
      final res = await service.getRecommendation(id);
      setState(() {
        _data = res;
        _isLoading = false;
      });
      _checkIfSaved();
    } catch (e) {
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  Future<void> _checkIfSaved() async {
    if (_data?.requestId == null) return;
    try {
      final service = ref.read(recommendationServiceProvider);
      final saved = await service.isSaved(_data!.requestId!);
      if (mounted) {
        setState(() {
          _isSaved = saved;
        });
      }
    } catch (_) {}
  }

  Future<void> _toggleSave() async {
    if (_data?.requestId == null) return;
    setState(() {
      _isSaving = true;
    });

    final id = _data!.requestId!;
    final savedNotifier = ref.read(savedProvider.notifier);

    if (_isSaved) {
      final ok = await savedNotifier.unsaveRecommendation(id);
      if (ok && mounted) {
        setState(() {
          _isSaved = false;
          _isSaving = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Removed from saved recommendations')),
        );
      }
    } else {
      final ok = await savedNotifier.saveRecommendation(id, notes: 'Saved from mobile app');
      if (ok && mounted) {
        setState(() {
          _isSaved = true;
          _isSaving = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Recommendation saved successfully')),
        );
      }
    }

    if (mounted) {
      setState(() {
        _isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Recommendation Details')),
        body: const LoadingStateWidget(message: 'Loading recommendation results...'),
      );
    }

    if (_error != null || _data == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Recommendation Details')),
        body: ErrorStateWidget(
          message: _error ?? 'Failed to load recommendation',
          onRetry: () => widget.requestId != null ? _loadById(widget.requestId!) : null,
        ),
      );
    }

    final topMatch = _data!.topRecommendation;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'AI Recommendation',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
            ),
            if (_data!.foodCommodityName != null)
              Text(
                'For: ${_data!.foodCommodityName}',
                style: const TextStyle(fontSize: 12, color: AppColors.primary),
              ),
          ],
        ),
        actions: [
          // Save / Bookmark Action
          IconButton(
            icon: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(
                    _isSaved ? Icons.bookmark : Icons.bookmark_border,
                    color: _isSaved ? AppColors.primary : null,
                  ),
            tooltip: _isSaved ? 'Remove from Saved' : 'Save Recommendation',
            onPressed: _isSaving ? null : _toggleSave,
          ),
          // PDF Report Action
          IconButton(
            icon: const Icon(Icons.picture_as_pdf_outlined),
            tooltip: 'View / Share Report',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ReportPreviewScreen(recommendation: _data!),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Recommendation Hero Card
            if (topMatch != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppColors.surfaceDark
                      : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.primary, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.12),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: AppColors.primaryContainer,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.check_circle, size: 14, color: AppColors.primary),
                              SizedBox(width: 4),
                              Text(
                                'TOP RECOMMENDATION',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.onPrimaryContainer,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          topMatch.materialCode,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondaryLight,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ScoreRadialGauge(
                          score: topMatch.suitabilityScore,
                          size: 94,
                          strokeWidth: 8,
                          label: 'AI MATCH',
                        ),
                        const SizedBox(width: 18),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                topMatch.materialName,
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 19,
                                    ),
                              ),
                              const SizedBox(height: 6),
                              if (topMatch.explanation != null)
                                Text(
                                  topMatch.explanation!,
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        height: 1.35,
                                      ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 8),

                    // Multi-objective Scores Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildSubScore('Suitability', topMatch.suitabilityScore, AppColors.primary),
                        _buildSubScore('Cost Fit', topMatch.costScore ?? 0, Colors.amber.shade700),
                        _buildSubScore('Eco Rating', topMatch.sustainabilityScore ?? 0, AppColors.secondary),
                        _buildSubScore('Overall', topMatch.overallScore ?? 0, const Color(0xFF2563EB)),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Barrier & Physical Specifications
              if (topMatch.materialProperties != null) ...[
                Text(
                  'Barrier & Technical Specifications',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (topMatch.materialProperties!.oxygenTransmissionRate != null)
                      PropertyPill(
                        label: 'Oxygen Trans (OTR)',
                        value: '${topMatch.materialProperties!.oxygenTransmissionRate} cc/m²/day',
                        icon: Icons.shield_outlined,
                        color: AppColors.primary,
                      ),
                    if (topMatch.materialProperties!.waterVaporTransmissionRate != null)
                      PropertyPill(
                        label: 'Moisture Trans (WVTR)',
                        value: '${topMatch.materialProperties!.waterVaporTransmissionRate} g/m²/day',
                        icon: Icons.water_drop_outlined,
                        color: const Color(0xFF0284C7),
                      ),
                    if (topMatch.materialProperties!.thicknessMicrons != null)
                      PropertyPill(
                        label: 'Film Thickness',
                        value: '${topMatch.materialProperties!.thicknessMicrons} µm',
                        icon: Icons.straighten,
                        color: Colors.purple.shade600,
                      ),
                    if (topMatch.materialProperties!.tensileStrength != null)
                      PropertyPill(
                        label: 'Tensile Strength',
                        value: '${topMatch.materialProperties!.tensileStrength} MPa',
                        icon: Icons.fitness_center_outlined,
                        color: Colors.indigo.shade600,
                      ),
                    if (topMatch.materialProperties!.estimatedCostPerSqm != null)
                      PropertyPill(
                        label: 'Estimated Cost',
                        value: '\$${topMatch.materialProperties!.estimatedCostPerSqm!.toStringAsFixed(2)}/m²',
                        icon: Icons.attach_money,
                        color: Colors.amber.shade800,
                      ),
                  ],
                ),
                const SizedBox(height: 20),
              ],

              // SHAP Explainability Visualizer (Requirement 11 & 13)
              ShapBarChart(factors: topMatch.factors),

              const SizedBox(height: 24),
            ],

            // Top 3 Alternatives & Comparison Section (Requirement 12)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Top 3 Packaging Ranking',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                TextButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ComparisonScreen(results: _data!.results),
                      ),
                    );
                  },
                  icon: const Icon(Icons.compare_arrows, size: 16),
                  label: const Text('Compare All'),
                ),
              ],
            ),
            const SizedBox(height: 8),

            ..._data!.results.map((res) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: MaterialCard(
                  result: res,
                  isTopMatch: res.rank == 1,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ComparisonScreen(
                          results: _data!.results,
                          initialSelectedIndex: res.rank - 1,
                        ),
                      ),
                    );
                  },
                ),
              );
            }),

            const SizedBox(height: 16),

            // Bottom Action Row (Compare & PDF Report)
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ComparisonScreen(results: _data!.results),
                        ),
                      );
                    },
                    icon: const Icon(Icons.compare_arrows, size: 18),
                    label: const Text('Compare Top 3'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ReportPreviewScreen(recommendation: _data!),
                        ),
                      );
                    },
                    icon: const Icon(Icons.download_outlined, size: 18),
                    label: const Text('Export Report'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSubScore(String label, double score, Color color) {
    return Column(
      children: [
        Text(
          '${score.toStringAsFixed(0)}%',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: AppColors.textSecondaryLight),
        ),
      ],
    );
  }
}
