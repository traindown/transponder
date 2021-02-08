import 'dart:io';
import 'package:intl/intl.dart';

import 'package:traindown/traindown.dart';

class TTSession {
  File file;
  List<Movement> _movements;

  TTSession(this.file, {bool empty = true, String unit = 'lbs'}) {
    unit ??= 'lbs';

    if (empty) {
      file.writeAsStringSync('@ $defaultDateString\n# unit: $unit\n\n');
    }
  }

  final String defaultSessionName = 'Traindown Session';

  TTSession flushCache() {
    _movements = null;
    return this;
  }

  bool teardown() {
    try {
      file.deleteSync();
    } catch (e) {
      return false;
    }
    return true;
  }

  // TODO: Intl
  String get defaultDateString {
    DateTime date = DateTime.now();
    String month = date.month.toString().padLeft(2, '0');
    String day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }

  String get filename => file.path.split('/').last;

  List<String> get lifts {
    if (movements.isEmpty) return ['No lifts yet'];

    return movements.map((m) => m.name).toList();
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

  List<Movement> get movements {
    if (_movements != null) return _movements;

    String content = file.readAsStringSync();
    Parser parser = Parser(content);
    Session session;
    try {
      session = Session(parser.tokens());
      _movements = session.movements;

      return _movements;
    } catch (_) {
      return [];
    }
  }

  String get name {
    if (filename == null) return defaultSessionName;

    String dateString = filename.split('.').first;
    if (dateString == null) return defaultSessionName;

    DateTime date = DateTime.tryParse(dateString);
    if (date == null) return defaultSessionName;

    return DateFormat('E, LLLL d, y').format(date);
  }

  double get repCount {
    return movements.fold(0, (ms, m) {
      return ms + m.performances.fold(0, (ps, p) => ps + (p.sets * p.reps));
    });
  }

  double get setCount {
    return movements.fold(0, (ms, m) {
      return ms + m.performances.fold(0, (ps, p) => ps + p.sets);
    });
  }

  double get volume => movements.fold(0, (acc, cur) => acc + cur.volume);

  String get volumeString => NumberFormat.decimalPattern().format(volume);
}
