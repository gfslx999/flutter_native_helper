# flutter_native_helper

Provides functions to the Flutter, from Android：

* App installer.
* Get system ringtone/notification/alarm list.
* Play system ringtone/notification/alarm.

[中文文档](https://github.com/gfslx999/flutter_native_helper)

[Preview GIF](https://github.com/gfslx999/flutter_native_helper/blob/master/example/PREVIEW.md)

## Installing

In pubspec.yaml.

Latest version: [Latest version](https://pub.flutter-io.cn/packages/flutter_native_helper/install)

```kotlin
dependencies:
  flutter_native_helper: ^$latestVersion
```

## Import

In the class you're going to use.

```kotlin
import 'package:flutter_native_helper/flutter_native_helper.dart';
```

## Setting

In `android - build.gradle`，find: 
```kotlin

ext.kotlin_version = '1.3.10'

```
or
```kotlin

classpath "org.jetbrains.kotlin:kotlin-gradle-plugin:1.3.10"

```

Change `1.3.10` to `1.5.20`.

## How to use

### 一、 App installer

Previously, it was not easy to perform the current in-app upgrade on the Flutter side. 
But now, this will change - you can perform the in-app upgrade with only one line of code (no permissions concerns).

Fro compatibility with Android 7.0 and above，**Need configuration FileProvider**.

In `android - app - src - main - res`, create `xml` directory，
And then, in `xml` create `file_provider_path.xml`，the file content is:

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
Last，open `android - app - src - main - AndroidManifest.xml`，
To the `application` label add：

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
example：[example file](https://github.com/gfslx999/flutter_native_helper/blob/develop_v0.1/example/android/app/src/main/AndroidManifest.xml)


#### 1. Download and install.

```kotlin
/// Attention：This method simply downloads the APK to the sandbox directory.
///
/// Take this example, it's finally path is '/data/user/0/$applicationPackageName/files/updateApk/new.apk'.
/// What if I want to specify two levels of directories, very simple, just set [fileDirectory] to 'updateApk/second'.
/// And then, it will generate '/data/user/0/$applicationPackageName/files/updateApk/second/new.apk'.
FlutterNativeHelper.instance.downloadAndInstallApk(
    fileUrl: "https://xxxx.apk",
fileDirectory: "updateApk",
fileName: "new.apk");
```

| Param name | Param sense | Is required |
| ------ | :------: | :------: |
| fileUrl | The address to download the apk | yes |
| fileDirectory | Folder path (without concatenating backslashes at the beginning and end) | yes |
| fileName | File name (no concatenation backslash required) | yes |
| isDeleteOriginalFile | Whether to delete the same file if it already exists on the local PC (default:true)) | no |

#### 2.Get download progress.

```kotlin
///In initState
///
///progress is 0~100, is double type
///Remember in dispose, call it:  'FlutterNativeHelper.instance.disposeNativeListener();'
FlutterNativeHelper.instance.setOnNativeListener(
    method: FlutterNativeConstant.methodDownloadProgress,
    result: (progress) {
        if (progress is double) {
            if (progress < 100) {
                EasyLoading.showProgress(progress / 100, status: "Downloading");
            } else {
                EasyLoading.showSuccess("Download success");
            }
        }
    }
);
```

#### 3. Only install.

```kotlin
FlutterNativeHelper.instance.installApk(
    filePath: "/data/user/0/$applicationPackageName/files/updateApk/new.apk"
);
```

### 二、SystemRingtone.

#### 1.Play system ringtone、notification.

```kotlin
/// [assignUri] If this parameter is not specified, the default ringtone is played
///
/// If the continuous play calls multiple ringtones will automatically interrupt the last one.
/// Returns whether the playback is successful.
val isSuccess = await FlutterNativeHelper.instance.playSystemRingtone(
        assignUri: assignUri);
```

#### 2.Stop play.

```kotlin
/// Returns whether the stop is successful.
val isSuccess = await FlutterNativeHelper.instance.stopSystemRingtone();
```

#### 3.Is playing.

```kotlin
val isPlaying = await FlutterNativeHelper.instance.isPlayingSystemRingtone();
 ```

#### 4.Get system ringtone/notification/alarm list.
```kotlin
final List<SystemRingtoneModel> list = await FlutterNativeHelper.instance.getSystemRingtoneList(FlutterNativeConstant.systemRingtoneTypeNotification);
 ```
| RingtoneType | Sense |
| ------ | :------: |
| FlutterNativeConstant.systemRingtoneTypeNotification | Notification |
| FlutterNativeConstant.systemRingtoneTypeAlarm | Alarm |
| FlutterNativeConstant.systemRingtoneTypeRingtone | Ringtone |
| FlutterNativeConstant.systemRingtoneTypeAll | All |

#### SystemRingtoneModel.

| Param | Sense |
| ------ | :------: |
| ringtoneTitle | Ringtone name |
| ringtoneUri | Ringtone uri |

### 三、Other API.

#### 1.Convert the Uri to a real path.

```kotlin
/// If something goes wrong，it will return: ''.
final String realPath = await FlutterNativeHelper.instance.transformUriToRealPath(String? targetUri);
```

#### 2.Call phone to shake.

```kotlin
FlutterNativeHelper.instance.callPhoneToShake();
```

| Param name | Param sense | Is required |
| ------ | :------: | :------: |
| millSeconds | Shake duration，default: 500 | no |
| amplitude | Shake amplitude in 1~255 | no |

#### 3.Download file.

```kotlin
/// And 'downloadAndInstallApk' ths same. 
/// 
/// You can use this function and 'installApk' to complete 'downloadAndInstallApk'.
/// Return：the file real path.
/// Reference: '2.Get download progress.'
final String filePath = await FlutterNativeHelper.instance.downloadFile(fileUrl: "https://xxxx.apk",
    fileDirectory: "updateApk",
    fileName: "new.apk");
```

#### 4.Go to the App Settings details page.

```kotlin
final bool intoResult = await FlutterNativeHelper.instance.intoAppSettingDetail();
```

#### 5.Get device name.

```kotlin
final String deviceName = await FlutterNativeHelper.instance.deviceName;
```
