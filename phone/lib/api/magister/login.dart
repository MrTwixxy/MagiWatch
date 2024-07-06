import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:magiwatch/api/magister/api.dart';
import 'package:webview_flutter/webview_flutter.dart';

class SignIn extends StatefulWidget {
  final String deviceId;
  const SignIn({super.key, required this.deviceId});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  ValueNotifier<Map<dynamic, dynamic>?> tokenSet = ValueNotifier(null);

  @SemanticsHintOverrides()
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => setTokenSet());
  }

  Future<void> setTokenSet() async {
    tokenSet.value = await showMagisterLoginDialog(context, widget.deviceId)
        .onError((error, stackTrace) => null);
    //If the dialog was dismissed and no token was retrieved, return to the previous page.
    if (tokenSet.value == null) {
      WidgetsBinding.instance
          .addPostFrameCallback((_) async => Navigator.of(context).pop());
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: tokenSet,
      builder: (context, value, widget) {
        return const Center(child: LinearProgressIndicator());
      },
    );
  }
}

Future<Map<dynamic, dynamic>?> showMagisterLoginDialog(
    BuildContext context, String deviceId) async {
  ValueNotifier<Uri?> redirectUrl = ValueNotifier<Uri?>(null);

  //Settings for the webview (iOS & Android only)
  late WebViewController webViewController = WebViewController()
    ..setJavaScriptMode(JavaScriptMode.unrestricted)
    ..setNavigationDelegate(
      NavigationDelegate(
        onNavigationRequest: (NavigationRequest request) {
          if (request.url.contains("#code")) {
            redirectUrl.value = Uri.parse(request.url);
            return NavigationDecision.prevent;
          }
          return NavigationDecision.navigate;
        },
      ),
    );

  Future<void> returnWithTokenSet(Uri redirectURL) async {
    await sendUrl(redirectUrl.value.toString(), deviceId);
    if (!context.mounted) return;
    Navigator.of(context).pop();
  }

  return await showDialog<Map<dynamic, dynamic>?>(
    context: context,
    useSafeArea: false,
    builder: (BuildContext context) {
      return Dialog.fullscreen(
          backgroundColor: Colors.transparent,
          child: Scaffold(
            appBar: AppBar(
              title: const Text("Inloggen"),
              actions: ([
                IconButton(
                    onPressed: () => webViewController
                        .loadRequest(Uri.parse(generateLoginURL())),
                    icon: const Icon(Icons.refresh)),
              ]),
            ),
            body: SafeArea(
              child: ValueListenableBuilder(
                valueListenable: redirectUrl,
                builder: (context, value, child) {
                  if (value != null) {
                    //Redirect value has been set!
                    returnWithTokenSet(value);
                    return const Center(child: CircularProgressIndicator());
                  }
                  //Waiting for redirectUrl

                  WebViewCookieManager().clearCookies();
                  return WebViewWidget(
                      controller: webViewController
                        ..loadRequest(Uri.parse(generateLoginURL())));
                },
              ),
            ),
          ));
    },
  );
}
