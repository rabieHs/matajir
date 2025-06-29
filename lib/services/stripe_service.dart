import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/stripe_config.dart';

class StripeService {
  static StripeService? _instance;
  final SupabaseClient _supabase = Supabase.instance.client;

  // Get Stripe keys from configuration
  static String get _secretKey => StripeConfig.secretKey;
  static String get _publishableKey => StripeConfig.publishableKey;
  static String get _paymentIntentsEndpoint =>
      StripeConfig.paymentIntentsEndpoint;

  StripeService._();

  static StripeService get instance {
    _instance ??= StripeService._();
    return _instance!;
  }

  static Future<void> initialize() async {
    try {
      Stripe.publishableKey = _publishableKey;
      await Stripe.instance.applySettings();
      debugPrint('Stripe initialized successfully');
    } catch (e) {
      // Handle the error gracefully
      debugPrint('Error initializing Stripe: $e');
      debugPrint(
        'Continuing without Stripe initialization. Payment features may not work properly.',
      );
      // You can set a flag here to disable payment features in the app
    }
  }

  /// Create a payment intent on the server
  Future<Map<String, dynamic>> createPaymentIntent({
    required String amount,
    required String currency,
    required String description,
    String? customerId,
  }) async {
    try {
      // Convert amount to cents/smallest currency unit as required by Stripe
      final amountInCents = (double.parse(amount) * 100).round().toString();

      // Prepare the request body
      final Map<String, dynamic> body = {
        'amount': amountInCents,
        'currency': currency,
        'description': description,
        'payment_method_types[]': 'card',
      };

      if (customerId != null) {
        body['customer'] = customerId;
      }

      // Make the API request
      final response = await http.post(
        Uri.parse(_paymentIntentsEndpoint),
        headers: {
          'Authorization': 'Bearer $_secretKey',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: body,
      );

      // Parse the response
      final jsonResponse = jsonDecode(response.body);

      if (response.statusCode != 200) {
        throw Exception(
          'Failed to create payment intent: ${jsonResponse['error']['message']}',
        );
      }

      return jsonResponse;
    } catch (e) {
      debugPrint('Error creating payment intent: $e');
      rethrow;
    }
  }

  /// Process a payment with the Stripe SDK
  Future<Map<String, dynamic>> processPayment({
    required String paymentIntentClientSecret,
  }) async {
    try {
      // Confirm the payment with the card
      await Stripe.instance.confirmPayment(
        paymentIntentClientSecret: paymentIntentClientSecret,
        data: const PaymentMethodParams.card(
          paymentMethodData: PaymentMethodData(),
        ),
      );

      // Return a simplified result with the payment intent ID
      return {
        'paymentIntentId': paymentIntentClientSecret.split('_secret_')[0],
        'status': 'succeeded',
        'amount': '0', // This would normally come from the payment result
      };
    } catch (e) {
      debugPrint('Error processing payment: $e');
      rethrow;
    }
  }

  /// Save payment record to Supabase and return the payment UUID
  Future<String> savePaymentRecord({
    required String userId,
    required String paymentIntentId,
    required String amount,
    required String currency,
    required String status,
    required String description,
    String? advertisementId,
    String? storeId,
  }) async {
    try {
      final response =
          await _supabase
              .from('payments')
              .insert({
                'user_id': userId,
                'payment_intent_id': paymentIntentId,
                'amount': amount,
                'currency': currency,
                'status': status,
                'description': description,
                'advertisement_id': advertisementId,
                'store_id': storeId,
                'created_at': DateTime.now().toIso8601String(),
              })
              .select('id')
              .single();

      return response['id'] as String;
    } catch (e) {
      debugPrint('Error saving payment record: $e');
      rethrow;
    }
  }

  /// Get payment price for advertisement package
  double getPackagePrice(String packageId) {
    return StripeConfig.packagePrices[packageId] ?? 0.0;
  }

  /// Calculate total price based on package and duration
  double calculateTotalPrice({
    required String packageId,
    required int duration,
    required String durationType,
  }) {
    final basePrice = getPackagePrice(packageId);

    // Convert duration to weeks for calculation
    final durationInWeeks =
        durationType == 'week'
            ? duration
            : duration / 7; // If days, convert to weeks

    return basePrice * durationInWeeks;
  }
}
