package com.igrik.cpu_reader

import androidx.annotation.NonNull
import com.google.gson.Gson
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar

/** CpuReaderPlugin */
public class CpuReaderPlugin : FlutterPlugin, MethodCallHandler {
    // / The MethodChannel that will the communication between Flutter and native Android
    // /
    // / This local reference serves to register the plugin with the Flutter Engine and unregister it
    // / when the Flutter Engine is detached from the Activity
    private lateinit var channel: MethodChannel
    private lateinit var cpuProvider: CpuDataProvider
    private lateinit var gson: Gson

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.getFlutterEngine().getDartExecutor(), "cpu_reader")
        channel.setMethodCallHandler(this)
        cpuProvider = CpuDataProvider()
        gson = Gson()
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
    private fun getCpuInfo(): CpuInfo {
        val abi = cpuProvider.getAbi()
        val cores = cpuProvider.getNumberOfCores()
        val currentFrequencies = mutableMapOf<Int, Long>()
        val minMaxFrequencies = mutableMapOf<Int, Pair<Long, Long>>()
        for (i in 0..cores - 1) {
            currentFrequencies.put(i, cpuProvider.getCurrentFreq(i))
            minMaxFrequencies.put(i, cpuProvider.getMinMaxFreq(i))
        }

        return CpuInfo(abi = abi, numberOfCores = cores, currentFrequencies = currentFrequencies, minMaxFrequencies = minMaxFrequencies)
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
            "getCpuInfo" -> result.success(gson.toJson(getCpuInfo()))
            else -> {
                result.notImplemented()
            }
        }
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }
}
