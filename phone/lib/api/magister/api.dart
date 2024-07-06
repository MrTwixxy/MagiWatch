import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter_wear_os_connectivity/flutter_wear_os_connectivity.dart';
import 'package:pointycastle/export.dart' as castle;

Map? preFill;
String codeVerifier = generateRandomString();

String generateRandomString() {
  var r = Random.secure();
  var chars = '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';
  return Iterable.generate(50, (_) => chars[r.nextInt(chars.length)]).join();
}

String generateLoginURL({String? tenant, String? username}) {
  String generateRandomBase64(length) {
    var r = Random.secure();
    var chars = 'abcdef0123456789';
    return Iterable.generate(length, (_) => chars[r.nextInt(chars.length)])
        .join();
  }

  String nonce = generateRandomBase64(32);
  String state = generateRandomString();
  String codeChallenge = base64Url
      .encode(castle.SHA256Digest()
          .process(Uint8List.fromList(codeVerifier.codeUnits)))
      .replaceAll('=', '');
  String str =
      "https://accounts.magister.net/connect/authorize?client_id=M6LOAPP&redirect_uri=m6loapp%3A%2F%2Foauth2redirect%2F&scope=openid%20profile%20offline_access%20magister.mobile%20magister.ecs&response_type=code%20id_token&state=$state&nonce=$nonce&code_challenge=$codeChallenge&code_challenge_method=S256";
  if (tenant != null) {
    str += "&acr_values=tenant:${Uri.parse(tenant).host}&prompt=select_account";
    if (username != null) str += "&login_hint=${preFill?['username']}";
  }
  return str;
}

Future<bool> sendUrl(String url, String deviceId) async {
  FlutterWearOsConnectivity flutterWearOsConnectivity =
      FlutterWearOsConnectivity();
  flutterWearOsConnectivity.configureWearableAPI();

  List<WearOsDevice> connectedDevices =
      await flutterWearOsConnectivity.getConnectedDevices();

  if (connectedDevices.isNotEmpty) {
    Uint8List uint8List = utf8.encode("${url}____$codeVerifier");
    await flutterWearOsConnectivity.sendMessage(uint8List,
        deviceId: deviceId,
        path: "/magisterAuth",
        priority: MessagePriority.high);
  }

  return true;
}
