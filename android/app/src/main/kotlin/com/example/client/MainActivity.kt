package com.example.client

import android.telephony.TelephonyManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "country_detector"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                if (call.method == "getSimCountry") {
                    val tm = getSystemService(TELEPHONY_SERVICE) as TelephonyManager
                    val simCountry = tm.simCountryIso?.uppercase()
                    result.success(simCountry)
                } else {
                    result.notImplemented()
                }
            }
    }
}
