import 'dart:async';
import 'dart:convert';
import 'package:cpu_reader/cpuinfo.dart';
import 'package:flutter/services.dart';

/// This is the [CpuReader] plugin responsible for communication with (Android) platform
/// plugins using asynchronous method calls through [cpu_reader] channel.
class CpuReader {
  static const MethodChannel _channel = const MethodChannel('cpu_reader');

  // Gets the Android Binary Interface of the device
  static Future<String> get abi async {
    try {
      return await _channel.invokeMethod('getAbi');
    } on PlatformException catch (e) {
      throw 'Failed to retrieve abi ${e.code}: ${e.message}';
    }
  }

  // Gets the number of cores
  static Future<int> get numberOfCores async {
    try {
      return await _channel.invokeMethod('getNumberOfCores');
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
  static Future<Map<int, int>> getMinMaxFrequencies(int coreNumber) async {
    try {
      return Map.from(await _channel
          .invokeMethod('getMinMaxFrequencies', {"coreNumber": coreNumber}));
    } on PlatformException catch (e) {
      throw 'Failed to retrieve current frequency for the core ${e.code}: ${e.message}';
    }
  }

  /// This retries the overall information [CpuInfo] of the device CPU.
  static Future<CpuInfo> get cpuInfo async {
    try {
      final String cpuIngoJson = await _channel.invokeMethod('getCpuInfo');
      Map<String, dynamic> info = jsonDecode(cpuIngoJson);
      var jsonObj = CpuInfo.fromJson(info);
      return jsonObj;
    } on PlatformException catch (e) {
      throw 'Failed to retrieve cpu info ${e.code}: ${e.message}';
    }
  }
}
