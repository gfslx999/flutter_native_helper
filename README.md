# flutter_native_helper

向Flutter端提供原生Android功能，包括：

* 应用内升级
* 获取系统铃声/通知/警报列表
* 播放、暂停铃声/通知/警报

[English document](https://github.com/gfslx999/flutter_native_helper/blob/master/example/README.md)

[效果在这里](https://github.com/gfslx999/flutter_native_helper/blob/master/example/PREVIEW.md)

## 当前插件已经停止对应用内升级相关功能的更新，请移步到：[easy_app_installer](https://pub.flutter-io.cn/packages/easy_app_installer)

## 安装

在 pubspec.yaml 内.

latestVersion: [latestVersion](https://pub.flutter-io.cn/packages/flutter_native_helper/install)

```kotlin
dependencies:
  flutter_native_helper: ^$latestVersion
```

## 导入

在你要使用的类中.

```kotlin
import 'package:flutter_native_helper/flutter_native_helper.dart';
```

## 配置

### 1.在 `android - build.gradle`，找到: 
```kotlin

ext.kotlin_version = '1.3.10'

```
或
```kotlin

classpath "org.jetbrains.kotlin:kotlin-gradle-plugin:1.3.10"

```
将`1.3.10`修改为`1.5.20`

## 使用

### 一、 应用内升级

在之前，想要完成当前应用内升级，在Flutter端是不太便捷的事情，但现在，它将改变- 你只需要一行代码，即可完成应用内升级(无需关注权限问题)

为了兼容Android 7.0及以上，**需要配置FileProvider**.

在 `android - app - src - main - res` 下，新建 `xml` 文件夹，
随后在 `xml` 内新建 `file_provider_path.xml` 文件，内容如下: 

```kotlin

<?xml version="1.0" encoding="utf-8"?>
<paths>
    <root-path name="root" path="."/>
    
    <files-path
    name="files"
    path="."/>
    
    <cache-path
    name="cache"
    path="."/>
    
    <external-path
    name="external"
    path="."/>
    
    <external-cache-path
    name="external_cache"
    path="."/>
    
    <external-files-path
    name="external_file"
    path="."/>
</paths>

```
最后，打开 `android - app - src - main - AndroidManifest.xml` 文件，
在 `application` 标签下添加：

```kotlin

<provider
    android:authorities="${applicationId}.fileprovider"
    android:exported="false"
    android:grantUriPermissions="true"
    android:name="androidx.core.content.FileProvider">
        <meta-data
            android:name="android.support.FILE_PROVIDER_PATHS"
            android:resource="@xml/file_provider_path" />
</provider>

```
示例：[示例文件](https://github.com/gfslx999/flutter_native_helper/blob/master/example/android/app/src/main/AndroidManifest.xml)

#### 1. 下载并安装

```kotlin
/// 注意：该方法仅会将apk下载到沙盒目录下
/// 这个示例最终生成的文件路径就是 '/data/user/0/$applicationPackageName/files/updateApk/new.apk'
/// 如果我想指定两层目录怎么办呢，很简单，只需要将 [fileDirectory] 设置为 'updateApk/second'
/// 那么他就会生成 '/data/user/0/$applicationPackageName/files/updateApk/second/new.apk'
///
/// 如果，连续多次调用此方法，并且三个参数为完全相同的，那么 Native 端将等待第一个下载完成后才允许继续下载。
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

建议[参考](https://github.com/gfslx999/flutter_native_helper/blob/master/example/lib/main.dart)
```kotlin

///在initState中调用
FlutterNativeHelper.instance.setMethodCallHandler((call) async {
    if (call.method == FlutterNativeConstant.methodDownloadProgress) {
        if (call.argument is String) {
            final cancelTag = call.argument as String;
        }
    }
});

```

#### 3.取消下载

建议[参考](https://github.com/gfslx999/flutter_native_helper/blob/master/example/lib/main.dart)
```kotlin

/// [cancelTag] 在 'initState' 中：
/// 调用 [FlutterNativeHelper.instance.setMethodCallHandler]，'method': [FlutterNativeConstant.methodCancelTag]，
FlutterNativeHelper.instance.cancelDownload(cancelTag: "$_cancelTag");

```

#### 4.仅安装

```kotlin
/// [filePath] apk文件地址，必传
FlutterNativeHelper.instance.installApk(
    filePath: "/data/user/0/$applicationPackageName/files/updateApk/new.apk"
);
```

#### 5.打开应用市场当前详情页

简单来说，如果你有指定的应用市场，就传递 'targetMarketPackageName' 为对应的包名；
如果你没有指定的应用市场，但是想让大部分机型都打开厂商应用商店，那么就设置 'isOpenSystemMarket' 为true

```kotlin
FlutterNativeHelper.instance.openAppMarket(
    targetMarketPackageName: "$targetPackageName", //指定的应用市场包名，默认为空
    isOpenSystemMarket: true //如果未指定包名，是否要打开系统自带-应用市场，默认为true
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
final String realPath = await FlutterNativeHelper.instance.transformUriToRealPath(String? targetUri);
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
/// 
/// 如果，连续多次调用此方法，并且三个参数为完全相同的，那么 Native 端将等待第一个下载完成后才允许继续下载。
final String filePath = await FlutterNativeHelper.instance.downloadFile(fileUrl: "https://xxxx.apk",
    fileDirectory: "updateApk",
    fileName: "new.apk");
```

#### 4.进入应用设置详情页

```kotlin
final bool intoResult = await FlutterNativeHelper.instance.intoAppSettingDetail();
```

#### 5.获取设备名称

```kotlin
final String deviceName = await FlutterNativeHelper.instance.deviceName;
```
