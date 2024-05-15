import 'package:flutter/material.dart';
import 'package:wear_os/esenseconnect.dart';
import 'package:wear_os/pongsense.dart';
import 'globals.dart' as g;

class TabControl extends StatefulWidget {
  const TabControl({Key? key}) : super(key: key);

  @override
  State<TabControl> createState() => _TabControlState();
}

class _TabControlState extends State<TabControl> {
  @override
  Widget build(BuildContext context) {
    if(!g.pages){

      return EsenseConnect();
    }
    else{
      return PongSense();
    }


  }
}
