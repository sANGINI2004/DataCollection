import 'dart:math';

import 'package:flame/components.dart';

double distanceOnSphere(Vector3 lhs, Vector3 rhs, [double radius = 1]) {
  return radius * acos(lhs.dot(rhs) / (radius * radius));
}
