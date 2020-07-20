import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'transponder.dart';

// TODO: Load these in via sharedPref.
final Color accentColor = Colors.orangeAccent[400];
final Brightness brightness = Brightness.light;
final Color primaryColor = Colors.purple;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final SharedPreferences sharedPreferences =
      await SharedPreferences.getInstance();
  runApp(MaterialApp(
      theme: ThemeData(
        // Define the default brightness and colors.
        brightness: Brightness.light,
        primaryColor: primaryColor,
        accentColor: accentColor,
        chipTheme: ChipThemeData.fromDefaults(
            labelStyle: TextStyle(fontWeight: FontWeight.normal),
            primaryColor: accentColor,
            secondaryColor: accentColor),

        // Define the default font family.
        //fontFamily: 'Georgia',

        // Define the default TextTheme. Use this to specify the default
        // text styling for headlines, titles, bodies of text, and more.
        textTheme: TextTheme(
          bodyText1: TextStyle(fontSize: 16.0, fontWeight: FontWeight.normal),
          headline1: TextStyle(fontSize: 36.0),
          headline2: TextStyle(fontSize: 26.0),
          headline3: TextStyle(fontSize: 20.0),
        ),
      ),
      home: Scaffold(body: Transponder(sharedPreferences: sharedPreferences))));
}
