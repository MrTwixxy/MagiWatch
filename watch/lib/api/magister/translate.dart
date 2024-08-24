import 'dart:convert';

import 'package:magiwatch/extensions.dart';
import 'package:magiwatch/hive/adapters.dart';

CalendarEvent? magisterCalendarEvent([Map? event]) {
  if (event != null) {
    //MagIcal personal changes
    if (event["Aantekening"] != null &&
        (event["Aantekening"] as String).isBase64) {
      try {
        Map<String, dynamic> magIcal =
            jsonDecode(utf8.decode(base64.decode(event["Aantekening"])));
        event["Status"] = magIcal["Status"] != null &&
                magIcal["originalStatus"] == event["Status"]
            ? num.parse(magIcal["Status"])
            : event["Status"];
        event["InfoType"] = magIcal["InfoType"] != null &&
                magIcal["originalInfoType"] == event["InfoType"]
            ? num.parse(magIcal["InfoType"])
            : event["InfoType"];
        event["Lokalen"] = magIcal["Lokatie"] != null &&
                magIcal["originalLokatie"] ==
                    event["Lokalen"]
                        .map<String>((lokaal) => lokaal["Naam"].toString())
                        .toList()
                        .first
            ? [magIcal["Lokatie"]]
            : event["Lokalen"];
        event["Inhoud"] = magIcal["Inhoud"] != null &&
                magIcal["originalInhoud"] == event["Inhoud"]
            ? magIcal["Inhoud"]
            : event["Inhoud"];
        // ignore: empty_catches
      } catch (e) {
        //Whoops, no magIcal was used for this event...
      }
    }

    CalendarEventTypes generateType(status, infoType) {
      if (status != 4 && status != 5) {
        switch (infoType) {
          case 1:
            return CalendarEventTypes.homework;
          case 2:
            return CalendarEventTypes.test;
          case 3:
            return CalendarEventTypes.exam;
          case 4:
            return CalendarEventTypes.writtenExam;
          case 5:
            return CalendarEventTypes.oralExam;
          default:
            return CalendarEventTypes.other;
        }
      } else {
        return CalendarEventTypes.other;
      }
    }

    return CalendarEvent(
        omschrijving: event["Omschrijving"],
        status: event["Status"],
        // locations: event["Lokalen"]
        //     .map<String>((lokaal) => lokaal["Naam"].toString())
        //     .toList(),
        locations: event["Lokalen"]
            .map<String>((lokaal) => lokaal["Naam"].toString())
            .toList()?[event["Lokatie"]],
        description: event["Inhoud"] ?? "",
        end: DateTime.parse(event["Einde"] ?? "1970-01-01T00:00:00.0000000Z")
            .toUtc(),
        endHour: event["LesuurTotMet"] ?? 0,
        id: event["Id"],
        isFinished: event["Afgerond"],
        start: DateTime.parse(event["Start"] ?? "1970-01-01T00:00:00.0000000Z")
            .toUtc(),
        startHour: event["LesuurVan"] ?? event["LesuurTotMet"] ?? 0,
        subjectsNames: event["Vakken"].isNotEmpty
            ? event["Vakken"]
                .map<String>((vak) => vak["Naam"].toString().capitalize())
                .toList()
            : [event["Omschrijving"].split(" - ")[0]],
        teacherNames: event["Docenten"]
            .map<String>((teacher) => teacher["Naam"].toString())
            .toList(),
        type: generateType(event["Status"], event["InfoType"]));
  }
  return null;
}

Grade? magisterGrade([Map? grade]) {
  if (grade != null) {
    return Grade(
        description: grade["omschrijving"],
        date: DateTime.parse(
            grade["ingevoerdOp"] ?? "1970-01-01T00:00:00.0000000Z"),
        factor: grade["weegfactor"],
        grade: grade["waarde"],
        subjectName: grade["vak"]["omschrijving"]);
  }
  return null;
}
