import 'package:flutter/material.dart' hide Card;
import 'package:flutter/material.dart' as material show Card;
// Commented out for test mode, uncomment for production
// import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:provider/provider.dart';
import 'package:matajir/constants/app_colors.dart';
// Commented out for test mode, uncomment for production
// import 'package:matajir/controllers/payment_controller.dart';
import 'package:matajir/controllers/advertisement_controller.dart';
import 'package:matajir/services/stripe_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class PaymentScreen extends StatefulWidget {
  final String packageId;
  final int duration;
  final String durationType;
  final Map<String, dynamic> adData;
  final Function(bool success) onPaymentComplete;

  const PaymentScreen({
    Key? key,
    required this.packageId,
    required this.duration,
    required this.durationType,
    required this.adData,
    required this.onPaymentComplete,
  }) : super(key: key);

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  bool _isLoading = false;
  String? _error;
  double _totalPrice = 0;
  String? _advertisementId;

  @override
  void initState() {
    super.initState();
    _calculatePrice();
  }

  void _calculatePrice() {
    final totalPrice = StripeService.instance.calculateTotalPrice(
      packageId: widget.packageId,
      duration: widget.duration,
      durationType: widget.durationType,
    );

    setState(() {
      _totalPrice = totalPrice;
    });
  }

  Future<void> _processPayment() async {
    final localizations = AppLocalizations.of(context);
    // Commented out for test mode, uncomment for production
    // final paymentController = Provider.of<PaymentController>(
    //   context,
    //   listen: false,
    // );
    final adController = Provider.of<AdvertisementController>(
      context,
      listen: false,
    );

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // First create the advertisement in Supabase (unpaid)
      final adResult = await adController.createAdvertisement(
        name: widget.adData['name'],
        imageUrl: widget.adData['imageUrl'],
        clickUrl: widget.adData['clickUrl'],
        startsAt: widget.adData['startsAt'],
        endsAt: widget.adData['endsAt'],
        adType: widget.adData['adType'],
        categoryId: widget.adData['categoryId'],
        subcategoryId: widget.adData['subcategoryId'],
        storeId: widget.adData['storeId'],
        isPaid: false,
        paymentStatus: 'pending',
      );

      if (!adResult) {
        setState(() {
          _error =
              adController.error ?? localizations.failedToCreateAdvertisement;
          _isLoading = false;
        });
        return;
      }

      // Get the advertisement ID
      _advertisementId = adController.createdAdvertisementId;

      // For development/testing: Skip actual payment processing and mark as paid
      // Remove this in production and uncomment the Stripe code below
      if (true) {
        // Change to false to use actual Stripe payment
        // Simulate successful payment
        await Future.delayed(
          const Duration(seconds: 2),
        ); // Simulate processing time

        // Update the advertisement as paid
        final success = await adController.updateAdvertisement(
          id: _advertisementId!,
          isPaid: true,
          paymentStatus: 'succeeded',
          isActive: true,
        );

        if (success) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("${localizations.paymentSuccessful} (Test Mode)"),
                backgroundColor: Colors.green,
              ),
            );

            // Call the callback
            widget.onPaymentComplete(true);

            // Navigate back
            Navigator.pop(context);
          }
        } else {
          setState(() {
            _error =
                adController.error ?? localizations.paymentConfirmationFailed;
          });
        }
        return;
      }

      // REAL STRIPE PAYMENT PROCESSING - Uncomment for production
      /*
      // Create a payment intent
      final paymentIntent = await paymentController.processAdvertisementPayment(
        packageId: widget.packageId,
        duration: widget.duration,
        durationType: widget.durationType,
        description:
            'Advertisement: ${widget.adData['name']} (${widget.packageId})',
      );

      if (paymentIntent == null) {
        setState(() {
          _error =
              paymentController.error ?? localizations.paymentProcessingFailed;
          _isLoading = false;
        });
        return;
      }

      try {
        // Initialize the payment sheet
        await Stripe.instance.initPaymentSheet(
          paymentSheetParameters: SetupPaymentSheetParameters(
            paymentIntentClientSecret: paymentIntent['client_secret'],
            merchantDisplayName: 'Matajir',
            style: ThemeMode.light,
          ),
        );

        // Present the payment sheet
        await Stripe.instance.presentPaymentSheet();

        // Confirm the payment
        final success = await paymentController.confirmPayment(
          paymentIntentClientSecret: paymentIntent['client_secret'],
          packageId: widget.packageId,
          description:
              'Advertisement: ${widget.adData['name']} (${widget.packageId})',
          advertisementId: _advertisementId,
          storeId: widget.adData['storeId'],
        );

        if (success) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(localizations.paymentSuccessful),
                backgroundColor: Colors.green,
              ),
            );

            // Call the callback
            widget.onPaymentComplete(true);

            // Navigate back
            Navigator.pop(context);
          }
        } else {
          setState(() {
            _error =
                paymentController.error ??
                localizations.paymentConfirmationFailed;
          });
        }
      } catch (stripeError) {
        setState(() {
          _error = "Stripe error: $stripeError";
        });
      }
      */
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF673AB7), Color(0xFF311B92)],
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              // Sliver App Bar with back button and title
              SliverAppBar(
                backgroundColor: Colors.transparent,
                pinned: true,
                automaticallyImplyLeading: false,
                leading: GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Container(
                    margin: const EdgeInsets.all(8),
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
                      Icons.arrow_back,
                      color: Color(0xFF673AB7),
                      size: 20,
                    ),
                  ),
                ),
                title: Text(
                  localizations.payment,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              // Main content
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Payment Summary Card
                      material.Card(
                        elevation: 8,
                        shadowColor: Colors.black.withAlpha(76),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withAlpha(26),
                                blurRadius: 10,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Summary header
                              Row(
                                children: [
                                  const Icon(
                                    Icons.receipt_long,
                                    size: 20,
                                    color: Color(0xFF673AB7),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    localizations.paymentSummary,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF673AB7),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),

                              // Package details
                              _buildSummaryItem(
                                localizations.package,
                                _getPackageName(
                                  widget.packageId,
                                  localizations,
                                ),
                              ),
                              const Divider(),
                              _buildSummaryItem(
                                localizations.duration,
                                '${widget.duration} ${widget.durationType == 'week' ? localizations.weeks : localizations.days}',
                              ),
                              const Divider(),
                              _buildSummaryItem(
                                localizations.price,
                                '\$${_totalPrice.toStringAsFixed(2)}',
                                isTotal: true,
                              ),

                              if (_error != null) ...[
                                const SizedBox(height: 16),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.red.shade50,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: Colors.red.shade200,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.error_outline,
                                        color: Colors.red,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          _error!,
                                          style: const TextStyle(
                                            color: Colors.red,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Payment button
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.buttonPrimary.withAlpha(76),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _processPayment,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.buttonPrimary,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          child:
                              _isLoading
                                  ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                      strokeWidth: 2,
                                    ),
                                  )
                                  : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.payment, size: 20),
                                      const SizedBox(width: 10),
                                      Text(
                                        localizations.payNow,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ],
                                  ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: Colors.black87,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 18 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? AppColors.accentColor : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  String _getPackageName(String packageId, AppLocalizations localizations) {
    switch (packageId) {
      case 'home_spotlight':
        return localizations.homeSpotlight;
      case 'category_match':
        return localizations.categoryMatch;
      case 'top_store_boost':
        return localizations.topStoreBoost;
      default:
        return packageId;
    }
  }
}
