import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'services/auth_service.dart';
import 'services/data_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Date names for English and Arabic (used by History, Reports, date picker).
  await initializeDateFormatting();

  final prefs = await SharedPreferences.getInstance();

  runApp(
    MizaniaApp(
      prefs: prefs,
      // Phase 3 uses the on-device services below. Phase 4: replace them with
      // a FirebaseAuthService and an sqflite-based DataRepository.
      authService: LocalAuthService(prefs),
      repository: LocalDataRepository(prefs),
    ),
  );
}
