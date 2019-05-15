import 'package:flutter/material.dart';
import 'package:mokki_app/screens/devices_list.dart';
import 'package:mokki_app/state_container.dart';

void main() {
  runApp(StateContainer(
    child: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.lightGreen,
      ),
      home: DevicesListScreen(),
    );
  }
}
