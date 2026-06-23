import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/supabase_service.dart';

class StaffModel {
  final String id;
  final String vendorId;
  final String name;
  final String phone;
  final String role;
  final String? passcode;
  final bool isActive;
  final DateTime createdAt;

  const StaffModel({
    required this.id,
    required this.vendorId,
    required this.name,
    required this.phone,
    required this.role,
    this.passcode,
    required this.isActive,
    required this.createdAt,
  });

  factory StaffModel.fromJson(Map<String, dynamic> json) => StaffModel(
        id: json['id'] as String,
        vendorId: json['vendor_id'] as String,
        name: json['name'] as String,
        phone: json['phone'] as String? ?? '',
        role: json['role'] as String? ?? 'delivery',
        passcode: json['passcode'] as String?,
        isActive: json['is_active'] as bool? ?? true,
        createdAt: DateTime.parse(json['created_at'] as String),
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'phone': phone,
        'role': role,
        'passcode': passcode,
        'is_active': isActive,
      };
}

final staffRepositoryProvider =
    Provider<StaffRepository>((ref) => StaffRepository());

class StaffRepository {
  final _client = SupabaseService.client;

  Future<List<StaffModel>> fetchStaff() async {
    final res = await _client
        .from('staff')
        .select()
        .eq('is_active', true)
        .order('name');
    return (res as List).map((e) => StaffModel.fromJson(e)).toList();
  }

  Future<void> createStaff(StaffModel staff) async {
    final staffJson = staff.toJson();
    await _client.from('staff').insert(staffJson);
  }

  Future<void> updateStaff(StaffModel staff) async {
    await _client
        .from('staff')
        .update(staff.toJson())
        .eq('id', staff.id);
  }

  Future<void> deactivateStaff(String id) async {
    await _client
        .from('staff')
        .update({'is_active': false})
        .eq('id', id);
  }
}
