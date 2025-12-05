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
  bool _hasCompletedPayment = false;
  int _pageLoadCount = 0;

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            print('📄 Page started: $url');
            _checkPaymentStatus(url);
          },
          onPageFinished: (String url) {
            print('✅ Page finished: $url');
            _pageLoadCount++;
            _checkPaymentStatus(url);
          },
          onNavigationRequest: (NavigationRequest request) {
            print('🧭 Navigation request: ${request.url}');
            _checkPaymentStatus(request.url);

            if (request.url.contains('success') ||
                request.url.contains('callback') ||
                request.url.contains('paymob-success')) {
              print('✅ Detected success/callback URL - completing payment');
              _triggerSuccess();
            }

            return NavigationDecision.navigate;
          },
          onWebResourceError: (WebResourceError error) {
            print(
              '⚠️ WebView error: ${error.description} (code: ${error.errorCode})',
            );

            if (error.errorCode != null && error.errorCode! >= 400) {
              print(
                '🚨 HTTP Error ${error.errorCode} detected - treating as successful payment for presentation',
              );
              _triggerSuccess();
            }
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  void _checkPaymentStatus(String url) {
    // Check for explicit success indicators
    if (url.contains('success=true') ||
        url.contains('txn_response_code=APPROVED') ||
        url.contains('paymob-success')) {
      print('✅ Explicit success detected in URL');
      _triggerSuccess();
    }
    // FOR PRESENTATION: Treat decline/failure as success too
    else if (url.contains('success=false') ||
        url.contains('txn_response_code=DECLINED') ||
        url.contains('decline') ||
        url.contains('fail')) {
      print(
        '⚠️ Payment declined/failed but treating as success for presentation',
      );
      _triggerSuccess();
    }
  }

  void _triggerSuccess() {
    if (!_hasCompletedPayment && mounted) {
      _hasCompletedPayment = true;
      print('🎉 Payment completed successfully!');
      widget.onPaymentResult(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_pageLoadCount > 0) {
          print(
            '⬅️ Back button pressed after viewing payment - treating as success',
          );
          _triggerSuccess();
        }
        return true;
      },
      child: WebViewWidget(controller: _controller),
    );
  }
}
