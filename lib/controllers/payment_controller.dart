import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/payment.dart';
import '../services/stripe_service.dart';

class PaymentController extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;
  final StripeService _stripeService = StripeService.instance;

  bool _isLoading = false;
  String? _error;
  List<Payment> _payments = [];

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<Payment> get payments => _payments;

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  /// Process payment for an advertisement
  Future<Map<String, dynamic>?> processAdvertisementPayment({
    required String packageId,
    required int duration,
    required String durationType,
    required String description,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        _setError('User not authenticated');
        return null;
      }

      // Calculate the total price
      final totalPrice = _stripeService.calculateTotalPrice(
        packageId: packageId,
        duration: duration,
        durationType: durationType,
      );

      // Create a payment intent
      final paymentIntent = await _stripeService.createPaymentIntent(
        amount: totalPrice.toString(),
        currency: 'usd',
        description: description,
      );

      return paymentIntent;
    } catch (e) {
      _setError('Failed to process payment: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  /// Confirm payment with Stripe
  Future<bool> confirmPayment({
    required String paymentIntentClientSecret,
    required String packageId,
    required String description,
    String? advertisementId,
    String? storeId,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        _setError('User not authenticated');
        return false;
      }

      // Confirm the payment with Stripe
      final paymentResult = await _stripeService.processPayment(
        paymentIntentClientSecret: paymentIntentClientSecret,
      );

      // Save the payment record to Supabase and get the payment UUID
      final paymentUuid = await _stripeService.savePaymentRecord(
        userId: userId,
        paymentIntentId: paymentResult['paymentIntentId'],
        amount: paymentResult['amount'],
        currency: 'usd',
        status: paymentResult['status'],
        description: description,
        advertisementId: advertisementId,
        storeId: storeId,
      );

      // If this is for an advertisement, update the advertisement record
      if (advertisementId != null) {
        await _supabase
            .from('advertisements')
            .update({
              'is_paid': true,
              'payment_status': 'succeeded',
              'is_active': true,
              'payment_id': paymentUuid, // Use the payment UUID
            })
            .eq('id', advertisementId);
      }

      // If this is for a store promotion, update the store record
      if (storeId != null && packageId == 'top_store_boost') {
        await _supabase
            .from('stores')
            .update({'is_promoted': true})
            .eq('id', storeId);
      }

      return true;
    } catch (e) {
      _setError('Failed to confirm payment: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Fetch payment history for the current user
  Future<void> fetchPaymentHistory() async {
    _setLoading(true);
    _setError(null);

    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        _setError('User not authenticated');
        return;
      }

      final response = await _supabase
          .from('payments')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      _payments =
          response
              .map((payment) => Payment.fromJson(payment))
              .toList()
              .cast<Payment>();

      notifyListeners();
    } catch (e) {
      _setError('Failed to fetch payment history: $e');
    } finally {
      _setLoading(false);
    }
  }
}
