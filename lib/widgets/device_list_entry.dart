import 'package:flutter/material.dart';
import 'package:mokki_app/device.dart';

class DeviceListEntry extends StatelessWidget {
  final Device device;
  final VoidCallback onTap;

  DeviceListEntry({this.device, this.onTap});

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
      onTap: onTap, // TODO: enter Device screen on tap
    );
  }

}