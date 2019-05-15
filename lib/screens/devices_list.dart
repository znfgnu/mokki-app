import 'package:flutter/material.dart';
import 'package:mokki_app/app_drawer.dart';
import 'package:mokki_app/device.dart';
import 'package:mokki_app/screens/scanning_screen.dart';
import 'package:mokki_app/state_container.dart';
import 'package:mokki_app/widgets/device_list_entry.dart';

class DevicesListScreen extends StatefulWidget {
  @override
  createState() => DevicesListScreenState();
}

class DevicesListScreenState extends State<DevicesListScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  List<Device> devicesList;

  openScanningScreen(BuildContext context) async {
    final Device result = await Navigator.of(context).push(MaterialPageRoute(
        fullscreenDialog: true, builder: (context) => new ScanningScreen()));

    _scaffoldKey.currentState
      ..removeCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(result != null
            ? "Successfully added ${result.name}."
            : "Device not added"),
      ));
  }

  Widget buildDevicesList() {
    if (devicesList.isEmpty) {
      return Container(
        child: Text("You don't have any devices yet."),
        alignment: Alignment.center,
      );
    } else {
      return ListView.builder(
        itemCount: devicesList.length,
        itemBuilder: (ctx, idx) => DeviceListEntry(
              device: devicesList[idx],
            ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final container = StateContainer.of(context);
    devicesList = container.devicesList;

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text("My devices"),
      ),
      body: buildDevicesList(),
      drawer: AppDrawer(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          openScanningScreen(context);
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
