import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:proj/services/data_service.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class AIService {
  final String _apiKey;
  final String _baseUrl = 'https://api.groq.com/openai/v1';
  final String _model = 'llama-3.3-70b-versatile';  
  final DataService _dataService = DataService();

  AIService() : _apiKey = dotenv.env['GROQ_API_KEY'] ?? '';

  /// Basic ask method without context
  Future<String> ask(String prompt) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/chat/completions'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': _model,
          'messages': [
            {'role': 'user', 'content': prompt},
          ],
          'temperature': 0.7,
          'max_tokens': 1024,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'] ?? 'No response';
      } else {
        print('API Error: ${response.statusCode} - ${response.body}');
        return 'Error: Unable to get response';
      }
    } catch (e) {
      print('Error in ask: $e');
      return 'Error: $e';
    }
  }

  /// Ask with user context for personalized AI support
  /// This method enriches the AI with knowledge about the user's data
  Future<String> askWithContext({
    required String userId,
    required String userQuestion,
    bool includeRestaurants = true,
    bool includeMeals = true,
    bool includeCharities = true,
  }) async {
    try {
      // Get user context
      final userContext = await _dataService.getUserContext(userId);

      // Get app data
      List<Map<String, dynamic>> restaurants = [];
      List<Map<String, dynamic>> meals = [];
      List<Map<String, dynamic>> charities = [];

      if (includeRestaurants) {
        restaurants = await _dataService.getRestaurants();
      }
      if (includeMeals) {
        meals = await _dataService.getAvailableMeals();
      }
      if (includeCharities) {
        charities = await _dataService.getCharities();
      }

      // Build system message and user context
      final systemMessage = _buildSystemMessage();
      final userContextMessage = _buildUserContextMessage(
        userContext: userContext,
        restaurants: restaurants,
        meals: meals,
        charities: charities,
        userQuestion: userQuestion,
      );

      // Send to AI using Groq with proper message structure
      final response = await http.post(
        Uri.parse('$_baseUrl/chat/completions'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': _model,
          'messages': [
            {'role': 'system', 'content': systemMessage},
            {'role': 'user', 'content': userContextMessage},
          ],
          'temperature': 0.7,
          'max_tokens': 2048,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'] ??
            "I couldn't generate a response. Please try again.";
      } else {
        print('API Error: ${response.statusCode} - ${response.body}');
        return "I couldn't generate a response. Please try again.";
      }
    } catch (e) {
      print('Error in askWithContext: $e');
      return "I'm having trouble accessing the information right now. Please try again later.";
    }
  }

  /// Build the system message for Nourish AI Support
  String _buildSystemMessage() {
    final buffer = StringBuffer();

    buffer.writeln(
      'You are Nourish AI Support, a friendly and knowledgeable assistant for the Nourish mobile application.',
    );
    buffer.writeln('');
    buffer.writeln('ABOUT NOURISH:');
    buffer.writeln(
      'Nourish is a food waste reduction platform that connects users with surplus food from restaurants at discounted prices.',
    );
    buffer.writeln(
      'Our mission is to reduce food waste while making quality meals accessible and supporting charitable causes.',
    );
    buffer.writeln('');
    buffer.writeln('KEY FEATURES:');
    buffer.writeln(
      '• Browse surplus meals from local restaurants at up to 70% off original prices',
    );
    buffer.writeln('• Pick up meals before they go to waste');
    buffer.writeln('• Support local charities with every purchase');
    buffer.writeln('• Save favorite restaurants for quick access');
    buffer.writeln('• Track environmental impact and meals saved');
    buffer.writeln('');
    buffer.writeln('YOUR RESPONSIBILITIES:');
    buffer.writeln(
      '• Help users find the best meal deals based on their preferences',
    );
    buffer.writeln(
      '• Answer questions about restaurants, meals, pickup times, and allergens',
    );
    buffer.writeln('• Assist with cart, orders, and payment-related questions');
    buffer.writeln('• Provide information about supported charities');
    buffer.writeln(
      '• Explain how the app works and its impact on reducing food waste',
    );
    buffer.writeln('• Be friendly, helpful, and concise in your responses');
    buffer.writeln('');
    buffer.writeln('RESPONSE GUIDELINES:');
    buffer.writeln('• Always be warm, friendly, and encouraging');
    buffer.writeln(
      '• Use the user\'s context (cart, favorites, orders) to personalize responses',
    );
    buffer.writeln(
      '• Reference specific restaurants and meals when making recommendations',
    );
    buffer.writeln('• Keep responses concise but informative');
    buffer.writeln('• Emphasize the positive impact of reducing food waste');
    buffer.writeln(
      '• If you don\'t have information, politely say so and suggest alternatives',
    );

    return buffer.toString();
  }

  /// Build user context message with all relevant data
  String _buildUserContextMessage({
    required Map<String, dynamic> userContext,
    required List<Map<String, dynamic>> restaurants,
    required List<Map<String, dynamic>> meals,
    required List<Map<String, dynamic>> charities,
    required String userQuestion,
  }) {
    final buffer = StringBuffer();

    buffer.writeln('=== CURRENT USER CONTEXT ===');

    // User cart info
    final cart = userContext['cart'] as List;
    final cartTotal = userContext['cartTotal'] as double;
    if (cart.isNotEmpty) {
      buffer.writeln(
        'User\'s Cart (${cart.length} items, \$${cartTotal.toStringAsFixed(2)} total):',
      );
      for (var item in cart) {
        buffer.writeln(
          '  - ${item['food_name']}: ${item['quantity']}x @ \$${item['food_price']}',
        );
      }
    } else {
      buffer.writeln('User\'s Cart: Empty');
    }
    buffer.writeln('');

    // Favorite restaurants
    final favoriteRestaurants = userContext['favoriteRestaurants'] as List;
    if (favoriteRestaurants.isNotEmpty) {
      buffer.writeln('Favorite Restaurants (${favoriteRestaurants.length}):');
      for (var rest in favoriteRestaurants.take(5)) {
        buffer.writeln('  - ${rest['restaurant_name']}');
      }
    }
    buffer.writeln('');

    // Supported charities
    final supportedCharities = userContext['supportedCharities'] as List;
    if (supportedCharities.isNotEmpty) {
      buffer.writeln('Supported Charities (${supportedCharities.length}):');
      for (var charity in supportedCharities) {
        buffer.writeln('  - ${charity['name']}: ${charity['description']}');
      }
    }
    buffer.writeln('');

    // Recent orders
    final orders = userContext['orders'] as List;
    if (orders.isNotEmpty) {
      buffer.writeln('Recent Orders (showing last ${orders.take(3).length}):');
      for (var order in orders.take(3)) {
        buffer.writeln('  - Order: \$${order['total'] ?? 'N/A'}');
      }
    }
    buffer.writeln('');

    // App data
    buffer.writeln('=== AVAILABLE DATA ===');

    if (restaurants.isNotEmpty) {
      buffer.writeln('Available Restaurants (${restaurants.length} total):');
      for (var rest in restaurants.take(10)) {
        buffer.writeln(
          '  - ${rest['name']}: ${rest['address']} (Rating: ${rest['rating']}/5.0)',
        );
      }
      if (restaurants.length > 10) {
        buffer.writeln('  ... and ${restaurants.length - 10} more restaurants');
      }
      buffer.writeln('');
    }

    if (meals.isNotEmpty) {
      buffer.writeln('Available Meals (${meals.length} total):');
      for (var meal in meals.take(10)) {
        final discount =
            ((meal['originalPrice'] - meal['price']) /
                    meal['originalPrice'] *
                    100)
                .toStringAsFixed(0);
        buffer.writeln(
          '  - ${meal['name']}: \$${meal['price']} (${discount}% off, ${meal['quantity']} available)',
        );
      }
      if (meals.length > 10) {
        buffer.writeln('  ... and ${meals.length - 10} more meals');
      }
      buffer.writeln('');
    }

    if (charities.isNotEmpty) {
      buffer.writeln('Supported Charities (${charities.length} total):');
      for (var charity in charities.take(5)) {
        buffer.writeln('  - ${charity['name']}: ${charity['description']}');
      }
      buffer.writeln('');
    }

    buffer.writeln('=== USER QUESTION ===');
    buffer.writeln(userQuestion);
    buffer.writeln('');
    buffer.writeln(
      'Please provide a helpful, concise, and friendly response based on the context above.',
    );
    buffer.writeln(
      'Reference specific restaurants, meals, or charities when relevant.',
    );
    buffer.writeln(
      'If the user asks about their cart, favorites, or orders, use the user context provided.',
    );

    return buffer.toString();
  }

  /// Get all data for a specific user (useful for debugging or admin panels)
  Future<Map<String, dynamic>> getAllUserData(String userId) async {
    return await _dataService.getUserContext(userId);
  }

  /// Get complete app context
  Future<Map<String, dynamic>> getCompleteContext(String userId) async {
    return await _dataService.getCompleteContext(userId: userId);
  }
}
