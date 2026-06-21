import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/repositories/auth_repository.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/services/supabase_service.dart';
import '../../../../core/auth/user_role.dart';

part 'auth_provider.g.dart';

@riverpod
AuthRepository authRepository(AuthRepositoryRef ref) => AuthRepository();

@riverpod
class AuthNotifier extends _$AuthNotifier {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<String?> signIn({
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();
    try {
      await ref.read(authRepositoryProvider).signInWithEmail(email, password);
      state = const AsyncData(null);
      return _routeForRole();
    } on Exception catch (e) {
      state = AsyncError(e, StackTrace.current);
      return null;
    }
  }

  Future<String?> signInWithOtp({required String phone}) async {
    state = const AsyncLoading();
    try {
      await ref.read(authRepositoryProvider).signInWithPhone(phone);
      state = const AsyncData(null);
      return null;
    } on Exception catch (e) {
      state = AsyncError(e, StackTrace.current);
      return null;
    }
  }

  Future<String?> verifyOtp({
    required String phone,
    required String otp,
  }) async {
    state = const AsyncLoading();
    try {
      await ref.read(authRepositoryProvider).verifyOtp(phone, otp);
      state = const AsyncData(null);
      return _routeForRole();
    } on Exception catch (e) {
      state = AsyncError(e, StackTrace.current);
      return null;
    }
  }

  Future<void> signOut() async {
    state = const AsyncLoading();
    try {
      await ref.read(authRepositoryProvider).signOut();
      state = const AsyncData(null);
    } on Exception catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }

  /// Determines the correct route based on the user's role.
  Future<String> _routeForRole() async {
    final role = await SupabaseService.getUserRole();
    switch (role) {
      case UserRole.vendor:
        return AppRoutes.dashboard;
      case UserRole.customer:
        return AppRoutes.customerHome;
      case UserRole.staff:
        return AppRoutes.staffHome;
      case UserRole.unknown:
        return AppRoutes.setupProfile;
    }
  }

  /// Static helper for use from outside the notifier (e.g., splash screen).
  static Future<String> routeForRole() async {
    final role = await SupabaseService.getUserRole();
    switch (role) {
      case UserRole.vendor:
        return AppRoutes.dashboard;
      case UserRole.customer:
        return AppRoutes.customerHome;
      case UserRole.staff:
        return AppRoutes.staffHome;
      case UserRole.unknown:
        return AppRoutes.setupProfile;
    }
  }
}
