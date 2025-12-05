import 'dart:convert';
import 'package:http/http.dart' as http;

class PaymobService {
  // Paymob Credentials
  static const String _apiKey =
      'ZXlKaGJHY2lPaUpJVXpVeE1pSXNJblI1Y0NJNklrcFhWQ0o5LmV5SmpiR0Z6Y3lJNklrMWxjbU5vWVc1MElpd2ljSEp2Wm1sc1pWOXdheUk2T1RrME5UUXlMQ0p1WVcxbElqb2lNVGMwTkRnek1qZ3pPQzQxTlRBeU1qY2lmUS5sZ2RXVVlFQXduNTBuaVRwQXdOZGN1Y3dQY0QtOXozQk5IWGw1Rm5jMEVSamRDcFlmSWNlb2FsdzdzTEJ1V3g4Y3I4THd6OGVPV2lMM1gxMzFSeGFpdw==';
  static const int _integrationId = 4829834;
  static const int _iFrameId = 867265;

  static const String _baseUrl = 'https://accept.paymob.com/api';

  /// Step 1: Get authentication token
  Future<String> getAuthToken() async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/tokens'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'api_key': _apiKey}),
      );

      print('🔐 Auth response: ${response.statusCode}');

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        print('✅ Got auth token');
        return data['token'];
      }
      throw Exception('Failed to get auth token: ${response.body}');
    } catch (e) {
      print('❌ Auth error: $e');
      rethrow;
    }
  }

  /// Step 2: Create order
  Future<int> createOrder(String authToken, double amountCents) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/ecommerce/orders'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'auth_token': authToken,
          'delivery_needed': 'false',
          'amount_cents': amountCents.toInt().toString(),
          'currency': 'EGP',
        }),
      );

      print('📦 Order response: ${response.statusCode}');

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        print('✅ Order created: ${data['id']}');
        return data['id'];
      }
      throw Exception('Failed to create order: ${response.body}');
    } catch (e) {
      print('❌ Order error: $e');
      rethrow;
    }
  }

  /// Step 3: Get payment key
  Future<String> getPaymentKey({
    required String authToken,
    required int orderId,
    required double amountCents,
    required String userEmail,
    required String userName,
    required String userPhone,
    String? redirectionUrl,
  }) async {
    try {
      final nameParts = userName.split(' ');
      final firstName = nameParts.first;
      final lastName = nameParts.length > 1 ? nameParts.last : 'User';

      final Map<String, dynamic> body = {
        'auth_token': authToken,
        'amount_cents': amountCents.toInt().toString(),
        'expiration': 3600,
        'order_id': orderId.toString(),
        'billing_data': {
          'email': userEmail,
          'first_name': firstName,
          'last_name': lastName,
          'phone_number': userPhone.isEmpty ? '+201000000000' : userPhone,
          'apartment': 'NA',
          'floor': 'NA',
          'street': 'NA',
          'building': 'NA',
          'shipping_method': 'NA',
          'postal_code': 'NA',
          'city': 'Cairo',
          'country': 'EG',
          'state': 'NA',
        },
        'currency': 'EGP',
        'integration_id': _integrationId,
      };

      if (redirectionUrl != null) {
        body['redirection_url'] = redirectionUrl;
      }

      final response = await http.post(
        Uri.parse('$_baseUrl/acceptance/payment_keys'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      print('🔑 Payment key response: ${response.statusCode}');

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        print('✅ Payment key obtained');
        return data['token'];
      }
      
      // If 400 and we sent a redirect URL, retry without it
      if (response.statusCode == 400 && redirectionUrl != null) {
        print('⚠️  400 error with redirect URL, retrying without it...');
        body.remove('redirection_url');
        
        final retryResponse = await http.post(
          Uri.parse('$_baseUrl/acceptance/payment_keys'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(body),
        );
        
        print('🔑 Retry response: ${retryResponse.statusCode}');
        
        if (retryResponse.statusCode == 201) {
          final data = jsonDecode(retryResponse.body);
          print('✅ Payment key obtained (without redirect URL)');
          return data['token'];
        }
      }
      
      throw Exception('Failed to get payment key: ${response.body}');
    } catch (e) {
      print('❌ Payment key error: $e');
      rethrow;
    }
  }

  /// Main method: Get payment URL
  Future<String> getPaymentUrl({
    required double amountInDollars,
    required String userEmail,
    required String userName,
    required String userPhone,
    String? redirectionUrl,
  }) async {
    try {
      print('💰 Processing payment: \$${amountInDollars.toStringAsFixed(2)}');

      // Convert USD to EGP cents (1 USD = 31 EGP approximately, * 100 for cents)
      final amountCents = amountInDollars * 31 * 100;
      print('💵 Amount in EGP cents: $amountCents');

      // Step 1: Get auth token
      final authToken = await getAuthToken();

      // Step 2: Create order
      final orderId = await createOrder(authToken, amountCents);

      // Step 3: Get payment key
      final paymentKey = await getPaymentKey(
        authToken: authToken,
        orderId: orderId,
        amountCents: amountCents,
        userEmail: userEmail,
        userName: userName,
        userPhone: userPhone,
        redirectionUrl: redirectionUrl,
      );

      // Return payment URL for iFrame
      final paymentUrl =
          'https://accept.paymob.com/api/acceptance/iframes/$_iFrameId?payment_token=$paymentKey';
      print('🌐 Payment URL generated');
      return paymentUrl;
    } catch (e) {
      print('❌ Payment processing failed: $e');
      throw Exception('Payment processing failed: $e');
    }
  }
}
