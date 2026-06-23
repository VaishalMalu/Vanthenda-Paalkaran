import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/language_selection_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/milk_card/presentation/screens/milk_card_screen.dart';
import '../../features/customer/presentation/screens/customers_list_screen.dart';
import '../../features/billing/presentation/screens/billing_dashboard_screen.dart';
import '../../features/payments/presentation/screens/payments_screen.dart';
import '../../features/vacation/presentation/screens/vacation_mode_screen.dart';
import '../../features/emergency/presentation/screens/emergency_requests_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/milk_types/presentation/screens/milk_types_screen.dart';
import '../../features/delivery/presentation/screens/delivery_routes_screen.dart';
import '../../features/analytics/presentation/screens/analytics_screen.dart';
import '../../features/analytics/presentation/screens/demand_forecast_screen.dart';
import '../../features/analytics/presentation/screens/ai_assistant_screen.dart';
import '../../features/staff/presentation/screens/staff_list_screen.dart';
import '../../features/customer_portal/presentation/screens/customer_home_screen.dart';
import '../../features/staff_portal/presentation/screens/staff_home_screen.dart';
import '../../features/vendor/presentation/screens/vendor_setup_screen.dart';
import 'app_routes.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: false,
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.language,
        builder: (context, state) => const LanguageSelectionScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.setupProfile,
        builder: (context, state) => const VendorSetupScreen(),
      ),
      GoRoute(
        path: AppRoutes.dashboard,
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: AppRoutes.milkCard,
        builder: (context, state) => const MilkCardScreen(),
      ),
      GoRoute(
        path: AppRoutes.customers,
        builder: (context, state) => const CustomersListScreen(),
      ),
      GoRoute(
        path: AppRoutes.billing,
        builder: (context, state) => const BillingDashboardScreen(),
      ),
      GoRoute(
        path: AppRoutes.payments,
        builder: (context, state) => const PaymentsScreen(),
      ),
      GoRoute(
        path: AppRoutes.vacation,
        builder: (context, state) => const VacationModeScreen(),
      ),
      GoRoute(
        path: AppRoutes.emergency,
        builder: (context, state) => const EmergencyRequestsScreen(),
      ),
      GoRoute(
        path: AppRoutes.settings,
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: AppRoutes.milkTypes,
        builder: (context, state) => const MilkTypesScreen(),
      ),
      GoRoute(
        path: AppRoutes.delivery,
        builder: (context, state) => const DeliveryRoutesScreen(),
      ),
      GoRoute(
        path: AppRoutes.analytics,
        builder: (context, state) => const AnalyticsScreen(),
      ),
      GoRoute(
        path: AppRoutes.demandForecast,
        builder: (context, state) => const DemandForecastScreen(),
      ),
      GoRoute(
        path: AppRoutes.aiAssistant,
        builder: (context, state) => const AiAssistantScreen(),
      ),
      GoRoute(
        path: AppRoutes.staff,
        builder: (context, state) => const StaffListScreen(),
      ),
      GoRoute(
        path: AppRoutes.customerHome,
        builder: (context, state) => const CustomerHomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.staffHome,
        builder: (context, state) => const StaffHomeScreen(),
      ),
    ],
  );
});
