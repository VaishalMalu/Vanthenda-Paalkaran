import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/premium_card.dart';
import '../../../billing/data/repositories/billing_repository.dart';
import '../../../billing/presentation/providers/billing_provider.dart';

class PaymentsScreen extends ConsumerWidget {
  const PaymentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final billsAsync = ref.watch(currentMonthBillsProvider);
    final pendingAsync = ref.watch(totalPendingAmountProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Payments',
          style: AppTypography.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
      body: Column(
        children: [
          pendingAsync.when(
            loading: () => const LinearProgressIndicator(),
            error: (_, __) => const SizedBox.shrink(),
            data: (pending) => Padding(
              padding: const EdgeInsets.all(16),
              child: PremiumCard(
                backgroundColor: AppColors.warning,
                hasShadow: true,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Pending Collections',
                            style: AppTypography.textTheme.bodyMedium?.copyWith(
                              color: AppColors.surface.withOpacity(0.9),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '₹${pending.toStringAsFixed(0)}',
                            style: AppTypography.textTheme.displayMedium?.copyWith(
                                color: AppColors.surface,
                                fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.surface.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.account_balance_wallet_outlined,
                          size: 32, color: AppColors.surface),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: billsAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
              error: (e, _) => Center(
                child: Text('Error: $e', style: AppTypography.textTheme.bodyMedium),
              ),
              data: (bills) {
                final unpaid = bills.where((b) => !b.isPaid).toList();
                if (unpaid.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: AppColors.secondary.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.check_circle_outline,
                              size: 48, color: AppColors.secondary),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'All collected this month!',
                          style: AppTypography.textTheme.titleLarge?.copyWith(
                              color: AppColors.secondary, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  itemCount: unpaid.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, i) => _PendingPaymentCard(bill: unpaid[i]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _PendingPaymentCard extends StatelessWidget {
  final BillModel bill;

  const _PendingPaymentCard({required this.bill});

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      padding: const EdgeInsets.all(16),
      hasShadow: false,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.warning.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.timer_outlined, color: AppColors.warning),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  bill.customerName,
                  style: AppTypography.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  '${bill.billingMonth}/${bill.billingYear}',
                  style: AppTypography.textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          Text(
            '₹${bill.amountDue.toStringAsFixed(0)}',
            style: AppTypography.textTheme.titleLarge?.copyWith(
              color: AppColors.warning,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
