import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/supabase_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

// ─── Model ──────────────────────────────────────────────────────────────────

class MilkTypeModel {
  final String id;
  final String vendorId;
  final String name;
  final double pricePerLiter;
  final bool isActive;

  const MilkTypeModel({
    required this.id,
    required this.vendorId,
    required this.name,
    required this.pricePerLiter,
    required this.isActive,
  });

  factory MilkTypeModel.fromJson(Map<String, dynamic> json) => MilkTypeModel(
        id: json['id'] as String,
        vendorId: json['vendor_id'] as String,
        name: json['name'] as String,
        pricePerLiter: (json['price_per_liter'] as num).toDouble(),
        isActive: json['is_active'] as bool? ?? true,
      );

  Map<String, dynamic> toJson() => {
        'vendor_id': vendorId,
        'name': name,
        'price_per_liter': pricePerLiter,
        'is_active': isActive,
      };
}

// ─── Provider ────────────────────────────────────────────────────────────────

class MilkTypesNotifier extends Notifier<AsyncValue<List<MilkTypeModel>>> {
  @override
  AsyncValue<List<MilkTypeModel>> build() {
    _load();
    return const AsyncValue.loading();
  }

  Future<void> _load() async {
    final vendorId = SupabaseService.currentUserId;
    if (vendorId == null) {
      state = const AsyncData([]);
      return;
    }
    try {
      final res = await SupabaseService.client
          .from('milk_types')
          .select()
          .eq('vendor_id', vendorId)
          .eq('is_active', true)
          .order('name');
      state = AsyncData(
          (res as List).map((e) => MilkTypeModel.fromJson(e)).toList());
    } on Exception catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }

  Future<void> add(String name, double price) async {
    try {
      final vendorId = SupabaseService.currentUserId;
      await SupabaseService.client.from('milk_types').insert({
        'vendor_id': vendorId,
        'name': name,
        'price_per_liter': price,
        'is_active': true,
      });
      await _load();
    } on Exception catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }

  Future<void> updatePrice(String id, double price) async {
    try {
      await SupabaseService.client
          .from('milk_types')
          .update({'price_per_liter': price})
          .eq('id', id);
      await _load();
    } on Exception catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }

  Future<void> delete(String id) async {
    try {
      await SupabaseService.client
          .from('milk_types')
          .update({'is_active': false})
          .eq('id', id);
      await _load();
    } on Exception catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }
}

// ─── Screen ──────────────────────────────────────────────────────────────────

final milkTypesNotifierProvider =
    NotifierProvider<MilkTypesNotifier, AsyncValue<List<MilkTypeModel>>>(
  MilkTypesNotifier.new,
);

class MilkTypesScreen extends ConsumerWidget {
  const MilkTypesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(milkTypesNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Milk Types & Pricing')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddSheet(context, ref),
        child: const Icon(Icons.add),
      ),
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Text('Error: $e',
              style: AppTypography.textTheme.bodyMedium
                  ?.copyWith(color: AppColors.error)),
        ),
        data: (types) {
          if (types.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.water_drop_outlined,
                      size: 64, color: AppColors.textTertiary),
                  const SizedBox(height: 16),
                  Text('No milk types yet',
                      style: AppTypography.textTheme.titleMedium
                          ?.copyWith(color: AppColors.textSecondary)),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () => _showAddSheet(context, ref),
                    child: const Text('Add Milk Type'),
                  ),
                ],
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: types.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, i) => _MilkTypeCard(
              type: types[i],
              onEdit: () => _showEditSheet(context, ref, types[i]),
              onDelete: () =>
                  ref.read(milkTypesNotifierProvider.notifier).delete(types[i].id),
            ),
          );
        },
      ),
    );
  }

  void _showAddSheet(BuildContext context, WidgetRef ref) {
    final nameCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
          left: 16,
          right: 16,
          top: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Add Milk Type',
                style: AppTypography.textTheme.titleLarge),
            const SizedBox(height: 16),
            TextField(
                controller: nameCtrl,
                decoration:
                    const InputDecoration(labelText: 'Name (e.g. Cow, Buffalo)')),
            const SizedBox(height: 12),
            TextField(
              controller: priceCtrl,
              keyboardType: TextInputType.number,
              decoration:
                  const InputDecoration(labelText: 'Price per Liter (₹)'),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final price =
                      double.tryParse(priceCtrl.text.trim()) ?? 0;
                  if (nameCtrl.text.trim().isNotEmpty && price > 0) {
                    ref
                        .read(milkTypesNotifierProvider.notifier)
                        .add(nameCtrl.text.trim(), price);
                    Navigator.pop(ctx);
                  }
                },
                child: const Text('Add'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditSheet(
      BuildContext context, WidgetRef ref, MilkTypeModel type) {
    final priceCtrl =
        TextEditingController(text: type.pricePerLiter.toString());
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
          left: 16,
          right: 16,
          top: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Edit Price — ${type.name}',
                style: AppTypography.textTheme.titleLarge),
            const SizedBox(height: 16),
            TextField(
              controller: priceCtrl,
              keyboardType: TextInputType.number,
              decoration:
                  const InputDecoration(labelText: 'New Price per Liter (₹)'),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final price =
                      double.tryParse(priceCtrl.text.trim()) ?? 0;
                  if (price > 0) {
                    ref
                        .read(milkTypesNotifierProvider.notifier)
                        .updatePrice(type.id, price);
                    Navigator.pop(ctx);
                  }
                },
                child: const Text('Update Price'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MilkTypeCard extends StatelessWidget {
  final MilkTypeModel type;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _MilkTypeCard({
    required this.type,
    required this.onEdit,
    required this.onDelete,
  });

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
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.water_drop_outlined,
                color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(type.name, style: AppTypography.textTheme.titleSmall),
                Text('₹${type.pricePerLiter.toStringAsFixed(2)}/L',
                    style: AppTypography.textTheme.bodySmall),
              ],
            ),
          ),
          IconButton(
              icon: const Icon(Icons.edit_outlined, size: 20),
              onPressed: onEdit),
          IconButton(
              icon: const Icon(Icons.delete_outline,
                  size: 20, color: AppColors.error),
              onPressed: onDelete),
        ],
      ),
    );
  }
}
