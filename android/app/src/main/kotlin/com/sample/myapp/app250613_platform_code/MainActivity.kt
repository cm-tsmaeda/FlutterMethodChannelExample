package com.sample.myapp.app250613_platform_code

import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.content.Context
import android.content.ContextWrapper
import android.content.Intent
import android.content.IntentFilter
import android.os.BatteryManager
import android.os.Build.VERSION
import android.os.Build.VERSION_CODES
import android.widget.Toast

class MainActivity : FlutterActivity() {
    private val BATTERY_CHANNEL = "samples.flutter.dev/battery"
    private val ADDITION_CHANNEL = "samples.flutter.dev/addition"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, BATTERY_CHANNEL).setMethodCallHandler {
            call, result ->
            if (call.method == "getBatteryLevel") {
                val batteryLevel = getBatteryLevel()

                if (batteryLevel != -1) {
                    result.success(batteryLevel)
                } else {
                    result.error("UNAVAILABLE", "Battery level not available.", null)
                }
            } else {
                result.notImplemented()
            }
        }
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, ADDITION_CHANNEL).setMethodCallHandler {
                call, result ->
            if (call.method == "add") {
                add(flutterEngine)
                result.success(true)
            } else {
                result.notImplemented()
            }
        }
    }

    private fun getBatteryLevel(): Int {
        val batteryLevel: Int
        if (VERSION.SDK_INT >= VERSION_CODES.LOLLIPOP) {
            val batteryManager = getSystemService(Context.BATTERY_SERVICE) as BatteryManager
            batteryLevel = batteryManager.getIntProperty(BatteryManager.BATTERY_PROPERTY_CAPACITY)
        } else {
            val intent = ContextWrapper(applicationContext).registerReceiver(null, IntentFilter(Intent.ACTION_BATTERY_CHANGED))
            batteryLevel = intent!!.getIntExtra(BatteryManager.EXTRA_LEVEL, -1) * 100 / intent.getIntExtra(BatteryManager.EXTRA_SCALE, -1)
        }

        return batteryLevel
    }

    private fun add(@NonNull flutterEngine: FlutterEngine) {
        val channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, ADDITION_CHANNEL)
        val num1: Int = 35
        val num2: Int = 8
        channel.invokeMethod("add", intArrayOf(num1, num2), object : MethodChannel.Result {
            override fun success(result: Any?) {
                if (result != null) {
                    val text = "result: $num1 + $num2 = $result"
                    showToast(text)
                }
            }

            override fun error(errorCode: String, errorMessage: String?, errorDetails: Any?) {
                // Handle error if needed
            }

            override fun notImplemented() {
                // Handle not implemented if needed
            }
        })
    }

    private fun showToast(text: String) {
        Toast.makeText(this, text, Toast.LENGTH_LONG).show()
    }
}
