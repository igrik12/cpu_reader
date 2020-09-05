import 'dart:convert';

import 'package:cpu_reader/cpu_reader.dart';
import 'package:cpu_reader/cpuinfo.dart';
import 'package:cpu_reader/minMaxFreq.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const MethodChannel channel = MethodChannel('cpu_reader');

  const int coreNumber = 2;
  const int numberOfCores = 8;
  const String abi = 'arm-84';
  final CpuInfo cpuInfo = CpuInfo()
    ..abi = abi
    ..numberOfCores = numberOfCores
    ..currentFrequencies = {0: 1000, 1: 1000, 2: 3000}
    ..minMaxFrequencies = {
      0: MinMaxFrequency(300, 1000),
      1: MinMaxFrequency(600, 2700)
    };

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      switch (methodCall.method) {
        case "getAbi":
          return abi;
        case "getNumberOfCores":
          return numberOfCores;
        case "getCurrentFrequency":
          assert(methodCall.arguments["coreNumber"] == coreNumber);
          return 1000;
        case "getCpuInfo":
          final converted = jsonEncode(cpuInfo);
          return converted;
        default:
          return 'Not implemented';
      }
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getAbi', () async {
    expect(await CpuReader.getAbi, abi);
  });

  test('getNumberOfCores', () async {
    expect(await CpuReader.getNumberOfCores, numberOfCores);
  });

  test('getCurrentFrequency', () async {
    expect(await CpuReader.getCurrentFrequency(coreNumber), 1000);
  });

  test('getCpuInfo', () async {
    expect((await CpuReader.cpuInfo).abi, cpuInfo.abi);
    expect((await CpuReader.cpuInfo).currentFrequencies,
        cpuInfo.currentFrequencies);
    expect((await CpuReader.cpuInfo).numberOfCores, cpuInfo.numberOfCores);
    expect((await CpuReader.cpuInfo).minMaxFrequencies.length,
        cpuInfo.minMaxFrequencies.length);
  });
}
