import 'package:hive_flutter/adapters.dart';
import 'package:magiwatch/api/abstract_api.dart';
import 'package:magiwatch/api/magister/api.dart';
import 'package:magiwatch/api/magister/translate.dart';
import 'package:magiwatch/hive/adapters.dart';

class Magister implements Api {
  @override
  Account account;
  Magister(this.account);

  late MagisterApi api = MagisterApi(account);

  @override
  late bool isOnline = true;

  @override
  Future<void> refreshCalendarEvents(Person person) async {
    dynamic futures = await Future.wait([
      api.dio.get(
          "/api/personen/${person.id}/afspraken?tot=${DateTime.now().add(const Duration(days: 8)).toIso8601String()}&van=${DateTime.now().add(const Duration(days: -1)).toIso8601String()}"),
    ]);

    person.calendarEvents = (futures[0].data["Items"] as List)
        .map((event) => magisterCalendarEvent(event)!)
        .toList();

    for (CalendarEvent event in person.calendarEvents) {
      if (event.description != null) {
        event.description = event.description!
            .replaceAll('<br>', '\n')
            .replaceAll('</p>', '\n')
            .replaceAll('&nbsp;', ' ')
            .replaceAll(RegExp(r'<[^<>]+>'), '') //Remove remaining HTML tags
            .replaceAll(RegExp(r'^\s+|\s+$'),
                ''); //Remove whitespace at beginning and the end of the description
      }

      person.calendarEvents.sort((CalendarEvent a, CalendarEvent b) => a
          .start.millisecondsSinceEpoch
          .compareTo(b.start.millisecondsSinceEpoch));
    }

    if (account.isInBox) await account.save();
  }

  @override
  Future<void> refreshGrades(Person person) async {
    dynamic futures = await Future.wait([
      api.dio.get("/api/personen/${person.id}/cijfers/laatste?top=10&skip=0"),
    ]);

    person.grades = (futures[0].data["items"] as List)
        .map((grade) => magisterGrade(grade)!)
        .toList();

    for (Grade grade in person.grades) {
      grade.description = grade.description
          .replaceAll('<br>', '\n')
          .replaceAll('</p>', '\n')
          .replaceAll('&nbsp;', ' ')
          .replaceAll(RegExp(r'<[^<>]+>'), '') //Remove remaining HTML tags
          .replaceAll(RegExp(r'^\s+|\s+$'),
              ''); //Remove whitespace at beginning and the end of the description
    }

    person.grades.sort((Grade a, Grade b) => b.date.compareTo(a.date));

    if (account.isInBox) await account.save();
  }

  @override
  Future<void> logout() async {
    await Hive.box<Account>('accountList').clear();
  }
}
