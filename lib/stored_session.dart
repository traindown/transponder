import 'dart:io';
import 'package:intl/intl.dart';

import 'package:traindown/traindown.dart';

import 'repo.dart';

class StoredSession {
  int id = 0;
  Error error;
  String traindown;

  List<Movement> _movements;
  Repo _repo;
  Session _session;

  StoredSession(this.traindown, Repo repo) : _repo = repo;
  StoredSession.fromRepo({this.id, this.traindown, Repo repo}) : _repo = repo;
  factory StoredSession.blank(Repo repo, {String unit = 'lbs'}) {
    if (unit == null) unit = 'lbs';

    return StoredSession('@ $defaultDateString\n# unit: $unit\n\n', repo);
  }

  static String get defaultDateString {
    DateTime date = DateTime.now();
    String month = date.month.toString().padLeft(2, '0');
    String day = date.day.toString().padLeft(2, '0');

    return '${date.year}-$month-$day';
  }

  bool get errored => error != null;

  bool get isPersisted => id > 0;

  List<String> get lifts {
    if (movements.isEmpty) return ['No lifts yet'];

    return movements.map((m) => m.name).toList();
  }

  String get liftsSentence {
    String sentence = "No lifts yet";

    if (lifts.length == 1) sentence = lifts.first;
    if (lifts.length == 2) {
      sentence = '${lifts.first} and ${lifts.last}';
    }
    if (lifts.length == 3) {
      sentence =
          '${lifts.sublist(0, lifts.length - 1).join(", ")}, and ${lifts.last}';
    }
    if (lifts.length > 3) {
      sentence =
          '${lifts.sublist(0, 3).join(", ")}, and ${lifts.length - 3} others';
    }

    return "${sentence[0].toUpperCase()}${sentence.substring(1)}.";
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

  String get name => DateFormat('E, LLLL d, y').format(session.occurred);

  DateTime get occurred => session.occurred;

  Session get session {
    if (_session == null) {
      _updateSession();
      _updateMovements();
    }

    return _session;
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

  Future<bool> destroy() async {
    if (_repo == null) {
      error = StateError('Must connect to repo first');
      return false;
    }

    error = null;

    try {
      return _repo.destroy(this);
    } catch (e) {
      error = e;
      return false;
    }
  }

  Future<bool> save() async {
    if (_repo == null) {
      error = StateError('Must connect to repo first');
      return false;
    }

    _updateSession();
    _updateMovements();

    error = null;

    try {
      if (isPersisted) {
        return _repo.update(this);
      } else {
        return _repo.create(this);
      }
    } catch (e) {
      error = e;
      return false;
    }
  }

  void _updateMovements() {
    try {
      _movements = _session.movements;
    } catch (e) {
      error = e;
      _movements = [];
    }
  }

  void _updateSession() {
    Parser parser = Parser(traindown);

    try {
      _session = Session(parser.tokens());
      error = null;
    } catch (e) {
      error = e;
    }
  }
}
