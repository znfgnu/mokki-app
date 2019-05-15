import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mokki_app/device.dart';
import 'package:mokki_app/screens/add_device_screen.dart';
import 'package:mokki_app/state_container.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:mokki_app/widgets/scan_result_tile.dart';

class ScanningScreen extends StatefulWidget {
  @override
  createState() => ScanningScreenState();
}

class ScanningScreenState extends State<ScanningScreen> {
  FlutterBlue _flutterBlue = FlutterBlue.instance;
  StreamSubscription _scanSubscription;
  Map<DeviceIdentifier, ScanResult> scanResults = new Map();
  bool isScanning = false;

  StreamSubscription _stateSubscription;
  BluetoothState state = BluetoothState.unknown;

  initState() {
    super.initState();
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
    _startScan();
  }

  Widget buildDevicesList() {
    if (isScanning) {
      return Container(
        alignment: Alignment.center,
        child: Text("Scanning for nearby devices..."),
      );
    } else {
      return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: _buildScanResultTiles(),
      );
    }
  }

  _isScanResultMokki(ScanResult scanResult) {
    return scanResult.advertisementData.manufacturerData.containsKey(21852);
  }

  _startScan() {
    _scanSubscription = _flutterBlue
        .scan(
      timeout: const Duration(seconds: 5),
    )
        .listen((scanResult) {
      print('localName: ${scanResult.advertisementData.localName}');
      print(
          'manufacturerData: ${scanResult.advertisementData.manufacturerData}');
      print('serviceData: ${scanResult.advertisementData.serviceData}');
      if (_isScanResultMokki(scanResult)) {
        setState(() {
          scanResults[scanResult.device.id] = scanResult;
        });
      }
    }, onDone: _stopScan);
    setState(() {
      isScanning = true;
    });
  }

  _stopScan() {
    _scanSubscription?.cancel();
    _scanSubscription = null;
    setState(() {
      isScanning = false;
    });
  }

  _openAddDeviceScreen(ScanResult scanResult) async {
    final Device device = await Navigator.of(context).push(
        new MaterialPageRoute(
          fullscreenDialog: true,
          builder: (context) => new AddDeviceScreen(scanResult: scanResult),
        ));

    if (device != null) {
      Navigator.pop(context, device);
    }
  }

  _buildScanResultTiles() {
    return scanResults.values
        .map((r) =>
        ScanResultTile(
            result: r,
            onTap: () => _openAddDeviceScreen(r),
    )).
    toList
    (
    );
  }

  _buildScanningButton() {
    if (state != BluetoothState.on) {
      return null;
    }
    if (isScanning) {
      return new FloatingActionButton(
        child: new Icon(Icons.stop),
        onPressed: _stopScan,
        backgroundColor: Colors.red,
      );
    } else {
      return new FloatingActionButton(
          child: new Icon(Icons.refresh), onPressed: _startScan);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add device"),
      ),
      body: buildDevicesList(),
      floatingActionButton: _buildScanningButton(),
    );
  }

//  String name;
//  final formKey = GlobalKey<FormState>();
//
//  validateAndSave() {
//    final container = StateContainer.of(context);
//    if (formKey.currentState.validate()) {
//      formKey.currentState.save();
//      final device = Device(name: name);
//      container.addDevice(device);
//      Navigator.pop(context, device);
//    } else {
//      print("Validation error");
//    }
//  }
//
//  @override
//  Widget build(BuildContext context) {
//    return Scaffold(
//      appBar: AppBar(
//        title: Text("Add device"),
//      ),
//      body: Form(
//        key: formKey,
//        child: Column(
//          children: <Widget>[
//            TextFormField(
//              keyboardType: TextInputType.text,
//              decoration: InputDecoration(labelText: "Name"),
//              validator: (val) => val.length == 0 ? "Enter name" : null,
//              onSaved: (val) => name = val,
//            ),
//            RaisedButton(
//              child: Text("Save"),
//              onPressed: validateAndSave,
//            )
//          ],
//        )
//      ),
//    );
//  }

}
