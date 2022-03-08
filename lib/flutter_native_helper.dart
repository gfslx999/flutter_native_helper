
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
  /// [millSeconds] 震动时长，默认为500
  /// [amplitude] 震动强度 1~255之间
  Future<void> callPhoneToShake({int? millSeconds, int? amplitude}) async {
    final arguments = <String, dynamic>{
      "millSeconds": millSeconds,
      "amplitude": amplitude
    };
    await _channel.invokeMethod("callPhoneToShake", arguments);
  }

  /// 安装apk，内部已处理 '允许应用内安装其他应用' 权限
  /// [filePath] 要安装的apk绝对路径
  Future<void> installApk(String filePath) async {
    final arguments = <String, dynamic>{
      "filePath": filePath
    };
    await _channel.invokeMethod("installApk", arguments);
  }

  /// 下载文件到沙盒目录下
  /// [fileUrl] 文件远程地址
  /// [fileDirectory] 在沙盒目录下的文件夹路径
  /// 如果你想在沙盒目录下创建一个 'updateApkDirectory' ，即只需要传递 'updateApkDirectory'，native端负责拼接 '/' 斜杠，
  /// 双层文件夹就为 'updateApkDirectory/new'，无需传递首、尾斜杠
  /// [fileName] 文件名称，示例：newApk.apk(注意要拼接后缀.apk或.xxx)，无需传递 '/'
  /// [isDeleteOriginalFile] 如果本地存在相同文件，是否删除已存在文件，默认为true
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

  ///注释详见 [downloadFile]
  Future<void> downloadAndInstallApk({
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
    await _channel.invokeMethod("downloadAndInstallApk", arguments) ?? "";
  }

  /// 获取系统铃声/通知/警报列表
  /// [systemRingtoneType] 铃声类型，参见[FlutterNativeConstant]
  Future<List<SystemRingtoneModel>> getSystemRingtoneList(int systemRingtoneType) async {
    final arguments = <String, dynamic>{
      "systemRingtoneType": systemRingtoneType
    };
    try {
      final result = await _channel.invokeMethod("getSystemRingtoneList", arguments);
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
      var arguments = <String, dynamic>{
        "assignUri": assignUri
      };
      return await _channel.invokeMethod("playSystemRingtone", arguments);
    } catch (e) {
      debugPrint("playSystemRingtone.error: $e");
      return false;
    }
  }

  /// 暂停播放系统铃声/通知/警报
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
