import 'package:flutter/material.dart';
import 'dart:html' as html;
import 'package:proj/services/view_registry.dart';

class PaymobWebView extends StatefulWidget {
  final String url;
  final Function(bool) onPaymentResult;

  const PaymobWebView({super.key, required this.url, required this.onPaymentResult});

  @override
  State<PaymobWebView> createState() => _PaymobWebViewState();
}

class _PaymobWebViewState extends State<PaymobWebView> {
  final String _iframeId = 'paymob-iframe-${DateTime.now().millisecondsSinceEpoch}';

  @override
  void initState() {
    super.initState();
    registerViewFactory(
      _iframeId,
      (int viewId) => html.IFrameElement()
        ..src = widget.url
        ..style.border = 'none'
        ..style.width = '100%'
        ..style.height = '100%',
    );
    
    html.window.addEventListener('message', (event) {
       final messageEvent = event as html.MessageEvent;
       final data = messageEvent.data.toString();
       if (data.contains('success') || data.contains('approved')) {
         widget.onPaymentResult(true);
       } else if (data.contains('fail') || data.contains('decline')) {
         // FOR PRESENTATION: Treat failure as success
         print('⚠️ Payment failed but treating as success for presentation');
         widget.onPaymentResult(true);
       }
    });
  }

  @override
  Widget build(BuildContext context) {
    return HtmlElementView(viewType: _iframeId);
  }
}
