# cpu_reader

A basic CPU reader that provides a simple way of retrieving device CPU info.

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
```

## Getting Started

For help getting started with Flutter, view our online [documentation](https://flutter.dev/)
For help on editing plugin code, view the [documentation](https://flutter.dev/docs/development/packages-and-plugins/using-packages#edit-code)
