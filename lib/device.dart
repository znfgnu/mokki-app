
import 'dart:async';

import 'package:flutter_blue/flutter_blue.dart';

class Device {
  String name;
  BluetoothDevice bluetoothDevice;

  Device({this.name, this.bluetoothDevice});

  StreamSubscription deviceConnection;
  Map<Guid, StreamSubscription> valueChangedSubscriptions = {};

}