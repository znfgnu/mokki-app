import 'package:flutter/material.dart';

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Drawer(
      child: ListView(
        children: <Widget>[
          DrawerHeader(
            child: Text("Mokki", style: Theme.of(context).textTheme.display1,),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.lightGreen,
                  Colors.white,
                ],
              )
            ),
          ),
          ListTile(
            title: Text("My devices"),
            onTap: () {},
          ),
          ListTile(
            title: Text("My ROMs"),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
