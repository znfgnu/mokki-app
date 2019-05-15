import 'dart:async';
import 'dart:math';
import 'dart:typed_data';

import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:mokki_app/device.dart';

import 'package:flutter/services.dart' show ByteData, rootBundle;


class DeviceDashboardScreen extends StatefulWidget {
  final Device device;

  DeviceDashboardScreen({@required this.device});

  @override
  createState() => DeviceDashboardScreenState(device: device);
}

class DeviceDashboardScreenState extends State<DeviceDashboardScreen> {
  final Device device;

  Stream<List<int>> characteristicChangeStream;

  DeviceDashboardScreenState({@required this.device});

  final List<Tab> myTabs = <Tab>[
    Tab(text: 'INFO'),
    Tab(text: 'COMMANDS'),
    Tab(text: 'ROMS'),
  ];

  _buildInfo() {
    return Center(
      child: MaterialButton(
        child: Text("Blink upload"),
        onPressed: _blinkUpload,
      ),
    );
  }

  _buildCommands() {
    return Center(
      child: MaterialButton(
        child: Text("Run program"),
        onPressed: () {
          _runCmd(1, true);
        },
      ),
    );
  }

  _buildRoms() {
    return Center(
      child: MaterialButton(
        child: Text("Reset device"),
        onPressed: () {
          _runCmd(0, false);
        },
      ),
    );
  }

  _buildTabs() {
    return <Widget>[
      _buildInfo(),
      _buildCommands(),
      _buildRoms()
    ];
  }

  _buildFloatingActionButton() {
    if (isConnected) {
      return FloatingActionButton.extended(
        label: Text("Disconnect"),
        icon: Icon(Icons.bluetooth),
        backgroundColor: Colors.red,
        onPressed: _disconnect,
      );
    } else {
      return FloatingActionButton.extended(
        label: Text("Connect"),
        icon: Icon(Icons.bluetooth),
        backgroundColor: Colors.lightGreenAccent,
        onPressed: _connect,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: myTabs.length,
      child: Scaffold(
        appBar: AppBar(
          title: Text(device.name),
          bottom: TabBar(
            tabs: myTabs,
          ),
        ),
        body: TabBarView(
          children: _buildTabs()
        ),
        floatingActionButton: _buildFloatingActionButton(),
      ),
    );
  }

  // BT
  FlutterBlue _flutterBlue = FlutterBlue.instance;
  StreamSubscription _stateSubscription;
  BluetoothState state = BluetoothState.unknown;

  bool isConnected = false;
  StreamSubscription deviceConnection;
  StreamSubscription deviceStateSubscription;
  List<BluetoothService> services = new List();
//  Map<Guid, StreamSubscription> valueChangedSubscriptions = {};
  BluetoothDeviceState deviceState = BluetoothDeviceState.disconnected;
  BluetoothCharacteristic characteristic;

  // Characteristic change
  StreamSubscription characteristicChangeSubscription;

  @override
  void dispose() {
    _stateSubscription?.cancel();
    _stateSubscription = null;
    deviceConnection?.cancel();
    deviceConnection = null;
    super.dispose();
  }


  @override
  void initState() {
    super.initState();
    // Immediately get the state of FlutterBlue
    _flutterBlue.state.then((s) {
      setState(() {
        state = s;
      });
    });
    // Subscribe to state changes
    _stateSubscription = _flutterBlue.onStateChanged().listen((s) {
      setState(() {
        state = s;
      });
    });

//    _connect();
  }

  _blinkUpload() async {
    var queue = StreamQueue<List<int>>(characteristicChangeStream);
    ByteData program = await rootBundle.load("images/blink.bin");
    List<int> response;

    for (var i=0; i<(program.lengthInBytes+15)/16; i++) {
      var packet = Uint8List(19).buffer;
      var bdata = new ByteData.view(packet);
      bdata.setUint8(0, 0x03);
      bdata.setUint16(1, i, Endian.little);
      for (int j=0; j<16; ++j) {
        var idx = i*16+j;
        bdata.setUint8(3+j, idx < program.lengthInBytes ? program.getUint8(idx) : 0x00);
      }
      // Send programming request
      _writeCharacteristic(packet.asUint8List());
      response = await queue.next;
      print(response);
    }
  }

  _runCmd(int cmdNo, bool waitForResponse) async {
    var queue = StreamQueue<List<int>>(characteristicChangeStream);
    List<int> response;

    var packet = Uint8List(3).buffer;
    var bdata = new ByteData.view(packet);
    bdata.setUint8(0, 0x05);
    bdata.setUint16(1, cmdNo, Endian.little);

    _writeCharacteristic(packet.asUint8List());

    if (waitForResponse) {
      response = await queue.next;
      print(response);
    }

  }

  _setNotification() async {
    await device.bluetoothDevice.setNotifyValue(characteristic, true);
    // ignore: cancel_subscriptions
    characteristicChangeStream = device.bluetoothDevice.onValueChanged(characteristic);
    
    characteristicChangeSubscription = characteristicChangeStream.listen((d) {
      setState(() {
        print('onValueChanged $d');
      });
    });
    setState(() {});
  }

  _writeCharacteristic(List<int> val) async {
    await device.bluetoothDevice.writeCharacteristic(characteristic, val,
        type: CharacteristicWriteType.withResponse);
  }

  _connect() async {
    isConnected = true;
    // Connect to device
    deviceConnection = _flutterBlue
        .connect(device.bluetoothDevice, timeout: const Duration(seconds: 4))
        .listen(
      null,
      onDone: _disconnect,
    );

    // Update the connection state immediately
    device.bluetoothDevice.state.then((s) {
      setState(() {
        deviceState = s;
      });
    });

    // Subscribe to connection changes
    deviceStateSubscription = device.bluetoothDevice.onStateChanged().listen((s) {
      setState(() {
        deviceState = s;
      });
      if (s == BluetoothDeviceState.connected) {
        device.bluetoothDevice.discoverServices().then((s) {
          setState(() {
            characteristic = s[0].characteristics[0];
            _setNotification();
          });
        });
      }
    });
  }

  _disconnect() {
    // Remove all value changed listeners
//    valueChangedSubscriptions.forEach((uuid, sub) => sub.cancel());
//    valueChangedSubscriptions.clear();
    deviceStateSubscription?.cancel();
    deviceStateSubscription = null;
    deviceConnection?.cancel();
    deviceConnection = null;
    setState(() {
      isConnected = false;
      characteristic = null;
    });
  }

}
