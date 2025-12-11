import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'services/firebase_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:timezone/data/latest.dart' as tz;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  tz.initializeTimeZones();

  await FirebaseService.instance.init();

  runApp(const RecipeApp());
}

class RecipeApp extends StatelessWidget {
  const RecipeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Recipe Browser',
      theme: ThemeData(primarySwatch: Colors.teal, useMaterial3: true),
      home: const HomeScreen(),
    );
  }
}
