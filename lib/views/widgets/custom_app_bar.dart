import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../providers/localization_provider.dart';
import '../../utils/dialog_utils.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showDrawerIcon;
  final bool showLanguageSelector;
  final bool showCountrySelector;
  final Function()? onDrawerPressed;

  const CustomAppBar({
    Key? key,
    this.title = '',
    this.showDrawerIcon = true,
    this.showLanguageSelector = true,
    this.showCountrySelector = true,
    this.onDrawerPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<LocalizationProvider>(
      builder: (context, localizationProvider, _) {
        final isRTL = localizationProvider.locale.languageCode == 'ar';

        // Build action widgets
        final languageWidget =
            showLanguageSelector
                ? GestureDetector(
                  onTap: () {
                    DialogUtils.showLanguageDialog(context);
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      localizationProvider.displayLanguageCode,
                      style: const TextStyle(
                        color: AppColors.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                )
                : null;

        final countryWidget =
            showCountrySelector
                ? GestureDetector(
                  onTap: () {
                    DialogUtils.showCountryDialog(context);
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child:
                        localizationProvider.isDetectingLocation
                            ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.red,
                                ),
                              ),
                            )
                            : Text(
                              localizationProvider.countryCode,
                              style: const TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                  ),
                )
                : null;

        return AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: title.isNotEmpty ? Text(title) : null,
          centerTitle: true,
          automaticallyImplyLeading: false,
          leading:
              isRTL
                  ? null // In RTL, leading should be empty
                  : showDrawerIcon
                  ? IconButton(
                    icon: const Icon(Icons.menu, color: Colors.white),
                    onPressed: onDrawerPressed,
                  )
                  : null,
          actions:
              isRTL
                  ? [
                    // In RTL, put drawer icon first (on the right side)
                    if (showDrawerIcon)
                      IconButton(
                        icon: const Icon(Icons.menu, color: Colors.white),
                        onPressed: onDrawerPressed,
                      ),
                    // Then language and country selectors on the left side
                    if (countryWidget != null) countryWidget,
                    if (languageWidget != null) languageWidget,
                  ]
                  : [
                    // In LTR, language and country selectors on the right side
                    if (languageWidget != null) languageWidget,
                    if (countryWidget != null) countryWidget,
                  ],
        );
      },
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(60);
}
