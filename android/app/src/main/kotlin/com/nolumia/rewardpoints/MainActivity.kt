package com.nolumia.rewardpoints

import android.content.Intent
import android.util.Log
import androidx.core.content.FileProvider
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL_NAME,
        ).setMethodCallHandler(::handleMethodCall)
    }

    private fun handleMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            SHARE_FILE_METHOD -> shareFile(call, result)
            else -> result.notImplemented()
        }
    }

    private fun shareFile(call: MethodCall, result: MethodChannel.Result) {
        Log.d(NATIVE_SHARE_TAG, "entered shareFile")

        val path = call.argument<String>("path")
        val mimeType = call.argument<String>("mimeType")
        val chooserTitle = call.argument<String>("chooserTitle")
        val text = call.argument<String>("text")
        val subject = call.argument<String>("subject")

        Log.d(NATIVE_SHARE_TAG, "path=$path")
        Log.d(NATIVE_SHARE_TAG, "mimeType=$mimeType")
        Log.d(NATIVE_SHARE_TAG, "chooserTitle=$chooserTitle")

        if (path.isNullOrBlank() || mimeType.isNullOrBlank() || chooserTitle.isNullOrBlank()) {
            Log.e(NATIVE_SHARE_TAG, "invalid args")
            result.error("invalid_args", "path/mimeType/chooserTitle は必須です", null)
            return
        }

        val file = File(path)
        Log.d(NATIVE_SHARE_TAG, "exists=${file.exists()}")
        Log.d(NATIVE_SHARE_TAG, "length=${if (file.exists()) file.length() else -1}")
        Log.d(NATIVE_SHARE_TAG, "absolutePath=${file.absolutePath}")

        if (!file.exists()) {
            Log.e(NATIVE_SHARE_TAG, "file not found")
            result.error("file_not_found", "共有対象ファイルが存在しません: $path", null)
            return
        }

        val uri = FileProvider.getUriForFile(
            this,
            "${applicationContext.packageName}.fileprovider",
            file,
        )
        Log.d(NATIVE_SHARE_TAG, "uri=$uri")

        val intent = Intent(Intent.ACTION_SEND).apply {
            type = mimeType
            putExtra(Intent.EXTRA_STREAM, uri)
            addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)

            if (!text.isNullOrBlank()) {
                putExtra(Intent.EXTRA_TEXT, text)
            }
            if (!subject.isNullOrBlank()) {
                putExtra(Intent.EXTRA_SUBJECT, subject)
            }
        }
        Log.d(NATIVE_SHARE_TAG, "intentResolve=${intent.resolveActivity(packageManager)}")

        val chooser = Intent.createChooser(intent, chooserTitle)
        Log.d(NATIVE_SHARE_TAG, "chooserResolve=${chooser.resolveActivity(packageManager)}")
        Log.d(NATIVE_SHARE_TAG, "before startActivity")
        startActivity(chooser)
        Log.d(NATIVE_SHARE_TAG, "after startActivity")
        result.success("success")
    }

    private companion object {
        const val CHANNEL_NAME = "com.nolumia.rewardpoints/share"
        const val SHARE_FILE_METHOD = "shareFile"
        const val NATIVE_SHARE_TAG = "NativeShare"
    }
}
