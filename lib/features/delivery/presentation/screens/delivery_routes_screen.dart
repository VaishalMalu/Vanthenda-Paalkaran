import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/delivery_provider.dart';
import '../../data/repositories/delivery_repository.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/premium_card.dart';
import '../../../../core/widgets/premium_button.dart';

class DeliveryRoutesScreen extends ConsumerStatefulWidget {
  const DeliveryRoutesScreen({super.key});

  @override
  ConsumerState<DeliveryRoutesScreen> createState() =>
      _DeliveryRoutesScreenState();
}

class _DeliveryRoutesScreenState
    extends ConsumerState<DeliveryRoutesScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(deliveryNotifierProvider.notifier).loadTodaysDeliveries(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final deliveriesState = ref.watch(deliveryNotifierProvider);
    final now = DateTime.now();
    final dateStr = '${now.day}/${now.month}/${now.year}';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Today's Route", style: AppTypography.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
            Text(dateStr, style: AppTypography.textTheme.bodySmall?.copyWith(color: AppColors.textSecondary)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref
                .read(deliveryNotifierProvider.notifier)
                .loadTodaysDeliveries(),
          ),
        ],
      ),
      body: deliveriesState.when(
        loading: () =>
            const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.error_outline,
                    size: 48, color: AppColors.error),
              ),
              const SizedBox(height: 16),
              Text('Could not load deliveries',
                  style: AppTypography.textTheme.titleMedium),
              const SizedBox(height: 16),
              PremiumButton(
                text: 'Retry',
                isOutlined: true,
                onPressed: () => ref
                    .read(deliveryNotifierProvider.notifier)
                    .loadTodaysDeliveries(),
              ),
            ],
          ),
        ),
        data: (deliveries) {
          if (deliveries.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.local_shipping_outlined,
                      size: 64, color: AppColors.border),
                  const SizedBox(height: 16),
                  Text(
                    'No deliveries today',
                    style: AppTypography.textTheme.titleMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          }
          final morning =
              deliveries.where((d) => d.session == 'morning').toList();
          final evening =
              deliveries.where((d) => d.session == 'evening').toList();

          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            children: [
              if (morning.isNotEmpty) ...[
                _SessionHeader(
                  title: 'Morning Session',
                  icon: Icons.wb_sunny_outlined,
                  color: AppColors.warning,
                  count: morning.length,
                  delivered: morning.where((d) => d.isDelivered).length,
                ),
                const SizedBox(height: 16),
                ...morning.map((d) => _DeliveryCard(
                      delivery: d,
                      onMarkDelivered: () => ref
                          .read(deliveryNotifierProvider.notifier)
                          .markDelivered(d.id),
                    )),
                const SizedBox(height: 32),
              ],
              if (evening.isNotEmpty) ...[
                _SessionHeader(
                  title: 'Evening Session',
                  icon: Icons.nights_stay_outlined,
                  color: AppColors.primary,
                  count: evening.length,
                  delivered: evening.where((d) => d.isDelivered).length,
                ),
                const SizedBox(height: 16),
                ...evening.map((d) => _DeliveryCard(
                      delivery: d,
                      onMarkDelivered: () => ref
                          .read(deliveryNotifierProvider.notifier)
                          .markDelivered(d.id),
                    )),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _SessionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final int count;
  final int delivered;

  const _SessionHeader({
    required this.title,
    required this.icon,
    required this.color,
    required this.count,
    required this.delivered,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Text(title, style: AppTypography.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.borderSubtle),
          ),
          child: Text(
            '$delivered / $count',
            style: AppTypography.textTheme.labelMedium?.copyWith(color: AppColors.textPrimary),
          ),
        ),
      ],
    );
  }
}

class _DeliveryCard extends StatelessWidget {
  final DeliveryModel delivery;
  final VoidCallback onMarkDelivered;

  const _DeliveryCard({
    required this.delivery,
    required this.onMarkDelivered,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: PremiumCard(
        padding: const EdgeInsets.all(16),
        hasShadow: false,
        backgroundColor: delivery.isDelivered ? AppColors.surfaceVariant : AppColors.surface,
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: delivery.isDelivered
                    ? AppColors.secondary.withOpacity(0.1)
                    : AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                delivery.isDelivered
                    ? Icons.check_circle
                    : Icons.water_drop_outlined,
                color: delivery.isDelivered
                    ? AppColors.secondary
                    : AppColors.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Customer #${delivery.customerId.substring(0, 8)}',
                    style: AppTypography.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      decoration: delivery.isDelivered ? TextDecoration.lineThrough : null,
                      color: delivery.isDelivered ? AppColors.textSecondary : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${delivery.quantity}L · ₹${delivery.totalAmount.toStringAsFixed(0)}',
                    style: AppTypography.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            if (!delivery.isDelivered)
              PremiumButton(
                text: 'Done',
                isOutlined: true,
                onPressed: onMarkDelivered,
              )
            else
              Text(
                'Completed',
                style: AppTypography.textTheme.labelSmall?.copyWith(
                  color: AppColors.secondary,
                  fontWeight: FontWeight.w700,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
