import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:magiwatch/api/magister.dart';
import 'package:magiwatch/hive/adapters.dart';
import 'package:magiwatch/main.dart';

Future<Map?> getTokenSet(String input) async {
  String url = input.split("____")[0];
  String codeVerifier = input.split("____")[1];
  if (url.startsWith("refreshtoken")) {
    Account tempAccount = Account();

    tempAccount.apiStorage!.refreshToken =
        url.replaceFirst("refreshtoken=", "");
    await Magister(tempAccount).api.refreshToken();

    return {
      "access_token": tempAccount.apiStorage!.accessToken,
      "refresh_token": tempAccount.apiStorage!.refreshToken,
    };
  } else {
    String? code =
        Uri.parse(url.replaceFirst("#", "?")).queryParameters["code"];

    Response<Map> res = await Dio().post(
      "https://accounts.magister.net/connect/token",
      options: Options(
        contentType: "application/x-www-form-urlencoded",
      ),
      data:
          "code=$code&redirect_uri=m6loapp://oauth2redirect/&client_id=M6LOAPP&grant_type=authorization_code&code_verifier=$codeVerifier",
    );

    return res.data;
  }
}

Future<Account> getAccount(tokenSet) async {
  Magister magister = Magister(Account());
  magister.api.saveTokens(tokenSet);
  await magister.api.setTenant();
  await magister.api.setAccountDetails();

  if (Hive.box<Account>('accountList').values.isNotEmpty) {
    Hive.box<Account>('accountList').clear();
  }
  Hive.box<Account>('accountList').add(magister.account);

  return magister.account;
}

class MagisterApi extends Magister {
  MagisterApi(super.account);

  late Dio dio = Dio(
    BaseOptions(
        baseUrl: account.apiStorage?.baseUrl ?? "",
        headers: {"authorization": "Bearer ${account.apiStorage?.accessToken}"},
        connectTimeout: const Duration(seconds: 15)),
  )..interceptors.addAll([
      InterceptorsWrapper(
        onError: (e, handler) async {
          if (e.response?.data != null && e.response?.statusCode == 429) {
            debugPrint(
                "Limit reached... Please wait ${e.response?.data["secondsLeft"]} seconds.");
            // await RateLimitOverlay.of(navigatorKey.currentContext!)
            //     .during(Duration(seconds: e.response?.data["secondsLeft"] + 1));
            await Future.delayed(
                Duration(seconds: e.response?.data["secondsLeft"] + 1));
            //redo request
            await dio.fetch(e.requestOptions).then(
              (r) => handler.resolve(r),
              onError: (e) {
                debugPrint("retry failed");
                handler.next(e);
              },
            );
          } else {
            handler.next(e);
          }
        },
      ),
      QueuedInterceptorsWrapper(
        onRequest: (options, handler) async {
          debugPrint("request: ${options.uri.pathSegments.last}");
          if (account.apiStorage!.accessToken == null ||
              DateTime.now().millisecondsSinceEpoch >
                  account.apiStorage!.expiry!) {
            debugPrint("Accestoken expired");
            await refreshToken().onError((e, stack) {
              handler.reject(e as DioException);
              return;
            });
          }

          options.baseUrl = account.apiStorage!.baseUrl;

          options.headers["Authorization"] =
              "Bearer ${account.apiStorage!.accessToken}";

          return handler.next(options);
        },
        onError: (e, handler) async {
          var options = e.requestOptions;

          Future<void> retry() => dio.fetch(options).then(
                (r) => handler.resolve(r),
                onError: (e) => handler.reject(e),
              );

          if (e.response?.data == "SecurityToken Expired") {
            debugPrint("Request failed, token is invalid");

            if (options.headers["Authorization"] !=
                "Bearer ${account.apiStorage!.accessToken}") {
              options.headers["Authorization"] =
                  "Bearer ${account.apiStorage!.accessToken}";

              return await retry();
            }

            return await refreshToken().then((_) => retry()).onError(
                  (e, stack) => handler.reject(e as DioException),
                );
          }

          return handler.next(e);
        },
      ),
      QueuedInterceptorsWrapper(
        onError: (e, handler) async {
          int tries = 0;
          if (e.type == DioExceptionType.unknown ||
              e.type == DioExceptionType.connectionTimeout) {
            Future<void> retry() async {
              await dio.fetch(e.requestOptions).then(
                (r) => handler.resolve(r),
                onError: (e) async {
                  if (tries < 3) {
                    tries++;
                    await retry();
                  } else {
                    handler.reject(e);
                  }
                },
              );
            }

            await retry();
          } else {
            handler.next(e);
          }
        },
      ),
    ]);

  Future<void> refreshToken() async {
    await Dio(BaseOptions(
      contentType: Headers.formUrlEncodedContentType,
    ))
        .post<Map>(
      "https://accounts.magister.net/connect/token",
      data:
          "refresh_token=${account.apiStorage!.refreshToken}&client_id=M6LOAPP&grant_type=refresh_token",
    )
        .then((res) async {
      saveTokens(res.data!);
      if (account.isInBox) account.save();
    }).catchError((err) {
      if (err.response?.data != null &&
          (err.response?.data["error"] == "invalid_grant" ||
              err.response?.data["error"] == "invalid_request")) {
        rootScaffoldMessengerKey.currentState?.clearSnackBars();
        rootScaffoldMessengerKey.currentState?.showSnackBar(const SnackBar(
          duration: Duration(hours: 4),
          showCloseIcon: true,
          content: Text(
              "Sessie verlopen. Log uit en log opnieuw in via MagiWatch Connect"),
        ));
      }
      throw err;
    });
  }

  void saveTokens(tokenSet) {
    account.apiStorage!.accessToken = tokenSet["access_token"];
    account.apiStorage!.refreshToken = tokenSet["refresh_token"];
    account.apiStorage!.idToken ??= tokenSet["id_token"];
    account.apiStorage!.expiry =
        DateTime.now().add(const Duration(hours: 1)).millisecondsSinceEpoch;
  }

  Future<void> setTenant() async {
    Map body = (await Dio().get(
            "https://magister.net/.well-known/host-meta.json?rel=magister-api",
            options: Options(headers: {
              "Authorization": "Bearer ${account.apiStorage!.accessToken}"
            })))
        .data;
    account.apiStorage!.baseUrl =
        "https://${Uri.parse(body["links"].first["href"]).host}/";
  }

  Future<void> setAccountDetails() async {
    Map res = (await dio.get("api/account")).data;

    account.id = res["Persoon"]["Id"];

    Future<void> initPerson(Person person) async {
      await refreshCalendarEvents(person);
      await refreshGrades(person);

      account.person = person;
    }

    await initPerson(Person(
        id: res["Persoon"]["Id"],
        firstName: res["Persoon"]["Roepnaam"] ?? res["Persoon"]["Voorletters"],
        middleName: res["Persoon"]["Tussenvoegsel"],
        lastName: res["Persoon"]["Achternaam"]));

    if (account.isInBox) account.save();
  }
}
