import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

typedef void X5WebViewCreatedCallback(X5WebViewController controller);
typedef void PageFinishedCallback();
typedef void ShowCustomViewCallback();
typedef void HideCustomViewCallback();
typedef void ProgressChangedCallback(int progress);
typedef void MessageReceived(String name, String data);

class X5WebView extends StatefulWidget {
  final url;
  final X5WebViewCreatedCallback? onWebViewCreated;
  final PageFinishedCallback? onPageFinished;
  final ShowCustomViewCallback? onShowCustomView;
  final HideCustomViewCallback? onHideCustomView;
  final ProgressChangedCallback? onProgressChanged;
  final bool javaScriptEnabled;
  final JavascriptChannels? javascriptChannels;

  const X5WebView(
      {Key? key,
      this.url,
      this.javaScriptEnabled = false,
      this.onWebViewCreated,
      this.onPageFinished,
      this.onShowCustomView,
      this.onHideCustomView,
      this.javascriptChannels,
      this.onProgressChanged})
      : super(key: key);

  @override
  _X5WebViewState createState() => _X5WebViewState();
}

class _X5WebViewState extends State<X5WebView> {
  @override
  Widget build(BuildContext context) {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return AndroidView(
        //在这里对应上native中的AndroidView
        viewType: 'com.tbs_static/x5WebView',
        onPlatformViewCreated: _onPlatformViewCreated,
        creationParamsCodec: const StandardMessageCodec(),
        creationParams: _CreationParams.fromWidget(widget).toMap(),
        layoutDirection: TextDirection.rtl,
      );
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      //TODO 添加ios WebView
      return Container();
    } else {
      return Container();
    }
  }

  void _onPlatformViewCreated(int id) {
    if (widget.onWebViewCreated != null) {
      final X5WebViewController controller = X5WebViewController._(id, widget);
      widget.onWebViewCreated!(controller);
    }
  }
}

class X5WebViewController {
  X5WebView _widget;

  X5WebViewController._(
    int id,
    this._widget,
  ) : _channel = MethodChannel('com.tbs_static/x5WebView_$id') {
    _channel.setMethodCallHandler(_onMethodCall);
  }

  final MethodChannel _channel;

  Future<void> loadUrl(String url, Map<String, String>? headers) async {
    return _channel.invokeMethod('loadUrl', {
      'url': url,
      'headers': headers,
    });
  }

  Future<bool> isX5WebViewLoadSuccess() async {
    return _channel.invokeMethod('isX5WebViewLoadSuccess').then((value) => value);
  }

  Future<String> evaluateJavascript(String js) async {
    return _channel.invokeMethod('evaluateJavascript', {
      'js': js,
    }).then((value) => value);
  }


///  直接使用X5WebView(javascriptChannels:JavascriptChannels(names, (name, data) { }))
  @deprecated
  Future<void> addJavascriptChannels(
      List<String> names, MessageReceived callback) async {
    await _channel.invokeMethod("addJavascriptChannels", {'names': names});
    _channel.setMethodCallHandler((call) {
      if (call.method == "onJavascriptChannelCallBack") {
        Map arg = call.arguments;
        callback(arg["name"], arg["msg"]);
      }
      return Future.value(null);
    });
  }

  Future<void> goBackOrForward(int i) async {
    return _channel.invokeMethod('goBackOrForward', {
      'i': i,
    });
  }

  Future<bool> canGoBack() async {
    return _channel.invokeMethod('canGoBack').then((value) => value);
  }

  Future<bool> canGoForward() async {
    return _channel.invokeMethod('canGoForward').then((value) => value);
  }

  Future<void> goBack() async {
    return _channel.invokeMethod('goBack');
  }

  Future<void> goForward() async {
    return _channel.invokeMethod('goForward');
  }

  Future<void> reload() async {
    return _channel.invokeMethod('reload');
  }

  Future<String> currentUrl() async {
    return _channel.invokeMethod('currentUrl').then((value) => value);
  }

  Future _onMethodCall(MethodCall call) async {
    switch (call.method) {
      case "onPageFinished":
        if (_widget.onPageFinished != null) {
          _widget.onPageFinished!();
        }
        break;
      case "onJavascriptChannelCallBack":
        if (_widget.javascriptChannels?.callback != null) {
          Map arg = call.arguments;
          _widget.javascriptChannels!.callback(arg["name"], arg["msg"]);
        }
        break;
      case "onShowCustomView":
        if (_widget.onShowCustomView != null) {
          _widget.onShowCustomView!();
        }
        break;
      case "onHideCustomView":
        if (_widget.onHideCustomView != null) {
          _widget.onHideCustomView!();
        }
        break;
      case "onProgressChanged":
        if (_widget.onProgressChanged != null) {
          Map arg = call.arguments;
          _widget.onProgressChanged!(arg["progress"]);
        }
        break;
      default:
        throw MissingPluginException(
            '${call.method} was invoked but has no handler');
    }
  }
}

class _CreationParams {
  _CreationParams({this.url, this.javaScriptEnabled, this.javascriptChannels});

  static _CreationParams fromWidget(X5WebView widget) {
    return _CreationParams(
        url: widget.url, javaScriptEnabled: widget.javaScriptEnabled,javascriptChannels:widget.javascriptChannels?.names);
  }

  final String? url;
  final bool? javaScriptEnabled;
  final List<String>? javascriptChannels;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'url': url,
      'javaScriptEnabled': javaScriptEnabled,
      "javascriptChannels": javascriptChannels
    };
  }
}

class JavascriptChannels{
  List<String> names;
  MessageReceived callback;
  JavascriptChannels(this.names,this.callback);
}
