import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
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
      appBar: AppBar(title: const Text('Payments')),
      body: Column(
        children: [
          pendingAsync.when(
            loading: () => const LinearProgressIndicator(),
            error: (_, __) => const SizedBox.shrink(),
            data: (pending) => Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Pending Collections',
                            style: AppTypography.textTheme.bodySmall),
                        Text(
                          '₹${pending.toStringAsFixed(0)}',
                          style: AppTypography.textTheme.headlineMedium
                              ?.copyWith(
                                  color: AppColors.warning,
                                  fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.account_balance_wallet_outlined,
                      size: 36, color: AppColors.warning),
                ],
              ),
            ),
          ),
          Expanded(
            child: billsAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(
                    color: AppColors.primary),
              ),
              error: (e, _) => Center(
                child: Text('Error: $e',
                    style: AppTypography.textTheme.bodyMedium),
              ),
              data: (bills) {
                final unpaid =
                    bills.where((b) => !b.isPaid).toList();
                if (unpaid.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.check_circle_outline,
                            size: 64, color: AppColors.secondary),
                        const SizedBox(height: 16),
                        Text('All collected this month!',
                            style: AppTypography.textTheme.titleMedium
                                ?.copyWith(
                                    color: AppColors.secondary)),
                      ],
                    ),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: unpaid.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: 8),
                  itemBuilder: (context, i) =>
                      _PendingPaymentCard(bill: unpaid[i]),
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
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(bill.customerName,
                    style: AppTypography.textTheme.titleSmall),
                Text(
                  '${bill.billingMonth}/${bill.billingYear}',
                  style: AppTypography.textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Text(
            '₹${bill.amountDue.toStringAsFixed(0)}',
            style: AppTypography.textTheme.titleMedium?.copyWith(
              color: AppColors.warning,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
