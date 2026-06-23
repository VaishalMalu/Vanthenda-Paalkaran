import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/supabase_service.dart';

class BillModel {
  final String id;
  final String vendorId;
  final String customerId;
  final String customerName;
  final int billingMonth;
  final int billingYear;
  final double totalLiters;
  final double totalAmount;
  final double amountPaid;
  final double amountDue;
  final bool isPaid;
  final DateTime? paidAt;

  const BillModel({
    required this.id,
    required this.vendorId,
    required this.customerId,
    required this.customerName,
    required this.billingMonth,
    required this.billingYear,
    required this.totalLiters,
    required this.totalAmount,
    required this.amountPaid,
    required this.amountDue,
    required this.isPaid,
    this.paidAt,
  });

  factory BillModel.fromJson(Map<String, dynamic> json) => BillModel(
        id: json['id'] as String,
        vendorId: json['vendor_id'] as String,
        customerId: json['customer_id'] as String,
        customerName: json['customer_name'] as String? ?? '',
        billingMonth: json['billing_month'] as int,
        billingYear: json['billing_year'] as int,
        totalLiters: (json['total_liters'] as num?)?.toDouble() ?? 0,
        totalAmount: (json['total_amount'] as num?)?.toDouble() ?? 0,
        amountPaid: (json['amount_paid'] as num?)?.toDouble() ?? 0,
        amountDue: (json['amount_due'] as num?)?.toDouble() ?? 0,
        isPaid: json['is_paid'] as bool? ?? false,
        paidAt: json['paid_at'] != null
            ? DateTime.parse(json['paid_at'] as String)
            : null,
      );

  Map<String, dynamic> toJson() => {
        'customer_id': customerId,
        'customer_name': customerName,
        'billing_month': billingMonth,
        'billing_year': billingYear,
        'amount_due': amountDue,
        'is_paid': isPaid,
      };
}

final billingRepositoryProvider =
    Provider<BillingRepository>((ref) => BillingRepository());

class BillingRepository {
  final _client = SupabaseService.client;

  Future<List<BillModel>> fetchMonthlyBills() async {
    final now = DateTime.now();
    final res = await _client
        .from('bills')
        .select()
        .eq('billing_month', now.month)
        .eq('billing_year', now.year)
        .order('customer_name');
    return (res as List).map((e) => BillModel.fromJson(e)).toList();
  }

  Future<List<BillModel>> fetchBillsForCustomer(String customerId) async {
    final res = await _client
        .from('bills')
        .select()
        .eq('customer_id', customerId)
        .order('billing_year', ascending: false)
        .order('billing_month', ascending: false);
    return (res as List).map((e) => BillModel.fromJson(e)).toList();
  }

  Future<double> getPendingAmount() async {
    final res = await _client
        .from('bills')
        .select('pending_amount')
        .eq('is_paid', false);
    double total = 0;
    for (final b in (res as List)) {
      total += (b['pending_amount'] as num?)?.toDouble() ?? 0.0;
    }
    return total;
  }

  Future<void> generateMonthlyBills() async {
    final vendorId = SupabaseService.currentUserId;
    if (vendorId == null) return;
    await _client.rpc('generate_monthly_bills',
        params: {'p_vendor_id': vendorId});
  }

  Future<void> markAsPaid(String billId) async {
    await _client.from('bills').update({'is_paid': true}).eq('id', billId);
  }

  Future<void> recordPayment({
    required String billId,
    required double amount,
    required String paymentMethod,
  }) async {
    await _client.from('payments').insert({
      'bill_id': billId,
      'amount': amount,
      'payment_method': paymentMethod,
      'paid_at': DateTime.now().toIso8601String(),
    });
    await _client.from('bills').update({
      'amount_paid': amount,
      'amount_due': 0,
      'is_paid': true,
      'paid_at': DateTime.now().toIso8601String(),
    }).eq('id', billId);
  }
}
