import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/localization_provider.dart';
import '../constants/app_colors.dart';

/// Utility class to fix back button positioning for RTL languages
class BackButtonFixer {
  /// Fix positioned back button for RTL support
  static Widget fixPositionedBackButton({
    required BuildContext context,
    required Widget child,
    double? top,
    double? bottom,
    double? start, // Will be left for LTR, right for RTL
    double? end,   // Will be right for LTR, left for RTL
    double? width,
    double? height,
  }) {
    return Consumer<LocalizationProvider>(
      builder: (context, localizationProvider, _) {
        final isRTL = localizationProvider.locale.languageCode == 'ar';
        
        return Positioned(
          top: top,
          bottom: bottom,
          left: isRTL ? end : start,
          right: isRTL ? start : end,
          width: width,
          height: height,
          child: child,
        );
      },
    );
  }

  /// Create a back button with proper RTL support
  static Widget createBackButton({
    required BuildContext context,
    VoidCallback? onPressed,
    Color? backgroundColor,
    Color? iconColor,
    double? size,
    EdgeInsetsGeometry? padding,
  }) {
    return Consumer<LocalizationProvider>(
      builder: (context, localizationProvider, _) {
        final isRTL = localizationProvider.locale.languageCode == 'ar';
        
        return GestureDetector(
          onTap: onPressed ?? () => Navigator.pop(context),
          child: Container(
            padding: padding ?? const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: backgroundColor ?? Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(26),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              isRTL ? Icons.arrow_forward : Icons.arrow_back,
              color: iconColor ?? AppColors.primaryColor,
              size: size ?? 20,
            ),
          ),
        );
      },
    );
  }

  /// Fix navigation arrows in carousels for RTL
  static IconData getNavigationIcon({
    required BuildContext context,
    required bool isNext,
  }) {
    final localizationProvider = Provider.of<LocalizationProvider>(context, listen: false);
    final isRTL = localizationProvider.locale.languageCode == 'ar';
    
    if (isNext) {
      return isRTL ? Icons.arrow_back_ios_new : Icons.arrow_forward_ios;
    } else {
      return isRTL ? Icons.arrow_forward_ios : Icons.arrow_back_ios_new;
    }
  }

  /// Fix row direction for RTL
  static MainAxisAlignment getRowAlignment({
    required BuildContext context,
    MainAxisAlignment ltrAlignment = MainAxisAlignment.start,
  }) {
    final localizationProvider = Provider.of<LocalizationProvider>(context, listen: false);
    final isRTL = localizationProvider.locale.languageCode == 'ar';
    
    if (!isRTL) return ltrAlignment;
    
    // Flip alignment for RTL
    switch (ltrAlignment) {
      case MainAxisAlignment.start:
        return MainAxisAlignment.end;
      case MainAxisAlignment.end:
        return MainAxisAlignment.start;
      case MainAxisAlignment.spaceBetween:
        return MainAxisAlignment.spaceBetween; // No change needed
      case MainAxisAlignment.spaceAround:
        return MainAxisAlignment.spaceAround; // No change needed
      case MainAxisAlignment.spaceEvenly:
        return MainAxisAlignment.spaceEvenly; // No change needed
      case MainAxisAlignment.center:
        return MainAxisAlignment.center; // No change needed
    }
  }

  /// Fix text alignment for RTL
  static TextAlign getTextAlignment({
    required BuildContext context,
    TextAlign ltrAlignment = TextAlign.start,
  }) {
    final localizationProvider = Provider.of<LocalizationProvider>(context, listen: false);
    final isRTL = localizationProvider.locale.languageCode == 'ar';
    
    if (!isRTL) return ltrAlignment;
    
    // Flip alignment for RTL
    switch (ltrAlignment) {
      case TextAlign.start:
        return TextAlign.end;
      case TextAlign.end:
        return TextAlign.start;
      case TextAlign.left:
        return TextAlign.right;
      case TextAlign.right:
        return TextAlign.left;
      case TextAlign.center:
        return TextAlign.center; // No change needed
      case TextAlign.justify:
        return TextAlign.justify; // No change needed
    }
  }

  /// Fix edge insets for RTL
  static EdgeInsetsGeometry getEdgeInsets({
    required BuildContext context,
    double? left,
    double? top,
    double? right,
    double? bottom,
  }) {
    final localizationProvider = Provider.of<LocalizationProvider>(context, listen: false);
    final isRTL = localizationProvider.locale.languageCode == 'ar';
    
    if (!isRTL) {
      return EdgeInsets.fromLTRB(
        left ?? 0,
        top ?? 0,
        right ?? 0,
        bottom ?? 0,
      );
    }
    
    // Flip left and right for RTL
    return EdgeInsets.fromLTRB(
      right ?? 0,
      top ?? 0,
      left ?? 0,
      bottom ?? 0,
    );
  }

  /// Create a directional padding that respects RTL
  static EdgeInsetsGeometry getDirectionalPadding({
    required BuildContext context,
    double? start,
    double? top,
    double? end,
    double? bottom,
  }) {
    final localizationProvider = Provider.of<LocalizationProvider>(context, listen: false);
    final isRTL = localizationProvider.locale.languageCode == 'ar';
    
    return EdgeInsets.fromLTRB(
      isRTL ? (end ?? 0) : (start ?? 0),
      top ?? 0,
      isRTL ? (start ?? 0) : (end ?? 0),
      bottom ?? 0,
    );
  }
}
