import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_wear_os_connectivity/flutter_wear_os_connectivity.dart';
import 'package:magiwatch/api/magister/login.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    systemNavigationBarColor: Colors.transparent,
  ));
  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.edgeToEdge,
  );

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
      builder: (_, __) {
        ColorScheme lightColorScheme;
        ColorScheme darkColorScheme;
        //Not using Material You colors set by Android S+ devices
        lightColorScheme = ColorScheme.fromSeed(
          seedColor: Color(const Color.fromARGB(255, 244, 123, 3).value),
        ).harmonized();
        darkColorScheme = ColorScheme.fromSeed(
          seedColor: Color(const Color.fromARGB(255, 244, 123, 3).value),
          brightness: Brightness.dark,
        ).harmonized();

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
          title: 'MagiWatch Connect',
          debugShowCheckedModeBanner: false,
          theme: theme(),
          home: const Start(),
        );
      },
    );
  }
}

class Start extends StatefulWidget {
  const Start({super.key});

  @override
  State<StatefulWidget> createState() => _Start();
}

class _Start extends State<Start> {
  FlutterWearOsConnectivity? _flutterWearOsConnectivity;
  List<WearOsDevice>? _connectedDevices;

  @override
  void initState() {
    super.initState();

    connect();
  }

  Future<void> connect() async {
    _flutterWearOsConnectivity = FlutterWearOsConnectivity();
    _flutterWearOsConnectivity?.configureWearableAPI();

    _connectedDevices = await _flutterWearOsConnectivity?.getConnectedDevices();
    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();

    _flutterWearOsConnectivity?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return Scaffold(
          appBar: AppBar(
            title: Center(
                child: Text("MagiWatch Connect",
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.onBackground,
                        fontWeight: FontWeight.w500))),
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          ),
          body: Padding(
              padding: const EdgeInsets.all(15),
              child: _connectedDevices != null &&
                      _flutterWearOsConnectivity != null
                  ? Column(children: [
                      const Text(
                          "Selecteer een apparaat om te verbinden. Zorg dat de app geopend is en nog niet is ingelogd."),
                      const SizedBox(
                        height: 4,
                      ),
                      Expanded(
                          child: _connectedDevices!.isNotEmpty
                              ? ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: _connectedDevices!.length,
                                  itemBuilder: (context, ind) {
                                    return Card(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .surfaceVariant,
                                        margin: const EdgeInsets.only(top: 10),
                                        child: Padding(
                                            padding: const EdgeInsets.all(10),
                                            child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.stretch,
                                                children: [
                                                  Text(
                                                    _connectedDevices![ind]
                                                        .name,
                                                    style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        fontSize: 16),
                                                  ),
                                                  const SizedBox(height: 8),
                                                  FilledButton(
                                                      onPressed: () {
                                                        Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                                builder: (context) => SignIn(
                                                                    deviceId: _connectedDevices![
                                                                            ind]
                                                                        .id)));
                                                      },
                                                      child: const Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Icon(Icons.login),
                                                          SizedBox(width: 8),
                                                          Text(
                                                              "Verbinden met Magister"),
                                                        ],
                                                      ))
                                                ])));
                                  })
                              : const Center(
                                  child: Text(
                                      "Geen verbonden apparaten gevonden")))
                    ])
                  : const Column(children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 8),
                      Text(
                        "Verbonden apparaten ophalen...",
                        style: TextStyle(fontSize: 25),
                        textAlign: TextAlign.center,
                      )
                    ])));
    });
  }
}
