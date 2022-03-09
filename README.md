# flutter_native_helper

向Flutter端提供原生Android功能，包括：

* 下载并安装apk(一条龙服务，已处理相关权限)
* 下载文件
* 安装apk(已处理相关权限)
* 获取系统铃声/通知/警报列表
* 播放、暂停铃声/通知/警报
* 其余部分功能，可自行查看源码，有详细注释

[效果在这里](https://github.com/gfslx999/flutter_native_helper/blob/master/example/README.md)

## 一、导入

* 在pubspec.yaml内
  
  > flutter_native_helper: ^0.1

* 在要使用的地方

  > import 'package:flutter_native_helper/flutter_native_helper.dart';

## 二、特别API说明

```kotlin

/// 常量
class FlutterNativeConstant {
  ///下载进度回调 method
  static const String methodDownloadProgress = "resultDownloadProgress";

  /// 系统铃声类型-通知声
  static const int systemRingtoneTypeNotification = 2;
  /// 系统铃声类型-警报
  static const int systemRingtoneTypeAlarm = 4;
  /// 系统铃声类型-铃声
  static const int systemRingtoneTypeRingtone = 1;
  /// 系统铃声类型-全部
  static const int systemRingtoneTypeAll = 7;
}

/// 下载并安装apk
///
/// [fileUrl] 文件远程地址
/// [fileDirectory] 在沙盒目录下的文件夹路径
/// [fileName] 文件名称，示例：newApk.apk(注意要拼接后缀.apk或.xxx)，无需传递 '/'
/// [isDeleteOriginalFile] 如果本地存在相同文件，是否删除已存在文件，默认为true
///
/// 关于 [fileDirectory]、[fileName] 的说明
/// 如沙盒目录为：/data/user/0/com.xxxxx.flutter_native_helper_example/files
/// [fileDirectory] 传递的为 'updateApk' ，[fileName] 为 'new.apk'，
/// 那么最终生成的路径就是: /data/user/0/com.xxxxx.flutter_native_helper_example/files/updateApk/new.apk
/// 即你无需关心反斜杠拼接，如果 [fileDirectory] 想要为两级，那就为 'updateApk/second'，
/// 最终路径就为：/data/user/0/com.xxxxx.flutter_native_helper_example/files/updateApk/second/new.apk
///
/// 如需获取下载进度回调，调用[setOnNativeListener]，method为 [FlutterNativeConstant.methodDownloadProgress]，
/// 回调值为 'double' 类型

/// 注意⚠️：此方法没有成功回调，即不需要异步等待
FlutterNativeHelper.instance.downloadAndInstallApk({
  required String fileUrl,
  required String fileDirectory,
  required String fileName,
  bool isDeleteOriginalFile = true,
}) async {}

/// 获取系统铃声/通知/警报列表
///
/// [systemRingtoneType] 铃声类型，参见[FlutterNativeConstant]
/// SystemRingtoneModel包含：铃声标题、铃声Uri，即可使用此uri去播放
Future<List<SystemRingtoneModel>> getSystemRingtoneList(
        int systemRingtoneType,
) async {}

/// 播放系统铃声/通知/警报，如为空则播放系统默认铃声
FlutterNativeHelper.instance.playSystemRingtone({String? assignUri}) async {}

/// 暂停播放系统铃声/通知/警报
///
/// 与[playSystemRingtone]对应
FlutterNativeHelper.instance.stopSystemRingtone() async {}

```
其余API可自行查看，包含详细注释