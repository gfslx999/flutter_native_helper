
import 'dart:async';

import 'package:flutter/services.dart';

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
    return await _channel.invokeMethod("getDeviceName") ?? "";
  }

  /// 控制设备震动
  /// [millSeconds] 震动时长
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
  Future<String> downloadFile({
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
    return await _channel.invokeMethod("downloadFile", arguments) ?? "";
  }

  /// 下载文件到沙盒目录下
  /// [fileUrl] 文件远程地址
  /// [fileDirectory] 在沙盒目录下的文件夹路径
  /// 如果你想在沙盒目录下创建一个 'updateApkDirectory' ，即只需要传递 'updateApkDirectory'，native端负责拼接 '/' 斜杠，
  /// 双层文件夹就为 'updateApkDirectory/new'，无需传递首、尾斜杠
  /// [fileName] 文件名称，示例：newApk.apk(注意要拼接后缀.apk或.xxx)，无需传递 '/'
  /// [isDeleteOriginalFile] 如果本地存在相同文件，是否删除已存在文件，默认为true
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

}
