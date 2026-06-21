import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:intl/intl.dart';
import '../../../../core/services/supabase_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

part 'emergency_requests_screen.g.dart';

class EmergencyRequest {
  final String id;
  final String customerId;
  final String customerName;
  final String type;
  final String note;
  final DateTime requestDate;
  final bool isResolved;

  const EmergencyRequest({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.type,
    required this.note,
    required this.requestDate,
    required this.isResolved,
  });

  factory EmergencyRequest.fromJson(Map<String, dynamic> json) =>
      EmergencyRequest(
        id: json['id'] as String,
        customerId: json['customer_id'] as String,
        customerName: json['customers'] != null
            ? (json['customers']['full_name'] as String? ?? 'Unknown')
            : 'Unknown',
        type: json['type'] as String? ?? 'general',
        note: json['note'] as String? ?? '',
        requestDate:
            DateTime.parse(json['request_date'] as String),
        isResolved: json['is_resolved'] as bool? ?? false,
      );
}

@riverpod
class EmergencyNotifier extends _$EmergencyNotifier {
  @override
  AsyncValue<List<EmergencyRequest>> build() {
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
          .from('emergency_requests')
          .select('*, customers(full_name)')
          .eq('vendor_id', vendorId)
          .order('request_date', ascending: false);
      state = AsyncData(
          (res as List).map((e) => EmergencyRequest.fromJson(e)).toList());
    } on Exception catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }

  Future<void> resolve(String id) async {
    await SupabaseService.client
        .from('emergency_requests')
        .update({'is_resolved': true})
        .eq('id', id);
    await _load();
  }
}

class EmergencyRequestsScreen extends ConsumerWidget {
  const EmergencyRequestsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(emergencyNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Emergency Requests'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                ref.invalidate(emergencyNotifierProvider),
          ),
        ],
      ),
      body: state.when(
        loading: () =>
            const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Text('Error: $e',
              style: AppTypography.textTheme.bodyMedium
                  ?.copyWith(color: AppColors.error)),
        ),
        data: (requests) {
          if (requests.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check_circle_outline,
                      size: 64, color: AppColors.secondary),
                  const SizedBox(height: 16),
                  Text('No emergency requests',
                      style: AppTypography.textTheme.titleMedium
                          ?.copyWith(color: AppColors.secondary)),
                ],
              ),
            );
          }
          final pending =
              requests.where((r) => !r.isResolved).toList();
          final resolved =
              requests.where((r) => r.isResolved).toList();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (pending.isNotEmpty) ...[
                Text('Pending (${pending.length})',
                    style: AppTypography.textTheme.titleMedium
                        ?.copyWith(color: AppColors.error)),
                const SizedBox(height: 8),
                ...pending.map((r) => _RequestCard(
                      request: r,
                      onResolve: () => ref
                          .read(emergencyNotifierProvider.notifier)
                          .resolve(r.id),
                    )),
                const SizedBox(height: 16),
              ],
              if (resolved.isNotEmpty) ...[
                Text('Resolved (${resolved.length})',
                    style: AppTypography.textTheme.titleMedium
                        ?.copyWith(color: AppColors.secondary)),
                const SizedBox(height: 8),
                ...resolved.map((r) =>
                    _RequestCard(request: r, onResolve: null)),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _RequestCard extends StatelessWidget {
  final EmergencyRequest request;
  final VoidCallback? onResolve;

  const _RequestCard({required this.request, this.onResolve});

  @override
  Widget build(BuildContext context) {
    final color =
        request.isResolved ? AppColors.secondary : AppColors.error;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              request.isResolved
                  ? Icons.check_circle_outline
                  : Icons.warning_amber_outlined,
              color: color,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(request.customerName,
                    style: AppTypography.textTheme.titleSmall),
                Text(
                  '${request.type} · ${DateFormat('dd MMM').format(request.requestDate)}',
                  style: AppTypography.textTheme.bodySmall,
                ),
                if (request.note.isNotEmpty)
                  Text(request.note,
                      style: AppTypography.textTheme.bodySmall
                          ?.copyWith(color: AppColors.textSecondary)),
              ],
            ),
          ),
          if (onResolve != null)
            TextButton(
              onPressed: onResolve,
              child: const Text('Resolve'),
            ),
        ],
      ),
    );
  }
}
