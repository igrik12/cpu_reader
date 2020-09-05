import 'dart:async';

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
  CpuInfo _cpuInfo = CpuInfo()..currentFrequencies = Map();
  Timer _timer;
  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(Duration(milliseconds: 1000), (timer) async {
      var info = await CpuReader.cpuInfo;
      setState(() {
        _cpuInfo = info;
      });
    });
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
          child: Center(child: Text("${_cpuInfo?.currentFrequencies[1]}")),
        ),
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: FloatingActionButton(
            onPressed: () {
              setState(() {});
            },
            child: Icon(Icons.refresh),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      ),
    );
  }

  List<Widget> getFrequencies() {
    return _cpuInfo != null
        ? _cpuInfo?.currentFrequencies?.entries
            ?.map((entry) => Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Core ${entry.key}'),
                    Text('${entry.value} Mhz')
                  ],
                ))
            ?.toList()
        : [SizedBox()];
  }
}
