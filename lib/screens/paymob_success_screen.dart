import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proj/services/database_service.dart';
import 'package:proj/services/auth_service.dart';
import 'package:proj/routes/app_routes.dart';
import 'package:proj/services/iframe_bridge.dart';

class PaymobSuccessScreen extends StatefulWidget {
  const PaymobSuccessScreen({super.key});

  @override
  State<PaymobSuccessScreen> createState() => _PaymobSuccessScreenState();
}

class _PaymobSuccessScreenState extends State<PaymobSuccessScreen> {
  bool _isProcessing = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _processPaymentSuccess();
  }

  Future<void> _processPaymentSuccess() async {
    try {
      // Notify parent window if in iframe (Web)
      IframeBridge.sendSuccess();
      
      // Extract query parameters if any (for web)
      // Note: In a real app, you might want to verify the HMAC from query params here.
      // For now, we assume if we reached this page, the payment was successful.
      
      final authService = Provider.of<AuthService>(context, listen: false);
      final dbService = Provider.of<DatabaseService>(context, listen: false);
      final userId = await authService.getStoredUserId();

      if (userId != null) {
        print('🧹 Clearing cart for user: $userId');
        await dbService.clearCart(userId);
      }

      if (mounted) {
        setState(() => _isProcessing = false);
        
        // Auto-redirect after a short delay
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) {
            Navigator.of(context).pushNamedAndRemoveUntil(
              AppRoutes.home,
              (route) => false,
            );
          }
        });
      }
    } catch (e) {
      print('❌ Error processing payment success: $e');
      if (mounted) {
        setState(() {
          _isProcessing = false;
          _error = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_isProcessing)
                const CircularProgressIndicator(color: Colors.green)
              else if (_error != null)
                Column(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 80),
                    const SizedBox(height: 16),
                    Text(
                      'Error Processing Order',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(_error!),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil(
                        AppRoutes.home,
                        (route) => false,
                      ),
                      child: const Text('Go Home'),
                    ),
                  ],
                )
              else
                Column(
                  children: [
                    const Icon(Icons.check_circle_outline, color: Colors.green, size: 100),
                    const SizedBox(height: 24),
                    Text(
                      'Payment Successful!',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Your order has been placed successfully.\nRedirecting you to home...',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil(
                        AppRoutes.home,
                        (route) => false,
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      ),
                      child: const Text(
                        'Continue Shopping',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
