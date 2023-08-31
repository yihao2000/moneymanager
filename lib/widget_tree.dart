import 'package:flutter/material.dart';
import 'auth.dart';
import 'pages/login.dart';
import 'pages/home.dart';

class WidgetTree extends StatefulWidget {
  const WidgetTree({super.key});

  @override
  State<WidgetTree> createState() => _WidgetTreeState();
}

class _WidgetTreeState extends State<WidgetTree> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: Auth().authStateChanges,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return MyHomePage(title: 'Flutter Demo Home Page');
          } else {
            return LoginPage();
          }
        });
  }
}
