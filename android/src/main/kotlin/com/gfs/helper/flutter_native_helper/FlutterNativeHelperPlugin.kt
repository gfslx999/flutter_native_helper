package com.gfs.helper.flutter_native_helper

import android.app.Activity
import android.net.Uri
import androidx.annotation.NonNull
import androidx.lifecycle.*
import com.fs.freedom.basic.helper.*
import com.fs.freedom.basic.listener.CommonResultListener
import com.fs.freedom.basic.model.SystemRingtoneModel
import com.gfs.helper.flutter_native_helper.comments.CustomLifecycleObserver
import com.gfs.helper.flutter_native_helper.comments.InstallApkState
import com.gfs.helper.flutter_native_helper.model.InstallApkModel
import com.google.gson.Gson

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.embedding.engine.plugins.lifecycle.FlutterLifecycleAdapter
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import java.io.File

/** FlutterNativeHelperPlugin */
class FlutterNativeHelperPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {

  private var mInstallApkModel = InstallApkModel()
  private lateinit var mChannel : MethodChannel
  private var mActivity: Activity? = null
  private var mLifecycle: Lifecycle? = null
  private val mLifecycleObserver = object : CustomLifecycleObserver {
    override fun onResume() {
      //校验是否获取到了权限
      if (mInstallApkModel.isIntoOpenPermissionPage) {
        when (mInstallApkModel.currentState) {
          InstallApkState.INSTALL -> {
            installApk(mInstallApkModel.arguments, mInstallApkModel.result)
          }
          InstallApkState.DOWNLOAD_AND_INSTALL -> {
            downloadAndInstallApk(mInstallApkModel.arguments, mInstallApkModel.result)
          }
          else -> {}
        }
      }
    }
  }

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    mChannel = MethodChannel(flutterPluginBinding.binaryMessenger, "flutter_native_helper")
    mChannel.setMethodCallHandler(this)
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    val arguments = call.arguments as Map<*, *>?
    when (call.method) {
      "getPlatformVersion" -> {
        result.success("Android ${android.os.Build.VERSION.RELEASE}")
      }
      "getDeviceName" -> {
        result.success(SystemHelper.deviceName)
      }
      "callPhoneToShake" -> {
        callPhoneToShake(arguments, result)
      }
      "installApk" -> {
        installApk(arguments, result)
      }
      "downloadFile" -> {
        downloadFile(arguments, result)
      }
      "downloadAndInstallApk" -> {
        downloadAndInstallApk(arguments, result)
      }
      "cancelDownload" -> {
        cancelDownload(arguments, result)
      }
      "playSystemRingtone" -> {
        playSystemRingtone(arguments, result)
      }
      "stopSystemRingtone" -> {
        stopSystemRingtone(result)
      }
      "isPlayingSystemRingtone" -> {
        isPlayingSystemRingtone(result)
      }
      "getSystemRingtoneList" -> {
        getSystemRingtoneList(arguments, result)
      }
      "transformUriToRealPath" -> {
        transformUriToRealPath(arguments, result)
      }
      "intoAppSettingDetail" -> {
        intoAppSettingDetail(result)
      }
      "openAppMarket" -> {
        openAppMarket(arguments, result)
      }
      else -> {
        result.notImplemented()
      }
    }
  }

  /**
   * 进入应用设置详情页
   */
  private fun intoAppSettingDetail(result: Result) {
    if (mActivity != null) {
      val intoResult = AppHelper.intoAppSettingDetail(mActivity!!)
      if (intoResult) {
        result.success(true)
      } else {
        result.error("intoAppSettingDetail", "into detail failed", "")
      }
    } else {
      result.error("intoAppSettingDetail", "mActivity is null, wait a moment", "")
    }
  }

  /**
   * 打开应用市场-当前应用详情页
   */
  private fun openAppMarket(arguments: Map<*, *>?, result: Result) {
    val targetMarketPackageName = arguments?.get("targetMarketPackageName") as String? ?: ""
    val isOpenSystemMarket = arguments?.get("isOpenSystemMarket") as Boolean? ?: true
    val openResult = AppHelper.openAppMarket(
      mActivity,
      targetMarketPackageName = targetMarketPackageName,
      isOpenSystemMarket = isOpenSystemMarket
    )

    if (openResult) {
      result.success(true)
    } else {
      result.error("openAppMarket", "open market failed!", "")
    }
  }

  /**
   * 将Uri转换为真实路径
   */
  private fun transformUriToRealPath(arguments: Map<*, *>?, result: Result) {
    val targetUri = arguments?.get("targetUri") as String? ?: ""
    if (targetUri.isEmpty()) {
      result.error("transformUriToRealPath", "targetUri is must not be null or empty" ,"")
      return
    }
    val realPath = FileHelper.transformUriToRealPath(mActivity, Uri.parse(targetUri))
    if (realPath.isNotEmpty()) {
      result.success(realPath)
    } else {
      result.error("transformUriToRealPath", "transform failed","")
    }
  }

  /**
   * 获取系统铃声/通知/警报
   */
  private fun getSystemRingtoneList(arguments: Map<*, *>?, result: Result) {
    val ringtoneType = arguments?.get("systemRingtoneType") as Int?
    if (ringtoneType == null) {
      result.error("getSystemRingtoneList", "ringtoneType must not be null!", "")
      return
    }
    MediaHelper.getSystemRingtoneList(mActivity, ringtoneType, object : CommonResultListener<SystemRingtoneModel> {
      override fun onSuccess(list: List<SystemRingtoneModel>) {
        result.success(Gson().toJson(list))
      }

      override fun onEmpty() {
        result.error("getSystemRingtoneList", "empty", "")
      }

      override fun onError(message: String) {
        result.error("getSystemRingtoneList", message, "")
      }
    })
  }

  /**
   * 播放系统铃声/通知/警报
   */
  private fun playSystemRingtone(arguments: Map<*, *>?, result: Result) {
    val assignUri = arguments?.get("assignUri") as String?
    val uri = if (assignUri != null && assignUri.isNotEmpty()) {
      Uri.parse(assignUri)
    } else {
      null
    }
    val playResult = MediaHelper.playSystemRingtone(mActivity, uri)
    if (playResult) {
      result.success(playResult)
    } else {
      result.error("playSystemRingtone", "play failed", "")
    }
  }

  /**
   * 停止当前正在播放的铃声/通知/警报
   * 与 [playSystemRingtone] 对应
   */
  private fun stopSystemRingtone(result: Result) {
    val stopResult = MediaHelper.stopSystemRingtone()
    result.success(stopResult)
  }

  /**
   * 当前铃声是否在播放
   */
  private fun isPlayingSystemRingtone(result: Result) {
    result.success(MediaHelper.isRingtonePlaying)
  }

  /**
   * 控制手机震动
   */
  private fun callPhoneToShake(arguments: Map<*, *>?, result: Result) {
    val millSeconds = arguments?.get("millSeconds") as Int? ?: 500
    val amplitude = arguments?.get("amplitude") as Int?
    val callPhoneToShake = SystemHelper.callPhoneToShake(mActivity, millSeconds.toLong(), amplitude)
    if (callPhoneToShake) {
      result.success(true)
    } else {
      result.error("0", "控制震动失败", "")
    }
  }

  /**
   * 下载文件
   */
  private fun downloadFile(arguments: Map<*, *>?, result: Result) {
    val fileUrl = arguments?.get("fileUrl") as String? ?: ""
    val fileDirectory = arguments?.get("fileDirectory") as String? ?: ""
    val fileName = arguments?.get("fileName") as String? ?: ""
    val isDeleteOriginalFile = arguments?.get("isDeleteOriginalFile") as Boolean? ?: true

    DownloadHelper.downloadFile(
      fileUrl = fileUrl,
      filePath = "${mActivity?.filesDir}/$fileDirectory/",
      fileName = fileName,
      isDeleteOriginalFile = isDeleteOriginalFile,
      commonResultListener = object : CommonResultListener<File> {
        override fun onStart(attachParam: Any?) {
          resultCancelTag(attachParam)
        }
        override fun onSuccess(file: File) {
          result.success(file.absolutePath)
        }

        override fun onError(message: String) {
          result.error("", message,"")
        }

        override fun onProgress(currentProgress: Float) {
          resultDownloadProgress(currentProgress)
        }
      }
    )
  }

  /**
   * 下载apk并安装
   */
  private fun downloadAndInstallApk(arguments: Map<*, *>?, result: Result?) {
    val fileUrl = arguments?.get("fileUrl") as String? ?: ""
    val fileDirectory = arguments?.get("fileDirectory") as String? ?: ""
    val fileName = arguments?.get("fileName") as String? ?: ""
    val isDeleteOriginalFile = arguments?.get("isDeleteOriginalFile") as Boolean? ?: true

    mInstallApkModel = mInstallApkModel.copyWith(
      arguments = arguments,
      result = result,
      currentState = InstallApkState.DOWNLOAD_AND_INSTALL
    )

    SystemHelper.downloadAndInstallApk(
      activity = mActivity,
      fileUrl = fileUrl,
      filePath = "${mActivity?.filesDir}/$fileDirectory/",
      fileName = fileName,
      isDeleteOriginalFile = isDeleteOriginalFile,
      commonResultListener = object :CommonResultListener<File> {
        override fun onStart(attachParam: Any?) {
          resultCancelTag(attachParam)
          mInstallApkModel.isIntoOpenPermissionPage = false
        }

        override fun onError(message: String) {
          if (message == SystemHelper.OPEN_INSTALL_PACKAGE_PERMISSION) {
            mInstallApkModel.isIntoOpenPermissionPage = true
          } else {
            result?.error("0", message, "")
          }
        }

        override fun onProgress(currentProgress: Float) {
          resultDownloadProgress(currentProgress)
        }
      }
    )
  }

  /**
   * 取消下载
   */
  private fun cancelDownload(arguments: Map<*, *>?, result: Result?) {
    val cancelTag = arguments?.get("cancelTag") as String? ?: ""
    if (cancelTag.isEmpty()) {
      result?.error("cancelDownload", "cancelTag is must not be null!", "")
      return
    }
    DownloadHelper.cancelDownload(cancelTag)
    result?.success(true)
  }

  /**
   * 安装apk
   */
  private fun installApk(arguments: Map<*, *>?, result: Result?) {
    val filePath = arguments?.get("filePath") as String? ?: ""
    if (filePath.isNotEmpty()) {
      mInstallApkModel = mInstallApkModel.copyWith(
        arguments = arguments,
        result = result,
        currentState = InstallApkState.INSTALL
      )
      SystemHelper.installApk(mActivity, apkFile = File(filePath), commonResultListener = object : CommonResultListener<File>{
        override fun onStart(attachParam: Any?) {
          mInstallApkModel.isIntoOpenPermissionPage = false
        }
        override fun onError(message: String) {
          if (message == SystemHelper.OPEN_INSTALL_PACKAGE_PERMISSION) {
            mInstallApkModel.isIntoOpenPermissionPage = true
          } else {
            result?.error("0", message, "")
          }
        }

      })
    } else {
      result?.error("0", "installApk：file path can't be empty!", "")
    }
  }

  /**
   * =============================== Android send to Flutter ===============================
   */

  /**
   * 回调下载进度
   */
  private fun resultDownloadProgress(progress: Float) {
    mChannel.invokeMethod("resultDownloadProgress", progress)
  }

  /**
   * 回调用于取消下载的 cancelTag
   */
  private fun resultCancelTag(attachParam: Any?) {
    if (attachParam is String && attachParam.isNotEmpty()) {
      mChannel.invokeMethod("resultCancelTag", attachParam)
    }
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    mChannel.setMethodCallHandler(null)
  }

  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    mActivity = binding.activity
    mLifecycle = FlutterLifecycleAdapter.getActivityLifecycle(binding)
    mLifecycle?.addObserver(mLifecycleObserver)
  }

  override fun onDetachedFromActivityForConfigChanges() {
    mActivity = null

  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    mActivity = binding.activity

  }

  override fun onDetachedFromActivity() {
    mActivity = null
    mLifecycle?.removeObserver(mLifecycleObserver)
    mLifecycle = null
  }
}
