import 'package:flutter_test/flutter_test.dart';
import 'package:proj/utils/payment_link_handler.dart';

void main() {
  group('PaymentLinkHandler', () {
    test('handles paymob success deep link', () {
      final uri = Uri.parse(
        'antigravity://paymob-success?status=success&order_id=123',
      );
      final result = PaymentLinkHandler.handle(uri);

      expect(result.isSuccess, true);
      expect(result.orderId, '123');
      expect(result.errorMessage, null);
    });

    test('handles paymob failure deep link', () {
      final uri = Uri.parse(
        'antigravity://paymob-success?status=failed&order_id=456',
      );
      final result = PaymentLinkHandler.handle(uri);

      expect(result.isSuccess, false);
      expect(result.orderId, '456');
      expect(result.errorMessage, isNotNull);
    });

    test('handles web success URL with query params', () {
      final uri = Uri.parse(
        'http://localhost:8080/paymob-success?success=true&id=789',
      );
      final result = PaymentLinkHandler.handle(uri);

      expect(result.isSuccess, true);
      expect(result.orderId, '789');
    });

    test('handles paymob bridge URL', () {
      final uri = Uri.parse(
        'http://localhost:8080/paymob-bridge?status=success&order_id=999',
      );
      final result = PaymentLinkHandler.handle(uri);

      expect(result.isSuccess, true);
      expect(result.orderId, '999');
    });

    test('rejects invalid scheme', () {
      final uri = Uri.parse('http://example.com/random');
      final result = PaymentLinkHandler.handle(uri);

      expect(result.isSuccess, false);
      expect(result.errorMessage, contains('Invalid payment link format'));
    });

    test('handles missing order_id gracefully', () {
      final uri = Uri.parse('antigravity://paymob-success?status=success');
      final result = PaymentLinkHandler.handle(uri);

      expect(result.isSuccess, true);
      expect(result.orderId, null);
    });
  });
}
