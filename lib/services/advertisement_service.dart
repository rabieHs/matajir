import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:matajir/controllers/advertisement_controller.dart';
import 'package:matajir/controllers/store_controller.dart';
import 'package:matajir/services/stripe_service.dart';
import 'package:matajir/services/supabase_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// Shared service for handling advertisement upload and payment processing
/// across all three ad creation screens (home_spotlight, category_match, top_store_boost)
class AdvertisementService {
  static final AdvertisementService _instance =
      AdvertisementService._internal();
  factory AdvertisementService() => _instance;
  AdvertisementService._internal();

  /// Upload image and create advertisement with isPaid: false
  /// Returns the created advertisement ID if successful, null otherwise
  Future<String?> uploadAndCreateAd({
    required BuildContext context,
    required String name,
    required File imageFile,
    required String clickUrl,
    required int durationValue,
    required String durationType,
    required String adType,
    String? categoryId,
    String? subcategoryId,
    String? storeId,
    String? country,
  }) async {
    final adController = Provider.of<AdvertisementController>(
      context,
      listen: false,
    );
    final localizations = AppLocalizations.of(context);

    try {
      // Step 1: Upload image
      final imageUrl = await adController.uploadAdvertisementImage(imageFile);
      if (imageUrl == null) {
        _showError(context, localizations.failedToUploadImage);
        return null;
      }

      // Step 2: Calculate start and end dates
      final now = DateTime.now();
      final int durationInDays =
          durationType == 'week' ? durationValue * 7 : durationValue;
      final endDate = now.add(Duration(days: durationInDays));

      // Step 3: Create advertisement with isPaid: false
      final success = await adController.createAdvertisement(
        name: name,
        imageUrl: imageUrl,
        clickUrl: clickUrl,
        startsAt:
            now, // Will be updated to payment date after successful payment
        endsAt: endDate,
        adType: adType,
        categoryId: categoryId,
        subcategoryId: subcategoryId,
        storeId: storeId,
        country: country,
        isPaid: false, // Initially unpaid
        paymentStatus: 'pending',
      );

      if (success) {
        return adController.createdAdvertisementId;
      } else {
        _showError(
          context,
          adController.error ?? localizations.failedToCreateAdvertisement,
        );
        return null;
      }
    } catch (e) {
      _showError(context, 'Error creating advertisement: $e');
      return null;
    }
  }

  /// Process payment and activate advertisement
  /// Updates the advertisement to isPaid: true and startsAt: paymentDate
  Future<bool> processPaymentAndActivateAd({
    required BuildContext context,
    required String advertisementId,
    required String packageId,
    required int duration,
    required String durationType,
    required String adName,
  }) async {
    final adController = Provider.of<AdvertisementController>(
      context,
      listen: false,
    );
    final localizations = AppLocalizations.of(context);

    try {
      // For development/testing: Skip actual payment processing
      // Change this condition to false to use real Stripe payment
      const bool useTestMode =
          false; // Set to true for test mode, false for real payments

      if (useTestMode) {
        // Simulate payment processing
        await Future.delayed(const Duration(seconds: 2));

        // Update advertisement as paid with current date as start date
        final paymentDate = DateTime.now();
        final int durationInDays =
            durationType == 'week' ? duration * 7 : duration;
        final newEndDate = paymentDate.add(Duration(days: durationInDays));

        final success = await adController.updateAdvertisement(
          id: advertisementId,
          isPaid: true,
          paymentStatus: 'succeeded',
          isActive: true,
          startsAt: paymentDate, // Set start date to payment date
          endsAt: newEndDate, // Recalculate end date from payment date
        );

        if (success) {
          debugPrint('Advertisement updated successfully after test payment');
          // Store promotion is handled by AdvertisementController.updateAdvertisement()

          if (context.mounted) {
            _showSuccess(
              context,
              "${localizations.paymentSuccessful} (Test Mode)",
            );
          }
          return true;
        } else {
          if (context.mounted) {
            _showError(
              context,
              adController.error ?? localizations.paymentConfirmationFailed,
            );
          }
          return false;
        }
      }

      // REAL STRIPE PAYMENT PROCESSING
      final stripeService = StripeService.instance;

      // Calculate total amount
      final totalAmount = stripeService.calculateTotalPrice(
        packageId: packageId,
        duration: duration,
        durationType: durationType,
      );

      try {
        // Create payment intent
        final paymentIntent = await stripeService.createPaymentIntent(
          amount: totalAmount.toString(),
          currency: 'usd',
          description: 'Advertisement: $adName ($packageId)',
        );

        // Initialize payment sheet
        await Stripe.instance.initPaymentSheet(
          paymentSheetParameters: SetupPaymentSheetParameters(
            paymentIntentClientSecret: paymentIntent['client_secret'],
            merchantDisplayName: 'Matajir',
            style: ThemeMode.light,
          ),
        );

        // Present payment sheet
        await Stripe.instance.presentPaymentSheet();

        // If we reach here, payment was successful
        final paymentDate = DateTime.now();
        final int durationInDays =
            durationType == 'week' ? duration * 7 : duration;
        final newEndDate = paymentDate.add(Duration(days: durationInDays));

        // Save payment record and get the payment UUID
        final userId = Supabase.instance.client.auth.currentUser?.id;
        String? paymentUuid;
        if (userId != null) {
          paymentUuid = await stripeService.savePaymentRecord(
            userId: userId,
            paymentIntentId: paymentIntent['id'],
            amount: totalAmount.toString(),
            currency: 'usd',
            status: 'succeeded',
            description: 'Advertisement: $adName ($packageId)',
            advertisementId: advertisementId,
          );
        }

        // Update advertisement as paid with the payment UUID
        final success = await adController.updateAdvertisement(
          id: advertisementId,
          isPaid: true,
          paymentStatus: 'succeeded',
          isActive: true,
          startsAt: paymentDate,
          endsAt: newEndDate,
          paymentId:
              paymentUuid, // Use the payment UUID instead of Stripe Payment Intent ID
        );

        if (success) {
          debugPrint('Advertisement updated successfully after Stripe payment');
          // Store promotion is handled by AdvertisementController.updateAdvertisement()

          if (context.mounted) {
            _showSuccess(context, localizations.paymentSuccessful);
          }
          return true;
        } else {
          if (context.mounted) {
            _showError(
              context,
              adController.error ?? localizations.paymentConfirmationFailed,
            );
          }
          return false;
        }
      } on StripeConfigException catch (e) {
        if (context.mounted) {
          _showError(context, 'Stripe configuration error: ${e.message}');
        }
        return false;
      } on StripeException catch (e) {
        if (context.mounted) {
          if (e.error.code == FailureCode.Canceled) {
            _showError(context, 'Payment was cancelled');
          } else {
            _showError(context, 'Payment failed: ${e.error.message}');
          }
        }
        return false;
      } catch (e) {
        if (context.mounted) {
          _showError(context, 'Payment error: $e');
        }
        return false;
      }
    } catch (e) {
      _showError(context, 'Payment processing error: $e');
      return false;
    }
  }

  /// Create advertisement with existing image URL (for store boost ads)
  /// Returns the created advertisement ID if successful, null otherwise
  Future<String?> createAdWithImageUrl({
    required BuildContext context,
    required String name,
    required String imageUrl,
    required String clickUrl,
    required int durationValue,
    required String durationType,
    required String adType,
    String? categoryId,
    String? subcategoryId,
    String? storeId,
    String? country,
  }) async {
    final adController = Provider.of<AdvertisementController>(
      context,
      listen: false,
    );
    final localizations = AppLocalizations.of(context);

    try {
      // Calculate start and end dates
      final now = DateTime.now();
      final int durationInDays =
          durationType == 'week' ? durationValue * 7 : durationValue;
      final endDate = now.add(Duration(days: durationInDays));

      // Create advertisement with isPaid: false
      final success = await adController.createAdvertisement(
        name: name,
        imageUrl: imageUrl,
        clickUrl: clickUrl,
        startsAt:
            now, // Will be updated to payment date after successful payment
        endsAt: endDate,
        adType: adType,
        categoryId: categoryId,
        subcategoryId: subcategoryId,
        storeId: storeId,
        country: country,
        isPaid: false, // Initially unpaid
        paymentStatus: 'pending',
      );

      if (success) {
        return adController.createdAdvertisementId;
      } else {
        _showError(
          context,
          adController.error ?? localizations.failedToCreateAdvertisement,
        );
        return null;
      }
    } catch (e) {
      _showError(context, 'Error creating advertisement: $e');
      return null;
    }
  }

  /// Complete advertisement creation process (upload + payment)
  /// This is the main function that combines both upload and payment
  Future<bool> createAndPayForAdvertisement({
    required BuildContext context,
    required String name,
    required File imageFile,
    required String clickUrl,
    required int durationValue,
    required String durationType,
    required String adType,
    String? categoryId,
    String? subcategoryId,
    String? storeId,
    String? country,
  }) async {
    final localizations = AppLocalizations.of(context);

    // Step 1: Upload and create advertisement
    final advertisementId = await uploadAndCreateAd(
      context: context,
      name: name,
      imageFile: imageFile,
      clickUrl: clickUrl,
      durationValue: durationValue,
      durationType: durationType,
      adType: adType,
      categoryId: categoryId,
      subcategoryId: subcategoryId,
      storeId: storeId,
      country: country,
    );

    if (advertisementId == null) {
      return false;
    }

    // Step 2: Process payment and activate advertisement
    final paymentSuccess = await processPaymentAndActivateAd(
      context: context,
      advertisementId: advertisementId,
      packageId: adType,
      duration: durationValue,
      durationType: durationType,
      adName: name,
    );

    if (paymentSuccess) {
      _showSuccess(context, localizations.advertisementCreatedSuccess);
      return true;
    } else {
      // Payment failed, optionally delete the unpaid advertisement
      // or leave it as draft for user to retry payment later
      return false;
    }
  }

  /// Complete advertisement creation process for store boost (with existing image URL)
  Future<bool> createAndPayForStoreBoostAdvertisement({
    required BuildContext context,
    required String name,
    required String imageUrl,
    required String clickUrl,
    required int durationValue,
    required String durationType,
    required String adType,
    String? categoryId,
    String? subcategoryId,
    String? storeId,
    String? country,
  }) async {
    final localizations = AppLocalizations.of(context);

    // Step 1: Create advertisement with existing image URL
    final advertisementId = await createAdWithImageUrl(
      context: context,
      name: name,
      imageUrl: imageUrl,
      clickUrl: clickUrl,
      durationValue: durationValue,
      durationType: durationType,
      adType: adType,
      categoryId: categoryId,
      subcategoryId: subcategoryId,
      storeId: storeId,
      country: country,
    );

    if (advertisementId == null) {
      return false;
    }

    // Step 2: Process payment and activate advertisement
    final paymentSuccess = await processPaymentAndActivateAd(
      context: context,
      advertisementId: advertisementId,
      packageId: adType,
      duration: durationValue,
      durationType: durationType,
      adName: name,
    );

    if (paymentSuccess) {
      _showSuccess(context, localizations.advertisementCreatedSuccess);
      return true;
    } else {
      // Payment failed, optionally delete the unpaid advertisement
      // or leave it as draft for user to retry payment later
      return false;
    }
  }

  /// Get package price for display
  double getPackagePrice(String packageId) {
    return StripeService.instance.getPackagePrice(packageId);
  }

  /// Calculate total price for display
  double calculateTotalPrice({
    required String packageId,
    required int duration,
    required String durationType,
  }) {
    return StripeService.instance.calculateTotalPrice(
      packageId: packageId,
      duration: duration,
      durationType: durationType,
    );
  }

  /// Helper method to show error messages
  void _showError(BuildContext context, String message) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    }
  }

  /// Helper method to show success messages
  void _showSuccess(BuildContext context, String message) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.green),
      );
    }
  }

  /// Creates a store boost advertisement without image upload
  /// Used for promoting stores in category listings
  Future<bool> createStoreBoostAdvertisement({
    required BuildContext context,
    required String storeName,
    required String storeLogoUrl,
    required String storeWebsite,
    required int durationValue,
    required String durationType,
    required String storeId,
    required String country,
  }) async {
    try {
      // Step 1: Create unpaid advertisement
      final advertisementId = await _createStoreBoostAdInDatabase(
        context: context,
        storeName: storeName,
        storeLogoUrl: storeLogoUrl,
        storeWebsite: storeWebsite,
        durationValue: durationValue,
        durationType: durationType,
        storeId: storeId,
        country: country,
      );

      if (advertisementId == null) {
        return false;
      }

      // Step 2: Process payment and activate advertisement
      final paymentSuccess = await processPaymentAndActivateAd(
        context: context,
        advertisementId: advertisementId,
        packageId: 'store_boost',
        duration: durationValue,
        durationType: durationType,
        adName: '$storeName Store Boost',
      );

      return paymentSuccess;
    } catch (e) {
      debugPrint('Error creating store boost: $e');
      return false;
    }
  }

  /// Creates store boost ad in database (unpaid initially)
  Future<String?> _createStoreBoostAdInDatabase({
    required BuildContext context,
    required String storeName,
    required String storeLogoUrl,
    required String storeWebsite,
    required int durationValue,
    required String durationType,
    required String storeId,
    required String country,
  }) async {
    final localizations = AppLocalizations.of(context);

    try {
      final adController = Provider.of<AdvertisementController>(
        context,
        listen: false,
      );

      // Calculate dates
      final startDate = DateTime.now();
      final int durationInDays =
          durationType == 'week' ? durationValue * 7 : durationValue;
      final endDate = startDate.add(Duration(days: durationInDays));

      // Create store boost advertisement
      final success = await adController.createAdvertisement(
        name: '$storeName Store Boost',
        imageUrl: storeLogoUrl,
        clickUrl: storeWebsite,
        startsAt: startDate,
        endsAt: endDate,
        adType: 'store_boost',
        categoryId: null, // Store boost ads don't need category
        subcategoryId: null,
        storeId: storeId,
        country: country,
        isPaid: false, // Initially unpaid
        isActive: false, // Initially inactive
      );

      if (success) {
        return adController.createdAdvertisementId;
      } else {
        _showError(
          context,
          adController.error ?? localizations.failedToCreateAdvertisement,
        );
        return null;
      }
    } catch (e) {
      _showError(context, 'Error creating store boost: $e');
      return null;
    }
  }
}
