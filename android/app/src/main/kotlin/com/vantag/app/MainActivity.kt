package com.vantag.app

import android.content.ContentValues
import android.os.Build
import android.os.Environment
import android.provider.MediaStore
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileInputStream

// FlutterFragmentActivity is required for local_auth biometric authentication
class MainActivity : FlutterFragmentActivity() {
    private val CHANNEL = "com.vantag.app/file_saver"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "saveToDownloads" -> {
                    val sourcePath = call.argument<String>("sourcePath")
                    val fileName = call.argument<String>("fileName")
                    val mimeType = call.argument<String>("mimeType") ?: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
                    val subFolder = call.argument<String>("subFolder") ?: "Vantag"

                    if (sourcePath == null || fileName == null) {
                        result.error("INVALID_ARGS", "sourcePath and fileName are required", null)
                        return@setMethodCallHandler
                    }

                    try {
                        val savedPath = saveFileToDownloads(sourcePath, fileName, mimeType, subFolder)
                        if (savedPath != null) {
                            result.success(savedPath)
                        } else {
                            result.error("SAVE_FAILED", "Failed to save file to Downloads", null)
                        }
                    } catch (e: Exception) {
                        result.error("SAVE_ERROR", e.message, e.stackTraceToString())
                    }
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun saveFileToDownloads(sourcePath: String, fileName: String, mimeType: String, subFolder: String): String? {
        val sourceFile = File(sourcePath)
        if (!sourceFile.exists()) {
            return null
        }

        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            // Android 10+ - Use MediaStore API
            saveWithMediaStore(sourceFile, fileName, mimeType, subFolder)
        } else {
            // Android 9 and below - Direct file write
            saveDirectly(sourceFile, fileName, subFolder)
        }
    }

    private fun saveWithMediaStore(sourceFile: File, fileName: String, mimeType: String, subFolder: String): String? {
        val contentValues = ContentValues().apply {
            put(MediaStore.Downloads.DISPLAY_NAME, fileName)
            put(MediaStore.Downloads.MIME_TYPE, mimeType)
            put(MediaStore.Downloads.RELATIVE_PATH, "${Environment.DIRECTORY_DOWNLOADS}/$subFolder")
            put(MediaStore.Downloads.IS_PENDING, 1)
        }

        val resolver = contentResolver
        val uri = resolver.insert(MediaStore.Downloads.EXTERNAL_CONTENT_URI, contentValues)
            ?: return null

        try {
            resolver.openOutputStream(uri)?.use { outputStream ->
                FileInputStream(sourceFile).use { inputStream ->
                    inputStream.copyTo(outputStream)
                }
            }

            // Mark as complete
            contentValues.clear()
            contentValues.put(MediaStore.Downloads.IS_PENDING, 0)
            resolver.update(uri, contentValues, null, null)

            return "${Environment.DIRECTORY_DOWNLOADS}/$subFolder/$fileName"
        } catch (e: Exception) {
            // Delete the entry if save failed
            resolver.delete(uri, null, null)
            throw e
        }
    }

    private fun saveDirectly(sourceFile: File, fileName: String, subFolder: String): String? {
        val downloadsDir = Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOWNLOADS)
        val vantagDir = File(downloadsDir, subFolder)

        if (!vantagDir.exists()) {
            vantagDir.mkdirs()
        }

        val destFile = File(vantagDir, fileName)
        sourceFile.copyTo(destFile, overwrite = true)

        return destFile.absolutePath
    }
}
