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
        name: json['name'] as String? ?? 'Unknown',
        phone: json['phone'] as String? ?? '',
        address: json['address'] as String? ?? '',
        area: json['area'] as String? ?? '',
        defaultMorningQty:
            (json['default_morning_qty'] as num?)?.toDouble() ?? 0.0,
        defaultEveningQty:
            (json['default_evening_qty'] as num?)?.toDouble() ?? 0.0,
        milkTypeId: json['default_milk_type_id'] as String? ?? '',
        isActive: json['is_active'] as bool? ?? true,
        createdAt: DateTime.parse(json['created_at'] as String),
      );

  Map<String, dynamic> toJson() => {
        // 'vendor_id' is omitted, let DB set it via DEFAULT get_vendor_id()
        'name': name,
        'phone': phone,
        'address': address,
        // 'area': area, // DB doesn't have area column, ignore
        'default_morning_qty': defaultMorningQty,
        'default_evening_qty': defaultEveningQty,
        if (milkTypeId.isNotEmpty) 'default_milk_type_id': milkTypeId,
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
  }) {
    return CustomerModel(
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
}

final customerRepositoryProvider =
    Provider<CustomerRepository>((ref) => CustomerRepository());

class CustomerRepository {
  final _client = SupabaseService.client;

  Future<List<CustomerModel>> fetchCustomers() async {
    // We don't filter by vendor_id here because RLS handles it!
    final res = await _client
        .from('customers')
        .select()
        .eq('is_active', true)
        .order('name');
    return (res as List).map((e) => CustomerModel.fromJson(e)).toList();
  }

  Future<CustomerModel> createCustomer(CustomerModel customer) async {
    final data = customer.toJson();
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
