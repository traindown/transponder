import 'dart:io';
import 'package:intl/intl.dart';

import 'package:traindown/traindown.dart';

import 'repo.dart';

class StoredSession {
  int id = 0;
  bool errored = false;
  String traindown;

  List<Movement> _movements;
  Repo _repo;
  Session _session;

  StoredSession(this.traindown);
  StoredSession.fromRepo({this.id, this.traindown, Repo repo}) : _repo = repo;
  StoredSession.blank({String unit = 'lbs'}) {
    StoredSession('@ $_defaultDateString\n# unit: $unit\n\n');
  }

  bool get isPersisted => id > 0;
  Future<bool> save() async {
    if (_repo == null) throw 'Must connect to repo first';
    errored = false;

    try {
      if (isPersisted) {
        return _repo.update(this);
      } else {
        return _repo.create(this);
      }
    } catch (_) {
      errored = true;
      return false;
    }
  }

  Session get session {
    if (_session == null) {
      _updateSession();
      _updateMovements();
    }

    return _session;
  }

  void updateTraindown(String td) {
    traindown = td;
    _updateSession();
    _updateMovements();
  }

  String _defaultDateString() {
    DateTime date = DateTime.now();
    String month = date.month.toString().padLeft(2, '0');
    String day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }

  void _updateMovements() {
    try {
      _movements = _session.movements;
      errored = false;
    } catch (_) {
      errored = true;
      _movements = [];
    }
  }

  void _updateSession() {
    Parser parser = Parser(traindown);

    try {
      _session = Session(parser.tokens());
      errored = false;
    } catch (_) {
      errored = true;
    }
  }
}

class TTSession {
  File file;
  List<Movement> _movements;
  Session _session;
  bool errored = false;

  TTSession(this.file, {bool empty = true, String unit = 'lbs'}) {
    unit ??= 'lbs';

    if (empty) {
      file.writeAsStringSync('@ $defaultDateString\n# unit: $unit\n\n');
    }
  }

  final String defaultSessionName = 'Traindown Session';

  TTSession refresh() {
    _movements = null;
    _session = null;
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

    try {
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

  // NOTE: This may raise.
  Session get session {
    if (_session != null) return _session;

    String content = file.readAsStringSync();
    Parser parser = Parser(content);

    try {
      _session = Session(parser.tokens());
      errored = false;
    } catch (e) {
      errored = true;
    }

    return _session;
  }

  double get setCount {
    return movements.fold(0, (ms, m) {
      return ms + m.performances.fold(0, (ps, p) => ps + p.sets);
    });
  }

  double get volume => movements.fold(0, (acc, cur) => acc + cur.volume);

  String get volumeString => NumberFormat.decimalPattern().format(volume);
}
