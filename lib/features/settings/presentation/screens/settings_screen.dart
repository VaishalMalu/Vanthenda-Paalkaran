import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/services/supabase_service.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Profile section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                  child: const Icon(Icons.person_outline,
                      color: AppColors.primary, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        SupabaseService.auth.currentUser?.email ?? 'Vendor',
                        style: AppTypography.textTheme.titleMedium,
                      ),
                      Text(
                        'Milk Vendor',
                        style: AppTypography.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text('App', style: AppTypography.textTheme.titleSmall),
          const SizedBox(height: 8),
          _SettingsTile(
            icon: Icons.water_drop_outlined,
            label: 'Milk Types & Pricing',
            onTap: () => context.go(AppRoutes.milkTypes),
          ),
          _SettingsTile(
            icon: Icons.group_outlined,
            label: 'Staff Management',
            onTap: () => context.go(AppRoutes.staff),
          ),
          _SettingsTile(
            icon: Icons.beach_access_outlined,
            label: 'Vacation Mode',
            onTap: () => context.go(AppRoutes.vacation),
          ),
          _SettingsTile(
            icon: Icons.analytics_outlined,
            label: 'Analytics',
            onTap: () => context.go(AppRoutes.analytics),
          ),
          const SizedBox(height: 16),
          Text('Help & Info', style: AppTypography.textTheme.titleSmall),
          const SizedBox(height: 8),
          _SettingsTile(
            icon: Icons.info_outline,
            label: 'About App',
            onTap: () => _showAbout(context),
          ),
          const SizedBox(height: 16),
          _SettingsTile(
            icon: Icons.logout,
            label: 'Sign Out',
            iconColor: AppColors.error,
            onTap: () => _confirmSignOut(context),
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
      applicationLegalese: '© 2025 Vaishal',
    );
  }

  Future<void> _confirmSignOut(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
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

  const _SettingsTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: ListTile(
        leading: Icon(icon,
            color: iconColor ?? AppColors.textSecondary),
        title:
            Text(label, style: AppTypography.textTheme.bodyMedium),
        trailing: const Icon(Icons.chevron_right,
            color: AppColors.textTertiary),
        onTap: onTap,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
