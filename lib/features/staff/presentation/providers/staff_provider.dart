import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/staff_repository.dart';

class StaffNotifier extends Notifier<AsyncValue<List<StaffModel>>> {
  @override
  AsyncValue<List<StaffModel>> build() => const AsyncValue.loading();

  Future<void> loadStaff() async {
    state = const AsyncValue.loading();
    try {
      final repository = ref.read(staffRepositoryProvider);
      final staffList = await repository.fetchStaff();
      state = AsyncValue.data(staffList);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> addStaff(StaffModel staff) async {
    try {
      final repository = ref.read(staffRepositoryProvider);
      await repository.createStaff(staff);
      await loadStaff();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateStaff(StaffModel staff) async {
    try {
      final repository = ref.read(staffRepositoryProvider);
      await repository.updateStaff(staff);
      await loadStaff();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> removeStaff(String id) async {
    try {
      final repository = ref.read(staffRepositoryProvider);
      await repository.deactivateStaff(id);
      await loadStaff();
    } catch (e) {
      rethrow;
    }
  }
}

final staffNotifierProvider =
    NotifierProvider<StaffNotifier, AsyncValue<List<StaffModel>>>(
  StaffNotifier.new,
);
