import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary brand colors (Fresh, Clean, Modern Blue)
  static const Color primary = Color(0xFF0EA5E9); // Bright Sky Blue
  static const Color primaryLight = Color(0xFF38BDF8);
  static const Color primaryDark = Color(0xFF0284C7);

  // Secondary brand colors (Emerald/Nature Green for success, fresh accents)
  static const Color secondary = Color(0xFF10B981); 
  static const Color secondaryLight = Color(0xFF34D399);

  // Background and Surface (Ultra clean minimalist theme)
  static const Color background = Color(0xFFF8FAFC); // Slate 50, extremely light
  static const Color surface = Color(0xFFFFFFFF); // Pure white cards

  // Text colors (Dark slate for high contrast but softer than black)
  static const Color textPrimary = Color(0xFF0F172A); // Slate 900
  static const Color textSecondary = Color(0xFF64748B); // Slate 500
  static const Color textTertiary = Color(0xFF94A3B8); // Slate 400

  // State colors
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // Borders and dividers
  static const Color border = Color(0xFFE2E8F0); // Slate 200
  
  // Custom colors for specific items
  static const Color milkWhite = Color(0xFFFDFDFD);
  static const Color subtleShadow = Color(0x0A0F172A); // Very soft shadow
}
