import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  AppConfig._();

  static const String appName = 'Vanthenda Paalkaran';
  static const String appVersion = '1.0.0';

  // Supabase Configuration
  static String get supabaseUrl => dotenv.env['SUPABASE_URL'] ?? '';
  static String get supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';

  // Storage Buckets
  static const String vendorLogosBucket = 'vendor-logos';
  static const String invoicesBucket = 'invoices';
  static const String customerFilesBucket = 'customer-files';

  // Default Language
  static const String defaultLanguage = 'ta'; // Tamil

  // Hive Boxes
  static const String hiveDeliveriesBox = 'deliveries_box';
  static const String hiveCustomersBox = 'customers_box';
  static const String hiveSettingsBox = 'settings_box';
}
