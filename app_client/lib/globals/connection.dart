import 'package:wear_os/esense/angler.dart';
import 'package:wear_os/esense/device.dart';
import 'package:wear_os/globals.dart' as gt;

String connectionState = "";
Device device = Device(gt.devicenm);
Angler angler = Angler(device: device);
