import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../delivery/data/repositories/delivery_repository.dart';
import '../../../customer/data/repositories/customer_repository.dart';
import '../../../customer/presentation/providers/customers_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/premium_card.dart';
import '../../../../core/widgets/premium_button.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/localization/localization_provider.dart';

class MilkCardScreen extends ConsumerStatefulWidget {
  const MilkCardScreen({super.key});

  @override
  ConsumerState<MilkCardScreen> createState() => _MilkCardScreenState();
}

class _MilkCardScreenState extends ConsumerState<MilkCardScreen> {
  CustomerModel? _selectedCustomer;
  late String _session;
  double _quantity = 1.0;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _session = DateTime.now().hour < 12 ? 'morning' : 'evening';
    Future.microtask(() => ref.read(customerNotifierProvider.notifier).loadCustomers());
  }

  void _onCustomerSelected(CustomerModel? customer) {
    setState(() {
      _selectedCustomer = customer;
      if (customer != null) {
        _quantity = _session == 'morning' ? customer.defaultMorningQty : customer.defaultEveningQty;
        if (_quantity == 0) _quantity = 1.0;
      }
    });
  }

  void _onSessionChanged(String session) {
    setState(() {
      _session = session;
      if (_selectedCustomer != null) {
        _quantity = session == 'morning' ? _selectedCustomer!.defaultMorningQty : _selectedCustomer!.defaultEveningQty;
        if (_quantity == 0) _quantity = 1.0;
      }
    });
  }

  Future<void> _markAsGiven() async {
    if (_selectedCustomer == null) return;
    setState(() => _isLoading = true);

    try {
      final repo = ref.read(deliveryRepositoryProvider);
      final delivery = DeliveryModel(
        id: '',
        vendorId: '',
        customerId: _selectedCustomer!.id,
        milkTypeId: '',
        deliveryDate: DateTime.now(),
        session: _session,
        quantity: _quantity,
        pricePerLiter: 50.0, // Assuming static or from somewhere else
        totalAmount: 50.0 * _quantity,
        isDelivered: true,
        isExtraMilk: false,
      );

      await repo.createDelivery(delivery);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Text(AppLocalizations.tr(ref.read(languageProvider), 'attendance_success')),
              ],
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final customersState = ref.watch(customerNotifierProvider);
    final langCode = ref.watch(languageProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          AppLocalizations.tr(langCode, 'milk_card'),
          style: AppTypography.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. SELECT CUSTOMER
            Text(AppLocalizations.tr(langCode, 'select_customer'), style: AppTypography.textTheme.titleMedium),
            const SizedBox(height: 8),
            customersState.when(
              loading: () => const LinearProgressIndicator(),
              error: (_, __) => const Text('Error loading customers'),
              data: (customers) => PremiumCard(
                hasShadow: false,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<CustomerModel>(
                    isExpanded: true,
                    value: _selectedCustomer,
                    hint: Text(AppLocalizations.tr(langCode, 'select_customer')),
                    items: customers.map((c) => DropdownMenuItem(
                      value: c,
                      child: Row(
                        children: [
                          const Icon(Icons.person, color: AppColors.primary, size: 20),
                          const SizedBox(width: 12),
                          Text(c.name, style: AppTypography.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
                        ],
                      ),
                    )).toList(),
                    onChanged: _onCustomerSelected,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 2. SESSION
            Text(AppLocalizations.tr(langCode, 'session'), style: AppTypography.textTheme.titleMedium),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _SessionToggle(
                    title: AppLocalizations.tr(langCode, 'morning'),
                    icon: Icons.wb_sunny_outlined,
                    isSelected: _session == 'morning',
                    onTap: () => _onSessionChanged('morning'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _SessionToggle(
                    title: AppLocalizations.tr(langCode, 'evening'),
                    icon: Icons.nights_stay_outlined,
                    isSelected: _session == 'evening',
                    onTap: () => _onSessionChanged('evening'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // 3. QUANTITY
            Text(AppLocalizations.tr(langCode, 'quantity'), style: AppTypography.textTheme.titleMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [0.5, 1.0, 1.5, 2.0].map((q) => _QuantityChip(
                quantity: q,
                isSelected: _quantity == q,
                onTap: () => setState(() => _quantity = q),
              )).toList(),
            ),
            const SizedBox(height: 48),

            // 4. MARK AS GIVEN
            SizedBox(
              height: 70,
              child: ElevatedButton(
                onPressed: _selectedCustomer == null || _isLoading ? null : _markAsGiven,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: AppColors.border,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  elevation: 8,
                  shadowColor: AppColors.secondary.withOpacity(0.4),
                ),
                child: _isLoading 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.check_circle_outline, size: 32),
                        const SizedBox(width: 12),
                        Text(
                          AppLocalizations.tr(langCode, 'mark_as_given'),
                          style: AppTypography.textTheme.headlineSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SessionToggle extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _SessionToggle({
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.05) : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? AppColors.primary : AppColors.textSecondary, size: 28),
            const SizedBox(height: 8),
            Text(
              title,
              style: AppTypography.textTheme.bodyLarge?.copyWith(
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuantityChip extends StatelessWidget {
  final double quantity;
  final bool isSelected;
  final VoidCallback onTap;

  const _QuantityChip({
    required this.quantity,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80,
        height: 60,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accent : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.accent : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected ? [
            BoxShadow(
              color: AppColors.accent.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            )
          ] : null,
        ),
        child: Text(
          '${quantity}L',
          style: AppTypography.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: isSelected ? Colors.white : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
