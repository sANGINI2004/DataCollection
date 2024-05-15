import 'package:flutter/material.dart';
import 'package:wear_os/homescreen.dart';
import 'package:wear_os/pongsense.dart';
import 'globals.dart' as g;
class EsenseConnect extends StatefulWidget {
  const EsenseConnect({Key? key}) : super(key: key);

  @override
  State<EsenseConnect> createState() => _EsenseConnectState();
}

class _EsenseConnectState extends State<EsenseConnect> {


  @override
  TextEditingController tc = TextEditingController();
  Widget build(BuildContext context) {
    return Scaffold(

      body:

      Center(
          child:
          Padding(
            padding: EdgeInsets.all(16.0),
            child:  Column(
              children: [const Text(
                "Connect to Esense",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20.0,
                ),
              ),
                const SizedBox(
                  height: 20,
                ),
                TextField(
                  controller: tc,

                  decoration: const InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey, width: 0.0),
                    ),
                    hintText: 'Set the name for device',

                    labelText: 'Esense device',
                  ),


                ),
                // const SizedBox(
                //   height: 20,
                // ),
                // ElevatedButton(onPressed: (){
                //
                // },
                //     child: const Text("Set Esense device name")),
                const SizedBox(
                  height: 20,
                ),

                ElevatedButton(onPressed: () {
                  if (tc.text.trim() == "") {


                    const snackBar = SnackBar(
                      content: Text('Device name field cannot be empty'),
                    );

                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    tc.text="";
                  }

                  else {

                    setState(() {
                      g.devicenm=tc.text;
                      tc.text="";
                      g.pages = true;
                    });
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const HomeScreen()),
                    );

                  }

                },
                    child: const Text("GO")),
              ],
            ),
          ),



      ),
    );
  }


}