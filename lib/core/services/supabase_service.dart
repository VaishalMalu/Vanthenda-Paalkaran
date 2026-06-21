import 'package:supabase_flutter/supabase_flutter.dart';
import '../auth/user_role.dart';

class SupabaseService {
  SupabaseService._();

  static SupabaseClient get client => Supabase.instance.client;
  static GoTrueClient get auth => Supabase.instance.client.auth;

  static String? get currentUserId => auth.currentUser?.id;
  static bool get isAuthenticated => auth.currentUser != null;

  /// Detects the authenticated user's role via Supabase RPC.
  /// Returns [UserRole.unknown] if the user has no role yet (needs setup).
  static Future<UserRole> getUserRole() async {
    if (!isAuthenticated) return UserRole.unknown;
    try {
      final dynamic result = await client.rpc('get_user_role');
      switch (result as String?) {
        case 'vendor':
          return UserRole.vendor;
        case 'customer':
          return UserRole.customer;
        case 'staff':
          return UserRole.staff;
        default:
          return UserRole.unknown;
      }
    } catch (_) {
      return UserRole.unknown;
    }
  }
}
