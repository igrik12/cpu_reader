# cpu_reader

A basic CPU reader that provides a simple way of retrieving device CPU info (Currently only supports Android).

# Usage

Import `package:device_info/device_info.dart`,
use `CpuReader` getters to get device CPU information.

Example:

```dart
import 'package:cpu_reader/cpu_reader.dart';
import 'package:cpu_reader/cpuinfo.dart';

CpuInfo cpuInfo = await CpuReader.cpuInfo;
print('Number of Cores ${cpuInfo.numberOfCores}');

int freq = await CpuReader.getCurrentFrequency(2);
print('Core number 2 freq ${freq} Mhz');

CpuReader.cpuStream(1000).listen((cpuInfo) => print("Temperature: ${cpuInfo.cpuTemperature}"))
```
