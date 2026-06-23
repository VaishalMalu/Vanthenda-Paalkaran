import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/services/supabase_service.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/premium_card.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Settings',
          style: AppTypography.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // Profile section
          PremiumCard(
            padding: const EdgeInsets.all(24),
            hasShadow: false,
            child: Row(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.person_outline,
                      color: AppColors.primary, size: 32),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        SupabaseService.auth.currentUser?.email ?? 'Vendor',
                        style: AppTypography.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Milk Vendor',
                          style: AppTypography.textTheme.labelSmall?.copyWith(color: AppColors.textSecondary),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'App Preferences',
            style: AppTypography.textTheme.titleSmall?.copyWith(
              color: AppColors.textSecondary,
              letterSpacing: 0.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          PremiumCard(
            padding: EdgeInsets.zero,
            hasShadow: false,
            child: Column(
              children: [
                _SettingsTile(
                  icon: Icons.water_drop_outlined,
                  label: 'Milk Types & Pricing',
                  onTap: () => context.go(AppRoutes.milkTypes),
                ),
                const Divider(height: 1),
                _SettingsTile(
                  icon: Icons.group_outlined,
                  label: 'Staff Management',
                  onTap: () => context.go(AppRoutes.staff),
                ),
                const Divider(height: 1),
                _SettingsTile(
                  icon: Icons.beach_access_outlined,
                  label: 'Vacation Mode',
                  onTap: () => context.go(AppRoutes.vacation),
                ),
                const Divider(height: 1),
                _SettingsTile(
                  icon: Icons.analytics_outlined,
                  label: 'Analytics',
                  onTap: () => context.go(AppRoutes.analytics),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'Support & Account',
            style: AppTypography.textTheme.titleSmall?.copyWith(
              color: AppColors.textSecondary,
              letterSpacing: 0.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          PremiumCard(
            padding: EdgeInsets.zero,
            hasShadow: false,
            child: Column(
              children: [
                _SettingsTile(
                  icon: Icons.info_outline,
                  label: 'About App',
                  onTap: () => _showAbout(context),
                ),
                const Divider(height: 1),
                _SettingsTile(
                  icon: Icons.logout,
                  label: 'Sign Out',
                  iconColor: AppColors.error,
                  textColor: AppColors.error,
                  onTap: () => _confirmSignOut(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAbout(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Vanthenda Paalkaran',
      applicationVersion: '1.0.0',
      applicationLegalese: '© 2026 Vaishal',
    );
  }

  Future<void> _confirmSignOut(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Sign Out', style: AppTypography.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
        content: Text('Are you sure you want to sign out?', style: AppTypography.textTheme.bodyMedium),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.surface,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await SupabaseService.auth.signOut();
      if (context.mounted) context.go(AppRoutes.login);
    }
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? iconColor;
  final Color? textColor;

  const _SettingsTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.iconColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: (iconColor ?? AppColors.primary).withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: iconColor ?? AppColors.primary, size: 20),
      ),
      title: Text(
        label,
        style: AppTypography.textTheme.bodyLarge?.copyWith(
          color: textColor ?? AppColors.textPrimary,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: Icon(Icons.chevron_right, color: AppColors.textTertiary, size: 20),
      onTap: onTap,
    );
  }
}
