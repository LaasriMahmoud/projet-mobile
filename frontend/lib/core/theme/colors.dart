import 'package:flutter/material.dart';

/// Palette de couleurs inspirée de l'UCA (Université)
class UniversityColors {
  // Couleurs principales
  static const primaryBlue = Color(0xFF003D7A);      // Bleu universitaire profond
  static const accentCyan = Color(0xFF00A3E0);       // Cyan moderne
  static const darkNavy = Color(0xFF001E3C);         // Fond sombre navbar
  
  // Couleurs secondaires
  static const successGreen = Color(0xFF10B981);     // Validé
  static const warningOrange = Color(0xFFF59E0B);    // En attente
  static const errorRed = Color(0xFFEF4444);         // Rejeté
  static const infoBlue = Color(0xFF3B82F6);         // Information
  
  // Neutres
  static const lightGray = Color(0xFFF3F4F6);
  static const mediumGray = Color(0xFF9CA3AF);
  static const darkGray = Color(0xFF374151);
  static const textDark = Color(0xFF1F2937);
  
  // Backgrounds
  static const backgroundLight = Color(0xFFFAFAFA);
  static const cardBackground = Colors.white;
  
  // Gradients
  static const primaryGradient = LinearGradient(
    colors: [primaryBlue, accentCyan],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const darkGradient = LinearGradient(
    colors: [darkNavy, primaryBlue],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
