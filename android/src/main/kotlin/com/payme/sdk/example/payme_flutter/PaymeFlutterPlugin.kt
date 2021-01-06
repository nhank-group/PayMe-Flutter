package com.payme.sdk.example.payme_flutter

import android.app.Activity
import android.content.Context
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
import vn.payme.sdk.model.Action
import vn.payme.sdk.model.Env
import java.sql.Timestamp
import java.util.*
import kotlin.collections.ArrayList


/** PaymeFlutterPlugin */
class PaymeFlutterPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private lateinit var channel: MethodChannel
    private lateinit var payme: PayME

    private lateinit var context: Context
    private lateinit var activity: Activity

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "payme_flutter")
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

              whenAllNotNull(appId,colors,publicKey){
                  var _env = Env.PRODUCTION
                  if (env == "TEST") {
                      _env = Env.TEST
                  } else if (env == "SANDBOX") {
                      _env = Env.SANDBOX
                  }
                  this.payme = PayME(context, appId!!, publicKey!!, connectToken!!, appPrivateKey!!, colors?.toArray() as Array<String>, _env)
              }


          }

            "generate_token" -> {
                java.util.Calendar.getInstance()
                val userId = call.argument<String>("user_id")
                val key = call.argument<String>("key")
                val phone = call.argument<String>("phone")
                val connectToken: String? = CryptoAES.encrypt("{ \"timestamp\": \"${Timestamp(System.currentTimeMillis())}\", \"userId\" : \"${userId}\", \"phone\" : \"${phone}\"}", key)
            }

          "open_wallet" -> {
            payme?.let {
              payme.openWallet(Action.OPEN, null, null, null,
                      onSuccess = { json: JSONObject ->
                        println("onSuccess$json")
                      },
                      onError = { message: String ->
                        println("onError$message")
                      })
            }
          }
        }
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity;
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
fun <T: Any, R: Any> whenAllNotNull(vararg options: T?, block: (List<T>)->R) {
    if (options.all { it != null }) {
        block(options.filterNotNull()) // or do unsafe cast to non null collection
    }
}