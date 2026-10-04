import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

class ScoreRadialGauge extends StatelessWidget {
  final double score; // 0 to 100
  final double size;
  final double strokeWidth;
  final String? label;
  final bool showPercentSign;

  const ScoreRadialGauge({
    super.key,
    required this.score,
    this.size = 110,
    this.strokeWidth = 9,
    this.label,
    this.showPercentSign = true,
  });

  Color _getScoreColor(double val) {
    if (val >= 85) return AppColors.scoreHigh;
    if (val >= 70) return AppColors.scoreMedium;
    return AppColors.scoreLow;
  }

  @override
  Widget build(BuildContext context) {
    final clampedScore = score.clamp(0.0, 100.0);
    final progress = clampedScore / 100.0;
    final color = _getScoreColor(clampedScore);

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background track
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: 1.0,
              strokeWidth: strokeWidth,
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).brightness == Brightness.dark
                    ? Colors.white.withOpacity(0.08)
                    : Colors.black.withOpacity(0.06),
              ),
            ),
          ),
          // Progress arc
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: strokeWidth,
              strokeCap: StrokeCap.round,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          // Inner score text
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    clampedScore.toStringAsFixed(0),
                    style: TextStyle(
                      fontSize: size * 0.32,
                      fontWeight: FontWeight.w800,
                      color: Theme.of(context).colorScheme.onSurface,
                      height: 1.0,
                    ),
                  ),
                  if (showPercentSign)
                    Text(
                      '%',
                      style: TextStyle(
                        fontSize: size * 0.16,
                        fontWeight: FontWeight.w700,
                        color: color,
                      ),
                    ),
                ],
              ),
              if (label != null) ...[
                const SizedBox(height: 2),
                Text(
                  label!,
                  style: TextStyle(
                    fontSize: size * 0.11,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
