import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../models/recommendation_response.dart';
import 'score_radial_gauge.dart';

class MaterialCard extends StatelessWidget {
  final RecommendationResultDTO result;
  final bool isTopMatch;
  final VoidCallback? onTap;

  const MaterialCard({
    super.key,
    required this.result,
    this.isTopMatch = false,
    this.onTap,
  });

  String _getRankTitle(int rank) {
    switch (rank) {
      case 1:
        return 'BEST MATCH';
      case 2:
        return 'ALTERNATIVE';
      case 3:
        return 'ECO OPTION';
      default:
        return 'MATCH #$rank';
    }
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return AppColors.primary;
      case 2:
        return const Color(0xFF2563EB); // Blue
      case 3:
        return AppColors.secondary; // Green
      default:
        return AppColors.textSecondaryLight;
    }
  }

  @override
  Widget build(BuildContext context) {
    final rankColor = _getRankColor(result.rank);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isTopMatch
              ? AppColors.primary
              : (Theme.of(context).brightness == Brightness.dark
                  ? AppColors.borderDark
                  : AppColors.borderLight),
          width: isTopMatch ? 2.0 : 1.0,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Rank Pill & Material Code
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: rankColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          result.rank == 1 ? Icons.check_circle : Icons.verified_outlined,
                          size: 14,
                          color: rankColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _getRankTitle(result.rank),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: rankColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    result.materialCode,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Title and Score Gauge Row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          result.materialName,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                        ),
                        if (result.explanation != null) ...[
                          const SizedBox(height: 6),
                          Text(
                            result.explanation!,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontSize: 12.5,
                                  height: 1.35,
                                ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  ScoreRadialGauge(
                    score: result.suitabilityScore,
                    size: 64,
                    strokeWidth: 6,
                    label: 'FIT',
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Metric Chips Row
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  if (result.materialProperties?.estimatedCostPerSqm != null)
                    _buildTag(
                      icon: Icons.attach_money,
                      label: '\$${result.materialProperties!.estimatedCostPerSqm!.toStringAsFixed(2)}/m²',
                      color: Colors.amber.shade700,
                    ),
                  if (result.sustainabilityScore != null)
                    _buildTag(
                      icon: Icons.eco_outlined,
                      label: 'Eco ${result.sustainabilityScore!.toStringAsFixed(0)}/10',
                      color: AppColors.secondary,
                    ),
                  if (result.materialProperties?.oxygenTransmissionRate != null)
                    _buildTag(
                      icon: Icons.shield_outlined,
                      label: 'OTR ${result.materialProperties!.oxygenTransmissionRate!.toStringAsFixed(0)}',
                      color: AppColors.primary,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTag({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.2), width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
