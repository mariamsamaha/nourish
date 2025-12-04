import 'package:flutter/material.dart';

class WebViewController {
  void setJavaScriptMode(dynamic mode) {}
  void setNavigationDelegate(dynamic delegate) {}
  void loadRequest(Uri uri) {}
}

class NavigationDelegate {
  NavigationDelegate({
    required Function(String) onPageStarted,
    required Function(String) onPageFinished,
    required Function(NavigationRequest) onNavigationRequest,
  });
}

class NavigationRequest {
  final String url;
  NavigationRequest({required this.url});
}

enum NavigationDecision { navigate, prevent }

enum JavaScriptMode { unrestricted, disabled }

class WebViewWidget extends StatelessWidget {
  final WebViewController controller;
  const WebViewWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return const SizedBox();
  }
}
