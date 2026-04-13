import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive
  await Hive.initFlutter();
  
  // Open boxes
  await Future.wait([
    Hive.openBox('tasks'),
    Hive.openBox('resources'),
    Hive.openBox('resource_files'),
    Hive.openBox('profile'),
    Hive.openBox('settings'),
  ]);
  
  runApp(
    ProviderScope(
      child: StudyFlowApp(),
    ),
  );
}
