class CpuInfo {
  int numberOfCores;
  String abi;
  Map<String, Map<String, int>> minMaxFrequencies =
      Map<String, Map<String, int>>();
  Map<String, int> currentFriquencies;

  CpuInfo(
      {this.numberOfCores,
      this.abi,
      this.minMaxFrequencies,
      this.currentFriquencies});

  CpuInfo.fromJson(Map<String, dynamic> json) {
    this.numberOfCores = json['numberOfCores'];
    this.abi = json['abi'];
    this.currentFriquencies = Map.from(json['currentFrequencies']);

    Map.from(json['minMaxFrequencies']).forEach((key, value) {
      this.minMaxFrequencies[key] = Map.from(value);
    });
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.abi;
    return data;
  }
}

class Pair<T, Y> {
  T first;
  Y second;

  Pair({this.first, this.second});
}
