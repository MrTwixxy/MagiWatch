import 'dart:convert';

import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_wear_os_connectivity/flutter_wear_os_connectivity.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:magiwatch/api/magister/api.dart';
import 'package:magiwatch/hive/adapters.dart';
import 'package:rotary_scrollbar/rotary_scrollbar.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(AccountAdapter());
  if (!Hive.isAdapterRegistered(2)) Hive.registerAdapter(ApiStorageAdapter());
  if (!Hive.isAdapterRegistered(3)) Hive.registerAdapter(PersonAdapter());
  if (!Hive.isAdapterRegistered(4)) {
    Hive.registerAdapter(CalendarEventAdapter());
  }
  if (!Hive.isAdapterRegistered(5)) {
    Hive.registerAdapter(CalendarEventTypesAdapter());
  }
  if (!Hive.isAdapterRegistered(6)) {
    Hive.registerAdapter(GradeAdapter());
  }

  await Hive.openBox<Account>('accountList');
  // await Hive.box<Account>("accountList").clear();

  runApp(const MainApp());
}

final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(
      builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
        ColorScheme lightColorScheme;
        ColorScheme darkColorScheme;
        if (lightDynamic != null && darkDynamic != null) {
          //Using Material You colors set by Android S+ devices
          lightColorScheme = lightDynamic.harmonized();
          darkColorScheme = darkDynamic.harmonized();
        } else {
          //Not using Material You colors set by Android S+ devices
          lightColorScheme = ColorScheme.fromSeed(
            seedColor: Color(const Color.fromARGB(255, 244, 123, 3).value),
          ).harmonized();
          darkColorScheme = ColorScheme.fromSeed(
            seedColor: Color(const Color.fromARGB(255, 244, 123, 3).value),
            brightness: Brightness.dark,
          ).harmonized();
        }

        ThemeData theme({bool useDarkMode = true}) {
          ColorScheme colorScheme =
              useDarkMode ? darkColorScheme : lightColorScheme;
          return ThemeData(
              brightness: useDarkMode ? Brightness.dark : Brightness.light,
              colorScheme: colorScheme,
              platform: TargetPlatform.android,
              useMaterial3: true,
              tooltipTheme: TooltipThemeData(
                textStyle: TextStyle(color: colorScheme.onBackground),
                decoration: BoxDecoration(
                  border: Border.fromBorderSide(
                      BorderSide(color: colorScheme.outline, width: 1)),
                  color: colorScheme.background,
                  borderRadius: const BorderRadius.all(Radius.circular(4)),
                ),
              ),
              badgeTheme: BadgeThemeData(
                  textColor: colorScheme.onPrimaryContainer,
                  backgroundColor: colorScheme.primaryContainer),
              snackBarTheme: SnackBarThemeData(
                  backgroundColor: colorScheme.surfaceVariant,
                  closeIconColor: colorScheme.onSurfaceVariant,
                  contentTextStyle:
                      TextStyle(color: colorScheme.onSurfaceVariant),
                  actionBackgroundColor: colorScheme.primary));
        }

        return MaterialApp(
          navigatorKey: navigatorKey,
          scaffoldMessengerKey: rootScaffoldMessengerKey,
          title: 'MagiWatch',
          debugShowCheckedModeBanner: false,
          theme: theme(),
          home: const MagiWatch(),
        );
      },
    );
  }
}

class MagiWatch extends StatefulWidget {
  const MagiWatch({super.key});

  @override
  State<StatefulWidget> createState() => MagiWatchState();
  static MagiWatchState of(BuildContext context) =>
      context.findAncestorStateOfType<MagiWatchState>()!;
}

class MagiWatchState extends State<MagiWatch> {
  late FlutterWearOsConnectivity _flutterWearOsConnectivity;

  Account? account = Hive.box<Account>("accountList").isNotEmpty
      ? Hive.box<Account>("accountList").values.first
      : null;

  final listViewScrollController = ScrollController();

  final screenWidth =
      WidgetsBinding.instance.platformDispatcher.views.first.physicalSize.width;
  final screenHeight = WidgetsBinding
      .instance.platformDispatcher.views.first.physicalSize.height;

  int index = 0;

  bool loading = false;

  @override
  void initState() {
    super.initState();
    if (account == null) {
      connect();
    }
  }

  Future<void> connect() async {
    _flutterWearOsConnectivity = FlutterWearOsConnectivity();
    _flutterWearOsConnectivity.configureWearableAPI();

    _flutterWearOsConnectivity
        .messageReceived(
            pathURI: Uri(scheme: "wear", host: "*", path: "/magisterAuth"))
        .listen((message) async {
      Map<dynamic, dynamic>? tokenSet =
          await getTokenSet(utf8.decode(message.data));

      if (tokenSet == null) return;

      setState(() {
        loading = true;
      });

      account = await getAccount(tokenSet);
      setState(() {
        loading = false;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();

    listViewScrollController.dispose();
    _flutterWearOsConnectivity.dispose();
  }

  String formatDate(DateTime date) {
    // Get the day of the week
    int day = date.day;
    int weekday = date.weekday;
    String getDayName(int day) {
      switch (day) {
        case 1:
          return "Maandag";
        case 2:
          return "Dinsdag";
        case 3:
          return "Woensdag";
        case 4:
          return "Donderdag";
        case 5:
          return "Vrijdag";
        case 6:
          return "Zaterdag";
        case 7:
          return "Zondag";
      }
      return "";
    }

    String dayName = getDayName(weekday);
    // Combine the formatted strings
    String formattedDate = '$dayName $day/${date.month}';

    return formattedDate;
  }

  Widget listItem(CalendarEvent event, int length) {
    if (length == 0) {
      return const SizedBox(
        width: 0,
        height: 0,
      );
    }
    return Center(
        child: Padding(
            padding: EdgeInsets.only(
                top: 2,
                bottom: 2,
                left: screenWidth * 0.03,
                right: screenWidth * 0.03),
            child: GestureDetector(
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            HomeworkScreen(text: event.description ?? ""))),
                child: Container(
                    decoration: BoxDecoration(
                        color: ElevationOverlay.applySurfaceTint(
                            Theme.of(context).colorScheme.background,
                            Theme.of(context).colorScheme.surfaceTint,
                            1),
                        borderRadius: BorderRadius.circular(20)),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: event.status == 4 ||
                                  event.status == 5
                              ? Theme.of(context).colorScheme.errorContainer
                              : Theme.of(context).colorScheme.primaryContainer,
                          child: Center(
                            child: Text(event.startHour.toString()),
                          ),
                        ),
                        Flexible(
                            child: Padding(
                                padding: const EdgeInsets.only(left: 5),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      event.omschrijving,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      event.locations.toString(),
                                      overflow: TextOverflow.ellipsis,
                                    )
                                  ],
                                )))
                      ],
                    )))));
  }

  Widget footer() {
    return Padding(
        padding: EdgeInsets.only(bottom: screenHeight * 0.05, top: 10),
        child: Column(children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(40),
                      color: index > 0
                          ? Theme.of(context).colorScheme.secondaryContainer
                          : Theme.of(context).colorScheme.background),
                  child: IconButton(
                      onPressed: () {
                        if (index > 0) {
                          setState(() {
                            index--;
                          });
                        }
                      },
                      icon: const Icon(Icons.arrow_back))),
              const SizedBox(width: 10),
              Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(40),
                      color: index != 0
                          ? Theme.of(context).colorScheme.secondaryContainer
                          : Theme.of(context).colorScheme.background),
                  child: IconButton(
                      onPressed: () {
                        if (index > 0) {
                          setState(() {
                            index = 0;
                          });
                        }
                      },
                      icon: const Icon(Icons.subdirectory_arrow_left))),
              const SizedBox(width: 10),
              Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(40),
                      color: index < 7
                          ? Theme.of(context).colorScheme.secondaryContainer
                          : Theme.of(context).colorScheme.background),
                  child: IconButton(
                      onPressed: () {
                        if (index < 7) {
                          setState(() {
                            index++;
                          });
                        }
                      },
                      icon: const Icon(Icons.arrow_forward))),
            ],
          ),
          const SizedBox(height: 10),
          Padding(
              padding: EdgeInsets.only(
                top: 5,
                bottom: 5,
                left: screenWidth * 0.075,
                right: screenWidth * 0.075,
              ),
              child: FilledButton(
                  style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(
                          Theme.of(context).colorScheme.secondaryContainer)),
                  onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const GradesScreen())),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.menu,
                          color: Theme.of(context).colorScheme.onBackground),
                      const SizedBox(width: 10),
                      Text(
                        "Cijfers",
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.onBackground),
                      )
                    ],
                  )))
        ]));
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return Scaffold(
          body: account != null
              ? RefreshIndicator(
                  child: Center(
                      child: RotaryScrollWrapper(
                          rotaryScrollbar: RotaryScrollbar(
                              controller: listViewScrollController),
                          child: ListView.builder(
                              controller: listViewScrollController,
                              itemCount: account!.person.calendarEvents
                                      .where((x) => DateUtils.isSameDay(
                                          x.start,
                                          DateTime.now()
                                              .add(Duration(days: index))))
                                      .isEmpty
                                  ? 1
                                  : account!.person.calendarEvents
                                      .where((x) => DateUtils.isSameDay(
                                          x.start,
                                          DateTime.now()
                                              .add(Duration(days: index))))
                                      .length,
                              physics: const AlwaysScrollableScrollPhysics(),
                              itemBuilder: (context, ind) {
                                int length = account!.person.calendarEvents
                                    .where((x) => DateUtils.isSameDay(
                                        x.start,
                                        DateTime.now()
                                            .add(Duration(days: index))))
                                    .length;
                                List<CalendarEvent> events = account!
                                    .person.calendarEvents
                                    .where((x) => DateUtils.isSameDay(
                                        x.start,
                                        DateTime.now()
                                            .add(Duration(days: index))))
                                    .toList();

                                return length == 0
                                    ? Column(children: [
                                        header(screenHeight, account!,
                                            formatDate, index),
                                        Padding(
                                            padding: EdgeInsets.only(
                                                top: 5,
                                                bottom: 5,
                                                left: screenWidth * 0.03,
                                                right: screenWidth * 0.03),
                                            child:
                                                const Text("Geen Resultaten")),
                                        footer()
                                      ])
                                    : length == 1
                                        ? Column(children: [
                                            header(screenHeight, account!,
                                                formatDate, index),
                                            listItem(events[ind], length),
                                            footer()
                                          ])
                                        : ind == 0
                                            ? Column(children: [
                                                header(screenHeight, account!,
                                                    formatDate, index),
                                                listItem(events[ind], length)
                                              ])
                                            : ind == length - 1
                                                ? Column(
                                                    children: [
                                                      listItem(
                                                          events[ind], length),
                                                      footer()
                                                    ],
                                                  )
                                                : listItem(events[ind], length);
                              }))),
                  onRefresh: () async {
                    await account!.api.refreshCalendarEvents(account!.person);
                    setState(() {});
                  })
              : loading
                  ? const Center(child: CircularProgressIndicator())
                  : const Center(
                      child: Text(
                      "Login met MagiWatch Connect",
                      textAlign: TextAlign.center,
                    )));
    });
  }
}

Widget header(double screenHeight, Account account,
    [Function? formatDate, int index = 0, bool grades = false]) {
  return Padding(
      padding: EdgeInsets.only(top: screenHeight * 0.05, bottom: 10),
      child: Column(
        children: [
          const Text(
            "MagiWatch",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          Text(account.person.middleName != null
              ? "${account.person.firstName} ${account.person.middleName} ${account.person.lastName}"
              : "${account.person.firstName} ${account.person.lastName}"),
          Text(grades
              ? "Laatste Cijfers"
              : formatDate!(DateTime.now().add(Duration(days: index))))
        ],
      ));
}

class GradesScreen extends StatefulWidget {
  const GradesScreen({super.key});

  @override
  State<StatefulWidget> createState() => _GradesScreen();
}

class _GradesScreen extends State<GradesScreen> {
  final screenWidth =
      WidgetsBinding.instance.platformDispatcher.views.first.physicalSize.width;
  final screenHeight = WidgetsBinding
      .instance.platformDispatcher.views.first.physicalSize.height;

  final Account? account = Hive.box<Account>("accountList").values.first;

  final gradeViewScrollController = ScrollController();

  @override
  void dispose() {
    super.dispose();

    gradeViewScrollController.dispose();
  }

  Widget gradesFooter() {
    return Padding(
        padding: EdgeInsets.only(bottom: screenHeight * 0.05, top: 10),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(40),
                  color: Theme.of(context).colorScheme.secondaryContainer),
              child: IconButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(Icons.arrow_back))),
          const SizedBox(width: 10),
          Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(40),
                  color: Theme.of(context).colorScheme.secondaryContainer),
              child: IconButton(
                  onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const LogoutScreen())),
                  icon: const Icon(Icons.logout)))
        ]));
  }

  Widget gradeListItem(int length, Grade grade) {
    if (length == 0) {
      return const SizedBox(
        width: 0,
        height: 0,
      );
    }
    return Padding(
        padding: EdgeInsets.only(
            top: 2,
            bottom: 2,
            left: screenWidth * 0.03,
            right: screenWidth * 0.03),
        child: Center(
            child: Container(
                decoration: BoxDecoration(
                    color: ElevationOverlay.applySurfaceTint(
                        Theme.of(context).colorScheme.background,
                        Theme.of(context).colorScheme.surfaceTint,
                        1),
                    borderRadius: BorderRadius.circular(20)),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor:
                          Theme.of(context).colorScheme.primaryContainer,
                      child: Center(
                        child: Text(grade.grade),
                      ),
                    ),
                    Flexible(
                        child: Padding(
                            padding: const EdgeInsets.only(left: 5),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "${grade.factor}x - ${grade.subjectName}",
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  grade.description,
                                  overflow: TextOverflow.ellipsis,
                                )
                              ],
                            )))
                  ],
                ))));
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return Scaffold(
          body: RefreshIndicator(
              onRefresh: () async {
                await account!.api.refreshGrades(account!.person);
                setState(() {});
              },
              child: Center(
                  child: RotaryScrollWrapper(
                      rotaryScrollbar: RotaryScrollbar(
                          controller: gradeViewScrollController),
                      child: ListView.builder(
                          controller: gradeViewScrollController,
                          itemCount: account!.person.grades.isEmpty
                              ? 1
                              : account!.person.grades.length,
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemBuilder: (context, ind) {
                            int length = account!.person.grades.length;
                            List<Grade> grades = account!.person.grades;
                            return length == 0
                                ? Column(
                                    children: [
                                      header(screenHeight, account!, () {}, 0,
                                          true),
                                      const Text(
                                        "Geen Resultaten",
                                        textAlign: TextAlign.center,
                                      ),
                                      gradesFooter()
                                    ],
                                  )
                                : length == 1
                                    ? Column(
                                        children: [
                                          header(screenHeight, account!, () {},
                                              0, true),
                                          gradeListItem(length, grades[ind]),
                                          gradesFooter()
                                        ],
                                      )
                                    : ind == 0
                                        ? Column(
                                            children: [
                                              header(screenHeight, account!,
                                                  () {}, 0, true),
                                              gradeListItem(length, grades[ind])
                                            ],
                                          )
                                        : ind == length - 1
                                            ? Column(children: [
                                                gradeListItem(
                                                    length, grades[ind]),
                                                gradesFooter()
                                              ])
                                            : gradeListItem(
                                                length, grades[ind]);
                          })))));
    });
  }
}

class LogoutScreen extends StatefulWidget {
  const LogoutScreen({super.key});

  @override
  State<StatefulWidget> createState() => _LogoutScreen();
}

class _LogoutScreen extends State<LogoutScreen> {
  final Account? account = Hive.box<Account>("accountList").values.first;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return Scaffold(
          body: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
            const Text("Uitloggen?"),
            const SizedBox(height: 10),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(40),
                      color: Theme.of(context).colorScheme.secondaryContainer),
                  child: IconButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      icon: const Icon(Icons.arrow_back))),
              const SizedBox(width: 10),
              Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(40),
                      color: Theme.of(context).colorScheme.errorContainer),
                  child: IconButton(
                      onPressed: () async {
                        await account!.api.logout();
                        SystemChannels.platform
                            .invokeMethod('SystemNavigator.pop');
                      },
                      icon: const Icon(Icons.logout)))
            ])
          ]));
    });
  }
}

class HomeworkScreen extends StatefulWidget {
  const HomeworkScreen({super.key, required this.text});

  final String text;

  @override
  State<StatefulWidget> createState() => _HomeworkScreen();
}

class _HomeworkScreen extends State<HomeworkScreen> {
  final Account? account = Hive.box<Account>("accountList").values.first;

  final homeworkViewScrollController = ScrollController();

  @override
  void dispose() {
    super.dispose();

    homeworkViewScrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return Scaffold(
          body: Center(
              child: RotaryScrollWrapper(
                  rotaryScrollbar:
                      RotaryScrollbar(controller: homeworkViewScrollController),
                  child: ListView.builder(
                      controller: homeworkViewScrollController,
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: 1,
                      itemBuilder: (_, __) {
                        return Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const SizedBox(height: 45),
                              const Text("Info"),
                              const SizedBox(height: 10),
                              Text(
                                widget.text.isNotEmpty
                                    ? widget.text
                                    : "Geen informatie over Huiswerk of Toets",
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 20),
                              Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(40),
                                            color: Theme.of(context)
                                                .colorScheme
                                                .secondaryContainer),
                                        child: IconButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            icon:
                                                const Icon(Icons.arrow_back))),
                                  ]),
                              const SizedBox(height: 45),
                            ]);
                      }))));
    });
  }
}
