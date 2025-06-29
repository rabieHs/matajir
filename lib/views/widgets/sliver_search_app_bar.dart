import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/localization_provider.dart';
import '../../utils/dialog_utils.dart';
import 'custom_search_bar.dart';

class SliverSearchAppBar extends StatelessWidget {
  final String title;
  final String hintText;
  final bool showDrawerIcon;
  final bool showLanguageSelector;
  final bool showCountrySelector;
  final Function()? onDrawerPressed;
  final Function(String)? onSearchChanged;
  final double expandedHeight;
  final double collapsedHeight;

  const SliverSearchAppBar({
    super.key,
    this.title = '',
    required this.hintText,
    this.showDrawerIcon = true,
    this.showLanguageSelector = true,
    this.showCountrySelector = true,
    this.onDrawerPressed,
    this.onSearchChanged,
    this.expandedHeight = 120.0,
    this.collapsedHeight = 60.0,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<LocalizationProvider>(
      builder: (context, localizationProvider, _) {
        final isRTL = localizationProvider.currentLocale.languageCode == 'ar';

        // Build widgets for reuse
        final menuButton =
            showDrawerIcon
                ? (double expandRatio) => GestureDetector(
                  onTap: expandRatio > 0.5 ? onDrawerPressed : null,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(26),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.menu,
                      color: Color(0xFF673AB7),
                      size: 20,
                    ),
                  ),
                )
                : null;

        final languageSelector =
            showLanguageSelector
                ? (double expandRatio) => GestureDetector(
                  onTap:
                      expandRatio > 0.5
                          ? () {
                            DialogUtils.showLanguageDialog(context);
                          }
                          : null,
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(26),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      localizationProvider.displayLanguageCode,
                      style: const TextStyle(
                        color: Color(0xFF673AB7),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                )
                : null;

        final countrySelector =
            showCountrySelector
                ? (double expandRatio) => GestureDetector(
                  onTap:
                      expandRatio > 0.5
                          ? () {
                            DialogUtils.showCountryDialog(context);
                          }
                          : null,
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(26),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      localizationProvider.countryCode,
                      style: const TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                )
                : null;

        return SliverAppBar(
          backgroundColor: Colors.transparent,
          pinned: true,
          floating: true,
          snap: false,
          expandedHeight: expandedHeight,
          collapsedHeight: collapsedHeight,
          automaticallyImplyLeading: false, // Don't show automatic back button
          title: null, // No title in the app bar
          flexibleSpace: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              // Calculate the percentage of expansion (1.0 = fully expanded, 0.0 = collapsed)
              final double expandRatio = ((constraints.maxHeight -
                          collapsedHeight) /
                      (expandedHeight - collapsedHeight))
                  .clamp(0.0, 1.0);

              return FlexibleSpaceBar(
                background: Stack(
                  children: [
                    // Top row with menu, language and country selectors
                    Positioned(
                      top: MediaQuery.of(context).padding.top + 8,
                      left: 16.0,
                      right: 16.0,
                      child: Opacity(
                        opacity: expandRatio,
                        child: Row(
                          children:
                              isRTL
                                  ? [
                                    // RTL: Menu button on the right
                                    if (menuButton != null)
                                      menuButton(expandRatio),
                                    const Spacer(),
                                    // RTL: Country and language selectors on the left
                                    if (languageSelector != null)
                                      languageSelector(expandRatio),
                                    if (countrySelector != null)
                                      countrySelector(expandRatio),
                                  ]
                                  : [
                                    // LTR: Menu button on the left
                                    if (menuButton != null)
                                      menuButton(expandRatio),
                                    const Spacer(),
                                    // LTR: Language and country selectors on the right
                                    if (languageSelector != null)
                                      languageSelector(expandRatio),
                                    if (countrySelector != null)
                                      countrySelector(expandRatio),
                                  ],
                        ),
                      ),
                    ),

                    // Search bar below the top row
                    Positioned(
                      top: MediaQuery.of(context).padding.top + 60,
                      left: 16.0,
                      right: 16.0,
                      child: Opacity(
                        opacity: expandRatio,
                        child: CustomSearchBar(
                          hintText: hintText,
                          onSearchChanged: onSearchChanged,
                        ),
                      ),
                    ),

                    // Title in the center when collapsed
                    if (title.isNotEmpty)
                      Positioned(
                        top: MediaQuery.of(context).padding.top + 16,
                        left: 0,
                        right: 0,
                        child: Opacity(
                          opacity: 1.0 - expandRatio,
                          child: Center(
                            child: Text(
                              title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}
