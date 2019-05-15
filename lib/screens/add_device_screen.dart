import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:mokki_app/device.dart';
import 'package:mokki_app/state_container.dart';

class AddDeviceScreen extends StatefulWidget {
  final ScanResult scanResult;

  AddDeviceScreen({Key key, @required this.scanResult});

  @override
  State<StatefulWidget> createState() =>
      AddDeviceScreenState(scanResult: scanResult);
}

class AddDeviceScreenState extends State<AddDeviceScreen> {
  final ScanResult scanResult;
  final formKey = GlobalKey<FormState>();
  final scaffoldKey = GlobalKey<ScaffoldState>();

  String name;

  AddDeviceScreenState({@required this.scanResult});

  validateAndSave() {
    final container = StateContainer.of(context);

    if (!formKey.currentState.validate()) {
      scaffoldKey.currentState
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text("Validation error")));
      return;
    }
    formKey.currentState.save();

    if (container.hasDeviceNamed(name)) { // TODO: Check also manufacturer data
      scaffoldKey.currentState
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text("You already have device called \"$name\"")));
      return;
    }

    final Device device = Device(name: name, bluetoothDevice: scanResult.device);
    container.addDevice(device);
    Navigator.pop(context, device);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: Text("New device"),
      ),
      body: Form(
        key: formKey,
        child: Container(
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              TextFormField(
                keyboardType: TextInputType.text,
                decoration: InputDecoration(labelText: "Name"),
                validator: (val) => val.length == 0 ? "Enter name" : null,
                onSaved: (val) => name = val,
              ),
              RaisedButton(
                child: Text("Save"),
                onPressed: validateAndSave,
              )
            ],
          ),
        ),
      ),
    );
  }
}
