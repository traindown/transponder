import 'dart:io';

import 'package:traindown/traindown.dart';

class Session {
  File file;

  Session(this.file, {bool copy = false}) {
    if (!copy) {
      file.writeAsString('@ $defaultDateString\n# unit: lbs\n\n');
    }
  }

  final String defaultSessionName = 'Traindown Session';

  bool teardown() {
    try {
      file.deleteSync();
    } catch (e) {
      return false;
    }
    return true;
  }

  String get defaultDateString {
    DateTime date = DateTime.now();
    String month = date.month.toString().padLeft(2, '0');
    String day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }

  String get filename => file.path.split('/').last;

  List<String> get lifts {
    Parser parser = Parser.for_file(file.path);
    try {
      parser.call();
    } catch (_) {
      return ['No lifts yet'];
    }

    if (parser.movements.isEmpty) return ['No lifts yet'];

    return parser.movements.map((m) => m.name).toList();
  }

  String get liftsSentence {
    if (lifts.length == 1) return lifts.first;
    if (lifts.length == 2) {
      return '${lifts.first} and ${lifts.last}';
    }
    if (lifts.length == 3) {
      return '${lifts.sublist(0, lifts.length - 1).join(", ")}, and ${lifts.last}';
    }

    return '${lifts.sublist(0, 3).join(", ")}, and ${lifts.length - 3} others';
  }

  String get name {
    if (filename == null) return defaultSessionName;

    String dateString = filename.split('.').first;
    if (dateString == null) return defaultSessionName;

    DateTime date = DateTime.tryParse(dateString);
    if (date == null) return defaultSessionName;

    String dow = 'Unknown day';
    switch (date.weekday) {
      case DateTime.sunday:
        dow = 'Sunday';
        break;
      case DateTime.monday:
        dow = 'Monday';
        break;
      case DateTime.tuesday:
        dow = 'Tuesday';
        break;
      case DateTime.wednesday:
        dow = 'Wednesday';
        break;
      case DateTime.thursday:
        dow = 'Thursday';
        break;
      case DateTime.friday:
        dow = 'Friday';
        break;
      case DateTime.saturday:
        dow = 'Saturday';
        break;
    }

    return '${dow} ${date.month}/${date.day}/${date.year}';
  }
}
