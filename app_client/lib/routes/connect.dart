import 'package:flutter/material.dart';
import 'package:wear_os/esense/device.dart';
import 'package:wear_os/esenseconnect.dart';
import 'package:wear_os/globals/connection.dart' as g;
import 'package:wear_os/homescreen.dart';
import 'package:wear_os/util/callback.dart';
import 'package:wear_os/globals.dart' as gt;

class ConnectScreen extends StatefulWidget {
  const ConnectScreen({super.key});

  @override
  ConnectScreenState createState() => ConnectScreenState();
}

const YesIcon = Icon(
  Icons.check,
  color: Colors.green,
);
const NoIcon = Icon(
  Icons.close,
  color: Colors.red,
);
const SyncIcon = Icon(
  Icons.sync,
  color: Colors.blue,
);

class ConnectScreenState extends State<ConnectScreen> {
  var _deviceState = g.device.state;

  var _receivedSensorEvent = g.device.receivedSensorEvent;
  var _receivedDeviceName = g.device.receivedDeviceName;
  var _receivedBatteryVolt = g.device.receivedBatteryVolt;
  var _receivedDeviceConfig = g.device.receivedDeviceConfig;

  Closer? _stateCallbackCloser;
  Closer? _eventCallbackCloser;

  void _updateDevice() {
    setState(() {
      _receivedSensorEvent = g.device.receivedSensorEvent;
      _receivedDeviceName = g.device.receivedDeviceName;
      _receivedBatteryVolt = g.device.receivedBatteryVolt;
      _receivedDeviceConfig = g.device.receivedDeviceConfig;
      _deviceState = g.device.state;
    });
  }

  @override
  void initState() {
    super.initState();
    _stateCallbackCloser = g.device.registerStateCallback((state) {
      _updateDevice();
    });
    _eventCallbackCloser = g.device.registerEventCallback((_) {
      _updateDevice();
    });
  }

  @override
  void dispose() {
    _stateCallbackCloser?.call();
    _eventCallbackCloser?.call();
    super.dispose();
  }

  String get _buttonText {
    switch (_deviceState) {
      case DeviceState.waiting:
        {
          // gt.pages = false;
          return 'Connect';
        }
      case DeviceState.searching:
        return 'Searching...';
      case DeviceState.connecting:
        return 'Connecting...';
      case DeviceState.connected:
        return 'Initializing...';
      case DeviceState.initialized:
        {
          gt.pages = true;
          return 'Disconnect';
        }
    }
  }

  VoidCallback? _onPressed() {
    switch (_deviceState) {
      case DeviceState.waiting:
        return () {

          g.device.connectAndStartListening();
        };
      case DeviceState.searching:
      case DeviceState.connecting:
      case DeviceState.connected:
        return null;
      case DeviceState.initialized:
        return () {

          g.device.disconnectAndStopListening();
        };
    }
  }

  TextEditingController textcon = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   leading: BackButton(
      //     onPressed: () {
      //       Navigator.push(
      //         context,
      //         MaterialPageRoute(builder: (context) => const HomeScreen()),
      //       );
      //     },
      //   ),
      //   title: const Text('Esense Connect'),
      // ),
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ListView(
                children: <Widget>[
                  const ListTile(
                    title: Text(
                      'Connection State',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  ListTile(
                    leading: _receivedSensorEvent
                        ? YesIcon
                        : (_deviceState == DeviceState.connected
                            ? SyncIcon
                            : NoIcon),
                    title: const Text('Received Sensor-Event'),
                  ),
                  ListTile(
                    leading: _receivedDeviceName
                        ? YesIcon
                        : (_deviceState == DeviceState.connected
                            ? SyncIcon
                            : NoIcon),
                    title: const Text('Received Device-Name'),
                  ),
                  ListTile(
                    leading: _receivedBatteryVolt
                        ? YesIcon
                        : (_deviceState == DeviceState.connected
                            ? SyncIcon
                            : NoIcon),
                    title: const Text('Received Battery-Voltage'),
                  ),
                  ListTile(
                    leading: _receivedDeviceConfig
                        ? YesIcon
                        : (_deviceState == DeviceState.connected
                            ? SyncIcon
                            : NoIcon),
                    title: const Text('Received Device-Config'),
                  ),
                ],
              ),
            ),
             Expanded(
              child: Column(
                children: [
                  //   TextField(
                  //     controller: textcon,
                  // decoration: const InputDecoration(
                  //   enabledBorder: OutlineInputBorder(
                  //     borderSide: BorderSide(color: Colors.grey, width: 0.0),
                  //   ),
                  //   hintText: 'Set the name for device',
                  //
                  //   labelText: 'Esense device',
                  // ),
                  //
                  //
                  //   ),
                  ElevatedButton(onPressed: (){

                    print('hi');
                    gt.pages=false;
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const EsenseConnect()),
                    );
                    Navigator.pop(context);
                  },
                      child: Text("Change device name")),
                  Text(
                      "Currently Selected Device:"),
                  SizedBox(
                    height: 20,
                  ),
                  Text(
                     gt.devicenm,
                    style: TextStyle(
                    color: Colors.black,
                    fontSize: 12.0,
                  ),),
                  SizedBox(
                    height: 20,
                  ),
                  Text(
                      "After connecting, go to other tab to calibrate the data  and generate CSV"),


                ],
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _onPressed(),
                child: Text(_buttonText),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
