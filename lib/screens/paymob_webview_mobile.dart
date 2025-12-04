import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PaymobWebView extends StatefulWidget {
  final String url;
  final Function(bool) onPaymentResult;

  const PaymobWebView({
    super.key,
    required this.url,
    required this.onPaymentResult,
  });

  @override
  State<PaymobWebView> createState() => _PaymobWebViewState();
}

class _PaymobWebViewState extends State<PaymobWebView> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) {
            _checkPaymentStatus(url);
          },
          onNavigationRequest: (NavigationRequest request) {
            _checkPaymentStatus(request.url);
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  void _checkPaymentStatus(String url) {
    if (url.contains('success=true') ||
        url.contains('txn_response_code=APPROVED')) {
      widget.onPaymentResult(true);
    } else if (url.contains('success=false') ||
        url.contains('txn_response_code=DECLINED')) {
      widget.onPaymentResult(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WebViewWidget(controller: _controller);
  }
}
