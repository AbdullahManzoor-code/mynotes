package com.abdullahmanzoor.mynotes

import android.app.NotificationManager
import android.content.Context
import android.content.Intent
import android.provider.Settings
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterFragmentActivity() {
    private val channelName = "com.abdullahmanzoor.mynotes/dnd"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
            .setMethodCallHandler { call, result ->
                val notificationManager =
                    getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager

                when (call.method) {
                    "checkDndPermission" -> {
                        result.success(notificationManager.isNotificationPolicyAccessGranted)
                    }
                    "openDndSettings" -> {
                        try {
                            val intent = Intent(Settings.ACTION_NOTIFICATION_POLICY_ACCESS_SETTINGS)
                            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                            startActivity(intent)
                            result.success(true)
                        } catch (e: Exception) {
                            result.error("settings_error", e.message, null)
                        }
                    }
                    "enableDnd" -> {
                        if (!notificationManager.isNotificationPolicyAccessGranted) {
                            result.error("permission_denied", "DND permission not granted", null)
                            return@setMethodCallHandler
                        }

                        val mode = call.argument<Int>("mode") ?: 1
                        try {
                            val filter = when (mode) {
                                1 -> NotificationManager.INTERRUPTION_FILTER_ALL
                                2 -> NotificationManager.INTERRUPTION_FILTER_PRIORITY
                                3 -> NotificationManager.INTERRUPTION_FILTER_NONE
                                4 -> NotificationManager.INTERRUPTION_FILTER_ALARMS
                                else -> NotificationManager.INTERRUPTION_FILTER_ALL
                            }
                            notificationManager.setInterruptionFilter(filter)
                            result.success(true)
                        } catch (e: Exception) {
                            result.error("enable_failed", e.message, null)
                        }
                    }
                    "disableDnd" -> {
                        if (!notificationManager.isNotificationPolicyAccessGranted) {
                            result.error("permission_denied", "DND permission not granted", null)
                            return@setMethodCallHandler
                        }

                        try {
                            notificationManager.setInterruptionFilter(
                                NotificationManager.INTERRUPTION_FILTER_ALL
                            )
                            result.success(true)
                        } catch (e: Exception) {
                            result.error("disable_failed", e.message, null)
                        }
                    }
                    "getDndStatus" -> {
                        if (!notificationManager.isNotificationPolicyAccessGranted) {
                            result.success(-1)
                            return@setMethodCallHandler
                        }

                        try {
                            result.success(notificationManager.currentInterruptionFilter)
                        } catch (e: Exception) {
                            result.error("status_failed", e.message, null)
                        }
                    }
                    else -> result.notImplemented()
                }
            }
    }
}