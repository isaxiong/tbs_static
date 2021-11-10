import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tbs_static/tbs_static.dart';

import 'package:tbs_static/x5_webview.dart';


class X5WebViewPage extends StatefulWidget {

  final String x5DebugUrl = "http://debugtbs.qq.com";
  final String? url;
  X5WebViewPage({this.url});

  @override
  _X5WebViewState createState() => _X5WebViewState();
}

class _X5WebViewState extends State<X5WebViewPage> {
  late X5WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _loadX5();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _loadX5() async {
    //内核下载安装监听
    // await TbsStatic.setX5SdkListener(X5SdkListener(onInstallFinish: (int p0) {
    //   print("X5WebViewPage 5内核安装完成 $p0 ");
    //   //showToast("视频插件安装完成，请重启应用");
    // }));

    if (TbsStatic.canUseX5) {
      print("X5内核已成功安装");
      return;
    }
    TbsStatic.preinstallStaticTbs().then((value) {
      print("X5WebViewPage 安装结果：$value");
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
          onWillPop: _onWillPop,
          child: Scaffold(
            appBar: AppBar(
              title: Text('X5WebView',),
              elevation: 0,
              //去除底部阴影
              leading: Navigator.of(context).canPop()
                  ? InkWell(
                onTap: () {
                  Navigator.of(context).maybePop();
                },
                child: SizedBox(
                  width: 60,
                  height: 44,
                  child: Icon(Icons.arrow_back),
                ),
              )
                  : null,
              //判断是否需要返回按钮
              centerTitle: true,
            ),
            body: Center(
              child: Stack(
                children: <Widget>[
                  X5WebView(
                    url: widget.url ?? widget.x5DebugUrl,
                    javaScriptEnabled: true,
                    javascriptChannels:
                        JavascriptChannels(["X5Web", "Toast"], (name, data) {
                      switch (name) {
                        case "X5Web":
                          showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: Text("获取到的字符串为："),
                                  content: Text(data),
                                );
                              });
                          break;
                        case "Toast":
                          print(data);
                          break;
                      }
                    }),
                    onWebViewCreated: (control) {
                      _controller = control;
                    },
                    onPageFinished: () async {
                      var url = await _controller.currentUrl();
                      print("webview  $url");
                    },
                    onProgressChanged: (progress) {
                      print("webview加载进度------$progress%");
                    },
                  ),
                ],
              ),
            ),
          ),
    );
  }

  Future<bool> _onWillPop() async {
    bool canGoBack = await _controller.canGoBack();
    String url = await _controller.currentUrl();
    print("当前的Url = $url");
    if (canGoBack && url != widget.url) {
        _controller.goBack();
      } else {
        Navigator.of(context).pop();
      }
    return Future.value(false);
  }
}
