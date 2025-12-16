import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/app_config.dart';

class StripeService {
  static final StripeService _instance = StripeService._internal();
  factory StripeService() => _instance;
  StripeService._internal();

  bool _initialized = false;

  /// Initialize Stripe with publishable key
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      Stripe.publishableKey = AppConfig.stripePublishableKey;
      Stripe.merchantIdentifier = 'merchant.com.gidyo.app';
      Stripe.urlScheme = 'gidyo';

      await Stripe.instance.applySettings();

      _initialized = true;
      debugPrint('✅ Stripe initialized successfully');
    } catch (e) {
      debugPrint('❌ Failed to initialize Stripe: $e');
      rethrow;
    }
  }

  /// Create a payment intent on the server
  Future<Map<String, dynamic>> createPaymentIntent({
    required double amount,
    required String guideId,
    String? bookingId,
    String currency = 'usd',
    Map<String, dynamic>? metadata,
  }) async {
    try {
      debugPrint('Creating payment intent for amount: \$${amount.toStringAsFixed(2)}');

      final response = await http.post(
        Uri.parse('${AppConfig.apiBaseUrl}/api/stripe/create-payment-intent'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${AppConfig.supabaseAnonKey}',
        },
        body: jsonEncode({
          'amount': amount,
          'currency': currency,
          'guide_id': guideId,
          if (bookingId != null) 'booking_id': bookingId,
          if (metadata != null) 'metadata': metadata,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        debugPrint('✅ Payment intent created: ${data['payment_intent_id']}');
        return data;
      } else {
        final error = jsonDecode(response.body);
        throw StripeException(error['error'] ?? 'Failed to create payment intent');
      }
    } catch (e) {
      debugPrint('❌ Error creating payment intent: $e');
      rethrow;
    }
  }

  /// Confirm payment with client secret
  Future<PaymentIntentResult> confirmPayment({
    required String clientSecret,
    String? paymentMethodId,
    BillingDetails? billingDetails,
  }) async {
    try {
      debugPrint('Confirming payment...');

      // If payment method ID is provided, use it
      // Otherwise, Stripe will use the default payment method UI
      final paymentMethod = paymentMethodId != null
          ? PaymentMethodParams.card(
              paymentMethodData: PaymentMethodData(
                billingDetails: billingDetails,
              ),
            )
          : null;

      // Present payment sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: 'GIDYO',
          style: ThemeMode.system,
          billingDetails: billingDetails,
          appearance: PaymentSheetAppearance(
            colors: PaymentSheetAppearanceColors(
              primary: const Color(0xFF14B8A6),
            ),
          ),
        ),
      );

      // Present the payment sheet
      await Stripe.instance.presentPaymentSheet();

      debugPrint('✅ Payment confirmed successfully');

      // Return success result
      return PaymentIntentResult(
        status: PaymentIntentStatus.succeeded,
        paymentIntentId: _extractPaymentIntentId(clientSecret),
      );
    } on StripeException catch (e) {
      debugPrint('❌ Stripe error: ${e.error.message}');

      if (e.error.code == FailureCode.Canceled) {
        return PaymentIntentResult(
          status: PaymentIntentStatus.canceled,
          error: 'Payment canceled by user',
        );
      }

      return PaymentIntentResult(
        status: PaymentIntentStatus.failed,
        error: e.error.message ?? 'Payment failed',
      );
    } catch (e) {
      debugPrint('❌ Error confirming payment: $e');
      return PaymentIntentResult(
        status: PaymentIntentStatus.failed,
        error: e.toString(),
      );
    }
  }

  /// Handle 3D Secure authentication if required
  Future<PaymentIntentResult> handle3DSecure({
    required String clientSecret,
  }) async {
    try {
      debugPrint('Handling 3D Secure authentication...');

      final paymentIntent = await Stripe.instance.handleNextAction(
        clientSecret,
      );

      if (paymentIntent.status == PaymentIntentsStatus.Succeeded) {
        debugPrint('✅ 3D Secure authentication successful');
        return PaymentIntentResult(
          status: PaymentIntentStatus.succeeded,
          paymentIntentId: paymentIntent.id,
        );
      } else if (paymentIntent.status == PaymentIntentsStatus.RequiresPaymentMethod) {
        return PaymentIntentResult(
          status: PaymentIntentStatus.requiresPaymentMethod,
          error: 'Payment method required',
        );
      } else {
        return PaymentIntentResult(
          status: PaymentIntentStatus.processing,
          paymentIntentId: paymentIntent.id,
        );
      }
    } catch (e) {
      debugPrint('❌ Error handling 3D Secure: $e');
      return PaymentIntentResult(
        status: PaymentIntentStatus.failed,
        error: e.toString(),
      );
    }
  }

  /// Complete payment flow (create + confirm)
  Future<PaymentIntentResult> processPayment({
    required double amount,
    required String guideId,
    String? bookingId,
    BillingDetails? billingDetails,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      // Step 1: Create payment intent
      final paymentIntentData = await createPaymentIntent(
        amount: amount,
        guideId: guideId,
        bookingId: bookingId,
        metadata: metadata,
      );

      final clientSecret = paymentIntentData['client_secret'] as String;
      final paymentIntentId = paymentIntentData['payment_intent_id'] as String;

      // Step 2: Confirm payment
      final result = await confirmPayment(
        clientSecret: clientSecret,
        billingDetails: billingDetails,
      );

      return result.copyWith(paymentIntentId: paymentIntentId);
    } catch (e) {
      debugPrint('❌ Error processing payment: $e');
      return PaymentIntentResult(
        status: PaymentIntentStatus.failed,
        error: e.toString(),
      );
    }
  }

  /// Retrieve payment intent status
  Future<Map<String, dynamic>> getPaymentIntentStatus(
    String paymentIntentId,
  ) async {
    try {
      final response = await http.get(
        Uri.parse(
          '${AppConfig.apiBaseUrl}/api/stripe/create-payment-intent?payment_intent_id=$paymentIntentId',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${AppConfig.supabaseAnonKey}',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to get payment intent status');
      }
    } catch (e) {
      debugPrint('❌ Error getting payment intent status: $e');
      rethrow;
    }
  }

  /// Extract payment intent ID from client secret
  String _extractPaymentIntentId(String clientSecret) {
    return clientSecret.split('_secret_')[0];
  }

  /// Handle common payment errors
  String getErrorMessage(String? errorCode) {
    switch (errorCode) {
      case 'card_declined':
        return 'Your card was declined. Please try a different card.';
      case 'insufficient_funds':
        return 'Insufficient funds. Please use a different payment method.';
      case 'expired_card':
        return 'Your card has expired. Please use a different card.';
      case 'incorrect_cvc':
        return 'Incorrect security code. Please check and try again.';
      case 'processing_error':
        return 'An error occurred while processing your card. Please try again.';
      case 'incorrect_number':
        return 'Incorrect card number. Please check and try again.';
      default:
        return 'Payment failed. Please try again.';
    }
  }
}

/// Payment intent result model
class PaymentIntentResult {
  final PaymentIntentStatus status;
  final String? paymentIntentId;
  final String? error;

  PaymentIntentResult({
    required this.status,
    this.paymentIntentId,
    this.error,
  });

  bool get isSuccess => status == PaymentIntentStatus.succeeded;
  bool get isCanceled => status == PaymentIntentStatus.canceled;
  bool get isFailed => status == PaymentIntentStatus.failed;

  PaymentIntentResult copyWith({
    PaymentIntentStatus? status,
    String? paymentIntentId,
    String? error,
  }) {
    return PaymentIntentResult(
      status: status ?? this.status,
      paymentIntentId: paymentIntentId ?? this.paymentIntentId,
      error: error ?? this.error,
    );
  }
}

/// Payment intent status enum
enum PaymentIntentStatus {
  succeeded,
  processing,
  requiresPaymentMethod,
  requiresAction,
  canceled,
  failed,
}

/// Custom Stripe exception
class StripeException implements Exception {
  final String message;

  StripeException(this.message);

  @override
  String toString() => message;
}
