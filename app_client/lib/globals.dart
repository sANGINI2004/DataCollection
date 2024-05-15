library globals;

import 'dart:async';

String currentActivity = "Not Selected";

bool pages = false;

String devicenm = "none";
List<String> options = [];
List<String> activity = [];
Map<String, bool> values = {};

List<dynamic> times = [];
List<dynamic> etimes = [];
List<dynamic> datalist = [];

List<dynamic> datalistesense = [];

StreamController<List<dynamic>> _datalistStreamController =
    StreamController<List<dynamic>>.broadcast();
Stream<List<dynamic>> get datalistStream => _datalistStreamController.stream;

void updateDatalist(List<dynamic> newData) {
  _datalistStreamController.add(datalist);
}

StreamController<List<dynamic>> _EdatalistStreamController =
    StreamController<List<dynamic>>.broadcast();
Stream<List<dynamic>> get EdatalistStream => _EdatalistStreamController.stream;

void EupdateDatalist(List<dynamic> newData) {
  _EdatalistStreamController.add(datalistesense);
}

void dispose() {
  _datalistStreamController.close();
  _EdatalistStreamController.close();
}
