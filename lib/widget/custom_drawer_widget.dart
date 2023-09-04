import 'package:flutter/material.dart';
import 'package:moneymanager/auth.dart';
import 'package:moneymanager/widget/change_theme_button.dart';

class CustomDrawer extends StatelessWidget {
  CustomDrawer();

  Future<void> _signOut() async {
    await Auth().signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: Text(
              'Sidebar Header',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            title: ChangeThemeButtonWidget(),
          ),
          ListTile(
            title: Text('Sidebar Item 2'),
            onTap: () {
              // Handle sidebar item press
            },
          ),
          ElevatedButton(
            onPressed: _signOut,
            child: Text('Sign out'),
          ),
        ],
      ),
    );
  }
}
