import '../../../../core/services/supabase_service.dart';

class DemandForecast {
  final String customerId;
  final String customerName;
  final double predictedMorningQty;
  final double predictedEveningQty;

  const DemandForecast({
    required this.customerId,
    required this.customerName,
    required this.predictedMorningQty,
    required this.predictedEveningQty,
  });
}

class DemandForecastingService {
  /// Predicts tomorrow's demand for each customer based on
  /// the average deliveries in the past 7 days.
  static Future<List<DemandForecast>> forecastTomorrow() async {
    final vendorId = SupabaseService.currentUserId;
    if (vendorId == null) return [];

    // Fetch past 7 days of deliveries with customer info
    final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
    final dateStr = sevenDaysAgo.toIso8601String().split('T')[0];

    final res = await SupabaseService.client
        .from('deliveries')
        .select('customer_id, session, quantity, customers(full_name)')
        .eq('vendor_id', vendorId)
        .gte('delivery_date', dateStr)
        .eq('is_delivered', true);

    // Aggregate by customer
    final Map<String, Map<String, dynamic>> customerData = {};

    for (final d in (res as List)) {
      final cid = d['customer_id'] as String;
      final name = d['customers'] != null
          ? (d['customers']['full_name'] as String? ?? 'Unknown')
          : 'Unknown';
      final session = d['session'] as String;
      final qty = (d['quantity'] as num).toDouble();

      customerData.putIfAbsent(cid, () => {
            'name': name,
            'morning_total': 0.0,
            'morning_count': 0,
            'evening_total': 0.0,
            'evening_count': 0,
          });

      if (session == 'morning') {
        customerData[cid]!['morning_total'] =
            (customerData[cid]!['morning_total'] as double) + qty;
        customerData[cid]!['morning_count'] =
            (customerData[cid]!['morning_count'] as int) + 1;
      } else {
        customerData[cid]!['evening_total'] =
            (customerData[cid]!['evening_total'] as double) + qty;
        customerData[cid]!['evening_count'] =
            (customerData[cid]!['evening_count'] as int) + 1;
      }
    }

    // Build forecasts
    return customerData.entries.map((entry) {
      final data = entry.value;
      final morningCount = data['morning_count'] as int;
      final eveningCount = data['evening_count'] as int;

      return DemandForecast(
        customerId: entry.key,
        customerName: data['name'] as String,
        predictedMorningQty: morningCount > 0
            ? (data['morning_total'] as double) / morningCount
            : 0,
        predictedEveningQty: eveningCount > 0
            ? (data['evening_total'] as double) / eveningCount
            : 0,
      );
    }).toList();
  }

  /// Returns a simple day-by-day volume for the last N days.
  static Future<Map<String, double>> dailyVolumeLastNDays(int n) async {
    final vendorId = SupabaseService.currentUserId;
    if (vendorId == null) return {};

    final results = <String, double>{};
    for (int i = n - 1; i >= 0; i--) {
      final day = DateTime.now().subtract(Duration(days: i + 1));
      final key =
          '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
      results[key] = 0;
    }

    final startDate = DateTime.now()
        .subtract(Duration(days: n))
        .toIso8601String()
        .split('T')[0];

    final res = await SupabaseService.client
        .from('deliveries')
        .select('delivery_date, quantity')
        .eq('vendor_id', vendorId)
        .gte('delivery_date', startDate)
        .eq('is_delivered', true);

    for (final d in (res as List)) {
      final date = d['delivery_date'] as String;
      final qty = (d['quantity'] as num).toDouble();
      if (results.containsKey(date)) {
        results[date] = results[date]! + qty;
      }
    }

    return results;
  }
}
