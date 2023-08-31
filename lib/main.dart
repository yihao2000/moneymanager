import 'package:flutter/material.dart';
import 'package:moneymanager/pages/home.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:moneymanager/provider/theme_provider.dart';
import 'package:provider/provider.dart';
import 'pages/firebase_options.dart';

import 'package:firebase_core/firebase_core.dart';
import './widget_tree.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      builder: (context, _) {
        final themeProvider = Provider.of<ThemeProvider>(context, listen: true);
        return MaterialApp(
          title: 'Flutter Demo',
          themeMode: themeProvider.themeMode,
          theme: MyThemes.lightTheme,
          darkTheme: MyThemes.darkTheme,
          home: WidgetTree(),
        );
      },
    );
  }
}
