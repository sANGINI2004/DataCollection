import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:is_wear/is_wear.dart';
import 'package:sensors/sensors.dart';
import 'package:watch_connectivity/watch_connectivity.dart';
import 'package:wear/wear.dart';

late final bool isWear;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  isWear = (await IsWear().check()) ?? false;

  runApp(const MyApp());
}

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
    _watch.messageStream
        .listen((e) => setState(() => _log.add('Received message: $e')));
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

  @override
  Widget build(BuildContext context) {
    final home = Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SafeArea(
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Supported: $_supported'),
                  Text('Paired: $_paired'),
                  Text('Reachable: $_reachable'),
                  TextButton(
                    onPressed: initPlatformState,
                    child: const Text('Refresh'),
                  ),
                  const SizedBox(height: 8),
                  const Text('Send'),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        onPressed: toggleBackgroundMessaging,
                        child: Text(
                          '${timer == null ? 'Start' : 'Stop'} background messaging',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
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
      timer = Timer.periodic(
          const Duration(milliseconds: 100), (_) => sendMessage());
    } else {
      timer?.cancel();
      timer = null;
    }
    setState(() {});
  }

  void sendMessage() {
    final message = {
      'Timestamp':DateTime.now(),
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
    _watch.sendMessage(message);
    // setState(() => _log.add('Sent message: $message'));
  }
}
