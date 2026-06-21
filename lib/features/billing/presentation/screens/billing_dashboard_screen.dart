import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/billing_provider.dart';
import '../../data/repositories/billing_repository.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

class BillingDashboardScreen extends ConsumerStatefulWidget {
  const BillingDashboardScreen({super.key});

  @override
  ConsumerState<BillingDashboardScreen> createState() =>
      _BillingDashboardScreenState();
}

class _BillingDashboardScreenState
    extends ConsumerState<BillingDashboardScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
        () => ref.read(billingNotifierProvider.notifier).loadBills());
  }

  @override
  Widget build(BuildContext context) {
    final billsState = ref.watch(billingNotifierProvider);
    final pendingAsync = ref.watch(totalPendingAmountProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Billing'),
        actions: [
          IconButton(
            icon: const Icon(Icons.autorenew),
            tooltip: 'Generate Bills',
            onPressed: () => _confirmGenerate(context),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async =>
            ref.read(billingNotifierProvider.notifier).loadBills(),
        child: Column(
          children: [
            // Summary card
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
                          Text('Total Pending',
                              style: AppTypography.textTheme.bodySmall),
                          Text(
                            '₹${NumberFormat('#,##0').format(pending)}',
                            style: AppTypography.textTheme.headlineSmall
                                ?.copyWith(
                                    color: AppColors.warning,
                                    fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.receipt_long_outlined,
                        size: 36,
                        color: AppColors.warning.withValues(alpha: 0.5)),
                  ],
                ),
              ),
            ),
            Expanded(
              child: billsState.when(
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline,
                          size: 48, color: AppColors.error),
                      const SizedBox(height: 12),
                      Text('Could not load bills',
                          style: AppTypography.textTheme.bodyLarge),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () => ref
                            .read(billingNotifierProvider.notifier)
                            .loadBills(),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
                data: (bills) {
                  if (bills.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.receipt_outlined,
                              size: 64, color: AppColors.textTertiary),
                          const SizedBox(height: 16),
                          Text('No bills this month',
                              style: AppTypography.textTheme.titleMedium
                                  ?.copyWith(
                                      color: AppColors.textSecondary)),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: () => _confirmGenerate(context),
                            child: const Text('Generate Bills'),
                          ),
                        ],
                      ),
                    );
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: bills.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: 8),
                    itemBuilder: (context, i) => _BillCard(
                      bill: bills[i],
                      onPay: () => _showPaymentSheet(context, bills[i]),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmGenerate(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Generate Bills'),
        content: const Text(
            'Generate bills for all active customers this month?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Generate')),
        ],
      ),
    );
    if (confirm == true) {
      await ref.read(billingNotifierProvider.notifier).generateBills();
    }
  }

  void _showPaymentSheet(BuildContext context, BillModel bill) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _PaymentSheet(
        bill: bill,
        onRecord: (method) {
          ref.read(billingNotifierProvider.notifier).recordPayment(
                billId: bill.id,
                amount: bill.amountDue,
                method: method,
              );
        },
      ),
    );
  }
}

class _BillCard extends StatelessWidget {
  final BillModel bill;
  final VoidCallback onPay;

  const _BillCard({required this.bill, required this.onPay});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: bill.isPaid
              ? AppColors.secondary.withValues(alpha: 0.4)
              : AppColors.border,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(bill.customerName,
                    style: AppTypography.textTheme.titleSmall),
                const SizedBox(height: 4),
                Text(
                  '${bill.totalLiters.toStringAsFixed(1)}L · ₹${bill.totalAmount.toStringAsFixed(0)}',
                  style: AppTypography.textTheme.bodySmall,
                ),
              ],
            ),
          ),
          if (bill.isPaid)
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.secondary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text('Paid',
                  style: AppTypography.textTheme.labelSmall
                      ?.copyWith(color: AppColors.secondary)),
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '₹${bill.amountDue.toStringAsFixed(0)}',
                  style: AppTypography.textTheme.titleMedium?.copyWith(
                    color: AppColors.warning,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                TextButton(
                  onPressed: onPay,
                  style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(60, 28)),
                  child: const Text('Record Payment'),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _PaymentSheet extends StatefulWidget {
  final BillModel bill;
  final void Function(String method) onRecord;

  const _PaymentSheet({required this.bill, required this.onRecord});

  @override
  State<_PaymentSheet> createState() => _PaymentSheetState();
}

class _PaymentSheetState extends State<_PaymentSheet> {
  String _method = 'cash';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        left: 16,
        right: 16,
        top: 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Record Payment',
              style: AppTypography.textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(
            'Customer: ${widget.bill.customerName}\nAmount: ₹${widget.bill.amountDue.toStringAsFixed(0)}',
            style: AppTypography.textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          Text('Payment Method',
              style: AppTypography.textTheme.titleSmall),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: ['cash', 'upi', 'bank_transfer'].map((m) {
              return ChoiceChip(
                label: Text(m.replaceAll('_', ' ').toUpperCase()),
                selected: _method == m,
                onSelected: (_) => setState(() => _method = m),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                widget.onRecord(_method);
                Navigator.pop(context);
              },
              child: const Text('Confirm Payment'),
            ),
          ),
        ],
      ),
    );
  }
}
