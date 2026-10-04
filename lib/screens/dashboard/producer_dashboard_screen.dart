import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../providers/auth_provider.dart';
import '../../providers/dashboard_provider.dart';
import '../../providers/recommendation_provider.dart';
import '../../widgets/empty_error_state.dart';
import '../../widgets/stat_kpi_card.dart';
import '../recommendation/recommendation_wizard_screen.dart';
import '../results/recommendation_result_screen.dart';

class ProducerDashboardScreen extends ConsumerWidget {
  final void Function(int tabIndex)? onNavigateTab;

  const ProducerDashboardScreen({super.key, this.onNavigateTab});

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final dashboardAsync = ref.watch(producerDashboardProvider);

    final user = authState.user;
    final displayName = user?.username.isNotEmpty == true
        ? user!.username[0].toUpperCase() + user.username.substring(1)
        : 'Producer';

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.primaryContainer,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.eco_rounded,
                size: 20,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              AppStrings.appName,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Dashboard',
            onPressed: () {
              ref.invalidate(producerDashboardProvider);
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(producerDashboardProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User Greeting Banner
              Text(
                '${_getGreeting()}, $displayName 👋',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      fontSize: 22,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                'Find optimal, sustainable packaging with AI precision.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),

              const SizedBox(height: 18),

              // Hero AI Recommendation CTA Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0F766E), Color(0xFF0D9488)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
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
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.auto_awesome, size: 14, color: Colors.white),
                              SizedBox(width: 5),
                              Text(
                                'XGBoost + SHAP Engine',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.biotech_outlined,
                          color: Colors.white70,
                          size: 28,
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'AI Packaging Assistant',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Input food commodity moisture, pH, storage conditions, and barrier requirements to generate Top 3 packaging materials.',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 18),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.primaryDark,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        ref.read(recommendationProvider.notifier).resetForm();
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const RecommendationWizardScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.rocket_launch, size: 18),
                      label: const Text(
                        'Get Recommendation',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn().slideY(begin: 0.1, end: 0),

              const SizedBox(height: 24),

              // KPI Statistics Section
              Text(
                'Performance Overview',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 12),

              dashboardAsync.when(
                data: (dash) {
                  return Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: StatKpiCard(
                              title: 'Recommendations',
                              value: '${dash.totalRecommendations}',
                              subtitle: 'Generated',
                              icon: Icons.analytics_outlined,
                              iconColor: AppColors.primary,
                              iconBackgroundColor: AppColors.primaryContainer,
                              onTap: () => onNavigateTab?.call(1),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: StatKpiCard(
                              title: 'Saved Matches',
                              value: '${dash.savedRecommendations}',
                              subtitle: 'Bookmarked',
                              icon: Icons.bookmark_added_outlined,
                              iconColor: AppColors.accent,
                              iconBackgroundColor: AppColors.accentContainer,
                              onTap: () => onNavigateTab?.call(2),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: StatKpiCard(
                              title: 'Avg Suitability',
                              value: dash.avgSuitabilityScore > 0
                                  ? '${dash.avgSuitabilityScore.toStringAsFixed(1)}%'
                                  : '0%',
                              subtitle: 'High Precision',
                              icon: Icons.verified_outlined,
                              iconColor: AppColors.secondary,
                              iconBackgroundColor: AppColors.secondaryContainer,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: StatKpiCard(
                              title: 'Top Material',
                              value: dash.mostRecommendedMaterial?.split(' ').first ?? 'N/A',
                              subtitle: dash.mostRecommendedMaterial ?? 'No data',
                              icon: Icons.inventory_2_outlined,
                              iconColor: Colors.amber.shade700,
                              iconBackgroundColor: Colors.amber.shade100,
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
                loading: () => const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: LoadingStateWidget(message: 'Loading performance metrics...'),
                ),
                error: (err, _) => ErrorStateWidget(
                  message: err.toString(),
                  onRetry: () => ref.invalidate(producerDashboardProvider),
                ),
              ),

              const SizedBox(height: 24),

              // Recent Recommendations List Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recent Recommendations',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  TextButton(
                    onPressed: () => onNavigateTab?.call(1),
                    child: const Text('View All'),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Recent List Content
              dashboardAsync.when(
                data: (dash) {
                  if (dash.recentRecommendations.isEmpty) {
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Center(
                          child: Column(
                            children: [
                              const Icon(
                                Icons.hourglass_empty_rounded,
                                size: 36,
                                color: AppColors.textMutedLight,
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'No recommendations yet',
                                style: Theme.of(context).textTheme.titleSmall,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Tap "Get Recommendation" above to generate your first AI match.',
                                style: Theme.of(context).textTheme.bodySmall,
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }

                  return Column(
                    children: dash.recentRecommendations.take(3).map((item) {
                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          leading: CircleAvatar(
                            backgroundColor: AppColors.primaryContainer,
                            child: const Icon(
                              Icons.science_outlined,
                              color: AppColors.primary,
                              size: 20,
                            ),
                          ),
                          title: Text(
                            item.foodCommodityName ?? 'Food Commodity',
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          subtitle: Text(
                            item.topMaterial != null
                                ? 'Top: ${item.topMaterial}'
                                : 'Pending Evaluation',
                            style: const TextStyle(fontSize: 12),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (item.topScore != null)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.secondaryContainer,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '${item.topScore!.toStringAsFixed(1)}%',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 12,
                                      color: AppColors.onSecondaryContainer,
                                    ),
                                  ),
                                ),
                              const SizedBox(width: 6),
                              const Icon(Icons.chevron_right, size: 20),
                            ],
                          ),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => RecommendationResultScreen(
                                  requestId: item.id,
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    }).toList(),
                  );
                },
                loading: () => const SizedBox.shrink(),
                error: (err, stack) => const SizedBox.shrink(),
              ),

              const SizedBox(height: 20),

              // Sustainability Insight Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.secondaryContainer.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.secondary.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        color: AppColors.secondary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.eco, color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Sustainability Target',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                              color: AppColors.onSecondaryContainer,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Optimized barrier matching extends food shelf life by up to 40% while reducing single-use plastic waste.',
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).textTheme.bodyMedium?.color,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
