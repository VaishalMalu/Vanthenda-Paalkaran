import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/supabase_service.dart';

class CustomerModel {
  final String id;
  final String vendorId;
  final String name;
  final String phone;
  final String address;
  final String area;
  final double defaultMorningQty;
  final double defaultEveningQty;
  final String milkTypeId;
  final bool isActive;
  final DateTime createdAt;

  const CustomerModel({
    required this.id,
    required this.vendorId,
    required this.name,
    required this.phone,
    required this.address,
    required this.area,
    required this.defaultMorningQty,
    required this.defaultEveningQty,
    required this.milkTypeId,
    required this.isActive,
    required this.createdAt,
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json) => CustomerModel(
        id: json['id'] as String,
        vendorId: json['vendor_id'] as String,
        name: json['full_name'] as String,
        phone: json['phone'] as String? ?? '',
        address: json['address'] as String? ?? '',
        area: json['area'] as String? ?? '',
        defaultMorningQty:
            (json['default_morning_qty'] as num?)?.toDouble() ?? 0.0,
        defaultEveningQty:
            (json['default_evening_qty'] as num?)?.toDouble() ?? 0.0,
        milkTypeId: json['milk_type_id'] as String? ?? '',
        isActive: json['is_active'] as bool? ?? true,
        createdAt: DateTime.parse(json['created_at'] as String),
      );

  Map<String, dynamic> toJson() => {
        'vendor_id': vendorId,
        'full_name': name,
        'phone': phone,
        'address': address,
        'area': area,
        'default_morning_qty': defaultMorningQty,
        'default_evening_qty': defaultEveningQty,
        'milk_type_id': milkTypeId,
        'is_active': isActive,
      };

  CustomerModel copyWith({
    String? id,
    String? vendorId,
    String? name,
    String? phone,
    String? address,
    String? area,
    double? defaultMorningQty,
    double? defaultEveningQty,
    String? milkTypeId,
    bool? isActive,
    DateTime? createdAt,
  }) =>
      CustomerModel(
        id: id ?? this.id,
        vendorId: vendorId ?? this.vendorId,
        name: name ?? this.name,
        phone: phone ?? this.phone,
        address: address ?? this.address,
        area: area ?? this.area,
        defaultMorningQty: defaultMorningQty ?? this.defaultMorningQty,
        defaultEveningQty: defaultEveningQty ?? this.defaultEveningQty,
        milkTypeId: milkTypeId ?? this.milkTypeId,
        isActive: isActive ?? this.isActive,
        createdAt: createdAt ?? this.createdAt,
      );
}

final customerRepositoryProvider =
    Provider<CustomerRepository>((ref) => CustomerRepository());

class CustomerRepository {
  final _client = SupabaseService.client;

  Future<List<CustomerModel>> fetchCustomers() async {
    final vendorId = SupabaseService.currentUserId;
    if (vendorId == null) return [];
    final res = await _client
        .from('customers')
        .select()
        .eq('vendor_id', vendorId)
        .eq('is_active', true)
        .order('full_name');
    return (res as List).map((e) => CustomerModel.fromJson(e)).toList();
  }

  Future<CustomerModel> createCustomer(CustomerModel customer) async {
    final vendorId = SupabaseService.currentUserId;
    final data = customer.toJson();
    if (vendorId != null) data['vendor_id'] = vendorId;
    final res =
        await _client.from('customers').insert(data).select().single();
    return CustomerModel.fromJson(res);
  }

  Future<CustomerModel> updateCustomer(CustomerModel customer) async {
    final res = await _client
        .from('customers')
        .update(customer.toJson())
        .eq('id', customer.id)
        .select()
        .single();
    return CustomerModel.fromJson(res);
  }

  Future<void> deactivateCustomer(String customerId) async {
    await _client
        .from('customers')
        .update({'is_active': false})
        .eq('id', customerId);
  }
}
