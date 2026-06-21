import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../delivery/presentation/providers/delivery_provider.dart';
import '../../../customer/data/repositories/customer_repository.dart';
import '../../../customer/presentation/providers/customers_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

class MilkCardScreen extends ConsumerStatefulWidget {
  const MilkCardScreen({super.key});

  @override
  ConsumerState<MilkCardScreen> createState() => _MilkCardScreenState();
}

class _MilkCardScreenState extends ConsumerState<MilkCardScreen> {
  CustomerModel? _selectedCustomer;
  late DateTime _currentMonth;

  @override
  void initState() {
    super.initState();
    _currentMonth = DateTime(DateTime.now().year, DateTime.now().month);
    Future.microtask(
        () => ref.read(customerNotifierProvider.notifier).loadCustomers());
  }

  void _prevMonth() {
    setState(() {
      _currentMonth =
          DateTime(_currentMonth.year, _currentMonth.month - 1);
    });
  }

  void _nextMonth() {
    final next = DateTime(_currentMonth.year, _currentMonth.month + 1);
    if (next.isBefore(DateTime.now().add(const Duration(days: 31)))) {
      setState(() => _currentMonth = next);
    }
  }

  @override
  Widget build(BuildContext context) {
    final customersState = ref.watch(customerNotifierProvider);
    final monthLabel =
        DateFormat('MMMM yyyy').format(_currentMonth);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Milk Card')),
      body: Column(
        children: [
          // Customer selector
          Padding(
            padding: const EdgeInsets.all(16),
            child: customersState.when(
              loading: () => const LinearProgressIndicator(),
              error: (_, __) =>
                  const Text('Could not load customers'),
              data: (customers) => DropdownButtonFormField<CustomerModel>(
                value: _selectedCustomer,
                hint: const Text('Select customer'),
                decoration: const InputDecoration(
                    labelText: 'Customer',
                    prefixIcon: Icon(Icons.person_outline)),
                items: customers
                    .map((c) => DropdownMenuItem(
                          value: c,
                          child: Text(c.name),
                        ))
                    .toList(),
                onChanged: (c) => setState(() => _selectedCustomer = c),
              ),
            ),
          ),
          // Month navigation
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: _prevMonth,
                  icon: const Icon(Icons.chevron_left),
                ),
                Text(monthLabel,
                    style: AppTypography.textTheme.titleMedium),
                IconButton(
                  onPressed: _nextMonth,
                  icon: const Icon(Icons.chevron_right),
                ),
              ],
            ),
          ),
          const Divider(),
          // Milk card grid
          if (_selectedCustomer == null)
            Expanded(
              child: Center(
                child: Text(
                  'Select a customer to view milk card',
                  style: AppTypography.textTheme.bodyMedium
                      ?.copyWith(color: AppColors.textSecondary),
                ),
              ),
            )
          else
            Expanded(
              child: Consumer(
                builder: (context, ref, _) {
                  final from = DateTime(
                      _currentMonth.year, _currentMonth.month, 1);
                  final to = DateTime(
                      _currentMonth.year, _currentMonth.month + 1, 0);
                  final deliveriesAsync = ref.watch(
                    customerMilkCardProvider((
                      customerId: _selectedCustomer!.id,
                      from: from,
                      to: to,
                    )),
                  );
                  return deliveriesAsync.when(
                    loading: () => const Center(
                        child: CircularProgressIndicator()),
                    error: (e, _) => Center(
                      child: Text('Error: $e',
                          style: AppTypography.textTheme.bodyMedium),
                    ),
                    data: (deliveries) {
                      final daysInMonth = to.day;
                      double totalLiters = 0;
                      for (final d in deliveries) {
                        totalLiters += d.quantity;
                      }

                      return Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceAround,
                              children: [
                                _SummaryPill(
                                  label: 'Total Liters',
                                  value:
                                      '${totalLiters.toStringAsFixed(1)}L',
                                  color: AppColors.primary,
                                ),
                                _SummaryPill(
                                  label: 'Deliveries',
                                  value: '${deliveries.length}',
                                  color: AppColors.secondary,
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: GridView.builder(
                              padding: const EdgeInsets.all(16),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 7,
                                mainAxisSpacing: 4,
                                crossAxisSpacing: 4,
                                childAspectRatio: 1,
                              ),
                              itemCount: daysInMonth,
                              itemBuilder: (context, idx) {
                                final day = idx + 1;
                                final date = DateTime(
                                    _currentMonth.year,
                                    _currentMonth.month,
                                    day);
                                final dayDeliveries =
                                    deliveries.where((d) =>
                                        d.deliveryDate.day == day &&
                                        d.deliveryDate.month ==
                                            _currentMonth.month);
                                final hasDelivery =
                                    dayDeliveries.isNotEmpty;
                                final allDelivered = dayDeliveries
                                    .every((d) => d.isDelivered);

                                return Container(
                                  decoration: BoxDecoration(
                                    color: hasDelivery
                                        ? (allDelivered
                                            ? AppColors.secondary
                                                .withValues(alpha: 0.2)
                                            : AppColors.warning
                                                .withValues(alpha: 0.2))
                                        : AppColors.background,
                                    borderRadius:
                                        BorderRadius.circular(6),
                                    border: Border.all(
                                      color: date.day ==
                                              DateTime.now().day &&
                                          date.month ==
                                              DateTime.now().month &&
                                          date.year == DateTime.now().year
                                          ? AppColors.primary
                                          : AppColors.border,
                                      width: date.day ==
                                              DateTime.now().day &&
                                          date.month ==
                                              DateTime.now().month
                                          ? 2
                                          : 1,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      '$day',
                                      style: AppTypography
                                          .textTheme.labelSmall
                                          ?.copyWith(
                                        color: hasDelivery
                                            ? AppColors.textPrimary
                                            : AppColors.textTertiary,
                                        fontWeight: hasDelivery
                                            ? FontWeight.w600
                                            : FontWeight.w400,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _SummaryPill extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _SummaryPill({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(value,
              style: AppTypography.textTheme.titleLarge
                  ?.copyWith(color: color)),
          Text(label,
              style: AppTypography.textTheme.bodySmall
                  ?.copyWith(color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}
