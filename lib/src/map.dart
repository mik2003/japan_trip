import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';


class MapPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(),//title: const Text('Flutter Simple Example')),
      body: WebViewWidget(controller:
        WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setBackgroundColor(const Color(0x00000000))
          ..setNavigationDelegate(
            NavigationDelegate(
              onProgress: (int progress) {
                // Update loading bar.
              },
              onPageStarted: (String url) {},
              onPageFinished: (String url) {},
              onWebResourceError: (WebResourceError error) {},
              onNavigationRequest: (NavigationRequest request) {
                if (request.url.startsWith('https://www.youtube.com/')) {
                  return NavigationDecision.prevent;
                }
                return NavigationDecision.navigate;
              },
            ),
          )
          ..loadRequest(Uri.parse('https://www.google.com/maps/d/embed?mid=18yINesZ0_bjv9w6DCQT6PmHRiph5eRM&ehbc=2E312F&noprof=1'))
      ),
    );
  }
}
