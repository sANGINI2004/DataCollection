import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:is_wear/is_wear.dart';
import 'package:sensors/sensors.dart';
import 'package:watch_connectivity/watch_connectivity.dart';
import 'package:wear/wear.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wear_os/graphs.dart';
import 'package:wear_os/homescreen.dart';
import 'package:wear_os/pongsense.dart';
import 'globals.dart' as globals;

late final bool isWear;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  isWear = (await IsWear().check()) ?? false;

  runApp(
    const MaterialApp(
      home: HomeScreen(),
    ),
  );
}

const YesIcon = Icon(
  Icons.check,
  color: Colors.green,
);

const NoIcon = Icon(
  Icons.close,
  color: Colors.red,
);

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final WatchConnectivityBase _watch;

  var _supported = false;
  var _paired = false;
  var _reachable = false;
  var _context = <String, dynamic>{};
  var _receivedContexts = <Map<String, dynamic>>[];
  final _log = <String>[];

  Timer? timer;

  AccelerometerEvent? _accelerometerEvent;
  GyroscopeEvent? _gyroscopeEvent;
  StreamSubscription<AccelerometerEvent>? _accelerometerStream;
  StreamSubscription<GyroscopeEvent>? _gyroscopeStream;

  @override
  void initState() {
    super.initState();
    _watch = WatchConnectivity();
    _watch.messageStream.listen((e) {
      setState(() {
        List liss = [
          e['Timestamp'],
          e['accelerometer']['x'],
          e['accelerometer']['y'],
          e['accelerometer']['z'],
          e['gyroscope']['x'],
          e['gyroscope']['y'],
          e['gyroscope']['z'],
        ];
        List l = liss + globals.activity;
        globals.datalist.add(l);
        globals.updateDatalist(l);
        globals.times.add(DateTime.now().millisecondsSinceEpoch);
        _log.add('Received message: $e');
      });
    });
    initPlatformState();

    _accelerometerStream =
        accelerometerEvents.listen((AccelerometerEvent event) {
      setState(() {
        _accelerometerEvent = event;
      });
    });

    _gyroscopeStream = gyroscopeEvents.listen((GyroscopeEvent event) {
      setState(() {
        _gyroscopeEvent = event;
      });
    });
  }

  @override
  void dispose() {
    _accelerometerStream?.cancel();
    _gyroscopeStream?.cancel();
    timer?.cancel();
    super.dispose();
  }

  void initPlatformState() async {
    _supported = await _watch.isSupported;
    _paired = await _watch.isPaired;
    _reachable = await _watch.isReachable;
    setState(() {});
  }

  Future<void> _generateCsvFile() async {
  // Request storage permission
  if (!Platform.isIOS) {
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      status = await Permission.storage.request();
      if (!status.isGranted) {
        print('Storage permission not granted');
        return;
      }
    }
  }

  // Format data for CSV. Assuming each sublist in globals.datalist has the timestamp and gyroscope values at the correct indexes
  final csvData = globals.datalist.map((list) => "${list[0]},${list[4]},${list[5]},${list[6]},${list[1]},${list[2]},${list[3]}").join('\n');
  final csvHeader = 'timestamp,gyro_x,gyro_y,gyro_z,acc_x,acc_y,acc_z\n';  // CSV header
  final csvString = csvHeader + csvData;

  Directory? tempDirectory = await getExternalStorageDirectory();
  if (tempDirectory == null) {
    print('Failed to find an external directory');
    return;
  }
  Directory directory = Directory('${tempDirectory.path}/Download');
  if (!await directory.exists()) {
    await directory.create(recursive: true);
  }

  String filePath = '${directory.path}/data.csv';
  final file = File(filePath);

  try {
    await file.writeAsString(csvString);
    print('CSV file saved successfully at $filePath');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('CSV file saved at $filePath')),
    );
  } catch (e) {
    print('Failed to write to the file: $e');
  }
}



  @override
  Widget build(BuildContext context) {
    final home = Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(32),
        child: SafeArea(
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const ListTile(
                  title: Text(
                    'Connection State',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                ListTile(
                  leading: _supported ? YesIcon : NoIcon,
                  title: const Text('Supported'),
                ),
                ListTile(
                  leading: _paired ? YesIcon : NoIcon,
                  title: const Text('Paired'),
                ),
                ListTile(
                  leading: _reachable ? YesIcon : NoIcon,
                  title: const Text('Reachable'),
                ),
                // Text('Supported: $_supported'),
                // Text('Paired: $_paired'),
                // Text('Reachable: $_reachable'),
                TextButton(
                  onPressed: initPlatformState,
                  child: const Text('Refresh'),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _generateCsvFile,
                  child: const Text('Generate CSV'),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: toggleBackgroundMessaging,
                  child: Text(
                    '${timer == null ? 'Start' : 'Stop'} background messaging',
                    textAlign: TextAlign.center,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => Graphs()));
                  },
                  child: const Text('Graphs'),
                ),
                // const SizedBox(width: 16),
                // TextButton(
                //   onPressed: () {
                //     Navigator.push(context,
                //         MaterialPageRoute(builder: (context) => PongSense()));
                //   },
                //   child: const Text('Esense'),
                // ),
                const SizedBox(width: 30),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _log.clear();
                    });
                  },
                  child: const Text('Clear Log'),
                ),
                const SizedBox(width: 15),
                const Text('Log'),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Center(
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: ListView(
                        shrinkWrap: true,
                        children:
                            _log.reversed.map((log) => Text(log)).toList(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    return MaterialApp(
      home: isWear
          ? AmbientMode(
              builder: (context, mode, child) => child!,
              child: home,
            )
          : home,
    );
  }

  void toggleBackgroundMessaging() {
    if (timer == null) {
      timer = Timer.periodic(const Duration(seconds: 1), (_) => sendMessage());
    } else {
      timer?.cancel();
      timer = null;
    }
    setState(() {});
  }

  void sendMessage() {
    final message = {
      'accelerometer': {
        'x': _accelerometerEvent?.x,
        'y': _accelerometerEvent?.y,
        'z': _accelerometerEvent?.z,
      },
      'gyroscope': {
        'x': _gyroscopeEvent?.x,
        'y': _gyroscopeEvent?.y,
        'z': _gyroscopeEvent?.z,
      },
    };

    List l = [
      _accelerometerEvent?.x,
      _accelerometerEvent?.y,
      _accelerometerEvent?.z,
      _gyroscopeEvent?.x,
      _gyroscopeEvent?.y,
      _gyroscopeEvent?.z
    ];
    // globals.datalist.add(l);
    // globals.updateDatalist(l);
    // globals.times.add(DateTime.now().millisecondsSinceEpoch);
    _watch.sendMessage(message);
    setState(() => _log.add('Sent message: $message'));
  }
}
