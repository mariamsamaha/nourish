import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import 'package:proj/services/paymob_service.dart';
import 'package:proj/services/database_service.dart';
import 'package:proj/services/auth_service.dart';
import 'package:proj/services/firestore_service.dart';
import 'package:proj/screens/paymob_webview.dart';

class PaymobCheckoutScreen extends StatefulWidget {
  final double totalAmount;
  final List<Map<String, dynamic>> cartItems;

  const PaymobCheckoutScreen({
    super.key,
    required this.totalAmount,
    required this.cartItems,
  });

  @override
  State<PaymobCheckoutScreen> createState() => _PaymobCheckoutScreenState();
}

class _PaymobCheckoutScreenState extends State<PaymobCheckoutScreen> {
  final PaymobService _paymobService = PaymobService();
  String? _paymentUrl;
  bool _isLoadingUrl = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initializePayment();
  }

  Future<void> _initializePayment() async {
    try {
      print('🚀 Initializing payment...');

      final authService = Provider.of<AuthService>(context, listen: false);
      final userEmail =
          await authService.getStoredUserEmail() ?? 'user@nourish.com';
      final userName = await authService.getStoredUserName() ?? 'Nourish User';

      // Determine redirection URL based on platform
      String? redirectionUrl;
      if (kIsWeb) {
        // For Web: Use current origin + success route
        // Note: Uri.base works in Flutter Web to get current URL
        final origin = Uri.base.origin;
        redirectionUrl = '$origin/paymob-success';
        print('🌐 Web Redirection URL: $redirectionUrl');
      } else {
        // For Mobile: Use deep link
        redirectionUrl = 'antigravity://paymob-success';
        print('📱 Mobile Redirection URL: $redirectionUrl');
      }

      // Get payment URL from Paymob
      final paymentUrl = await _paymobService.getPaymentUrl(
        amountInDollars: widget.totalAmount,
        userEmail: userEmail,
        userName: userName,
        userPhone: '+201000000000',
        redirectionUrl: redirectionUrl,
      );

      print('✅ Payment URL ready: $paymentUrl');

      setState(() {
        _paymentUrl = paymentUrl;
        _isLoadingUrl = false;
      });
    } catch (e) {
      print('❌ Payment init error: $e');
      setState(() {
        _error = e.toString();
        _isLoadingUrl = false;
      });
    }
  }

  Future<void> _handlePaymentResult(bool success) async {
    if (success) {
      print('✅ PAYMENT SUCCESS!');
      await _handlePaymentSuccess();
    } else {
      print('❌ PAYMENT FAILED');
      _handlePaymentFailure();
    }
  }

  Future<void> _handlePaymentSuccess() async {
    print('🎉 Processing successful payment...');

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final dbService = Provider.of<DatabaseService>(context, listen: false);
      final userId = await authService.getStoredUserId();

      if (userId != null) {
        print('🧹 Clearing cart...');
        await dbService.clearCart(userId);
        print('✅ Cart cleared!');
      }

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      print('❌ Error processing payment: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Payment succeeded but order processing failed: $e'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  void _handlePaymentFailure() {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Payment failed. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
      Navigator.pop(context, false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Paymob Payment',
          style: TextStyle(
            color: Color(0xFF1B5E20),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF1B5E20)),
        actions: [
          // Fake success button for testing
          if (kIsWeb)
            IconButton(
              icon: const Icon(Icons.check_circle, color: Colors.green),
              tooltip: 'Test: Simulate Success',
              onPressed: () => _handlePaymentSuccess(),
            ),
        ],
      ),
      body: _isLoadingUrl
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Color(0xFF4CAF50)),
                  SizedBox(height: 16),
                  Text(
                    'Preparing payment...',
                    style: TextStyle(fontSize: 16, color: Color(0xFF1B5E20)),
                  ),
                ],
              ),
            )
          : _error != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error, color: Colors.red, size: 64),
                    const SizedBox(height: 16),
                    const Text(
                      'Payment Error',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _error!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context, false),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4CAF50),
                      ),
                      child: const Text(
                        'Go Back',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : PaymobWebView(
              url: _paymentUrl!,
              onPaymentResult: _handlePaymentResult,
            ),
      floatingActionButton: kIsWeb
          ? FloatingActionButton.extended(
              onPressed: _handlePaymentSuccess,
              label: const Text('BYPASS PAYMENT'),
              icon: const Icon(Icons.check),
              backgroundColor: Colors.green,
            )
          : null,
    );
  }
}
