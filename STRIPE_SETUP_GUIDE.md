# Stripe Payment Setup Guide

## Current Status
✅ **Storage buckets fixed** - Image upload should now work properly  
✅ **Real Stripe payments enabled** - Test mode is now disabled  
⚠️ **Stripe keys need to be configured** - You need to add your sandbox keys  

## Steps to Configure Real Stripe Payments

### 1. Get Your Stripe Sandbox Keys

1. Go to [Stripe Dashboard](https://dashboard.stripe.com/)
2. Make sure you're in **"Test mode"** (toggle in the top right corner)
3. Navigate to **Developers > API keys**
4. Copy your:
   - **Publishable key** (starts with `pk_test_`)
   - **Secret key** (starts with `sk_test_`)

### 2. Update Configuration

Open the file `lib/config/stripe_config.dart` and replace the placeholder keys:

```dart
// Replace these lines:
static const String testPublishableKey = 'pk_test_YOUR_PUBLISHABLE_KEY_HERE';
static const String testSecretKey = 'sk_test_YOUR_SECRET_KEY_HERE';

// With your actual keys:
static const String testPublishableKey = 'pk_test_your_actual_publishable_key';
static const String testSecretKey = 'sk_test_your_actual_secret_key';
```

### 3. Test the Payment Flow

1. **Run the app** and try creating an advertisement
2. **Upload an image** - this should now work with the fixed storage buckets
3. **Proceed to payment** - you'll see the real Stripe payment sheet
4. **Use test card numbers**:
   - Success: `4242 4242 4242 4242`
   - Declined: `4000 0000 0000 0002`
   - Any future expiry date and any 3-digit CVC

### 4. Monitor Payments

- Check your [Stripe Dashboard](https://dashboard.stripe.com/test/payments) to see test payments
- Payments will appear in the "Payments" section
- You can see payment details, refund if needed, etc.

## What Was Fixed

### Storage Issues
- ✅ Fixed `Uint8List` type errors in storage setup
- ✅ Added fallback bucket logic for image uploads
- ✅ Enhanced error logging for debugging
- ✅ Added storage bucket creation on app startup

### Payment System
- ✅ Disabled test mode (set `useTestMode = false`)
- ✅ Enabled real Stripe payment processing
- ✅ Added proper error handling for payment failures
- ✅ Integrated payment records with Supabase database
- ✅ Added payment confirmation and advertisement activation

### Code Structure
- ✅ Created centralized Stripe configuration
- ✅ Improved error handling and user feedback
- ✅ Added proper payment flow with Stripe SDK

## Next Steps

1. **Add your Stripe keys** to `lib/config/stripe_config.dart`
2. **Test the complete flow**: image upload → payment → advertisement activation
3. **Check Supabase storage** to ensure buckets are created properly
4. **Monitor Stripe dashboard** for payment records

## For Production

When ready to go live:

1. Get your **live Stripe keys** from the Stripe dashboard (Live mode)
2. Update `lib/config/stripe_config.dart`:
   ```dart
   static const bool isProduction = true; // Change to true
   static const String livePublishableKey = 'pk_live_your_live_key';
   static const String liveSecretKey = 'sk_live_your_live_key';
   ```
3. Test thoroughly with small amounts first
4. Set up webhooks for payment confirmations (recommended)

## Troubleshooting

### Image Upload Fails
- Check Supabase storage buckets are created
- Verify user authentication
- Check debug logs for specific errors

### Payment Fails
- Verify Stripe keys are correct
- Check internet connection
- Use valid test card numbers
- Check Stripe dashboard for error details

### App Crashes
- Check debug console for error messages
- Verify all dependencies are properly installed
- Make sure Supabase and Stripe are properly initialized

## Support

If you encounter issues:
1. Check the debug logs in your IDE
2. Verify your Stripe dashboard for payment attempts
3. Check Supabase storage for uploaded images
4. Test with different devices/networks
