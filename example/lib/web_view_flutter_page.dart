import 'dart:io';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';


class WebViewFlutterPage extends StatefulWidget {
  final String? url;
  WebViewFlutterPage({Key? key, this.url}) : super(key: key);

  @override
  _WebViewFlutterPageState createState() => _WebViewFlutterPageState();
}

class _WebViewFlutterPageState extends State<WebViewFlutterPage> {

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) {
      WebView.platform = SurfaceAndroidWebView();
    }
  }

  @override
  Widget build(BuildContext context) {
    return WebView(initialUrl: widget.url,);
  }
}