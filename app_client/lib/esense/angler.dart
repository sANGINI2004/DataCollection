import 'package:esense_flutter/esense.dart';
import 'package:flame/components.dart';
import 'package:wear_os/esense/device.dart';
import 'package:wear_os/math/remap.dart';
import 'package:wear_os/math/vector.dart';
import 'package:wear_os/util/pair.dart';

import '../util/callback.dart';

class AnglerEvent {
  final double leftAngle;
  final double rightAngle;
  final double percent;

  AnglerEvent({
    required this.leftAngle,
    required this.rightAngle,
    required this.percent,
  });
}

class Angler {
  Vector3? _calibrateLeft;
  Vector3? _calibrateRight;
  Vector3? _lastAccel;

  // TODO: use finalizer to close
  late Closer _sensorCallbackCloser;

  var _callbackIndex = 0;
  final _angleChangedCallbacks = <Pair<int, Callback<AnglerEvent>>>[];

  Angler({required Device device}) {
    _sensorCallbackCloser = device.registerSensorCallback(_onSensorEvent);
  }

  Vector3? get calibrateLeft => _calibrateLeft;
  Vector3? get calibrateRight => _calibrateRight;

  bool canCalibrate() {
    return _lastAccel != null;
  }

  bool doCalibrateLeft() {
    final last = _lastAccel;
    if (last == null) return false;
    _calibrateLeft = _lastAccel;
    return true;
  }

  bool doCalibrateRight() {
    final last = _lastAccel;
    if (last == null) return false;
    _calibrateRight = _lastAccel;
    return true;
  }

  bool isCalibrated() {
    return _calibrateLeft != null && _calibrateRight != null;
  }

  static void invokeCallbacks<T>(
      Iterable<Pair<int, Callback<T>>> pairs, T event) {
    for (final pair in pairs) {
      pair.second(event);
    }
  }

  void _onSensorEvent(SensorEvent event) {
    final accel = toVec3(event.accel);
    if (accel == null) return;
    _lastAccel = accel;

    if (!isCalibrated()) return;

    final left = _calibrateLeft;
    final right = _calibrateRight;
    if (left == null || right == null) return;

    final planeNormal = left.cross(right);
    final projectedAccel = projectOntoPlane(accel, planeNormal);

    final leftAngle = projectedAccel.angleToSigned(left, planeNormal);
    final rightAngle = projectedAccel.angleToSigned(right, planeNormal);

    final diff = rightAngle - leftAngle;
    final percent = 1.0 - rightAngle.remapAndClamp(0, diff, 0, 1).toDouble();

    invokeCallbacks(
        _angleChangedCallbacks,
        AnglerEvent(
          leftAngle: leftAngle,
          rightAngle: rightAngle,
          percent: percent,
        ));
  }

  int _nextId() {
    final next = _callbackIndex;
    _callbackIndex += 1;
    return next;
  }

  Closer registerAngleChangedCallback(Callback<AnglerEvent> callback) {
    final id = _nextId();
    _angleChangedCallbacks.add(Pair(id, callback));
    return () => _removeAngleChangedCallback(id);
  }

  void _removeAngleChangedCallback(int id) {
    _angleChangedCallbacks.removeWhere((pair) => pair.first == id);
  }
}
