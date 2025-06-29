import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/localization_provider.dart';
import '../constants/app_colors.dart';

class RTLBackButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? iconColor;
  final double? size;
  final EdgeInsetsGeometry? padding;

  const RTLBackButton({
    super.key,
    this.onPressed,
    this.backgroundColor,
    this.iconColor,
    this.size,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<LocalizationProvider>(
      builder: (context, localizationProvider, _) {
        final isRTL = localizationProvider.currentLocale.languageCode == 'ar';

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
}

class RTLAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final Widget? titleWidget;
  final List<Widget>? actions;
  final bool automaticallyImplyLeading;
  final VoidCallback? onBackPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double elevation;

  const RTLAppBar({
    super.key,
    this.title,
    this.titleWidget,
    this.actions,
    this.automaticallyImplyLeading = true,
    this.onBackPressed,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<LocalizationProvider>(
      builder: (context, localizationProvider, _) {
        return AppBar(
          backgroundColor: backgroundColor ?? Colors.transparent,
          foregroundColor: foregroundColor ?? Colors.white,
          elevation: elevation,
          automaticallyImplyLeading: false,
          title: titleWidget ?? (title != null ? Text(title!) : null),
          centerTitle: true,
          leading:
              automaticallyImplyLeading && Navigator.canPop(context)
                  ? RTLBackButton(
                    onPressed: onBackPressed,
                    backgroundColor: backgroundColor ?? Colors.white,
                    iconColor: foregroundColor ?? AppColors.primaryColor,
                  )
                  : null,
          actions: actions,
        );
      },
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class RTLPositioned extends StatelessWidget {
  final Widget child;
  final double? top;
  final double? bottom;
  final double? start; // This will be left for LTR, right for RTL
  final double? end; // This will be right for LTR, left for RTL
  final double? width;
  final double? height;

  const RTLPositioned({
    super.key,
    required this.child,
    this.top,
    this.bottom,
    this.start,
    this.end,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<LocalizationProvider>(
      builder: (context, localizationProvider, _) {
        final isRTL = localizationProvider.currentLocale.languageCode == 'ar';

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
}
