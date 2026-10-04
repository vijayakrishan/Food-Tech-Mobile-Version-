import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../models/recommendation_response.dart';

class ComparisonScreen extends StatefulWidget {
  final List<RecommendationResultDTO> results;
  final int initialSelectedIndex;

  const ComparisonScreen({
    super.key,
    required this.results,
    this.initialSelectedIndex = 0,
  });

  @override
  State<ComparisonScreen> createState() => _ComparisonScreenState();
}

class _ComparisonScreenState extends State<ComparisonScreen> {
  late int _selectedPrimary;
  late int _selectedSecondary;

  @override
  void initState() {
    super.initState();
    _selectedPrimary = widget.initialSelectedIndex.clamp(0, widget.results.length - 1);
    _selectedSecondary = widget.results.length > 1 ? 1 : 0;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.results.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Compare Materials')),
        body: const Center(child: Text('No materials available for comparison.')),
      );
    }

    final mat1 = widget.results[_selectedPrimary];
    final mat2 = widget.results.length > _selectedSecondary ? widget.results[_selectedSecondary] : mat1;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Side-by-Side Comparison'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Selectors row
            Row(
              children: [
                Expanded(
                  child: _buildSelectorDropdown(
                    label: 'Material A',
                    selectedIndex: _selectedPrimary,
                    color: AppColors.primary,
                    onChanged: (idx) {
                      setState(() {
                        _selectedPrimary = idx;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSelectorDropdown(
                    label: 'Material B',
                    selectedIndex: _selectedSecondary,
                    color: const Color(0xFF2563EB),
                    onChanged: (idx) {
                      setState(() {
                        _selectedSecondary = idx;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Material Headers
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _buildMaterialHeader(mat1, AppColors.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMaterialHeader(mat2, const Color(0xFF2563EB)),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Comparative Metrics Section
            Text(
              'Comparative Performance Metrics',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 14),

            _buildComparisonMetricRow(
              title: 'AI Suitability Score',
              val1: mat1.suitabilityScore,
              val2: mat2.suitabilityScore,
              unit: '%',
              maxVal: 100,
            ),
            const SizedBox(height: 14),

            _buildComparisonMetricRow(
              title: 'Cost Efficiency Score',
              val1: mat1.costScore ?? 50.0,
              val2: mat2.costScore ?? 50.0,
              unit: '%',
              maxVal: 100,
            ),
            const SizedBox(height: 14),

            _buildComparisonMetricRow(
              title: 'Sustainability Score',
              val1: (mat1.sustainabilityScore ?? 50.0),
              val2: (mat2.sustainabilityScore ?? 50.0),
              unit: '%',
              maxVal: 100,
            ),
            const SizedBox(height: 14),

            _buildComparisonMetricRow(
              title: 'Overall Weighted Score',
              val1: mat1.overallScore ?? 50.0,
              val2: mat2.overallScore ?? 50.0,
              unit: '%',
              maxVal: 100,
            ),
            const SizedBox(height: 24),

            // Technical Specifications Table Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Technical & Barrier Specifications',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const Divider(height: 20),
                    _buildSpecRow(
                      'Est. Cost / m²',
                      mat1.materialProperties?.estimatedCostPerSqm != null
                          ? '\$${mat1.materialProperties!.estimatedCostPerSqm!.toStringAsFixed(2)}'
                          : '-',
                      mat2.materialProperties?.estimatedCostPerSqm != null
                          ? '\$${mat2.materialProperties!.estimatedCostPerSqm!.toStringAsFixed(2)}'
                          : '-',
                    ),
                    _buildSpecRow(
                      'OTR (cc/m²/day)',
                      '${mat1.materialProperties?.oxygenTransmissionRate ?? "-"}',
                      '${mat2.materialProperties?.oxygenTransmissionRate ?? "-"}',
                    ),
                    _buildSpecRow(
                      'WVTR (g/m²/day)',
                      '${mat1.materialProperties?.waterVaporTransmissionRate ?? "-"}',
                      '${mat2.materialProperties?.waterVaporTransmissionRate ?? "-"}',
                    ),
                    _buildSpecRow(
                      'Thickness (µm)',
                      '${mat1.materialProperties?.thicknessMicrons ?? "-"}',
                      '${mat2.materialProperties?.thicknessMicrons ?? "-"}',
                    ),
                    _buildSpecRow(
                      'Tensile Strength',
                      mat1.materialProperties?.tensileStrength != null
                          ? '${mat1.materialProperties!.tensileStrength} MPa'
                          : '-',
                      mat2.materialProperties?.tensileStrength != null
                          ? '${mat2.materialProperties!.tensileStrength} MPa'
                          : '-',
                    ),
                    _buildSpecRow(
                      'Eco Rating',
                      mat1.sustainabilityScore != null
                          ? '${mat1.sustainabilityScore!.toStringAsFixed(0)}/10'
                          : '-',
                      mat2.sustainabilityScore != null
                          ? '${mat2.sustainabilityScore!.toStringAsFixed(0)}/10'
                          : '-',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectorDropdown({
    required String label,
    required int selectedIndex,
    required Color color,
    required ValueChanged<int> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color),
        ),
        const SizedBox(height: 4),
        DropdownButtonFormField<int>(
          value: selectedIndex,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: color, width: 2),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          items: List.generate(widget.results.length, (i) {
            final item = widget.results[i];
            return DropdownMenuItem<int>(
              value: i,
              child: Text(
                '#${item.rank} ${item.materialCode}',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
            );
          }),
          onChanged: (val) {
            if (val != null) onChanged(val);
          },
        ),
      ],
    );
  }

  Widget _buildMaterialHeader(RecommendationResultDTO mat, Color accentColor) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: accentColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accentColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 10,
                backgroundColor: accentColor,
                child: Text(
                  '${mat.rank}',
                  style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  mat.materialCode,
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: accentColor),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            mat.materialName,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          Text(
            '${mat.suitabilityScore.toStringAsFixed(1)}% Suitability',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: accentColor),
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonMetricRow({
    required String title,
    required double val1,
    required double val2,
    required String unit,
    required double maxVal,
  }) {
    final r1 = (val1 / maxVal).clamp(0.0, 1.0);
    final r2 = (val2 / maxVal).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            // Bar 1
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Container(
                      height: 8,
                      color: AppColors.borderLight,
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: r1,
                        child: Container(color: AppColors.primary),
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${val1.toStringAsFixed(1)}$unit',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            // Bar 2
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Container(
                      height: 8,
                      color: AppColors.borderLight,
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: r2,
                        child: Container(color: const Color(0xFF2563EB)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${val2.toStringAsFixed(1)}$unit',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF2563EB)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSpecRow(String label, String v1, String v2) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryLight),
            ),
          ),
          Expanded(
            child: Text(
              v1,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Text(
              v2,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
