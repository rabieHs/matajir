import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
// Supabase is initialized in SupabaseService

import 'constants/app_theme.dart';
import 'controllers/home_controller.dart';
import 'controllers/category_controller.dart';
import 'controllers/store_controller.dart';
import 'controllers/auth_controller.dart';
import 'controllers/advertisement_controller.dart';
import 'controllers/payment_controller.dart';
import 'providers/localization_provider.dart';
import 'services/supabase_service.dart';
import 'services/stripe_service.dart';
import 'utils/database_checker.dart';
import 'views/screens/home_screen.dart';
import 'views/screens/complete_profile_screen.dart';
import 'views/screens/dashboard/dashboard_screen.dart';
import 'views/screens/dashboard/my_ads_screen.dart';
import 'views/screens/advertise/edit_ad/edit_ad_screen.dart';
import 'models/advertisement.dart';
import 'utils/storage_setup.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  await SupabaseService.initialize();

  // Initialize Stripe
  await StripeService.initialize();

  // Check and create database tables if needed
  await DatabaseChecker.checkAndCreateTables();

  // Setup storage buckets (non-blocking)
  StorageSetup.ensureStorageBucketsExist().catchError((e) {
    debugPrint('Storage setup failed (non-critical): $e');
  });

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LocalizationProvider()),
        ChangeNotifierProvider(create: (_) => HomeController()),
        ChangeNotifierProvider(create: (_) => CategoryController()),
        ChangeNotifierProvider(create: (_) => StoreController()),
        ChangeNotifierProvider(create: (_) => AuthController()),
        ChangeNotifierProvider(create: (_) => AdvertisementController()),
        ChangeNotifierProvider(create: (_) => PaymentController()),
      ],
      child: Consumer<LocalizationProvider>(
        builder: (context, localizationProvider, child) {
          // Update controllers with the current country code and language
          final categoryController = Provider.of<CategoryController>(
            context,
            listen: false,
          );
          final storeController = Provider.of<StoreController>(
            context,
            listen: false,
          );
          final homeController = Provider.of<HomeController>(
            context,
            listen: false,
          );

          // Update controllers with the current country code
          categoryController.updateFromLocalizationProvider(
            localizationProvider,
          );
          storeController.updateFromLocalizationProvider(localizationProvider);

          // Update HomeController with the current language and country
          // Using post-frame callback to avoid setState during build
          final displayCode = localizationProvider.displayLanguageCode;
          final countryCode = localizationProvider.countryCode;

          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (homeController.selectedLanguage != displayCode) {
              homeController.setLanguage(displayCode);
            }

            if (homeController.selectedCountry != countryCode) {
              homeController.setCountry(countryCode);
            }
          });

          return MaterialApp(
            title: 'Matajir',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.theme,
            locale: localizationProvider.locale,
            supportedLocales: const [
              Locale('en'), // English
              Locale('fr'), // French
              Locale('ar'), // Arabic
            ],
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            initialRoute: '/',
            routes: {
              '/': (context) => const HomeScreen(),
              '/home': (context) => const HomeScreen(),
              '/complete-profile': (context) => const CompleteProfileScreen(),
              '/dashboard': (context) => const DashboardScreen(),
              '/my-ads': (context) => const MyAdsScreen(),
            },
            onGenerateRoute: (settings) {
              if (settings.name == '/edit-ad') {
                final ad = settings.arguments as Advertisement;
                return MaterialPageRoute(
                  builder: (context) => EditAdScreen(advertisement: ad),
                );
              }
              return null;
            },
          );
        },
      ),
    );
  }
}
