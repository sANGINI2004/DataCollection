import 'dart:async';

import 'dart:io';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:flutter/material.dart';
import 'globals.dart' as globals;

class EGraphs extends StatefulWidget {
  const EGraphs({Key? key}) : super(key: key);

  @override
  State<EGraphs> createState() => _EGraphsState();
}

class _EGraphsState extends State<EGraphs> {
  @override
  Widget build(BuildContext context) {
    // print(globals.datalist);
    // print(globals.etimes );

    return Scaffold(
        appBar: AppBar(
          title: const Text('Graphs'),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              StreamBuilder<List<dynamic>>(
                stream: globals.EdatalistStream,
                builder: (context, snapshot) {
                  // globals.datalistesense.add('2');
                  // print(globals.datalistesense.toString());
                  // globals.EupdateDatalist(['x']);
                  if (snapshot.hasData && snapshot.data!.length >= 2) {
                    final List<dynamic> updatedData = snapshot.data!;
                    print("hehehehe");

                    print(updatedData);
                    // print(updatedData);
                    // print(globals.etimes );
                    // List<_SensorData> data = [];
                    // for (var i = 0; i < updatedData.length; i++) {
                    //   data.add(_SensorData(
                    //       (globals.etimes [i] - globals.etimes [0]).toString(),
                    //       updatedData[i][0],
                    //       updatedData[i][1],
                    //       updatedData[i][2]));
                    // }

                    // List<_SensorData> data1 = [];
                    // for (var i = 0; i < updatedData.length; i++) {
                    //   data1.add(_SensorData(
                    //       (globals.etimes [i] - globals.etimes [0]).toString(),
                    //       updatedData[i][3],
                    //       updatedData[i][4],
                    //       updatedData[i][5]));
                    // }

                    List<_SensorData> data = [
                      _SensorData(
                          (globals.etimes[globals.etimes.length - 5] -
                                  globals.etimes[0])
                              .toString(),
                          updatedData[updatedData.length - 5][1],
                          updatedData[updatedData.length - 5][2],
                          updatedData[updatedData.length - 5][3]),
                      _SensorData(
                          (globals.etimes[globals.etimes.length - 4] -
                                  globals.etimes[0])
                              .toString(),
                          updatedData[updatedData.length - 4][1],
                          updatedData[updatedData.length - 4][2],
                          updatedData[updatedData.length - 4][3]),
                      _SensorData(
                          (globals.etimes[globals.etimes.length - 3] -
                                  globals.etimes[0])
                              .toString(),
                          updatedData[updatedData.length - 3][1],
                          updatedData[updatedData.length - 3][2],
                          updatedData[updatedData.length - 3][3]),
                      _SensorData(
                          (globals.etimes[globals.etimes.length - 2] -
                                  globals.etimes[0])
                              .toString(),
                          updatedData[updatedData.length - 2][1],
                          updatedData[updatedData.length - 2][2],
                          updatedData[updatedData.length - 2][3]),
                      _SensorData(
                          (globals.etimes[globals.etimes.length - 1] -
                                  globals.etimes[0])
                              .toString(),
                          updatedData[updatedData.length - 1][1],
                          updatedData[updatedData.length - 1][2],
                          updatedData[updatedData.length - 1][3])
                    ];
                    List<_SensorData> data1 = [
                      _SensorData(
                          globals.etimes[globals.etimes.length - 5].toString(),
                          updatedData[updatedData.length - 5][4],
                          updatedData[updatedData.length - 5][5],
                          updatedData[updatedData.length - 5][6]),
                      _SensorData(
                          globals.etimes[globals.etimes.length - 4].toString(),
                          updatedData[updatedData.length - 4][4],
                          updatedData[updatedData.length - 4][5],
                          updatedData[updatedData.length - 4][6]),
                      _SensorData(
                          globals.etimes[globals.etimes.length - 3].toString(),
                          updatedData[updatedData.length - 3][4],
                          updatedData[updatedData.length - 3][5],
                          updatedData[updatedData.length - 3][6]),
                      _SensorData(
                          globals.etimes[globals.etimes.length - 2].toString(),
                          updatedData[updatedData.length - 2][4],
                          updatedData[updatedData.length - 2][5],
                          updatedData[updatedData.length - 2][6]),
                      _SensorData(
                          globals.etimes[globals.etimes.length - 1].toString(),
                          updatedData[updatedData.length - 1][4],
                          updatedData[updatedData.length - 1][5],
                          updatedData[updatedData.length - 1][6])
                    ];

                    return SingleChildScrollView(
                        child: Column(
                      children: [
                        SfCartesianChart(
                          primaryXAxis: CategoryAxis(),
                          title:
                              ChartTitle(text: 'Accelerometer Data Analysis'),
                          legend: Legend(isVisible: true),
                          tooltipBehavior: TooltipBehavior(enable: true),
                          series: <ChartSeries<_SensorData, String>>[
                            LineSeries<_SensorData, String>(
                              dataSource: data,
                              xValueMapper: (_SensorData data, _) => data.time,
                              yValueMapper: (_SensorData data, _) => data.x,
                              name: 'Accelerometer-X',
                              dataLabelSettings:
                                  DataLabelSettings(isVisible: true),
                            ),
                            LineSeries<_SensorData, String>(
                              dataSource: data,
                              xValueMapper: (_SensorData data, _) => data.time,
                              yValueMapper: (_SensorData data, _) => data.y,
                              name: 'Accelerometer-Y',
                              dataLabelSettings:
                                  DataLabelSettings(isVisible: true),
                            ),
                            LineSeries<_SensorData, String>(
                              dataSource: data,
                              xValueMapper: (_SensorData data, _) => data.time,
                              yValueMapper: (_SensorData data, _) => data.z,
                              name: 'Accelerometer-Z',
                              dataLabelSettings:
                                  DataLabelSettings(isVisible: true),
                            ),
                          ],
                        ),
                        SfCartesianChart(
                          primaryXAxis: CategoryAxis(),
                          title: ChartTitle(text: 'Gyroscopic Data Analysis'),
                          legend: Legend(isVisible: true),
                          tooltipBehavior: TooltipBehavior(enable: true),
                          series: <ChartSeries<_SensorData, String>>[
                            LineSeries<_SensorData, String>(
                              dataSource: data1,
                              xValueMapper: (_SensorData data1, _) =>
                                  data1.time,
                              yValueMapper: (_SensorData data1, _) => data1.x,
                              name: 'Gyroscopic-X',
                              dataLabelSettings:
                                  DataLabelSettings(isVisible: true),
                            ),
                            LineSeries<_SensorData, String>(
                              dataSource: data1,
                              xValueMapper: (_SensorData data1, _) =>
                                  data1.time,
                              yValueMapper: (_SensorData data1, _) => data1.y,
                              name: 'Gyroscopic-Y',
                              dataLabelSettings:
                                  DataLabelSettings(isVisible: true),
                            ),
                            LineSeries<_SensorData, String>(
                              dataSource: data1,
                              xValueMapper: (_SensorData data1, _) =>
                                  data1.time,
                              yValueMapper: (_SensorData data1, _) => data1.z,
                              name: 'Gyroscopic-Z',
                              dataLabelSettings:
                                  DataLabelSettings(isVisible: true),
                            ),
                          ],
                        ),
                      ],
                    ));

                    // return Container();
                  } else if (snapshot.hasError) {
                    return Text('Err: ${snapshot.error}');
                  } else if (!snapshot.hasData) {
                    return Text('No data found');
                  } else {
                    return Center(child: CircularProgressIndicator());
                  }
                },
              ),
            ],
          ),
        ));
  }
}

class _SensorData {
  final String time;
  final int x;
  final int y;
  final int z;

  _SensorData(this.time, this.x, this.y, this.z);
}
