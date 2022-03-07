import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_native_helper/flutter_native_helper.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      platformVersion =
          await FlutterNativeHelper.instance.platformVersion ?? 'Unknown platform version';
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Running on: $_platformVersion\n'),
              _buildButton("控制手机震动", () async {
                FlutterNativeHelper.instance.callPhoneToShake();
              }),
              _buildButton("下载并安装apk", () async {
                await FlutterNativeHelper.instance.downloadAndInstallApk(
                    fileUrl: "https://hipos.oss-cn-shanghai.aliyuncs.com/hipos-kds-v.5.10.031-g.apk",
                    fileDirectory: "updateApk",
                    fileName: "newApk.apk");
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildButton(String text, Function function) {
    return MaterialButton(
      color: Colors.blue,
      child: Text(text, style: const TextStyle(color: Colors.white),),
      onPressed: () {
        function();
      },
    );
  }

}
