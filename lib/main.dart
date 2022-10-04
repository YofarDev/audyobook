import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firedart/firestore/firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:window_manager/window_manager.dart';

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
    await windowManager.ensureInitialized();

    const WindowOptions windowOptions = WindowOptions(
      size: Size(500, 900),
      skipTaskbar: false,
      minimumSize: Size(500, 900),
      maximumSize: Size(500, 900),
      titleBarStyle: TitleBarStyle.normal,
    );
    
    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
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
