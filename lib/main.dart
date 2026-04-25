import 'package:flutter/material.dart';
import 'screens/home_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const CaseDairy());
}

class CaseDairy extends StatelessWidget {
  const CaseDairy({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Case Diary',

      // 🔹 Theme
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.grey[100],
      ),

      // 🔹 Home Screen
      home: HomePage(),
    );
  }
}