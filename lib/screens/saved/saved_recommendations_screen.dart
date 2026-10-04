import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/saved_provider.dart';
import '../../widgets/empty_error_state.dart';
import '../results/recommendation_result_screen.dart';

class SavedRecommendationsScreen extends ConsumerWidget {
  const SavedRecommendationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final savedAsync = ref.watch(savedProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Recommendations'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: () {
              ref.read(savedProvider.notifier).refresh();
            },
          ),
        ],
      ),
      body: savedAsync.when(
        data: (savedList) {
          if (savedList.isEmpty) {
            return const EmptyStateWidget(
              icon: Icons.bookmark_border,
              title: 'No saved recommendations',
              message:
                  'Bookmark recommendations using the bookmark icon on any result screen to access them quickly here.',
            );
          }

          return RefreshIndicator(
            onRefresh: () => ref.read(savedProvider.notifier).refresh(),
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: savedList.length,
              itemBuilder: (context, index) {
                final rec = savedList[index];
                final topMatch = rec.topRecommendation;
                final score = topMatch?.suitabilityScore ?? 0.0;
                final scoreColor = score >= 85
                    ? AppColors.scoreHigh
                    : score >= 70
                        ? AppColors.scoreMedium
                        : AppColors.scoreLow;

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => RecommendationResultScreen(
                            recommendation: rec,
                            requestId: rec.requestId,
                          ),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  rec.foodCommodityName ?? 'Food Commodity',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.bookmark_remove_outlined,
                                  color: AppColors.error,
                                  size: 20,
                                ),
                                tooltip: 'Remove from saved',
                                onPressed: () async {
                                  if (rec.requestId != null) {
                                    await ref
                                        .read(savedProvider.notifier)
                                        .unsaveRecommendation(rec.requestId!);
                                    if (!context.mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Removed from saved recommendations'),
                                      ),
                                    );
                                  }
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          if (topMatch != null) ...[
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: scoreColor.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    '${score.toStringAsFixed(1)}% Match',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 11.5,
                                      color: scoreColor,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    topMatch.materialName,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Theme.of(context).colorScheme.onSurface,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                rec.createdAt != null && rec.createdAt!.length >= 10
                                    ? 'Saved: ${rec.createdAt!.substring(0, 10)}'
                                    : 'Saved recently',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textMutedLight,
                                ),
                              ),
                              const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'View Match',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  SizedBox(width: 4),
                                  Icon(Icons.arrow_forward_ios,
                                      size: 11, color: AppColors.primary),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
        loading: () => const LoadingStateWidget(
          message: 'Loading saved recommendations...',
        ),
        error: (err, _) => ErrorStateWidget(
          message: err.toString(),
          onRetry: () => ref.read(savedProvider.notifier).refresh(),
        ),
      ),
    );
  }
}
