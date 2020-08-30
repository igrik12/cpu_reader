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
          child: Center(
              child: FutureBuilder(
            future: CpuReader.cpuInfo,
            builder: (BuildContext context, AsyncSnapshot<CpuInfo> snapshot) {
              if (snapshot.connectionState == ConnectionState.done &&
                  snapshot.hasData) {
                var data = snapshot.data;
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      StreamBuilder(
                          stream: CpuReader.cpuStream(5000),
                          builder: (context, AsyncSnapshot<CpuInfo> snapshot) {
                            if (snapshot.connectionState ==
                                    ConnectionState.active &&
                                snapshot.hasData) {
                              return Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'CPU core 1 Stream frequency',
                                    style: TextStyle(color: Colors.blue),
                                  ),
                                  Text('${snapshot.data.currentFriquencies[2]}',
                                      style: TextStyle(color: Colors.blue)),
                                ],
                              );
                            }
                            return CircularProgressIndicator();
                          }),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Android Binary Interface'),
                          Text(data.abi)
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Number of Cores'),
                          Text('${data.numberOfCores}')
                        ],
                      ),
                      ...data.currentFriquencies.entries
                          .map((entry) => Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Core ${entry.key}'),
                                  Text('${entry.value} Mhz')
                                ],
                              ))
                          .toList()
                    ],
                  ),
                );
              }
              return CircularProgressIndicator();
            },
          )),
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
}
