class PaymentLinkResult {
  final bool isSuccess;
  final String? orderId;
  final String? errorMessage;

  PaymentLinkResult({required this.isSuccess, this.orderId, this.errorMessage});
}

class PaymentLinkHandler {
  /// Parse and validate Paymob deep link
  /// Supports both antigravity://paymob-success and web URLs
  static PaymentLinkResult handle(Uri uri) {
    try {
      // Check for deep link scheme
      if (uri.scheme == 'antigravity' && uri.host == 'paymob-success') {
        return _parseQueryParams(uri);
      }

      // Check for web success path
      if (uri.path.contains('paymob-success') ||
          uri.path.contains('paymob-bridge')) {
        return _parseQueryParams(uri);
      }

      return PaymentLinkResult(
        isSuccess: false,
        errorMessage: 'Invalid payment link format',
      );
    } catch (e) {
      return PaymentLinkResult(
        isSuccess: false,
        errorMessage: 'Error parsing payment link: $e',
      );
    }
  }

  static PaymentLinkResult _parseQueryParams(Uri uri) {
    final status =
        uri.queryParameters['status'] ?? uri.queryParameters['success'] ?? '';
    final orderId =
        uri.queryParameters['order_id'] ?? uri.queryParameters['id'];

    final isSuccess =
        status.toLowerCase() == 'success' ||
        status.toLowerCase() == 'true' ||
        uri.queryParameters['success'] == 'true';

    return PaymentLinkResult(
      isSuccess: isSuccess,
      orderId: orderId,
      errorMessage: isSuccess ? null : 'Payment failed or declined',
    );
  }
}
