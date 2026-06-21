import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/customers_provider.dart';
import '../../data/repositories/customer_repository.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

class CustomersListScreen extends ConsumerStatefulWidget {
  const CustomersListScreen({super.key});

  @override
  ConsumerState<CustomersListScreen> createState() =>
      _CustomersListScreenState();
}

class _CustomersListScreenState
    extends ConsumerState<CustomersListScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(customerNotifierProvider.notifier).loadCustomers(),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final customersState = ref.watch(customerNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Customers'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(64),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: SearchBar(
              controller: _searchController,
              hintText: 'Search customers...',
              leading: const Icon(Icons.search),
              trailing: _searchQuery.isNotEmpty
                  ? [
                      IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    ]
                  : null,
              onChanged: (q) => setState(() => _searchQuery = q),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddCustomerSheet(context),
        child: const Icon(Icons.person_add_outlined),
      ),
      body: customersState.when(
        loading: () =>
            const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline,
                  size: 48, color: AppColors.error),
              const SizedBox(height: 12),
              Text('Could not load customers',
                  style: AppTypography.textTheme.bodyLarge),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => ref
                    .read(customerNotifierProvider.notifier)
                    .loadCustomers(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (customers) {
          final filtered = _searchQuery.isEmpty
              ? customers
              : customers
                  .where((c) =>
                      c.name
                          .toLowerCase()
                          .contains(_searchQuery.toLowerCase()) ||
                      c.phone.contains(_searchQuery) ||
                      c.area
                          .toLowerCase()
                          .contains(_searchQuery.toLowerCase()))
                  .toList();

          if (filtered.isEmpty) {
            return Center(
              child: Text(
                _searchQuery.isEmpty
                    ? 'No customers yet'
                    : 'No results for "$_searchQuery"',
                style: AppTypography.textTheme.bodyMedium
                    ?.copyWith(color: AppColors.textSecondary),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async =>
                ref.read(customerNotifierProvider.notifier).loadCustomers(),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: filtered.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, i) =>
                  _CustomerCard(customer: filtered[i]),
            ),
          );
        },
      ),
    );
  }

  void _showAddCustomerSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _AddCustomerSheet(
        onAdd: (customer) {
          ref.read(customerNotifierProvider.notifier).addCustomer(customer);
        },
      ),
    );
  }
}

class _CustomerCard extends StatelessWidget {
  final CustomerModel customer;

  const _CustomerCard({required this.customer});

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
          CircleAvatar(
            backgroundColor:
                AppColors.primary.withValues(alpha: 0.12),
            child: Text(
              customer.name.isNotEmpty
                  ? customer.name[0].toUpperCase()
                  : '?',
              style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(customer.name,
                    style: AppTypography.textTheme.titleSmall),
                const SizedBox(height: 2),
                Text(
                  '${customer.phone} · ${customer.area}',
                  style: AppTypography.textTheme.bodySmall,
                ),
                const SizedBox(height: 2),
                Text(
                  'Morning: ${customer.defaultMorningQty}L  Evening: ${customer.defaultEveningQty}L',
                  style: AppTypography.textTheme.bodySmall?.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AddCustomerSheet extends StatefulWidget {
  final void Function(CustomerModel) onAdd;

  const _AddCustomerSheet({required this.onAdd});

  @override
  State<_AddCustomerSheet> createState() => _AddCustomerSheetState();
}

class _AddCustomerSheetState extends State<_AddCustomerSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _areaCtrl = TextEditingController();
  double _morningQty = 0.5;
  double _eveningQty = 0.5;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    _areaCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        left: 16,
        right: 16,
        top: 20,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Add Customer',
                style: AppTypography.textTheme.titleLarge),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameCtrl,
              decoration:
                  const InputDecoration(labelText: 'Full Name'),
              validator: (v) =>
                  v == null || v.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _phoneCtrl,
              keyboardType: TextInputType.phone,
              decoration:
                  const InputDecoration(labelText: 'Phone'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _areaCtrl,
              decoration:
                  const InputDecoration(labelText: 'Area'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _addressCtrl,
              decoration:
                  const InputDecoration(labelText: 'Address'),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: _morningQty.toString(),
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                        labelText: 'Morning (L)'),
                    onChanged: (v) =>
                        _morningQty = double.tryParse(v) ?? 0.5,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    initialValue: _eveningQty.toString(),
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                        labelText: 'Evening (L)'),
                    onChanged: (v) =>
                        _eveningQty = double.tryParse(v) ?? 0.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (!_formKey.currentState!.validate()) return;
                  final customer = CustomerModel(
                    id: '',
                    vendorId: '',
                    name: _nameCtrl.text.trim(),
                    phone: _phoneCtrl.text.trim(),
                    address: _addressCtrl.text.trim(),
                    area: _areaCtrl.text.trim(),
                    defaultMorningQty: _morningQty,
                    defaultEveningQty: _eveningQty,
                    milkTypeId: '',
                    isActive: true,
                    createdAt: DateTime.now(),
                  );
                  widget.onAdd(customer);
                  Navigator.pop(context);
                },
                child: const Text('Add Customer'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
