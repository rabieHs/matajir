import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Stripe Configuration
///
/// IMPORTANT: Stripe keys are now loaded from environment variables (.env file)
///
/// To get your Stripe keys:
/// 1. Go to https://dashboard.stripe.com/
/// 2. Make sure you're in "Test mode" (toggle in the top right)
/// 3. Go to Developers > API keys
/// 4. Copy your Publishable key and Secret key
/// 5. Update the .env file with your actual keys
///
/// For production:
/// 1. Switch to "Live mode" in Stripe dashboard
/// 2. Get your live keys
/// 3. Update the .env file with your live keys
/// 4. Set STRIPE_IS_PRODUCTION=true in .env file

class StripeConfig {
  // Get keys from environment variables
  static String get testPublishableKey =>
      dotenv.env['STRIPE_TEST_PUBLISHABLE_KEY'] ?? '';
  static String get testSecretKey => dotenv.env['STRIPE_TEST_SECRET_KEY'] ?? '';

  static String get livePublishableKey =>
      dotenv.env['STRIPE_LIVE_PUBLISHABLE_KEY'] ?? '';
  static String get liveSecretKey => dotenv.env['STRIPE_LIVE_SECRET_KEY'] ?? '';

  // Environment setting from .env file
  static bool get isProduction =>
      dotenv.env['STRIPE_IS_PRODUCTION']?.toLowerCase() == 'true';

  // Get current keys based on environment
  static String get publishableKey =>
      isProduction ? livePublishableKey : testPublishableKey;
  static String get secretKey => isProduction ? liveSecretKey : testSecretKey;

  // Stripe API endpoints
  static const String paymentIntentsEndpoint =
      'https://api.stripe.com/v1/payment_intents';

  // Supported currencies
  static const String defaultCurrency = 'usd';

  // Package prices (in USD)
  static const Map<String, double> packagePrices = {
    'home_spotlight': 50.0, // $50 per week
    'category_match': 30.0, // $30 per week
    'top_store_boost': 40.0, // $40 per week
    'store_boost': 40.0, // $40 per week (same as top_store_boost)
  };
}
