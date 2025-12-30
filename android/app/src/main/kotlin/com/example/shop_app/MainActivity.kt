package com.example.shop_app

import android.app.NotificationChannel
import android.app.NotificationManager
import android.os.Build
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterFragmentActivity() {
    private val CHANNEL = "com.example.shop_app/notification"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "createNotificationChannel") {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                    val id = call.argument<String>("id") ?: "high_importance_channel"
                    val name = call.argument<String>("name") ?: "High Importance Notifications"
                    val description = call.argument<String>("description") ?: "Important notifications"
                    val importance = NotificationManager.IMPORTANCE_HIGH
                    
                    val channel = NotificationChannel(id, name, importance).apply {
                        this.description = description
                        enableVibration(true)
                        enableLights(true)
                    }
                    
                    val notificationManager = getSystemService(NotificationManager::class.java)
                    notificationManager.createNotificationChannel(channel)
                    
                    result.success(true)
                } else {
                    result.success(false)
                }
            } else {
                result.notImplemented()
            }
        }
    }
}