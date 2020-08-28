import 'minMaxFreq.dart';

// This class represents the overall CPU information gathered from the native
// side.
class CpuInfo {
  int numberOfCores;
  String abi;
  Map<String, MinMaxFrequency> minMaxFrequencies =
      Map<String, MinMaxFrequency>();
  Map<String, int> currentFriquencies;

  CpuInfo(
      {this.numberOfCores,
      this.abi,
      this.minMaxFrequencies,
      this.currentFriquencies});

  // Deserialize the data retrieved from the device through platform specific code
  CpuInfo.fromJson(Map<String, dynamic> json) {
    this.numberOfCores = json['numberOfCores'];
    this.abi = json['abi'];
    this.currentFriquencies = Map.from(json['currentFrequencies']);

    Map.from(json['minMaxFrequencies']).forEach((key, value) {
      var map = Map.from(value);
      this.minMaxFrequencies[key] =
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
