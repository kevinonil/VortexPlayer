package com.vortexplayer.vortex_player

import android.app.Activity
import android.content.ComponentName
import android.content.Intent
import android.database.Cursor
import android.net.Uri
import android.provider.OpenableColumns
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity : FlutterActivity() {

    private val CHANNEL = "com.vortexplayer.vortex_player/file_picker"
    private val REQUEST_VIDEO = 1001

    private val fileManagerPackages = listOf(
        "ru.zdevs.zarchiver",
        "com.lonelycatgames.Xplore"
    )

    private var pendingResult: MethodChannel.Result? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        ).setMethodCallHandler { call, result ->

            when (call.method) {

                "getFileManagers" -> {
                    val managers = getAvailableFileManagers()
                    result.success(managers)
                }

                "pickVideo" -> {

                    if (pendingResult != null) {
                        result.error(
                            "BUSY",
                            "A picker is already open",
                            null
                        )
                        return@setMethodCallHandler
                    }

                    val packageName =
                        call.argument<String>("packageName")

                    if (packageName !in fileManagerPackages) {
                        result.error(
                            "INVALID_PACKAGE",
                            "Unsupported file manager",
                            null
                        )
                        return@setMethodCallHandler
                    }

                    pendingResult = result

                    try {
                        val intent = Intent(
                            Intent.ACTION_GET_CONTENT
                        ).apply {
                            type = "video/*"
                            addCategory(Intent.CATEGORY_OPENABLE)
                            setPackage(packageName)
                        }

                        startActivityForResult(
                            intent,
                            REQUEST_VIDEO
                        )

                    } catch (error: Exception) {
                        pendingResult?.error(
                            "OPEN_ERROR",
                            error.message,
                            null
                        )
                        pendingResult = null
                    }
                }

                else -> result.notImplemented()
            }
        }
    }

    private fun getAvailableFileManagers(): List<Map<String, String>> {

        val result = mutableListOf<Map<String, String>>()

        for (packageName in fileManagerPackages) {

            val intent = Intent(
                Intent.ACTION_GET_CONTENT
            ).apply {
                type = "video/*"
                addCategory(Intent.CATEGORY_OPENABLE)
                setPackage(packageName)
            }

            val activities = packageManager.queryIntentActivities(
                intent,
                0
            )

            if (activities.isNotEmpty()) {

                val appName = activities.first()
                    .loadLabel(packageManager)
                    .toString()

                result.add(
                    mapOf(
                        "packageName" to packageName,
                        "appName" to appName
                    )
                )
            }
        }

        return result
    }

    @Deprecated("Deprecated in Android")
    override fun onActivityResult(
        requestCode: Int,
        resultCode: Int,
        data: Intent?
    ) {
        super.onActivityResult(requestCode, resultCode, data)

        if (requestCode != REQUEST_VIDEO) return

        if (resultCode != Activity.RESULT_OK || data?.data == null) {
            pendingResult?.success(null)
            pendingResult = null
            return
        }

        try {
            val uri = data.data!!

            val fileName = getFileName(uri)

            val extension = fileName.substringAfterLast(
                ".",
                "mp4"
            ).takeIf {
                it.length in 1..8
            } ?: "mp4"

            val file = File.createTempFile(
                "vortex_video_",
                ".$extension",
                cacheDir
            )

            contentResolver.openInputStream(uri).use { input ->

                requireNotNull(input) {
                    "Cannot open selected video"
                }

                file.outputStream().use { output ->
                    input.copyTo(output)
                }
            }

            pendingResult?.success(file.absolutePath)

        } catch (error: Exception) {

            pendingResult?.error(
                "FILE_ERROR",
                error.message,
                null
            )
        }

        pendingResult = null
    }

    private fun getFileName(uri: Uri): String {

        var name = "video.mp4"

        val cursor: Cursor? = contentResolver.query(
            uri,
            null,
            null,
            null,
            null
        )

        cursor?.use {

            if (it.moveToFirst()) {

                val index = it.getColumnIndex(
                    OpenableColumns.DISPLAY_NAME
                )

                if (index >= 0) {
                    name = it.getString(index) ?: name
                }
            }
        }

        return name
    }
}
