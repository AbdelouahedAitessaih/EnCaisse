package com.encaisse.encaisse

import android.content.Context
import android.os.Build
import android.telephony.TelephonyManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "encaisse/device_region",
        ).setMethodCallHandler { call, result ->
            if (call.method == "getCountryCode") {
                result.success(resolveCountryCode())
            } else {
                result.notImplemented()
            }
        }
    }

    private fun resolveCountryCode(): String? {
        val telephony = getSystemService(Context.TELEPHONY_SERVICE) as? TelephonyManager
        countryOrNull(telephony?.simCountryIso)?.let { return it }
        countryOrNull(telephony?.networkCountryIso)?.let { return it }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            val locales = resources.configuration.locales
            for (i in 0 until locales.size()) {
                countryOrNull(locales[i].country)?.let { return it }
            }
        } else {
            @Suppress("DEPRECATION")
            countryOrNull(resources.configuration.locale.country)?.let { return it }
        }
        return countryOrNull(java.util.Locale.getDefault().country)
    }

    private fun countryOrNull(raw: String?): String? {
        val code = raw?.trim()?.uppercase()
        return if (code != null && code.length == 2 && code.all { it in 'A'..'Z' }) {
            code
        } else {
            null
        }
    }
}
