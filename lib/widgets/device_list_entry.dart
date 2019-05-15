import 'package:flutter/material.dart';
import 'package:mokki_app/device.dart';

class DeviceListEntry extends StatelessWidget {
  final Device device;

  DeviceListEntry({this.device});

  Widget build(BuildContext context) {
    return ListTile(
      title: Row(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(Icons.gamepad, size: 30.0,),
          ),
          Text(device.name),
        ],
      ),
      onTap: () {}, // TODO: enter Device screen on tap
    );
  }

}