import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../models/recommendation_history.dart';
import '../../providers/history_provider.dart';
import '../../widgets/empty_error_state.dart';
import '../results/recommendation_result_screen.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String _sortBy = 'date_desc'; // date_desc, date_asc, score_desc, score_asc

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<RecommendationHistoryDTO> _filterAndSort(List<RecommendationHistoryDTO> items) {
    var filtered = items.where((item) {
      if (_searchQuery.isEmpty) return true;
      final food = item.foodCommodityName?.toLowerCase() ?? '';
      final mat = item.topMaterial?.toLowerCase() ?? '';
      final query = _searchQuery.toLowerCase();
      return food.contains(query) || mat.contains(query);
    }).toList();

    filtered.sort((a, b) {
      if (_sortBy == 'date_asc') {
        return (a.createdAt ?? '').compareTo(b.createdAt ?? '');
      } else if (_sortBy == 'score_desc') {
        return (b.topScore ?? 0.0).compareTo(a.topScore ?? 0.0);
      } else if (_sortBy == 'score_asc') {
        return (a.topScore ?? 0.0).compareTo(b.topScore ?? 0.0);
      }
      // default: date_desc
      return (b.createdAt ?? '').compareTo(a.createdAt ?? '');
    });

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final historyAsync = ref.watch(historyProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recommendation History'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort_outlined),
            tooltip: 'Sort History',
            onSelected: (val) {
              setState(() {
                _sortBy = val;
              });
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'date_desc', child: Text('Newest First')),
              PopupMenuItem(value: 'date_asc', child: Text('Oldest First')),
              PopupMenuItem(value: 'score_desc', child: Text('Highest Score')),
              PopupMenuItem(value: 'score_asc', child: Text('Lowest Score')),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: () {
              ref.read(historyProvider.notifier).refresh();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search food or packaging material...',
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
              onChanged: (val) {
                setState(() {
                  _searchQuery = val.trim();
                });
              },
            ),
          ),

          // History List
          Expanded(
            child: historyAsync.when(
              data: (items) {
                final filtered = _filterAndSort(items);

                if (filtered.isEmpty) {
                  return EmptyStateWidget(
                    icon: Icons.history_outlined,
                    title: _searchQuery.isNotEmpty
                        ? 'No matching history found'
                        : 'No recommendation history yet',
                    message: _searchQuery.isNotEmpty
                        ? 'Try searching with another keyword.'
                        : 'Generate recommendations in the "Recommend" tab to build your log.',
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => ref.read(historyProvider.notifier).refresh(),
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final item = filtered[index];
                      final score = item.topScore ?? 0.0;
                      final scoreColor = score >= 85
                          ? AppColors.scoreHigh
                          : score >= 70
                              ? AppColors.scoreMedium
                              : AppColors.scoreLow;

                      final formattedDate = item.createdAt != null && item.createdAt!.length >= 10
                          ? item.createdAt!.substring(0, 10)
                          : 'Recent';

                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => RecommendationResultScreen(
                                  requestId: item.id,
                                ),
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                // Circular Score Badge
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: scoreColor.withOpacity(0.12),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: scoreColor.withOpacity(0.3),
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${score.toStringAsFixed(0)}%',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w800,
                                        color: scoreColor,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 14),

                                // Details
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.foodCommodityName ?? 'Unknown Commodity',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 15,
                                        ),
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        item.topMaterial != null
                                            ? 'Top: ${item.topMaterial}'
                                            : 'Evaluation Completed',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(fontSize: 12.5),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          const Icon(Icons.calendar_today_outlined,
                                              size: 11, color: AppColors.textMutedLight),
                                          const SizedBox(width: 4),
                                          Text(
                                            formattedDate,
                                            style: const TextStyle(
                                              fontSize: 11,
                                              color: AppColors.textMutedLight,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 6, vertical: 1),
                                            decoration: BoxDecoration(
                                              color: AppColors.primaryContainer.withOpacity(0.5),
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              item.status ?? 'COMPLETED',
                                              style: const TextStyle(
                                                fontSize: 9.5,
                                                fontWeight: FontWeight.w700,
                                                color: AppColors.onPrimaryContainer,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),

                                const Icon(
                                  Icons.chevron_right,
                                  color: AppColors.textMutedLight,
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
                message: 'Loading recommendation logs...',
              ),
              error: (err, _) => ErrorStateWidget(
                message: err.toString(),
                onRetry: () => ref.read(historyProvider.notifier).refresh(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
