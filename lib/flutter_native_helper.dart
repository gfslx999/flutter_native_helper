library flutter_native_hlper;

export 'package:flutter_native_helper/flutter_native_constant.dart';
export 'package:flutter_native_helper/model/system_ringtone_model.dart';

import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_helper/flutter_native_constant.dart';
import 'package:flutter_native_helper/model/system_ringtone_model.dart';

class FlutterNativeHelper {
  FlutterNativeHelper.internal();

  static FlutterNativeHelper get instance => _getInstance();
  static FlutterNativeHelper? _instance;
  final MethodChannel _channel = const MethodChannel('flutter_native_helper');

  static FlutterNativeHelper _getInstance() {
    _instance ??= FlutterNativeHelper.internal();
    return _instance!;
  }

  /// 获取平台版本号
  Future<String?> get platformVersion async {
    final String? version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  /// 获取设备名称
  Future<String> get deviceName async {
    try {
      return await _channel.invokeMethod("getDeviceName") ?? "";
    } catch (e) {
      debugPrint("getDeviceName.error: $e");
      return "";
    }
  }

  /// 控制设备震动
  ///
  /// [millSeconds] 震动时长，默认为500
  /// [amplitude] 震动强度 1~255之间
  Future<void> callPhoneToShake({int? millSeconds, int? amplitude}) async {
    final arguments = <String, dynamic>{
      "millSeconds": millSeconds,
      "amplitude": amplitude
    };
    await _channel.invokeMethod("callPhoneToShake", arguments);
  }

  /// 下载并安装apk ～ 一条龙服务
  ///
  /// 注意：此方法没有成功回调，即不需要异步等待
  /// 参数注释参见 [downloadFile]
  void downloadAndInstallApk({
    required String fileUrl,
    required String fileDirectory,
    required String fileName,
    bool isDeleteOriginalFile = true,
  }) async {
    final arguments = <String, dynamic>{
      "fileUrl": fileUrl,
      "fileDirectory": fileDirectory,
      "fileName": fileName,
      "isDeleteOriginalFile": isDeleteOriginalFile,
    };
    await _channel.invokeMethod("downloadAndInstallApk", arguments);
  }

  /// 安装apk，内部已处理 '允许应用内安装其他应用' 权限
  /// [filePath] 要安装的apk绝对路径
  Future<void> installApk(String filePath) async {
    final arguments = <String, dynamic>{"filePath": filePath};
    await _channel.invokeMethod("installApk", arguments);
  }

  /// 下载文件到⚠️沙盒目录下（仅能下载到沙盒目录下）
  ///
  /// [fileUrl] 文件远程地址
  /// [fileDirectory] 在沙盒目录下的文件夹路径
  /// [fileName] 文件名称，示例：newApk.apk(注意要拼接后缀.apk或.xxx)，无需传递 '/'
  /// [isDeleteOriginalFile] 如果本地存在相同文件，是否删除已存在文件，默认为true
  ///
  /// 关于 [fileDirectory]、[fileName] 的说明
  /// 如沙盒目录为：/data/user/0/com.xxxxx.flutter_native_helper_example/files
  /// [fileDirectory] 为 'updateApk' ，[fileName] 为 'new.apk'，
  /// 那么最终生成的路径就是: /data/user/0/com.xxxxx.flutter_native_helper_example/files/updateApk/new.apk
  /// 即你无需关心反斜杠拼接，如果 [fileDirectory] 想要为两级，那就为 'updateApk/second'，
  /// 最终路径就为：/data/user/0/com.xxxxx.flutter_native_helper_example/files/updateApk/second/new.apk
  ///
  /// 如需获取下载进度回调，调用[setOnNativeListener]，method为 [FlutterNativeConstant.methodDownloadProgress]，
  /// 回调值为 'double' 类型
  Future<String> downloadFile({
    required String fileUrl,
    required String fileDirectory,
    required String fileName,
    bool isDeleteOriginalFile = true,
  }) async {
    try {
      final arguments = <String, dynamic>{
        "fileUrl": fileUrl,
        "fileDirectory": fileDirectory,
        "fileName": fileName,
        "isDeleteOriginalFile": isDeleteOriginalFile,
      };
      return await _channel.invokeMethod("downloadFile", arguments) ?? "";
    } catch (e) {
      debugPrint("downloadFile.error: $e");
      return "";
    }
  }

  /// 获取系统铃声/通知/警报列表
  ///
  /// [systemRingtoneType] 铃声类型，参见[FlutterNativeConstant]
  Future<List<SystemRingtoneModel>> getSystemRingtoneList(
      int systemRingtoneType) async {
    final arguments = <String, dynamic>{
      "systemRingtoneType": systemRingtoneType
    };
    try {
      final result =
          await _channel.invokeMethod("getSystemRingtoneList", arguments);
      List<dynamic> jsonArray = jsonDecode(result);
      return SystemRingtoneModel.fromJsonArray(jsonArray);
    } catch (e) {
      debugPrint("getSystemRingtoneList.error: $e");
      return [];
    }
  }

  /// 播放系统铃声/通知/警报，如为空则播放系统默认铃声
  Future<bool> playSystemRingtone({String? assignUri}) async {
    try {
      var arguments = <String, dynamic>{"assignUri": assignUri};
      return await _channel.invokeMethod("playSystemRingtone", arguments);
    } catch (e) {
      debugPrint("playSystemRingtone.error: $e");
      return false;
    }
  }

  /// 暂停播放系统铃声/通知/警报
  ///
  /// 与[playSystemRingtone]对应
  Future<bool> stopSystemRingtone() async {
    try {
      return await _channel.invokeMethod("stopSystemRingtone");
    } catch (e) {
      debugPrint("stopSystemRingtone.error: $e");
      return false;
    }
  }

  /// 系统铃声是否正在播放
  Future<bool> isPlayingSystemRingtone() async {
    try {
      return await _channel.invokeMethod("isPlayingSystemRingtone");
    } catch (e) {
      debugPrint("isPlayingSystemRingtone.error: $e");
      return false;
    }
  }

  /// 将 Uri 转换为真实路径
  Future<String> transformUriToRealPath(String? targetUri) async {
    if (targetUri == null || targetUri.isEmpty) {
      debugPrint("transformUriToRealPath.error: targetUri is null or empty");
      return "";
    }
    try {
      var arguments = <String, dynamic>{"targetUri": targetUri};
      return await _channel.invokeMethod("transformUriToRealPath", arguments);
    } catch (e) {
      debugPrint("transformUriToRealPath.error: $e");
      return "";
    }
  }

  /// 进入应用设置详情页
  Future<bool> intoAppSettingDetail() async {
    try {
      return await _channel.invokeMethod("intoAppSettingDetail") ?? false;
    } catch (e) {
      return false;
    }
  }

  /// 监听Native端发送的信息
  void setOnNativeListener({
    required String method,
    required Function(dynamic) result,
  }) {
    _channel.setMethodCallHandler((call) async {
      if (call.method == method && call.arguments != null) {
        result(call.arguments);
      }
    });
  }

  /// 销毁对 Native 端的监听
  void disposeNativeListener() {
    _channel.setMethodCallHandler(null);
  }
}
