import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/delivery_provider.dart';
import '../../data/repositories/delivery_repository.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

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
        title: Text("Today's Route — $dateStr"),
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
              const Icon(Icons.error_outline,
                  size: 48, color: AppColors.error),
              const SizedBox(height: 12),
              Text('Could not load deliveries',
                  style: AppTypography.textTheme.bodyLarge),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => ref
                    .read(deliveryNotifierProvider.notifier)
                    .loadTodaysDeliveries(),
                child: const Text('Retry'),
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
                      size: 64,
                      color: AppColors.textTertiary),
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
            padding: const EdgeInsets.all(16),
            children: [
              if (morning.isNotEmpty) ...[
                _SessionHeader(
                  title: 'Morning Session',
                  icon: Icons.wb_sunny_outlined,
                  color: AppColors.warning,
                  count: morning.length,
                  delivered: morning.where((d) => d.isDelivered).length,
                ),
                const SizedBox(height: 8),
                ...morning.map((d) => _DeliveryCard(
                      delivery: d,
                      onMarkDelivered: () => ref
                          .read(deliveryNotifierProvider.notifier)
                          .markDelivered(d.id),
                    )),
                const SizedBox(height: 16),
              ],
              if (evening.isNotEmpty) ...[
                _SessionHeader(
                  title: 'Evening Session',
                  icon: Icons.nights_stay_outlined,
                  color: AppColors.info,
                  count: evening.length,
                  delivered: evening.where((d) => d.isDelivered).length,
                ),
                const SizedBox(height: 8),
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
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Text(title, style: AppTypography.textTheme.titleMedium),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '$delivered/$count done',
            style: AppTypography.textTheme.labelSmall?.copyWith(color: color),
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
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: delivery.isDelivered
              ? AppColors.secondary.withValues(alpha: 0.4)
              : AppColors.border,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: delivery.isDelivered
                  ? AppColors.secondary.withValues(alpha: 0.12)
                  : AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              delivery.isDelivered
                  ? Icons.check_circle_outline
                  : Icons.water_drop_outlined,
              color: delivery.isDelivered
                  ? AppColors.secondary
                  : AppColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Customer #${delivery.customerId.substring(0, 8)}',
                  style: AppTypography.textTheme.titleSmall,
                ),
                Text(
                  '${delivery.quantity}L · ₹${delivery.totalAmount.toStringAsFixed(0)}',
                  style: AppTypography.textTheme.bodySmall,
                ),
              ],
            ),
          ),
          if (!delivery.isDelivered)
            TextButton(
              onPressed: onMarkDelivered,
              child: const Text('Mark Done'),
            )
          else
            Text(
              'Delivered',
              style: AppTypography.textTheme.labelSmall?.copyWith(
                color: AppColors.secondary,
              ),
            ),
        ],
      ),
    );
  }
}
