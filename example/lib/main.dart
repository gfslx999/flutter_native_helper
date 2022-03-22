import 'dart:ffi';

import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
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

  String _cancelTag = "";

  @override
  void initState() {
    super.initState();
    initPlatformState();
    listenNativeMessage();
  }

  /// 监听 Native 端发送的信息
  void listenNativeMessage() {
    FlutterNativeHelper.instance.setMethodCallHandler((call) async {
      switch (call.method) {
        case FlutterNativeConstant.methodDownloadProgress:
          //获取下载进度
          if (call.arguments is double) {
            final progress = call.arguments as double;
            if (progress < 100) {
              String stringProgress = progress.toString();
              if (stringProgress.length > 5) {
                stringProgress = stringProgress.substring(0, 5);
              }
              EasyLoading.showProgress(progress / 100,
                  status: "下载中 $stringProgress%");
            } else {
              EasyLoading.showSuccess("下载成功");
            }
          }
          break;
        case FlutterNativeConstant.methodCancelTag:
          //得到 cancelTag
          if (call.arguments is String) {
            _cancelTag = call.arguments as String;
          }
          break;
      }
    });
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    try {
      platformVersion = await FlutterNativeHelper.instance.platformVersion ??
          'Unknown platform version';
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      builder: EasyLoading.init(),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Running on: $_platformVersion\n'),
              _buildButton("下载并安装apk", () {
                EasyLoading.show(status: "开始下载");
                FlutterNativeHelper.instance.downloadAndInstallApk(
                    fileUrl: "https://xxxxx.apk",
                    fileDirectory: "updateApk",
                    fileName: "newApk.apk");
              }),
              _buildButton("取消下载", () async {
                if (_cancelTag.isNotEmpty) {
                  await FlutterNativeHelper.instance.cancelDownload(_cancelTag);
                  EasyLoading.dismiss();
                }
              }),
              _buildButton('打开应用市场', () async {}),
              _buildButton("得到铃声列表", () async {
                final List<SystemRingtoneModel> list =
                    await FlutterNativeHelper.instance.getSystemRingtoneList(
                        FlutterNativeConstant.systemRingtoneTypeNotification);
                for (var value in list) {
                  print(
                      "lxlx ringtoneTitle: ${value.ringtoneTitle}, ${value.ringtoneUri}");
                }
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
      child: Text(
        text,
        style: const TextStyle(color: Colors.white),
      ),
      onPressed: () {
        function();
      },
    );
  }

  @override
  void dispose() {
    FlutterNativeHelper.instance.dispose();
    super.dispose();
  }
}
