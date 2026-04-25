import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'app.dart';
import 'core/database/database_service.dart';
import 'core/services/fcm_service.dart';
import 'features/onboarding/presentation/pages/onboarding_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  } else {
    await Firebase.initializeApp();
    await FcmService.instance.initialize();
  }

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  await DatabaseService.instance.database;

  final prefs = await SharedPreferences.getInstance();
  final onboardingDone = prefs.getBool(kOnboardingKey) ?? false;

  runApp(
    ProviderScope(
      overrides: [
        onboardingDoneSyncProvider.overrideWith((ref) => onboardingDone),
      ],
      child: const BelloHorizonteApp(),
    ),
  );
}
