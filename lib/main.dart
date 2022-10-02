import 'dart:io';

import 'package:desktop_window/desktop_window.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firedart/firestore/firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'res/app_theme.dart';
import 'services/audio_handler_service.dart';
import 'ui/home.dart';

Future<void> main() async {
  // Call this first
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isAndroid || Platform.isIOS) {
// To disable vertical orientation
    SystemChrome.setPreferredOrientations(<DeviceOrientation>[
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

// Init firebase
    await Firebase.initializeApp();
  } else {
    await DesktopWindow.setWindowSize(const Size(500, 900));
    await DesktopWindow.setMinWindowSize(const Size(500, 900));
    Firestore.initialize("audyoplayer");
  }

  await AudioHandlerService.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.appThemeData,
      home: const Home(),
    );
  }
}
