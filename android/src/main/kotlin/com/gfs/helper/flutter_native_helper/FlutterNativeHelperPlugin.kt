package com.gfs.helper.flutter_native_helper

import android.app.Activity
import androidx.annotation.NonNull
import androidx.lifecycle.*
import com.fs.freedom.basic.helper.DownloadHelper
import com.fs.freedom.basic.helper.SystemHelper
import com.fs.freedom.basic.listener.CommonResultListener
import com.fs.freedom.basic.util.LogUtil
import com.fs.freedom.basic.util.ToastUtil
import com.gfs.helper.flutter_native_helper.model.InstallApkModel

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
      //todo 需要添加同意权限弹窗
      //todo 解决小新Pad上同意权限后应用进程被关闭问题
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
      else -> {
        result.notImplemented()
      }
    }
  }

  /**
   * 控制手机震动
   */
  private fun callPhoneToShake(arguments: Map<*, *>?, result: Result) {
    val millSeconds = arguments?.get("millSeconds") as Long? ?: 500
    val amplitude = arguments?.get("amplitude") as Int?
    val callPhoneToShake = SystemHelper.callPhoneToShake(mActivity, millSeconds, amplitude)
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
        override fun onSuccess(file: File) {
          result.success(file.absolutePath)
        }

        override fun onError(message: String) {
          result.error("", message,"")
        }

        override fun onProgress(currentProgress: Float) {
          updateDownloadProgress(currentProgress)
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
        override fun onStart() {
          ToastUtil.showToast(mActivity, "正在下载，请稍后")
          mInstallApkModel.isIntoOpenPermissionPage = false
        }

        override fun onError(message: String) {
          if (message == SystemHelper.OPEN_INSTALL_PACKAGE_PERMISSION) {
            ToastUtil.showToast(mActivity, "请同意该权限")
            mInstallApkModel.isIntoOpenPermissionPage = true
          } else {
            result?.error("0", message, "")
          }
        }

        override fun onProgress(currentProgress: Float) {
          updateDownloadProgress(currentProgress)
        }
      }
    )
  }

  /**
   * 更新下载进度
   */
  private fun updateDownloadProgress(progress: Float) {
    //todo 待在flutter端添加监听
    ToastUtil.showToast(mActivity,"当前进度: $progress")
    mChannel.invokeMethod("updateDownloadProgress", progress)
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
        override fun onStart() {
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
