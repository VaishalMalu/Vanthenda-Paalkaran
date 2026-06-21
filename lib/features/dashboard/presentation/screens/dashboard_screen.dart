import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../providers/dashboard_provider.dart';
import '../widgets/stat_card.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  int _selectedNavIndex = 0;

  void _onNavTap(int index) {
    if (index == _selectedNavIndex) return;
    setState(() => _selectedNavIndex = index);
    switch (index) {
      case 0:
        break; // Dashboard
      case 1:
        context.go(AppRoutes.customers);
        break;
      case 2:
        context.go(AppRoutes.delivery);
        break;
      case 3:
        context.go(AppRoutes.settings);
        break;
    }
  }

  String _timeOfDay() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Morning';
    if (hour < 17) return 'Afternoon';
    return 'Evening';
  }

  @override
  Widget build(BuildContext context) {
    final statsAsync = ref.watch(dashboardStatsProvider);
    final customerCountAsync = ref.watch(activeCustomerCountProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () async {
            ref.invalidate(dashboardStatsProvider);
            ref.invalidate(activeCustomerCountProvider);
          },
          child: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Good ${_timeOfDay()}!',
                                style: AppTypography.textTheme.bodyMedium?.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              Text(
                                'Vanthenda Paalkaran',
                                style: AppTypography.textTheme.headlineMedium,
                              ),
                            ],
                          ),
                          IconButton(
                            onPressed: () => context.go(AppRoutes.settings),
                            icon: const Icon(Icons.settings_outlined),
                            style: IconButton.styleFrom(
                              backgroundColor: AppColors.surface,
                              side: const BorderSide(color: AppColors.border),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      // Stats grid
                      statsAsync.when(
                        loading: () => const Center(child: CircularProgressIndicator()),
                        error: (e, _) => Text(
                          'Could not load stats',
                          style: AppTypography.textTheme.bodyMedium?.copyWith(
                            color: AppColors.error,
                          ),
                        ),
                        data: (stats) => GridView.count(
                          crossAxisCount: 2,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 1.2,
                          children: [
                            customerCountAsync.when(
                              loading: () => StatCard(
                                label: 'Customers',
                                value: '...',
                                icon: Icons.people_outlined,
                                color: AppColors.primary,
                              ),
                              error: (_, __) => StatCard(
                                label: 'Customers',
                                value: '—',
                                icon: Icons.people_outlined,
                                color: AppColors.primary,
                              ),
                              data: (count) => StatCard(
                                label: 'Customers',
                                value: '$count',
                                icon: Icons.people_outlined,
                                color: AppColors.primary,
                              ),
                            ),
                            StatCard(
                              label: "Today's Deliveries",
                              value: '${stats['today_count'] ?? 0}',
                              icon: Icons.local_shipping_outlined,
                              color: AppColors.secondary,
                            ),
                            StatCard(
                              label: 'Pending Bills',
                              value: '₹${stats['pending_amount'] ?? 0}',
                              icon: Icons.receipt_outlined,
                              color: AppColors.warning,
                            ),
                            StatCard(
                              label: 'This Month',
                              value: '${stats['month_count'] ?? 0}L',
                              icon: Icons.water_drop_outlined,
                              color: AppColors.info,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text('Quick Actions', style: AppTypography.textTheme.titleLarge),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          _QuickAction(
                            icon: Icons.local_shipping_outlined,
                            label: "Today's Route",
                            color: AppColors.primary,
                            onTap: () => context.go(AppRoutes.delivery),
                          ),
                          _QuickAction(
                            icon: Icons.person_add_outlined,
                            label: 'Add Customer',
                            color: AppColors.secondary,
                            onTap: () => context.go(AppRoutes.customers),
                          ),
                          _QuickAction(
                            icon: Icons.receipt_long_outlined,
                            label: 'Billing',
                            color: AppColors.warning,
                            onTap: () => context.go(AppRoutes.billing),
                          ),
                          _QuickAction(
                            icon: Icons.credit_card_outlined,
                            label: 'Milk Card',
                            color: AppColors.info,
                            onTap: () => context.go(AppRoutes.milkCard),
                          ),
                          _QuickAction(
                            icon: Icons.bar_chart_outlined,
                            label: 'Analytics',
                            color: AppColors.secondary,
                            onTap: () => context.go(AppRoutes.analytics),
                          ),
                          _QuickAction(
                            icon: Icons.beach_access_outlined,
                            label: 'Vacation',
                            color: AppColors.error,
                            onTap: () => context.go(AppRoutes.vacation),
                          ),
                          _QuickAction(
                            icon: Icons.warning_amber_outlined,
                            label: 'Emergency',
                            color: AppColors.error,
                            onTap: () => context.go(AppRoutes.emergency),
                          ),
                          _QuickAction(
                            icon: Icons.group_outlined,
                            label: 'Staff',
                            color: AppColors.textSecondary,
                            onTap: () => context.go(AppRoutes.staff),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedNavIndex,
        onTap: _onNavTap,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_outlined),
            activeIcon: Icon(Icons.people),
            label: 'Customers',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_shipping_outlined),
            activeIcon: Icon(Icons.local_shipping),
            label: 'Delivery',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            activeIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: (MediaQuery.of(context).size.width - 64) / 3,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: AppTypography.textTheme.labelSmall,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
