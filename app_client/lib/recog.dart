import 'package:flutter/material.dart';
import 'globals.dart' as g;

class Recog extends StatefulWidget {
  const Recog({Key? key}) : super(key: key);

  @override
  State<Recog> createState() => _RecogState();
}

class _RecogState extends State<Recog> {
  final TextEditingController _textFieldController = TextEditingController();

  // int selectedIndex = -1;

  @override
  void dispose() {
    _textFieldController.dispose();
    super.dispose();
  }

  void _addOption(String text) {

    if(text!="") {
      setState(() {
        g.options.add(text);
        g.values[text] = true;
        g.activity.add(text);
        _textFieldController.clear();
        // if (selectedIndex == -1) {
        //   g.currentActivity = text;
        // }


      });
    }
  }

  void _removeOption(String text) {
    setState(() {
      g.options.remove(text);
      g.activity.remove(text);
      // if (g.currentActivity == text) {
      //   g.currentActivity = '';
      // }
    });
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _textFieldController,
              decoration: const InputDecoration(
                labelText: 'Add Activity',
              ),
              onSubmitted: (text) {
                _addOption(text);
              },
            ),
          ),
          const SizedBox(height: 16.0),
          const Text(
            "Currently Selected Activity:",
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          Text(
            g.activity.join(', '),
            style: const TextStyle(fontWeight: FontWeight.w300),
          ),
          const SizedBox(
            height: 20,
          ),
          const Text(
            "Click the checkbox to Select Activity",
            style: TextStyle(fontWeight: FontWeight.w500),
          ),

          Expanded(
            child: ListView.builder(
              itemCount: g.options.length,
              itemBuilder: (context, index) {
                return ListTile(
                  // tileColor: selectedIndex == index ? Colors.blue : null,
                  title: Row(
                    children: [
                      Checkbox(
                        value: g.values[g.options[index]],
                        onChanged: (bool? val) {
                          setState(() {
                            if(g.values[g.options[index]] == false){
                              g.values[g.options[index]] = true;

                            }
                            else{
                              g.values[g.options[index]] = false;
                              g.activity.remove(g.options[index]);
                            }

                            if (g.values[g.options[index]] != false) {
                              // g.currentActivity = g.options[selectedIndex];

                              g.activity.add(g.options[index]);

                            }
                            // else {
                            //   g.currentActivity = '';
                            // }
                          });
                        },
                      ),
                      Text(g.options[index]),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      _removeOption(g.options[index]);
                    },
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16.0),
          // ElevatedButton(
          //   child: const Text('Generate CSV'),
          //   onPressed: _csvoption,
          // ),
        ],
      ),
    );
  }
}
