import 'package:flutter/material.dart';
import 'device.dart';

class StateContainer extends StatefulWidget {
  final Widget child;

  StateContainer({@required this.child});

  static StateContainerState of(BuildContext context) {
    return (context.inheritFromWidgetOfExactType(InheritedStateContainer)
            as InheritedStateContainer)
        .data;
  }

  @override
  createState() => new StateContainerState();
}

class StateContainerState extends State<StateContainer> {
  List<Device> devicesList;

  StateContainerState() {
    devicesList = new List<Device>();
    // TODO: import stored devices
  }

  addDevice(device) {
    devicesList.add(device);
  }

  hasDeviceNamed(String name) {
    return devicesList.where((d) => d.name == name).isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return InheritedStateContainer(
        data: this,
        child: widget.child
    );
  }
}

class InheritedStateContainer extends InheritedWidget {
  final StateContainerState data;

  InheritedStateContainer({
    Key key,
    @required this.data,
    @required Widget child,
  }) : super(key: key, child: child);

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) => true;
}
