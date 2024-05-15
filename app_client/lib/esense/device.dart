import 'dart:async';

import 'package:esense_flutter/esense.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wear_os/esense/sender.dart';
import 'package:wear_os/util/callback.dart';
import 'package:wear_os/util/pair.dart';
import 'package:wear_os/globals.dart' as g;

enum DeviceState {
  waiting,
  searching,
  connecting,
  connected,
  initialized,
}

class Device {
  String deviceName = "";
  Device(String name) {
    this.deviceName = name;
    _debugConnectionSub = _manager.connectionEvents.listen(print);
    _connectionSub = _manager.connectionEvents.listen(_onConnectionEvent);
  }

  static const Duration requestDelay = Duration(milliseconds: 1000);
  static const Duration connectionDelay = Duration(milliseconds: 250);
  static const int samplingRate = 60;

  final _manager = ESenseManager(g.devicenm);
  final _sender = Sender(1000);

  var _callbackIndex = 0;
  final _eventCallbacks = <Pair<int, Callback<ESenseEvent>>>[];
  final _sensorCallbacks = <Pair<int, Callback<SensorEvent>>>[];
  final _stateCallbacks = <Pair<int, Callback<DeviceState>>>[];

  // TODO: use finalizer to close
  StreamSubscription? _connectionSub;
  StreamSubscription? _debugConnectionSub;

  StreamSubscription? _eventSub;
  StreamSubscription? _debugEventSub;
  StreamSubscription? _callbackEventSub;

  StreamSubscription? _sensorSub;
  StreamSubscription? _debugSensorSub;
  StreamSubscription? _callbackSensorSub;

  String? _deviceName;
  double? _deviceBatteryVolt;
  ESenseConfig? _deviceConfig;
  bool _receivedSensorEvent = false;

  DeviceState __state = DeviceState.waiting;

  ESenseManager get manager => _manager;
  Sender get sender => _sender;
  ESenseConfig? get deviceConfig => _deviceConfig;
  bool get receivedSensorEvent => _receivedSensorEvent;
  bool get receivedDeviceName => _deviceName != null;
  bool get receivedBatteryVolt => _deviceBatteryVolt != null;
  bool get receivedDeviceConfig => _deviceConfig != null;

  DeviceState get state => __state;
  set _state(DeviceState val) {
    if (__state == val) {
      return;
    }
    __state = val;
    invokeCallbacks(_stateCallbacks, val);
  }

  bool isReady() => __state == DeviceState.initialized;
  bool isIdle() => __state == DeviceState.waiting;

  static String _formatConfig(ESenseConfig? cfg) {
    if (cfg != null) {
      var buffer = '\n';
      buffer += '\t${cfg.accLowPass}\n';
      buffer += '\t${cfg.gyroLowPass}\n';
      buffer += '\t${cfg.accRange}\n';
      buffer += '\t${cfg.gyroRange}';
      return buffer;
    }
    return 'null';
  }

  @override
  String toString() {
    final getter = <Pair<String, String Function()>>[
      Pair('State', () => __state.name),
      Pair('MgrConnected', () => '${_manager.connected}'),
      Pair('Name', () => '$_deviceName'),
      Pair('Config', () => _formatConfig(_deviceConfig)),
      Pair('Voltage', () => '${_deviceBatteryVolt}V'),
    ];

    var buffer = '';
    for (var i = 0; i < getter.length; i += 1) {
      if (i > 0) buffer += '\n';
      buffer += '${getter[i].first}: ${getter[i].second()}';
    }
    return buffer;
  }

  int _nextId() {
    final next = _callbackIndex;
    _callbackIndex += 1;
    return next;
  }

  Closer registerSensorCallback(Callback<SensorEvent> callback) {
    final id = _nextId();
    _sensorCallbacks.add(Pair(id, callback));
    return () => _removeSensorCallback(id);
  }

  Closer registerEventCallback(Callback<ESenseEvent> callback) {
    final id = _nextId();
    _eventCallbacks.add(Pair(id, callback));
    return () => _removeEventCallback(id);
  }

  Closer registerStateCallback(Callback<DeviceState> callback) {
    final id = _nextId();
    _stateCallbacks.add(Pair(id, callback));
    return () => _removeStateCallback(id);
  }

  void _removeSensorCallback(int id) {
    _sensorCallbacks.removeWhere((pair) => pair.first == id);
  }

  void _removeEventCallback(int id) {
    _eventCallbacks.removeWhere((pair) => pair.first == id);
  }

  void _removeStateCallback(int id) {
    _stateCallbacks.removeWhere((pair) => pair.first == id);
  }

  static void invokeCallbacks<T>(
      Iterable<Pair<int, Callback<T>>> pairs, T event) {
    for (final pair in pairs) {
      pair.second(event);
    }
  }

  Future<bool> _askForPermission(Permission permission) async {
    return await permission.request().isGranted;
  }

  Future<bool> _initialize() async {
    final queue = [
      () async => await _manager.setSamplingRate(samplingRate),
      () async => await _manager.getDeviceName(),
      () async => await _manager.getSensorConfig(),
      () async => await _manager.getBatteryVoltage(),
      () async {
        _sensorSub = _manager.sensorEvents.listen(_onSensorEvent);
        return true;
      },
    ];
    for (final req in queue) {
      if (!await req()) {
        return false;
      }
      await Future.delayed(requestDelay);
    }

    for (;;) {
      if (_deviceName == null ||
          _deviceConfig == null ||
          _deviceBatteryVolt == null ||
          !_receivedSensorEvent) {
        await Future.delayed(requestDelay);
        continue;
      }
      break;
    }

    return true;
  }

  Future<void> _connect() async {
    if (!await _askForPermissions()) {
      throw Exception("permissions not given");
    }

    if (!await _manager.connect()) {
      throw Exception("couldn't start looking for device");
    }

    _state = DeviceState.searching;

    for (;;) {
      switch (__state) {
        case DeviceState.waiting:
          break; // look again
        case DeviceState.searching:
          break; // keep waiting
        case DeviceState.connecting:
          break; // keep waiting
        case DeviceState.connected:
          return; // success
        case DeviceState.initialized:
          throw Exception("initialized-state while connecting");
      }
      await Future.delayed(connectionDelay);
    }
  }

  Future<bool> _disconnect() async {
    if (__state != DeviceState.initialized &&
        __state != DeviceState.connected &&
        __state != DeviceState.connecting) {
      throw Exception("not connected");
    }

    return await _manager.disconnect();
  }

  Future<bool> _askForPermissions() async {
    return await _askForPermission(Permission.bluetooth) &&
        await _askForPermission(Permission.bluetoothScan) &&
        await _askForPermission(Permission.bluetoothConnect) &&
        await _askForPermission(Permission.locationWhenInUse);
  }

  Future<bool> connectAndStartListening() async {
    if (_manager.connected) {
      throw Exception("already connected");
    }

    if (__state != DeviceState.waiting) {
      throw Exception("already connecting");
    }

    await _connect();
    _debugEventSub = _manager.eSenseEvents.listen(print);
    _eventSub = _manager.eSenseEvents.listen(_onESenseEvent);
    _callbackEventSub = _manager.eSenseEvents.listen((event) {
      invokeCallbacks(_eventCallbacks, event);
    });

    await Future.delayed(const Duration(seconds: 1));
    await _initialize();
    // _debugSensorSub = _manager.sensorEvents.listen(print);
    // we start listening to sensor-events inside `_initialize`
    _callbackSensorSub = _manager.sensorEvents.listen((event) {
      invokeCallbacks(_sensorCallbacks, event);
    });
    _state = DeviceState.initialized;

    return true;
  }

  void _onESenseEvent(ESenseEvent event_) {
    switch (event_.runtimeType) {
      case RegisterListenerEvent:
        final _ = event_ as RegisterListenerEvent;
        break;
      case DeviceNameRead:
        final e = event_ as DeviceNameRead;
        _deviceName = e.deviceName;
        break;
      case BatteryRead:
        final e = event_ as BatteryRead;
        _deviceBatteryVolt = e.voltage;
        break;
      case AccelerometerOffsetRead:
        final _ = event_ as AccelerometerOffsetRead;
        break;
      case AdvertisementAndConnectionIntervalRead:
        final _ = event_ as AdvertisementAndConnectionIntervalRead;
        break;
      case ButtonEventChanged:
        final _ = event_ as ButtonEventChanged;
        break;
      case SensorConfigRead:
        final e = event_ as SensorConfigRead;
        _deviceConfig = e.config;
        break;
    }
  }

  void _onSensorEvent(SensorEvent event) {
    if (!_receivedSensorEvent) {
      _receivedSensorEvent = true;
    }
  }

  void _onConnectionEvent(ConnectionEvent event) {
    switch (event.type) {
      case ConnectionType.unknown:
        assert(true, "encountered unknown state");
        break;
      case ConnectionType.connected:
        // assert(_state == _State.connecting, "invalid state-sequence");
        _state = DeviceState.connected;
        break;
      case ConnectionType.disconnected:
        // assert(_state == _State.connected || _state == _State.initialized,
        //     "disconnected from invalid state");
        _state = DeviceState.waiting;
        break;
      case ConnectionType.device_found:
        // assert(_state == _State.searching, "invalid state-sequence");
        _state = DeviceState.connecting;
        break;
      case ConnectionType.device_not_found:
        // assert(__state == DeviceState.searching, "invalid state-sequence");
        _manager.connect();
        _state = DeviceState.searching;
        break;
    }
  }

  Future<void> _removeSubscriptions() async {
    // don't remove connection-subscriptions

    await _eventSub?.cancel();
    await _debugEventSub?.cancel();
    await _callbackEventSub?.cancel();
    _eventSub = _debugEventSub = _callbackEventSub = null;

    await _sensorSub?.cancel();
    await _debugSensorSub?.cancel();
    await _callbackSensorSub?.cancel();
    _sensorSub = _debugSensorSub = _callbackSensorSub = null;
  }

  Future<bool> disconnectAndStopListening() async {
    _deviceBatteryVolt = _deviceConfig = _deviceName = null;
    _receivedSensorEvent = false;

    if (__state != DeviceState.initialized &&
        __state != DeviceState.connected &&
        __state != DeviceState.connecting) {
      _state = DeviceState.waiting;
      return true;
    }

    await _removeSubscriptions();

    if (!await _disconnect()) {
      throw Exception("couldn't send disconnect request");
    }

    _state = DeviceState.waiting;
    return true;
  }
}
