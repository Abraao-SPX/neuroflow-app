package com.example.neuroflow

import android.content.ActivityNotFoundException
import android.content.Intent
import android.net.Uri
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val phoneChannel = "neuroflow/phone"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, phoneChannel).setMethodCallHandler { call, result ->
            if (call.method != "openDialer") {
                result.notImplemented()
                return@setMethodCallHandler
            }

            val number = call.argument<String>("number") ?: ""
            val intent = Intent(Intent.ACTION_DIAL).apply {
                data = Uri.parse("tel:$number")
            }

            try {
                startActivity(intent)
                result.success(null)
            } catch (error: ActivityNotFoundException) {
                result.error("NO_DIALER", error.message ?: "Nenhum aplicativo de ligação encontrado.", null)
            }
        }
    }
}
