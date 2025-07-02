import 'package:flutter/material.dart';

class AppColors {
  // Main colors
  static const Color primaryColor = Color(0xFF1A237E); // Dark blue
  static const Color primary = primaryColor; // Backward compatibility
  static const Color secondaryColor = Color(0xFF7B1FA2); // Purple
  static const Color accentColor = Color(0xFFFF4081); // Pink

  // Background colors
  static const Color scaffoldBackground = Color(
    0xFF673AB7,
  ); // Purple gradient start
  static const Color scaffoldBackgroundEnd = Color(
    0xFF311B92,
  ); // Purple gradient end

  // Text colors
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFFE1BEE7);

  // Card colors
  static const Color cardBackground = Colors.white;
  static const Color cardShadow = Color(0x40000000);

  // Button colors
  static const Color buttonPrimary = Color(0xFFFF4081);
  static const Color buttonSecondary = Color(0xFF7C4DFF);

  // Gradient colors for categories
  static const List<List<Color>> categoryGradients = [
    [Color(0xFFF44336), Color(0xFFE91E63)], // Red to Pink
    [Color(0xFF9C27B0), Color(0xFF673AB7)], // Purple to Deep Purple
    [Color(0xFF3F51B5), Color(0xFF2196F3)], // Indigo to Blue
    [Color(0xFF009688), Color(0xFF4CAF50)], // Teal to Green
    [Color(0xFFFF9800), Color(0xFFFF5722)], // Orange to Deep Orange
    [Color(0xFF795548), Color(0xFF607D8B)], // Brown to Blue Grey
  ];
}
