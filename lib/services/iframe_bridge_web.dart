import 'dart:html' as html;

class IframeBridge {
  static void sendSuccess() {
    // Send message to parent window
    html.window.parent?.postMessage('success', '*');
  }
}
