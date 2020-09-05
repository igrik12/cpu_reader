import 'package:cpu_reader/cpu_reader.dart';
import 'package:cpu_reader/cpuinfo.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('CPU Reader'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              FutureBuilder<CpuInfo>(
                  future: CpuReader.cpuInfo,
                  builder: (context, AsyncSnapshot<CpuInfo> snapshot) =>
                      snapshot.hasData
                          ? Text(
                              'Number of cores: ${snapshot.data.numberOfCores}')
                          : Text('No data!')),
              StreamBuilder<CpuInfo>(
                  stream: CpuReader.cpuStream(1000),
                  builder: (_, AsyncSnapshot<CpuInfo> snapshot) {
                    if (snapshot.hasData) {
                      return Column(
                        children: buildFreqList(snapshot),
                      );
                    }
                    return Text('No data!');
                  }),
            ],
          ),
        ),
      ),
    );
  }

  List<Row> buildFreqList(AsyncSnapshot<CpuInfo> snapshot) {
    return snapshot.data.currentFrequencies.entries
        .map((entry) => Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [Text('CPU ${entry.key} '), Text('${entry.value}')]))
        .toList();
  }
}
