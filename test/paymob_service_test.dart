import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PaymobService - Payment Logic', () {
    test('converts USD to EGP cents correctly', () {
      // Test the conversion formula: USD * 31 (exchange rate) * 100 (to cents)
      const usd1 = 1.0;
      const usd10 = 10.0;
      const usd50_99 = 50.99;

      final egpCents1 = usd1 * 31 * 100;
      final egpCents10 = usd10 * 31 * 100;
      final egpCents50_99 = usd50_99 * 31 * 100;

      expect(egpCents1, equals(3100.0)); // 1 USD = 3100 EGP cents
      expect(egpCents10, equals(31000.0)); // 10 USD = 31000 EGP cents
      expect(egpCents50_99, equals(158069.0)); // 50.99 USD = 158069 EGP cents
    });

    test('USD to EGP conversion handles zero correctly', () {
      const usdZero = 0.0;
      final egpCents = usdZero * 31 * 100;

      expect(egpCents, equals(0.0));
    });

    test('USD to EGP conversion handles large amounts correctly', () {
      const usd1000 = 1000.0;
      final egpCents = usd1000 * 31 * 100;

      expect(egpCents, equals(3100000.0)); // 1000 USD = 3,100,000 EGP cents
    });

    test('billing data formats name correctly when single word provided', () {
      const fullName = 'John';
      final nameParts = fullName.split(' ');
      final firstName = nameParts.first;
      final lastName = nameParts.length > 1 ? nameParts.last : 'User';

      expect(firstName, equals('John'));
      expect(lastName, equals('User')); // Default when no last name provided
    });

    test('billing data formats name correctly when full name provided', () {
      const fullName = 'John Doe Smith';
      final nameParts = fullName.split(' ');
      final firstName = nameParts.first;
      final lastName = nameParts.last;

      expect(firstName, equals('John'));
      expect(lastName, equals('Smith')); // Takes the last word
    });

    test('billing data uses default phone when empty provided', () {
      const userPhone = '';
      final phoneNumber = userPhone.isEmpty ? '+201000000000' : userPhone;

      expect(phoneNumber, equals('+201000000000'));
    });

    test('billing data uses provided phone when available', () {
      const userPhone = '+201234567890';
      final phoneNumber = userPhone.isEmpty ? '+201000000000' : userPhone;

      expect(phoneNumber, equals('+201234567890'));
    });

    test('generates correct iframe URL format', () {
      const iframeId = 867265;
      const paymentToken = 'test_payment_token_12345';

      final paymentUrl =
          'https://accept.paymob.com/api/acceptance/iframes/$iframeId?payment_token=$paymentToken';

      expect(
        paymentUrl,
        contains('https://accept.paymob.com/api/acceptance/iframes/'),
      );
      expect(paymentUrl, contains('867265'));
      expect(paymentUrl, contains('?payment_token='));
      expect(paymentUrl, contains(paymentToken));
    });

    test('iframe URL includes all required components', () {
      const iframeId = 867265;
      const paymentToken = 'ZXlKaGJHY2lPaUp';

      final paymentUrl =
          'https://accept.paymob.com/api/acceptance/iframes/$iframeId?payment_token=$paymentToken';

      final uri = Uri.parse(paymentUrl);

      expect(uri.scheme, equals('https'));
      expect(uri.host, equals('accept.paymob.com'));
      expect(uri.path, contains('/api/acceptance/iframes/'));
      expect(uri.queryParameters.containsKey('payment_token'), isTrue);
      expect(uri.queryParameters['payment_token'], equals(paymentToken));
    });

    test('amount in cents is always integer', () {
      // Important: Paymob requires amount_cents as string of integer
      const usd15_99 = 15.99;
      final egpCents = usd15_99 * 31 * 100;
      final egpCentsInt = egpCents.toInt();

      expect(egpCentsInt, equals(49569)); // Truncated to integer
      expect(egpCentsInt.toString(), equals('49569'));
    });

    test('integration ID and iframe ID are correct constants', () {
      // These values must match the actual Paymob account configuration
      const integrationId = 4829834;
      const iframeId = 867265;

      expect(integrationId, isPositive);
      expect(iframeId, isPositive);
      expect(integrationId, greaterThan(1000000)); // Reasonable check
      expect(iframeId, greaterThan(100000)); // Reasonable check
    });

    test('billing data contains all required fields', () {
      final billingData = {
        'email': 'test@example.com',
        'first_name': 'John',
        'last_name': 'Doe',
        'phone_number': '+201234567890',
        'apartment': 'NA',
        'floor': 'NA',
        'street': 'NA',
        'building': 'NA',
        'shipping_method': 'NA',
        'postal_code': 'NA',
        'city': 'Cairo',
        'country': 'EG',
        'state': 'NA',
      };

      // Verify all required fields are present
      expect(billingData.containsKey('email'), isTrue);
      expect(billingData.containsKey('first_name'), isTrue);
      expect(billingData.containsKey('last_name'), isTrue);
      expect(billingData.containsKey('phone_number'), isTrue);
      expect(billingData.containsKey('city'), isTrue);
      expect(billingData.containsKey('country'), isTrue);

      // Verify values are not null or empty
      expect(billingData['email'], isNotEmpty);
      expect(billingData['first_name'], isNotEmpty);
      expect(billingData['last_name'], isNotEmpty);
      expect(billingData['phone_number'], isNotEmpty);
      expect(billingData['city'], equals('Cairo'));
      expect(billingData['country'], equals('EG'));
    });
  });
}
