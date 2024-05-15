import 'package:flutter/material.dart';
import 'package:wear_os/esenseconnect.dart';
import 'package:wear_os/graphs.dart';
import 'package:wear_os/main.dart';
import 'package:wear_os/pongsense.dart';
import 'package:wear_os/prediction.dart';
import 'package:wear_os/recog.dart';
import 'package:wear_os/tabcontrol.dart';
import 'globals.dart' as gs;

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 4,
        child: Scaffold(
            appBar: AppBar(
              title: const Text('Complex Behaviour Recognition'),
              bottom: const TabBar(
                tabs: [
                  Tab(
                    text: 'Activity',
                  ),
                  Tab(
                    text: 'Watch',
                  ),
                  Tab(
                    text: 'Esense',
                  ),
                  Tab(
                    text: 'Combined',
                  ),
                ],
              ),
            ),
            body: const TabBarView(
              children: <Widget>[
                Recog(),
                MyApp(),
                TabControl(),
                ActivityRecog()
              ],
            )));
  }
}
