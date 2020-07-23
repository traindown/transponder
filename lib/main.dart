import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:flutter/scheduler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'transponder.dart';

// TODO: Load these in via sharedPref.
final Color accentColor = Colors.orangeAccent[400];
final Brightness brightness =
    SchedulerBinding.instance.window.platformBrightness;
final Color primaryColor = Colors.purple;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final SharedPreferences sharedPreferences =
      await SharedPreferences.getInstance();
  runApp(MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: brightness,
        primaryColor: primaryColor,
        accentColor: accentColor,
        chipTheme: ChipThemeData.fromDefaults(
            labelStyle: TextStyle(fontWeight: FontWeight.normal),
            primaryColor: accentColor,
            secondaryColor: accentColor),
        textTheme: TextTheme(
          bodyText1: TextStyle(fontSize: 18.0, fontWeight: FontWeight.normal),
          caption: TextStyle(fontSize: 16.0),
          headline1: TextStyle(fontSize: 36.0),
          headline2: TextStyle(fontSize: 26.0),
          headline3: TextStyle(fontSize: 20.0),
        ),
      ),
      home: Scaffold(body: Transponder(sharedPreferences: sharedPreferences))));
}
