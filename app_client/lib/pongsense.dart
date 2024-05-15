import 'package:flutter/material.dart';
import 'package:wear_os/esense/device.dart';
import 'package:wear_os/esense/device.dart';
import 'package:wear_os/routes/calibration.dart';
import 'package:wear_os/routes/connect.dart';
import 'package:wear_os/globals/connection.dart' as g;
import 'package:wear_os/util/callback.dart';



class PongSense extends StatelessWidget {
  const PongSense({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Pongsense',
      home: Navigation(),
    );
  }
}

class Navigation extends StatefulWidget {
  const Navigation({super.key});

  @override
  NavigationState createState() => NavigationState();
}

class NavigationState extends State<Navigation> {
  Closer? _stateCallbackCloser;
  var _deviceState = g.device.state;

  int _currentTabIndex = 0;

  final calibrateScreen = const CalibrationScreen();
  final connectScreen = const ConnectScreen();

  final reconnectSnackBar = const SnackBar(
    content: Text('Please reconnect to the device first!'),
  );
  final connectSnackBar = const SnackBar(
    content: Text('You have to connect to a device first!'),
  );

  @override
  void initState() {
    super.initState();

    _stateCallbackCloser = g.device.registerStateCallback((state) {
      if (state == _deviceState) return;
      setState(() {
        _deviceState = state;

        // redirect to connect widget on disconnect
        if (_currentTabIndex != 0 && _deviceState != DeviceState.initialized) {
          ScaffoldMessenger.of(context).showSnackBar(reconnectSnackBar);
          _currentTabIndex = 0;
        }
      });
    });
  }

  Widget _bottomNavigationBar() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      items: [
        const BottomNavigationBarItem(
          icon: Icon(Icons.bluetooth_connected),
          label: "Connect",
        ),
        BottomNavigationBarItem(
          icon: Icon(
            Icons.calculate,
            color: _deviceState != DeviceState.initialized
                ? Theme.of(context).disabledColor
                : null,
          ),
          label: "Calibrate",
        ),

      ],
      onTap: _onTap,
      currentIndex: _currentTabIndex,
    );
  }

  _onTap(int tabIndex) {
    if (_currentTabIndex == tabIndex) {
      return;
    }

    // calibrate is disabled when not connected
    // if (tabIndex != 0 && _deviceState != DeviceState.initialized) {
    //   ScaffoldMessenger.of(context).showSnackBar(connectSnackBar);
    //   return;
    // }

    setState(() {
      _currentTabIndex = tabIndex;
    });
  }

  Widget get route {
    switch (_currentTabIndex) {
      case 0:
        return connectScreen;
      case 1:
        return calibrateScreen;

      default:
        return connectScreen;
    }
  }

  String get routeTitle {
    switch (_currentTabIndex) {
      case 0:
        return "Connect";
      case 1:
        return "Calibrate";
      default:
        return "Connect";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text(routeTitle),
      // ),
      body: route,
      bottomNavigationBar: _bottomNavigationBar(),
    );
  }

  @override
  void dispose() {
    _stateCallbackCloser?.call();
    super.dispose();
  }
}
