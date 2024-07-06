import 'package:hive/hive.dart';
import 'package:magiwatch/api/abstract_api.dart';
import 'package:magiwatch/api/magister.dart';

part 'adapters.g.dart';

@HiveType(typeId: 1)
class Account extends HiveObject {
  @HiveField(0)
  int id;
  int get uuid => "$id${apiStorage?.baseUrl}".hashCode;
  @HiveField(1)
  ApiStorage? apiStorage = ApiStorage();
  @HiveField(2)
  late Person person;

  Api get api {
    return Magister(this);
  }

  Account({this.id = 0});

  Account get copy {
    Account objectInstance = Account(id: id);
    objectInstance.apiStorage = apiStorage;
    return objectInstance;
  }
}

@HiveType(typeId: 2)
class ApiStorage {
  @HiveField(1)
  String? accessToken;
  @HiveField(2)
  String? refreshToken;
  @HiveField(3)
  String? idToken;
  @HiveField(4)
  int? expiry;
  @HiveField(5)
  String baseUrl = "";
}

@HiveType(typeId: 3)
class Person {
  @HiveField(0)
  String firstName = "";
  @HiveField(1)
  String lastName = "";
  @HiveField(2)
  String? middleName;
  @HiveField(3)
  int id;
  int get uuid => "$id".hashCode;
  @HiveField(5)
  List<CalendarEvent> calendarEvents = [];
  @HiveField(6)
  List<Grade> grades = [];

  Person({
    required this.id,
    required this.firstName,
    this.lastName = "",
    this.middleName,
  });
}

@HiveType(typeId: 4)
class CalendarEvent {
  @HiveField(0)
  late DateTime start;
  @HiveField(1)
  late DateTime end;
  @HiveField(2)
  late int startHour;
  @HiveField(3)
  late int endHour;
  @HiveField(4)
  late List<String> subjectsNames;
  @HiveField(5)
  late String? description;
  @HiveField(6)
  late List<String> locations;
  @HiveField(7)
  late List<String> teacherNames;
  @HiveField(8)
  late bool isFinished;
  @HiveField(9)
  late int id;
  @HiveField(10)
  late CalendarEventTypes type;
  @HiveField(11)
  late int status;
  @HiveField(12)
  late String omschrijving;

  CalendarEvent(
      {required this.start,
      required this.locations,
      this.description,
      required this.end,
      required this.endHour,
      required this.id,
      required this.isFinished,
      required this.startHour,
      required this.subjectsNames,
      required this.teacherNames,
      required this.type,
      required this.status,
      required this.omschrijving});

  String infoTypeString(context, {bool short = false}) {
    switch (type) {
      case CalendarEventTypes.homework:
        return short ? "HW" : "Huiswerk";
      case CalendarEventTypes.test:
        return short ? "PW" : "Proefwerk";
      case CalendarEventTypes.exam:
        return short ? "T" : "Toets";
      case CalendarEventTypes.writtenExam:
        return short ? "SO" : "SO";
      case CalendarEventTypes.oralExam:
        return short ? "MO" : "MO";
      case CalendarEventTypes.assignment:
        return short ? "PO" : "PO";
      default:
        return "";
    }
  }
}

@HiveType(typeId: 5)
enum CalendarEventTypes {
  @HiveField(0)
  homework,
  @HiveField(1)
  test,
  @HiveField(2)
  exam,
  @HiveField(3)
  writtenExam,
  @HiveField(4)
  oralExam,
  @HiveField(5)
  assignment,
  @HiveField(6)
  other
}

@HiveType(typeId: 6)
class Grade {
  @HiveField(0)
  late DateTime date;
  @HiveField(1)
  late String grade;
  @HiveField(2)
  late String description;
  @HiveField(3)
  late String subjectName;
  @HiveField(4)
  late double factor;

  Grade(
      {required this.date,
      required this.grade,
      required this.description,
      required this.subjectName,
      required this.factor});
}
