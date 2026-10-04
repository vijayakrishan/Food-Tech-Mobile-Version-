import 'package:flutter/material.dart';

class AppColors {
  // Brand / Primary Palette (Biotech Emerald & Teal)
  static const Color primary = Color(0xFF0D9488); // Teal 600
  static const Color primaryDark = Color(0xFF0F766E); // Teal 700
  static const Color primaryLight = Color(0xFF2DD4BF); // Teal 400
  static const Color primaryContainer = Color(0xFFCCFBF1); // Teal 100
  static const Color onPrimaryContainer = Color(0xFF134E4A);

  // Secondary Palette (Eco Sage / Sustainable Green)
  static const Color secondary = Color(0xFF059669); // Emerald 600
  static const Color secondaryLight = Color(0xFF34D399); // Emerald 400
  static const Color secondaryContainer = Color(0xFFD1FAE5);
  static const Color onSecondaryContainer = Color(0xFF064E3B);

  // Accent & Action
  static const Color accent = Color(0xFF2563EB); // Blue 600
  static const Color accentContainer = Color(0xFFDBEAFE);

  // Neutrals - Light Theme
  static const Color backgroundLight = Color(0xFFF8FAFC); // Slate 50
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceVariantLight = Color(0xFFF1F5F9); // Slate 100
  static const Color borderLight = Color(0xFFE2E8F0); // Slate 200
  static const Color textPrimaryLight = Color(0xFF0F172A); // Slate 900
  static const Color textSecondaryLight = Color(0xFF64748B); // Slate 500
  static const Color textMutedLight = Color(0xFF94A3B8); // Slate 400

  // Neutrals - Dark Theme
  static const Color backgroundDark = Color(0xFF0B1120); // Deep Dark Slate
  static const Color surfaceDark = Color(0xFF151F32); // Dark Card Surface
  static const Color surfaceVariantDark = Color(0xFF1E293B); // Slate 800
  static const Color borderDark = Color(0xFF334155); // Slate 700
  static const Color textPrimaryDark = Color(0xFFF8FAFC); // Slate 50
  static const Color textSecondaryDark = Color(0xFF94A3B8); // Slate 400
  static const Color textMutedDark = Color(0xFF64748B); // Slate 500

  // Semantic & AI Explainability (SHAP & Scoring)
  static const Color shapPositive = Color(0xFF10B981); // Emerald 500 (Increases suitability)
  static const Color shapPositiveBg = Color(0xFFECFDF5);
  static const Color shapNegative = Color(0xFFF43F5E); // Rose 500 (Decreases suitability)
  static const Color shapNegativeBg = Color(0xFFFFF1F2);

  static const Color scoreHigh = Color(0xFF10B981); // 85-100%
  static const Color scoreMedium = Color(0xFFF59E0B); // 70-84%
  static const Color scoreLow = Color(0xFFEF4444); // <70%

  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color success = Color(0xFF10B981);
  static const Color info = Color(0xFF3B82F6);
}
