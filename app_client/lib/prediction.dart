import 'package:flutter/material.dart';
// import 'globals.dart' as g;

// import 'dart:collection';
import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:wear_os/globals.dart' as globals;

class ActivityRecog extends StatefulWidget {
  const ActivityRecog({Key? key}) : super(key: key);

  @override
  State<ActivityRecog> createState() => _ActivityRecogState();
}

class _ActivityRecogState extends State<ActivityRecog> {
  bool useFilter = false;

  Future<void> _generateCsvFile() async {
    PermissionStatus status = await Permission.storage.request();
    print(status.isGranted);
    if (!status.isGranted) {
      print('Permission denied');
      Map<Permission, PermissionStatus> statuses = await [
        Permission.storage,
      ].request();
      print(statuses[Permission.storage]);
    }

    // Combine the data from globals.datalist and globals.datalistesense
    List<List<dynamic>> datacombined = [
      ...globals.datalist
          .map((row) => [row[0], 'Smartwatch', ...row.sublist(1)]),
      ...globals.datalistesense
          .map((row) => [row[0], 'Esense', ...row.sublist(1)]),
    ];

    // Sort the data based on the 'x' value (assuming each sublist has at least 1 element)
    datacombined.sort((a, b) => a[0].compareTo(b[0]));
    datacombined.shuffle();

    final csvData = datacombined.map((list) => list.join(',')).join('\n');
    final csvString =
        'x,device,y,z\n' + csvData; // Added 'device' column header

    bool dirDownloadExists = true;
    var directory;
    if (Platform.isIOS) {
      directory = await getDownloadsDirectory();
    } else {
      directory = "/storage/emulated/0/Download/";

      dirDownloadExists = await Directory(directory).exists();
      if (dirDownloadExists) {
        directory = "/storage/emulated/0/Download/";
      } else {
        directory = "/storage/emulated/0/Downloads/";
      }
    }
    final filePath = '${directory}/datacombined1.csv';

    final file = File(filePath);
    await file.writeAsString(csvString);

    const snackBar = SnackBar(
      content: Text('CSV file saved in downloads as datacombined1.csv'),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);

    print('CSV file saved in external storage: $directory');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            SizedBox(
              height: 20,
            ),
            SizedBox(
              height: 20,
            ),
            ElevatedButton(
              onPressed: _generateCsvFile,
              child: Text("Get Combined data"),
            ),
            SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Use Filter'),
                Switch(
                  value: useFilter,
                  onChanged: (value) {
                    setState(() {
                      useFilter = value;
                    });
                  },
                ),
                Text('Don\'t Use Filter'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
