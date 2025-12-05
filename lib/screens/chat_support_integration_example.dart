// EXAMPLE: How to integrate the Chat Support Screen into your app
// Add this code to your existing navigation/routing system

// Option 1: Navigate from a button or menu item
// Example in your home screen or settings screen:
/*
ElevatedButton(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ChatSupportScreen(),
      ),
    );
  },
  child: const Text('Chat Support'),
),
*/

// Option 2: Add to your app drawer
/*
ListTile(
  leading: const Icon(Icons.support_agent),
  title: const Text('Chat Support'),
  onTap: () {
    Navigator.pop(context); // Close drawer
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ChatSupportScreen(),
      ),
    );
  },
),
*/

// Option 3: Add to your app bar as an action button
/*
AppBar(
  title: const Text('Nourish'),
  actions: [
    IconButton(
      icon: const Icon(Icons.chat_bubble_outline),
      tooltip: 'Chat Support',
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ChatSupportScreen(),
          ),
        );
      },
    ),
  ],
)
*/

// Option 4: Floating Action Button
/*
floatingActionButton: FloatingActionButton(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ChatSupportScreen(),
      ),
    );
  },
  child: const Icon(Icons.chat),
  tooltip: 'Chat Support',
),
*/

// Don't forget to import the screen:
// import 'package:proj/screens/chat_support_screen.dart';
