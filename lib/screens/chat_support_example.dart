import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:proj/services/ai_service.dart';
import 'package:proj/services/data_service.dart';

/// Example chat support screen demonstrating how to use the AI service
/// with complete user and app context.
///
/// This is a DEMO/EXAMPLE file showing how to integrate the DataService
/// and AIService into your chat support feature.
class ChatSupportExample extends StatefulWidget {
  const ChatSupportExample({Key? key}) : super(key: key);

  @override
  State<ChatSupportExample> createState() => _ChatSupportExampleState();
}

class _ChatSupportExampleState extends State<ChatSupportExample> {
  final AIService _aiService = AIService();
  final DataService _dataService = DataService();
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, String>> _messages = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _messages.add({
      'sender': 'AI',
      'message':
          'Hello! I\'m your Nourish AI assistant. '
          'I can help you find meals, restaurants, and answer questions about your orders and favorites. '
          'How can I assist you today?',
    });
  }

  Future<void> _sendMessage() async {
    final userMessage = _messageController.text.trim();
    if (userMessage.isEmpty) return;

    // Get current user ID
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to use chat support')),
      );
      return;
    }

    // Add user message to chat
    setState(() {
      _messages.add({'sender': 'User', 'message': userMessage});
      _isLoading = true;
    });
    _messageController.clear();

    try {
      // Get AI response with full context
      final aiResponse = await _aiService.askWithContext(
        userId: userId,
        userQuestion: userMessage,
        includeRestaurants: true,
        includeMeals: true,
        includeCharities: true,
      );

      // Add AI response to chat
      setState(() {
        _messages.add({'sender': 'AI', 'message': aiResponse});
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _messages.add({
          'sender': 'AI',
          'message': 'Sorry, I encountered an error. Please try again.',
        });
        _isLoading = false;
      });
    }
  }

  /// Example: Debug method to see what data is available
  Future<void> _showUserContext() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    final context = await _dataService.getUserContext(userId);
    print('=== USER CONTEXT ===');
    print('Cart items: ${(context['cart'] as List).length}');
    print('Cart total: \$${context['cartTotal']}');
    print(
      'Favorite restaurants: ${(context['favoriteRestaurants'] as List).length}',
    );
    print(
      'Supported charities: ${(context['supportedCharities'] as List).length}',
    );
    print('Orders: ${(context['orders'] as List).length}');
    print('Payments: ${(context['payments'] as List).length}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Chat Support'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: _showUserContext,
            tooltip: 'Show User Context (Debug)',
          ),
        ],
      ),
      body: Column(
        children: [
          // Chat messages
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isUser = message['sender'] == 'User';

                return Align(
                  alignment: isUser
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.75,
                    ),
                    decoration: BoxDecoration(
                      color: isUser ? Colors.blue : Colors.grey[300],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      message['message']!,
                      style: TextStyle(
                        color: isUser ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Loading indicator
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ),

          // Input field
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Ask me anything...',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                  color: Colors.blue,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }
}

// ========== EXAMPLE USAGE WITHOUT UI ==========

/// Example function showing how to use the services programmatically
Future<void> exampleUsage() async {
  final aiService = AIService();
  final dataService = DataService();

  // Get current user
  final userId = FirebaseAuth.instance.currentUser!.uid;

  // Example 1: Ask a simple question with context
  final response1 = await aiService.askWithContext(
    userId: userId,
    userQuestion: "What are the best deals available right now?",
  );
  print('AI Response: $response1');

  // Example 2: Get user's cart
  final cart = await dataService.getUserCart(userId);
  print('User has ${cart.length} items in cart');

  // Example 3: Get all restaurants
  final restaurants = await dataService.getRestaurants();
  print('Found ${restaurants.length} restaurants');

  // Example 4: Get user's favorite restaurants
  final favorites = await dataService.getUserFavoriteRestaurants(userId);
  print('User has ${favorites.length} favorite restaurants');

  // Example 5: Get complete user context
  final userContext = await dataService.getUserContext(userId);
  print('Complete user context: ${userContext.keys}');

  // Example 6: Ask about specific data
  final response2 = await aiService.askWithContext(
    userId: userId,
    userQuestion: "What's in my cart and how much will it cost?",
  );
  print('AI Response: $response2');
}
