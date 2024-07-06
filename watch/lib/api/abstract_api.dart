import 'package:magiwatch/hive/adapters.dart';

abstract class Api {
  Account account;
  Api(this.account);
  late bool isOnline;

  Future<void> refreshCalendarEvents(Person person) async {}
  Future<void> refreshGrades(Person person) async {}
  Future<void> logout() async {}
}
