import 'package:flutter/material.dart';

import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tbs_static/tbs_static.dart';
import 'package:tbs_static_example/X5WebViewPage.dart';
import 'package:tbs_static_example/web_view_flutter_page.dart';

const String TAG = "Xiong -- X5WebViewActivity";
void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

const String testUrl = "https://ykt.eduyun.cn";
const String debugUrl = "http://debugtbs.qq.com";
class _MyAppState extends State<MyApp> {

  @override
  void initState() {
    super.initState();
    loadX5();
  }



  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home:Builder(builder: buildScoffold),
    );
  }

  Widget buildScoffold(BuildContext context) {
    return   Scaffold(
      appBar: AppBar(
        title: const Text('Plugin example app'),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            new MaterialButton(
              color: Colors.blue,
              textColor: Colors.white,
              child: new Text('跳转到原生X5WebView'),
              onPressed: () async {
                try {
                  //跳转到native方式的使用了Tba浏览器的WebViewActivity
                  await TbsStatic.openWebActivity(testUrl, title: "TestPage",landspace:false );
                } on PlatformException {

                }
              },
            ),

            new MaterialButton(
              color: Colors.blue,
              textColor: Colors.white,
              child: new Text('跳转到X5WebViewWidget'),
              onPressed: () async {
                Navigator.push(context, MaterialPageRoute(builder: (_) {
                  return new X5WebViewPage(url: testUrl,);
                }));
              },
            ),

            new MaterialButton(
              color: Colors.blue,
              textColor: Colors.white,
              child: new Text('跳转到Google Webview'),
              onPressed: () async {
                Navigator.push(context, MaterialPageRoute(builder: (_) {
                  return new WebViewFlutterPage(url: testUrl,);
                }));
              },
            ),
          //   Text(
          //       "内核状态：\n${crashInfo == null ? "未加载" : isLoadOk ? "加载成功---\n" + crashInfo.toString() : "加载失败---\n" + crashInfo.toString()}"),
          ],
        ),

      ),
    );
  }

  // var isLoad = false;
  void loadX5() async {
    // if (isLoad) {
    //   showMsg("你已经加载过x5内核了,如果需要重新加载，请重启");
    //   return;
    // }

    //请求动态权限，6.0安卓及以上必有
    Map<Permission, PermissionStatus> statuses = await [
      Permission.phone,
      Permission.storage,
    ].request();
    //判断权限
    if (!(statuses[Permission.phone]!.isGranted &&
        statuses[Permission.storage]!.isGranted)) {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              content: Text("请同意所有权限后再尝试加载X5"),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text("取消")),
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      loadX5();
                    },
                    child: Text("再次加载")),
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      openAppSettings();
                    },
                    child: Text("打开设置页面")),
              ],
            );
          });
      return;
    }

    var x5Load = await TbsStatic.preinstallStaticTbs();
    print(x5Load ? "X5内核成功加载" : "X5内核加载失败");
    // var x5CrashInfo = await TbsStatic.getCrashInfo();
    // print("$TAG, $x5CrashInfo");
    // if (x5Load) {
    //   x5CrashInfo =
    //       "tbs_core_version" + x5CrashInfo.split("tbs_core_version")[1];
    // }
    // print("$TAG, x5Info = $x5CrashInfo");

    // isLoad = true;
  }

  void showMsg(String msg) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: Text(msg),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text("我知道了"))
            ],
          );
        });
  }

}
