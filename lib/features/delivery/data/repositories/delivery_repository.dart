import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/supabase_service.dart';

class DeliveryModel {
  final String id;
  final String vendorId;
  final String customerId;
  final String milkTypeId;
  final DateTime deliveryDate;
  final String session; // 'morning' | 'evening'
  final double quantity;
  final double pricePerLiter;
  final double totalAmount;
  final bool isDelivered;
  final bool isExtraMilk;

  const DeliveryModel({
    required this.id,
    required this.vendorId,
    required this.customerId,
    required this.milkTypeId,
    required this.deliveryDate,
    required this.session,
    required this.quantity,
    required this.pricePerLiter,
    required this.totalAmount,
    required this.isDelivered,
    required this.isExtraMilk,
  });

  factory DeliveryModel.fromJson(Map<String, dynamic> json) => DeliveryModel(
        id: json['id'] as String,
        vendorId: json['vendor_id'] as String,
        customerId: json['customer_id'] as String,
        milkTypeId: json['milk_type_id'] as String? ?? '',
        deliveryDate: DateTime.parse(json['delivery_date'] as String),
        session: json['session'] as String,
        quantity: (json['quantity'] as num).toDouble(),
        pricePerLiter: (json['price_per_liter'] as num).toDouble(),
        totalAmount: (json['total_amount'] as num).toDouble(),
        isDelivered: json['is_delivered'] as bool? ?? false,
        isExtraMilk: json['is_extra_milk'] as bool? ?? false,
      );

  Map<String, dynamic> toJson() => {
        // 'vendor_id' is omitted, DB handles it via DEFAULT get_vendor_id()
        'customer_id': customerId,
        'milk_type_id': milkTypeId,
        'delivery_date': deliveryDate.toIso8601String().split('T')[0],
        'session': session,
        'quantity': quantity,
        'price_per_liter': pricePerLiter,
        'total_amount': totalAmount,
        'is_delivered': isDelivered,
        'is_extra_milk': isExtraMilk,
      };
}

final deliveryRepositoryProvider =
    Provider<DeliveryRepository>((ref) => DeliveryRepository());

class DeliveryRepository {
  final _client = SupabaseService.client;

  Future<List<DeliveryModel>> fetchTodaysDeliveries() async {
    final today = DateTime.now().toIso8601String().split('T')[0];
    final res = await _client
        .from('deliveries')
        .select()
        .eq('delivery_date', today)
        .order('session');
    return (res as List).map((e) => DeliveryModel.fromJson(e)).toList();
  }

  Future<List<DeliveryModel>> fetchCustomerDeliveries({
    required String customerId,
    required DateTime from,
    required DateTime to,
  }) async {
    final res = await _client
        .from('deliveries')
        .select()
        .eq('customer_id', customerId)
        .gte('delivery_date', from.toIso8601String().split('T')[0])
        .lte('delivery_date', to.toIso8601String().split('T')[0])
        .order('delivery_date');
    return (res as List).map((e) => DeliveryModel.fromJson(e)).toList();
  }

  Future<DeliveryModel> createDelivery(DeliveryModel delivery) async {
    final res = await _client
        .from('deliveries')
        .insert(delivery.toJson())
        .select()
        .single();
    return DeliveryModel.fromJson(res);
  }

  Future<void> markDelivered(String deliveryId) async {
    await _client
        .from('deliveries')
        .update({'is_delivered': true})
        .eq('id', deliveryId);
  }

  Future<Map<String, dynamic>> fetchDashboardStats() async {
    final today = DateTime.now().toIso8601String().split('T')[0];
    final firstOfMonth =
        DateTime(DateTime.now().year, DateTime.now().month, 1)
            .toIso8601String()
            .split('T')[0];

    final todayRes = await _client
        .from('deliveries')
        .select('id')
        .eq('delivery_date', today);

    final monthRes = await _client
        .from('deliveries')
        .select('quantity')
        .gte('delivery_date', firstOfMonth);

    final pendingRes = await _client
        .from('bills')
        .select('pending_amount')
        .neq('status', 'paid');

    double totalQty = 0;
    for (final d in (monthRes as List)) {
      totalQty += (d['quantity'] as num).toDouble();
    }

    double pendingAmount = 0;
    for (final b in (pendingRes as List)) {
      pendingAmount += (b['pending_amount'] as num).toDouble();
    }

    return {
      'today_count': (todayRes as List).length,
      'month_count': totalQty.toStringAsFixed(1),
      'pending_amount': pendingAmount.toStringAsFixed(0),
    };
  }
}
