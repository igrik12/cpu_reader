import 'dart:convert';

import 'package:cpu_reader/models/cpuinfo.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:cpu_reader/cpu_reader.dart';
import 'package:mp_chart/mp/chart/line_chart.dart';
import 'package:mp_chart/mp/controller/line_chart_controller.dart';
import 'package:mp_chart/mp/core/common_interfaces.dart';
import 'package:mp_chart/mp/core/data/line_data.dart';
import 'package:mp_chart/mp/core/data_interfaces/i_line_data_set.dart';
import 'package:mp_chart/mp/core/data_set/line_data_set.dart';
import 'package:mp_chart/mp/core/description.dart';
import 'package:mp_chart/mp/core/enums/legend_form.dart';
import 'package:mp_chart/mp/core/enums/mode.dart';
import 'package:mp_chart/mp/core/highlight/highlight.dart';
import 'package:mp_chart/mp/core/entry/entry.dart';
import 'package:mp_chart/mp/core/utils/color_utils.dart';

import 'constants.dart';

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
      home: Scaffold(
        appBar: AppBar(
          title: const Text('CPU reader'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Center(
              child: Column(
            children: [
              Expanded(
                  child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                children:
                    new List<Widget>.generate(8, (i) => CpuChart(index: i)),
              )),
            ],
          )),
        ),
      ),
    );
  }
}

class CpuChart extends StatefulWidget {
  final ChartDataUnit dataUnit;

  final int index;

  CpuChart({this.dataUnit, this.index});
  @override
  State<StatefulWidget> createState() {
    return CpuChartState();
  }
}

class CpuChartState extends State<CpuChart>
    implements OnChartValueSelectedListener {
  static const int VISIBLE_COUNT = 60;
  LineChartController controller;
  int _removalCounter = 0;

  CpuInfo _cpuInfo;
  Timer _timer;

  @override
  void dispose() {
    _timer.cancel();
    _timer = null;
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    _timer = Timer.periodic(Duration(milliseconds: 100), (timer) async {
      CpuInfo cpuInfo;
      // Platform messages may fail, so we use a try/catch PlatformException.
      try {
        var cpuInfoJson = await CpuReader.platformVersion;
        Map<String, dynamic> info = jsonDecode(cpuInfoJson);
        cpuInfo = CpuInfo.fromJson(info);
      } on PlatformException {
        cpuInfo = null;
      }

      // If the widget was removed from the tree while the asynchronous platform
      // message was in flight, we want to discard the reply rather than calling
      // setState to update our non-existent appearance.
      if (!mounted) return;
      var index = widget.index;
      addEntry(cpuInfo.currentFriquencies['$index'].toDouble());

      setState(() {
        _cpuInfo = cpuInfo;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        LineChart(controller),
      ],
    );
  }

  @override
  void initState() {
    _initController();
    initPlatformState();
    super.initState();
  }

  @override
  void onNothingSelected() {}

  @override
  void onValueSelected(Entry e, Highlight h) {}

  void addEntry(double y0) {
    //print("y: ${y0.toInt()} ${y1.toInt()}");
    LineData data = controller.data;
    if (data != null) {
      ILineDataSet set0 = data.getDataSetByIndex(0);
      addWithRemove(set0, data, y0);
      controller.setVisibleXRangeMaximum(VISIBLE_COUNT.toDouble());
      controller.moveViewToX(data.getEntryCount().toDouble());
      controller.state?.setStateIfNotDispose();
    }
  }

  void addWithRemove(ILineDataSet set0, LineData data, double y0) {
    double x = (set0.getEntryCount() + _removalCounter).toDouble();
    data.addEntry(
        Entry(
          x: x,
          y: y0,
        ),
        0);
    //remove entry which is out of visible range
    if (set0.getEntryCount() > VISIBLE_COUNT) {
      data.removeEntry2(_removalCounter.toDouble(), 0);
      _removalCounter++;
    }
  }

  void _initController() {
    // print("_initController");
    var desc = Description()..enabled = false;
    controller = LineChartController(
        legendSettingFunction: (legend, controller) {
          legend
            ..shape = LegendForm.LINE
            ..textColor = ColorUtils.BLUE
            ..enabled = false;
        },
        xAxisSettingFunction: (xAxis, controller) {
          xAxis
            ..textColor = ColorUtils.WHITE
            ..drawGridLines = false
            ..avoidFirstLastClipping = true
            ..enabled = false;
          //xAxis.drawLabels = false;
        },
        axisLeftSettingFunction: (axisLeft, controller) {
          axisLeft
            ..textColor = ColorUtils.BLUE
            ..drawGridLines = false
            ..enabled = false;
          axisLeft.setAxisMaximum(2500.0);
          axisLeft.setAxisMinimum(0.0);
          axisLeft.setDrawZeroLine(false);
        },
        axisRightSettingFunction: (axisRight, controller) {
          axisRight.enabled = false;
        },
        drawGridBackground: false,
        dragXEnabled: false,
        dragYEnabled: false,
        scaleXEnabled: true,
        scaleYEnabled: false,
        backgroundColor: Colors.lightBlue,
        selectionListener: this,
        pinchZoomEnabled: false,
        autoScaleMinMaxEnabled: false,
        minOffset: 0,
        description: desc,
        infoTextColor: kSliderColor,
        maxVisibleCount: 60,
        infoBgColor: kBackgroundColor);

    LineData data = controller?.data;

    if (data == null) {
      data = LineData();
      controller.data = data;
      if (data != null) {
        ILineDataSet set0 = data.getDataSetByIndex(0);
        if (set0 == null) {
          set0 = _createSet(0);
          data.addDataSet(set0);
          for (var nn = 0; nn < VISIBLE_COUNT; nn++) {
            addWithRemove(set0, data, 50);
            //controller.moveViewToX(data.getEntryCount().toDouble());
          }
        }
      }
    }
  }

  LineDataSet _createSet(int ix) {
    LineDataSet set = LineDataSet(null, "y$ix");
    set.setMode(Mode.CUBIC_BEZIER);
    set.setCubicIntensity(0.5);
    set.setDrawFilled(false);
    set.setDrawCircles(false);
    set.setLineWidth(1.8);
    set.setCircleRadius(4);
    set.setCircleColor(ColorUtils.WHITE);
    set.setHighLightColor(Color.fromARGB(255, 244, 117, 117));
    set.setColor1(ColorUtils.WHITE);
    set.setFillColor(ColorUtils.WHITE);
    set.setFillAlpha(100);
    set.setDrawHorizontalHighlightIndicator(false);
    return set;
  }
}

class ChartDataUnit {
  final double maxFrequency;
  final double minFrequency;
  final double currentFrequency;

  ChartDataUnit(this.maxFrequency, this.minFrequency, this.currentFrequency);
}
