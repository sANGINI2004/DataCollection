import 'dart:collection';
import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:esense_flutter/esense.dart';
import 'package:flame/components.dart';
import 'package:wear_os/esense/device.dart';
import 'package:wear_os/esense_graph.dart';
import 'package:wear_os/globals/connection.dart' as g;
import 'package:ditredi/ditredi.dart';
import 'package:wear_os/math/remap.dart';
import 'package:wear_os/math/vector.dart';
import 'package:wear_os/util/callback.dart';
import 'package:wear_os/globals.dart' as globals;

class CalibrationScreen extends StatefulWidget {
  const CalibrationScreen({super.key});

  @override
  CalibrationScreenState createState() => CalibrationScreenState();
}

const YesIcon = Icon(
  Icons.check,
  color: Colors.green,
);
const NoIcon = Icon(
  Icons.close,
  color: Colors.red,
);

class CalibrationScreenState extends State<CalibrationScreen> {
  static const int _maxLen = 60 * 1; // 60fps, 10s
  static final _calibrationColorLeft = Colors.orange.withAlpha(180);
  static final _calibrationColorRight = Colors.yellow.withAlpha(180);
  static final _bounds = Aabb3.minMax(Vector3(-1, -1, -1), Vector3(1, 1, 1));
  static const _accelColor = Colors.purple;

  var _lastAccels = ListQueue<Vector3>(_maxLen);
  var _lastGyros = ListQueue<Vector3>(_maxLen);
  var _deviceState = g.device.state;

  Vector3? _calibrateLeft = g.angler.calibrateLeft;
  Vector3? _calibrateRight = g.angler.calibrateRight;

  final _controllerFront = DiTreDiController(
    rotationX: -90,
    rotationY: 90,
    rotationZ: 0,
    userScale: 1.8,
    minUserScale: 1.5,
    maxUserScale: 3,
  );

  Closer? _sensorCallbackCloser;
  Closer? _stateCallbackCloser;
  Closer? _angleChangedCallbackCloser;

  Future<void> _generateCsvFile() async {
    PermissionStatus status = await Permission.storage.request();
    print(status.isGranted);
    if (!status.isGranted) {
      print('Permission denied');
      Map<Permission, PermissionStatus> statuses = await [
        Permission.storage,
      ].request();
      print(statuses[Permission.storage]);
    }

    final csvData =
        globals.datalistesense.map((list) => list.join(',')).join('\n');
    final csvString = 'x,y,z\n' + csvData;

    bool dirDownloadExists = true;
    var directory;
    if (Platform.isIOS) {
      directory = await getDownloadsDirectory();
    } else {
      directory = "/storage/emulated/0/Download/";

      dirDownloadExists = await Directory(directory).exists();
      if (dirDownloadExists) {
        directory = "/storage/emulated/0/Download/";
      } else {
        directory = "/storage/emulated/0/Downloads/";
      }
    }
    final filePath = '${directory}/dataensense.csv';

    final file = File(filePath);
    await file.writeAsString(csvString);

    const snackBar = SnackBar(
      content: Text('CSV file saved in downloads as dataesense.csv'),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);

    print('CSV file saved in external storage: $directory');
  }

  List<Point3D> _generateAccelPoints() {
    final len = _lastAccels.length;
    return _lastAccels.mapIndexed((v, i) {
      final alpha = (i / len).remap(0, 1, 0, 150).floor();
      return Point3D(v, width: 2, color: _accelColor.withAlpha(alpha));
    }).toList();
  }

  List<Line3D> _generateAccelLine() {
    final len = _lastAccels.length;
    if (len == 0) return [];

    final last = _lastAccels.last;
    return [
      Line3D(
        Vector3.zero(),
        last,
        width: 2,
        color: _accelColor,
      )
    ];
  }

  List<Line3D> _generateCalibrationLines() {
    var buffer = <Line3D>[];
    final left = _calibrateLeft;
    final right = _calibrateRight;

    if (left != null) {
      buffer.add(Line3D(
        Vector3.zero(),
        left.normalized(),
        width: 2,
        color: _calibrationColorLeft,
      ));
    }
    if (right != null) {
      buffer.add(Line3D(
        Vector3.zero(),
        right.normalized(),
        width: 2,
        color: _calibrationColorRight,
      ));
    }

    return buffer;
  }

  List liss = [];
  List<Line3D> _generateCoordinateAxes() {
    return <Line3D>[
      Line3D(Vector3.zero(), Vector3(0.5, 0, 0), width: 2, color: Colors.red),
      Line3D(Vector3.zero(), Vector3(0, 0.5, 0), width: 2, color: Colors.green),
      Line3D(Vector3.zero(), Vector3(0, 0, 0.5), width: 2, color: Colors.blue),
    ];
  }

  VoidCallback? _onPressCalibrateLeft() {
    return () {
      if (g.angler.doCalibrateLeft()) {
        setState(() {
          _calibrateLeft = g.angler.calibrateLeft;
        });
      }
    };
  }

  VoidCallback? _onPressCalibrateRight() {
    return () {
      if (g.angler.doCalibrateRight()) {
        setState(() {
          _calibrateRight = g.angler.calibrateRight;
        });
      }
    };
  }

  @override
  void initState() {
    super.initState();
    _stateCallbackCloser = g.device.registerStateCallback((state) {
      if (state == _deviceState) return;
      setState(() {
        _deviceState = state;
        if (state != DeviceState.initialized) {
          _lastAccels = ListQueue<Vector3>(_maxLen);
          _lastGyros = ListQueue<Vector3>(_maxLen);
        }
      });
    });
    _sensorCallbackCloser = g.device.registerSensorCallback((event) {
      final gyroScale = g.device.deviceConfig?.gyroRange?.sensitivityFactor;
      final accelScale = g.device.deviceConfig?.accRange?.sensitivityFactor;
      if (gyroScale == null || accelScale == null) return;

      liss = [
        DateTime.now().millisecondsSinceEpoch,
        event.accel?[0],
        event.accel?[1],
        event.accel?[2],
        event.gyro?[0],
        event.gyro?[1],
        event.gyro?[2],
      ];
      List l = liss + globals.activity;

      globals.datalistesense.add(l);
      globals.EupdateDatalist(l);
      globals.etimes.add(DateTime.now().millisecondsSinceEpoch);
      
      var gyro = toVec3(event.gyro);
      var accel = toVec3(event.accel);
      if (gyro == null || accel == null) return;

      setState(() {
        if (_lastGyros.length > _maxLen) _lastGyros.removeFirst();
        if (_lastAccels.length > _maxLen) _lastAccels.removeFirst();
        _lastGyros.addLast(gyro / gyroScale);
        _lastAccels.addLast(accel / accelScale);
      });
    });
  }

  @override
  void dispose() {
    _sensorCallbackCloser?.call();
    _stateCallbackCloser?.call();
    _angleChangedCallbackCloser?.call();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final points = _generateAccelPoints();
    final plane = PointPlane3D(2, Axis3D.y, 0.1, Vector3.zero(), pointWidth: 1);
    final figures = <Model3D>[
      plane,
      ...points,
      ..._generateAccelLine(),
      ..._generateCalibrationLines(),
    ];

    return Scaffold(
      body: Column(
        children: [
          Container(
            height: 200,
            color: Colors.blueGrey,
            child: DiTreDiDraggable(
              controller: _controllerFront,
              child: DiTreDi(
                bounds: _bounds,
                config: const DiTreDiConfig(),
                figures: figures,
                controller: _controllerFront,
              ),
            ),
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    spreadRadius: 0,
                    blurRadius: 4,
                    offset: const Offset(0, -5), // changes position of shadow
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: ListView(
                        children: <Widget>[
                          // const ListTile(
                          //   title: Text(
                          //     'Calibration State',
                          //     style: TextStyle(fontWeight: FontWeight.bold),
                          //   ),
                          // ),
                          // ListTile(
                          //   leading: _calibrateLeft != null ? YesIcon : NoIcon,
                          //   title: const Text('Calibrated Left'),
                          // ),
                          // ListTile(
                          //   leading: _calibrateRight != null ? YesIcon : NoIcon,
                          //   title: const Text('Calibrated Right'),
                          // ),
                        ],
                      ),
                    ),
                    Text(
                      'To generate the csv click on the button below',
                    ),
                    const SizedBox(height: 10),
                    Text(
                      liss.toString(),
                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                    const SizedBox(height: 30),
                    // Row(
                    //   children: [
                    //     Expanded(
                    //       child: ElevatedButton(
                    //         onPressed: _onPressCalibrateLeft(),
                    //         child: const Text('Calibrate Left'),
                    //       ),
                    //     ),
                    //     const SizedBox(width: 10),
                    //     Expanded(
                    //       child: ElevatedButton(
                    //         onPressed: _onPressCalibrateRight(),
                    //         child: const Text('Calibrate Right'),
                    //       ),
                    //     ),
                    //   ],
                    // ),
                    SizedBox(
                      height: 20,
                    ),
                    Center(
                      child: ElevatedButton(
                        onPressed: _generateCsvFile,
                        child: const Text('Generate CSV'),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) => EGraphs()));
                      },
                      child: const Text('Graphs'),
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
