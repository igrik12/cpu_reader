import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'package:cpu_reader/cpuinfo.dart';
import 'package:cpu_reader/minMaxFreq.dart';
import 'package:flutter/services.dart';

/// This is the [CpuReader] plugin responsible for communication with (Android) platform
/// plugins using asynchronous method calls through [cpu_reader] channel.
class CpuReader {
  static const MethodChannel _channel = const MethodChannel('cpu_reader');
  static const EventChannel _stream = EventChannel('cpuReaderStream');
  static String _abi;
  static int _numberOfCores;
  static double _temperature;
  static HashMap<int, MinMaxFrequency<int>> _minMaxFrequencies =
      HashMap<int, MinMaxFrequency<int>>();

  /// [CpuInfo] stream with set [interval] value in milliseconds
  static Stream<CpuInfo> cpuStream(int interval) {
    var str = _stream
        .receiveBroadcastStream(interval)
        .map((event) => CpuInfo.fromJson(event));
    return str;
  }

  /// Gets the Android Binary Interface [getAbi] of the device
  static Future<String> getAbi() async {
    try {
      return _abi ??= await _channel.invokeMethod('getAbi');
    } on PlatformException catch (e) {
      throw 'Failed to retrieve abi ${e.code}: ${e.message}';
    }
  }

  // Gets the number of cores
  static Future<int> getNumberOfCores() async {
    try {
      return _numberOfCores ??= await _channel.invokeMethod('getNumberOfCores');
    } on PlatformException catch (e) {
      throw 'Failed to retrieve number of cores ${e.code}: ${e.message}';
    }
  }

  /// Gets the current frequency for the specified [coreNumber]
  static Future<int> getCurrentFrequency(int coreNumber) async {
    try {
      return await _channel
          .invokeMethod('getCurrentFrequency', {"coreNumber": coreNumber});
    } on PlatformException catch (e) {
      throw 'Failed to retrieve current frequency for the core ${e.code}: ${e.message}';
    }
  }

  /// Gets the current min and max frequencies for the specified [coreNumber]
  static Future<MinMaxFrequency> getMinMaxFrequencies(int coreNumber) async {
    try {
      if (_minMaxFrequencies.containsKey(coreNumber)) {
        return _minMaxFrequencies[coreNumber];
      }
      var map = Map<int, int>.from(await _channel
          .invokeMethod('getMinMaxFrequencies', {"coreNumber": coreNumber}));
      var minMax = MinMaxFrequency(map.keys.first, map.values.first);
      _minMaxFrequencies[coreNumber] = minMax;
      return minMax;
    } on PlatformException catch (e) {
      throw 'Failed to retrieve current frequency for the core ${e.code}: ${e.message}';
    }
  }

  static Future<double> getTemperature() async {
    return _temperature ??= await _channel.invokeMethod("getCpuTemperature");
  }

  static Future<CpuInfo> get cpuInfo async {
    var cpuInfo = CpuInfo()
      ..minMaxFrequencies = Map<int, MinMaxFrequency>()
      ..currentFrequencies = Map<int, int>();
    var numberOfCores = await getNumberOfCores();
    var abi = await getAbi();
    var temperature = await getTemperature();
    for (var i = 0; i < numberOfCores; i++) {
      cpuInfo.minMaxFrequencies[i] = await getMinMaxFrequencies(i);
      cpuInfo.currentFrequencies[i] = await getCurrentFrequency(i);
    }
    return cpuInfo
      ..abi = abi
      ..cpuTemperature = temperature
      ..numberOfCores = numberOfCores;
  }

  /// This retries the overall information [CpuInfo] of the device CPU.
  static Future<CpuInfo> get cpuInfo2 async {
    try {
      var cpuInfoJson = await _channel.invokeMethod('getCpuInfo');
      Map<String, dynamic> info = cpuInfoJson;
      var jsonObj = CpuInfo.fromJson(info);
      return jsonObj;
    } on PlatformException catch (e) {
      throw 'Failed to retrieve cpu info ${e.code}: ${e.message}';
    }
  }
}
