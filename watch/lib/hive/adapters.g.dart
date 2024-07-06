// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'adapters.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AccountAdapter extends TypeAdapter<Account> {
  @override
  final int typeId = 1;

  @override
  Account read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Account(
      id: fields[0] as int,
    )
      ..apiStorage = fields[1] as ApiStorage?
      ..person = fields[2] as Person;
  }

  @override
  void write(BinaryWriter writer, Account obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.apiStorage)
      ..writeByte(2)
      ..write(obj.person);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AccountAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ApiStorageAdapter extends TypeAdapter<ApiStorage> {
  @override
  final int typeId = 2;

  @override
  ApiStorage read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ApiStorage()
      ..accessToken = fields[1] as String?
      ..refreshToken = fields[2] as String?
      ..idToken = fields[3] as String?
      ..expiry = fields[4] as int?
      ..baseUrl = fields[5] as String;
  }

  @override
  void write(BinaryWriter writer, ApiStorage obj) {
    writer
      ..writeByte(5)
      ..writeByte(1)
      ..write(obj.accessToken)
      ..writeByte(2)
      ..write(obj.refreshToken)
      ..writeByte(3)
      ..write(obj.idToken)
      ..writeByte(4)
      ..write(obj.expiry)
      ..writeByte(5)
      ..write(obj.baseUrl);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ApiStorageAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class PersonAdapter extends TypeAdapter<Person> {
  @override
  final int typeId = 3;

  @override
  Person read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Person(
      id: fields[3] as int,
      firstName: fields[0] as String,
      lastName: fields[1] as String,
      middleName: fields[2] as String?,
    )
      ..calendarEvents = (fields[5] as List).cast<CalendarEvent>()
      ..grades = (fields[6] as List).cast<Grade>();
  }

  @override
  void write(BinaryWriter writer, Person obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.firstName)
      ..writeByte(1)
      ..write(obj.lastName)
      ..writeByte(2)
      ..write(obj.middleName)
      ..writeByte(3)
      ..write(obj.id)
      ..writeByte(5)
      ..write(obj.calendarEvents)
      ..writeByte(6)
      ..write(obj.grades);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PersonAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class CalendarEventAdapter extends TypeAdapter<CalendarEvent> {
  @override
  final int typeId = 4;

  @override
  CalendarEvent read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CalendarEvent(
      start: fields[0] as DateTime,
      locations: (fields[6] as List).cast<String>(),
      description: fields[5] as String?,
      end: fields[1] as DateTime,
      endHour: fields[3] as int,
      id: fields[9] as int,
      isFinished: fields[8] as bool,
      startHour: fields[2] as int,
      subjectsNames: (fields[4] as List).cast<String>(),
      teacherNames: (fields[7] as List).cast<String>(),
      type: fields[10] as CalendarEventTypes,
      status: fields[11] as int,
      omschrijving: fields[12] as String,
    );
  }

  @override
  void write(BinaryWriter writer, CalendarEvent obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.start)
      ..writeByte(1)
      ..write(obj.end)
      ..writeByte(2)
      ..write(obj.startHour)
      ..writeByte(3)
      ..write(obj.endHour)
      ..writeByte(4)
      ..write(obj.subjectsNames)
      ..writeByte(5)
      ..write(obj.description)
      ..writeByte(6)
      ..write(obj.locations)
      ..writeByte(7)
      ..write(obj.teacherNames)
      ..writeByte(8)
      ..write(obj.isFinished)
      ..writeByte(9)
      ..write(obj.id)
      ..writeByte(10)
      ..write(obj.type)
      ..writeByte(11)
      ..write(obj.status)
      ..writeByte(12)
      ..write(obj.omschrijving);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CalendarEventAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class GradeAdapter extends TypeAdapter<Grade> {
  @override
  final int typeId = 6;

  @override
  Grade read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Grade(
      date: fields[0] as DateTime,
      grade: fields[1] as String,
      description: fields[2] as String,
      subjectName: fields[3] as String,
      factor: fields[4] as double,
    );
  }

  @override
  void write(BinaryWriter writer, Grade obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.date)
      ..writeByte(1)
      ..write(obj.grade)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.subjectName)
      ..writeByte(4)
      ..write(obj.factor);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GradeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class CalendarEventTypesAdapter extends TypeAdapter<CalendarEventTypes> {
  @override
  final int typeId = 5;

  @override
  CalendarEventTypes read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return CalendarEventTypes.homework;
      case 1:
        return CalendarEventTypes.test;
      case 2:
        return CalendarEventTypes.exam;
      case 3:
        return CalendarEventTypes.writtenExam;
      case 4:
        return CalendarEventTypes.oralExam;
      case 5:
        return CalendarEventTypes.assignment;
      case 6:
        return CalendarEventTypes.other;
      default:
        return CalendarEventTypes.homework;
    }
  }

  @override
  void write(BinaryWriter writer, CalendarEventTypes obj) {
    switch (obj) {
      case CalendarEventTypes.homework:
        writer.writeByte(0);
        break;
      case CalendarEventTypes.test:
        writer.writeByte(1);
        break;
      case CalendarEventTypes.exam:
        writer.writeByte(2);
        break;
      case CalendarEventTypes.writtenExam:
        writer.writeByte(3);
        break;
      case CalendarEventTypes.oralExam:
        writer.writeByte(4);
        break;
      case CalendarEventTypes.assignment:
        writer.writeByte(5);
        break;
      case CalendarEventTypes.other:
        writer.writeByte(6);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CalendarEventTypesAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
