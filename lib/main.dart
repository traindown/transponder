import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:flutter/scheduler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'repo.dart';
import 'stored_session.dart';
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

  Directory directory = await getApplicationDocumentsDirectory();
  // NOTE: For local debugging:
  //final Repo repo = Repo(directory.path, debug: true);
  final Repo repo = Repo(directory.path);

  await repo.start();
  repo.log('Started: ${repo.started}', subject: 'Repo');

  await _initAppData(repo);

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
      home: Scaffold(
          body:
              Transponder(repo: repo, sharedPreferences: sharedPreferences))));
}

Future<void> _initAppData(Repo repo) async {
  // TODO: Constants file
  const migrationName = 'files to db';

  repo.log('Initializing', subject: 'Application');

  bool canMigrate = await repo.canMigrate(migrationName);

  if (canMigrate) {
    await _migrateFilesToDb(repo);
    await repo.markMigration(migrationName);
  } else {
    await repo.tidy();
  }

  repo.log('Initialized', subject: 'Application');
}

Future<void> _migrateFilesToDb(Repo repo) async {
  repo.log('Migrating legacy files', subject: 'Application');

  int fileCount = 0;
  int migratedFileCount = 0;

  Directory directory = await getApplicationDocumentsDirectory();
  List<FileSystemEntity> files = directory.listSync();

  if (files.isNotEmpty) {
    for (File file in files) {
      if (file is File && file.path.endsWith('.traindown')) {
        fileCount++;
        bool result = await repo.upsertFileSession(file.readAsStringSync());
        if (result) migratedFileCount++;
      }
    }
  }

  repo.log('${fileCount} legacy files', subject: 'Application');
  repo.log('Migrated $migratedFileCount files', subject: 'Application');
}
