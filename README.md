# flutter_native_helper

向Flutter端提供原生Android功能，包括：

* 应用内升级
* 获取系统铃声/通知/警报列表
* 播放、暂停铃声/通知/警报

[效果在这里](https://github.com/gfslx999/flutter_native_helper/blob/master/example/README.md)

## 安装

在 pubspec.yaml 内.

```kotlin
dependencies:
  flutter_native_helper: ^0.1
```

## 导入

在你要使用的类中.

```kotlin
import 'package:flutter_native_helper/flutter_native_helper.dart';
```

## 使用

### 一、 应用内升级

在之前，想要完成当前应用内升级，在Flutter端是不太便捷的事情，但现在，它将改变- 你只需要一行代码，即可完成应用内升级(无需关注权限问题)

#### 1. 下载并安装

```kotlin
/// 注意：该方法仅会将apk下载到沙盒目录下
/// 这个示例最终生成的文件路径就是 '/data/user/0/$applicationPackageName/files/updateApk/new.apk'
/// 如果我想指定两层目录怎么办呢，很简单，只需要将 [fileDirectory] 设置为 'updateApk/second'
/// 那么他就会生成 '/data/user/0/$applicationPackageName/files/updateApk/second/new.apk'
FlutterNativeHelper.instance.downloadAndInstallApk(
    fileUrl: "https://xxxx.apk",
fileDirectory: "updateApk",
fileName: "new.apk");
```

| 参数名称 | 参数意义 | 是否必传 |
| ------ | :------: | :------: |
| fileUrl | 要下载apk的url地址 | 是 |
| fileDirectory | 文件夹路径(首尾无须拼接反斜杠) | 是 |
| fileName | 文件名称(无需拼接反斜杠) | 是 |
| isDeleteOriginalFile | 如果本地已存在相同文件，是否要删除(默认为true) | 否 |

#### 2.获取下载apk进度

```kotlin
///在initState中调用
///
///progress 为 0~100, double类型
///用完之后记得在dispose中调用 'FlutterNativeHelper.instance.disposeNativeListener();'
FlutterNativeHelper.instance.setOnNativeListener(
    method: FlutterNativeConstant.methodDownloadProgress,
    result: (progress) {
        if (progress is double) {
            if (progress < 100) {
                EasyLoading.showProgress(progress / 100, status: "下载中");
            } else {
                EasyLoading.showSuccess("下载成功");
            }
        }
    }
);
```

#### 3. 仅安装

```kotlin
/// [filePath] apk文件地址，必传
FlutterNativeHelper.instance.installApk(
    filePath: "/data/user/0/$applicationPackageName/files/updateApk/new.apk"
);
```

### 二、控制手机发出通知、铃声

#### 1.播放通知、铃声

```kotlin
/// [assignUri] 指定铃声uri，如不指定，会播放系统默认铃声
///
/// 如需指定铃声，可调用[FlutterNativeHelper.instance.getSystemRingtoneList]，选择心仪的铃声
/// 如连续播放调用多个铃声则会自动中断上一个
/// 返回是否播放成功
val isSuccess = await FlutterNativeHelper.instance.playSystemRingtone(
        assignUri: assignUri);
```

#### 2.暂停播放

```kotlin
/// 返回是否暂停成功
val isSuccess = await FlutterNativeHelper.instance.stopSystemRingtone();
```

#### 3.是否正在播放

```kotlin
val isPlaying = await FlutterNativeHelper.instance.isPlayingSystemRingtone();
 ```

#### 4.获取系统通知/铃声/警报列表
```kotlin
/// 参数：systemRingtoneType，铃声类型
final List<SystemRingtoneModel> list = await FlutterNativeHelper.instance.getSystemRingtoneList(FlutterNativeConstant.systemRingtoneTypeNotification);
 ```
| 铃声类型 | 含义 |
| ------ | :------: |
| FlutterNativeConstant.systemRingtoneTypeNotification | 通知声 |
| FlutterNativeConstant.systemRingtoneTypeAlarm | 警报 |
| FlutterNativeConstant.systemRingtoneTypeRingtone | 铃声 |
| FlutterNativeConstant.systemRingtoneTypeAll | 全部 |

#### SystemRingtoneModel

| 字段 | 含义 |
| ------ | :------: |
| ringtoneTitle | 铃声名称 |
| ringtoneUri | 铃声Uri |

### 三、其他API

#### 1.将Uri转换为真实路径

```kotlin
/// 如果出现异常，将返回空字符串
final realPath = await FlutterNativeHelper.instance.transformUriToRealPath(String? targetUri);
```

#### 2.控制设备震动

```kotlin
FlutterNativeHelper.instance.callPhoneToShake();
```

| 参数名称 | 参数意义 | 是否必传 |
| ------ | :------: | :------: |
| millSeconds | 震动时长，默认为500 | 否 |
| amplitude | 震动强度 1~255之间 | 否 |

#### 3.下载文件

```kotlin
/// 该方法与 'downloadAndInstallApk' 参数一致，仅负责下载
/// 
/// 如果你想预下载apk或其他什么骚操作，可以根据此方法+installApk来完成
/// 返回：文件的真实路径
/// 如需获取下载进度，可参考 第一项第二小节
final filePath = await FlutterNativeHelper.instance.downloadFile(fileUrl: "https://xxxx.apk",
    fileDirectory: "updateApk",
    fileName: "new.apk");
```

#### 4.获取设备名称

```kotlin
final deviceName = await FlutterNativeHelper.instance.deviceName;
```
