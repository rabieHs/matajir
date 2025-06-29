/// Stripe Configuration
///
/// IMPORTANT: Replace these with your actual Stripe sandbox keys
///
/// To get your Stripe keys:
/// 1. Go to https://dashboard.stripe.com/
/// 2. Make sure you're in "Test mode" (toggle in the top right)
/// 3. Go to Developers > API keys
/// 4. Copy your Publishable key and Secret key
///
/// For production:
/// 1. Switch to "Live mode" in Stripe dashboard
/// 2. Get your live keys
/// 3. Update these values
/// 4. Make sure to keep these keys secure!

class StripeConfig {
  // Test/Sandbox Keys (replace with your actual test keys)
  static const String testPublishableKey =
      'pk_test_PLACEHOLDER_PUBLISHABLE_KEY';
  static const String testSecretKey = 'sk_test_PLACEHOLDER_SECRET_KEY';

  // Live/Production Keys (replace with your actual live keys when ready)
  static const String livePublishableKey =
      'pk_live_YOUR_LIVE_PUBLISHABLE_KEY_HERE';
  static const String liveSecretKey = 'sk_live_YOUR_LIVE_SECRET_KEY_HERE';

  // Environment setting
  static const bool isProduction = false; // Set to true for production

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
