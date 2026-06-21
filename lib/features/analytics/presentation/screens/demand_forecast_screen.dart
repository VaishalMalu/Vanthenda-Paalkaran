import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/demand_forecasting_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

part 'demand_forecast_screen.g.dart';

@riverpod
Future<List<DemandForecast>> demandForecast(DemandForecastRef ref) async {
  return DemandForecastingService.forecastTomorrow();
}

class DemandForecastScreen extends ConsumerWidget {
  const DemandForecastScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final forecastAsync = ref.watch(demandForecastProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Demand Forecast'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(demandForecastProvider),
          ),
        ],
      ),
      body: forecastAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline,
                  size: 48, color: AppColors.error),
              const SizedBox(height: 12),
              Text('Could not load forecast',
                  style: AppTypography.textTheme.bodyLarge),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => ref.invalidate(demandForecastProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (forecasts) {
          if (forecasts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.trending_up_outlined,
                      size: 64, color: AppColors.textTertiary),
                  const SizedBox(height: 16),
                  Text('No delivery data to forecast from',
                      style: AppTypography.textTheme.titleMedium
                          ?.copyWith(color: AppColors.textSecondary)),
                ],
              ),
            );
          }

          double totalMorning = 0;
          double totalEvening = 0;
          for (final f in forecasts) {
            totalMorning += f.predictedMorningQty;
            totalEvening += f.predictedEveningQty;
          }

          return Column(
            children: [
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        Text('Tomorrow Total',
                            style:
                                AppTypography.textTheme.bodySmall),
                        Text(
                          '${(totalMorning + totalEvening).toStringAsFixed(1)}L',
                          style: AppTypography.textTheme.headlineMedium
                              ?.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        Text('Morning',
                            style:
                                AppTypography.textTheme.bodySmall),
                        Text(
                          '${totalMorning.toStringAsFixed(1)}L',
                          style: AppTypography.textTheme.titleLarge
                              ?.copyWith(color: AppColors.warning),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        Text('Evening',
                            style:
                                AppTypography.textTheme.bodySmall),
                        Text(
                          '${totalEvening.toStringAsFixed(1)}L',
                          style: AppTypography.textTheme.titleLarge
                              ?.copyWith(color: AppColors.info),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: forecasts.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: 8),
                  itemBuilder: (context, i) {
                    final f = forecasts[i];
                    return Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(f.customerName,
                                style: AppTypography
                                    .textTheme.titleSmall),
                          ),
                          Text(
                            'M: ${f.predictedMorningQty.toStringAsFixed(1)}L',
                            style: AppTypography.textTheme.bodySmall
                                ?.copyWith(color: AppColors.warning),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'E: ${f.predictedEveningQty.toStringAsFixed(1)}L',
                            style: AppTypography.textTheme.bodySmall
                                ?.copyWith(color: AppColors.info),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
