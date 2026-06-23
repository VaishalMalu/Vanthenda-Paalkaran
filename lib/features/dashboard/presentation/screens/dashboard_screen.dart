import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/localization/localization_provider.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/premium_card.dart';
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

  String _timeOfDay(String langCode) {
    final hour = DateTime.now().hour;
    if (hour < 12) return AppLocalizations.tr(langCode, 'morning');
    if (hour < 17) return AppLocalizations.tr(langCode, 'afternoon');
    return AppLocalizations.tr(langCode, 'evening');
  }

  @override
  Widget build(BuildContext context) {
    final statsAsync = ref.watch(dashboardStatsProvider);
    final customerCountAsync = ref.watch(activeCustomerCountProvider);
    final langCode = ref.watch(languageProvider);

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
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _timeOfDay(langCode),
                                style: AppTypography.textTheme.bodyMedium?.copyWith(
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Vanthenda Paalkaran',
                                style: AppTypography.textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.5,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.subtleShadow,
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                )
                              ],
                              border: Border.all(color: AppColors.borderSubtle),
                            ),
                            child: IconButton(
                              onPressed: () => context.go(AppRoutes.settings),
                              icon: const Icon(Icons.settings_outlined, color: AppColors.textPrimary),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      
                      // Stats grid
                      statsAsync.when(
                        loading: () => const Center(child: CircularProgressIndicator()),
                        error: (e, _) => PremiumCard(
                          child: Text(
                            'Could not load stats',
                            style: AppTypography.textTheme.bodyMedium?.copyWith(
                              color: AppColors.error,
                            ),
                          ),
                        ),
                        data: (stats) => GridView.count(
                          crossAxisCount: 2,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 1.3,
                          children: [
                            customerCountAsync.when(
                              loading: () => const StatCard(
                                label: 'Customers',
                                value: '...',
                                icon: Icons.people_outline,
                                color: AppColors.accent,
                              ),
                              error: (_, __) => const StatCard(
                                label: 'Customers',
                                value: '—',
                                icon: Icons.people_outline,
                                color: AppColors.accent,
                              ),
                              data: (count) => StatCard(
                                label: 'Customers',
                                value: '$count',
                                icon: Icons.people_outline,
                                color: AppColors.accent,
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
                              icon: Icons.receipt_long_outlined,
                              color: AppColors.warning,
                            ),
                            StatCard(
                              label: 'This Month',
                              value: '${stats['month_count'] ?? 0}L',
                              icon: Icons.water_drop_outlined,
                              color: AppColors.primary,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),
                      
                      // Quick Actions
                      Text(
                        'Quick Actions',
                        style: AppTypography.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          _QuickAction(
                            icon: Icons.local_shipping_outlined,
                            label: "Today's Route",
                            color: AppColors.accent,
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
                            color: AppColors.primary,
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
            icon: Icon(Icons.people_outline),
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
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: (MediaQuery.of(context).size.width - 72) / 3, // Accounts for padding and spacing
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderSubtle),
          boxShadow: [
            BoxShadow(
              color: AppColors.subtleShadow,
              blurRadius: 8,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    color.withValues(alpha: 0.15),
                    color.withValues(alpha: 0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                border: Border.all(
                  color: color.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: AppTypography.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
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
