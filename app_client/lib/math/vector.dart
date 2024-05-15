import 'package:flame/components.dart';

/// Project `input` onto the plane defined by `planeNormal`
Vector3 projectOntoPlane(Vector3 input, Vector3 planeNormal) {
  return input -
      planeNormal * (input.dot(planeNormal) / planeNormal.dot(planeNormal));
}

Vector3? toVec3(List<int>? it) {
  if (it == null || it.length < 3) return null;
  return Vector3(it[0].toDouble(), it[1].toDouble(), it[2].toDouble());
}
