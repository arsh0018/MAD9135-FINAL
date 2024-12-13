import 'package:arsh_final/screens/welcome_screen.dart';
import 'package:arsh_final/utils/app_state.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  await dotenv.load(fileName: ".env");
  runApp(ChangeNotifierProvider(
    create: (context) => AppState(),
    child: MainApp(),
  ));
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: WelcomeScreen(),
    );
  }
}
