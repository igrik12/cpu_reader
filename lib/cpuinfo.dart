import 'minMaxFreq.dart';

/// This class represents the overall CPU information gathered from the native
/// side.
class CpuInfo {
  int numberOfCores;
  double cpuTemperature;
  String abi;
  Map<int, MinMaxFrequency> minMaxFrequencies = Map<int, MinMaxFrequency>();
  Map<int, int> currentFrequencies = Map<int, int>();

  CpuInfo(
      {this.numberOfCores,
      this.abi,
      this.minMaxFrequencies,
      this.currentFrequencies,
      this.cpuTemperature});

  /// Deserialize the data [json] retrieved from the device through platform specific code
  CpuInfo.fromJson(Map<dynamic, dynamic> json) {
    this.numberOfCores = json['numberOfCores'];
    this.abi = json['abi'];
    this.cpuTemperature = json['cpuTemperature'];
    Map.from(json['currentFrequencies']).forEach((key, value) {
      this.currentFrequencies[key] = value;
    });

    Map.from(json['minMaxFrequencies']).forEach((key, value) {
      var map = Map.from(value);
      this.minMaxFrequencies[key] = MinMaxFrequency(map['min'], map['max']);
    });
  }

  /// Converts instance to Json format
  Map<String, dynamic> toJson() => {
        "abi": abi,
        "numberOfCores": numberOfCores,
        "cpuTemprature": cpuTemperature,
        "currentFrequencies": currentFrequencies.map(_convert),
        "minMaxFrequencies": minMaxFrequencies.map(_convert)
      };

  /// Helper function to convert Map<Y, T> => Map<String, T>
  MapEntry _convert<T>(int key, T value) {
    return MapEntry(key.toString(), value);
  }
}
