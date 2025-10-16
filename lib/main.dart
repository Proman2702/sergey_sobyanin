import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:sergey_sobyanin/features/error_screen.dart';
import 'package:sergey_sobyanin/features/screen/screen.dart';
import 'firebase_options.dart';
import 'dart:ui_web' as ui_web;
import 'dart:html' as html;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  ui_web.platformViewRegistry.registerViewFactory(
    'camera-stream',
    (int viewId) => html.VideoElement()
      ..autoplay = true
      ..muted = true
      ..style.width = '100%'
      ..style.height = '100%',
  );

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: ErrorNotifier.navigatorKey,
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const Screen(),
      },
      theme: ThemeData(fontFamily: "Jura"),
    );
  }
}
