package com.nolumia.rewardpoints

import android.content.ContentValues
import android.os.Build
import android.os.Environment
import android.provider.MediaStore
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.IOException

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL_NAME)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "saveJsonToDownloads" -> {
                        val fileName = call.argument<String>("fileName")
                        val bytes = call.argument<ByteArray>("bytes")

                        if (fileName.isNullOrBlank() || bytes == null) {
                            result.error(
                                "invalid_args",
                                "fileName and bytes are required.",
                                null,
                            )
                            return@setMethodCallHandler
                        }

                        try {
                            val uri = saveBytesToPublicDownloads(
                                fileName = fileName,
                                bytes = bytes,
                                mimeType = "application/json",
                            )
                            result.success(uri.toString())
                        } catch (e: Exception) {
                            result.error("save_failed", e.message, null)
                        }
                    }

                    else -> result.notImplemented()
                }
            }
    }

    private fun saveBytesToPublicDownloads(
        fileName: String,
        bytes: ByteArray,
        mimeType: String,
    ) = contentResolver.run {
        val values = ContentValues().apply {
            put(MediaStore.Downloads.DISPLAY_NAME, fileName)
            put(MediaStore.Downloads.MIME_TYPE, mimeType)
            put(MediaStore.Downloads.RELATIVE_PATH, Environment.DIRECTORY_DOWNLOADS)
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                put(MediaStore.Downloads.IS_PENDING, 1)
            }
        }

        val uri = insert(MediaStore.Downloads.EXTERNAL_CONTENT_URI, values)
            ?: throw IOException("Failed to create MediaStore record.")

        try {
            openOutputStream(uri)?.use { output ->
                output.write(bytes)
            } ?: throw IOException("Failed to open output stream.")

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                val completed = ContentValues().apply {
                    put(MediaStore.Downloads.IS_PENDING, 0)
                }
                update(uri, completed, null, null)
            }

            uri
        } catch (e: Exception) {
            delete(uri, null, null)
            throw e
        }
    }

    companion object {
        private const val CHANNEL_NAME = "rewardpoints/export_file"
    }
}
