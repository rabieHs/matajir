import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/home_controller.dart';
import '../controllers/category_controller.dart';
import '../controllers/store_controller.dart';
import '../providers/localization_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class DialogUtils {
  static void showLanguageDialog(BuildContext context) {
    final homeController = Provider.of<HomeController>(context, listen: false);
    final localizationProvider = Provider.of<LocalizationProvider>(
      context,
      listen: false,
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  AppLocalizations.of(context).selectLanguage,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF673AB7),
                  ),
                ),
                const SizedBox(height: 16),
                _buildLanguageOption(
                  context,
                  'en',
                  AppLocalizations.of(context).english,
                  homeController,
                  localizationProvider,
                ),
                _buildLanguageOption(
                  context,
                  'fr',
                  AppLocalizations.of(context).french,
                  homeController,
                  localizationProvider,
                ),
                _buildLanguageOption(
                  context,
                  'ar',
                  AppLocalizations.of(context).arabic,
                  homeController,
                  localizationProvider,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static Widget _buildLanguageOption(
    BuildContext context,
    String code,
    String name,
    HomeController controller,
    LocalizationProvider localizationProvider,
  ) {
    final isSelected = localizationProvider.languageCode == code;

    return InkWell(
      onTap: () {
        // Convert language code to display format (En, Fr, Ar) for HomeController
        String displayCode =
            code.substring(0, 1).toUpperCase() + code.substring(1);
        controller.setLanguage(displayCode);
        localizationProvider.setLocale(Locale(code));
        Navigator.pop(context);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFEDE7F6) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? const Color(0xFF673AB7) : Colors.grey.shade300,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Text(
              name,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? const Color(0xFF673AB7) : Colors.black87,
              ),
            ),
            const Spacer(),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: Color(0xFF673AB7),
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  static void showCountryDialog(BuildContext context) {
    final homeController = Provider.of<HomeController>(context, listen: false);
    final localizationProvider = Provider.of<LocalizationProvider>(
      context,
      listen: false,
    );
    final categoryController = Provider.of<CategoryController>(
      context,
      listen: false,
    );
    final storeController = Provider.of<StoreController>(
      context,
      listen: false,
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppLocalizations.of(context).selectCountry,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF673AB7),
                      ),
                    ),
                    // GPS detection button
                    Consumer<LocalizationProvider>(
                      builder: (context, locProvider, _) {
                        return IconButton(
                          onPressed:
                              locProvider.isDetectingLocation
                                  ? null
                                  : () async {
                                    await locProvider.detectCountryFromGPS();
                                    // Update all controllers with the new country
                                    homeController.setCountry(
                                      locProvider.countryCode,
                                    );
                                    categoryController.setCountryCode(
                                      locProvider.countryCode,
                                    );
                                    storeController.setCountryCode(
                                      locProvider.countryCode,
                                    );
                                  },
                          icon:
                              locProvider.isDetectingLocation
                                  ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Color(0xFF673AB7),
                                      ),
                                    ),
                                  )
                                  : const Icon(
                                    Icons.my_location,
                                    color: Color(0xFF673AB7),
                                  ),
                          tooltip: 'Detect from GPS',
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildCountryOption(
                  context,
                  'TN',
                  AppLocalizations.of(context).tunisia,
                  homeController,
                  localizationProvider,
                  categoryController,
                  storeController,
                ),
                _buildCountryOption(
                  context,
                  'US',
                  AppLocalizations.of(context).unitedStates,
                  homeController,
                  localizationProvider,
                  categoryController,
                  storeController,
                ),
                _buildCountryOption(
                  context,
                  'FR',
                  AppLocalizations.of(context).france,
                  homeController,
                  localizationProvider,
                  categoryController,
                  storeController,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static Widget _buildCountryOption(
    BuildContext context,
    String code,
    String name,
    HomeController controller,
    LocalizationProvider localizationProvider,
    CategoryController categoryController,
    StoreController storeController,
  ) {
    final isSelected = localizationProvider.countryCode == code;

    return InkWell(
      onTap: () {
        // Update country code in all controllers
        controller.setCountry(code);
        localizationProvider.setCountryCode(code);
        categoryController.setCountryCode(code);
        storeController.setCountryCode(code);

        // Debug print to confirm country change
        debugPrint('Country changed to: $code');

        Navigator.pop(context);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFEDE7F6) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? const Color(0xFF673AB7) : Colors.grey.shade300,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Text(
              name,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? const Color(0xFF673AB7) : Colors.black87,
              ),
            ),
            const Spacer(),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: Color(0xFF673AB7),
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}
