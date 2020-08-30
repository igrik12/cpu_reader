import 'minMaxFreq.dart';

// This class represents the overall CPU information gathered from the native
// side.
class CpuInfo {
  int numberOfCores;
  String abi;
  Map<int, MinMaxFrequency> minMaxFrequencies = Map<int, MinMaxFrequency>();
  Map<int, int> currentFriquencies = Map<int, int>();

  CpuInfo(
      {this.numberOfCores,
      this.abi,
      this.minMaxFrequencies,
      this.currentFriquencies});

  // Deserialize the data retrieved from the device through platform specific code
  CpuInfo.fromJson(Map<dynamic, dynamic> json) {
    this.numberOfCores = json['numberOfCores'];
    this.abi = json['abi'];
    Map.from(json['currentFrequencies']).forEach((key, value) {
      this.currentFriquencies[int.parse(key)] = value;
    });

    Map.from(json['minMaxFrequencies']).forEach((key, value) {
      var map = Map.from(value);
      this.minMaxFrequencies[int.parse(key)] =
          MinMaxFrequency(map['first'], map['second']);
    });
  }

  // Serialize the data to json
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['abi'] = this.abi;
    data['numberOfCores'] = this.numberOfCores;
    data['currentFrequencies'] = this.currentFriquencies;
    data['minMaxFrequencies'] = this.minMaxFrequencies;
    return data;
  }
}
