import 'package:flutter/material.dart';
import 'package:mokki_app/app_drawer.dart';
import 'package:mokki_app/device.dart';
import 'package:mokki_app/screens/device_dashboard_screen.dart';
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

  _openScanningScreen(BuildContext context) async {
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

  _openDeviceDashboard(Device device) {
    Navigator.of(context).push(new MaterialPageRoute(
        builder: (ctx) => DeviceDashboardScreen(
              device: device,
            )));
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
              onTap: () {
                final Device device = devicesList[idx];
                _openDeviceDashboard(device);
              },
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
          _openScanningScreen(context);
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
