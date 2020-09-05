package com.igrik.cpu_reader

import androidx.annotation.NonNull
import com.google.gson.Gson
import io.flutter.Log
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar
import io.reactivex.rxjava3.android.schedulers.AndroidSchedulers
import io.reactivex.rxjava3.core.Observable
import io.reactivex.rxjava3.disposables.Disposable
import io.reactivex.rxjava3.internal.jdk8.FlowableFlatMapStream.subscribe
import java.util.concurrent.TimeUnit

/** CpuReaderPlugin */
class CpuReaderPlugin : FlutterPlugin, MethodCallHandler {
    // / The MethodChannel that will act as the communication between Flutter and native Android
    // /
    // / This local reference serves to register the plugin with the Flutter Engine and unregister it
    // / when the Flutter Engine is detached from the Activity
    private lateinit var channel: MethodChannel
    private lateinit var cpuProvider: CpuDataProvider
    private lateinit var cache: HashMap<String, Any>

    @Suppress("UNCHECKED_CAST")
    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.flutterEngine.dartExecutor, "cpu_reader")
        channel.setMethodCallHandler(this)
        cpuProvider = CpuDataProvider()
        cache = hashMapOf<String, Any>()
    }

    // This static function is optional and equivalent to onAttachedToEngine. It supports the old
    // pre-Flutter-1.12 Android projects. You are encouraged to continue supporting
    // plugin registration via this function while apps migrate to use the new Android APIs
    // post-flutter-1.12 via https://flutter.dev/go/android-project-migration.
    //
    // It is encouraged to share logic between onAttachedToEngine and registerWith to keep
    // them functionally equivalent. Only one of onAttachedToEngine or registerWith will be called
    // depending on the user's project. onAttachedToEngine or registerWith must both be defined
    // in the same class.
    companion object {
        @JvmStatic
        fun registerWith(registrar: Registrar) {
            val channel = MethodChannel(registrar.messenger(), "cpu_reader")
            channel.setMethodCallHandler(CpuReaderPlugin())
        }
    }

    // This function retrieves all of the CPU information for all the cores
    // as CpuInfo object
    @Suppress("UNCHECKED_CAST")
    private fun getCpuInfo(): Map<String, Any> {
        val map = mutableMapOf<String,Any>()
        val abi = cache.getOrPut("abi") { cpuProvider.getAbi() } as String
        val cores = cache.getOrPut("cores") { cpuProvider.getNumberOfCores() }
        val minMaxFrequencies = cache.getOrPut("minMaxFrequencies") {
            val minMax = mutableMapOf<Int, Map<String, Long>>()
            for (i in 0 until cores as Int) {
                val values = cpuProvider.getMinMaxFreq(i);
                val mapOfMinMax = mapOf("min" to values.first, "max" to values.second)
                minMax[i] = mapOfMinMax
            }
            minMax
        } as MutableMap<Int, Map<String, Long>>

        val cpuTemperature = cpuProvider.getCpuTemperature()
        val currentFrequencies = mutableMapOf<Int, Long>()
        for (i in 0 until cores as Int) {
            currentFrequencies[i] = cpuProvider.getCurrentFreq(i)
        }

        map["abi"] = abi
        map["numberOfCores"] = cores
        map["minMaxFrequencies"] = minMaxFrequencies
        map["currentFrequencies"] = currentFrequencies
        map["cpuTemperature"] = cpuTemperature

        return map
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        when (call.method) {
            "getAbi" -> result.success(cpuProvider.getAbi())
            "getNumberOfCores" -> result.success(cpuProvider.getNumberOfCores())
            "getCurrentFrequency" -> {
                val coreNumber = (call.argument("coreNumber") as? Int) ?: 0
                result.success(cpuProvider.getCurrentFreq(coreNumber))
            }
            "getMinMaxFrequencies" -> {
                val coreNumber = (call.argument("coreNumber") as? Int) ?: 0
                val pair = cpuProvider.getMinMaxFreq(coreNumber)
                result.success(mapOf(pair))
            }
            "getCpuTemperature" -> result.success(cpuProvider.getCpuTemperature())
            "getCpuInfo" -> result.success(getCpuInfo())
            else -> {
                result.notImplemented()
            }
        }
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }
}
