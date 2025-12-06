import 'package:flutter_test/flutter_test.dart';
import 'package:proj/utils/payment_link_handler.dart';

void main() {
  group('PaymentLinkHandler - Extended Edge Cases', () {
    test('handles web failure URL with specific error message', () {
      final uri = Uri.parse(
        'http://localhost:8080/paymob-success?success=false&id=456&error=payment_declined',
      );
      final result = PaymentLinkHandler.handle(uri);

      expect(result.isSuccess, false);
      expect(result.orderId, '456');
      expect(result.errorMessage, isNotNull);
      expect(result.errorMessage, contains('Payment failed or declined'));
    });

    test('handles malformed query parameters gracefully', () {
      final uri = Uri.parse('antigravity://paymob-success?status=&order_id=');
      final result = PaymentLinkHandler.handle(uri);

      // Should handle empty values gracefully
      expect(result.isSuccess, false); // Empty status is not 'success'
      expect(result.orderId, ''); // Empty order_id returned as empty string
    });

    test('handles query string with no parameters', () {
      final uri = Uri.parse('antigravity://paymob-success');
      final result = PaymentLinkHandler.handle(uri);

      expect(result.isSuccess, false);
      expect(result.orderId, null);
    });

    test('handles case-insensitive success status', () {
      final uri1 = Uri.parse(
        'antigravity://paymob-success?status=SUCCESS&order_id=123',
      );
      final uri2 = Uri.parse(
        'antigravity://paymob-success?status=Success&order_id=456',
      );
      final uri3 = Uri.parse(
        'antigravity://paymob-success?status=success&order_id=789',
      );

      final result1 = PaymentLinkHandler.handle(uri1);
      final result2 = PaymentLinkHandler.handle(uri2);
      final result3 = PaymentLinkHandler.handle(uri3);

      expect(result1.isSuccess, true);
      expect(result2.isSuccess, true);
      expect(result3.isSuccess, true);
    });

    test('handles multiple status indicators (prioritizes status parameter)', () {
      final uri = Uri.parse(
        'antigravity://paymob-success?status=success&success=false&order_id=999',
      );
      final result = PaymentLinkHandler.handle(uri);

      // Should use 'status' parameter first
      expect(result.isSuccess, true);
      expect(result.orderId, '999');
    });

    test('handles order_id vs id parameter priority', () {
      final uri = Uri.parse(
        'antigravity://paymob-success?status=success&order_id=111&id=222',
      );
      final result = PaymentLinkHandler.handle(uri);

      // Should prioritize 'order_id' over 'id'
      expect(result.orderId, '111');
    });

    test('handles very long order IDs', () {
      const longOrderId = '123456789012345678901234567890';
      final uri = Uri.parse(
        'antigravity://paymob-success?status=success&order_id=$longOrderId',
      );
      final result = PaymentLinkHandler.handle(uri);

      expect(result.isSuccess, true);
      expect(result.orderId, longOrderId);
    });

    test('handles special characters in order ID', () {
      const specialOrderId = 'ORD-2024-ABC-123_XYZ';
      final uri = Uri.parse(
        'antigravity://paymob-success?status=success&order_id=$specialOrderId',
      );
      final result = PaymentLinkHandler.handle(uri);

      expect(result.isSuccess, true);
      expect(result.orderId, specialOrderId);
    });

    test('handles extra query parameters gracefully', () {
      final uri = Uri.parse(
        'antigravity://paymob-success?status=success&order_id=123&extra1=value&extra2=test&timestamp=1234567890',
      );
      final result = PaymentLinkHandler.handle(uri);

      // Should ignore extra parameters and work correctly
      expect(result.isSuccess, true);
      expect(result.orderId, '123');
    });

    test('handles paymob-bridge path correctly', () {
      final uri = Uri.parse(
        'http://localhost:8080/paymob-bridge?status=success&order_id=bridge-123',
      );
      final result = PaymentLinkHandler.handle(uri);

      expect(result.isSuccess, true);
      expect(result.orderId, 'bridge-123');
    });

    test('rejects non-paymob paths', () {
      final uri1 = Uri.parse(
        'http://localhost:8080/random-path?status=success',
      );
      final uri2 = Uri.parse('http://localhost:8080/payment?status=success');

      final result1 = PaymentLinkHandler.handle(uri1);
      final result2 = PaymentLinkHandler.handle(uri2);

      expect(result1.isSuccess, false);
      expect(result1.errorMessage, contains('Invalid payment link format'));
      expect(result2.isSuccess, false);
      expect(result2.errorMessage, contains('Invalid payment link format'));
    });

    test('handles failed status explicitly', () {
      final uri = Uri.parse(
        'antigravity://paymob-success?status=failed&order_id=999',
      );
      final result = PaymentLinkHandler.handle(uri);

      expect(result.isSuccess, false);
      expect(result.orderId, '999');
      expect(result.errorMessage, contains('Payment failed or declined'));
    });

    test('handles different host for deep link', () {
      final uri = Uri.parse(
        'antigravity://payment-callback?status=success&order_id=123',
      );
      final result = PaymentLinkHandler.handle(uri);

      // Should fail because host is not 'paymob-success'
      expect(result.isSuccess, false);
    });

    test('handles https scheme web URLs', () {
      final uri = Uri.parse(
        'https://myapp.com/paymob-success?status=success&order_id=https-123',
      );
      final result = PaymentLinkHandler.handle(uri);

      expect(result.isSuccess, true);
      expect(result.orderId, 'https-123');
    });

    test('error message is null for successful payments', () {
      final uri = Uri.parse(
        'antigravity://paymob-success?status=success&order_id=123',
      );
      final result = PaymentLinkHandler.handle(uri);

      expect(result.isSuccess, true);
      expect(result.errorMessage, isNull);
    });
  });
}
