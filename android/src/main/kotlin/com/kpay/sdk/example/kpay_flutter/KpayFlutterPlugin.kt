package com.kpay.sdk.example.kpay_flutter

import android.app.Activity
import android.content.Context
import android.util.Log
import android.view.View
import androidx.annotation.NonNull

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import org.json.JSONObject
import vn.payme.sdk.PayME
import vn.payme.sdk.enums.ERROR_CODE
import vn.payme.sdk.enums.Env
import vn.payme.sdk.enums.LANGUAGES


import java.text.DateFormat
import java.text.SimpleDateFormat
import java.util.*
import kotlin.collections.ArrayList


/** KpayFlutterPlugin */
class KpayFlutterPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private lateinit var channel: MethodChannel
    private var kpay: PayME? = null

    private lateinit var context: Context
    private lateinit var activity: Activity

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "kpay_flutter")
        channel.setMethodCallHandler(this)
        context = flutterPluginBinding.applicationContext
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        when (call.method) {
            "init" -> {
                val appId = call.argument<String>("app_id")
                val publicKey = call.argument<String>("public_key")
                val appPrivateKey = call.argument<String>("app_private_key")
                val connectToken = call.argument<String>("connect_token")
                val env = call.argument<String>("env")
                val colors = call.argument<ArrayList<String>>("colors")


                whenAllNotNull(appId, colors, publicKey) {
                    var _env = Env.PRODUCTION
                    if (env == "DEV") {
                        _env = Env.DEV
                    } else if (env == "SANDBOX") {
                        _env = Env.SANDBOX
                    }

                    this.kpay = PayME(context, appId!!, publicKey!!, connectToken!!, appPrivateKey!!, colors?.toTypedArray()!!, LANGUAGES.VN, _env, true)
                    result.success(true)
                }


            }

            "generate_token" -> {
                val tz = TimeZone.getTimeZone("UTC")
                val df: DateFormat =
                        SimpleDateFormat("yyyy-MM-dd'T'HH:mm'Z'") // Quoted "Z" to indicate UTC, no timezone offset

                df.timeZone = tz
                val nowAsISO: String = df.format(Date())

                java.util.Calendar.getInstance()
                val userId = call.argument<String>("user_id")
                val key = call.argument<String>("key")
                val phone = call.argument<String>("phone")
                val data =
                        "{\"userId\":\"${userId.toString()}\",\"timestamp\":\"${nowAsISO}\",\"phone\":\"${phone.toString()}\"}"
                Log.d("DATA", data)
                val connectToken: String? = CryptoAES.encrypt(data, key)
                result.success(connectToken)
            }

            "login" -> {
                kpay?.login(onSuccess = { jsonObject ->
                    result.success(true)
                },
                        onError = { jsonObject, code, message ->
                            result.error(code?.toString(), message, jsonObject)
                        })

            }

            "open_wallet" -> {
                kpay?.openWallet(onSuccess = { json: JSONObject? ->
                    result.success(true)
                },
                        onError = { jsonObject, code, message ->
                            PayME.showError(message)
                            if (code == ERROR_CODE.EXPIRED) {
                                kpay?.logout()
                            }
                            result.error(code?.toString(), message, jsonObject)
                        })
            }

            else -> {
                result.notImplemented()
            }
        }
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivityForConfigChanges() {
        TODO("Not yet implemented")
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        TODO("Not yet implemented")
    }

    override fun onDetachedFromActivity() {
        TODO("Not yet implemented")
    }
}

operator fun <T> List<T>.component6(): T = get(5)

inline fun <T : Any> guardLet(vararg elements: T?, closure: () -> Nothing): List<T> {
    return if (elements.all { it != null }) {
        elements.filterNotNull()
    } else {
        closure()
    }
}

inline fun <T : Any> ifLet(vararg elements: T?, closure: (List<T>) -> Unit) {
    if (elements.all { it != null }) {
        closure(elements.filterNotNull())
    }
}

fun <T : Any, R : Any> Collection<T?>.whenAnyNotNull(block: (List<T>) -> R) {
    if (this.any { it != null }) {
        block(this.filterNotNull())
    }
}

fun <T : Any, R : Any> whenAllNotNull(vararg options: T?, block: (List<T>) -> R) {
    if (options.all { it != null }) {
        block(options.filterNotNull()) // or do unsafe cast to non null collection
    }
}