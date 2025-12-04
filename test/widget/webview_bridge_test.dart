import 'package:flutter_test/flutter_test.dart';
import 'package:proj/utils/payment_link_handler.dart';

void main() {
  group('WebView Bridge Tests', () {
    test('parses WebView bridge redirect with success', () {
      final uri = Uri.parse(
        'http://localhost:8080/paymob-bridge?status=success&order_id=12345',
      );
      final result = PaymentLinkHandler.handle(uri);

      expect(result.isSuccess, true);
      expect(result.orderId, '12345');
    });

    test('detects failure in bridge URL', () {
      final uri = Uri.parse(
        'http://localhost:8080/paymob-bridge?status=failed',
      );
      final result = PaymentLinkHandler.handle(uri);

      expect(result.isSuccess, false);
      expect(result.errorMessage, isNotNull);
    });

    test('handles paymob-success web route', () {
      final uri = Uri.parse(
        'http://localhost:3000/paymob-success?success=true&id=999',
      );
      final result = PaymentLinkHandler.handle(uri);

      expect(result.isSuccess, true);
      expect(result.orderId, '999');
    });

    test('extracts order_id from different parameter names', () {
      // Test with 'id' parameter
      final uri1 = Uri.parse(
        'http://localhost/paymob-success?id=111&success=true',
      );
      final result1 = PaymentLinkHandler.handle(uri1);
      expect(result1.orderId, '111');

      // Test with 'order_id' parameter
      final uri2 = Uri.parse(
        'antigravity://paymob-success?order_id=222&status=success',
      );
      final result2 = PaymentLinkHandler.handle(uri2);
      expect(result2.orderId, '222');
    });
  });
}
