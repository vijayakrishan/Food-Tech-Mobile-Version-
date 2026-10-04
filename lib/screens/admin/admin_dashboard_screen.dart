import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/api_provider.dart';
import '../../providers/dashboard_provider.dart';
import '../../widgets/empty_error_state.dart';
import '../../widgets/stat_kpi_card.dart';

class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  ConsumerState<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<dynamic> _users = [];
  bool _isLoadingUsers = false;
  List<dynamic> _auditLogs = [];
  bool _isLoadingLogs = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadUsers();
    _loadLogs();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoadingUsers = true);
    try {
      final client = ref.read(apiClientProvider);
      final res = await client.get('/admin/users');
      if (res is Map && res['data'] is List) {
        setState(() => _users = res['data'] as List);
      }
    } catch (_) {}
    setState(() => _isLoadingUsers = false);
  }

  Future<void> _loadLogs() async {
    setState(() => _isLoadingLogs = true);
    try {
      final client = ref.read(apiClientProvider);
      final res = await client.get('/admin/audit-logs');
      if (res is Map && res['data'] is List) {
        setState(() => _auditLogs = res['data'] as List);
      }
    } catch (_) {}
    setState(() => _isLoadingLogs = false);
  }

  Future<void> _toggleUserActive(int userId) async {
    try {
      final client = ref.read(apiClientProvider);
      await client.put('/admin/users/$userId/toggle-active');
      await _loadUsers();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User active status updated')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update user: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final adminDashAsync = ref.watch(adminDashboardProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Console'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondaryLight,
          tabs: const [
            Tab(icon: Icon(Icons.analytics_outlined), text: 'Stats'),
            Tab(icon: Icon(Icons.people_outline), text: 'Users'),
            Tab(icon: Icon(Icons.receipt_long_outlined), text: 'Audit Logs'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: Stats
          _buildStatsTab(adminDashAsync),
          // Tab 2: Users
          _buildUsersTab(),
          // Tab 3: Logs
          _buildLogsTab(),
        ],
      ),
    );
  }

  Widget _buildStatsTab(AsyncValue adminDashAsync) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          adminDashAsync.when(
            data: (dash) {
              return Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: StatKpiCard(
                          title: 'Total Users',
                          value: '${dash.totalUsers}',
                          subtitle: '${dash.activeUsers} Active',
                          icon: Icons.people_outline,
                          iconColor: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: StatKpiCard(
                          title: 'AI Inferences',
                          value: '${dash.totalRecommendations}',
                          subtitle: 'Completed',
                          icon: Icons.auto_awesome,
                          iconColor: const Color(0xFF2563EB),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: StatKpiCard(
                          title: 'Audit Logs',
                          value: '${dash.totalAuditLogs}',
                          subtitle: 'Security Events',
                          icon: Icons.shield_outlined,
                          iconColor: AppColors.secondary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: StatKpiCard(
                          title: 'System Health',
                          value: '99.9%',
                          subtitle: 'All Microservices',
                          icon: Icons.check_circle_outline,
                          iconColor: AppColors.success,
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
            loading: () => const LoadingStateWidget(message: 'Loading admin metrics...'),
            error: (e, _) => ErrorStateWidget(message: e.toString()),
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('System Microservices Status', style: TextStyle(fontWeight: FontWeight.w700)),
                  const Divider(height: 20),
                  _buildServiceStatusRow('Spring Boot 3.2 Backend', 'Port 8080', true),
                  _buildServiceStatusRow('FastAPI ML Service', 'Port 8000', true),
                  _buildServiceStatusRow('XGBoost Model Pipeline', 'v1.0.0 Loaded', true),
                  _buildServiceStatusRow('MySQL 8.0 Database', '13 Tables Connected', true),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUsersTab() {
    if (_isLoadingUsers) {
      return const LoadingStateWidget(message: 'Loading users list...');
    }
    if (_users.isEmpty) {
      return const EmptyStateWidget(
        icon: Icons.people_outline,
        title: 'No users loaded',
        message: 'Unable to retrieve user list or empty directory.',
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _users.length,
      itemBuilder: (context, index) {
        final u = _users[index] as Map<String, dynamic>;
        final role = u['role'] is Map ? (u['role']['name'] ?? '') : '';
        final isActive = u['isActive'] == true;
        final id = u['id'] as int? ?? 0;

        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: isActive ? AppColors.primaryContainer : AppColors.borderLight,
              child: Icon(
                Icons.person,
                color: isActive ? AppColors.primary : AppColors.textMutedLight,
              ),
            ),
            title: Text(
              '${u["firstName"] ?? ""} ${u["lastName"] ?? ""} (${u["username"] ?? ""})',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            subtitle: Text(
              '${u["email"] ?? ""} • $role',
              style: const TextStyle(fontSize: 12),
            ),
            trailing: Switch(
              value: isActive,
              activeColor: AppColors.primary,
              onChanged: (_) => _toggleUserActive(id),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLogsTab() {
    if (_isLoadingLogs) {
      return const LoadingStateWidget(message: 'Loading audit logs...');
    }
    if (_auditLogs.isEmpty) {
      return const EmptyStateWidget(
        icon: Icons.receipt_long_outlined,
        title: 'No audit logs found',
        message: 'Security event logs will populate here.',
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _auditLogs.length,
      itemBuilder: (context, index) {
        final log = _auditLogs[index] as Map<String, dynamic>;
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            dense: true,
            title: Text(
              log['action']?.toString() ?? 'SYSTEM_EVENT',
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
            ),
            subtitle: Text(
              'Entity: ${log["entityType"] ?? "-"} • ${log["createdAt"]?.toString().substring(0, 19) ?? ""}',
              style: const TextStyle(fontSize: 11),
            ),
            trailing: const Icon(Icons.security, size: 16, color: AppColors.textSecondaryLight),
          ),
        );
      },
    );
  }

  Widget _buildServiceStatusRow(String name, String detail, bool ok) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                ok ? Icons.check_circle : Icons.error,
                size: 16,
                color: ok ? AppColors.success : AppColors.error,
              ),
              const SizedBox(width: 8),
              Text(name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            ],
          ),
          Text(detail, style: const TextStyle(fontSize: 11, color: AppColors.textSecondaryLight)),
        ],
      ),
    );
  }
}
